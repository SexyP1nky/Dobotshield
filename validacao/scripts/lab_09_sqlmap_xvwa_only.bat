@echo off
REM Reexecuta somente o cenario SQLMap que faltou: XVWA atraves do DoBotShield.

setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fI"

set "NET=dobotshield_waflab"
set "RESULTS=%ROOT%\results"
set "LIB=%SCRIPT_DIR%\lab_lib.bat"
set "CERT_DIR=%ROOT%\certs"
set "IMG_TOOLS=dobotshield/lab-tools:latest"
set "IMG_CURL=curlimages/curl:latest"

call "%LIB%" ensure_net || exit /b 2

for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_xvwa') do set "IP_DOBOT_XVWA=%%I"
if not defined IP_DOBOT_XVWA (
    echo [ERRO] IP_DOBOT_XVWA nao resolvido.
    exit /b 3
)

call "%SCRIPT_DIR%\lab_04_sqlmap_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443" "/xvwa/vulnerabilities/sqli/" "" "item" lab_xvwa lab_dobot_xvwa "" "item=1"
exit /b %ERRORLEVEL%
