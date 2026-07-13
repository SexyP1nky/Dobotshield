@echo off
REM ============================================================================
REM  lab_run_tudo.bat  --  Executa a bancada completa sem interacao manual
REM
REM  Ordem:
REM    1) lab_00_setup.bat
REM    2) lab_01_subir.bat
REM    3) lab_02_testssl.bat ... lab_07_wrk.bat
REM
REM  Alem dos logs individuais de cada ferramenta, grava:
REM    - results\run_<timestamp>.log
REM    - 00_pre_battery_* e 99_post_battery_* por app/cenario
REM    - 99_backend_full.log e 99_waf_full.log por app/cenario
REM    - SUMMARY.txt por app/cenario
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fI"

set "RESULTS=%ROOT%\results"
set "LIB=%SCRIPT_DIR%\lab_lib.bat"
set "NET=dobotshield_waflab"
set "IMG_CURL=curlimages/curl:latest"
set "FAIL=0"

if not exist "%RESULTS%" mkdir "%RESULTS%"

for /f "tokens=*" %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "RUN_ID=%%T"
set "RUN_LOG=%RESULTS%\run_%RUN_ID%.log"

> "%RUN_LOG%" echo === DoBotShield lab_run_tudo ^| %DATE% %TIME% ===
>> "%RUN_LOG%" echo ROOT=%ROOT%
>> "%RUN_LOG%" echo.

echo.
echo ============================================================
echo   DoBotShield Lab -- BATERIA COMPLETA
echo   Log mestre: %RUN_LOG%
echo ============================================================

call :run_step "00_setup" "%SCRIPT_DIR%\lab_00_setup.bat" true
if errorlevel 1 exit /b %ERRORLEVEL%

call :run_step "01_subir" "%SCRIPT_DIR%\lab_01_subir.bat" true
if errorlevel 1 exit /b %ERRORLEVEL%

call :resolve_ips
call :battery_snapshot "00_pre_battery"

call :run_step "02_testssl"  "%SCRIPT_DIR%\lab_02_testssl.bat"  false
call :run_step "03_zap"      "%SCRIPT_DIR%\lab_03_zap.bat"      false
call :run_step "04_sqlmap"   "%SCRIPT_DIR%\lab_04_sqlmap.bat"   false
call :run_step "05_xsstrike" "%SCRIPT_DIR%\lab_05_xsstrike.bat" false
call :run_step "06_commix"   "%SCRIPT_DIR%\lab_06_commix.bat"   false
call :run_step "08_manual_regression" "%SCRIPT_DIR%\lab_08_manual_regression.bat" false
call :run_step "07_wrk"      "%SCRIPT_DIR%\lab_07_wrk.bat"      false

call :resolve_ips
call :battery_snapshot "99_post_battery"
call :dump_final_logs
call :write_summaries

echo.
if "%FAIL%"=="0" (
    echo ============================================================
    echo   BATERIA COMPLETA CONCLUIDA SEM ERRO DE ORQUESTRACAO
    echo   Log mestre: %RUN_LOG%
    echo ============================================================
) else (
    echo ============================================================
    echo   BATERIA COMPLETA CONCLUIDA COM ERROS EM UMA OU MAIS ETAPAS
    echo   Log mestre: %RUN_LOG%
    echo ============================================================
)

exit /b %FAIL%

REM ----------------------------------------------------------------------------
:run_step
set "LABEL=%~1"
set "BAT=%~2"
set "REQUIRED=%~3"

echo.
echo [RUN] %LABEL%
echo   Script: %BAT%
>> "%RUN_LOG%" echo.
>> "%RUN_LOG%" echo ======================================================================
>> "%RUN_LOG%" echo [RUN] %LABEL% ^| %DATE% %TIME%
>> "%RUN_LOG%" echo ======================================================================

call "%BAT%" >> "%RUN_LOG%" 2>&1
set "RC=!ERRORLEVEL!"

>> "%RUN_LOG%" echo.
>> "%RUN_LOG%" echo [END] %LABEL% RC=!RC! ^| %DATE% %TIME%
echo   RC=!RC!

if not "!RC!"=="0" (
    set "FAIL=1"
    if /i "%REQUIRED%"=="true" (
        echo   [ERRO] etapa obrigatoria falhou: %LABEL%
        exit /b !RC!
    )
)
exit /b 0

REM ----------------------------------------------------------------------------
:resolve_ips
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dvwa') do set "IP_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_xvwa') do set "IP_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_dvwa') do set "IP_DOBOT_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_xvwa') do set "IP_DOBOT_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_modsec_dvwa') do set "IP_MODSEC_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_modsec_xvwa') do set "IP_MODSEC_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_coraza_dvwa') do set "IP_CORAZA_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_coraza_xvwa') do set "IP_CORAZA_XVWA=%%I"
exit /b 0

REM ----------------------------------------------------------------------------
:battery_snapshot
set "PREFIX=%~1"
echo.
echo [SNAPSHOT] %PREFIX%
>> "%RUN_LOG%" echo.
>> "%RUN_LOG%" echo [SNAPSHOT] %PREFIX% ^| %DATE% %TIME%
call :snap_one dvwa no_waf      "http://!IP_DVWA!:80"                 lab_dvwa        ""                  "%PREFIX%"
call :snap_one dvwa modsecurity "https://!IP_MODSEC_DVWA!:8443"       lab_dvwa        lab_modsec_dvwa     "%PREFIX%"
call :snap_one dvwa dobotshield "https://!IP_DOBOT_DVWA!:443"         lab_dvwa        lab_dobot_dvwa      "%PREFIX%"
call :snap_one dvwa coraza      "https://!IP_CORAZA_DVWA!:443"        lab_dvwa        lab_coraza_dvwa     "%PREFIX%"
call :snap_one xvwa no_waf      "http://!IP_XVWA!:80/xvwa/"           lab_xvwa        ""                  "%PREFIX%"
call :snap_one xvwa modsecurity "https://!IP_MODSEC_XVWA!:8443/xvwa/" lab_xvwa        lab_modsec_xvwa     "%PREFIX%"
call :snap_one xvwa dobotshield "https://!IP_DOBOT_XVWA!:443/xvwa/"   lab_xvwa        lab_dobot_xvwa      "%PREFIX%"
call :snap_one xvwa coraza      "https://!IP_CORAZA_XVWA!:443/xvwa/"  lab_xvwa        lab_coraza_xvwa     "%PREFIX%"
exit /b 0

REM ----------------------------------------------------------------------------
:snap_one
set "APP=%~1"
set "SCEN=%~2"
set "URL=%~3"
set "BACKEND=%~4"
set "WAFCT=%~5"
set "PREFIX=%~6"
set "OUT=%RESULTS%\%APP%\%SCEN%"
if not exist "%OUT%" mkdir "%OUT%"
call "%LIB%" health_probe "%URL%" "%OUT%\%PREFIX%_health.txt" >> "%RUN_LOG%" 2>&1
call "%LIB%" stats_snap   "%BACKEND%" "%WAFCT%" "%OUT%\%PREFIX%_stats.txt" >> "%RUN_LOG%" 2>&1
exit /b 0

REM ----------------------------------------------------------------------------
:dump_final_logs
echo.
echo [LOGS] salvando logs finais dos containers
>> "%RUN_LOG%" echo.
>> "%RUN_LOG%" echo [LOGS] salvando logs finais dos containers ^| %DATE% %TIME%
call :dump_one dvwa no_waf      lab_dvwa ""              
call :dump_one dvwa modsecurity lab_dvwa lab_modsec_dvwa
call :dump_one dvwa dobotshield lab_dvwa lab_dobot_dvwa
call :dump_one dvwa coraza      lab_dvwa lab_coraza_dvwa
call :dump_one xvwa no_waf      lab_xvwa ""              
call :dump_one xvwa modsecurity lab_xvwa lab_modsec_xvwa
call :dump_one xvwa dobotshield lab_xvwa lab_dobot_xvwa
call :dump_one xvwa coraza      lab_xvwa lab_coraza_xvwa
exit /b 0

REM ----------------------------------------------------------------------------
:dump_one
set "APP=%~1"
set "SCEN=%~2"
set "BACKEND=%~3"
set "WAFCT=%~4"
set "OUT=%RESULTS%\%APP%\%SCEN%"
if not exist "%OUT%" mkdir "%OUT%"
call "%LIB%" dump_logs "%BACKEND%" "%OUT%\99_backend_full.log" >> "%RUN_LOG%" 2>&1
if not "%WAFCT%"=="" call "%LIB%" dump_logs "%WAFCT%" "%OUT%\99_waf_full.log" >> "%RUN_LOG%" 2>&1
exit /b 0

REM ----------------------------------------------------------------------------
:write_summaries
echo.
echo [SUMMARY] escrevendo SUMMARY.txt por cenario
call :summary_one dvwa no_waf
call :summary_one dvwa modsecurity
call :summary_one dvwa dobotshield
call :summary_one dvwa coraza
call :summary_one xvwa no_waf
call :summary_one xvwa modsecurity
call :summary_one xvwa dobotshield
call :summary_one xvwa coraza
exit /b 0

REM ----------------------------------------------------------------------------
:summary_one
set "APP=%~1"
set "SCEN=%~2"
set "OUT=%RESULTS%\%APP%\%SCEN%"
set "SUMMARY=%OUT%\SUMMARY.txt"
if not exist "%OUT%" mkdir "%OUT%"
> "%SUMMARY%" echo === SUMMARY ^| %APP%/%SCEN% ^| %DATE% %TIME% ===
>> "%SUMMARY%" echo.
>> "%SUMMARY%" echo Arquivos principais:
for %%F in ("%OUT%\01_testssl.log" "%OUT%\02_zap.log" "%OUT%\03_sqlmap.log" "%OUT%\04_xsstrike.log" "%OUT%\05_commix.log" "%OUT%\06_wrk.log" "%OUT%\99_backend_full.log" "%OUT%\99_waf_full.log") do (
    if exist "%%~fF" >> "%SUMMARY%" echo   %%~nxF
)
>> "%SUMMARY%" echo.
>> "%SUMMARY%" echo Probes de saude:
for %%F in ("%OUT%\*_health.txt") do (
    >> "%SUMMARY%" echo.
    >> "%SUMMARY%" echo ----- %%~nxF -----
    type "%%~fF" >> "%SUMMARY%" 2>nul
)
>> "%SUMMARY%" echo.
>> "%SUMMARY%" echo Snapshots de recursos:
for %%F in ("%OUT%\*_stats.txt") do (
    >> "%SUMMARY%" echo.
    >> "%SUMMARY%" echo ----- %%~nxF -----
    type "%%~fF" >> "%SUMMARY%" 2>nul
)
exit /b 0
