@echo off
REM ============================================================================
REM  lab_04_sqlmap_one.bat -- execucao unitaria do SQLMap
REM
REM  Uso interno pelo lab_04_sqlmap.bat:
REM    lab_04_sqlmap_one.bat <app> <cenario> <base_url> <path1> <path2>
REM                          <parameter> <backend_ct> <waf_ct> <cookie> <post_data>
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
set "BASE=%~3"
set "PATH1=%~4"
set "PATH2=%~5"
set "PARAM=%~6"
set "BACKEND=%~7"
set "WAFCT=%~8"
set "COOKIE=%~9"
shift
set "DATA=%~9"
set "LAB_USER_AGENT=DoBotShield-TCC-Validation/1.0"

if "%APP%"=="" (
    echo [ERRO] app vazio em lab_04_sqlmap_one.bat.
    exit /b 2
)
if "%SCEN%"=="" (
    echo [ERRO] cenario vazio em lab_04_sqlmap_one.bat.
    exit /b 2
)
if "%BASE%"=="" (
    echo [ERRO] base URL vazia para %APP%/%SCEN%.
    exit /b 2
)
if "%PATH1%"=="" (
    echo [ERRO] path SQLMap vazio para %APP%/%SCEN%.
    exit /b 2
)
if "%PARAM%"=="" (
    echo [ERRO] parametro SQLMap vazio para %APP%/%SCEN%.
    exit /b 2
)

set "OUT=%RESULTS%\%APP%\%SCEN%"
if not exist "%OUT%\sqlmap" mkdir "%OUT%\sqlmap"
set "OUT_FWD=%OUT:\=/%"
set "LOG=%OUT%\03_sqlmap.log"

set "_CK_ARG="
if not "%COOKIE%"=="" set "_CK_ARG=--cookie="%COOKIE%""
set "_DATA_ARG="
REM Sem aspas internas (mesmo motivo do commix): se o POST data tiver '&', as
REM aspas internas o expoem como separador de comando no cmd.exe. Valor sem
REM espacos -> aspas externas do SET ja bastam.
if not "%DATA%"=="" set "_DATA_ARG=--data=%DATA%"
REM --string=<marcador>: texto que so aparece na resposta quando a condicao
REM booleana e VERDADEIRA. E o que permite ao SQLMap distinguir TRUE/FALSE
REM IGNORANDO o ruido do DoBotShield (400 nos payloads bloqueados e 502 da
REM inspecao de resposta nos payloads que geram erro SQL). Definido por app em
REM lab_04_sqlmap.bat (DVWA=Surname, XVWA=Category). Mesmo valor nos 4 cenarios.
set "_STR_ARG="
if defined SQLMAP_STRING set "_STR_ARG=--string="%SQLMAP_STRING%""

echo   - %APP% / %SCEN%  -^>  %BASE%
call "%LIB%" health_probe "%BASE%" "%OUT%\03_pre_sqlmap_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\03_pre_sqlmap_stats.txt"

if exist "%LOG%" del "%LOG%"

> "%LOG%" echo === SQLMap ^| %APP%/%SCEN% ^| "%BASE%%PATH1%" ^| %DATE% %TIME% ===
>> "%LOG%" echo CMD: sqlmap.py -u "%BASE%%PATH1%" -p "%PARAM%" !_DATA_ARG! --batch --user-agent="%LAB_USER_AGENT%" --level=1 --risk=1 --retries=2 --technique=B --skip-waf --ignore-redirects --flush-session --delay=0.3 --tamper=equaltolike !_STR_ARG! !_CK_ARG! --output-dir=/work
>> "%LOG%" echo ----------------------------------------------------------------
docker run --rm --network %NET% ^
    -v "%CERT_FWD%:/lab-ca:ro" ^
    -v "%OUT_FWD%/sqlmap:/work" ^
    %IMG_TOOLS% ^
    python /opt/sqlmap/sqlmap.py ^
        -u "%BASE%%PATH1%" ^
        -p "%PARAM%" ^
        !_DATA_ARG! ^
        --batch --user-agent="%LAB_USER_AGENT%" ^
        --level=1 --risk=1 ^
        --retries=2 ^
        --technique=B ^
        --skip-waf ^
        --ignore-redirects ^
        --delay=0.3 ^
        --tamper=equaltolike ^
        !_STR_ARG! ^
        --answers="keep testing the others=Y,skip test payloads specific for other DBMSes=N,extending provided level=Y,redirect=N,continue with further target testing=Y" ^
        --flush-session ^
        !_CK_ARG! ^
        --output-dir=/work >> "%LOG%" 2>&1
set "TOOL_RC_1=!ERRORLEVEL!"
>> "%LOG%" echo.
>> "%LOG%" echo TOOL_RC_1=!TOOL_RC_1!

if not "%PATH2%"=="" (
    >> "%LOG%" echo.
    >> "%LOG%" echo --- Blind SQLi: "%BASE%%PATH2%" ---
    >> "%LOG%" echo CMD: sqlmap.py -u "%BASE%%PATH2%" -p "%PARAM%" --batch --user-agent="%LAB_USER_AGENT%" --level=1 --risk=1 --retries=2 --technique=B --skip-waf --ignore-redirects --flush-session --delay=0.3 --tamper=equaltolike !_STR_ARG! !_CK_ARG! --output-dir=/work
    >> "%LOG%" echo ----------------------------------------------------------------
    docker run --rm --network %NET% ^
        -v "%CERT_FWD%:/lab-ca:ro" ^
        -v "%OUT_FWD%/sqlmap:/work" ^
        %IMG_TOOLS% ^
        python /opt/sqlmap/sqlmap.py ^
            -u "%BASE%%PATH2%" ^
            -p "%PARAM%" ^
            --batch --user-agent="%LAB_USER_AGENT%" ^
            --level=1 --risk=1 ^
            --retries=2 ^
            --technique=B ^
            --skip-waf ^
            --ignore-redirects ^
            --delay=0.3 ^
            --tamper=equaltolike ^
            !_STR_ARG! ^
            --answers="keep testing the others=Y,skip test payloads specific for other DBMSes=N,extending provided level=Y,redirect=N,continue with further target testing=Y" ^
            --flush-session ^
            !_CK_ARG! ^
            --output-dir=/work >> "%LOG%" 2>&1
    set "TOOL_RC_2=!ERRORLEVEL!"
    >> "%LOG%" echo.
    >> "%LOG%" echo TOOL_RC_2=!TOOL_RC_2!
)

call "%LIB%" health_probe "%BASE%" "%OUT%\03_post_sqlmap_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\03_post_sqlmap_stats.txt"
if not "%WAFCT%"=="" call "%LIB%" dump_logs "%WAFCT%" "%OUT%\03_sqlmap_waf.log"

exit /b 0
