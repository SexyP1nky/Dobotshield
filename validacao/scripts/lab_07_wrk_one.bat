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
for %%I in ("%ROOT%\..") do set "LAB_ROOT=%%~fI"
if "%NET%"=="" set "NET=dobotshield_waflab"
if "%RESULTS%"=="" set "RESULTS=%LAB_ROOT%\results"
if "%LIB%"=="" set "LIB=%ROOT%\lab_lib.bat"
if "%IMG_WRK%"=="" set "IMG_WRK=dobotshield/wrk:latest"
if "%IMG_CURL%"=="" set "IMG_CURL=curlimages/curl:latest@sha256:7c12af72ceb38b7432ab85e1a265cff6ae58e06f95539d539b654f2cfa64bb13"

set "APP=%~1"
set "SCEN=%~2"
set "URL=%~3"
set "BACKEND=%~4"
set "WAFCT=%~5"
if "%WRK_REPETITIONS%"=="" set "WRK_REPETITIONS=3"
set "LAB_USER_AGENT=DoBotShield-TCC-Validation/1.0"

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
>> "%LOG%" echo REPETICOES: %WRK_REPETITIONS%
>> "%LOG%" echo CMD: wrk -t12 -c400 -d30s --timeout 5s --latency -H "User-Agent: %LAB_USER_AGENT%" %URL%
>> "%LOG%" echo ----------------------------------------------------------------
set "TOOL_RC=0"
for /l %%R in (1,1,%WRK_REPETITIONS%) do (
    >> "%LOG%" echo.
    >> "%LOG%" echo === REPETICAO %%R/%WRK_REPETITIONS% ===
    docker run --rm --network %NET% %IMG_WRK% ^
        -t12 -c400 -d30s --timeout 5s --latency ^
        -H "User-Agent: %LAB_USER_AGENT%" ^
        "%URL%" >> "%LOG%" 2>&1
    set "RUN_RC=!ERRORLEVEL!"
    >> "%LOG%" echo RUN_RC_%%R=!RUN_RC!
    if not "!RUN_RC!"=="0" set "TOOL_RC=!RUN_RC!"
    if not "%%R"=="%WRK_REPETITIONS%" ping -n 6 127.0.0.1 >nul
)
>> "%LOG%" echo.
>> "%LOG%" echo TOOL_RC=!TOOL_RC!

call "%LIB%" health_probe "%URL%" "%OUT%\06_post_wrk_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\06_post_wrk_stats.txt"
if not "%WAFCT%"=="" call "%LIB%" dump_logs "%WAFCT%" "%OUT%\06_wrk_waf.log"

exit /b 0
