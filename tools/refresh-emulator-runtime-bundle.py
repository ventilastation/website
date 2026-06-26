#!/usr/bin/env python3

import base64
import json
import pathlib
import sys


def main() -> int:
    repo_root = pathlib.Path(__file__).resolve().parent.parent
    target_root = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else (repo_root / "vsdk" / "web")
    bundle_path = target_root / "runtime-bundle.json"
    source_roots = [target_root]
    if target_root.name == "web":
        source_roots.append(target_root.parent)

    if not bundle_path.is_file():
        print(f"error: missing bundle file: {bundle_path}", file=sys.stderr)
        return 1

    bundle = json.loads(bundle_path.read_text(encoding="utf-8"))
    updated = 0
    missing = []

    for entry in bundle.get("files", []):
        rel_path = entry.get("path")
        if not isinstance(rel_path, str):
            continue
        source_path = None
        for base_root in source_roots:
            candidate = base_root / rel_path
            if candidate.is_file():
                source_path = candidate
                break
        if source_path is None:
            missing.append(rel_path)
            continue
        entry["base64"] = base64.b64encode(source_path.read_bytes()).decode("ascii")
        updated += 1

    bundle_path.write_text(
        json.dumps(bundle, ensure_ascii=True, separators=(",", ":")),
        encoding="utf-8",
    )

    print(f"updated {updated} bundle entries from {target_root}")
    if missing:
        print(f"skipped {len(missing)} missing entries", file=sys.stderr)
        print(missing, file=sys.stderr)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
