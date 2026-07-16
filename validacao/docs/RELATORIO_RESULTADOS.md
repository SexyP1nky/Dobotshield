# Relatório da rodada completa de validação

Data da rodada: 14 de julho de 2026.

A matriz comparativa contém 48 execuções: duas aplicações, quatro cenários e seis ferramentas. Para cada ferramenta, os parâmetros foram mantidos e somente o destino mudou. Nenhuma regra dos WAFs foi ajustada em função do resultado. A regra ativa 40026 (DOM XSS) do ZAP foi ignorada de modo uniforme nos oito destinos porque encerrava o processo Java do scanner nesta bancada; XSS refletido permaneceu coberto pelo ZAP e pelo XSStrike.

## Resultados por cenário

| Aplicação | Cenário | ZAP HIGH | SQLMap confirmou SQLi | XSStrike encontrou XSS | Commix confirmou OSCI | wrk req/s média | wrk não 2xx/3xx | Erros socket/timeout |
|---|---|---:|---|---|---|---:|---:|---:|
| DVWA | no_waf | 6 | sim | sim | sim | 6.335,85 | 0 | 572 |
| DVWA | modsecurity | 1 | não | não | não | 1.538,21 | 0 | 0 |
| DVWA | dobotshield | 1 | sim | não | não | 54.766,95 | 1.647.255 | 8 |
| DVWA | coraza | 0 | não | não | não | 2.094,63 | 0 | 76 |
| XVWA | no_waf | 5 | sim | sim | sim | 692,97 | 0 | 212 |
| XVWA | modsecurity | 1 | não | não | não | 412,36 | 0 | 48 |
| XVWA | dobotshield | 2 | sim | não | não | 50.707,19 | 1.525.223 | 18 |
| XVWA | coraza | 1 | não | não | não | 123,27 | 0 | 612 |

## Leitura cautelosa

A confirmação de SQLi booleana pelo SQLMap através do DoBotShield é mantida como limitação real. Códigos HTTP, erros de conexão e alertas do scanner devem ser lidos junto com os logs brutos; uma interrupção de ferramenta não é tratada como bloqueio do WAF.

Os arquivos brutos, relatórios do ZAP, snapshots de saúde/recursos e logs dos WAFs estão em `validacao/results/`. A entrega contém apenas a rodada consolidada; tentativas interrompidas por falha de infraestrutura não foram incluídas.
