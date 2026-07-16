from __future__ import annotations

import json
import sys
from pathlib import Path


ORDER = [
    (app, scenario)
    for app in ("dvwa", "xvwa")
    for scenario in ("no_waf", "modsecurity", "dobotshield", "coraza")
]


def yes_no(value: bool) -> str:
    return "sim" if value else "não"


def number(value: float | int | None, decimals: int = 2) -> str:
    if value is None:
        return "n/d"
    return f"{value:,.{decimals}f}".replace(",", "X").replace(".", ",").replace("X", ".")


def main() -> int:
    if len(sys.argv) != 3:
        print("uso: generate_validation_report.py <analise.json> <saida.md>", file=sys.stderr)
        return 2
    analysis = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    output = Path(sys.argv[2])

    lines = [
        "# Relatório da rodada completa de validação",
        "",
        "Data da rodada: 14 de julho de 2026.",
        "",
        "A matriz comparativa contém 48 execuções: duas aplicações, quatro cenários e seis ferramentas. "
        "Para cada ferramenta, os parâmetros foram mantidos e somente o destino mudou. Nenhuma regra dos WAFs "
        "foi ajustada em função do resultado. A regra ativa 40026 (DOM XSS) do ZAP foi ignorada de modo uniforme "
        "nos oito destinos porque encerrava o processo Java do scanner nesta bancada; XSS refletido permaneceu "
        "coberto pelo ZAP e pelo XSStrike.",
        "",
        "## Resultados por cenário",
        "",
        "| Aplicação | Cenário | ZAP HIGH | SQLMap confirmou SQLi | XSStrike encontrou XSS | Commix confirmou OSCI | wrk req/s média | wrk não 2xx/3xx | Erros socket/timeout |",
        "|---|---|---:|---|---|---|---:|---:|---:|",
    ]

    for app, scenario in ORDER:
        item = analysis["cenarios"][f"{app}/{scenario}"]
        wrk = item["wrk"].get("media", {})
        errors = sum(
            round(wrk.get(key) or 0)
            for key in ("socket_connect", "socket_read", "socket_write", "timeout")
        )
        lines.append(
            f"| {app.upper()} | {scenario} | {item['zap'].get('high', 0)} | "
            f"{yes_no(item['sqlmap'].get('vulneravel', False))} | "
            f"{yes_no(item['xsstrike'].get('xss_encontrado', False))} | "
            f"{yes_no(item['commix'].get('vulneravel', False))} | "
            f"{number(wrk.get('req_s'))} | {number(wrk.get('non_2xx_3xx'), 0)} | {number(errors, 0)} |"
        )

    lines.extend(
        [
            "",
            "## Leitura cautelosa",
            "",
            "A confirmação de SQLi booleana pelo SQLMap através do DoBotShield é mantida como limitação real. "
            "Códigos HTTP, erros de conexão e alertas do scanner devem ser lidos junto com os logs brutos; "
            "uma interrupção de ferramenta não é tratada como bloqueio do WAF.",
            "",
            "Os arquivos brutos, relatórios do ZAP, snapshots de saúde/recursos e logs dos WAFs estão em "
            "`validacao/results/`. A entrega contém apenas a rodada consolidada; tentativas interrompidas "
            "por falha de infraestrutura não foram incluídas.",
            "",
        ]
    )
    output.write_text("\n".join(lines), encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
