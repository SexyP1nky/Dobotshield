@echo off
REM ============================================================================
REM  lab_02_testssl_one.bat -- execucao unitaria do testssl.sh
REM
REM  Uso interno pelo lab_02_testssl.bat:
REM    lab_02_testssl_one.bat <app> <cenario> <url> <backend_ct> <waf_ct>
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fI"
if "%NET%"=="" set "NET=dobotshield_waflab"
if "%RESULTS%"=="" set "RESULTS=%ROOT%\results"
if "%LIB%"=="" set "LIB=%SCRIPT_DIR%\lab_lib.bat"
if "%IMG_TESTSSL%"=="" set "IMG_TESTSSL=drwetter/testssl.sh:latest"
if "%IMG_CURL%"=="" set "IMG_CURL=curlimages/curl:latest"

set "APP=%~1"
set "SCEN=%~2"
set "URL=%~3"
set "BACKEND=%~4"
set "WAFCT=%~5"

if "%APP%"=="" (
    echo [ERRO] app vazio em lab_02_testssl_one.bat.
    exit /b 2
)
if "%SCEN%"=="" (
    echo [ERRO] cenario vazio em lab_02_testssl_one.bat.
    exit /b 2
)
if "%URL%"=="" (
    echo [ERRO] URL vazia para %APP%/%SCEN%.
    exit /b 2
)

set "OUT=%RESULTS%\%APP%\%SCEN%"
if not exist "%OUT%" mkdir "%OUT%"
set "LOG=%OUT%\01_testssl.log"

REM testssl exige host:porta -- remove o esquema da URL.
set "_TGT=%URL%"
set "_TGT=!_TGT:https://=!"
set "_TGT=!_TGT:http://=!"

echo   - %APP% / %SCEN%  -^>  !_TGT!
call "%LIB%" health_probe "%URL%" "%OUT%\01_pre_testssl_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\01_pre_testssl_stats.txt"

> "%LOG%" echo === testssl.sh ^| %APP%/%SCEN% ^| !_TGT! ^| %DATE% %TIME% ===
>> "%LOG%" echo CMD: docker run --rm --network %NET% %IMG_TESTSSL% --quiet --color 0 --warnings off --connect-timeout 10 --openssl-timeout 10 !_TGT!
>> "%LOG%" echo ----------------------------------------------------------------
docker run --rm --network %NET% %IMG_TESTSSL% ^
    --quiet --color 0 --warnings off ^
    --connect-timeout 10 --openssl-timeout 10 ^
    "!_TGT!" >> "%LOG%" 2>&1
set "TOOL_RC=!ERRORLEVEL!"
>> "%LOG%" echo.
>> "%LOG%" echo TOOL_RC=!TOOL_RC!

call "%LIB%" health_probe "%URL%" "%OUT%\01_post_testssl_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\01_post_testssl_stats.txt"
if not "%WAFCT%"=="" call "%LIB%" dump_logs "%WAFCT%" "%OUT%\01_testssl_waf.log"

exit /b 0
