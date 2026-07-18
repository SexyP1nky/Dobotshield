# Guia de evidências da validação

Este guia descreve como localizar e interpretar os artefatos da bancada
`DVWA + XVWA`. A rodada consolidada foi executada em 17 e 18 de julho de 2026.

## Estrutura

Cada combinação `aplicação × cenário` usa o diretório:

```text
validacao/results/<app>/<cenario>/
```

Aplicações: `dvwa` e `xvwa`.

Cenários: `no_waf`, `modsecurity`, `dobotshield` e `coraza`.

Arquivos principais de cada combinação:

```text
00_pre_battery_health.txt
00_pre_battery_stats.txt
01_pre_testssl_health.txt / 01_post_testssl_health.txt
01_pre_testssl_stats.txt  / 01_post_testssl_stats.txt
01_testssl.log
02_pre_zap_health.txt     / 02_post_zap_health.txt
02_pre_zap_stats.txt      / 02_post_zap_stats.txt
02_zap.log
03_pre_sqlmap_health.txt  / 03_post_sqlmap_health.txt
03_pre_sqlmap_stats.txt   / 03_post_sqlmap_stats.txt
03_sqlmap.log
04_pre_xsstrike_health.txt / 04_post_xsstrike_health.txt
04_pre_xsstrike_stats.txt  / 04_post_xsstrike_stats.txt
04_xsstrike.log
05_pre_commix_health.txt  / 05_post_commix_health.txt
05_pre_commix_stats.txt   / 05_post_commix_stats.txt
05_commix.log
06_pre_wrk_health.txt     / 06_post_wrk_health.txt
06_pre_wrk_stats.txt      / 06_post_wrk_stats.txt
06_wrk.log
```

Nos cenários protegidos, cada etapa também possui `<etapa>_waf.log`, com a
saída do contêiner do WAF. As subpastas nativas são:

- `zap/`: `zap_report.html`, `zap_report.json` e `zap_report.md`;
- `sqlmap/`: sessão e CSV de resultados do SQLMap;
- `commix/`: saída própria do Commix.

Na raiz de `validacao/results/` ficam:

- `ANALISE_RESULTADOS.json`;
- `RESUMO_RESULTADOS.txt`;
- `METODOLOGIA.txt`, cópia da metodologia usada na rodada.

## Como interpretar

Compare sempre quatro sinais:

1. veredito da ferramenta no log numerado;
2. códigos HTTP e erros de conexão no mesmo log;
3. saúde e recursos imediatamente antes e depois da ferramenta;
4. log do WAF, quando o cenário é protegido.

Um `403`, `400`, `429`, `502`, timeout ou encerramento da ferramenta não prova
sozinho que o WAF bloqueou o ataque. O veredito precisa ser coerente com o
payload enviado, a regra registrada e o estado do backend.

Exemplo de bloqueio de SQLi pelo DoBotShield:

```text
03_sqlmap.log:             payloads enviados e resultado "não injetável"
03_sqlmap_waf.log:         eventos da regra SQLi
03_post_sqlmap_health.txt: aplicação continua respondendo
```

Exemplo de leitura do `wrk`:

```text
06_wrk.log:              req/s, total, não 2xx/3xx, latência e erros
06_pre_wrk_stats.txt:    recursos antes da carga
06_post_wrk_stats.txt:   recursos depois da carga
06_post_wrk_health.txt:  disponibilidade após a execução única
```

## Paridade dos inputs

Dentro de cada aplicação, os quatro cenários recebem a mesma entrada; somente o
host/porta muda. A paridade final passou em 12/12 grupos de
aplicação/ferramenta.

- SQLMap DVWA: endpoints `sqli` e `sqli_blind`, parâmetro `id`, cookie renovado,
  `--technique=B --level=1 --risk=1 --delay=0.3 --string=Surname`, sem tamper.
- SQLMap XVWA: `POST /xvwa/vulnerabilities/sqli/`, `item=1`, parâmetro `item`,
  `--technique=B --level=1 --risk=1 --delay=0.3 --string=Category`, sem tamper.
- XSStrike DVWA: `GET /vulnerabilities/xss_r/?name=test`, cookie renovado,
  dez threads, `--skip --skip-dom`.
- XSStrike XVWA: `GET /xvwa/vulnerabilities/reflected_xss/?item=test`, dez
  threads, `--skip --skip-dom`.
- Commix DVWA: `POST /vulnerabilities/exec/`,
  `ip=127.0.0.1&Submit=Submit`, cookie renovado, `--level=3 --delay=1`.
- Commix XVWA: `GET /xvwa/vulnerabilities/cmdi/?target=127.0.0.1`,
  `--level=3 --delay=1`.
- ZAP: mesma política e regra 40026 ignorada em todos os destinos; DVWA usa
  sessão autenticada e XVWA usa as mesmas sementes relativas nos quatro
  cenários.
- wrk: `-t12 -c400 -d30s --timeout 5s --latency`, uma execução por cenário.
- testssl.sh: mesmo perfil por aplicação; os baselines `no_waf` usam HTTP e,
  portanto, não oferecem TLS.

## Execução por etapas

A partir de `validacao/scripts/`:

```bat
lab_00_setup.bat
lab_01_subir.bat
lab_02_testssl.bat
lab_03_zap_isolado.bat
lab_04_sqlmap.bat
lab_05_xsstrike.bat
lab_06_commix.bat
lab_07_wrk.bat
lab_99_derrubar.bat
```

Os scripts `lab_0X_*_one.bat` são os executores unitários chamados pelos
runners. Apenas `lab_00_setup.bat` cria ou redefine os bancos; as demais etapas
preservam o estado preparado.

Os resultados consolidados versionados são apenas as evidências diretas das seis
ferramentas, os logs dos WAFs, os snapshots de saúde/recursos e os resumos da
rodada. Testes end-to-end adicionais, auditorias auxiliares e seus utilitários
permanecem fora do repositório.
