# Relatório da rodada completa de validação

Período consolidado: 17 e 18 de julho de 2026.

A matriz contém 48 combinações comparativas: duas aplicações, quatro cenários e seis ferramentas. Para cada ferramenta, os parâmetros foram mantidos e somente o destino mudou. O `wrk` teve uma execução por cenário. Como a bancada havia produzido três execuções por engano, foi mantida sistematicamente a primeira execução completa de cada cenário, sem seleção por desempenho, e as duas posteriores foram excluídas. Nenhuma regra dos WAFs foi ajustada em função do resultado.

A regra ativa 40026 (DOM XSS) do ZAP foi ignorada uniformemente nos oito destinos porque encerrava o processo Java do scanner nesta bancada; XSS refletido permaneceu coberto pelo ZAP e pelo XSStrike.

## Resultados por cenário

| Aplicação | Cenário | ZAP HIGH | SQLMap confirmou SQLi | XSStrike encontrou XSS | Commix confirmou OSCI | wrk req/s | wrk não 2xx/3xx | Erros socket/timeout |
|---|---|---:|---|---|---|---:|---:|---|
| DVWA | no_waf | 1 | sim | sim | sim | 5.327,70 | 0 | timeout 558 |
| DVWA | modsecurity | 2 | não | não | não | 1.539,92 | 0 | 0 |
| DVWA | dobotshield | 1 | não | não | não | 2.299,94 | 0 | 0 |
| DVWA | coraza | 0 | não | não | não | 2.039,97 | 0 | timeout 733 |
| XVWA | no_waf | 5 | sim | sim | sim | 641,58 | 0 | timeout 178 |
| XVWA | modsecurity | 1 | não | não | não | 368,64 | 0 | read 320, timeout 63 |
| XVWA | dobotshield | 1 | não | não | não | 142,34 | 0 | timeout 296 |
| XVWA | coraza | 1 | não | não | não | 131,94 | 0 | timeout 465 |

## SQLMap

O SQLMap foi executado sem `--tamper`, com `--level=1`, `--risk=1`, `--batch`, `--flush-session`, `--retries=2`, `--technique=B`, `--skip-waf`, `--ignore-redirects` e `--delay=0.3`. O tamper `equaltolike` foi removido para avaliar o comportamento do WAF sem mascaramento do operador de comparação; a regra corrigida também bloqueia as variantes com `LIKE` e `~`, conforme verificado em teste ponta a ponta. O nível e o risco foram mantidos porque o objetivo era comparar o mesmo vetor booleano entre os destinos, sem ampliar desnecessariamente a duração nem introduzir payloads de maior impacto.

A injeção foi confirmada nos dois destinos diretos (`no_waf`) e não foi confirmada nos seis destinos protegidos. No DoBotShield, a regra de SQLi cobriu o vetor booleano original, incluindo as formas relevantes com `=`, `LIKE`, `~` e aspas desbalanceadas. Isso valida a cobertura do conjunto ensaiado, mas não demonstra proteção universal contra toda variante de SQLi.

## Leitura dos demais resultados

- No XVWA, ModSecurity e Coraza, ambos com CRS, deixaram passar o vetor de URL externa que o ZAP classificou como RFI (`High`); no DoBotShield, o mesmo vetor foi barrado com HTTP 400 pela regra de SSRF e o alerta RFI não apareceu no relatório do ZAP.
- O alerta ZAP 40018 não apareceu na rodada final. O alerta de Spring4Shell observado no DVWA direto foi classificado como falso positivo para a aplicação PHP.
- Códigos HTTP, erros de conexão e alertas do scanner devem ser lidos junto com os logs brutos; uma interrupção de ferramenta não é tratada como bloqueio do WAF.
- A diferença de throughput entre os cenários não deve ser atribuída somente ao WAF: cada implantação tem cadeia de proxy, limites e condições de execução próprios.
- A latência de 2.190 ms no XVWA com Coraza sugere sensibilidade ao perfil da aplicação, possivelmente porque regras do CRS são acionadas com maior frequência em suas páginas PHP; a investigação causal permanece fora do escopo.

## Tráfego legítimo e falsos positivos

Em um ensaio complementar, o DoBotShield permaneceu em `WAF_MODE=block` e recebeu 100 requisições GET legítimas por aplicação. Cada amostra percorreu 10 rotas com valores neutros, repetidas 10 vezes. No DVWA houve 20/100 bloqueios indevidos (20,0% por evento e 2/10 rotas): `/instructions.php` acionou `RESPONSE_SQL_ERROR` e `/security.php` acionou `RESPONSE_XSS_PATTERN`, sempre com HTTP 502. No XVWA, as 100 requisições retornaram HTTP 200 e nenhum bloqueio do WAF foi observado.

As repetições não constituem 100 casos independentes, por isso o resultado também é informado por rota e não deve ser extrapolado para produção. O achado mostra sensibilidade da inspeção de resposta a conteúdo didático do DVWA e fundamenta a sequência operacional Modo de Treinamento → `monitor` → revisão → `block`, com allowlist restrita à categoria e à rota quando necessária. Evidências: `validacao/results/falsos_positivos/`.

## Rastreabilidade

Os 12 grupos aplicação/ferramenta mantiveram os mesmos parâmetros e divergiram somente no destino. Os arquivos brutos, relatórios do ZAP, snapshots de saúde/recursos, logs dos WAFs e o ensaio complementar de tráfego legítimo estão em `validacao/results/`.

A entrega contém a rodada consolidada e o ensaio complementar de tráfego legítimo. Tentativas interrompidas por falha de infraestrutura não foram incorporadas aos resultados finais.
