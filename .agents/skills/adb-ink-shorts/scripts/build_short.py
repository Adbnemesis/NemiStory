#!/usr/bin/env python3
"""Validate, render and technically check a scoped Godot version-3 ink Short.

This helper resolves the repository through the installed skill's real path or
--repo. It delegates media work to the maintained Shorts pipeline and does not
invent engine controls or claim visual/playback approval.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

AUTHOR_SCOPE = {"adb"}


def find_repo(explicit: Path | None) -> Path:
    candidates = [explicit] if explicit else [Path(__file__).resolve().parent, Path.cwd()]
    for candidate in candidates:
        if candidate is None:
            continue
        candidate = candidate.resolve()
        for directory in (candidate, *candidate.parents):
            if (directory / "shorts/godot/validate_ink.py").is_file():
                return directory
    raise SystemExit("Repository not found. Pass --repo /path/to/adb.")


def under_shorts(path: Path, repo: Path) -> Path:
    path = path.resolve()
    try:
        path.relative_to((repo / "shorts").resolve())
    except ValueError:
        raise SystemExit(f"Production/media must stay under {repo / 'shorts'}: {path}")
    return path


def read_scope(spec: Path) -> dict:
    config = json.loads(spec.read_text())
    if config.get("version") != 3:
        raise SystemExit("Use version 3. Old version-2 timing is style context, not the current motion workflow.")
    authors = {actor.get("author") for actor in config.get("actors", [])}
    if authors != AUTHOR_SCOPE:
        raise SystemExit(f"This skill requires exactly these author types: {', '.join(sorted(AUTHOR_SCOPE))}.")
    return config


def file_hash(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("validate", "stills", "build", "check"))
    parser.add_argument("spec", type=Path)
    parser.add_argument("--revision", default="r1", help="New alphanumeric render revision.")
    parser.add_argument("--movie", type=Path, help="Required for check; an existing encoded export.")
    parser.add_argument("--repo", type=Path)
    args = parser.parse_args()
    repo = find_repo(args.repo)
    spec = under_shorts(args.spec if args.spec.is_absolute() else repo / args.spec, repo)
    read_scope(spec)
    if not args.revision.isalnum():
        parser.error("--revision must be alphanumeric.")
    if args.action == "check" and args.movie is None:
        parser.error("check requires --movie.")
    if args.movie is not None and args.action != "check":
        parser.error("--movie is only used with check.")

    pipeline = repo / "shorts/godot"
    python = repo / ".venv/bin/python"
    executable = str(python) if python.is_file() else sys.executable

    def run(script: str, *arguments: object) -> None:
        target = pipeline / script
        if not target.is_file():
            raise SystemExit(f"Current version-3 pipeline is incomplete: missing {target}")
        subprocess.run([executable, str(target), *(str(item) for item in arguments)], cwd=repo, check=True)

    run("validate_ink.py", spec)
    if args.action == "validate":
        return
    config = read_scope(spec)
    if args.action == "stills":
        run("render_ink.py", spec, args.revision, "--stills")
        print(f"Inspect {spec.parent / 'review/stills' / args.revision} before the movie build.")
        return
    if args.action == "build":
        run("render_ink.py", spec, args.revision)
        movie = spec.parent / "renders" / f"{config['id']}_{args.revision}_1080x1920.mp4"
    else:
        movie = args.movie if args.movie.is_absolute() else repo / args.movie
    movie = under_shorts(movie, repo)
    if not movie.is_file():
        raise SystemExit(f"Movie missing: {movie}")
    review = spec.parent / "review"
    review.mkdir(exist_ok=True)
    tag = movie.stem
    audio_path = review / f"audio_{tag}.json"
    pacing_path = review / f"pacing_{tag}.json"
    run("inspect_export.py", spec, movie)
    run("verify_audio.py", spec, movie, audio_path)
    run("check_pacing.py", spec, movie, pacing_path)
    audio = json.loads(audio_path.read_text())
    pacing = json.loads(pacing_path.read_text())
    if not audio.get("passed"):
        raise SystemExit("Encoded audio failed. Read the audio report and repair the mix.")
    if pacing.get("passed") is not True or pacing.get("maxStaticSeconds", float("inf")) > 1.5:
        raise SystemExit("Decoded pacing failed or its evidence is missing. Repair actual visible motion/poses/events.")
    export_path = review / "export.json"
    export = json.loads(export_path.read_text())
    export_copy = review / f"export_{tag}.json"
    export_copy.write_text(json.dumps(export, indent=2) + "\n")
    record = {
        "skill": Path(__file__).resolve().parents[1].name,
        "authors": sorted(AUTHOR_SCOPE),
        "version": 3,
        "spec": str(spec),
        "specSha256": file_hash(spec),
        "movie": str(movie),
        "movieSha256": file_hash(movie),
        "technicalPassed": True,
        "decodedMaxStaticSeconds": pacing["maxStaticSeconds"],
        "reports": {"export": str(export_copy), "audio": str(audio_path), "pacing": str(pacing_path)},
        "visualAndPlaybackReview": "pending: inspect actual exported picture and listen before completing QA",
    }
    record_path = review / f"skill-build_{tag}.json"
    record_path.write_text(json.dumps(record, indent=2) + "\n")
    print(f"Technical checks passed. Complete visual/playback QA: {record_path}")


if __name__ == "__main__":
    main()
