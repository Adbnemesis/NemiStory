#!/usr/bin/env python3
"""Inject/inspect monoscopic 360 metadata without changing media samples.

References (read 2026-10-25):
https://github.com/google/spatial-media/blob/master/docs/spherical-video-rfc.md
https://github.com/google/spatial-media/blob/master/docs/spherical-video-v2-rfc.md

This independently written implementation supports ordinary, non-fragmented MP4.
It rewrites only moov and adjusts every stco/co64 chunk offset after moov. It does
not mistake an MP4 text tag for spherical metadata. No third-party package needed.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import struct
import tempfile
import xml.etree.ElementTree as ET

SPHERICAL_UUID = bytes.fromhex("ffcc8263f8554a938814587a02521fdd")
SPHERICAL_NS = "http://ns.google.com/videos/1.0/spherical/"
CONTAINERS = {b"moov", b"trak", b"mdia", b"minf", b"stbl"}
VISUAL_ENTRIES = {b"avc1", b"avc3", b"hvc1", b"hev1", b"mp4v", b"av01", b"vp09"}


class MetadataError(ValueError):
    pass


def box(kind: bytes, payload: bytes, extended: bool = False) -> bytes:
    size = len(payload) + 8
    if extended or size > 0xFFFFFFFF:
        return struct.pack(">I4sQ", 1, kind, len(payload) + 16) + payload
    return struct.pack(">I4s", size, kind) + payload


def atoms(data: bytes, start: int = 0, end: int | None = None):
    """Yield (type, payload, extended) after strict bounded atom parsing."""
    end = len(data) if end is None else end
    position = start
    while position < end:
        if end - position < 8:
            raise MetadataError("Truncated MP4 atom header")
        size, kind = struct.unpack_from(">I4s", data, position)
        header, extended = 8, size == 1
        if extended:
            if end - position < 16:
                raise MetadataError("Truncated extended MP4 atom")
            size = struct.unpack_from(">Q", data, position + 8)[0]
            header = 16
        if size == 0:
            size = end - position
        if size < header or position + size > end:
            raise MetadataError("Invalid MP4 atom bounds")
        yield kind, data[position + header:position + size], extended
        position += size


def top_atoms(path: Path):
    end = path.stat().st_size
    with path.open("rb") as stream:
        position = 0
        while position < end:
            stream.seek(position)
            header = stream.read(8)
            if len(header) != 8:
                raise MetadataError("Truncated top-level atom")
            size, kind = struct.unpack(">I4s", header)
            headsize = 8
            if size == 1:
                raw = stream.read(8)
                if len(raw) != 8:
                    raise MetadataError("Truncated extended top-level atom")
                size = struct.unpack(">Q", raw)[0]
                headsize = 16
            if size == 0:
                size = end - position
            if size < headsize or position + size > end:
                raise MetadataError("Invalid top-level atom bounds")
            yield kind, position, size, headsize
            position += size


def is_video_track(payload: bytes) -> bool:
    for kind, body, _ in atoms(payload):
        if kind == b"mdia":
            for subkind, subbody, _ in atoms(body):
                if subkind == b"hdlr" and len(subbody) >= 12:
                    return subbody[8:12] == b"vide"
    return False


def v1_payload() -> bytes:
    xml = ('<?xml version="1.0"?>'
           '<rdf:SphericalVideo xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" '
           'xmlns:GSpherical="http://ns.google.com/videos/1.0/spherical/">'
           '<GSpherical:Spherical>true</GSpherical:Spherical>'
           '<GSpherical:Stitched>true</GSpherical:Stitched>'
           '<GSpherical:StitchingSoftware>Nemi Playable Storytime</GSpherical:StitchingSoftware>'
           '<GSpherical:ProjectionType>equirectangular</GSpherical:ProjectionType>'
           '<GSpherical:StereoMode>mono</GSpherical:StereoMode>'
           '</rdf:SphericalVideo>')
    return SPHERICAL_UUID + xml.encode("utf-8")


def v2_boxes() -> bytes:
    full = b"\0" * 4
    st3d = box(b"st3d", full + b"\0")
    header = box(b"svhd", full + b"Nemi Playable Storytime\0")
    projection = box(b"proj", box(b"prhd", full + b"\0" * 12)
                     + box(b"equi", full + b"\0" * 16))
    return st3d + box(b"sv3d", header + projection)


def _rewrite(kind, payload, extended, version, delta, moov_end, video=False):
    if kind in {b"cmov", b"mvex"}:
        raise MetadataError("Compressed or fragmented MP4 is unsupported; remux to ordinary MP4 first")
    if kind in {b"stco", b"co64"}:
        if len(payload) < 8:
            raise MetadataError("Truncated chunk-offset table")
        count = struct.unpack_from(">I", payload, 4)[0]
        width = 4 if kind == b"stco" else 8
        if len(payload) != 8 + width * count:
            raise MetadataError("Invalid chunk-offset table length")
        values = [struct.unpack_from(">I" if width == 4 else ">Q", payload, 8 + i * width)[0]
                  for i in range(count)]
        values = [value + delta if value >= moov_end else value for value in values]
        if any(value < 0 or value > 0xFFFFFFFFFFFFFFFF for value in values):
            raise MetadataError("Chunk offset overflow")
        if kind == b"stco" and any(value > 0xFFFFFFFF for value in values):
            kind, width = b"co64", 8
        rebuilt = payload[:8] + b"".join(struct.pack(">I" if width == 4 else ">Q", value) for value in values)
        return box(kind, rebuilt, extended)
    if kind in CONTAINERS:
        if kind == b"trak":
            video = is_video_track(payload)
        children = []
        for childkind, child, childextended in atoms(payload):
            if kind == b"trak" and video and childkind == b"uuid" and child[:16] == SPHERICAL_UUID:
                continue
            children.append(_rewrite(childkind, child, childextended, version, delta, moov_end, video))
        if kind == b"trak" and video and version in {"v1", "both"}:
            children.append(box(b"uuid", v1_payload()))
        return box(kind, b"".join(children), extended)
    if kind == b"stsd" and video:
        if len(payload) < 8:
            raise MetadataError("Invalid sample description")
        entries = []
        for entrykind, entry, entryextended in atoms(payload, 8):
            if entrykind not in VISUAL_ENTRIES:
                raise MetadataError(f"Unsupported video sample entry: {entrykind!r}")
            if len(entry) < 78:
                raise MetadataError("Truncated visual sample entry")
            children = [box(k, body, ext) for k, body, ext in atoms(entry, 78)
                        if k not in {b"st3d", b"sv3d"}]
            if version in {"v2", "both"}:
                children.append(v2_boxes())
            entries.append(box(entrykind, entry[:78] + b"".join(children), entryextended))
        if len(entries) != struct.unpack_from(">I", payload, 4)[0]:
            raise MetadataError("Sample-entry count mismatch")
        return box(kind, payload[:8] + b"".join(entries), extended)
    return box(kind, payload, extended)


def inject(source: str | Path, destination: str | Path, version: str = "both") -> dict:
    source, destination = Path(source).resolve(), Path(destination).resolve()
    if version not in {"v1", "v2", "both"}:
        raise MetadataError("version must be v1, v2, or both")
    if source == destination or destination.exists():
        raise MetadataError("Output must be a new path; source is never overwritten")
    inventory = list(top_atoms(source))
    if any(kind in {b"moof", b"sidx", b"mfra", b"ssix"} for kind, *_ in inventory):
        raise MetadataError("Fragmented/indexed MP4 unsupported; remux first")
    movies = [item for item in inventory if item[0] == b"moov"]
    if len(movies) != 1 or not any(kind == b"mdat" for kind, *_ in inventory):
        raise MetadataError("Expected exactly one moov and at least one mdat")
    _, start, size, header = movies[0]
    if size > 256 * 1024 * 1024:
        raise MetadataError("Unexpectedly large moov; refusing unbounded metadata allocation")
    with source.open("rb") as stream:
        stream.seek(start + header)
        movie = stream.read(size - header)
    if not any(kind == b"trak" and is_video_track(body) for kind, body, _ in atoms(movie)):
        raise MetadataError("No video track found")
    delta = 0
    for _ in range(8):
        rewritten = _rewrite(b"moov", movie, header == 16, version, delta, start + size)
        new_delta = len(rewritten) - size
        if new_delta == delta:
            break
        delta = new_delta
    else:
        raise MetadataError("Chunk-offset rewriting did not converge")
    destination.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".spatial-", suffix=".mp4", dir=destination.parent)
    try:
        with source.open("rb") as infile, os.fdopen(fd, "wb") as outfile:
            remaining = start
            while remaining:
                block = infile.read(min(8 * 1024 * 1024, remaining))
                if not block:
                    raise MetadataError("Unexpected EOF before moov")
                outfile.write(block)
                remaining -= len(block)
            outfile.write(rewritten)
            infile.seek(start + size)
            shutil.copyfileobj(infile, outfile, 8 * 1024 * 1024)
        report = inspect(temporary)
        if not report["valid_spherical_metadata"]:
            raise MetadataError("Injected metadata did not pass inspection")
        os.replace(temporary, destination)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    report.update({"file": str(destination), "source": str(source), "moov_growth_bytes": delta,
                   "youtube_verified": False, "sample_payloads_changed": False})
    return report


def inspect(path: str | Path) -> dict:
    path = Path(path)
    inventory = list(top_atoms(path))
    movies = [item for item in inventory if item[0] == b"moov"]
    if len(movies) != 1:
        raise MetadataError("Expected one moov")
    _, start, size, header = movies[0]
    with path.open("rb") as stream:
        stream.seek(start + header)
        movie = stream.read(size - header)
    tracks = []

    def walk(payload, result):
        for kind, body, _ in atoms(payload):
            if kind in CONTAINERS:
                walk(body, result)
            elif kind == b"stsd":
                for entrykind, entry, _ in atoms(body, 8):
                    if entrykind in VISUAL_ENTRIES and len(entry) >= 78:
                        for childkind, child, _ in atoms(entry, 78):
                            if childkind == b"st3d":
                                result["stereo_mode"] = child[4] if len(child) >= 5 else -1
                            if childkind == b"sv3d":
                                for k2, b2, _ in atoms(child):
                                    if k2 == b"svhd" and len(b2) >= 5 and b2[-1:] == b"\0":
                                        result["v2_source"] = b2[4:-1].decode("utf-8", errors="replace")
                                    if k2 == b"proj":
                                        for k3, b3, _ in atoms(b2):
                                            if k3 == b"prhd" and len(b3) == 16:
                                                result["pose_degrees"] = [v / 65536 for v in struct.unpack(">iii", b3[4:])]
                                            if k3 == b"equi" and len(b3) == 20:
                                                result["v2_projection"] = "equirectangular"
                                                result["bounds"] = list(struct.unpack(">IIII", b3[4:]))
            elif kind == b"uuid" and body[:16] == SPHERICAL_UUID:
                try:
                    xml = ET.fromstring(body[16:])
                except ET.ParseError as exc:
                    raise MetadataError("Invalid spherical XML") from exc
                result["v1"] = {child.tag.removeprefix("{" + SPHERICAL_NS + "}"): child.text for child in xml}

    for kind, body, _ in atoms(movie):
        if kind == b"trak" and is_video_track(body):
            result = {}
            walk(body, result)
            result["valid_v1"] = (result.get("v1", {}).get("Spherical") == "true" and
                                  result.get("v1", {}).get("Stitched") == "true" and
                                  bool(result.get("v1", {}).get("StitchingSoftware")) and
                                  result.get("v1", {}).get("ProjectionType") == "equirectangular")
            result["valid_v2"] = (result.get("v2_projection") == "equirectangular" and
                                  result.get("bounds") == [0] * 4 and bool(result.get("v2_source")) and
                                  "pose_degrees" in result and result.get("stereo_mode", 0) == 0)
            result["valid"] = result["valid_v1"] or result["valid_v2"]
            tracks.append(result)
    return {"file": str(path.resolve()), "bytes": path.stat().st_size,
            "faststart": start < min((pos for k, pos, *_ in inventory if k == b"mdat"), default=start),
            "video_tracks": tracks, "valid_spherical_metadata": bool(tracks) and all(track["valid"] for track in tracks),
            "youtube_verified": False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    writer = sub.add_parser("inject")
    writer.add_argument("source")
    writer.add_argument("destination")
    writer.add_argument("--version", choices=["v1", "v2", "both"], default="both")
    reader = sub.add_parser("inspect")
    reader.add_argument("file")
    args = parser.parse_args()
    report = inject(args.source, args.destination, args.version) if args.command == "inject" else inspect(args.file)
    print(json.dumps(report, indent=2))
    if args.command == "inspect" and not report["valid_spherical_metadata"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
