#!/usr/bin/env python3
import json
import ssl
import sys
import time
import urllib.error
import urllib.parse
import urllib.request


def request_case(case, timeout=10):
    data = None
    if case.get("data") is not None:
        data = urllib.parse.urlencode(case["data"]).encode("utf-8")

    req = urllib.request.Request(
        case["url"],
        data=data,
        method=case.get("method", "GET"),
        headers={"User-Agent": "DoBotShield-manual-regression/1.0"},
    )
    context = ssl._create_unverified_context()
    started = time.monotonic()
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=context) as response:
            status = response.status
            headers = response.headers
            body = response.read(512).decode("utf-8", "replace")
    except urllib.error.HTTPError as exc:
        status = exc.code
        headers = exc.headers
        body = exc.read(512).decode("utf-8", "replace")
    except Exception as exc:
        return {
            **case,
            "passed": False,
            "error": str(exc),
            "elapsed_seconds": round(time.monotonic() - started, 3),
        }

    elapsed = round(time.monotonic() - started, 3)
    action = headers.get("X-DoBotShield-Action", "")
    if case["kind"] == "attack":
        passed = status == 400 and action == "Blocked-WAF"
        expectation = "HTTP 400 and X-DoBotShield-Action=Blocked-WAF"
    else:
        passed = action != "Blocked-WAF"
        expectation = "request must not be blocked by the WAF"

    return {
        **case,
        "status": status,
        "action": action,
        "elapsed_seconds": elapsed,
        "response_excerpt": body.replace("\r", " ").replace("\n", " ")[:240],
        "expectation": expectation,
        "passed": passed,
    }


def main():
    if len(sys.argv) != 3:
        print("usage: manual_regression.py <dobot_dvwa_ip> <dobot_xvwa_ip>", file=sys.stderr)
        return 2

    dvwa_ip, xvwa_ip = sys.argv[1:3]
    dvwa = f"https://{dvwa_ip}:443"
    xvwa = f"https://{xvwa_ip}:443/xvwa"

    cases = [
        {
            "id": "dvwa_echo",
            "kind": "attack",
            "method": "POST",
            "url": f"{dvwa}/vulnerabilities/exec/",
            "data": {"ip": "127.0.0.1;echo DOBOT_CMDI_TEST", "Submit": "Submit"},
        },
        {
            "id": "dvwa_sleep",
            "kind": "attack",
            "method": "POST",
            "url": f"{dvwa}/vulnerabilities/exec/",
            "data": {"ip": "127.0.0.1;sleep 2", "Submit": "Submit"},
        },
        {
            "id": "xvwa_echo",
            "kind": "attack",
            "method": "GET",
            "url": f"{xvwa}/vulnerabilities/cmdi/?"
            + urllib.parse.urlencode({"target": "127.0.0.1;echo DOBOT_CMDI_TEST"}),
        },
        {
            "id": "xvwa_sleep",
            "kind": "attack",
            "method": "GET",
            "url": f"{xvwa}/vulnerabilities/cmdi/?"
            + urllib.parse.urlencode({"target": "127.0.0.1;sleep 2"}),
        },
        {"id": "dvwa_home", "kind": "benign", "method": "GET", "url": f"{dvwa}/"},
        {"id": "dvwa_login", "kind": "benign", "method": "GET", "url": f"{dvwa}/login.php"},
        {
            "id": "dvwa_benign_query",
            "kind": "benign",
            "method": "GET",
            "url": f"{dvwa}/?page=2&order=price",
        },
        {"id": "xvwa_home", "kind": "benign", "method": "GET", "url": f"{xvwa}/"},
        {
            "id": "xvwa_benign_search",
            "kind": "benign",
            "method": "GET",
            "url": f"{xvwa}/?q=wireless+keyboard",
        },
        {
            "id": "xvwa_benign_pagination",
            "kind": "benign",
            "method": "GET",
            "url": f"{xvwa}/?page=2&order=price",
        },
    ]

    results = []
    for case in cases:
        results.append(request_case(case))
        time.sleep(0.2)

    attacks = [item for item in results if item["kind"] == "attack"]
    benign = [item for item in results if item["kind"] == "benign"]
    report = {
        "scope": "targeted manual regression; not a population-wide false-positive estimate",
        "attack_cases": len(attacks),
        "attacks_blocked_as_expected": sum(item["passed"] for item in attacks),
        "benign_cases": len(benign),
        "benign_false_positives": sum(not item["passed"] for item in benign),
        "all_passed": all(item["passed"] for item in results),
        "results": results,
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report["all_passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
