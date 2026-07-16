#!/usr/bin/env python3
"""Audita se cada ferramenta recebe a mesma entrada nos quatro cenarios."""

from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path


LAB_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = LAB_ROOT / "scripts"
REPO_ROOT = LAB_ROOT.parent
TOKEN_RE = re.compile(r'"[^"\r\n]*"|\S+')
ORIGIN_RE = re.compile(r"https?://![A-Z0-9_]+!:[0-9]+", re.IGNORECASE)
CALL_RE = re.compile(
    r'^call\s+"%ROOT%\\(?P<runner>lab_0[2-7]_[^"\\]+_one\.bat)"\s+'
    r'(?P<app>dvwa|xvwa)\s+(?P<scenario>no_waf|modsecurity|dobotshield|coraza)\s+',
    re.IGNORECASE,
)
WAF_TOKEN_INDEX = {
    "lab_02_testssl_one.bat": 6,
    "lab_03_zap_one.bat": 6,
    "lab_04_sqlmap_one.bat": 9,
    "lab_05_xsstrike_one.bat": 6,
    "lab_06_commix_one.bat": 6,
    "lab_07_wrk_one.bat": 6,
}


def fail(message: str) -> None:
    print(f"FALHA: {message}")
    raise SystemExit(1)


def normalize_call(line: str, runner: str) -> str:
    tokens = TOKEN_RE.findall(line.strip())
    if len(tokens) <= WAF_TOKEN_INDEX[runner]:
        fail(f"chamada incompleta em {runner}: {line.strip()}")
    tokens[3] = "<SCENARIO>"
    tokens[WAF_TOKEN_INDEX[runner]] = "<WAF_LOG_TARGET>"
    return " ".join(ORIGIN_RE.sub("<DESTINATION>", token) for token in tokens)


def audit_driver_calls() -> int:
    groups: dict[tuple[str, str], list[tuple[str, str]]] = defaultdict(list)
    for driver in sorted(SCRIPTS.glob("lab_0[2-7]_*.bat")):
        if driver.name.endswith("_one.bat"):
            continue
        for line in driver.read_text(encoding="utf-8-sig").splitlines():
            match = CALL_RE.match(line.strip())
            if not match:
                continue
            runner = match.group("runner").lower()
            app = match.group("app").lower()
            groups[(runner, app)].append(
                (match.group("scenario").lower(), normalize_call(line, runner))
            )

    expected_groups = {(runner, app) for runner in WAF_TOKEN_INDEX for app in ("dvwa", "xvwa")}
    if set(groups) != expected_groups:
        fail(f"grupos de chamadas inesperados: {sorted(set(groups) ^ expected_groups)}")

    for (runner, app), calls in sorted(groups.items()):
        scenarios = [scenario for scenario, _ in calls]
        if scenarios != ["no_waf", "modsecurity", "dobotshield", "coraza"]:
            fail(f"ordem/cobertura incorreta em {runner}/{app}: {scenarios}")
        normalized = {call for _, call in calls}
        if len(normalized) != 1:
            fail(f"entradas diferentes alem do destino em {runner}/{app}: {sorted(normalized)}")

    return len(groups) * 4


def audit_determinism() -> None:
    scripts_text = "\n".join(
        path.read_text(encoding="utf-8-sig") for path in sorted(SCRIPTS.glob("*.bat"))
    )
    if "--random-agent" in scripts_text:
        fail("--random-agent ainda esta presente")

    required_agents = {
        "lab_03_zap_one.bat": "defaultUserAgent=DoBotShield-TCC-Validation/1.0",
        "lab_04_sqlmap_one.bat": '--user-agent="%LAB_USER_AGENT%"',
        "lab_05_xsstrike_one.bat": "User-Agent: %LAB_USER_AGENT%",
        "lab_06_commix_one.bat": '--user-agent="%LAB_USER_AGENT%"',
        "lab_07_wrk_one.bat": "User-Agent: %LAB_USER_AGENT%",
    }
    for filename, marker in required_agents.items():
        text = (SCRIPTS / filename).read_text(encoding="utf-8-sig")
        if marker not in text:
            fail(f"User-Agent fixo ausente em {filename}")

    wrk = (SCRIPTS / "lab_07_wrk_one.bat").read_text(encoding="utf-8-sig")
    match = re.search(r'set "WRK_REPETITIONS=([0-9]+)"', wrk)
    if not match or int(match.group(1)) < 3:
        fail("wrk deve executar pelo menos tres repeticoes")


def audit_pins() -> None:
    compose = (LAB_ROOT / "docker-compose.lab.yml").read_text(encoding="utf-8")
    for image in ("vulnerables/web-dvwa", "mysql:5.7", "owasp/modsecurity-crs:nginx"):
        line = next((line for line in compose.splitlines() if image in line), "")
        if "@sha256:" not in line:
            fail(f"imagem sem digest no compose: {image}")

    for dockerfile in [REPO_ROOT / "Dockerfile", *sorted((LAB_ROOT / "docker").glob("*/Dockerfile"))]:
        text = dockerfile.read_text(encoding="utf-8")
        for line in text.splitlines():
            if line.startswith("FROM ") and "@sha256:" not in line:
                fail(f"FROM sem digest em {dockerfile.relative_to(REPO_ROOT)}: {line}")

    for dockerfile in sorted((LAB_ROOT / "docker").glob("*/Dockerfile")):
        text = dockerfile.read_text(encoding="utf-8")
        for line in text.splitlines():
            if line.startswith("ARG ") and line.endswith("COMMIT"):
                fail(f"commit sem valor em {dockerfile.relative_to(REPO_ROOT)}")
        for value in re.findall(r"ARG\s+[A-Z_]+_COMMIT=([0-9a-f]+)", text):
            if len(value) != 40:
                fail(f"commit nao fixado em {dockerfile.relative_to(REPO_ROOT)}: {value}")


def main() -> int:
    call_count = audit_driver_calls()
    audit_determinism()
    audit_pins()
    print(f"PARIDADE OK: {call_count} chamadas comparativas; somente o destino varia por app/ferramenta.")
    print("DETERMINISMO OK: User-Agent fixo, sem --random-agent, wrk com 3 repeticoes.")
    print("VERSOES OK: imagens por digest e fontes externas por commit/tag fixo.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
