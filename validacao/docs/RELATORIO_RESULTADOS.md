# Relatório da rodada completa de validação

Período consolidado: 17 e 18 de julho de 2026.

A matriz contém 48 combinações comparativas: duas aplicações, quatro cenários e seis ferramentas. Para cada ferramenta, os parâmetros foram mantidos e somente o destino mudou. O `wrk` teve três repetições por cenário. Nenhuma regra dos WAFs foi ajustada em função do resultado.

A regra ativa 40026 (DOM XSS) do ZAP foi ignorada uniformemente nos oito destinos porque encerrava o processo Java do scanner nesta bancada; XSS refletido permaneceu coberto pelo ZAP e pelo XSStrike.

## Resultados por cenário

| Aplicação | Cenário | ZAP HIGH | SQLMap confirmou SQLi | XSStrike encontrou XSS | Commix confirmou OSCI | wrk req/s média | wrk não 2xx/3xx | Erros socket/timeout |
|---|---|---:|---|---|---|---:|---:|---|
| DVWA | no_waf | 1 | sim | sim | sim | 5.692,02 | 0 | timeout 338 |
| DVWA | modsecurity | 2 | não | não | não | 1.426,61 | 0 | 0 |
| DVWA | dobotshield | 1 | não | não | não | 1.894,84 | 990 | timeout 3 |
| DVWA | coraza | 0 | não | não | não | 1.999,55 | 0 | timeout 695 |
| XVWA | no_waf | 5 | sim | sim | sim | 490,54 | 0 | timeout 124 |
| XVWA | modsecurity | 1 | não | não | não | 328,49 | 0 | read 107, timeout 45 |
| XVWA | dobotshield | 1 | não | não | não | 144,07 | 0 | timeout 461 |
| XVWA | coraza | 1 | não | não | não | 130,61 | 0 | timeout 269 |

## SQLMap

O SQLMap foi executado sem `--tamper`, com `--level=1`, `--risk=1`, `--batch`, `--flush-session`, `--threads=2`, `--timeout=10` e `--retries=1`. O nível e o risco foram mantidos porque o objetivo era comparar o mesmo vetor booleano entre os destinos, sem ampliar desnecessariamente a duração nem introduzir payloads de maior impacto.

A injeção foi confirmada nos dois destinos diretos (`no_waf`) e não foi confirmada nos seis destinos protegidos. No DoBotShield, a regra de SQLi cobriu o vetor booleano original, incluindo as formas relevantes com `=`, `LIKE`, `~` e aspas desbalanceadas. Isso valida a cobertura do conjunto ensaiado, mas não demonstra proteção universal contra toda variante de SQLi.

## Leitura dos demais resultados

- O alerta ZAP 40018 não apareceu na rodada final. O alerta de Spring4Shell observado no DVWA direto foi classificado como falso positivo para a aplicação PHP.
- Códigos HTTP, erros de conexão e alertas do scanner devem ser lidos junto com os logs brutos; uma interrupção de ferramenta não é tratada como bloqueio do WAF.
- A diferença de throughput entre os cenários não deve ser atribuída somente ao WAF: cada implantação tem cadeia de proxy, limites e condições de execução próprios.

## Rastreabilidade

Os 12 grupos aplicação/ferramenta mantiveram os mesmos parâmetros e divergiram somente no destino. Os arquivos brutos, relatórios do ZAP, snapshots de saúde/recursos e logs dos WAFs estão em `validacao/results/`.

A entrega contém apenas a rodada consolidada. Tentativas interrompidas por falha de infraestrutura não foram incorporadas aos resultados finais.
