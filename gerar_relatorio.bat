@echo off
REM ============================================================
REM  DoBot Shield - Modo de Treinamento
REM  Gera o relatorio HTML (linha do tempo do ataque) a partir
REM  do log estruturado de requisicoes barradas pelo WAF.
REM
REM  Uso:
REM    gerar_relatorio.bat
REM    gerar_relatorio.bat -in logs\training.jsonl -out relatorio.html
REM ============================================================
setlocal
cd /d "%~dp0"

where go >nul 2>nul
if errorlevel 1 (
  echo [ERRO] Go nao foi encontrado no PATH. Instale o Go para gerar o relatorio.
  exit /b 1
)

echo Gerando relatorio do Modo de Treinamento...
go run ./cmd/report -open %*
if errorlevel 1 (
  echo [ERRO] Falha ao gerar o relatorio. Verifique se ha eventos registrados em logs\training.jsonl
  exit /b 1
)

echo Concluido.
endlocal
