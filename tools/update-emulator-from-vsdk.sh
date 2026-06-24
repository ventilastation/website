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
  --include 'sounds/***' \
  --include 'menu.png' \
  --exclude '*' \
  "$VSDK_DIR/games"/ "$OUT_DIR/games"/
rsync -a --delete --prune-empty-dirs \
  --include '*/' \
  --include 'images/***' \
  --include 'sounds/***' \
  --exclude '*' \
  "$VSDK_DIR/system"/ "$OUT_DIR/system"/

find "$OUT_DIR/games" "$OUT_DIR/system" -type f \( -name '__images__.yaml.txt' -o -name '__images__.yml.txt' -o -name 'images-manifest.yaml.txt' -o -name 'images-manifest.yml.txt' \) -delete 2>/dev/null || true
while IFS= read -r -d '' manifest; do
  manifest_dir="$(dirname "$manifest")"
  manifest_name="$(basename "$manifest")"
  case "$manifest_name" in
    __images__.yaml)
      cp "$manifest" "$manifest_dir/images-manifest.yaml.txt"
      ;;
    __images__.yml)
      cp "$manifest" "$manifest_dir/images-manifest.yml.txt"
      ;;
  esac
done < <(find "$OUT_DIR/games" "$OUT_DIR/system" -type f \( -name '__images__.yaml' -o -name '__images__.yml' \) -print0 2>/dev/null)

printf 'Updated emulator publish tree at %s from %s/web + %s/apps + source assets\n' "$OUT_DIR" "$VSDK_DIR" "$VSDK_DIR"
