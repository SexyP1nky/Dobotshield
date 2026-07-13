@echo off
REM ============================================================================
REM  lab_03_zap.bat  --  Ferramenta 2/6: ZAP (DAST full-scan)
REM
REM  Roda zap-full-scan.py contra os 8 alvos (DVWA e XVWA x 4 cenarios).
REM  Orcamento MODERADO: spider 2 min (-m 2) + scan/passivo ate 5 min (-T 5).
REM  Input IDENTICO nos 4 cenarios de cada app; so a URL base (host) muda.
REM
REM  DVWA: exige login. O cookie de sessao e RENOVADO (login fresco) antes do
REM        scan e injetado via ZAP Replacer em TODA requisicao, para varrer as
REM        paginas autenticadas. Alvo = raiz (/).
REM  XVWA: nao exige login (modulos abertos). Alvo = /xvwa/ (sem cookie).
REM
REM  Hook (helpers/zap_hook.py via --hook) exclui logout/setup/security do
REM  scan: evita deslogar o DVWA e evita resetar o banco do XVWA (/xvwa/setup/).
REM  Se ainda assim o scan quebrar, o relatorio e gerado mesmo assim (-I).
REM  Relatorios HTML/JSON/MD salvos em <app>\<cenario>\zap\.
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fI"
set "NET=dobotshield_waflab"
set "RESULTS=%ROOT%\results"
set "LIB=%SCRIPT_DIR%\lab_lib.bat"
set "IMG_CURL=curlimages/curl:latest"
set "IMG_ZAP=zaproxy/zap-stable:latest"
set "IMG_PY=python:3-alpine"
set "SCRIPTS_DIR=%ROOT%\helpers"
set "SCRIPTS_FWD=%SCRIPTS_DIR:\=/%"
set "COOKIE_FILE=%SCRIPTS_DIR%\dvwa_cookie.txt"
set "FAIL=0"

set "DVWA_COOKIE="
if exist "%COOKIE_FILE%" set /p DVWA_COOKIE=<"%COOKIE_FILE%"

echo.
echo ============================================================
echo   FERRAMENTA: ZAP (full-scan, moderado)  --  %DATE% %TIME%
if defined DVWA_COOKIE echo   Cookie DVWA: !DVWA_COOKIE!
echo ============================================================

call "%LIB%" ensure_net || exit /b 2
docker image inspect %IMG_ZAP% >nul 2>&1 || docker pull %IMG_ZAP% || ( echo [ERRO] sem imagem %IMG_ZAP%. Alternativa: ghcr.io/zaproxy/zaproxy:stable & exit /b 3 )

REM --- Resolver IPs dos containers (IP:PORTA em vez de hostname) ---
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dvwa') do set "IP_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_xvwa') do set "IP_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_dvwa') do set "IP_DOBOT_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_dobot_xvwa') do set "IP_DOBOT_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_modsec_dvwa') do set "IP_MODSEC_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_modsec_xvwa') do set "IP_MODSEC_XVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_coraza_dvwa') do set "IP_CORAZA_DVWA=%%I"
for /f "tokens=*" %%I in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" lab_coraza_xvwa') do set "IP_CORAZA_XVWA=%%I"

for %%V in (IP_DVWA IP_XVWA IP_DOBOT_DVWA IP_DOBOT_XVWA IP_MODSEC_DVWA IP_MODSEC_XVWA IP_CORAZA_DVWA IP_CORAZA_XVWA) do (
    if "!%%V!"=="" (
        echo [ERRO] %%V vazio. Rode lab_01_subir.bat e tente novamente.
        exit /b 6
    )
)

REM --- Renova o cookie do DVWA (login fresco) p/ o ZAP varrer AUTENTICADO ---
echo.
echo Renovando cookie do DVWA (login admin/password, security=low) para o ZAP...
set "DVWA_COOKIE="
for /f "delims=" %%C in ('docker run --rm --network %NET% -v "%SCRIPTS_FWD%:/scripts:ro" %IMG_PY% python /scripts/dvwa_login.py --no-setup "http://!IP_DVWA!:80" 2^>"%SCRIPTS_DIR%\dvwa_login.zap.stderr.log"') do set "DVWA_COOKIE=%%C"
if defined DVWA_COOKIE set "DVWA_COOKIE=!DVWA_COOKIE:; =;!"
if defined DVWA_COOKIE (
    > "%COOKIE_FILE%" echo !DVWA_COOKIE!
    echo   Cookie DVWA renovado: !DVWA_COOKIE!
) else (
    echo   [ERRO] Nao renovou o cookie DVWA. O ZAP nao sera executado sem sessao valida.
    if exist "%SCRIPTS_DIR%\dvwa_login.zap.stderr.log" type "%SCRIPTS_DIR%\dvwa_login.zap.stderr.log"
    exit /b 4
)

REM --- DVWA: scan AUTENTICADO a partir da raiz (cookie via Replacer) ---
call "%SCRIPT_DIR%\lab_03_zap_one.bat" dvwa no_waf      "http://!IP_DVWA!:80"            lab_dvwa      ""                "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"
call "%SCRIPT_DIR%\lab_03_zap_one.bat" dvwa modsecurity "https://!IP_MODSEC_DVWA!:8443"  lab_dvwa      lab_modsec_dvwa   "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"
call "%SCRIPT_DIR%\lab_03_zap_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443"    lab_dvwa      lab_dobot_dvwa    "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"
call "%SCRIPT_DIR%\lab_03_zap_one.bat" dvwa coraza      "https://!IP_CORAZA_DVWA!:443"   lab_dvwa      lab_coraza_dvwa   "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"

REM --- XVWA: scan a partir de /xvwa/ (sem cookie; modulos abertos) ---
call "%SCRIPT_DIR%\lab_03_zap_one.bat" xvwa no_waf      "http://!IP_XVWA!:80/xvwa/"            lab_xvwa      ""                ""
if errorlevel 1 set "FAIL=1"
call "%SCRIPT_DIR%\lab_03_zap_one.bat" xvwa modsecurity "https://!IP_MODSEC_XVWA!:8443/xvwa/"  lab_xvwa      lab_modsec_xvwa   ""
if errorlevel 1 set "FAIL=1"
call "%SCRIPT_DIR%\lab_03_zap_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443/xvwa/"    lab_xvwa      lab_dobot_xvwa    ""
if errorlevel 1 set "FAIL=1"
call "%SCRIPT_DIR%\lab_03_zap_one.bat" xvwa coraza      "https://!IP_CORAZA_XVWA!:443/xvwa/"   lab_xvwa      lab_coraza_xvwa   ""
if errorlevel 1 set "FAIL=1"

echo.
echo ============================================================
echo   ZAP CONCLUIDO: %DATE% %TIME%
echo   Logs em: %RESULTS%\^<app^>\^<cenario^>\02_zap.log  (+ pasta zap\)
echo ============================================================
exit /b %FAIL%
