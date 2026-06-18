@echo off
REM ============================================================================
REM  lab_05_xsstrike.bat  --  Ferramenta 4/6: XSStrike (XSS)
REM
REM  Roda XSStrike contra os 8 alvos (DVWA e XVWA x 4 cenarios).
REM
REM  Configuracao:
REM    - Alvo DIRETO: a URL ja inclui o parametro REFLETIDO vulneravel
REM      (DVWA  /vulnerabilities/xss_r/?name=test ;
REM       XVWA  /xvwa/vulnerabilities/reflected_xss/?item=test).
REM      SEM --crawl: garante que a ferramenta fuzze o parametro certo em
REM      TODOS os cenarios (antes, o --crawl na raiz nao achava parametro).
REM    - -t 10        : 10 threads.
REM    - --skip-dom   : foca em XSS refletido (server-side).
REM    - Cookie DVWA (se houver) via --headers "Cookie: ...". XVWA sem cookie.
REM  Input IDENTICO nos 4 cenarios de cada app; so a URL base (host) muda.
REM  XSStrike usa verify=False (ignora TLS), entao alcanca todos os WAFs HTTPS.
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "NET=dobotshield_waflab"
set "RESULTS=%ROOT%\lab_results"
set "LIB=%ROOT%\lab_lib.bat"
set "IMG_CURL=curlimages/curl:latest"
set "IMG_TOOLS=dobotshield/lab-tools:latest"
set "IMG_PY=python:3-alpine"
set "CERT_DIR=%ROOT%\certs"
set "CERT_FWD=%CERT_DIR:\=/%"
set "SCRIPTS_DIR=%ROOT%\lab_scripts"
set "SCRIPTS_FWD=%SCRIPTS_DIR:\=/%"
set "COOKIE_FILE=%SCRIPTS_DIR%\dvwa_cookie.txt"
set "FAIL=0"

set "DVWA_COOKIE="
if exist "%COOKIE_FILE%" set /p DVWA_COOKIE=<"%COOKIE_FILE%"

echo.
echo ============================================================
echo   FERRAMENTA: XSStrike (XSS refletido, parametro direto, 10t)  --  %DATE% %TIME%
if defined DVWA_COOKIE echo   Cookie DVWA: !DVWA_COOKIE!
echo ============================================================

call "%LIB%" ensure_net || exit /b 2
docker image inspect %IMG_TOOLS% >nul 2>&1 || (
    echo Imagem %IMG_TOOLS% ausente -- construindo...
    docker build -t %IMG_TOOLS% "%ROOT%\docker\lab-tools" || ( echo [ERRO] build lab-tools falhou. & exit /b 3 )
)

REM --- Resolver IPs dos containers (IP:PORTA em vez de hostname) ---
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dvwa') do set "IP_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_xvwa') do set "IP_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_dvwa') do set "IP_DOBOT_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_xvwa') do set "IP_DOBOT_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_modsec_dvwa') do set "IP_MODSEC_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_modsec_xvwa') do set "IP_MODSEC_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_coraza_dvwa') do set "IP_CORAZA_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_coraza_xvwa') do set "IP_CORAZA_XVWA=%%I"

for %%V in (IP_DVWA IP_XVWA IP_DOBOT_DVWA IP_DOBOT_XVWA IP_MODSEC_DVWA IP_MODSEC_XVWA IP_CORAZA_DVWA IP_CORAZA_XVWA) do (
    if "!%%V!"=="" (
        echo [ERRO] %%V vazio. Rode lab_01_subir.bat e tente novamente.
        exit /b 6
    )
)

REM --- Renova o cookie do DVWA antes dos alvos autenticados ---
docker image inspect %IMG_PY% >nul 2>&1 || docker pull %IMG_PY% || ( echo [ERRO] sem imagem %IMG_PY%. & exit /b 4 )
echo.
echo Renovando cookie do DVWA (login admin/password, security=low) para o XSStrike...
set "DVWA_COOKIE="
for /f "delims=" %%C in ('docker run --rm --network %NET% -v "%SCRIPTS_FWD%:/scripts:ro" %IMG_PY% python /scripts/dvwa_login.py --no-setup "http://!IP_DVWA!:80" 2^>"%SCRIPTS_DIR%\dvwa_login.xsstrike.stderr.log"') do set "DVWA_COOKIE=%%C"
if defined DVWA_COOKIE set "DVWA_COOKIE=!DVWA_COOKIE:; =;!"
if defined DVWA_COOKIE (
    > "%COOKIE_FILE%" echo !DVWA_COOKIE!
    echo   Cookie DVWA renovado: !DVWA_COOKIE!
) else (
    echo   [ERRO] Nao renovou o cookie DVWA. XSStrike nao sera executado sem sessao valida.
    if exist "%SCRIPTS_DIR%\dvwa_login.xsstrike.stderr.log" type "%SCRIPTS_DIR%\dvwa_login.xsstrike.stderr.log"
    exit /b 5
)

REM --- DVWA: XSS Refletido (GET, parametro name) ---
call "%ROOT%\lab_05_xsstrike_one.bat" dvwa no_waf      "http://!IP_DVWA!:80/vulnerabilities/xss_r/?name=test"            lab_dvwa      ""                "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_05_xsstrike_one.bat" dvwa modsecurity "https://!IP_MODSEC_DVWA!:8443/vulnerabilities/xss_r/?name=test"  lab_dvwa      lab_modsec_dvwa   "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_05_xsstrike_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443/vulnerabilities/xss_r/?name=test"    lab_dvwa      lab_dobot_dvwa    "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_05_xsstrike_one.bat" dvwa coraza      "https://!IP_CORAZA_DVWA!:443/vulnerabilities/xss_r/?name=test"   lab_dvwa      lab_coraza_dvwa   "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"

REM --- XVWA: XSS Refletido (GET, parametro item; sem cookie) ---
call "%ROOT%\lab_05_xsstrike_one.bat" xvwa no_waf      "http://!IP_XVWA!:80/xvwa/vulnerabilities/reflected_xss/?item=test"            lab_xvwa      ""                ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_05_xsstrike_one.bat" xvwa modsecurity "https://!IP_MODSEC_XVWA!:8443/xvwa/vulnerabilities/reflected_xss/?item=test"  lab_xvwa      lab_modsec_xvwa   ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_05_xsstrike_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443/xvwa/vulnerabilities/reflected_xss/?item=test"    lab_xvwa      lab_dobot_xvwa    ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_05_xsstrike_one.bat" xvwa coraza      "https://!IP_CORAZA_XVWA!:443/xvwa/vulnerabilities/reflected_xss/?item=test"   lab_xvwa      lab_coraza_xvwa   ""
if errorlevel 1 set "FAIL=1"

echo.
echo ============================================================
echo   XSStrike CONCLUIDO: %DATE% %TIME%
echo   Logs em: %RESULTS%\^<app^>\^<cenario^>\04_xsstrike.log
echo ============================================================
exit /b %FAIL%
