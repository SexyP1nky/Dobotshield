$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$labRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $labRoot
$results = Join-Path $labRoot "results\e2e_produto"
$network = "dobotshield_waflab"
$backendName = "lab_e2e_backend"
$wafName = "lab_e2e_dobotshield"
$pythonImage = "python:3-alpine@sha256:26730869004e2b9c4b9ad09cab8625e81d256d1ce97e72df5520e806b1709f92"

New-Item -ItemType Directory -Force -Path $results | Out-Null
$resolvedResults = (Resolve-Path -LiteralPath $results).Path
foreach ($name in @("e2e-training.jsonl", "e2e-report.html", "config-gerada.env", "09_e2e_resultados.csv", "09_e2e.log")) {
    $path = Join-Path $resolvedResults $name
    if ((Split-Path $path -Parent) -ne $resolvedResults) { throw "Caminho E2E fora da pasta validada" }
    Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
}

$log = Join-Path $resolvedResults "09_e2e.log"
$configPath = Join-Path $resolvedResults "config-gerada.env"
$configLines = & node (Join-Path $repoRoot "admin-config\tests\export-e2e-config.mjs")
if ($LASTEXITCODE -ne 0) { throw "Falha ao gerar configuracao pela Admin UI" }
$configLines | Set-Content -LiteralPath $configPath -Encoding utf8

$envArgs = @()
foreach ($line in $configLines) {
    if (-not $line -or $line.StartsWith("#")) { continue }
    $separator = $line.IndexOf("=")
    if ($separator -lt 1) { throw "Linha .env invalida: $line" }
    $key = $line.Substring(0, $separator)
    $encodedValue = $line.Substring($separator + 1)
    $value = $encodedValue | ConvertFrom-Json
    $envArgs += @("-e", "$key=$value")
}

$expectedKeys = @(
    "TARGET_URL", "PROXY_PORT", "HTTP_MODE", "ENABLE_WAF", "WAF_MODE",
    "ENABLE_RESPONSE_INSPECTION", "ENABLE_RATE_LIMIT", "RATE_LIMIT", "BURST_LIMIT",
    "MAX_CONNS", "MAX_TRACKED_IPS", "MAX_BODY_SIZE", "RESPONSE_INSPECTION_LIMIT",
    "CERT_FILE", "KEY_FILE", "TRUSTED_PROXIES", "INSECURE_SKIP_VERIFY",
    "CONTENT_SECURITY_POLICY", "WAF_ALLOWLIST", "BLOCKED_IPS", "RATE_LIMIT_STATE_FILE",
    "TRAINING_MODE", "TRAINING_LOG_FILE"
)
$actualKeys = @($configLines | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object { $_.Split("=", 2)[0] })
if (Compare-Object $expectedKeys $actualKeys) { throw "Configuracao gerada nao contem exatamente as 23 variaveis esperadas" }

$backendFile = (Resolve-Path -LiteralPath (Join-Path $labRoot "helpers\e2e_backend.py")).Path.Replace("\", "/")
$resultsFwd = $resolvedResults.Replace("\", "/")
$wafImage = (& docker inspect -f "{{.Config.Image}}" lab_dobot_dvwa).Trim()
if ($LASTEXITCODE -ne 0 -or -not $wafImage) { throw "Imagem do DoBotShield da bancada nao encontrada" }

function Remove-E2EContainers {
    foreach ($container in @($wafName, $backendName)) {
        $existingIds = @(& docker ps -aq --filter "name=^${container}$" 2>$null)
        if ($existingIds.Count -gt 0 -and $existingIds[0]) {
            & docker rm -f $container 2>$null | Out-Null
        }
    }
}

function Invoke-Probe {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [string[]]$Headers = @()
    )
    $headersFile = Join-Path $resolvedResults ("{0}_headers.txt" -f $Name)
    $bodyFile = Join-Path $resolvedResults ("{0}_body.txt" -f $Name)
    $args = @("-sS", "--max-time", "15", "-X", $Method, "-D", $headersFile, "-o", $bodyFile, "-w", "%{http_code}")
    foreach ($header in $Headers) { $args += @("-H", $header) }
    $args += $Url
    $statusText = (& curl.exe @args).Trim()
    $curlRc = $LASTEXITCODE
    $status = 0
    [void][int]::TryParse($statusText, [ref]$status)
    $headerText = if (Test-Path $headersFile) { Get-Content $headersFile -Raw } else { "" }
    $bodyText = if (Test-Path $bodyFile) { Get-Content $bodyFile -Raw } else { "" }
    $action = if ($headerText -match "(?im)^X-DoBotShield-Action:\s*([^\r\n]+)") { $Matches[1].Trim() } else { "" }
    [pscustomobject]@{ Name=$Name; HTTP=$status; Action=$action; CurlRC=$curlRc; Headers=$headerText; Body=$bodyText }
}

Remove-E2EContainers
try {
    & docker run -d --name $backendName --network $network -v "${backendFile}:/app/e2e_backend.py:ro" $pythonImage python /app/e2e_backend.py | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Falha ao iniciar backend E2E" }

    $dockerArgs = @("run", "-d", "--name", $wafName, "--network", $network, "-p", "127.0.0.1:18088:8088", "-v", "${resultsFwd}:/logs")
    $dockerArgs += $envArgs
    $dockerArgs += $wafImage
    & docker @dockerArgs | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Falha ao iniciar DoBotShield E2E" }

    $ready = $false
    for ($attempt = 1; $attempt -le 60; $attempt++) {
        & curl.exe -sS --max-time 2 -o NUL "http://127.0.0.1:18088/benign"
        if ($LASTEXITCODE -eq 0) { $ready = $true; break }
        Start-Sleep -Seconds 1
    }
    if (-not $ready) { throw "DoBotShield E2E nao ficou pronto" }

    $probes = @()
    $probes += Invoke-Probe "benigno" "GET" "http://127.0.0.1:18088/benign"
    $probes += Invoke-Probe "xss" "GET" "http://127.0.0.1:18088/search?q=%3Cscript%3Ealert(1)%3C%2Fscript%3E"
    $probes += Invoke-Probe "cmd" "GET" "http://127.0.0.1:18088/run?ip=127.0.0.1%3Bid"
    $probes += Invoke-Probe "sqli_booleana" "GET" "http://127.0.0.1:18088/items?id=1%20AND%201%20LIKE%201"
    $probes += Invoke-Probe "resposta_sql" "GET" "http://127.0.0.1:18088/leak"
    $probes += Invoke-Probe "trace" "TRACE" "http://127.0.0.1:18088/benign"
    $probes += Invoke-Probe "headers" "GET" "http://127.0.0.1:18088/headers" @("X-Forwarded-For: 198.51.100.20")

    $expected = @{
        benigno=@(200,"Forwarded"); xss=@(400,"Blocked-WAF"); cmd=@(400,"Blocked-WAF");
        sqli_booleana=@(200,"Forwarded"); resposta_sql=@(502,"Blocked-Response-WAF"); trace=@(405,""); headers=@(200,"Forwarded")
    }
    foreach ($probe in $probes) {
        $want = $expected[$probe.Name]
        if ($probe.CurlRC -ne 0 -or $probe.HTTP -ne $want[0] -or ($want[1] -and $probe.Action -ne $want[1])) {
            throw "Probe $($probe.Name) divergiu: HTTP=$($probe.HTTP), Action=$($probe.Action), CurlRC=$($probe.CurlRC)"
        }
    }

    $headerProbe = $probes | Where-Object Name -eq "headers"
    $forwarded = ($headerProbe.Body | ConvertFrom-Json).x_forwarded_for
    $proto = ($headerProbe.Body | ConvertFrom-Json).x_forwarded_proto
    if ($forwarded -match "198\.51\.100\.20" -or $forwarded -match "," -or $proto -ne "http") {
        throw "Headers encaminhados incorretamente: XFF=$forwarded, proto=$proto"
    }

    Start-Sleep -Milliseconds 800
    $trainingPath = Join-Path $resolvedResults "e2e-training.jsonl"
    if (-not (Test-Path $trainingPath)) { throw "Log de treinamento E2E ausente" }
    $events = @(Get-Content $trainingPath | Where-Object { $_.Trim() } | ForEach-Object { $_ | ConvertFrom-Json })
    foreach ($category in @("XSS", "CMD_INJ", "RESPONSE_SQL_ERROR")) {
        if (-not ($events | Where-Object category -eq $category)) { throw "Evento $category ausente no treinamento E2E" }
    }

    $reportPath = Join-Path $resolvedResults "e2e-report.html"
    & go run ./cmd/report -in $trainingPath -out $reportPath
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $reportPath)) { throw "Geracao do relatorio E2E falhou" }

    $probes | Select-Object Name,HTTP,Action,CurlRC | Export-Csv -LiteralPath (Join-Path $resolvedResults "09_e2e_resultados.csv") -NoTypeInformation -Encoding utf8
    @(
        "E2E_PRODUTO=OK",
        "CONFIG_VARIAVEIS=$($actualKeys.Count)",
        "PROBES=$($probes.Count)",
        "EVENTOS_TREINAMENTO=$($events.Count)",
        "XFF_BACKEND=$forwarded",
        "X_FORWARDED_PROTO=$proto",
        "RELATORIO=$reportPath"
    ) | Set-Content -LiteralPath $log -Encoding utf8
    Get-Content $log
}
finally {
    Remove-E2EContainers
}
