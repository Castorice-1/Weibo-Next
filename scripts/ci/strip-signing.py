#!/usr/bin/env python3
"""Remove machine-local signing material from build-profile.json5.

DevEco Studio's "automatic signing" writes absolute Windows/macOS paths and
encrypted passwords into build-profile.json5.  Those paths do not exist on a
GitHub Actions runner, so hvigor fails before it even starts compiling.

This script keeps every product/SDK setting and only clears:

    app.signingConfigs
    app.products[*].signingConfig

The result is an unsigned build.  Sign the HAP afterwards with DevEco Studio or
hap-sign-tool.jar if you need an installable package.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "build-profile.json5")
    if not path.is_file():
        print(f"error: {path} not found", file=sys.stderr)
        return 1

    text = path.read_text(encoding="utf-8")
    try:
        data = json.loads(text)
    except json.JSONDecodeError as exc:
        print(
            f"error: {path} is not plain JSON ({exc}); "
            "remove comments/trailing commas or strip signing manually",
            file=sys.stderr,
        )
        return 2

    app = data.setdefault("app", {})
    removed = len(app.get("signingConfigs") or [])
    app["signingConfigs"] = []

    for product in app.get("products") or []:
        product.pop("signingConfig", None)

    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"stripped {removed} signing config(s): {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
