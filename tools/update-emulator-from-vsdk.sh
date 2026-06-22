#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSDK_DIR="${1:-"$ROOT_DIR/vsdk"}"
OUT_DIR="${2:-"$ROOT_DIR/emulator"}"

if [[ ! -d "$VSDK_DIR/web" || ! -d "$VSDK_DIR/apps" ]]; then
  echo "Expected a vsdk checkout at $VSDK_DIR" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
rsync -a --delete --exclude 'apps' --exclude '__pycache__/' "$VSDK_DIR/web"/ "$OUT_DIR"/
rsync -a --delete --exclude '__pycache__/' "$VSDK_DIR/apps"/ "$OUT_DIR/apps"/
rsync -a --delete --prune-empty-dirs \
  --include '*/' \
  --include 'images/***' \
  --include 'menu.png' \
  --exclude '*' \
  "$VSDK_DIR/games"/ "$OUT_DIR/games"/
rsync -a --delete --prune-empty-dirs \
  --include '*/' \
  --include 'images/***' \
  --exclude '*' \
  "$VSDK_DIR/system"/ "$OUT_DIR/system"/

printf 'Updated emulator publish tree at %s from %s/web + %s/apps + source assets\n' "$OUT_DIR" "$VSDK_DIR" "$VSDK_DIR"
