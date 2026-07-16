@echo off
REM ============================================================================
REM  lab_99_derrubar.bat  --  Derruba e limpa o laboratorio
REM
REM  Para e remove os 8 containers + a rede do lab. NAO apaga validacao\results\
REM  (os resultados ficam preservados) nem as imagens construidas.
REM ============================================================================

setlocal enableextensions

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
for %%I in ("%ROOT%\..") do set "LAB_ROOT=%%~fI"
set "COMPOSE=%LAB_ROOT%\docker-compose.lab.yml"

echo.
echo ============================================================
echo   Derrubando o lab DoBotShield...  %DATE% %TIME%
echo ============================================================
docker compose -f "%COMPOSE%" down --remove-orphans

echo.
echo   Lab derrubado. Resultados preservados em: %LAB_ROOT%\results
echo   (Para apagar tambem os volumes: docker compose -f "%COMPOSE%" down -v)
exit /b 0
