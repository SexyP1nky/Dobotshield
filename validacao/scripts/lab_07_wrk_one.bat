@echo off
REM ============================================================================
REM  lab_07_wrk_one.bat -- execucao unitaria do wrk
REM
REM  Uso interno pelo lab_07_wrk.bat:
REM    lab_07_wrk_one.bat <app> <cenario> <url> <backend_ct> <waf_ct>
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
if "%NET%"=="" set "NET=dobotshield_waflab"
if "%RESULTS%"=="" set "RESULTS=%ROOT%\lab_results"
if "%LIB%"=="" set "LIB=%ROOT%\lab_lib.bat"
if "%IMG_WRK%"=="" set "IMG_WRK=dobotshield/wrk:latest"
if "%IMG_CURL%"=="" set "IMG_CURL=curlimages/curl:latest"

set "APP=%~1"
set "SCEN=%~2"
set "URL=%~3"
set "BACKEND=%~4"
set "WAFCT=%~5"

if "%APP%"=="" (
    echo [ERRO] app vazio em lab_07_wrk_one.bat.
    exit /b 2
)
if "%SCEN%"=="" (
    echo [ERRO] cenario vazio em lab_07_wrk_one.bat.
    exit /b 2
)
if "%URL%"=="" (
    echo [ERRO] URL vazia para %APP%/%SCEN%.
    exit /b 2
)

set "OUT=%RESULTS%\%APP%\%SCEN%"
if not exist "%OUT%" mkdir "%OUT%"
set "LOG=%OUT%\06_wrk.log"

echo   - %APP% / %SCEN%  -^>  %URL%
call "%LIB%" health_probe "%URL%" "%OUT%\06_pre_wrk_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\06_pre_wrk_stats.txt"

> "%LOG%" echo === wrk ^| %APP%/%SCEN% ^| %URL% ^| %DATE% %TIME% ===
>> "%LOG%" echo CMD: wrk -t12 -c400 -d30s --timeout 5s --latency %URL%
>> "%LOG%" echo ----------------------------------------------------------------
docker run --rm --network %NET% %IMG_WRK% ^
    -t12 -c400 -d30s --timeout 5s --latency ^
    "%URL%" >> "%LOG%" 2>&1
set "TOOL_RC=!ERRORLEVEL!"
>> "%LOG%" echo.
>> "%LOG%" echo TOOL_RC=!TOOL_RC!

call "%LIB%" health_probe "%URL%" "%OUT%\06_post_wrk_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\06_post_wrk_stats.txt"
if not "%WAFCT%"=="" call "%LIB%" dump_logs "%WAFCT%" "%OUT%\06_wrk_waf.log"

exit /b 0
