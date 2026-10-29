"""Synthetic MP4 fixtures and real FFmpeg faststart/media-preservation checks."""
from pathlib import Path
import importlib.util
import shutil
import struct
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("spatial_metadata", ROOT / "tools/spatial_metadata.py")
spatial = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(spatial)


def fixture(offset=32, offset_kind=b"stco", video=True):
    handler = spatial.box(b"hdlr", b"\0" * 8 + (b"vide" if video else b"soun") + b"\0" * 12)
    entry = spatial.box(b"avc1", b"\0" * 78 + spatial.box(b"avcC", b"test"))
    description = spatial.box(b"stsd", b"\0" * 4 + struct.pack(">I", 1) + entry)
    offsets = spatial.box(offset_kind, b"\0" * 4 + struct.pack(">I", 1)
                          + struct.pack(">Q" if offset_kind == b"co64" else ">I", offset))
    table = spatial.box(b"stbl", description + offsets)
    return spatial.box(b"moov", spatial.box(b"trak", spatial.box(b"mdia", handler + spatial.box(b"minf", table))))


def find_offsets(data):
    found = []
    for kind, body, _ in spatial.atoms(data):
        if kind in spatial.CONTAINERS:
            found.extend(find_offsets(body))
        if kind in {b"stco", b"co64"}:
            width = 4 if kind == b"stco" else 8
            found.extend(struct.unpack(">I" if width == 4 else ">Q", body[i:i + width])[0]
                         for i in range(8, len(body), width))
    return found


class SpatialMetadataTests(unittest.TestCase):
    def setUp(self):
        temporary_root = ROOT / "tests/.tmp"
        temporary_root.mkdir(exist_ok=True)
        self.temporary = tempfile.TemporaryDirectory(dir=temporary_root)
        self.folder = Path(self.temporary.name)

    def tearDown(self):
        self.temporary.cleanup()

    def test_v1_v2_and_both_roundtrip(self):
        for version in ("v1", "v2", "both"):
            source = self.folder / f"{version}.mp4"
            source.write_bytes(spatial.box(b"ftyp", b"isom\0\0\0\0") + spatial.box(b"mdat", b"unchanged samples") + fixture())
            output = self.folder / f"{version}-360.mp4"
            report = spatial.inject(source, output, version)
            track = report["video_tracks"][0]
            self.assertTrue(track["valid"])
            self.assertEqual(track["valid_v1"], version in {"v1", "both"})
            self.assertEqual(track["valid_v2"], version in {"v2", "both"})
            self.assertIn(b"unchanged samples", output.read_bytes())
            self.assertEqual(find_offsets(source.read_bytes()), find_offsets(output.read_bytes()))

    def test_faststart_adjusts_offsets(self):
        prefix = spatial.box(b"ftyp", b"isom\0\0\0\0")
        movie = fixture()
        original_offset = len(prefix) + len(movie) + 8
        source = self.folder / "faststart.mp4"
        source.write_bytes(prefix + fixture(original_offset) + spatial.box(b"mdat", b"media"))
        output = self.folder / "faststart-360.mp4"
        report = spatial.inject(source, output)
        self.assertTrue(report["faststart"])
        self.assertEqual(find_offsets(output.read_bytes()), [original_offset + report["moov_growth_bytes"]])

    def test_offsets_before_moov_do_not_move(self):
        source = self.folder / "end.mp4"
        source.write_bytes(spatial.box(b"mdat", b"media") + fixture(8, b"co64"))
        output = self.folder / "end-360.mp4"
        spatial.inject(source, output)
        self.assertEqual(find_offsets(output.read_bytes()), [8])

    def test_stco_overflow_converts_to_co64(self):
        original = fixture(0xFFFFFFFE)
        _, body, extended = next(spatial.atoms(original))
        rebuilt = spatial._rewrite(b"moov", body, extended, "both", 1000, 500)
        self.assertEqual(find_offsets(rebuilt), [0xFFFFFFFE + 1000])
        self.assertIn(b"co64", rebuilt)

    def test_reinjection_replaces_instead_of_duplicating(self):
        source = self.folder / "plain.mp4"
        source.write_bytes(spatial.box(b"mdat", b"media") + fixture())
        once, twice = self.folder / "once.mp4", self.folder / "twice.mp4"
        spatial.inject(source, once)
        spatial.inject(once, twice)
        self.assertEqual(once.read_bytes(), twice.read_bytes())

    def test_rejects_overwrite_and_fragmented_and_truncation(self):
        source = self.folder / "bad.mp4"
        source.write_bytes(spatial.box(b"moof", b""))
        with self.assertRaises(spatial.MetadataError):
            spatial.inject(source, source)
        with self.assertRaises(spatial.MetadataError):
            spatial.inject(source, self.folder / "out.mp4")
        source.write_bytes(b"\0\0\0\xffmoovshort")
        with self.assertRaises(spatial.MetadataError):
            spatial.inspect(source)

    def test_extended_atom_and_zero_sized_final_atom(self):
        data = spatial.box(b"free", b"abc", extended=True) + struct.pack(">I4s", 0, b"free") + b"tail"
        self.assertEqual([(kind, body) for kind, body, _ in spatial.atoms(data)], [(b"free", b"abc"), (b"free", b"tail")])

    @unittest.skipUnless(shutil.which("ffmpeg") and shutil.which("ffprobe"), "FFmpeg is required for real media fixture")
    def test_real_faststart_and_end_moov_decode_identically(self):
        for faststart in (False, True):
            source = self.folder / f"real-{faststart}.mp4"
            command = ["ffmpeg", "-v", "error", "-f", "lavfi", "-i", "testsrc2=size=160x80:rate=30",
                       "-f", "lavfi", "-i", "sine=frequency=440:sample_rate=48000", "-t", "0.5",
                       "-c:v", "libx264", "-pix_fmt", "yuv420p", "-c:a", "aac"]
            if faststart:
                command += ["-movflags", "+faststart"]
            subprocess.run(command + [str(source)], check=True)
            output = self.folder / f"real-{faststart}-360.mp4"
            spatial.inject(source, output)
            def media_payload(path):
                return [body for kind, body, _ in spatial.atoms(path.read_bytes()) if kind == b"mdat"]
            self.assertEqual(media_payload(source), media_payload(output))
            def hashes(path):
                result = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-map", "0:v:0", "-f", "framemd5", "-"],
                                        check=True, text=True, capture_output=True)
                return [line for line in result.stdout.splitlines() if not line.startswith("#")]
            self.assertEqual(hashes(source), hashes(output))
            result = subprocess.run(["ffprobe", "-v", "error", "-show_streams", "-of", "json", str(output)],
                                    check=True, text=True, capture_output=True)
            self.assertIn("spherical", result.stdout.lower())


if __name__ == "__main__":
    unittest.main()
