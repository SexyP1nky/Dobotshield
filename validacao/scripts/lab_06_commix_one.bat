@echo off
REM ============================================================================
REM  lab_06_commix_one.bat -- execucao unitaria do Commix
REM
REM  Uso interno pelo lab_06_commix.bat:
REM    lab_06_commix_one.bat <app> <cenario> <url> <backend_ct> <waf_ct> <cookie> <post_data>
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
set "DATA=%~7"
set "LAB_USER_AGENT=DoBotShield-TCC-Validation/1.0"

if "%APP%"=="" (
    echo [ERRO] app vazio em lab_06_commix_one.bat.
    exit /b 2
)
if "%SCEN%"=="" (
    echo [ERRO] cenario vazio em lab_06_commix_one.bat.
    exit /b 2
)
if "%URL%"=="" (
    echo [ERRO] URL vazia para %APP%/%SCEN%.
    exit /b 2
)

set "OUT=%RESULTS%\%APP%\%SCEN%"
if not exist "%OUT%\commix" mkdir "%OUT%\commix"
set "OUT_FWD=%OUT:\=/%"
set "LOG=%OUT%\05_commix.log"

set "_CK_ARG="
if not "%COOKIE%"=="" set "_CK_ARG=--cookie="%COOKIE%""
set "_DATA_ARG="
REM Sem aspas internas no valor: o POST data tem '&' (ip=...&Submit=Submit). Com
REM aspas internas (--data="...") o cmd.exe FECHA as aspas antes do '&', que vira
REM separador de comando e tenta rodar "Submit=Submit". Como o valor nao tem
REM espacos, as aspas externas do SET ja protegem o '&'. O !_DATA_ARG! e expandido
REM por delayed expansion no docker run/echo, onde o '&' tambem fica literal.
if not "%DATA%"=="" set "_DATA_ARG=--data=%DATA%"

echo   - %APP% / %SCEN%  -^>  %URL%
call "%LIB%" health_probe "%URL%" "%OUT%\05_pre_commix_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\05_pre_commix_stats.txt"

> "%LOG%" echo === Commix ^| %APP%/%SCEN% ^| %URL% ^| %DATE% %TIME% ===
REM A URL vai pelo STDIN (echo ... ^| docker run -i) em vez de --url. Isso liga o
REM STDIN_PARSING do commix, que faz o prompt "spawn pseudo-terminal shell?" ter
REM default "n" (checks.py:893). Assim, ao DETECTAR a injecao (ex.: no_waf), o
REM commix NAO abre o pseudo-shell interativo -- que, sem stdin real, entrava em
REM loop e INUNDAVA o log (>1 GB). Tambem removido --all (enumeracao pesada,
REM desnecessaria p/ medir deteccao). Detecta a injecao e sai limpo (rc=0).
>> "%LOG%" echo CMD: echo ^<url^> ^| commix.py !_DATA_ARG! --batch --user-agent="%LAB_USER_AGENT%" --level=3 --skip-empty --skip-waf --delay=1 --timeout=20 --retries=2 !_CK_ARG! --output-dir=/work
>> "%LOG%" echo ----------------------------------------------------------------
echo %URL%| docker run --rm -i --network %NET% ^
    -v "%CERT_FWD%:/lab-ca:ro" ^
    -v "%OUT_FWD%/commix:/work" ^
    %IMG_TOOLS% ^
    python /opt/commix/commix.py ^
        !_DATA_ARG! ^
        --batch --user-agent="%LAB_USER_AGENT%" ^
        --level=3 ^
        --skip-empty ^
        --skip-waf ^
        --delay=1 --timeout=20 --retries=2 ^
        !_CK_ARG! ^
        --output-dir=/work >> "%LOG%" 2>&1
set "TOOL_RC=!ERRORLEVEL!"
>> "%LOG%" echo.
>> "%LOG%" echo TOOL_RC=!TOOL_RC!

call "%LIB%" health_probe "%URL%" "%OUT%\05_post_commix_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\05_post_commix_stats.txt"
if not "%WAFCT%"=="" call "%LIB%" dump_logs "%WAFCT%" "%OUT%\05_commix_waf.log"

exit /b 0
