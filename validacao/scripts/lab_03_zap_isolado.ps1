param(
    [int]$TentativasPorCenario = 2
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$labRoot = Split-Path -Parent $PSScriptRoot
$results = Join-Path $labRoot "results"
$helpers = Join-Path $labRoot "helpers"
$one = Join-Path $PSScriptRoot "lab_03_zap_one.bat"
$network = "dobotshield_waflab"
$pythonImage = "python:3-alpine@sha256:26730869004e2b9c4b9ad09cab8625e81d256d1ce97e72df5520e806b1709f92"
$curlImage = "curlimages/curl:latest@sha256:7c12af72ceb38b7432ab85e1a265cff6ae58e06f95539d539b654f2cfa64bb13"

$allTargets = @(
    "lab_dvwa", "lab_xvwa", "lab_xvwa_db",
    "lab_dobot_dvwa", "lab_dobot_xvwa",
    "lab_modsec_dvwa", "lab_modsec_xvwa",
    "lab_coraza_dvwa", "lab_coraza_xvwa"
)

$scenarios = @(
    [pscustomobject]@{ App = "dvwa"; Scenario = "no_waf"; Backend = "lab_dvwa"; Waf = ""; Required = @("lab_dvwa"); Scheme = "http"; Port = 80; Path = "" },
    [pscustomobject]@{ App = "dvwa"; Scenario = "modsecurity"; Backend = "lab_dvwa"; Waf = "lab_modsec_dvwa"; Required = @("lab_dvwa", "lab_modsec_dvwa"); Scheme = "https"; Port = 8443; Path = "" },
    [pscustomobject]@{ App = "dvwa"; Scenario = "dobotshield"; Backend = "lab_dvwa"; Waf = "lab_dobot_dvwa"; Required = @("lab_dvwa", "lab_dobot_dvwa"); Scheme = "https"; Port = 443; Path = "" },
    [pscustomobject]@{ App = "dvwa"; Scenario = "coraza"; Backend = "lab_dvwa"; Waf = "lab_coraza_dvwa"; Required = @("lab_dvwa", "lab_coraza_dvwa"); Scheme = "https"; Port = 443; Path = "" },
    [pscustomobject]@{ App = "xvwa"; Scenario = "no_waf"; Backend = "lab_xvwa"; Waf = ""; Required = @("lab_xvwa_db", "lab_xvwa"); Scheme = "http"; Port = 80; Path = "/xvwa/" },
    [pscustomobject]@{ App = "xvwa"; Scenario = "modsecurity"; Backend = "lab_xvwa"; Waf = "lab_modsec_xvwa"; Required = @("lab_xvwa_db", "lab_xvwa", "lab_modsec_xvwa"); Scheme = "https"; Port = 8443; Path = "/xvwa/" },
    [pscustomobject]@{ App = "xvwa"; Scenario = "dobotshield"; Backend = "lab_xvwa"; Waf = "lab_dobot_xvwa"; Required = @("lab_xvwa_db", "lab_xvwa", "lab_dobot_xvwa"); Scheme = "https"; Port = 443; Path = "/xvwa/" },
    [pscustomobject]@{ App = "xvwa"; Scenario = "coraza"; Backend = "lab_xvwa"; Waf = "lab_coraza_xvwa"; Required = @("lab_xvwa_db", "lab_xvwa", "lab_coraza_xvwa"); Scheme = "https"; Port = 443; Path = "/xvwa/" }
)

function Invoke-Docker {
    param([string[]]$Arguments, [switch]$IgnoreExitCode)
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & docker @Arguments 2>&1
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if (-not $IgnoreExitCode -and $code -ne 0) {
        throw "Docker falhou (RC=$code): docker $($Arguments -join ' ')`n$($output -join "`n")"
    }
    return $output
}

function Set-TargetServices {
    param([string[]]$Required)
    foreach ($container in $allTargets) {
        if ($Required -notcontains $container) {
            Invoke-Docker -Arguments @("stop", "--time", "20", $container) -IgnoreExitCode | Out-Null
        }
    }
    foreach ($container in $Required) {
        Invoke-Docker -Arguments @("start", $container) | Out-Null
    }
    if ($Required -contains "lab_modsec_dvwa") {
        Invoke-Docker -Arguments @("exec", "lab_modsec_dvwa", "nginx", "-s", "reload") -IgnoreExitCode | Out-Null
    }
    if ($Required -contains "lab_modsec_xvwa") {
        Invoke-Docker -Arguments @("exec", "lab_modsec_xvwa", "nginx", "-s", "reload") -IgnoreExitCode | Out-Null
    }
}

function Get-ContainerIp {
    param([string]$Container)
    $ip = (Invoke-Docker -Arguments @("inspect", "-f", "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}", $Container) | Select-Object -Last 1).Trim()
    if (-not $ip) {
        throw "IP vazio para $Container"
    }
    return $ip
}

function Wait-Url {
    param([string]$Url)
    for ($attempt = 1; $attempt -le 60; $attempt++) {
        & docker run --rm --network $network $curlImage -k -sS -o /dev/null --max-time 5 $Url 2>$null
        if ($LASTEXITCODE -eq 0) {
            return
        }
        Start-Sleep -Seconds 2
    }
    throw "Alvo não ficou disponível: $Url"
}

function Get-DvwaCookie {
    param([string]$DvwaIp)
    $helpersForward = $helpers.Replace("\", "/")
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & docker run --rm --network $network -v "${helpersForward}:/scripts:ro" $pythonImage python /scripts/dvwa_login.py --no-setup "http://${DvwaIp}:80" 2>&1
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($code -ne 0) {
        throw "Falha ao renovar cookie do DVWA: $($output -join "`n")"
    }
    $cookie = ($output | Where-Object { $_ -match "PHPSESSID=" } | Select-Object -Last 1).Trim().Replace("; ", ";")
    if (-not $cookie) {
        throw "Cookie do DVWA não foi retornado."
    }
    Set-Content -LiteralPath (Join-Path $helpers "dvwa_cookie.txt") -Value $cookie -Encoding ASCII
    return $cookie
}

New-Item -ItemType Directory -Path $results -Force | Out-Null
$cookie = ""
$failures = @()

try {
    foreach ($scenario in $scenarios) {
        Write-Host ""
        Write-Host "=== ZAP isolado: $($scenario.App)/$($scenario.Scenario) ==="
        Set-TargetServices -Required $scenario.Required
        Start-Sleep -Seconds 8

        $targetContainer = if ($scenario.Waf) { $scenario.Waf } else { $scenario.Backend }
        $ip = Get-ContainerIp -Container $targetContainer
        $url = "{0}://{1}:{2}{3}" -f $scenario.Scheme, $ip, $scenario.Port, $scenario.Path
        Wait-Url -Url $url

        if ($scenario.App -eq "dvwa" -and -not $cookie) {
            $dvwaIp = Get-ContainerIp -Container "lab_dvwa"
            $cookie = Get-DvwaCookie -DvwaIp $dvwaIp
        }

        $outDir = Join-Path $results (Join-Path $scenario.App $scenario.Scenario)
        $completed = $false
        for ($attempt = 1; $attempt -le $TentativasPorCenario; $attempt++) {
            Write-Host "Tentativa $attempt/$TentativasPorCenario em $url"
            $zapDir = Join-Path $outDir "zap"
            foreach ($reportName in @("zap_report.html", "zap_report.json", "zap_report.md")) {
                $reportPath = Join-Path $zapDir $reportName
                if (Test-Path -LiteralPath $reportPath) {
                    Remove-Item -LiteralPath $reportPath -Force
                }
            }
            $command = "call `"$one`" `"$($scenario.App)`" `"$($scenario.Scenario)`" `"$url`" `"$($scenario.Backend)`" `"$($scenario.Waf)`" `"$cookie`""
            & cmd.exe /d /c $command

            $log = Join-Path $outDir "02_zap.log"
            $json = Join-Path $outDir "zap\zap_report.json"
            $logText = if (Test-Path -LiteralPath $log) { Get-Content -LiteralPath $log -Raw } else { "" }
            $toolRc = if ($logText -match "TOOL_RC=(-?\d+)") { [int]$Matches[1] } else { 999 }
            $jsonValid = $false
            if (Test-Path -LiteralPath $json) {
                try {
                    Get-Content -LiteralPath $json -Raw | ConvertFrom-Json | Out-Null
                    $jsonValid = $true
                }
                catch {
                    $jsonValid = $false
                }
            }
            if ($toolRc -eq 0 -and $jsonValid) {
                $completed = $true
                break
            }

            if (Test-Path -LiteralPath $log) {
                $failedLog = Join-Path $outDir ("02_zap_falha_infra_tentativa_{0}.log" -f $attempt)
                Copy-Item -LiteralPath $log -Destination $failedLog -Force
            }
            if ($attempt -lt $TentativasPorCenario) {
                Start-Sleep -Seconds 20
            }
        }

        if (-not $completed) {
            $failures += "$($scenario.App)/$($scenario.Scenario)"
        }
    }
}
finally {
    Write-Host ""
    Write-Host "Restaurando todos os serviços da bancada..."
    foreach ($container in $allTargets) {
        Invoke-Docker -Arguments @("start", $container) -IgnoreExitCode | Out-Null
    }
}

if ($failures.Count -gt 0) {
    throw "ZAP não concluiu após as tentativas: $($failures -join ', ')"
}

Write-Host "ZAP concluiu os 8 cenários com relatórios JSON."
