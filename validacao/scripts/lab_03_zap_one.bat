@echo off
REM ============================================================================
REM  lab_03_zap_one.bat -- execucao unitaria do OWASP ZAP
REM
REM  Uso interno pelo lab_03_zap.bat:
REM    lab_03_zap_one.bat <app> <cenario> <url> <backend_ct> <waf_ct> <cookie>
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
for %%I in ("%ROOT%\..") do set "LAB_ROOT=%%~fI"
if "%NET%"=="" set "NET=dobotshield_waflab"
if "%RESULTS%"=="" set "RESULTS=%LAB_ROOT%\results"
if "%LIB%"=="" set "LIB=%ROOT%\lab_lib.bat"
if "%IMG_ZAP%"=="" set "IMG_ZAP=zaproxy/zap-stable:latest@sha256:8d387b1a63e3425beef4846e39719f5af2a787753af2d8b6558c6257d7a577a2"
if "%IMG_CURL%"=="" set "IMG_CURL=curlimages/curl:latest@sha256:7c12af72ceb38b7432ab85e1a265cff6ae58e06f95539d539b654f2cfa64bb13"
if "%SCRIPTS_DIR%"=="" set "SCRIPTS_DIR=%LAB_ROOT%\helpers"
set "SCRIPTS_FWD=%SCRIPTS_DIR:\=/%"

set "APP=%~1"
set "SCEN=%~2"
set "URL=%~3"
set "BACKEND=%~4"
set "WAFCT=%~5"
set "COOKIE=%~6"

if "%APP%"=="" (
    echo [ERRO] app vazio em lab_03_zap_one.bat.
    exit /b 2
)
if "%SCEN%"=="" (
    echo [ERRO] cenario vazio em lab_03_zap_one.bat.
    exit /b 2
)
if "%URL%"=="" (
    echo [ERRO] URL vazia para %APP%/%SCEN%.
    exit /b 2
)

set "OUT=%RESULTS%\%APP%\%SCEN%"
if not exist "%OUT%\zap" mkdir "%OUT%\zap"
set "OUT_FWD=%OUT:\=/%"
set "LOG=%OUT%\02_zap.log"

echo   - %APP% / %SCEN%  -^>  %URL%
call "%LIB%" health_probe "%URL%" "%OUT%\02_pre_zap_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\02_pre_zap_stats.txt"

set "_ZAP_CFG=-config network.connection.timeoutInSecs=10 -config network.connection.defaultUserAgent=DoBotShield-TCC-Validation/1.0"
REM O cookie de sessao do DVWA e injetado em TODA requisicao do ZAP via Replacer,
REM criado pelo hook (zap_hook.py) atraves da API do ZAP. ATENCAO: criar a regra
REM por "-config replacer.rules..." NAO funciona nesta versao do ZAP (a config e
REM aceita mas a extensao nao a aplica -> o scan ia DESLOGADO e so achava
REM login.php). O cookie chega ao hook pela variavel de ambiente DVWA_COOKIE
REM (vazia no XVWA, que nao exige login -> o hook nao injeta nada).

> "%LOG%" echo === OWASP ZAP ^| %APP%/%SCEN% ^| %URL% ^| %DATE% %TIME% ===
>> "%LOG%" echo CMD: docker run --memory 3000m --memory-swap 3000m -e DVWA_COOKIE=^<cookie^> %IMG_ZAP% zap-full-scan.py -t %URL% -m 2 -T 5 -c /zap/hooks/zap_rules.tsv -r zap_report.html -J zap_report.json -w zap_report.md -z "!_ZAP_CFG!" --hook=/zap/hooks/zap_hook.py -I  (cookie injetado via Replacer pelo hook)
>> "%LOG%" echo ----------------------------------------------------------------
docker run --rm --memory 3000m --memory-swap 3000m --network %NET% ^
    -e "DVWA_COOKIE=%COOKIE%" ^
    -v "%OUT_FWD%/zap:/zap/wrk:rw" ^
    -v "%SCRIPTS_FWD%:/zap/hooks:ro" ^
    %IMG_ZAP% ^
    zap-full-scan.py ^
        -t "%URL%" ^
        -m 2 -T 5 ^
        -c /zap/hooks/zap_rules.tsv ^
        -r zap_report.html -J zap_report.json -w zap_report.md ^
        -z "!_ZAP_CFG!" ^
        --hook=/zap/hooks/zap_hook.py ^
        -I >> "%LOG%" 2>&1
set "TOOL_RC=!ERRORLEVEL!"
>> "%LOG%" echo.
>> "%LOG%" echo TOOL_RC=!TOOL_RC!

call "%LIB%" health_probe "%URL%" "%OUT%\02_post_zap_health.txt"
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\02_post_zap_stats.txt"
if not "%WAFCT%"=="" call "%LIB%" dump_logs "%WAFCT%" "%OUT%\02_zap_waf.log"

exit /b 0
