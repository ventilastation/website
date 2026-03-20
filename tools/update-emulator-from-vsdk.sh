#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSDK_DIR="${1:-"$ROOT_DIR/vsdk"}"
OUT_DIR="${2:-"$ROOT_DIR/emulator"}"

if [[ ! -d "$VSDK_DIR/web" || ! -d "$VSDK_DIR/apps" ]]; then
  echo "Expected a vsdk checkout at $VSDK_DIR" >&2
  exit 1
fi

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cp -R "$VSDK_DIR/web/." "$OUT_DIR/"
rm -f "$OUT_DIR/apps"
cp -R "$VSDK_DIR/apps" "$OUT_DIR/apps"

printf 'Updated emulator site bundle at %s from %s\n' "$OUT_DIR" "$VSDK_DIR"
