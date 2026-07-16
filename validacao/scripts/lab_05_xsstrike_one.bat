@echo off
REM ============================================================================
REM  lab_05_xsstrike_one.bat -- execucao unitaria do XSStrike
REM
REM  Uso interno pelo lab_05_xsstrike.bat:
REM    lab_05_xsstrike_one.bat <app> <cenario> <url> <backend_ct> <waf_ct> <cookie>
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
for %%I in ("%ROOT%\..") do set "LAB_ROOT=%%~fI"
if "%NET%"=="" set "NET=dobotshield_waflab"
if "%RESULTS%"=="" set "RESULTS=%LAB_ROOT%\results"
if "%LIB%"=="" set "LIB=%ROOT%\lab_lib.bat"
if "%IMG_TOOLS%"=="" set "IMG_TOOLS=dobotshield/lab-tools:latest"
if "%IMG_CURL%"=="" set "IMG_CURL=curlimages/curl:latest@sha256:7c12af72ceb38b7432ab85e1a265cff6ae58e06f95539d539b654f2cfa64bb13"
if "%CERT_DIR%"=="" set "CERT_DIR=%LAB_ROOT%\certs"
set "CERT_FWD=%CERT_DIR:\=/%"

set "APP=%~1"
set "SCEN=%~2"
set "URL=%~3"
set "BACKEND=%~4"
set "WAFCT=%~5"
set "COOKIE=%~6"
set "LAB_USER_AGENT=DoBotShield-TCC-Validation/1.0"

if "%APP%"=="" (
    echo [ERRO] app vazio em lab_05_xsstrike_one.bat.
    exit /b 2
)
if "%SCEN%"=="" (
    echo [ERRO] cenario vazio em lab_05_xsstrike_one.bat.
    exit /b 2
)
if "%URL%"=="" (
    echo [ERRO] URL vazia para %APP%/%SCEN%.
    exit /b 2
)

set "OUT=%RESULTS%\%APP%\%SCEN%"
if not exist "%OUT%" mkdir "%OUT%"
set "LOG=%OUT%\04_xsstrike.log"

set "_HDR_VALUE=User-Agent: %LAB_USER_AGENT%"
if not "%COOKIE%"=="" set "_HDR_VALUE=!_HDR_VALUE!\nCookie: %COOKIE%"

echo   - %APP% / %SCEN%  -^>  %URL%
call "%LIB%" health_probe "%URL%" "%OUT%\04_pre_xsstrike_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\04_pre_xsstrike_stats.txt"

REM --skip: NAO perguntar "continue scanning?" ao achar um XSS. Sem ele, rodando
REM via "docker run" sem stdin, o XSStrike abre input() ao encontrar payload e
REM quebra com EOFError (RC=1) logo apos achar a falha. Com --skip ele segue e
REM conclui o scan (mesmo flag p/ todos os cenarios).
> "%LOG%" echo === XSStrike ^| %APP%/%SCEN% ^| %URL% ^| %DATE% %TIME% ===
>> "%LOG%" echo CMD: xsstrike.py -u "%URL%" -t 10 --skip --skip-dom --headers "!_HDR_VALUE!"
>> "%LOG%" echo ----------------------------------------------------------------
docker run --rm --network %NET% ^
    -v "%CERT_FWD%:/lab-ca:ro" ^
    %IMG_TOOLS% ^
    python /opt/xsstrike/xsstrike.py ^
        -u "%URL%" ^
        -t 10 ^
        --skip ^
        --skip-dom ^
        --headers "!_HDR_VALUE!" >> "%LOG%" 2>&1
set "TOOL_RC=!ERRORLEVEL!"
>> "%LOG%" echo.
>> "%LOG%" echo TOOL_RC=!TOOL_RC!

call "%LIB%" health_probe "%URL%" "%OUT%\04_post_xsstrike_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\04_post_xsstrike_stats.txt"
if not "%WAFCT%"=="" call "%LIB%" dump_logs "%WAFCT%" "%OUT%\04_xsstrike_waf.log"

exit /b 0
