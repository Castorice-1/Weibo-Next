#!/usr/bin/env bash
# Build WeiboPura with a HarmonyOS Command Line Tools installation.
#
# Usage:
#   bash scripts/ci/build-hap.sh [debug|release] [product]
#
# Environment:
#   STRIP_SIGNING=1   remove local signing config before building (for CI;
#                     default is 1 so a machine-local path cannot break the run)
#   STRIP_SIGNING=0   keep build-profile.json5 as-is (for local signed builds)
#
# The script expects `ohpm` and `hvigorw` to be in PATH.  See
# docs/online-build.md for the GitHub Actions setup that supplies them.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

BUILD_MODE="${1:-debug}"
PRODUCT="${2:-default}"
STRIP_SIGNING="${STRIP_SIGNING:-1}"

PYTHON="${PYTHON:-}"
if [ -z "$PYTHON" ]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
  elif command -v python >/dev/null 2>&1; then
    PYTHON=python
  else
    echo "error: neither python3 nor python was found in PATH" >&2
    exit 127
  fi
fi

case "$BUILD_MODE" in
  debug|release) ;;
  *)
    echo "error: build mode must be 'debug' or 'release', got '$BUILD_MODE'" >&2
    exit 2
    ;;
esac

for tool in ohpm hvigorw; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "error: '$tool' not found in PATH" >&2
    echo "hint: source the Command Line Tools environment first, or use the GitHub Actions workflow" >&2
    exit 127
  fi
done

if [ "$STRIP_SIGNING" = "1" ]; then
  "$PYTHON" scripts/ci/strip-signing.py build-profile.json5
fi

echo "== ohpm =="
ohpm --version
echo "== hvigor =="
hvigorw --version || echo "warning: unable to read hvigor version"

echo "== install dependencies =="
ohpm install --all

echo "== clean =="
hvigorw clean --no-daemon

echo "== build ($BUILD_MODE / $PRODUCT) =="
hvigorw assembleHap \
  --mode module \
  -p "product=$PRODUCT" \
  -p "buildMode=$BUILD_MODE" \
  --no-daemon

echo "== output =="
find entry/build -type f \( -name '*.hap' -o -name '*.app' \) -print 2>/dev/null || true
