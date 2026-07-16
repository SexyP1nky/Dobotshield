@echo off
REM ============================================================================
REM  lab_07_wrk.bat  --  Ferramenta 6/6: wrk (carga HTTP / teste de DoS)
REM
REM  Roda wrk contra os 8 alvos. Input IDENTICO em todos; so a URL muda.
REM
REM  Configuracao (agressiva, identica para todos -- e um teste de carga,
REM  nao de payload; por isso NAO usa delay nem cookie):
REM    - 3 repeticoes por cenario; em cada uma: 12 threads, 400 conexoes,
REM      30s, timeout 5s, --latency e o mesmo User-Agent fixo.
REM
REM  Mede throughput/resiliencia. Contra o DoBotShield (rate-limit LIGADO),
REM  espera-se estrangulamento do flood (HTTP 429 / conexoes recusadas) --
REM  ModSecurity/Coraza (CRS) nao fazem rate-limiting.
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
for %%I in ("%ROOT%\..") do set "LAB_ROOT=%%~fI"
set "NET=dobotshield_waflab"
set "RESULTS=%LAB_ROOT%\results"
set "LIB=%ROOT%\lab_lib.bat"
set "IMG_CURL=curlimages/curl:latest@sha256:7c12af72ceb38b7432ab85e1a265cff6ae58e06f95539d539b654f2cfa64bb13"
set "IMG_WRK=dobotshield/wrk:latest"
set "FAIL=0"

echo.
echo ============================================================
echo   FERRAMENTA: wrk (3 x carga 12t x 400c x 30s)  --  %DATE% %TIME%
echo ============================================================

call "%LIB%" ensure_net || exit /b 2
docker image inspect %IMG_WRK% >nul 2>&1 || (
    echo Imagem %IMG_WRK% ausente -- construindo...
    docker build -t %IMG_WRK% "%LAB_ROOT%\docker\wrk" || ( echo [ERRO] build wrk falhou. & exit /b 3 )
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
        exit /b 4
    )
)

call "%ROOT%\lab_07_wrk_one.bat" dvwa no_waf      "http://!IP_DVWA!:80"                 lab_dvwa      ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_07_wrk_one.bat" dvwa modsecurity "https://!IP_MODSEC_DVWA!:8443"       lab_dvwa      lab_modsec_dvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_07_wrk_one.bat" dvwa dobotshield "https://!IP_DOBOT_DVWA!:443"         lab_dvwa      lab_dobot_dvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_07_wrk_one.bat" dvwa coraza      "https://!IP_CORAZA_DVWA!:443"        lab_dvwa      lab_coraza_dvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_07_wrk_one.bat" xvwa no_waf      "http://!IP_XVWA!:80/xvwa/"           lab_xvwa      ""
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_07_wrk_one.bat" xvwa modsecurity "https://!IP_MODSEC_XVWA!:8443/xvwa/" lab_xvwa      lab_modsec_xvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_07_wrk_one.bat" xvwa dobotshield "https://!IP_DOBOT_XVWA!:443/xvwa/"   lab_xvwa      lab_dobot_xvwa
if errorlevel 1 set "FAIL=1"
call "%ROOT%\lab_07_wrk_one.bat" xvwa coraza      "https://!IP_CORAZA_XVWA!:443/xvwa/"  lab_xvwa      lab_coraza_xvwa
if errorlevel 1 set "FAIL=1"

echo.
echo ============================================================
echo   wrk CONCLUIDO: %DATE% %TIME%
echo   Logs em: %RESULTS%\^<app^>\^<cenario^>\06_wrk.log
echo ============================================================
exit /b %FAIL%
