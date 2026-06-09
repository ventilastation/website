#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSDK_DIR="${1:-"$ROOT_DIR/vsdk"}"
OUT_DIR="${2:-"$ROOT_DIR/emulator"}"
PORT="${PORT:-8000}"
HOST="${HOST:-127.0.0.1}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<EOF
Usage: $(basename "$0") [vsdk_dir] [emulator_out_dir]

Performs a full local emulator deploy:
  1. clean the published emulator directory, keeping README.md
  2. refresh the source runtime bundle in vsdk/web
  3. publish vsdk/web + vsdk/apps into emulator/
  4. start a fresh local HTTP server

Environment variables:
  PORT   Server port (default: 8000)
  HOST   Server bind host (default: 127.0.0.1)
EOF
  exit 0
fi

if [[ ! -d "$VSDK_DIR/web" || ! -d "$VSDK_DIR/apps" ]]; then
  echo "Expected a vsdk checkout at $VSDK_DIR" >&2
  exit 1
fi

if [[ ! -d "$OUT_DIR" ]]; then
  mkdir -p "$OUT_DIR"
fi

echo "[1/4] Cleaning $OUT_DIR"
find "$OUT_DIR" -mindepth 1 ! -name README.md -exec rm -rf {} +

echo "[2/4] Refreshing runtime bundle in $VSDK_DIR/web"
python3 "$ROOT_DIR/tools/refresh-emulator-runtime-bundle.py" "$VSDK_DIR/web"

echo "[3/4] Publishing into $OUT_DIR"
"$ROOT_DIR/tools/update-emulator-from-vsdk.sh" "$VSDK_DIR" "$OUT_DIR"

echo "[4/4] Starting fresh server on http://$HOST:$PORT/"
existing_pid="$(lsof -tiTCP:"$PORT" -sTCP:LISTEN || true)"
if [[ -n "$existing_pid" ]]; then
  kill $existing_pid
fi

cd "$OUT_DIR"
exec python3 -m http.server "$PORT" --bind "$HOST"
