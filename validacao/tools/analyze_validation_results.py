from __future__ import annotations

import argparse
import json
import re
import statistics
from pathlib import Path


SCENARIOS = [
    ("dvwa", "no_waf"),
    ("dvwa", "modsecurity"),
    ("dvwa", "dobotshield"),
    ("dvwa", "coraza"),
    ("xvwa", "no_waf"),
    ("xvwa", "modsecurity"),
    ("xvwa", "dobotshield"),
    ("xvwa", "coraza"),
]


def read_text(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def parse_http_counts(text: str) -> dict[str, int]:
    counts: dict[str, int] = {}
    for status, amount in re.findall(
        r"\b([1-5]\d\d)\s*\([^\r\n)]*\)\s*-\s*([\d.,]+)\s+times?",
        text,
        flags=re.IGNORECASE,
    ):
        counts[status] = counts.get(status, 0) + int(amount.replace(".", "").replace(",", ""))
    return counts


def parse_zap(folder: Path) -> dict:
    path = folder / "zap" / "zap_report.json"
    if not path.exists():
        return {"disponivel": False}
    data = json.loads(path.read_text(encoding="utf-8", errors="replace"))
    alerts = []
    for site in data.get("site", []):
        alerts.extend(site.get("alerts") or [])
    high = [alert for alert in alerts if str(alert.get("riskcode")) == "3"]
    details = []
    for alert in high:
        evidence = ""
        for instance in alert.get("instances") or []:
            evidence = (instance.get("evidence") or instance.get("otherinfo") or "").strip()
            if evidence:
                break
        details.append(
            {
                "nome": alert.get("name") or alert.get("alert") or "",
                "ocorrencias": int(alert.get("count") or len(alert.get("instances") or [])),
                "evidencia": evidence[:300],
            }
        )
    return {"disponivel": True, "high": len(high), "alertas_high": details}


def parse_sqlmap(folder: Path) -> dict:
    text = read_text(folder / "03_sqlmap.log")
    lower = text.casefold()
    vulnerable = bool(
        re.search(r"parameter\s+['\"]?\w+['\"]?\s+is vulnerable", text, re.IGNORECASE)
        or "appears to be 'and boolean-based blind" in lower
        or "appears to be \"and boolean-based blind" in lower
    )
    not_injectable = "does not seem to be injectable" in lower or "all tested parameters do not appear to be injectable" in lower
    return {
        "disponivel": bool(text),
        "vulneravel": vulnerable,
        "nao_injetavel": not_injectable,
        "http": parse_http_counts(text),
        "tool_rc": re.findall(r"TOOL_RC(?:_\w+)?=(\d+)", text),
    }


def parse_xsstrike(folder: Path) -> dict:
    text = read_text(folder / "04_xsstrike.log")
    lower = text.casefold()
    efficiencies = [int(value) for value in re.findall(r"Efficiency:\s*(\d+)", text, re.IGNORECASE)]
    return {
        "disponivel": bool(text),
        "xss_encontrado": bool(efficiencies or "vulnerable webpage" in lower or "payload:" in lower),
        "sem_xss": "no xss found" in lower,
        "payloads_com_eficiencia": len(efficiencies),
        "eficiencia_min": min(efficiencies) if efficiencies else None,
        "eficiencia_max": max(efficiencies) if efficiencies else None,
    }


def parse_commix(folder: Path) -> dict:
    text = read_text(folder / "05_commix.log")
    lower = text.casefold()
    vulnerable = "is likely vulnerable" in lower or "is vulnerable" in lower
    codes = [int(code) for code in re.findall(r"\b(?:http error code|status code)\D{0,20}([1-5]\d\d)\b", text, re.IGNORECASE)]
    return {
        "disponivel": bool(text),
        "vulneravel": vulnerable,
        "codigos_http": sorted(set(codes)),
    }


def latency_ms(value: float, unit: str) -> float:
    unit = unit.casefold()
    if unit == "us":
        return value / 1000
    if unit == "s":
        return value * 1000
    return value


def parse_wrk(folder: Path) -> dict:
    text = read_text(folder / "06_wrk.log")
    runs = []
    parts = re.split(r"=== REPETICAO \d+/\d+ ===", text, flags=re.IGNORECASE)[1:]
    for part in parts:
        req_sec = re.search(r"Requests/sec:\s*([\d.]+)", part, re.IGNORECASE)
        total = re.search(r"([\d]+)\s+requests in\s+[\d.]+s", part, re.IGNORECASE)
        non_2xx = re.search(r"Non-2xx or 3xx responses:\s*([\d]+)", part, re.IGNORECASE)
        latency = re.search(r"^\s*Latency\s+([\d.]+)(us|ms|s)\b", part, re.IGNORECASE | re.MULTILINE)
        sockets = re.search(
            r"Socket errors:\s*connect\s+(\d+),\s*read\s+(\d+),\s*write\s+(\d+),\s*timeout\s+(\d+)",
            part,
            re.IGNORECASE,
        )
        if not req_sec:
            continue
        runs.append(
            {
                "req_s": float(req_sec.group(1)),
                "total": int(total.group(1)) if total else 0,
                "non_2xx_3xx": int(non_2xx.group(1)) if non_2xx else 0,
                "latencia_ms": latency_ms(float(latency.group(1)), latency.group(2)) if latency else None,
                "socket_connect": int(sockets.group(1)) if sockets else 0,
                "socket_read": int(sockets.group(2)) if sockets else 0,
                "socket_write": int(sockets.group(3)) if sockets else 0,
                "timeout": int(sockets.group(4)) if sockets else 0,
            }
        )
    numeric = lambda key: [run[key] for run in runs if run.get(key) is not None]
    means = {
        key: statistics.fmean(numeric(key)) if numeric(key) else None
        for key in ("req_s", "total", "non_2xx_3xx", "latencia_ms", "socket_connect", "socket_read", "socket_write", "timeout")
    }
    return {"disponivel": bool(text), "repeticoes": runs, "media": means}


def parse_testssl(folder: Path) -> dict:
    text = read_text(folder / "01_testssl.log")
    def protocol_offered(version: str) -> bool:
        match = re.search(rf"^\s*TLS\s*{re.escape(version)}\s+(.+)$", text, re.IGNORECASE | re.MULTILINE)
        return bool(match and "not offered" not in match.group(1).casefold())

    return {
        "disponivel": bool(text),
        "tls_1_2": protocol_offered("1.2"),
        "tls_1_3": protocol_offered("1.3"),
        "sem_tls": bool(re.search(r"^\s*TLS\s+(?:1|1\.1|1\.2|1\.3)\s+not offered\s*$", text, re.IGNORECASE | re.MULTILINE))
        and not protocol_offered("1.2")
        and not protocol_offered("1.3"),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("results", type=Path)
    parser.add_argument("--json-out", type=Path)
    parser.add_argument("--txt-out", type=Path)
    args = parser.parse_args()

    result = {"cenarios": {}}
    lines = ["RESUMO MECÂNICO DOS RESULTADOS", ""]
    for app, scenario in SCENARIOS:
        folder = args.results / app / scenario
        parsed = {
            "testssl": parse_testssl(folder),
            "zap": parse_zap(folder),
            "sqlmap": parse_sqlmap(folder),
            "xsstrike": parse_xsstrike(folder),
            "commix": parse_commix(folder),
            "wrk": parse_wrk(folder),
        }
        result["cenarios"][f"{app}/{scenario}"] = parsed
        lines.append(
            f"{app}/{scenario}: ZAP HIGH={parsed['zap'].get('high', 'n/d')}; "
            f"SQLMap vulnerável={parsed['sqlmap']['vulneravel']}; "
            f"XSStrike encontrou XSS={parsed['xsstrike']['xss_encontrado']}; "
            f"Commix vulnerável={parsed['commix']['vulneravel']}; "
            f"wrk repetições={len(parsed['wrk']['repeticoes'])}"
        )

    json_out = args.json_out or args.results / "ANALISE_RESULTADOS.json"
    txt_out = args.txt_out or args.results / "RESUMO_RESULTADOS.txt"
    json_out.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    txt_out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json_out)
    print(txt_out)


if __name__ == "__main__":
    main()
