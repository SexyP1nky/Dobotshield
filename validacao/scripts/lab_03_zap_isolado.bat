@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lab_03_zap_isolado.ps1"
exit /b %ERRORLEVEL%
