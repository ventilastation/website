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
  1. regenerate ROMs if source images changed
  2. refresh the source runtime bundle in vsdk/web
  3. publish vsdk/web + vsdk/apps into emulator/
  4. restart the local HTTP server

Environment variables:
  PORT   Server port (default: 8000)
  HOST   Server bind host (default: 127.0.0.1)
EOF
  exit 0
fi

exec make -C "$ROOT_DIR" start \
  VSDK_DIR="$VSDK_DIR" \
  OUT_DIR="$OUT_DIR" \
  HOST="$HOST" \
  PORT="$PORT"
