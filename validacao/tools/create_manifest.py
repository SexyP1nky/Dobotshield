from __future__ import annotations

import hashlib
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print("uso: create_manifest.py <raiz> <manifesto>", file=sys.stderr)
        return 2
    root = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2]).resolve()
    if root not in output.parents:
        print("o manifesto deve ficar dentro da raiz", file=sys.stderr)
        return 2

    lines: list[str] = []
    for path in sorted(root.rglob("*"), key=lambda item: item.relative_to(root).as_posix().casefold()):
        if not path.is_file() or path == output or ".git" in path.parts:
            continue
        digest = hashlib.sha256()
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
        lines.append(f"{digest.hexdigest()}  {path.relative_to(root).as_posix()}")

    output.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"{output} ({len(lines)} arquivos)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
