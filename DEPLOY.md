# Emulator Deploy / Refresh Notes

This file documents the local steps needed when changing the web emulator, especially the MicroPython files loaded by the WASM worker.

## Source of truth

The editable web emulator source lives under:

- `vsdk/web`

Inside the VSDK repo, `vsdk/web/apps` is a symlink to:

- `vsdk/apps`

The top-level `emulator/` directory is a publish/deploy copy used by the Jekyll site.

That means:

- make web-shell changes in `vsdk/web`
- make app/runtime payload changes through `vsdk/web/apps/...` or directly in `vsdk/apps/...`
- then publish those files into `emulator/`

## Why this matters

The web emulator does not load `apps/...` files directly at runtime.

The WASM worker boots MicroPython from:

- `runtime-bundle.json`
- with file paths listed in `runtime-manifest.json`

That means editing Python source under `vsdk/web/apps/micropython/...` is not enough by itself. If the runtime bundle is not refreshed, the browser may still run stale Python code even though the JS files are new.

Exception:

- if you are editing files through the browser workspace API exposed as `window.VentilastationWebEmulator`, those live workspace edits are written straight into the worker filesystem and do not require a bundle refresh for that browser session

## Canonical commands

The top-level `Makefile` is now the canonical deploy surface:

- `make install-deps`
- `make roms`
- `make bundle`
- `make publish`
- `make start`
- `make local-pages-build`

These targets replace the old ad-hoc sequence and are what local scripts plus GitHub Actions should call.

## What each command does

`make install-deps`

- creates the VSDK virtualenv at `vsdk/.venv`
- installs `vsdk/requirements.txt` into that virtualenv
- matches the VSDK emulator docs for macOS and Linux

`make roms`

- runs the Python ROM generator in `vsdk/tools/generate_roms.py`
- scans `vsdk/games/**/images` and `vsdk/system/**/images`
- rebuilds only ROM files whose source PNGs or `__images__.yaml` changed
- writes ROMs to `vsdk/apps/micropython/roms`
- requires the Python deps from `vsdk/requirements.txt`
- prefers `vsdk/.venv/bin/python` automatically, matching the VSDK emulator docs

`make bundle`

- runs `make roms` first
- refreshes `vsdk/web/runtime-bundle.json` from the current files under `vsdk/web`

`make publish`

- runs `make bundle` first
- republishes `vsdk/web` and `vsdk/apps` into the site-facing `emulator/` tree

`make start`

- runs `make publish` first
- rebuilds ROMs, bundle, or the published tree only when their inputs are newer or missing
- restarts the local static server for `emulator/`
- serves `http://127.0.0.1:8000/` by default

Override host or port when needed:

```bash
HOST=0.0.0.0 PORT=8001 make start
```

## After editing JS only

If only browser-side JS/CSS/HTML changed, a normal refresh flow is:

1. `make publish`
2. Reload `http://127.0.0.1:8000/`

## After editing MicroPython emulator code

If you change files such as:

- `vsdk/web/apps/micropython/ventilastation/browser.py`
- `vsdk/web/apps/micropython/ventilastation/director.py`
- `vsdk/web/apps/micropython/ventilastation/platforms/__init__.py`
- `vsdk/web/apps/micropython/ventilastation/wasm_bridge.py`

you must refresh `vsdk/web/runtime-bundle.json` before publishing.

## Fast local bundle refresh

```bash
make bundle
```

Use this when you want the runtime bundle refreshed and ROMs checked first.

## Local Pages build test

To reproduce the GitHub Pages Jekyll build locally with Homebrew Ruby 3.3 and Bundler 2.5.11:

```bash
make local-pages-build
```

That target:

1. uses `/usr/local/opt/ruby@3.3/bin`
2. regenerates ROMs if needed
3. refreshes `vsdk/web/runtime-bundle.json`
4. republishes `vsdk` into `emulator/`
5. runs `bundle install`
6. builds Jekyll into `_site_local_pages_test/`

The compatibility wrapper still exists:

```bash
tools/test-pages-build.sh
```

It now delegates to the same shared `make` targets.

## Compatibility wrappers

These scripts still exist for convenience, but now delegate to the `Makefile`:

- `tools/deploy-emulator-local.sh`
- `tools/test-pages-build.sh`

The low-level publish helper still exists and is used internally by `make publish`:

- `tools/update-emulator-from-vsdk.sh`

## ROM generation paths

There are two ROM-generation implementations on purpose:

- Python deploy path: `vsdk/tools/generate_roms.py`
- Browser/editor path: `vsdk/web/rom-builder-core.js`, `vsdk/web/rom-builder-browser.js`, `vsdk/web/workspace-rom-builder.js`

Use the Python path for deploys, CI, and checked-in ROM updates.

The recommended bootstrap step is now:

```bash
make install-deps
```

If you prefer a virtualenv, point `make` at it explicitly:

```bash
PYTHON=.venv/bin/python make publish
```

Use the JS path inside the browser IDE, where edited PNGs are converted into temporary runtime ROMs without waiting for a server-side deploy.

There is also a Node CLI wrapper around the JS path for parity/debugging:

```bash
make roms-js
```

## Local server

To rebuild anything stale, publish it, and restart the local emulator server:

```bash
make start
```

Open:

- `http://127.0.0.1:8000/`

The compatibility wrapper remains available:

```bash
tools/deploy-emulator-local.sh
```

You can override the port, for example:

```bash
PORT=8001 make start
```

Or:

```bash
PORT=8001 tools/deploy-emulator-local.sh
```

## Direct low-level commands

If you need to run the underlying pieces directly:

1. `cd vsdk/tools && python3 generate_roms.py`
2. `python3 tools/refresh-emulator-runtime-bundle.py vsdk/web`
3. `tools/update-emulator-from-vsdk.sh`
4. `cd emulator && python3 -m http.server 8000 --bind 127.0.0.1`

## Notes about full bundle rebuilds

There is a generator in:

- `vsdk/tools/generate_web_runtime_bundle.py`

and a helper script:

- `vsdk/tools/build-web-emulator-bundle.sh`

But those assume the original VSDK layout. In this repo, `vsdk/web/runtime-manifest.json` may reference files that are not all present on disk, so a naive full rebuild can fail.

If a full rebuild is needed:

1. verify the manifest paths are valid for the current source tree
2. or regenerate the emulator bundle from the correct root layout

## Worker caching

The browser can keep using a stale module worker even after JS edits if the worker URL does not change.

If `app.js` looks updated but worker-side diagnostics do not, bump the cache-busting version in the source tree:

- `vsdk/web/micropython-bridge.js`

Specifically, update the query string used for:

- `./wasm-worker.js?v=...`

If needed, also bump the import query inside:

- `vsdk/web/wasm-worker.js`

for:

- `./vendor/micropython/micropython.mjs?v=...`

## Recommended refresh flow

After Python-side emulator changes:

1. update the source files
2. run `make start` or at least `make publish`
3. reload the page
4. if behavior still looks stale, do a hard reload

## Browser IDE note

For web IDE integration, prefer this split:

- use `runtime-bundle.json` as the base read-only runtime payload
- layer editable project files on top through the browser workspace API
- restart the runtime after save

That gives a fast edit/test loop without rebuilding the bundle on every change.
