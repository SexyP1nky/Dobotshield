@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lab_09_e2e_produto.ps1"
exit /b %ERRORLEVEL%
