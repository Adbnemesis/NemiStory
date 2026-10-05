#!/usr/bin/env python3
"""Read-only source/status audit for the isolated Shorts pipeline."""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PROTECTED_ROOTS = ("adb", "nemi", "common", "docs/animation", "tools/storytime")
ROOT_SETTINGS = ("project.godot", "override.cfg")
SOURCE_SUFFIXES = {
    ".gd", ".tscn", ".tres", ".godot", ".py", ".json", ".md", ".txt",
    ".yaml", ".yml", ".toml", ".cfg", ".svg", ".gdshader", ".shader",
    ".glsl", ".html", ".css", ".js", ".ts", ".tsx", ".sh", ".csv",
    ".xml", ".ini", ".res", ".remap",
}
SKIP_DIRECTORIES = {".git", ".godot", "__pycache__", "node_modules", "renders"}


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def protected_files() -> dict[str, dict]:
    paths: set[Path] = set()
    for relative in PROTECTED_ROOTS:
        directory = ROOT / relative
        if not directory.exists():
            continue
        for path in directory.rglob("*"):
            if not path.is_file() or path.is_symlink():
                continue
            if set(path.relative_to(ROOT).parts) & SKIP_DIRECTORIES:
                continue
            if path.suffix.lower() not in SOURCE_SUFFIXES:
                continue
            paths.add(path)
    for relative in ROOT_SETTINGS:
        path = ROOT / relative
        if path.is_file():
            paths.add(path)
    return {
        path.relative_to(ROOT).as_posix(): {"sha256": sha256(path), "bytes": path.stat().st_size}
        for path in sorted(paths)
    }


def outside_shorts_status() -> list[dict]:
    raw = subprocess.check_output(
        ["git", "status", "--porcelain=v1", "-z", "--untracked-files=all"], cwd=ROOT
    )
    tokens = raw.decode("utf-8", errors="surrogateescape").split("\0")
    result = []
    i = 0
    while i < len(tokens) and tokens[i]:
        record = tokens[i]
        status, path = record[:2], record[3:]
        i += 1
        entry = {"status": status, "path": path}
        if "R" in status or "C" in status:
            entry["originalPath"] = tokens[i]
            i += 1
        if path != "shorts" and not path.startswith("shorts/"):
            result.append(entry)
    return sorted(result, key=lambda x: (x["path"], x["status"]))


def snapshot() -> dict:
    return {
        "capturedAtUTC": dt.datetime.now(dt.timezone.utc).isoformat(),
        "workspace": str(ROOT),
        "strategy": {
            "protectedRoots": list(PROTECTED_ROOTS),
            "rootSettings": list(ROOT_SETTINGS),
            "sourceSuffixes": sorted(SOURCE_SUFFIXES),
            "excludedDirectories": sorted(SKIP_DIRECTORIES),
            "excluded": "Binary media/fonts, generated .uid/.import sidecars, symlinks, and files under renders/ are excluded from source hashes. Git status still records nonignored changes outside shorts/.",
        },
        "rootSettingsExistence": {name: (ROOT / name).exists() for name in ROOT_SETTINGS},
        "files": protected_files(),
        "outsideShortsGitStatus": outside_shorts_status(),
    }


def compare(before: dict, after: dict) -> dict:
    old, new = before["files"], after["files"]
    changed = sorted(path for path in old.keys() & new.keys() if old[path]["sha256"] != new[path]["sha256"])
    added, removed = sorted(new.keys() - old.keys()), sorted(old.keys() - new.keys())
    status_unchanged = before["outsideShortsGitStatus"] == after["outsideShortsGitStatus"]
    settings_unchanged = before["rootSettingsExistence"] == after["rootSettingsExistence"]
    return {
        "checkedAtUTC": after["capturedAtUTC"],
        "protectedFileCountBefore": len(old),
        "protectedFileCountAfter": len(new),
        "changed": changed,
        "added": added,
        "removed": removed,
        "rootSettingsExistenceUnchanged": settings_unchanged,
        "outsideShortsGitStatusUnchanged": status_unchanged,
        "passed": not changed and not added and not removed and status_unchanged and settings_unchanged,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    take = sub.add_parser("snapshot")
    take.add_argument("output", type=Path)
    check = sub.add_parser("check")
    check.add_argument("baseline", type=Path)
    check.add_argument("output", type=Path)
    args = parser.parse_args()
    now = snapshot()
    if args.command == "snapshot":
        report = now
        code = 0
    else:
        report = compare(json.loads(args.baseline.read_text()), now)
        code = 0 if report["passed"] else 1
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps({"report": str(args.output.resolve()), "protectedFiles": len(now["files"]), "outsideShortsStatusEntries": len(now["outsideShortsGitStatus"]), **({"passed": report["passed"], "changed": report["changed"], "added": report["added"], "removed": report["removed"]} if args.command == "check" else {})}))
    return code


if __name__ == "__main__":
    raise SystemExit(main())
