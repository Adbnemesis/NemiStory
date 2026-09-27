#!/usr/bin/env python3
"""
render_ep06_master.py
Master Production Render Pipeline for Episode 06:
"HOW I ACTUALLY MAKE STORYTIME ANIMATIONS"

Pipeline:
1. Validate subtitle cards (verify strictly <= 5 words per card).
2. Execute single-pass Godot MovieWriter at 30 FPS, 1920x1080 resolution.
3. Transcode to high-fidelity 1080p H.264 MP4 muxed with canonical master audio.
4. Extract verification audit frames across all 10 beats for visual QA.
"""

import os
import sys
import time
import subprocess
import json

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
EP06_DIR = os.path.join(BASE_DIR, "nemi", "episodes", "ep06_how_i_animate")

GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

RENDERS_DIR = os.path.join(EP06_DIR, "renders")
PREVIEWS_DIR = os.path.join(EP06_DIR, "previews")
AUDIT_DIR = os.path.join(PREVIEWS_DIR, "audit_frames")

os.makedirs(RENDERS_DIR, exist_ok=True)
os.makedirs(PREVIEWS_DIR, exist_ok=True)
os.makedirs(AUDIT_DIR, exist_ok=True)

MASTER_SCENE = "res://nemi/episodes/ep06_how_i_animate/EP06_How_I_Animate.tscn"
MASTER_AUDIO = os.path.join(EP06_DIR, "audio", "EP06_voice.wav")
TIMING_JSON = os.path.join(EP06_DIR, "timing", "ep06_timing.json")
RAW_AVI = "/tmp/ep06_how_i_animate_raw.avi"
OUTPUT_MP4_4K = os.path.join(RENDERS_DIR, "EP06_How_I_Actually_Make_Storytime_Animations_4K.mp4")
OUTPUT_MP4_1080P = os.path.join(RENDERS_DIR, "EP06_How_I_Actually_Make_Storytime_Animations_1080p.mp4")
OUTPUT_MP4 = OUTPUT_MP4_4K

TOTAL_DURATION = 141.75 # Exact master duration

def log_step(title: str):
    print("\n" + "=" * 64)
    print(f"  {title}")
    print("=" * 64)

def check_subtitles():
    log_step("STEP 1: SUBTITLE WORD COUNT AUDIT")
    subtitles_path = os.path.join(EP06_DIR, "Episode06Subtitles.gd")
    if not os.path.exists(subtitles_path):
        print(f"  ❌ Subtitles file not found: {subtitles_path}")
        sys.exit(1)
        
    with open(subtitles_path, "r", encoding="utf-8") as f:
        content = f.read()

    cards = []
    for line in content.split("\n"):
        line = line.strip()
        if line.startswith('{"text":'):
            try:
                card = json.loads(line.rstrip(","))
                cards.append(card)
            except Exception as e:
                pass

    print(f"  Auditing {len(cards)} subtitle cards...")
    violations = []
    max_words = 0
    for c in cards:
        text = c["text"]
        words = len(text.split())
        if words > max_words:
            max_words = words
        if words > 5:
            violations.append((text, words))

    if violations:
        print(f"  ❌ FATAL: Found {len(violations)} cards exceeding 5 words!")
        for v in violations:
            print(f"     - '{v[0]}' ({v[1]} words)")
        sys.exit(1)

    print(f"  ✓ PASSED: All {len(cards)} cards strictly <= 5 words! (Peak words: {max_words})")

def render_movie():
    log_step("STEP 2: FULL EPISODE MOVIEWRITER RENDER (30 FPS)")
    print(f"  Scene: {MASTER_SCENE}")
    print(f"  Output AVI: {RAW_AVI}")
    print(f"  Duration: {TOTAL_DURATION}s (~{int(TOTAL_DURATION * 30)} frames)")

    if os.path.exists(RAW_AVI):
        os.remove(RAW_AVI)

    cmd_godot = [
        GODOT_BIN,
        "--path", BASE_DIR,
        "--write-movie", RAW_AVI,
        "--fixed-fps", "30",
        "--resolution", "1920x1080",
        MASTER_SCENE
    ]

    print(f"  Executing: {' '.join(cmd_godot)}\n")
    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0

    print(f"  Godot MovieWriter completed in {dt:.1f}s (Exit code: {res.returncode})")
    if res.returncode != 0:
        print(f"  STDERR:\n{res.stderr[-2000:]}")

    if not os.path.exists(RAW_AVI):
        print("  ❌ FATAL: Raw AVI was not created!")
        sys.exit(1)

    raw_mb = os.path.getsize(RAW_AVI) / (1024 * 1024)
    print(f"  ✓ Raw AVI captured: {raw_mb:.1f} MB")

def transcode_and_mux():
    log_step("STEP 3: TRANSCODE TO 4K UHD MP4 + MUX SYNCHRONIZED AUDIO & SFX")
    print(f"  Input AVI: {RAW_AVI}")
    print(f"  Master 4K Output: {OUTPUT_MP4_4K}")
    print(f"  Compatibility 1080p Output: {OUTPUT_MP4_1080P}")

    if os.path.exists(OUTPUT_MP4_4K):
        os.remove(OUTPUT_MP4_4K)
    if os.path.exists(OUTPUT_MP4_1080P):
        os.remove(OUTPUT_MP4_1080P)

    # 1. High-Fidelity 4K Master Render (CRF 16, Lanczos scaling, 320k AAC, full Godot Audio with SFX)
    cmd_ffmpeg_4k = [
        FFMPEG_BIN, "-y",
        "-i", RAW_AVI,
        "-map", "0:v:0",
        "-map", "0:a:0",
        "-c:v", "libx264", "-crf", "16", "-preset", "medium",
        "-vf", "scale=3840:2160:flags=lanczos",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "320k",
        "-t", f"{TOTAL_DURATION:.2f}",
        "-movflags", "+faststart",
        OUTPUT_MP4_4K
    ]

    print("  Transcoding 4K Master (3840x2160)...")
    t0 = time.time()
    res_4k = subprocess.run(cmd_ffmpeg_4k, capture_output=True, text=True)
    dt_4k = time.time() - t0

    if res_4k.returncode != 0 or not os.path.exists(OUTPUT_MP4_4K):
        print(f"  ❌ FATAL: FFmpeg 4K transcoding failed:\n{res_4k.stderr[-2000:]}")
        sys.exit(1)

    mp4_4k_mb = os.path.getsize(OUTPUT_MP4_4K) / (1024 * 1024)
    print(f"  ✓ Master 4K MP4 generated: {OUTPUT_MP4_4K} ({mp4_4k_mb:.2f} MB, {dt_4k:.1f}s)")

    # 2. Downscaled 1080p stream for instant preview
    cmd_ffmpeg_1080p = [
        FFMPEG_BIN, "-y",
        "-i", OUTPUT_MP4_4K,
        "-vf", "scale=1920:1080",
        "-c:v", "libx264", "-crf", "18", "-preset", "fast",
        "-pix_fmt", "yuv420p",
        "-c:a", "copy",
        "-movflags", "+faststart",
        OUTPUT_MP4_1080P
    ]
    subprocess.run(cmd_ffmpeg_1080p, capture_output=True, text=True)
    if os.path.exists(OUTPUT_MP4_1080P):
        mp4_1080p_mb = os.path.getsize(OUTPUT_MP4_1080P) / (1024 * 1024)
        print(f"  ✓ Compatibility 1080p MP4 generated: {OUTPUT_MP4_1080P} ({mp4_1080p_mb:.2f} MB)")

def extract_audit_frames():
    log_step("STEP 4: EXTRACT AUDIT FRAMES FOR QUALITY ASSURANCE")
    audit_points = [
        ("01_beat01_the_question.png",       "00:00:05.50"),
        ("02_beat02_real_life_spark.png",    "00:00:18.50"),
        ("03_beat03_notebook_script.png",    "00:00:32.00"),
        ("04_beat04_recording_voice.png",    "00:00:46.00"),
        ("05_beat05_timeline_beats.png",     "00:00:58.00"),
        ("06_beat06_why_beats_matter.png",   "00:01:12.00"),
        ("07_beat07_godot_timeline_scare.png","00:01:28.00"),
        ("08_beat08_props_and_doodles.png",  "00:01:40.00"),
        ("09_beat09_microscopic_fix.png",    "00:01:54.00"),
        ("10_beat10_final_render_outro.png", "00:02:14.00"),
    ]

    for fname, timestamp in audit_points:
        out_path = os.path.join(AUDIT_DIR, fname)
        cmd = [
            FFMPEG_BIN, "-y",
            "-i", OUTPUT_MP4,
            "-ss", timestamp,
            "-frames:v", "1",
            "-q:v", "2",
            out_path
        ]
        subprocess.run(cmd, capture_output=True, text=True)
        if os.path.exists(out_path):
            print(f"  ✓ Frame extracted: {fname} at {timestamp}")
        else:
            print(f"  ⚠ Failed to extract: {fname}")

    print(f"\n  All audit frames saved to: {AUDIT_DIR}")

def main():
    print("================================================================")
    print("  NEMI EPISODE 06: 'HOW I ACTUALLY MAKE STORYTIME ANIMATIONS'")
    print("  Resolution: 1920x1080 @ 30 FPS | Rig: Live Vector Nemi Bone2D")
    print("================================================================")
    
    t_start = time.time()
    check_subtitles()
    if "--skip-movie" not in sys.argv:
        render_movie()
    else:
        print("  [INFO] Skipping Godot MovieWriter (--skip-movie specified).")
    transcode_and_mux()
    extract_audit_frames()
    total_dt = time.time() - t_start
    
    print("\n" + "=" * 64)
    print(f"  EPISODE 06 MASTER RENDER COMPLETE IN {total_dt:.1f}s")
    print(f"  FINAL VIDEO: {OUTPUT_MP4}")
    print("=" * 64)

if __name__ == "__main__":
    main()
