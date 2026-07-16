from __future__ import annotations

import json
import re
import sys
from pathlib import Path


SCENARIOS = [
    (app, scenario)
    for app in ("dvwa", "xvwa")
    for scenario in ("no_waf", "modsecurity", "dobotshield", "coraza")
]

TOOLS = {
    "testssl": "01_testssl.log",
    "zap": "02_zap.log",
    "sqlmap": "03_sqlmap.log",
    "xsstrike": "04_xsstrike.log",
    "commix": "05_commix.log",
    "wrk": "06_wrk.log",
}


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: audit_validation.py <validacao/results>", file=sys.stderr)
        return 2

    root = Path(sys.argv[1]).resolve()
    errors: list[str] = []
    checked = 0

    for app, scenario in SCENARIOS:
        folder = root / app / scenario
        for tool, filename in TOOLS.items():
            path = folder / filename
            checked += 1
            if not path.is_file() or path.stat().st_size == 0:
                fail(errors, f"ausente/vazio: {path.relative_to(root)}")
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            codes = [int(value) for value in re.findall(r"TOOL_RC(?:_\d+)?=(\d+)", text)]
            if not codes:
                fail(errors, f"sem TOOL_RC: {path.relative_to(root)}")
            elif tool == "testssl" and scenario == "no_waf":
                if codes != [10]:
                    fail(errors, f"testssl HTTP deveria registrar RC=10, encontrado {codes}: {path.relative_to(root)}")
            elif any(code != 0 for code in codes):
                fail(errors, f"TOOL_RC nao zero {codes}: {path.relative_to(root)}")

            if tool == "wrk" and len(re.findall(r"^=== REPETICAO \d+/3 ===$", text, re.MULTILINE)) != 3:
                fail(errors, f"wrk sem exatamente 3 repeticoes: {path.relative_to(root)}")

        zap_json = folder / "zap" / "zap_report.json"
        if not zap_json.is_file() or zap_json.stat().st_size == 0:
            fail(errors, f"relatorio ZAP ausente: {zap_json.relative_to(root)}")
        else:
            try:
                json.loads(zap_json.read_text(encoding="utf-8", errors="replace"))
            except json.JSONDecodeError as exc:
                fail(errors, f"JSON ZAP invalido: {zap_json.relative_to(root)} ({exc})")

    go_log = root / "00_go_test.log"
    if not go_log.is_file() or "FAIL" in go_log.read_text(encoding="utf-8", errors="replace"):
        fail(errors, "go test ausente ou com FAIL")

    if errors:
        print(f"AUDITORIA: FALHOU ({len(errors)} problema(s), {checked} logs verificados)")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"AUDITORIA: OK ({checked}/48 logs, 8 JSONs ZAP e go test)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
