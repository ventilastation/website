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

## After editing JS only

If only browser-side JS/CSS/HTML changed, a normal reload is usually enough:

1. Publish `vsdk/web` into `emulator/`
2. Reload `http://127.0.0.1:8000/`

## After editing MicroPython emulator code

If you change files such as:

- `vsdk/web/apps/micropython/ventilastation/browser.py`
- `vsdk/web/apps/micropython/ventilastation/director.py`
- `vsdk/web/apps/micropython/ventilastation/platforms/__init__.py`
- `vsdk/web/apps/micropython/ventilastation/wasm_bridge.py`

you must refresh `vsdk/web/runtime-bundle.json` before publishing.

## Fast local bundle refresh

This updates bundle entries from files that currently exist under `vsdk/web/`:

```bash
python3 tools/refresh-emulator-runtime-bundle.py
```

Use this when the manifest is already in place and you only need the bundle contents to match the current checked-out web-emulator files.

## Publish into the site tree

After updating `vsdk/web`, publish it into the site-facing `emulator/` directory with:

```bash
tools/update-emulator-from-vsdk.sh
```

## Full local deploy

To clean the published copy, refresh the source bundle, publish into `emulator/`, and start a fresh local server in one step:

```bash
tools/deploy-emulator-local.sh
```

By default it serves on `http://127.0.0.1:8000/`.

You can override the port, for example:

```bash
PORT=8001 tools/deploy-emulator-local.sh
```

## Notes about full bundle rebuilds

There is a generator in:

- `vsdk/tools/generate_web_runtime_bundle.py`

and a helper script:

- `vsdk/tools/build-web-emulator-bundle.sh`

But those assume the original VSDK layout. In this repo, `vsdk/web/runtime-manifest.json` may reference files that are not all present on disk, so a naive full rebuild can fail.

If a full rebuild is needed:

1. verify the manifest paths are valid for the current source tree
2. or regenerate the emulator bundle from the correct root layout

## Local server

To serve the published emulator locally:

```bash
cd emulator
python3 -m http.server 8000 --bind 127.0.0.1
```

Open:

- `http://127.0.0.1:8000/`

Do not use `/emulator/` in the URL when serving from inside the `emulator/` directory.

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
2. refresh `vsdk/web/runtime-bundle.json`
3. publish `vsdk/web` into `emulator/`
4. reload the page
5. if behavior still looks stale, do a hard reload
