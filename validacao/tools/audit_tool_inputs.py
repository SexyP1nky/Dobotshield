from __future__ import annotations

import json
import re
import sys
from pathlib import Path


SCENARIOS = ("no_waf", "modsecurity", "dobotshield", "coraza")
TOOLS = {
    "testssl": "01_testssl.log",
    "zap": "02_zap.log",
    "sqlmap": "03_sqlmap.log",
    "xsstrike": "04_xsstrike.log",
    "commix": "05_commix.log",
    "wrk": "06_wrk.log",
}


def normalize(command: str) -> str:
    command = re.sub(r"https?://[^\s\"']+", "<URL>", command)
    command = re.sub(r"\b(?:\d{1,3}\.){3}\d{1,3}:\d+\b", "<TARGET>", command)
    command = re.sub(r"PHPSESSID=[^;\s\"']+", "PHPSESSID=<COOKIE>", command)
    command = re.sub(r"\s+", " ", command).strip()
    return command


def commands(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8", errors="replace")
    return [normalize(match.group(1)) for match in re.finditer(r"^CMD:\s*(.+)$", text, re.MULTILINE)]


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: audit_tool_inputs.py <validacao/results>", file=sys.stderr)
        return 2
    root = Path(sys.argv[1]).resolve()
    errors = []
    evidence: dict[str, dict[str, list[str]]] = {}

    for app in ("dvwa", "xvwa"):
        for tool, filename in TOOLS.items():
            key = f"{app}/{tool}"
            evidence[key] = {}
            expected_count = 2 if app == "dvwa" and tool == "sqlmap" else 1
            baseline = None
            for scenario in SCENARIOS:
                path = root / app / scenario / filename
                values = commands(path) if path.is_file() else []
                evidence[key][scenario] = values
                if len(values) != expected_count:
                    errors.append(f"{app}/{scenario}/{tool}: esperado {expected_count} CMD, encontrado {len(values)}")
                if baseline is None:
                    baseline = values
                elif values != baseline:
                    errors.append(f"{app}/{tool}: parametros diferem entre no_waf e {scenario}")

    out = root / "AUDITORIA_INPUTS.json"
    out.write_text(json.dumps(evidence, ensure_ascii=False, indent=2), encoding="utf-8")
    if errors:
        print(f"INPUTS: FALHOU ({len(errors)} problema(s))")
        for error in errors:
            print(f"- {error}")
        return 1
    print("INPUTS: OK (12 grupos app/ferramenta; somente o destino varia entre cenarios)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
