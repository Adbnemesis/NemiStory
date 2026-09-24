#!/usr/bin/env python3
"""
render_ep05_master.py
Single-Pass Full Episode Render for NEMI — Episode 05: "WHAT IS GOING ON WITH YOUTUBE?"

Strategy:
  Instead of rendering 10 beats individually and assembling, this script renders
  the entire episode in ONE Godot MovieWriter pass using EP05_Celebration.tscn
  (the master controller that already sequences all 10 beats internally).

  Then it muxes the result with the master audio track via FFmpeg.

Output:
  - 1080p (1920x1080) @ 30 FPS
  - H.264 CRF 18 + AAC 192k
  - Total: ~92.45 seconds
"""

import os
import sys
import subprocess
import time

EP05_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE_DIR = os.path.abspath(os.path.join(EP05_DIR, "..", "..", ".."))
GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

RENDERS_DIR = os.path.join(EP05_DIR, "renders")
PREVIEWS_DIR = os.path.join(EP05_DIR, "previews")

MASTER_SCENE = "res://nemi/episodes/ep05_celebration/EP05_Celebration.tscn"
SFX_MASTER_AUDIO = os.path.join(EP05_DIR, "audio", "EP05_audio_sfx_master.wav")
VOICE_AUDIO = os.path.join(EP05_DIR, "audio", "EP05_voice_v2.wav")
MASTER_AUDIO = SFX_MASTER_AUDIO if os.path.exists(SFX_MASTER_AUDIO) else VOICE_AUDIO

import argparse

RAW_AVI = "/tmp/ep05_full_master.avi"
TOTAL_DURATION = 92.45


def step(msg):
    print(f"\n{'='*64}")
    print(f"  {msg}")
    print(f"{'='*64}", flush=True)


def main():
    parser = argparse.ArgumentParser(description="Render EP05 Master Video")
    parser.add_argument("--quality", choices=["1080p", "4k"], default="4k", help="Render resolution (default: 4k)")
    args = parser.parse_args()

    is_4k = (args.quality == "4k")
    resolution = "3840x2160" if is_4k else "1920x1080"
    output_filename = "EP05_What_Is_Going_On_With_YouTube_4K_Master.mp4" if is_4k else "EP05_What_Is_Going_On_With_YouTube_1080p_Master.mp4"
    final_output = os.path.join(RENDERS_DIR, output_filename)
    crf = "16" if is_4k else "18"
    audio_bitrate = "320k" if is_4k else "192k"

    os.makedirs(RENDERS_DIR, exist_ok=True)

    # -------------------------------------------------------------------------
    # STEP 1: Subtitle Audit
    # -------------------------------------------------------------------------
    step("STEP 1: SUBTITLE WORD-COUNT AUDIT (strict <= 5 words)")
    import re
    sub_gd_path = os.path.join(EP05_DIR, "Episode05Subtitles.gd")
    with open(sub_gd_path, "r", encoding="utf-8") as f:
        content = f.read()

    cards = re.findall(r'\{"text":\s*"([^"]+)"', content)
    max_words = max(len(c.split()) for c in cards) if cards else 0
    violations = [(c, len(c.split())) for c in cards if len(c.split()) > 5]

    print(f"  Total subtitle cards: {len(cards)}")
    print(f"  Max word count: {max_words}")
    if violations:
        print(f"  ❌ FAILED: {len(violations)} cards exceed 5 words!")
        for v in violations:
            print(f"     - '{v[0]}' ({v[1]} words)")
        sys.exit(1)
    print(f"  ✓ PASSED: All {len(cards)} cards <= 5 words.")

    # -------------------------------------------------------------------------
    # STEP 2: Full Episode Render via Godot MovieWriter
    # -------------------------------------------------------------------------
    step("STEP 2: RENDERING FULL EPISODE (Single-Pass MovieWriter)")
    print(f"  Scene: {MASTER_SCENE}")
    print(f"  Output: {RAW_AVI}")
    print(f"  Expected: ~{TOTAL_DURATION}s @ 30 FPS = ~{int(TOTAL_DURATION * 30)} frames")

    if os.path.exists(RAW_AVI):
        os.remove(RAW_AVI)

    cmd_godot = [
        GODOT_BIN,
        "--path", BASE_DIR,
        "--write-movie", RAW_AVI,
        "--fixed-fps", "30",
        "--resolution", resolution,
        MASTER_SCENE
    ]

    print(f"\n  Command: {' '.join(cmd_godot)}\n")

    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0

    print(f"  Godot exit code: {res.returncode} ({dt:.1f}s)")

    if res.returncode != 0:
        print(f"  STDERR:\n{res.stderr[-2000:]}")

    if not os.path.exists(RAW_AVI):
        print(f"  ❌ FATAL: Raw AVI not created!")
        sys.exit(1)

    raw_size_mb = os.path.getsize(RAW_AVI) / (1024 * 1024)
    print(f"  ✓ Raw AVI: {raw_size_mb:.1f} MB")

    # Probe raw AVI to check frame count and duration
    probe_cmd = [
        FFMPEG_BIN, "-i", RAW_AVI,
        "-map", "0:v:0",
        "-c", "copy",
        "-f", "null", "-"
    ]
    probe_res = subprocess.run(probe_cmd, capture_output=True, text=True)
    # Extract frame count from stderr
    for line in probe_res.stderr.split('\n'):
        if 'frame=' in line:
            print(f"  Raw AVI stats: {line.strip()}")

    # -------------------------------------------------------------------------
    # STEP 3: Transcode to H.264 MP4 + Mux Master Audio
    # -------------------------------------------------------------------------
    step("STEP 3: TRANSCODE + MUX AUDIO")
    print(f"  Audio: {os.path.basename(MASTER_AUDIO)}")
    print(f"  Output: {final_output}")
    print(f"  Resolution: {resolution} | CRF: {crf} | Audio Bitrate: {audio_bitrate}")

    # Remove old broken file
    if os.path.exists(final_output):
        os.remove(final_output)

    cmd_ffmpeg = [
        FFMPEG_BIN, "-y",
        "-i", RAW_AVI,
        "-i", MASTER_AUDIO,
        "-map", "0:v",
        "-map", "1:a",
        "-c:v", "libx264", "-crf", crf, "-preset", "slow",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", audio_bitrate,
        "-t", f"{TOTAL_DURATION:.2f}",
        "-movflags", "+faststart",
        final_output
    ]

    t1 = time.time()
    res_ff = subprocess.run(cmd_ffmpeg, capture_output=True, text=True)
    dt_ff = time.time() - t1

    # Clean up raw AVI
    if os.path.exists(RAW_AVI):
        os.remove(RAW_AVI)

    if res_ff.returncode != 0 or not os.path.exists(final_output):
        print(f"  ❌ FFmpeg failed:\n{res_ff.stderr[-2000:]}")
        sys.exit(1)

    final_size_mb = os.path.getsize(final_output) / (1024 * 1024)
    print(f"  ✓ MASTER MP4: {final_size_mb:.2f} MB ({dt_ff:.1f}s)")

    # -------------------------------------------------------------------------
    # STEP 4: Verification — Extract Audit Frames
    # -------------------------------------------------------------------------
    step("STEP 4: EXTRACT AUDIT FRAMES")
    audit_dir = os.path.join(PREVIEWS_DIR, "audit_frames_v2")
    os.makedirs(audit_dir, exist_ok=True)

    audit_points = [
        ("01_b01_freeze_shock.png",         "00:00:08.50"),
        ("02_b02_seven_views.png",          "00:00:15.50"),
        ("03_b02_phone_blush.png",          "00:00:19.50"),
        ("04_b03_counter_climb.png",        "00:00:29.00"),
        ("05_b03_counter_999.png",          "00:00:32.50"),
        ("06_b04_explosion_1000.png",       "00:00:35.80"),
        ("07_b04_recoil.png",               "00:00:38.50"),
        ("08_b05_tiny_crowd.png",           "00:00:53.60"),
        ("09_b06_comments.png",             "00:01:00.00"),
        ("10_b07_gratitude.png",            "00:01:10.00"),
        ("11_b08_instagram.png",            "00:01:15.50"),
        ("12_b09_creator.png",              "00:01:21.00"),
        ("13_b10_signoff.png",              "00:01:27.50"),
        ("14_b10_wave.png",                 "00:01:31.00"),
    ]

    for fname, ts in audit_points:
        out_png = os.path.join(audit_dir, fname)
        subprocess.run([
            FFMPEG_BIN, "-y", "-ss", ts,
            "-i", final_output,
            "-vframes", "1", "-q:v", "2",
            out_png
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if os.path.exists(out_png):
            print(f"  ✓ [{ts}] {fname}")

    # -------------------------------------------------------------------------
    # STEP 5: Frame Uniqueness Verification
    # -------------------------------------------------------------------------
    step("STEP 5: FRAME UNIQUENESS CHECK (Freeze Detection)")
    import hashlib
    hashes = {}
    for fname, ts in audit_points:
        fpath = os.path.join(audit_dir, fname)
        if os.path.exists(fpath):
            with open(fpath, "rb") as f:
                h = hashlib.md5(f.read()).hexdigest()
            hashes[fname] = h

    unique = len(set(hashes.values()))
    total = len(hashes)
    print(f"  Extracted {total} frames, {unique} unique hashes")

    if unique < total * 0.7:
        print(f"  ⚠️ WARNING: Only {unique}/{total} unique frames — possible freeze detected!")
    else:
        print(f"  ✓ PASSED: {unique}/{total} unique — no freeze detected.")

    # -------------------------------------------------------------------------
    # DONE
    # -------------------------------------------------------------------------
    step("NEMI EPISODE 05 — SINGLE-PASS RENDER COMPLETE")
    print(f"  Master File: {final_output}")
    print(f"  Size:         {final_size_mb:.2f} MB")
    print(f"  Duration:     {TOTAL_DURATION}s")
    print(f"  Resolution:   {resolution} @ 30 FPS")
    print(f"  Audit Frames: {audit_dir}")


if __name__ == "__main__":
    main()
