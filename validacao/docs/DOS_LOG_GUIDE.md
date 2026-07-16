# Guia de Evidencias por Logs

Este guia descreve como usar os artefatos gerados pela bancada atual
(`DVWA + XVWA`) para sustentar que uma ferramenta degradou, explorou ou foi
bloqueada por um WAF. A execucao completa recomendada e `lab_run_tudo.bat`.

## Estrutura

Para cada combinacao `app x cenario`, os arquivos ficam em:

```text
validacao\results\<app>\<cenario>\
```

Apps:

- `dvwa`
- `xvwa`

Cenarios:

- `no_waf`
- `modsecurity`
- `dobotshield`
- `coraza`

Arquivos principais:

```text
00_pre_battery_health.txt
00_pre_battery_stats.txt
01_testssl.log
02_zap.log
02_zap_waf.log
03_sqlmap.log
03_sqlmap_waf.log
04_xsstrike.log
04_xsstrike_waf.log
05_commix.log
05_commix_waf.log
06_wrk.log
06_wrk_waf.log
99_post_battery_health.txt
99_post_battery_stats.txt
99_backend_full.log
99_waf_full.log
SUMMARY.txt
```

Subpastas nativas:

- `zap\` contem `zap_report.html`, `zap_report.json` e `zap_report.md`.
- `sqlmap\` contem a sessao e os resultados do SQLMap.
- `commix\` contem a saida propria do Commix.

## Como Ler

Compare sempre tres sinais:

1. Saude antes/depois: `*_health.txt`, olhando `code=`, `time=` e `bytes=`.
2. Recursos antes/depois: `*_stats.txt`, olhando CPU, memoria, rede e PIDs.
3. Logs do alvo/WAF: `*_waf.log`, `99_backend_full.log` e `99_waf_full.log`.

Exemplo de queda por carga:

```text
00_pre_battery_health.txt:  code=200 em 5 probes
06_post_wrk_health.txt:     code=000 ou timeouts
06_post_wrk_stats.txt:      CPU/PIDs/rede muito acima do pre-teste
99_backend_full.log:        rajada de requisicoes ou reinicio do processo
```

Exemplo de bloqueio pelo WAF:

```text
03_sqlmap.log:      ferramenta enviou payloads SQLi
03_sqlmap_waf.log:  WAF registrou bloqueios/regras disparadas
03_post_sqlmap_health.txt: app continuou respondendo
```

## Padrao de Inputs

Dentro de cada app, os quatro cenarios recebem o mesmo input. Apenas o IP:porta
do alvo muda.

- SQLMap DVWA: `GET /vulnerabilities/sqli/?id=1&Submit=Submit` e blind SQLi,
  parametro `id`, com cookie DVWA renovado via `--no-setup`.
- SQLMap XVWA: `POST /xvwa/vulnerabilities/sqli/`, `--data item=1`,
  parametro `item`.
- XSStrike DVWA: `GET /vulnerabilities/xss_r/?name=test`, com cookie DVWA
  renovado.
- XSStrike XVWA: `GET /xvwa/vulnerabilities/reflected_xss/?item=test`.
- Commix DVWA: `POST /vulnerabilities/exec/`, `ip=127.0.0.1&Submit=Submit`,
  com cookie DVWA renovado.
- Commix XVWA: `GET /xvwa/vulnerabilities/cmdi/?target=127.0.0.1`.
- ZAP DVWA: raiz autenticada com cookie renovado via `--no-setup` e hook
  contra logout/setup.
- ZAP XVWA: `/xvwa/`, sem cookie, com hook contra `/xvwa/setup/`.
- wrk e testssl: mesmo perfil em todos os cenarios.

Somente `lab_00_setup.bat` pode criar/resetar banco. Os scanners autenticados
usam login sem setup; o SQLMap nao usa crawl e nao acessa `/setup.php`.

## Execucao

```bat
lab_run_tudo.bat
```

O runner salva um log mestre em:

```text
validacao\results\run_<timestamp>.log
```

Os scripts individuais tambem podem ser rodados separadamente depois de
`lab_00_setup.bat` e `lab_01_subir.bat`.
