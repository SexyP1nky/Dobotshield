@echo off
REM ============================================================================
REM  lab_01_subir.bat  --  ETAPA 2: sobe os 8 alvos e aguarda a saude
REM
REM  Sobe (docker compose up -d) as 2 aplicacoes vulneraveis e as mesmas
REM  aplicacoes protegidas por cada um dos 3 WAFs:
REM
REM     DVWA : sem WAF / ModSecurity / DoBotShield / Coraza
REM     XVWA : sem WAF / ModSecurity / DoBotShield / Coraza
REM
REM  Pre-requisito: lab_00_setup.bat ja executado (imagens, certificado e
REM  bancos de DVWA + XVWA criados).
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fI"
set "COMPOSE=%ROOT%\docker-compose.lab.yml"
set "CERT_DIR=%ROOT%\certs"
set "NET=dobotshield_waflab"
set "IMG_CURL=curlimages/curl:latest"
set "IMG_PY=python:3-alpine"
set "SCRIPTS_DIR=%ROOT%\helpers"
set "SCRIPTS_FWD=%SCRIPTS_DIR:\=/%"

echo.
echo ============================================================
echo   DoBotShield Lab  --  SUBIR ALVOS (8 cenarios)
echo   Inicio: %DATE% %TIME%
echo ============================================================

if not exist "%CERT_DIR%\server.crt" (
    echo [ERRO] Certificado ausente em %CERT_DIR%.
    echo        Rode lab_00_setup.bat primeiro.
    exit /b 10
)

where docker >nul 2>&1 || ( echo [ERRO] docker nao encontrado no PATH. & exit /b 11 )
docker info >nul 2>&1 || ( echo [ERRO] Docker engine inacessivel. Abra o Docker Desktop. & exit /b 12 )

echo.
echo [1/2] Subindo containers (build se necessario)...
echo --------------------------------------------------------
docker compose -f "%COMPOSE%" up -d --build || ( echo [ERRO] docker compose up falhou. & exit /b 20 )

REM A imagem historica do DVWA ocasionalmente inicia o banco, mas deixa o
REM Apache parado. Corrige essa corrida de forma idempotente antes dos probes.
docker exec lab_dvwa sh -c "pidof apache2 >/dev/null 2>&1 || service apache2 start" >nul 2>&1

echo.
echo [2/2] Resolvendo IPs e aguardando disponibilidade dos 8 alvos (ate 180s cada)...
echo --------------------------------------------------------
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dvwa') do set "IP_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_xvwa') do set "IP_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_dvwa') do set "IP_DOBOT_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_xvwa') do set "IP_DOBOT_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_modsec_dvwa') do set "IP_MODSEC_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_modsec_xvwa') do set "IP_MODSEC_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_coraza_dvwa') do set "IP_CORAZA_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_coraza_xvwa') do set "IP_CORAZA_XVWA=%%I"

for %%V in (IP_DVWA IP_XVWA IP_DOBOT_DVWA IP_DOBOT_XVWA IP_MODSEC_DVWA IP_MODSEC_XVWA IP_CORAZA_DVWA IP_CORAZA_XVWA) do (
    if not defined %%V (
        echo [ERRO] Nao foi possivel resolver %%V.
        docker compose -f "%COMPOSE%" ps
        exit /b 21
    )
)

call :wait_target "http://!IP_DVWA!:80"                 "DVWA        no_waf"
call :wait_target "https://!IP_MODSEC_DVWA!:8443"       "DVWA        modsecurity"
call :wait_target "https://!IP_DOBOT_DVWA!:443"         "DVWA        dobotshield"
call :wait_target "https://!IP_CORAZA_DVWA!:443"        "DVWA        coraza"
call :wait_target "http://!IP_XVWA!:80/xvwa/"           "XVWA        no_waf"
call :wait_target "https://!IP_MODSEC_XVWA!:8443/xvwa/" "XVWA        modsecurity"
call :wait_target "https://!IP_DOBOT_XVWA!:443/xvwa/"   "XVWA        dobotshield"
call :wait_target "https://!IP_CORAZA_XVWA!:443/xvwa/"  "XVWA        coraza"

REM Garante o banco do XVWA criado/populado (idempotente: caso o container
REM tenha sido recriado pelo "up --build"). O XVWA nao exige autenticacao.
echo.
echo   Garantindo banco do XVWA (/xvwa/setup/?action=do)...
docker run --rm --network %NET% -v "%SCRIPTS_FWD%:/scripts:ro" %IMG_PY% python /scripts/xvwa_setup.py "http://!IP_XVWA!:80" >"%SCRIPTS_DIR%\xvwa_setup.subir.stdout.log" 2>"%SCRIPTS_DIR%\xvwa_setup.subir.stderr.log"
if errorlevel 1 (
    echo   [ERRO] setup do XVWA falhou. Detalhes:
    if exist "%SCRIPTS_DIR%\xvwa_setup.subir.stderr.log" type "%SCRIPTS_DIR%\xvwa_setup.subir.stderr.log"
    exit /b 21
)

REM --- Defensivo (NAO-FATAL): recarrega o nginx dos WAFs ModSecurity p/ garantir
REM     estado limpo dos workers. Um worker em estado ruim pode responder 308 ->
REM     porta :443 (fechada) e quebrar ZAP/Commix SO no alvo afetado. Qualquer
REM     falha aqui e ignorada (o lab segue no ar); o script encerra com exit /b 0.
echo.
echo   Recarregando nginx dos WAFs ModSecurity (defensivo, nao-fatal)...
for %%C in (lab_modsec_dvwa lab_modsec_xvwa) do (
    docker exec %%C nginx -s reload >nul 2>&1
    if !ERRORLEVEL!==0 ( echo   [OK]   %%C nginx -s reload ) else ( echo   [AVISO] %%C reload ignorado -- seguindo )
)

echo.
echo ============================================================
echo   ALVOS NO AR: %DATE% %TIME%
echo   Status dos containers:
docker compose -f "%COMPOSE%" ps
echo.
echo   Proximo passo: rode as ferramentas (lab_02_testssl.bat ... lab_07_wrk.bat)
echo   ou lab_run_tudo.bat para a bateria completa.
echo ============================================================
exit /b 0

REM ----------------------------------------------------------------------------
:wait_target
set "_WT_URL=%~1"
set "_WT_LBL=%~2"
set /a _WT_TRIES=0
:_wt_loop
set /a _WT_TRIES+=1
docker run --rm --network %NET% %IMG_CURL% -k -s -o /dev/null --max-time 5 "%_WT_URL%" >nul 2>&1
if !ERRORLEVEL!==0 ( echo   [OK]   %_WT_LBL% & exit /b 0 )
if !_WT_TRIES! GEQ 36 ( echo   [AVISO] %_WT_LBL% nao respondeu em 180s -- seguindo. & exit /b 0 )
ping -n 6 127.0.0.1 >nul
goto :_wt_loop
