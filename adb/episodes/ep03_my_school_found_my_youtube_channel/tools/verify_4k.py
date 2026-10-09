#!/usr/bin/env python3
"""Read-only comparison of the resolution-only EP03 final against approved R4."""
import hashlib
import json
import math
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[4]
EPISODE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools/storytime"))
from render_approval import render_inputs_sha256

PREFIX = "ADB_EP03_My_School_Found_My_YouTube_Channel_r4"
APPROVED = EPISODE / "renders" / f"{PREFIX}_1080p_REVIEW.mp4"
FINAL = EPISODE / "renders" / f"{PREFIX}_4K_FINAL.mp4"
SPEC = EPISODE / "scene_r4_1080p.json"
REPORT = EPISODE / "review/FINAL_4K_QA.json"


def sha(path):
    digest = hashlib.sha256()
    with Path(path).open("rb") as source:
        for chunk in iter(lambda: source.read(8 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def run(args):
    result = subprocess.run(args, capture_output=True, check=True)
    return result.stdout, result.stderr


def audio_hash(path, decoded=False):
    codec = ["-acodec", "pcm_s16le"] if decoded else ["-c:a", "copy"]
    output, _ = run([
        "ffmpeg", "-v", "error", "-i", str(path), "-map", "0:a:0",
        *codec, "-f", "hash", "-hash", "sha256", "-",
    ])
    return output.decode().strip().split("=", 1)[1]


def frame(path, time):
    output, _ = run([
        "ffmpeg", "-v", "error", "-threads", "1", "-ss", f"{time:.9f}",
        "-i", str(path), "-frames:v", "1", "-vf", "scale=1920:1080:flags=lanczos",
        "-pix_fmt", "rgb24", "-f", "rawvideo", "-",
    ])
    return np.frombuffer(output, dtype=np.uint8).reshape(1080, 1920, 3)


def block_ssim(first, second):
    # Luminance SSIM over 8x8 blocks. Encoding and high-resolution rasterization
    # have edge differences, so this is an image-comparison measure, not identity.
    weights = np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
    a = (first.astype(np.float32) @ weights).reshape(135, 8, 240, 8).transpose(0, 2, 1, 3)
    b = (second.astype(np.float32) @ weights).reshape(135, 8, 240, 8).transpose(0, 2, 1, 3)
    mean_a, mean_b = a.mean((2, 3)), b.mean((2, 3))
    var_a, var_b = a.var((2, 3)), b.var((2, 3))
    covariance = ((a - mean_a[..., None, None]) * (b - mean_b[..., None, None])).mean((2, 3))
    c1, c2 = (0.01 * 255) ** 2, (0.03 * 255) ** 2
    return float((((2 * mean_a * mean_b + c1) * (2 * covariance + c2)) /
                  ((mean_a ** 2 + mean_b ** 2 + c1) * (var_a + var_b + c2))).mean())


def audio_tail(path):
    output, _ = run([
        "ffmpeg", "-v", "error", "-ss", "146.4", "-i", str(path),
        "-map", "0:a:0", "-t", "1", "-acodec", "pcm_f32le", "-f", "f32le", "-",
    ])
    values = np.frombuffer(output, dtype="<f4")
    peak = float(np.max(np.abs(values)))
    rms = float(np.sqrt(np.mean(values.astype(np.float64) ** 2)))
    return {"start_seconds": 146.4, "duration_seconds": 1,
            "peak_dbfs": 20 * math.log10(max(peak, 1e-12)),
            "rms_dbfs": 20 * math.log10(max(rms, 1e-12))}


def load_stamp(path):
    for stamp in [path.with_suffix(".review_stamp.json"),
                  EPISODE / "review/render_records" / path.with_suffix(".review_stamp.json").name]:
        if stamp.is_file():
            return json.loads(stamp.read_text()), stamp
    raise FileNotFoundError(f"No render stamp for {path}")


def main():
    if not FINAL.is_file() or not APPROVED.is_file():
        raise SystemExit("Both final and approved movies must exist before comparison.")
    report = {"created_at_utc": datetime.now(timezone.utc).isoformat(),
              "scope": "Resolution-only 4K export of the user-approved full R4 cut",
              "final": str(FINAL.relative_to(ROOT)),
              "approved_preview": str(APPROVED.relative_to(ROOT)),
              "subjective_listening_performed": False,
              "full_4k_playback_review_performed": False,
              "visual_sample_inspection": "Recorded separately by root reviewer; this report performs quantitative comparisons.",
              "checks": {}}
    metadata, decode_stderr = run([
        "ffprobe", "-v", "error", "-count_frames", "-show_entries",
        "stream=codec_type,codec_name,width,height,r_frame_rate,nb_read_frames,sample_rate,channels:format=duration,size",
        "-of", "json", str(FINAL),
    ])
    report["metadata"] = json.loads(metadata)
    report["frame_decode_stderr"] = decode_stderr.decode()
    video = next(x for x in report["metadata"]["streams"] if x["codec_type"] == "video")
    audio = next(x for x in report["metadata"]["streams"] if x["codec_type"] == "audio")
    checks = report["checks"]
    checks["resolution"] = (video["width"], video["height"]) == (3840, 2160)
    checks["fps"] = video["r_frame_rate"] == "30/1"
    checks["decoded_frame_count"] = int(video["nb_read_frames"]) == 4422
    checks["duration"] = abs(float(report["metadata"]["format"]["duration"]) - 147.4) < 0.001
    checks["under_runtime_cap"] = float(report["metadata"]["format"]["duration"]) <= 180
    checks["decode_clean"] = not decode_stderr.strip()
    checks["audio_format"] = audio["codec_name"] == "aac" and audio["channels"] == 2
    stamp, stamp_path = load_stamp(FINAL)
    approved_stamp, approved_stamp_path = load_stamp(APPROVED)
    receipt = json.loads((EPISODE / "review/1080P_APPROVAL.json").read_text())
    current_spec_hash = sha(SPEC)
    current_input_hash = render_inputs_sha256(SPEC, ROOT)
    report["source_binding"] = {"spec_sha256": current_spec_hash,
                                "render_inputs_sha256": current_input_hash,
                                "final_stamp": str(stamp_path.relative_to(ROOT)),
                                "approved_stamp": str(approved_stamp_path.relative_to(ROOT)),
                                "final_stamp_data": stamp,
                                "approved_stamp_data": approved_stamp,
                                "user_quote": receipt["user_quote"]}
    checks["scene_hash_unchanged"] = current_spec_hash == approved_stamp["spec_sha256"] == stamp["spec_sha256"] == receipt["spec_sha256"]
    checks["input_signature_unchanged"] = current_input_hash == approved_stamp["render_inputs_sha256"] == stamp["render_inputs_sha256"] == receipt["render_inputs_sha256"]
    report["approved_preview_sha256"] = sha(APPROVED)
    report["final_sha256"] = sha(FINAL)
    checks["preview_hash_matches_approval"] = report["approved_preview_sha256"] == approved_stamp["preview_sha256"] == receipt["preview_sha256"]
    checks["final_hash_matches_stamp"] = report["final_sha256"] == stamp["preview_sha256"]
    checks["full_stamp_range"] = stamp["start"] == 0 and stamp["duration"] == 147.4 and stamp["resolution"] == [3840, 2160]
    report["audio_stream_sha256"] = {"approved": audio_hash(APPROVED), "final": audio_hash(FINAL)}
    checks["encoded_audio_identical"] = report["audio_stream_sha256"]["approved"] == report["audio_stream_sha256"]["final"]
    report["decoded_audio_sha256"] = {"approved": audio_hash(APPROVED, True), "final": audio_hash(FINAL, True)}
    checks["decoded_audio_identical"] = report["decoded_audio_sha256"]["approved"] == report["decoded_audio_sha256"]["final"]
    _, level_log = run(["ffmpeg", "-hide_banner", "-i", str(FINAL), "-map", "0:a:0",
                        "-af", "ebur128=peak=true", "-f", "null", "-"])
    log = level_log.decode()
    summary = log.rsplit("Summary:", 1)[1]
    integrated = float(re.search(r"I:\s*([-\d.]+) LUFS", summary)[1])
    peak = float(re.search(r"Peak:\s*([-\d.]+) dBFS", summary)[1])
    report["encoded_audio_levels"] = {"integrated_lufs": integrated, "true_peak_dbfs": peak}
    checks["true_peak_at_most_minus_1"] = peak <= -1
    report["audio_final_second"] = {"approved": audio_tail(APPROVED), "final": audio_tail(FINAL)}
    checks["final_silence_matches_approved"] = report["audio_final_second"]["approved"] == report["audio_final_second"]["final"]
    baseline = json.loads((EPISODE / "review/protected_sources_before.json").read_text())["files"]
    changed = [p for p, digest in baseline.items() if sha(ROOT / p) != digest]
    report["protected_sources"] = {"count": len(baseline), "changed": changed}
    checks["protected_sources_unchanged"] = not changed and len(baseline) == 74
    times = [0, 0.8, 14.4, 24.7, 31.9, 40.8, 50.6, 60.3, 67.9, 70.2, 74.3,
             80.5, 90.0, 99.0, 107.3, 111.4, 117.2, 127.2, 135.9, 138.7, 146.7,
             4421 / 30]
    samples = []
    for time in times:
        first, second = frame(APPROVED, time), frame(FINAL, time)
        difference = np.abs(first.astype(np.float32) - second.astype(np.float32))
        samples.append({"requested_time_seconds": time,
                        "mean_absolute_rgb_error_0_255": float(difference.mean()),
                        "rgb_rmse_0_255": float(np.sqrt(np.mean(difference ** 2))),
                        "fraction_pixels_any_channel_difference_over_30": float(np.mean(np.max(difference, axis=2) > 30)),
                        "luminance_block_ssim": block_ssim(first, second)})
    report["picture_comparison"] = {"method": "Exact clock samples; 4K Lanczos downscaled to 1920x1080; raw RGB comparison to approved 1080p.",
                                    "interpretation": "Small rasterization/codec edge differences are expected; unchanged scene/input signatures bind the authored picture.",
                                    "sample_count": len(samples), "samples": samples}
    checks["picture_samples_similar"] = all(s["mean_absolute_rgb_error_0_255"] <= 5 and s["fraction_pixels_any_channel_difference_over_30"] <= 0.025 and s["luminance_block_ssim"] >= 0.97 for s in samples)
    report["all_performed_checks_pass"] = all(checks.values())
    REPORT.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"report": str(REPORT), "checks": checks,
                      "picture_summary": {"max_mae": max(s["mean_absolute_rgb_error_0_255"] for s in samples),
                                          "max_changed_fraction": max(s["fraction_pixels_any_channel_difference_over_30"] for s in samples),
                                          "minimum_block_ssim": min(s["luminance_block_ssim"] for s in samples)},
                      "encoded_audio_levels": report["encoded_audio_levels"]}, indent=2))
    return 0 if report["all_performed_checks_pass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
