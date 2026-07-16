from __future__ import annotations

import html
import json
import re
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print("uso: audit_training_report.py <training.jsonl> <report.html>", file=sys.stderr)
        return 2
    log_path = Path(sys.argv[1])
    report_path = Path(sys.argv[2])

    events = []
    for line_number, line in enumerate(log_path.read_text(encoding="utf-8").splitlines(), start=1):
        if not line.strip():
            continue
        try:
            events.append(json.loads(line))
        except json.JSONDecodeError as exc:
            print(f"JSON invalido na linha {line_number}: {exc}", file=sys.stderr)
            return 1

    source = report_path.read_text(encoding="utf-8")
    cards = {
        html.unescape(label.strip()): int(value)
        for label, value in re.findall(
            r'<div class="card[^"]*"><div class="label">([^<]+)</div><div class="value">(\d+)</div></div>',
            source,
        )
    }
    expected = {
        "Total de eventos": len(events),
        "Bloqueados": sum(event.get("action") == "blocked" for event in events),
        "Apenas detectados": sum(event.get("action") == "detected" for event in events),
        "Em requisicoes": sum(event.get("phase") == "request" for event in events),
        "Em respostas": sum(event.get("phase") == "response" for event in events),
        "IPs distintos": len({event.get("ip") for event in events if event.get("ip")}),
        "Regras acionadas": len({event.get("rule") for event in events if event.get("rule")}),
    }
    errors = []
    for label, value in expected.items():
        if cards.get(label) != value:
            errors.append(f"cartao {label!r}: esperado {value}, encontrado {cards.get(label)}")

    timeline_count = len(re.findall(r'<article class="event\s', source))
    if timeline_count != len(events):
        errors.append(f"linha do tempo: esperado {len(events)}, encontrado {timeline_count}")
    if not re.search(r"<style>.{1000,}</style>", source, re.DOTALL):
        errors.append("CSS embutido ausente ou incompleto")
    if re.search(r'<link[^>]+rel=["\']stylesheet', source, re.IGNORECASE):
        errors.append("relatorio depende de stylesheet externo")

    for event in events:
        category = str(event.get("category") or "")
        if category and html.escape(category) not in source:
            errors.append(f"categoria ausente no HTML: {category}")
        payload = str(event.get("payload") or "")
        if "<script" in payload.casefold() and re.search(r"<script\b", source, re.IGNORECASE):
            errors.append("payload script apareceu como tag executavel")

    if errors:
        print(f"RELATORIO: FALHOU ({len(errors)} problema(s))")
        for error in errors:
            print(f"- {error}")
        return 1

    print(
        "RELATORIO: OK "
        f"({len(events)} eventos; {expected['Bloqueados']} bloqueados; "
        f"{expected['Apenas detectados']} detectados; {timeline_count} itens na linha do tempo)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
