#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUBY_BIN_DIR="${RUBY_BIN_DIR:-/usr/local/opt/ruby@3.3/bin}"
BUNDLER_VERSION="${BUNDLER_VERSION:-2.5.11}"
TMP_HOME="${TMP_HOME:-/private/tmp/codex-bundler-home}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/_site_local_pages_test}"

if [[ ! -x "$RUBY_BIN_DIR/ruby" || ! -x "$RUBY_BIN_DIR/bundle" ]]; then
  echo "Expected Ruby toolchain under $RUBY_BIN_DIR" >&2
  echo "Install it with: brew install ruby@3.3" >&2
  exit 1
fi

export PATH="$RUBY_BIN_DIR:$PATH"
export HOME="$TMP_HOME"
mkdir -p "$HOME"

cd "$ROOT_DIR"

echo "[1/5] Ruby: $(ruby --version)"
echo "[2/5] Bundler: $(bundle _${BUNDLER_VERSION}_ --version)"
echo "[3/5] Refreshing ROMs, bundle, and published emulator tree"
make publish OUTPUT_DIR="$OUTPUT_DIR"
echo "[4/5] Installing gems"
bundle _${BUNDLER_VERSION}_ install
echo "[5/5] Building Jekyll site"
bundle _${BUNDLER_VERSION}_ exec jekyll build --destination "$OUTPUT_DIR"

echo
echo "Local Pages build completed at:"
echo "  $OUTPUT_DIR"
