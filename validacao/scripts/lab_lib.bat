@echo off
REM ============================================================================
REM  lab_lib.bat  --  Subrotinas comuns da bancada DoBotShield
REM
REM  NAO executar diretamente. E chamado pelos demais .bat assim:
REM     call "%LIB%" health_probe  "<url>"        "<arquivo_saida>"
REM     call "%LIB%" stats_snap    "<backend_ct>" "<waf_ct>"  "<arquivo_saida>"
REM     call "%LIB%" dump_logs     "<container>"  "<arquivo_saida>"
REM     call "%LIB%" ensure_net
REM
REM  Cada chamada re-executa este script, despacha pela 1a palavra e retorna
REM  via exit /b. Le %NET% herdado do .bat chamador (fallback embutido abaixo).
REM ============================================================================

setlocal enableextensions enabledelayedexpansion

if "%NET%"==""      set "NET=dobotshield_waflab"
if "%IMG_CURL%"=="" set "IMG_CURL=curlimages/curl:latest"

set "LABFN=%~1"
shift

if /i "%LABFN%"=="health_probe" goto :health_probe
if /i "%LABFN%"=="stats_snap"   goto :stats_snap
if /i "%LABFN%"=="dump_logs"    goto :dump_logs
if /i "%LABFN%"=="ensure_net"   goto :ensure_net

echo [lab_lib] subrotina desconhecida: %LABFN%
exit /b 1

REM ----------------------------------------------------------------------------
REM  health_probe  <url>  <arquivo>
REM  5 requisicoes curl metrificadas (codigo HTTP, tempo, bytes) a partir de um
REM  container curl na rede do lab. Mede disponibilidade/recuperacao do alvo.
REM ----------------------------------------------------------------------------
:health_probe
set "_HP_URL=%~1"
set "_HP_FILE=%~2"
> "%_HP_FILE%" echo === health_probe  %DATE% %TIME% ===
>> "%_HP_FILE%" echo URL: %_HP_URL%
for /l %%I in (1,1,5) do (
    docker run --rm --network %NET% %IMG_CURL% ^
        -k -s -o /dev/null --max-time 10 ^
        -w "probe %%I  code=%%{http_code}  time=%%{time_total}s  bytes=%%{size_download}\n" ^
        "%_HP_URL%" >> "%_HP_FILE%" 2>&1
)
exit /b 0

REM ----------------------------------------------------------------------------
REM  stats_snap  <backend_ct>  <waf_ct>  <arquivo>
REM  Snapshot pontual de CPU/RAM/rede dos containers do alvo (backend e WAF).
REM ----------------------------------------------------------------------------
:stats_snap
set "_SS_BE=%~1"
set "_SS_WF=%~2"
set "_SS_FILE=%~3"
set "_SS_FMT=table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.PIDs}}"
> "%_SS_FILE%" echo === docker_stats  %DATE% %TIME% ===
if not "%_SS_BE%"=="" docker stats --no-stream --format "%_SS_FMT%" "%_SS_BE%" >> "%_SS_FILE%" 2>&1
if not "%_SS_WF%"=="" docker stats --no-stream --format "%_SS_FMT%" "%_SS_WF%" >> "%_SS_FILE%" 2>&1
exit /b 0

REM ----------------------------------------------------------------------------
REM  dump_logs  <container>  <arquivo>
REM  Ultimas 3000 linhas de log do container (ex.: eventos WAF_BLOCK/DoS_BLOCK
REM  do DoBotShield, ou regras CRS disparadas no ModSecurity/Coraza).
REM ----------------------------------------------------------------------------
:dump_logs
set "_DL_CT=%~1"
set "_DL_FILE=%~2"
> "%_DL_FILE%" echo === docker_logs %_DL_CT%  (%DATE% %TIME%) ===
docker logs --tail 3000 "%_DL_CT%" >> "%_DL_FILE%" 2>&1
exit /b 0

REM ----------------------------------------------------------------------------
REM  ensure_net
REM  Verifica se a rede do lab existe (alvos no ar). Retorna 1 se nao.
REM ----------------------------------------------------------------------------
:ensure_net
docker network inspect %NET% >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Rede Docker "%NET%" nao encontrada.
    echo        Rode primeiro:  lab_01_subir.bat
    exit /b 1
)
exit /b 0
