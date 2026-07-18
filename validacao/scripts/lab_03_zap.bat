@echo off
REM ============================================================================
REM  lab_03_zap.bat  --  Ferramenta 2/6: OWASP ZAP (DAST full-scan)
REM
REM  Roda zap-full-scan.py contra os 8 alvos (DVWA e XVWA x 4 cenarios).
REM  Orcamento MODERADO e limitado: spider 1 min, active scan ate 3 min e
REM  inicializacao/passivo ate 2 min. Mesmos limites nos 8 destinos.
REM  Input IDENTICO nos 4 cenarios de cada app; so a URL base (host) muda.
REM
REM  DVWA: exige login. O cookie de sessao e RENOVADO (login fresco) antes do
REM        scan e injetado via ZAP Replacer em TODA requisicao, para varrer as
REM        paginas autenticadas. Alvo = raiz (/).
REM  XVWA: nao exige login (modulos abertos). Alvo = /xvwa/ (sem cookie).
REM
REM  Hook (validacao/helpers/zap_hook.py via --hook) exclui logout/setup/security do
REM  scan: evita deslogar o DVWA e evita resetar o banco do XVWA (/xvwa/setup/).
REM  Se ainda assim o scan quebrar, o relatorio e gerado mesmo assim (-I).
REM  Relatorios HTML/JSON/MD salvos em <app>\<cenario>\zap\.
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
for %%I in ("%ROOT%\..") do set "LAB_ROOT=%%~fI"
set "NET=dobotshield_waflab"
set "RESULTS=%LAB_ROOT%\results"
set "LIB=%ROOT%\lab_lib.bat"
set "IMG_CURL=curlimages/curl:latest@sha256:7c12af72ceb38b7432ab85e1a265cff6ae58e06f95539d539b654f2cfa64bb13"
set "IMG_ZAP=zaproxy/zap-stable:latest@sha256:8d387b1a63e3425beef4846e39719f5af2a787753af2d8b6558c6257d7a577a2"
set "IMG_PY=python:3-alpine@sha256:26730869004e2b9c4b9ad09cab8625e81d256d1ce97e72df5520e806b1709f92"
set "SCRIPTS_DIR=%LAB_ROOT%\helpers"
set "SCRIPTS_FWD=%SCRIPTS_DIR:\=/%"
set "COOKIE_FILE=%SCRIPTS_DIR%\dvwa_cookie.txt"
set "TMP_LOG_DIR=%TEMP%\dobotshield-validation"
if not exist "%TMP_LOG_DIR%" mkdir "%TMP_LOG_DIR%"
set "FAIL=0"

set "DVWA_COOKIE="
if exist "%COOKIE_FILE%" set /p DVWA_COOKIE=<"%COOKIE_FILE%"

echo.
echo ============================================================
echo   FERRAMENTA: OWASP ZAP (full-scan, moderado)  --  %DATE% %TIME%
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
for /f "delims=" %%C in ('docker run --rm --network %NET% -v "%SCRIPTS_FWD%:/scripts:ro" %IMG_PY% python /scripts/dvwa_login.py --no-setup "http://!IP_DVWA!:80" 2^>"%TMP_LOG_DIR%\dvwa_login.zap.stderr.log"') do set "DVWA_COOKIE=%%C"
if defined DVWA_COOKIE set "DVWA_COOKIE=!DVWA_COOKIE:; =;!"
if defined DVWA_COOKIE (
    > "%COOKIE_FILE%" echo !DVWA_COOKIE!
    echo   Cookie DVWA renovado: !DVWA_COOKIE!
) else (
    echo   [ERRO] Nao renovou o cookie DVWA. O ZAP nao sera executado sem sessao valida.
    if exist "%TMP_LOG_DIR%\dvwa_login.zap.stderr.log" type "%TMP_LOG_DIR%\dvwa_login.zap.stderr.log"
    exit /b 4
)

REM --- DVWA: scan AUTENTICADO a partir da raiz (cookie via Replacer) ---
call "%ROOT%\lab_03_zap_one.bat" dvwa no_waf      "http://!IP_DVWA!:80"            lab_dvwa      ""                "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_03_zap_one.bat" dvwa modsecurity "https://!IP_MODSEC_DVWA!:8443"  lab_dvwa      lab_modsec_dvwa   "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_03_zap_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443"    lab_dvwa      lab_dobot_dvwa    "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_03_zap_one.bat" dvwa coraza      "https://!IP_CORAZA_DVWA!:443"   lab_dvwa      lab_coraza_dvwa   "!DVWA_COOKIE!"
if errorlevel 1 set "FAIL=1"

REM --- XVWA: scan a partir de /xvwa/ (sem cookie; modulos abertos) ---
call "%ROOT%\lab_03_zap_one.bat" xvwa no_waf      "http://!IP_XVWA!:80/xvwa/"            lab_xvwa      ""                ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_03_zap_one.bat" xvwa modsecurity "https://!IP_MODSEC_XVWA!:8443/xvwa/"  lab_xvwa      lab_modsec_xvwa   ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_03_zap_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443/xvwa/"    lab_xvwa      lab_dobot_xvwa    ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_03_zap_one.bat" xvwa coraza      "https://!IP_CORAZA_XVWA!:443/xvwa/"   lab_xvwa      lab_coraza_xvwa   ""
if errorlevel 1 set "FAIL=1"

echo.
echo ============================================================
echo   OWASP ZAP CONCLUIDO: %DATE% %TIME%
echo   Logs em: %RESULTS%\^<app^>\^<cenario^>\02_zap.log  (+ pasta zap\)
echo ============================================================
exit /b %FAIL%
