@echo off
REM ============================================================================
REM  Testes manuais focalizados: ;echo, ;sleep e corpus benigno.
REM  Executa apenas nos dois alvos DoBotShield e grava um relatorio JSON.
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fI"

set "NET=dobotshield_waflab"
set "RESULTS=%ROOT%\results"
set "HELPERS=%ROOT%\helpers"
set "HELPERS_FWD=%HELPERS:\=/%"
set "OUT=%RESULTS%\manual_regression"
set "REPORT=%OUT%\07_manual_cmdi_false_positives.json"
set "IMG_PY=python:3-alpine"

docker network inspect %NET% >nul 2>&1 || (
    echo [ERRO] Rede Docker "%NET%" nao encontrada. Rode lab_01_subir.bat.
    exit /b 2
)
docker image inspect %IMG_PY% >nul 2>&1 || docker pull %IMG_PY% || exit /b 3

for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_dvwa') do set "IP_DOBOT_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_xvwa') do set "IP_DOBOT_XVWA=%%I"

if not defined IP_DOBOT_DVWA (
    echo [ERRO] IP de lab_dobot_dvwa nao encontrado.
    exit /b 4
)
if not defined IP_DOBOT_XVWA (
    echo [ERRO] IP de lab_dobot_xvwa nao encontrado.
    exit /b 5
)
if not exist "%OUT%" mkdir "%OUT%"

docker run --rm --network %NET% -v "%HELPERS_FWD%:/helpers:ro" %IMG_PY% ^
    python /helpers/manual_regression.py "!IP_DOBOT_DVWA!" "!IP_DOBOT_XVWA!" > "%REPORT%"
set "RC=%ERRORLEVEL%"

type "%REPORT%"
if not "%RC%"=="0" (
    echo [ERRO] Uma ou mais regressoes manuais falharam.
    exit /b %RC%
)

echo [OK] Relatorio: %REPORT%
exit /b 0
