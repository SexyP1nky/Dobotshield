@echo off
REM ============================================================================
REM  Reexecuta somente os 12 cenarios DoBotShield que estavam sem artefatos:
REM  seis ferramentas x duas aplicacoes. Nao refaz no_waf/ModSecurity/Coraza.
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fI"

set "NET=dobotshield_waflab"
set "RESULTS=%ROOT%\results"
set "LIB=%SCRIPT_DIR%\lab_lib.bat"
set "CERT_DIR=%ROOT%\certs"
set "SCRIPTS_DIR=%ROOT%\helpers"
set "IMG_CURL=curlimages/curl:latest"
set "IMG_TESTSSL=drwetter/testssl.sh:latest"
set "IMG_ZAP=zaproxy/zap-stable:latest"
set "IMG_TOOLS=dobotshield/lab-tools:latest"
set "IMG_WRK=dobotshield/wrk:latest"
set "FAIL=0"

call "%LIB%" ensure_net || exit /b 2

for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dvwa') do set "IP_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_xvwa') do set "IP_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_dvwa') do set "IP_DOBOT_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_xvwa') do set "IP_DOBOT_XVWA=%%I"

for %%V in (IP_DVWA IP_XVWA IP_DOBOT_DVWA IP_DOBOT_XVWA) do (
    if not defined %%V (
        echo [ERRO] %%V nao resolvido.
        exit /b 3
    )
)

set "DVWA_COOKIE="
if exist "%SCRIPTS_DIR%\dvwa_cookie.txt" set /p DVWA_COOKIE=<"%SCRIPTS_DIR%\dvwa_cookie.txt"

echo [1/7] testssl.sh
call "%SCRIPT_DIR%\lab_02_testssl_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443" lab_dvwa lab_dobot_dvwa || set "FAIL=1"
call "%SCRIPT_DIR%\lab_02_testssl_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443" lab_xvwa lab_dobot_xvwa || set "FAIL=1"

echo [2/7] ZAP
call "%SCRIPT_DIR%\lab_03_zap_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443" lab_dvwa lab_dobot_dvwa "!DVWA_COOKIE!" || set "FAIL=1"
call "%SCRIPT_DIR%\lab_03_zap_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443/xvwa/" lab_xvwa lab_dobot_xvwa "" || set "FAIL=1"

echo [3/7] SQLMap
call "%SCRIPT_DIR%\lab_04_sqlmap_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443" "/vulnerabilities/sqli/?id=1&Submit=Submit" "/vulnerabilities/sqli_blind/?id=1&Submit=Submit" "id" lab_dvwa lab_dobot_dvwa "!DVWA_COOKIE!" "" || set "FAIL=1"
call "%SCRIPT_DIR%\lab_04_sqlmap_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443" "/xvwa/vulnerabilities/sqli/" "" "item" lab_xvwa lab_dobot_xvwa "" "item=1"
if errorlevel 1 set "FAIL=1"

echo [4/7] XSStrike
call "%SCRIPT_DIR%\lab_05_xsstrike_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443/vulnerabilities/xss_r/?name=test" lab_dvwa lab_dobot_dvwa "!DVWA_COOKIE!" || set "FAIL=1"
call "%SCRIPT_DIR%\lab_05_xsstrike_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443/xvwa/vulnerabilities/reflected_xss/?item=test" lab_xvwa lab_dobot_xvwa "" || set "FAIL=1"

echo [5/7] Commix
call "%SCRIPT_DIR%\lab_06_commix_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443/vulnerabilities/exec/" lab_dvwa lab_dobot_dvwa "!DVWA_COOKIE!" "ip=127.0.0.1&Submit=Submit" || set "FAIL=1"
call "%SCRIPT_DIR%\lab_06_commix_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443/xvwa/vulnerabilities/cmdi/?target=127.0.0.1" lab_xvwa lab_dobot_xvwa "" "" || set "FAIL=1"

echo [6/7] Testes manuais e falsos positivos
call "%SCRIPT_DIR%\lab_08_manual_regression.bat" || set "FAIL=1"

echo [7/7] wrk
call "%SCRIPT_DIR%\lab_07_wrk_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443" lab_dvwa lab_dobot_dvwa || set "FAIL=1"
call "%SCRIPT_DIR%\lab_07_wrk_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443/xvwa/" lab_xvwa lab_dobot_xvwa || set "FAIL=1"

if not "%FAIL%"=="0" (
    echo [ERRO] Uma ou mais execucoes DoBotShield falharam.
    exit /b 1
)

echo [OK] Reexecucao seletiva DoBotShield concluida.
exit /b 0
