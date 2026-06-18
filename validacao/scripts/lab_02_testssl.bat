@echo off
REM ============================================================================
REM  lab_02_testssl.bat  --  Ferramenta 1/6: testssl.sh (TLS/SSL)
REM
REM  Roda testssl.sh contra os 8 alvos (DVWA e XVWA x 4 cenarios).
REM  Input IDENTICO em todos; so a URL/host muda.
REM
REM  Observacao: nos cenarios "no_waf" o alvo e HTTP puro (sem TLS); o testssl
REM  registra a ausencia de TLS -- dado academicamente valido (a terminacao
REM  TLS so existe quando ha um WAF na frente).
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "NET=dobotshield_waflab"
set "RESULTS=%ROOT%\lab_results"
set "LIB=%ROOT%\lab_lib.bat"
set "IMG_CURL=curlimages/curl:latest"
set "IMG_TESTSSL=drwetter/testssl.sh:latest"
set "FAIL=0"

echo.
echo ============================================================
echo   FERRAMENTA: testssl.sh (TLS/SSL)   --  %DATE% %TIME%
echo ============================================================

call "%LIB%" ensure_net || exit /b 2
docker image inspect %IMG_TESTSSL% >nul 2>&1 || docker pull %IMG_TESTSSL% || ( echo [ERRO] sem imagem %IMG_TESTSSL%. & exit /b 3 )

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
        exit /b 4
    )
)

call "%ROOT%\lab_02_testssl_one.bat" dvwa no_waf      "http://!IP_DVWA!:80"            lab_dvwa      ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_02_testssl_one.bat" dvwa modsecurity "https://!IP_MODSEC_DVWA!:8443"  lab_dvwa      lab_modsec_dvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_02_testssl_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443"    lab_dvwa      lab_dobot_dvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_02_testssl_one.bat" dvwa coraza      "https://!IP_CORAZA_DVWA!:443"   lab_dvwa      lab_coraza_dvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_02_testssl_one.bat" xvwa no_waf      "http://!IP_XVWA!:80"            lab_xvwa      ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_02_testssl_one.bat" xvwa modsecurity "https://!IP_MODSEC_XVWA!:8443"  lab_xvwa      lab_modsec_xvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_02_testssl_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443"    lab_xvwa      lab_dobot_xvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_02_testssl_one.bat" xvwa coraza      "https://!IP_CORAZA_XVWA!:443"   lab_xvwa      lab_coraza_xvwa
if errorlevel 1 set "FAIL=1"

echo.
echo ============================================================
echo   testssl.sh CONCLUIDO: %DATE% %TIME%
echo   Logs em: %RESULTS%\^<app^>\^<cenario^>\01_testssl.log
echo ============================================================
exit /b %FAIL%
