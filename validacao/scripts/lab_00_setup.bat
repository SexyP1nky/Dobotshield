@echo off
REM ============================================================================
REM  lab_00_setup.bat  --  ETAPA 1: dependencias + login DVWA + cookie
REM
REM  Faz TUDO que precisa existir antes da bateria:
REM    - verifica Docker
REM    - gera certificado TLS auto-assinado (SAN p/ todos os hosts do lab)
REM    - baixa (pull) e constroi (build) TODAS as imagens necessarias
REM    - sobe o DVWA, cria o banco, faz login (admin/password),
REM      define DVWA Security = "low" e CAPTURA O COOKIE de sessao
REM    - salva o cookie em helpers\dvwa_cookie.txt (usado pelas ferramentas)
REM    - escreve results\METODOLOGIA.txt
REM
REM  Rode este .bat PRIMEIRO. Depois: lab_01_subir.bat e as ferramentas.
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fI"

set "COMPOSE=%ROOT%\docker-compose.lab.yml"
set "CERT_DIR=%ROOT%\certs"
set "SCRIPTS_DIR=%ROOT%\helpers"
set "RESULTS=%ROOT%\results"
set "NET=dobotshield_waflab"

set "CERT_FWD=%CERT_DIR:\=/%"
set "SCRIPTS_FWD=%SCRIPTS_DIR:\=/%"
set "COOKIE_FILE=%SCRIPTS_DIR%\dvwa_cookie.txt"

REM Imagens construidas localmente (referenciadas pelos .bat de ferramenta)
set "IMG_TOOLS=dobotshield/lab-tools:latest"
set "IMG_WRK=dobotshield/wrk:latest"
REM Imagens externas
set "IMG_TESTSSL=drwetter/testssl.sh:latest"
set "IMG_ZAP=zaproxy/zap-stable:latest"
set "IMG_PY=python:3-alpine"
set "IMG_CURL=curlimages/curl:latest"

set /a STEP=0

echo.
echo ============================================================
echo   DoBotShield Lab  --  SETUP (dependencias + login DVWA)
echo   Inicio: %DATE% %TIME%
echo ============================================================

REM --------------------------------------------------------------------------
call :step "Verificando Docker"
where docker >nul 2>&1 || ( echo [ERRO] docker nao encontrado no PATH. & exit /b 10 )
docker info >nul 2>&1 || ( echo [ERRO] Docker engine inacessivel. Abra o Docker Desktop. & exit /b 11 )
echo   Docker OK.

REM --------------------------------------------------------------------------
call :step "Gerando certificado TLS auto-assinado (se necessario)"
call :ensure_cert || exit /b %ERRORLEVEL%

REM --------------------------------------------------------------------------
call :step "Validando script de login DVWA"
if not exist "%SCRIPTS_DIR%\dvwa_login.py" (
    echo [ERRO] %SCRIPTS_DIR%\dvwa_login.py nao encontrado.
    exit /b 12
)
echo   OK: %SCRIPTS_DIR%\dvwa_login.py

REM --------------------------------------------------------------------------
call :step "Baixando imagens externas (testssl, ZAP, python, curl)"
docker pull %IMG_TESTSSL% || echo   [AVISO] pull de %IMG_TESTSSL% falhou (tentar novamente depois).
docker pull %IMG_ZAP%     || echo   [AVISO] pull de %IMG_ZAP% falhou. Alternativa: ghcr.io/zaproxy/zaproxy:stable
docker pull %IMG_PY%      || echo   [AVISO] pull de %IMG_PY% falhou.
docker pull %IMG_CURL%    || echo   [AVISO] pull de %IMG_CURL% falhou.

REM --------------------------------------------------------------------------
call :step "Construindo imagem de ferramentas (sqlmap + XSStrike + commix)"
docker build -t %IMG_TOOLS% "%ROOT%\docker\lab-tools" || ( echo [ERRO] build lab-tools falhou. & exit /b 20 )

call :step "Construindo imagem wrk"
docker build -t %IMG_WRK% "%ROOT%\docker\wrk" || ( echo [ERRO] build wrk falhou. & exit /b 21 )

REM --------------------------------------------------------------------------
call :step "Baixando imagens das aplicacoes e do ModSecurity"
docker pull vulnerables/web-dvwa        || echo   [AVISO] pull do DVWA falhou.
docker pull mysql:5.7                   || echo   [AVISO] pull do MySQL do XVWA falhou.
docker pull owasp/modsecurity-crs:nginx || echo   [AVISO] pull do ModSecurity falhou.

call :step "Construindo imagens DoBotShield e Coraza (compose build)"
docker compose -f "%COMPOSE%" build || ( echo [ERRO] compose build falhou. & exit /b 22 )

REM --------------------------------------------------------------------------
call :step "Subindo o DVWA (necessario para o login/cookie)"
docker compose -f "%COMPOSE%" up -d dvwa || ( echo [ERRO] nao subiu o DVWA. & exit /b 30 )

call :step "Aguardando o DVWA responder (ate 180s)"
echo   Resolvendo IP do DVWA...
set "IP_DVWA="
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dvwa') do set "IP_DVWA=%%I"
if not defined IP_DVWA (
    echo [ERRO] Nao foi possivel resolver IP do container lab_dvwa.
    docker compose -f "%COMPOSE%" ps
    exit /b 33
)
REM A imagem historica do DVWA pode deixar apenas o tail ativo se o Apache
REM perder a corrida de inicializacao com o banco. Garante o servico antes
REM da sondagem sem reiniciar um Apache que ja esteja saudavel.
docker exec lab_dvwa sh -c "pidof apache2 >/dev/null 2>&1 || service apache2 start" >nul 2>&1
call :wait_target "http://!IP_DVWA!:80" "DVWA HTTP"

REM --------------------------------------------------------------------------
call :step "Garantindo setup.php habilitado (idempotencia das re-execucoes)"
echo   Restaurando setup.php se estiver desabilitado (.bak) -- necessario p/ o
echo   create_db conseguir RESETAR o banco/senha do DVWA numa nova execucao.
docker exec lab_dvwa sh -c "if [ -f /var/www/html/setup.php.bak ] && [ ! -f /var/www/html/setup.php ]; then mv /var/www/html/setup.php.bak /var/www/html/setup.php; fi; exit 0" >nul 2>&1
echo   OK (re-rodar este .bat agora consegue restaurar um DVWA com login quebrado).

REM --------------------------------------------------------------------------
call :step "Login automatico DVWA (admin/password) + security=low + cookie"
echo   Executando login...
set "DVWA_COOKIE="
for /f "delims=" %%C in ('docker run --rm --network %NET% -v "%SCRIPTS_FWD%:/scripts:ro" %IMG_PY% python /scripts/dvwa_login.py "http://!IP_DVWA!:80" 2^>"%SCRIPTS_DIR%\dvwa_login.stderr.log"') do set "DVWA_COOKIE=%%C"

if defined DVWA_COOKIE (
    echo   Cookie capturado automaticamente: !DVWA_COOKIE!
) else (
    echo.
    echo   [ERRO] Login automatico nao retornou cookie. Detalhes:
    if exist "%SCRIPTS_DIR%\dvwa_login.stderr.log" type "%SCRIPTS_DIR%\dvwa_login.stderr.log"
    echo.
    echo   A bateria nao seguira com DVWA sem cookie valido, pois isso quebra
    echo   o padrao de input das ferramentas autenticadas.
    exit /b 31
)

REM Normaliza espacos apos ";" (document.cookie usa "; ", scanners preferem ";")
if defined DVWA_COOKIE set "DVWA_COOKIE=!DVWA_COOKIE:; =;!"

if not exist "%SCRIPTS_DIR%" mkdir "%SCRIPTS_DIR%"
if defined DVWA_COOKIE (
    > "%COOKIE_FILE%" echo !DVWA_COOKIE!
    echo   Cookie salvo em: %COOKIE_FILE%
) else (
    if exist "%COOKIE_FILE%" del "%COOKIE_FILE%" >nul 2>&1
    echo   [AVISO] Sem cookie. Os scans no DVWA rodarao SEM autenticacao.
)

REM --------------------------------------------------------------------------

REM --------------------------------------------------------------------------
call :step "Desativando /setup.php para proteger o banco de dados"
echo   Renomeando setup.php p/ setup.php.bak no container lab_dvwa...
docker exec lab_dvwa mv /var/www/html/setup.php /var/www/html/setup.php.bak >nul 2>&1
echo   Protecao ativada: nenhum scanner conseguira formatar o DB acidentalmente.

REM --------------------------------------------------------------------------
call :step "Subindo o XVWA e criando o banco (setup)"
echo   Subindo o XVWA (necessario para criar/popular o banco)...
docker compose -f "%COMPOSE%" up -d xvwa || echo   [AVISO] nao subiu o XVWA.
echo   Resolvendo IP do XVWA...
set "IP_XVWA="
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_xvwa') do set "IP_XVWA=%%I"
if not defined IP_XVWA (
    echo [ERRO] Nao foi possivel resolver IP do container lab_xvwa.
    docker compose -f "%COMPOSE%" ps
    exit /b 34
)
call :wait_target "http://!IP_XVWA!:80/xvwa/" "XVWA HTTP"
echo   Criando banco do XVWA via /xvwa/setup/?action=do ...
docker run --rm --network %NET% -v "%SCRIPTS_FWD%:/scripts:ro" %IMG_PY% python /scripts/xvwa_setup.py "http://!IP_XVWA!:80" >"%SCRIPTS_DIR%\xvwa_setup.stdout.log" 2>"%SCRIPTS_DIR%\xvwa_setup.stderr.log"
if errorlevel 1 (
    echo   [ERRO] setup do XVWA falhou. Detalhes:
    if exist "%SCRIPTS_DIR%\xvwa_setup.stderr.log" type "%SCRIPTS_DIR%\xvwa_setup.stderr.log"
    exit /b 32
)
echo   (Detalhes em %SCRIPTS_DIR%\xvwa_setup.stdout.log e %SCRIPTS_DIR%\xvwa_setup.stderr.log)
echo   OBS: o XVWA nao exige login; os scanners alcancam os modulos sem cookie.

call :step "Registrando METODOLOGIA.txt"
if not exist "%RESULTS%" mkdir "%RESULTS%"
> "%RESULTS%\METODOLOGIA.txt" echo # Rodada gerada em %DATE% %TIME%
>> "%RESULTS%\METODOLOGIA.txt" echo.
type "%ROOT%\docs\METODOLOGIA.txt" >> "%RESULTS%\METODOLOGIA.txt" 2>nul
echo   OK: %RESULTS%\METODOLOGIA.txt

echo.
echo ============================================================
echo   SETUP CONCLUIDO: %DATE% %TIME%
echo   Cookie DVWA: !DVWA_COOKIE!
echo   Proximo passo:  lab_01_subir.bat
echo ============================================================
exit /b 0


REM ############################################################################
REM  SUBROTINAS
REM ############################################################################

:step
set /a STEP+=1
echo.
echo [STEP %STEP%] %~1
echo --------------------------------------------------------
exit /b 0

REM ----------------------------------------------------------------------------
:ensure_cert
if exist "%CERT_DIR%\server.crt" if exist "%CERT_DIR%\server.key" (
    echo   Certificado ja existe em %CERT_DIR% -- mantendo.
    exit /b 0
)
if not exist "%CERT_DIR%" mkdir "%CERT_DIR%"
set "SUBJ=/C=BR/ST=PB/L=RioTinto/O=DoBotShield/CN=localhost"
set "SAN=subjectAltName=DNS:localhost,DNS:dvwa,DNS:xvwa,DNS:dobot_dvwa,DNS:dobot_xvwa,DNS:coraza_dvwa,DNS:coraza_xvwa,DNS:modsec_dvwa,DNS:modsec_xvwa,IP:127.0.0.1"

where openssl >nul 2>&1
if %ERRORLEVEL%==0 (
    openssl req -x509 -newkey rsa:2048 -nodes -days 365 ^
        -keyout "%CERT_DIR%\server.key" -out "%CERT_DIR%\server.crt" ^
        -subj "%SUBJ%" -addext "%SAN%" >nul 2>&1
    if exist "%CERT_DIR%\server.crt" ( echo   Certificado gerado via openssl local. & exit /b 0 )
)
echo   openssl ausente no host -- gerando via container alpine/openssl.
docker run --rm -v "%CERT_FWD%:/certs" alpine/openssl ^
    req -x509 -newkey rsa:2048 -nodes -days 365 ^
    -keyout /certs/server.key -out /certs/server.crt ^
    -subj "%SUBJ%" -addext "%SAN%"
if not exist "%CERT_DIR%\server.crt" ( echo [ERRO] Geracao de certificado falhou. & exit /b 13 )
echo   Certificado gerado em %CERT_DIR%.
exit /b 0

REM ----------------------------------------------------------------------------
:wait_target
set "_WT_URL=%~1"
set "_WT_LBL=%~2"
set /a _WT_TRIES=0
:_wt_loop
set /a _WT_TRIES+=1
docker run --rm --network %NET% %IMG_CURL% -k -s -o /dev/null --max-time 5 "%_WT_URL%" >nul 2>&1
if !ERRORLEVEL!==0 ( echo   [OK]   %_WT_LBL% & exit /b 0 )
if !_WT_TRIES! GEQ 36 ( echo   [AVISO] %_WT_LBL% nao respondeu em 180s -- seguindo. & exit /b 0 )
ping -n 6 127.0.0.1 >nul
goto :_wt_loop
