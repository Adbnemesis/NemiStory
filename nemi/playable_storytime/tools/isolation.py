#!/usr/bin/env python3
"""Snapshot/check repository isolation without modifying external files.

Only report paths, metadata and source hashes; never serialize source contents.
Large files and sensitive-name files receive metadata-only checks. Symlinks are
recorded without following them. Run snapshot before production, then check.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from datetime import datetime, timezone

PROJECT = Path(__file__).resolve().parents[1]
REPOSITORY = PROJECT.parents[1]
DEFAULT_BASELINE = PROJECT / "documentation/isolation_baseline.json"
EXCLUDED_DIR_NAMES = {".git", ".venv", ".godot", "node_modules"}
SOURCE_SUFFIXES = {
    ".py", ".gd", ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs",
    ".json", ".md", ".txt", ".toml", ".yaml", ".yml", ".cfg", ".ini",
    ".godot", ".tscn", ".tres", ".glsl", ".shader", ".gdshader", ".html",
    ".css", ".svg", ".sh", ".bash", ".zsh", ".xml", ".csv", ".srt",
    ".vtt", ".lock", ".gitignore", ".gitattributes", ".rst", ".sql",
}
SOURCE_NAMES = {"AGENTS.md", "SKILL.md", "Dockerfile", "Makefile", ".gitignore", ".gitattributes"}
MAX_HASH_BYTES = 4 * 1024 * 1024


def within(path: Path, parent: Path) -> bool:
    try:
        path.resolve().relative_to(parent.resolve())
        return True
    except ValueError:
        return False


def sensitive_name(path: Path) -> bool:
    name = path.name.lower()
    return (name == ".env" or name.startswith(".env.") or name in {
        "credentials", "credentials.json", "token.json", "tokens.json",
        "id_rsa", "id_ed25519", "secrets.json", "secrets.toml",
    } or path.suffix.lower() in {".pem", ".key", ".p12", ".pfx"})


def digest(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def inventory(repository: Path, excluded_project: Path) -> dict:
    files, errors, excluded_dirs = {}, [], []
    for base, dirs, names in os.walk(repository, followlinks=False):
        parent = Path(base)
        retained = []
        for name in sorted(dirs):
            path = parent / name
            relative = path.relative_to(repository).as_posix()
            if name in EXCLUDED_DIR_NAMES or path == excluded_project:
                excluded_dirs.append(relative)
            elif path.is_symlink():
                names.append(name)
            else:
                retained.append(name)
        dirs[:] = retained
        for name in sorted(names):
            path = parent / name
            relative = path.relative_to(repository).as_posix()
            try:
                stat = path.lstat()
                row = {"size": stat.st_size, "mtime_ns": stat.st_mtime_ns,
                       "mode": stat.st_mode}
                if path.is_symlink():
                    row.update(kind="symlink", target=os.readlink(path))
                else:
                    row["kind"] = "file"
                    source = path.suffix.lower() in SOURCE_SUFFIXES or path.name in SOURCE_NAMES
                    if sensitive_name(path):
                        row["verification"] = "metadata-only-sensitive-name"
                    elif source and stat.st_size <= MAX_HASH_BYTES:
                        row["sha256"] = digest(path)
                        row["verification"] = "sha256-and-metadata"
                    else:
                        row["verification"] = "metadata-only"
                files[relative] = row
            except (OSError, PermissionError) as exc:
                errors.append({"path": relative, "error": type(exc).__name__})
    return {"files": files, "errors": errors, "excluded_directories": sorted(excluded_dirs)}


def git_status(repository: Path) -> list[dict]:
    result = subprocess.run(["git", "-C", str(repository), "status", "--porcelain=v1", "-z", "--untracked-files=all"],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    if result.returncode:
        return [{"error": "git status unavailable", "returncode": result.returncode}]
    records, chunks, index = [], result.stdout.split(b"\0"), 0
    while index < len(chunks):
        chunk = chunks[index]
        index += 1
        if not chunk:
            continue
        text = chunk.decode("utf-8", "surrogateescape")
        record = {"status": text[:2], "path": text[3:]}
        if "R" in text[:2] or "C" in text[:2]:
            if index < len(chunks):
                record["previous_path"] = chunks[index].decode("utf-8", "surrogateescape")
                index += 1
        records.append(record)
    return records


def compare(before: dict, after: dict) -> dict:
    old, new = before["files"], after["files"]
    common = old.keys() & new.keys()
    modified = []
    for path in sorted(common):
        if old[path] != new[path]:
            fields = sorted(key for key in old[path].keys() | new[path].keys()
                            if old[path].get(key) != new[path].get(key))
            modified.append({"path": path, "changed_fields": fields})
    return {"added": sorted(new.keys() - old.keys()),
            "deleted": sorted(old.keys() - new.keys()), "modified": modified,
            "inventory_errors": after["errors"],
            "passed": not (new.keys() - old.keys() or old.keys() - new.keys()
                           or modified or before.get("errors") or after["errors"])}


def safe_output(path: Path) -> Path:
    if not within(path, PROJECT):
        raise SystemExit("Output must be inside nemi/playable_storytime/.")
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def write_json(path: Path, content: dict) -> None:
    safe_output(path).write_text(json.dumps(content, ensure_ascii=True, indent=2) + "\n")


def snapshot(path: Path) -> dict:
    if path.exists():
        raise SystemExit("Baseline already exists; choose a new baseline path to preserve evidence.")
    data = inventory(REPOSITORY, PROJECT)
    data.update(schema_version=1, created_utc=datetime.now(timezone.utc).isoformat(),
                repository=str(REPOSITORY), excluded_project=str(PROJECT),
                excluded_directory_names=sorted(EXCLUDED_DIR_NAMES),
                max_source_hash_bytes=MAX_HASH_BYTES,
                source_suffixes=sorted(SOURCE_SUFFIXES),
                limitations=[
                    "SHA256 covers recognized source/configuration files up to 4 MiB. Other files, large media, and sensitive-name files are checked by size, mtime_ns and mode only.",
                    "A large-file change that restores all recorded metadata could evade this check. This report is not a full media-content attestation.",
                    "Excluded .git, .venv, .godot and node_modules directory contents are not monitored; every discovered excluded path is listed.",
                    "External concurrent changes are detected but cannot be attributed automatically to this production.",
                    "The baseline preserves the existing dirty Git state; check compares filesystem state rather than assuming a clean checkout.",
                    "File access times are intentionally ignored because read-only inspection can change them.",
                ], preexisting_git_status=git_status(REPOSITORY))
    write_json(path, data)
    return {"baseline": str(path), "files": len(data["files"]),
            "hashed_files": sum("sha256" in row for row in data["files"].values()),
            "inventory_errors": data["errors"],
            "preexisting_git_entries": len(data["preexisting_git_status"])}


def self_test() -> dict:
    fixture_parent = safe_output(PROJECT / "tests/isolation_fixtures/.keep").parent
    fixture = Path(tempfile.mkdtemp(prefix="isolation-", dir=fixture_parent))
    try:
        external, generated = fixture / "external", fixture / "production"
        external.mkdir()
        generated.mkdir()
        (external / "source.py").write_text("value = 1\n")
        (external / "delete.txt").write_text("retain\n")
        before = inventory(fixture, generated)
        (generated / "allowed.txt").write_text("permitted output\n")
        ignored = compare(before, inventory(fixture, generated))["passed"]
        (external / "source.py").write_text("value = 2\n")
        (external / "delete.txt").unlink()
        (external / "added.py").write_text("added = True\n")
        result = compare(before, inventory(fixture, generated))
        assert ignored, "Production-directory changes should be ignored"
        assert result["added"] == ["external/added.py"]
        assert result["deleted"] == ["external/delete.txt"]
        assert [row["path"] for row in result["modified"]] == ["external/source.py"]
        assert "sha256" in result["modified"][0]["changed_fields"]
        assert not result["passed"]
        return {"passed": True, "checks": ["project outputs ignored", "outside addition detected", "outside deletion detected", "source-content modification detected"]}
    finally:
        shutil.rmtree(fixture)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["snapshot", "check", "self-test"])
    parser.add_argument("--baseline", type=Path, default=DEFAULT_BASELINE)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.command == "snapshot":
        result = snapshot(safe_output(args.baseline))
    elif args.command == "self-test":
        result = self_test()
    else:
        before = json.loads(args.baseline.read_text())
        if before["repository"] != str(REPOSITORY) or before["excluded_project"] != str(PROJECT):
            raise SystemExit("Baseline belongs to a different repository/project.")
        result = compare(before, inventory(REPOSITORY, PROJECT))
        result.update(baseline=str(args.baseline), checked_utc=datetime.now(timezone.utc).isoformat(),
                      baseline_files=len(before["files"]), limitations=before["limitations"])
    if args.output:
        write_json(args.output, result)
    print(json.dumps(result, indent=2))
    return 0 if result.get("passed", not result.get("inventory_errors")) else 1


if __name__ == "__main__":
    raise SystemExit(main())
