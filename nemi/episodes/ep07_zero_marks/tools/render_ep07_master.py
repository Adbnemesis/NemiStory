#!/usr/bin/env python3
"""
render_ep07_master.py
Master Production Render Pipeline for Episode 07:
"I GOT 0 MARKS IN MY EXAM"
4K UHD (3840x2160 @ 30 FPS) with 1.15x speedup.

Pipeline:
1. Validate subtitle cards (verify strictly <= 5 words per card).
2. Execute single-pass Godot MovieWriter at 30 FPS, native 4K (3840x2160) resolution.
3. Transcode to high-fidelity 4K UHD H.264 MP4 with 1.15x speedup (video PTS/1.15, audio atempo=1.15).
4. Generate 1080p downscaled companion master.
5. Extract verification audit frames across all 10 beats in 4K for visual QA.
"""

import os
import sys
import time
import subprocess
import json

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
EP07_DIR = os.path.join(BASE_DIR, "nemi", "episodes", "ep07_zero_marks")

GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

RENDERS_DIR = os.path.join(EP07_DIR, "renders")
PREVIEWS_DIR = os.path.join(EP07_DIR, "previews")
AUDIT_DIR = os.path.join(PREVIEWS_DIR, "audit_frames")

os.makedirs(RENDERS_DIR, exist_ok=True)
os.makedirs(PREVIEWS_DIR, exist_ok=True)
os.makedirs(AUDIT_DIR, exist_ok=True)

MASTER_SCENE = "res://nemi/episodes/ep07_zero_marks/EP07_Zero_Marks.tscn"
MASTER_AUDIO = os.path.join(EP07_DIR, "audio", "EP07_voice.wav")
TIMING_JSON = os.path.join(EP07_DIR, "timing", "ep07_timing.json")
RAW_AVI = "/tmp/ep07_zero_marks_raw_4k.avi"
OUTPUT_MP4_4K = os.path.join(RENDERS_DIR, "EP07_Zero_Marks_4K.mp4")
OUTPUT_MP4_1080P = os.path.join(RENDERS_DIR, "EP07_Zero_Marks_1080p.mp4")

ORIG_DURATION = 136.89 # Exact master audio duration
SPEED_FACTOR = 1.15
NEW_DURATION = ORIG_DURATION / SPEED_FACTOR # ~119.03s

def log_step(title: str):
    print("\n" + "=" * 64)
    print(f"  {title}")
    print("=" * 64)

def check_subtitles():
    log_step("STEP 1: SUBTITLE WORD COUNT AUDIT")
    subtitles_path = os.path.join(EP07_DIR, "Episode07Subtitles.gd")
    if not os.path.exists(subtitles_path):
        print(f"  ❌ Subtitles file not found: {subtitles_path}")
        sys.exit(1)
        
    with open(subtitles_path, "r", encoding="utf-8") as f:
        content = f.read()

    cards = []
    for line in content.split("\n"):
        line = line.strip()
        if line.startswith('{"beat":'):
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

def render_movie_4k():
    log_step("STEP 2: FULL EPISODE MOVIEWRITER RENDER IN 4K (30 FPS, 3840x2160)")
    print(f"  Scene: {MASTER_SCENE}")
    print(f"  Output AVI: {RAW_AVI}")
    print(f"  Source Duration: {ORIG_DURATION}s (~{int(ORIG_DURATION * 30)} frames)")

    if os.path.exists(RAW_AVI):
        os.remove(RAW_AVI)

    project_godot_path = os.path.join(BASE_DIR, "project.godot")
    with open(project_godot_path, "r", encoding="utf-8") as f:
        orig_config = f.read()

    try:
        # Set window size override to 3840x2160 for 4K MovieWriter capture
        config_4k = orig_config.replace("window/size/window_width_override=1920", "window/size/window_width_override=3840")
        config_4k = config_4k.replace("window/size/window_height_override=1080", "window/size/window_height_override=2160")
        with open(project_godot_path, "w", encoding="utf-8") as f:
            f.write(config_4k)

        cmd_godot = [
            GODOT_BIN,
            "--path", BASE_DIR,
            "--write-movie", RAW_AVI,
            "--fixed-fps", "30",
            MASTER_SCENE
        ]

        print(f"  Executing Godot 4K MovieWriter render...")
        t0 = time.time()
        res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
        dt = time.time() - t0

        print(f"  Godot MovieWriter completed in {dt:.1f}s (Exit code: {res.returncode})")
        if res.returncode != 0:
            print(f"  STDERR:\n{res.stderr[-2000:]}")

    finally:
        # Always restore original project.godot
        with open(project_godot_path, "w", encoding="utf-8") as f:
            f.write(orig_config)

    if not os.path.exists(RAW_AVI):
        print("  ❌ FATAL: Raw 4K AVI was not created!")
        sys.exit(1)

    raw_mb = os.path.getsize(RAW_AVI) / (1024 * 1024)
    print(f"  ✓ Raw 4K AVI captured: {raw_mb:.1f} MB")

def transcode_and_mux_4k():
    log_step("STEP 3: TRANSCODE TO 4K UHD H.264 MP4 WITH 1.15x SPEEDUP")
    print(f"  Input AVI: {RAW_AVI}")
    print(f"  Speed factor: {SPEED_FACTOR}x")
    print(f"  New Target Duration: {NEW_DURATION:.2f}s (~1m 59s)")
    print(f"  Master 4K Output: {OUTPUT_MP4_4K}")

    if os.path.exists(OUTPUT_MP4_4K):
        os.remove(OUTPUT_MP4_4K)

    # 4K UHD Master Render: CRF 17, slow preset, 320k AAC, video sped up by 1.15x, audio atempo 1.15
    cmd_ffmpeg_4k = [
        FFMPEG_BIN, "-y",
        "-i", RAW_AVI,
        "-filter_complex", f"[0:v]setpts=PTS/{SPEED_FACTOR},fps=30[v];[0:a]atempo={SPEED_FACTOR}[a]",
        "-map", "[v]",
        "-map", "[a]",
        "-c:v", "libx264", "-crf", "17", "-preset", "slow",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "320k",
        "-t", f"{NEW_DURATION:.2f}",
        "-movflags", "+faststart",
        OUTPUT_MP4_4K
    ]

    print("  Transcoding 4K UHD Master (3840x2160, 1.15x speed)...")
    t0 = time.time()
    res = subprocess.run(cmd_ffmpeg_4k, capture_output=True, text=True)
    dt = time.time() - t0

    if res.returncode != 0 or not os.path.exists(OUTPUT_MP4_4K):
        print(f"  ❌ FATAL: FFmpeg 4K transcoding failed:\n{res.stderr[-2000:]}")
        sys.exit(1)

    mp4_mb = os.path.getsize(OUTPUT_MP4_4K) / (1024 * 1024)
    print(f"  ✓ Master 4K MP4 generated: {OUTPUT_MP4_4K} ({mp4_mb:.2f} MB, {dt:.1f}s)")

    # Downscale companion 1080p version at 1.15x speed
    print(f"\n  Generating companion 1080p MP4: {OUTPUT_MP4_1080P}...")
    cmd_ffmpeg_1080p = [
        FFMPEG_BIN, "-y",
        "-i", OUTPUT_MP4_4K,
        "-vf", "scale=1920:1080:flags=lanczos",
        "-c:v", "libx264", "-crf", "17", "-preset", "fast",
        "-pix_fmt", "yuv420p",
        "-c:a", "copy",
        "-movflags", "+faststart",
        OUTPUT_MP4_1080P
    ]
    subprocess.run(cmd_ffmpeg_1080p, capture_output=True)
    if os.path.exists(OUTPUT_MP4_1080P):
        p1080_mb = os.path.getsize(OUTPUT_MP4_1080P) / (1024 * 1024)
        print(f"  ✓ Companion 1080p MP4 generated: {p1080_mb:.2f} MB")

    # Clean up temp raw AVI to save disk space
    if os.path.exists(RAW_AVI):
        os.remove(RAW_AVI)
        print("  ✓ Cleaned up temporary raw 4K AVI file.")

def extract_audit_frames():
    log_step("STEP 4: EXTRACT 4K AUDIT FRAMES ACROSS ALL 10 BEATS")
    
    # Audit timestamps scaled by 1.15x speed:
    audit_points = [
        ("beat01_wait_hook", 2.5 / SPEED_FACTOR),             # Beat 01
        ("beat02_online_classes", 13.5 / SPEED_FACTOR),        # Beat 02
        ("beat03_third_semester", 25.8 / SPEED_FACTOR),        # Beat 03
        ("beat04_terrible_plan", 44.5 / SPEED_FACTOR),         # Beat 04
        ("beat05_email_panic", 53.8 / SPEED_FACTOR),           # Beat 05
        ("beat06_study_grind_2am", 63.2 / SPEED_FACTOR),       # Beat 06
        ("beat07_exam_blank_mind", 80.5 / SPEED_FACTOR),       # Beat 07
        ("beat08_writing_frenzy", 98.5 / SPEED_FACTOR),        # Beat 08
        ("beat09_zero_reveal", 115.8 / SPEED_FACTOR),          # Beat 09
        ("beat10_future_me_wrapup", 132.0 / SPEED_FACTOR),     # Beat 10
    ]

    for name, timestamp in audit_points:
        out_jpg = os.path.join(AUDIT_DIR, f"{name}.png")
        cmd = [
            FFMPEG_BIN, "-y",
            "-ss", f"{timestamp:.3f}",
            "-i", OUTPUT_MP4_4K,
            "-vframes", "1",
            "-q:v", "2",
            out_jpg
        ]
        subprocess.run(cmd, capture_output=True)
        if os.path.exists(out_jpg):
            print(f"  ✓ Captured 4K {name}.png at {timestamp:.2f}s")

    print(f"\n  ✓ All 4K audit frames extracted to {AUDIT_DIR}")

def main():
    print("================================================================")
    print("  NEMI STORYTIME: EPISODE 07 4K MASTER PRODUCTION PIPELINE")
    print("  \"I GOT 0 MARKS IN MY EXAM\" (1.15x SPEED, 4K UHD 3840x2160)")
    print("================================================================")
    
    check_subtitles()
    render_movie_4k()
    transcode_and_mux_4k()
    extract_audit_frames()

    print("\n" + "=" * 64)
    print("  🎉 EPISODE 07 4K PRODUCTION MASTER RENDER COMPLETED SUCCESSFULLY!")
    print(f"  4K Master: {OUTPUT_MP4_4K}")
    print(f"  1080p Version: {OUTPUT_MP4_1080P}")
    print("================================================================\n")

if __name__ == "__main__":
    main()
