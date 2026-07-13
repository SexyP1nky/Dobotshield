@echo off
REM ============================================================================
REM  lab_99_derrubar.bat  --  Derruba e limpa o laboratorio
REM
REM  Para e remove os 8 containers + a rede do lab. NAO apaga results\
REM  (os resultados ficam preservados) nem as imagens construidas.
REM ============================================================================

setlocal enableextensions

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT=%%~fI"
set "COMPOSE=%ROOT%\docker-compose.lab.yml"

echo.
echo ============================================================
echo   Derrubando o lab DoBotShield...  %DATE% %TIME%
echo ============================================================
docker compose -f "%COMPOSE%" down --remove-orphans

echo.
echo   Lab derrubado. Resultados preservados em: %ROOT%\results
echo   (Para apagar tambem os volumes: docker compose -f "%COMPOSE%" down -v)
exit /b 0
