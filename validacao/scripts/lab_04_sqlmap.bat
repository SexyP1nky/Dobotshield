@echo off
REM ============================================================================
REM  lab_04_sqlmap.bat  --  Ferramenta 3/6: SQLMap (SQL Injection)
REM
REM  Roda SQLMap contra os 8 alvos (DVWA e XVWA x 4 cenarios).
REM
REM  DVWA:  URLs explicitas (GET) para as 2 paginas vulneraveis a SQLi
REM         (/vulnerabilities/sqli/ e /vulnerabilities/sqli_blind/), -p id.
REM         Os argumentos sao IDENTICOS nos 4 cenarios; so a URL base muda.
REM
REM  XVWA:  endpoint explicito (POST) /xvwa/vulnerabilities/sqli/ com
REM         --data="item=1" -p item (itemid concatenado direto -> injetavel).
REM         Os argumentos sao IDENTICOS nos 4 cenarios; so a URL base muda.
REM         NAO usa --crawl (assim nao toca /xvwa/setup/, que recriaria o banco).
REM
REM  Padrao comum (IDENTICO em TODOS os cenarios -- justo p/ todos os WAFs):
REM    - --tamper=equaltolike: troca '=' por LIKE. Mantem a injecao valida na
REM      app crua (no MySQL, LIKE sem curinga == igualdade) e deixa de depender
REM      do operador '='. Mesmo tamper no no_waf e nos 3 WAFs. NAO altera delays.
REM    - Faixa controlada: --level=1 --risk=1, tecnica booleana (B).
REM    - Cookie DVWA (se houver) via --cookie. XVWA roda sem cookie (modulos abertos).
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
for %%I in ("%ROOT%\..") do set "LAB_ROOT=%%~fI"
set "NET=dobotshield_waflab"
set "RESULTS=%LAB_ROOT%\results"
set "LIB=%ROOT%\lab_lib.bat"
set "IMG_CURL=curlimages/curl:latest@sha256:7c12af72ceb38b7432ab85e1a265cff6ae58e06f95539d539b654f2cfa64bb13"
set "IMG_TOOLS=dobotshield/lab-tools:latest"
set "IMG_PY=python:3-alpine@sha256:26730869004e2b9c4b9ad09cab8625e81d256d1ce97e72df5520e806b1709f92"
set "CERT_DIR=%LAB_ROOT%\certs"
set "CERT_FWD=%CERT_DIR:\=/%"
set "SCRIPTS_DIR=%LAB_ROOT%\helpers"
set "SCRIPTS_FWD=%SCRIPTS_DIR:\=/%"
set "COOKIE_FILE=%SCRIPTS_DIR%\dvwa_cookie.txt"
set "FAIL=0"

set "DVWA_COOKIE="
if exist "%COOKIE_FILE%" set /p DVWA_COOKIE=<"%COOKIE_FILE%"

echo.
echo ============================================================
echo   FERRAMENTA: SQLMap (SQLi, level 1/risk 1, tecnica B, tamper equaltolike)  --  %DATE% %TIME%
if defined DVWA_COOKIE echo   Cookie DVWA: !DVWA_COOKIE!
echo ============================================================

call "%LIB%" ensure_net || exit /b 2
docker image inspect %IMG_TOOLS% >nul 2>&1 || (
    echo Imagem %IMG_TOOLS% ausente -- construindo...
    docker build -t %IMG_TOOLS% "%LAB_ROOT%\docker\lab-tools" || ( echo [ERRO] build lab-tools falhou. & exit /b 3 )
)

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

REM --- Renova o cookie do DVWA antes dos alvos autenticados ---
docker image inspect %IMG_PY% >nul 2>&1 || docker pull %IMG_PY% || ( echo [ERRO] sem imagem %IMG_PY%. & exit /b 4 )
echo.
echo Renovando cookie do DVWA (login admin/password, security=low) para o SQLMap...
set "DVWA_COOKIE="
for /f "delims=" %%C in ('docker run --rm --network %NET% -v "%SCRIPTS_FWD%:/scripts:ro" %IMG_PY% python /scripts/dvwa_login.py --no-setup "http://!IP_DVWA!:80" 2^>"%SCRIPTS_DIR%\dvwa_login.sqlmap.stderr.log"') do set "DVWA_COOKIE=%%C"
if defined DVWA_COOKIE set "DVWA_COOKIE=!DVWA_COOKIE:; =;!"
if defined DVWA_COOKIE (
    > "%COOKIE_FILE%" echo !DVWA_COOKIE!
    echo   Cookie DVWA renovado: !DVWA_COOKIE!
) else (
    echo   [ERRO] Nao renovou o cookie DVWA. SQLMap nao sera executado sem sessao valida.
    if exist "%SCRIPTS_DIR%\dvwa_login.sqlmap.stderr.log" type "%SCRIPTS_DIR%\dvwa_login.sqlmap.stderr.log"
    exit /b 5
)

REM --- DVWA: SQLi normal e Blind SQLi (GET, parametro id) ---
REM --string=Surname: texto que so aparece na resposta do /sqli/ quando a linha
REM do usuario e retornada (condicao booleana VERDADEIRA). Lido por
REM lab_04_sqlmap_one.bat. Mesmo valor nos 4 cenarios DVWA (justo).
set "SQLMAP_STRING=Surname"
call "%ROOT%\lab_04_sqlmap_one.bat" dvwa no_waf      "http://!IP_DVWA!:80"           "/vulnerabilities/sqli/?id=1&Submit=Submit" "/vulnerabilities/sqli_blind/?id=1&Submit=Submit" "id" lab_dvwa      ""                "!DVWA_COOKIE!" ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_04_sqlmap_one.bat" dvwa modsecurity "https://!IP_MODSEC_DVWA!:8443" "/vulnerabilities/sqli/?id=1&Submit=Submit" "/vulnerabilities/sqli_blind/?id=1&Submit=Submit" "id" lab_dvwa      lab_modsec_dvwa   "!DVWA_COOKIE!" ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_04_sqlmap_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443"   "/vulnerabilities/sqli/?id=1&Submit=Submit" "/vulnerabilities/sqli_blind/?id=1&Submit=Submit" "id" lab_dvwa      lab_dobot_dvwa    "!DVWA_COOKIE!" ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_04_sqlmap_one.bat" dvwa coraza      "https://!IP_CORAZA_DVWA!:443"  "/vulnerabilities/sqli/?id=1&Submit=Submit" "/vulnerabilities/sqli_blind/?id=1&Submit=Submit" "id" lab_dvwa      lab_coraza_dvwa   "!DVWA_COOKIE!" ""
if errorlevel 1 set "FAIL=1"

REM --- XVWA: SQLi (POST, parametro item; sem cookie; sem crawl) ---
REM --string=Category: so aparece quando o produto e retornado (TRUE). Mesmo
REM valor nos 4 cenarios XVWA.
set "SQLMAP_STRING=Category"
call "%ROOT%\lab_04_sqlmap_one.bat" xvwa no_waf      "http://!IP_XVWA!:80"           "/xvwa/vulnerabilities/sqli/" "" "item" lab_xvwa      ""                "" "item=1"
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_04_sqlmap_one.bat" xvwa modsecurity "https://!IP_MODSEC_XVWA!:8443" "/xvwa/vulnerabilities/sqli/" "" "item" lab_xvwa      lab_modsec_xvwa   "" "item=1"
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_04_sqlmap_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443"   "/xvwa/vulnerabilities/sqli/" "" "item" lab_xvwa      lab_dobot_xvwa    "" "item=1"
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_04_sqlmap_one.bat" xvwa coraza      "https://!IP_CORAZA_XVWA!:443"  "/xvwa/vulnerabilities/sqli/" "" "item" lab_xvwa      lab_coraza_xvwa   "" "item=1"
if errorlevel 1 set "FAIL=1"

echo.
echo ============================================================
echo   SQLMap CONCLUIDO: %DATE% %TIME%
echo   Logs em: %RESULTS%\^<app^>\^<cenario^>\03_sqlmap.log  (+ pasta sqlmap\)
echo ============================================================
exit /b %FAIL%
