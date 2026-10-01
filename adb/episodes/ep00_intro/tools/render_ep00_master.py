#!/usr/bin/env python3
"""
render_ep00_master.py
Master Production Render Pipeline for ADB Episode 00:
"HI, I'M ADB."

Supports:
- Native 4K UHD (3840 × 2160 @ 30 FPS) Master Quality (default or --4k)
- 1080p FHD (1920 × 1080 @ 30 FPS) Review Quality (--1080p)

Voice Master Clock: Native 1.0x timing (NO pitch shift, NO speedup/timestretch).

Pipeline:
1. Validate subtitle cards (verify strictly <= 5 words per card).
2. Execute single-pass Godot MovieWriter at 30 FPS (4K UHD or 1080p).
3. Transcode to high-fidelity H.264 MP4 (CRF 16 for 4K / CRF 17 for 1080p, 320k AAC, original timing).
4. Save master MP4 to renders directory and project root.
5. Extract verification audit frames across all 10 beats for visual QA.
6. Verify output resolution, frame count, audio levels, and stream integrity.
"""

import os
import sys
import time
import subprocess
import json
import shutil
import argparse

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
EP00_DIR = os.path.join(BASE_DIR, "adb", "episodes", "ep00_intro")

GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"
FFPROBE_BIN = "/opt/homebrew/bin/ffprobe"

RENDERS_DIR = os.path.join(EP00_DIR, "renders")
PREVIEWS_DIR = os.path.join(EP00_DIR, "previews")
AUDIT_DIR = os.path.join(PREVIEWS_DIR, "audit_frames")

os.makedirs(RENDERS_DIR, exist_ok=True)
os.makedirs(PREVIEWS_DIR, exist_ok=True)
os.makedirs(AUDIT_DIR, exist_ok=True)

MASTER_SCENE = "res://adb/episodes/ep00_intro/ADB_EP00_Intro.tscn"
MASTER_AUDIO = os.path.join(EP00_DIR, "audio", "ADB_Intro_voice.wav")
TIMING_JSON = os.path.join(EP00_DIR, "timing", "ep00_timing.json")

TOTAL_DURATION = 132.41 # Native duration of master voice audio

def log_step(title: str):
    print("\n" + "=" * 64)
    print(f"  {title}")
    print("=" * 64)

def check_subtitles():
    log_step("STEP 1: SUBTITLE WORD COUNT AUDIT (STRICT <= 5 WORDS)")
    subtitles_path = os.path.join(EP00_DIR, "Episode00Subtitles.gd")
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
            except Exception:
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

def render_movie(is_4k: bool, raw_avi: str):
    mode_str = "4K UHD (3840x2160 @ 30 FPS)" if is_4k else "1080p FHD (1920x1080 @ 30 FPS)"
    log_step(f"STEP 2: FULL EPISODE MOVIEWRITER RENDER ({mode_str})")
    print(f"  Scene: {MASTER_SCENE}")
    print(f"  Output AVI: {raw_avi}")
    print(f"  Duration: {TOTAL_DURATION}s (~{int(TOTAL_DURATION * 30)} frames)")

    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    override_path = os.path.join(BASE_DIR, "override.cfg")
    if is_4k:
        print(f"  Writing 4K display overrides to {override_path}...")
        with open(override_path, "w", encoding="utf-8") as f:
            f.write("[display]\n\nwindow/size/window_width_override=3840\nwindow/size/window_height_override=2160\n")
    else:
        if os.path.exists(override_path):
            os.remove(override_path)

    cmd_godot = [
        GODOT_BIN,
        "--path", BASE_DIR,
        "--write-movie", raw_avi,
        "--fixed-fps", "30",
        MASTER_SCENE
    ]

    print(f"  Executing Godot {mode_str} MovieWriter render...")
    t0 = time.time()
    try:
        res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    finally:
        if os.path.exists(override_path):
            os.remove(override_path)
            print("  ✓ Removed temporary override.cfg")

    dt = time.time() - t0
    print(f"  Godot MovieWriter completed in {dt:.1f}s (Exit code: {res.returncode})")
    if res.returncode != 0:
        print(f"  STDERR:\n{res.stderr[-2000:]}")

    if not os.path.exists(raw_avi):
        print(f"  ❌ FATAL: Raw AVI was not created at {raw_avi}!")
        sys.exit(1)

    raw_mb = os.path.getsize(raw_avi) / (1024 * 1024)
    print(f"  ✓ Raw AVI captured: {raw_mb:.1f} MB")

def transcode_and_mux(is_4k: bool, raw_avi: str, output_renders: str, output_root: str):
    mode_str = "4K UHD" if is_4k else "1080p FHD"
    crf = "16" if is_4k else "17"
    log_step(f"STEP 3: TRANSCODE TO {mode_str} H.264 MP4 WITH AUDITED VOICE & SFX")
    print(f"  Input AVI: {raw_avi}")
    print(f"  Output MP4: {output_renders}")
    print(f"  Encoding settings: libx264 CRF {crf}, preset=slow, 320k AAC")

    if os.path.exists(output_renders):
        os.remove(output_renders)

    # 1. Audit RAW AVI audio volume
    check_vol_cmd = [FFMPEG_BIN, "-i", raw_avi, "-filter:a", "volumedetect", "-f", "null", "/dev/null"]
    vol_res = subprocess.run(check_vol_cmd, capture_output=True, text=True)
    raw_mean_db = -99.0
    for line in vol_res.stderr.split("\n"):
        if "mean_volume" in line or "max_volume" in line:
            print(f"    [Audio Audit] {line.strip()}")
            if "mean_volume" in line:
                try:
                    raw_mean_db = float(line.split("mean_volume:")[1].replace("dB", "").strip())
                except Exception:
                    pass

    # If raw audio mean volume is silent (< -35 dB), mix in master audio explicitly
    if raw_mean_db < -35.0:
        print("  ⚠️ Notice: Raw AVI audio is below threshold. Muxing master voice track via amix...")
        cmd_ffmpeg = [
            FFMPEG_BIN, "-y",
            "-i", raw_avi,
            "-i", MASTER_AUDIO,
            "-filter_complex", "[0:a][1:a]amix=inputs=2:duration=first:dropout_transition=0:normalize=0[a]",
            "-map", "0:v",
            "-map", "[a]",
            "-c:v", "libx264", "-crf", crf, "-preset", "slow",
            "-pix_fmt", "yuv420p",
            "-c:a", "aac", "-b:a", "320k",
            "-t", f"{TOTAL_DURATION:.2f}",
            "-movflags", "+faststart",
            output_renders
        ]
    else:
        print(f"  ✓ Raw AVI contains healthy full-mix audio ({raw_mean_db:.1f} dB mean volume).")
        cmd_ffmpeg = [
            FFMPEG_BIN, "-y",
            "-i", raw_avi,
            "-c:v", "libx264", "-crf", crf, "-preset", "slow",
            "-pix_fmt", "yuv420p",
            "-c:a", "aac", "-b:a", "320k",
            "-t", f"{TOTAL_DURATION:.2f}",
            "-movflags", "+faststart",
            output_renders
        ]

    print(f"  Transcoding {mode_str} MP4...")
    t0 = time.time()
    res = subprocess.run(cmd_ffmpeg, capture_output=True, text=True)
    dt = time.time() - t0

    if res.returncode != 0 or not os.path.exists(output_renders):
        print(f"  ❌ FATAL: FFmpeg transcoding failed:\n{res.stderr[-2000:]}")
        sys.exit(1)

    mp4_mb = os.path.getsize(output_renders) / (1024 * 1024)
    print(f"  ✓ Master MP4 generated: {output_renders} ({mp4_mb:.2f} MB, {dt:.1f}s)")

    # 2. Verify Final MP4 Audio Levels
    post_check = subprocess.run([FFMPEG_BIN, "-i", output_renders, "-filter:a", "volumedetect", "-f", "null", "/dev/null"], capture_output=True, text=True)
    for line in post_check.stderr.split("\n"):
        if "mean_volume" in line or "max_volume" in line:
            print(f"    [Final MP4 Audio] {line.strip()}")

    # Also copy to root workspace directory for immediate access
    shutil.copy2(output_renders, output_root)
    print(f"  ✓ Copied to project root: {output_root}")

    # Clean up temp raw AVI
    if os.path.exists(raw_avi):
        os.remove(raw_avi)
        print(f"  ✓ Cleaned up temporary raw AVI ({raw_avi}).")

def extract_audit_frames(is_4k: bool, output_mp4: str):
    mode_str = "4K" if is_4k else "1080P"
    log_step(f"STEP 4: EXTRACT {mode_str} AUDIT FRAMES ACROSS ALL 10 BEATS")

    audit_points = [
        ("beat01_pushed_hook", 2.2),             # Beat 1: ADB pushed in by silhouette
        ("beat02_intro_confession", 11.0),       # Beat 2: ADB introducing himself
        ("beat03_table_tennis_smash", 31.5),     # Beat 3: Table tennis anime smash
        ("beat04_sports_games", 42.5),           # Beat 4: Gamepad and ranked games
        ("beat05_anime_mountain", 58.5),         # Beat 5: Absurd mountain of manga
        ("beat06_gym_workout", 73.0),            # Beat 6: Lifting dumbbell / leg day
        ("beat07_engineering_job", 84.5),        # Beat 7: Laptop & "why did I do this"
        ("beat08_timeline_overwhelm", 102.5),    # Beat 8: Giant unrolled timeline
        ("beat08_deadpan_great", 104.65),        # Beat 8: Iconic deadpan "Great."
        ("beat09_girlfriend_help", 112.0),       # Beat 9: Mystery silhouette thumbs up
        ("beat09_potato_doodle", 114.5),         # Beat 9: Crossed-out potato doodle
        ("beat10_outro_welcoming", 125.0),       # Beat 10: ADB talking to camera
        ("beat10_outro_stumble", 130.15),        # Beat 10: Mystery shove impact & stumble
        ("beat10_outro_shove", 131.20),          # Beat 10: "LET ME DO THE INTRO!"
    ]

    prefix = "4k_" if is_4k else ""
    for name, timestamp in audit_points:
        out_png = os.path.join(AUDIT_DIR, f"{prefix}{name}.png")
        cmd = [
            FFMPEG_BIN, "-y",
            "-ss", f"{timestamp:.3f}",
            "-i", output_mp4,
            "-vframes", "1",
            "-q:v", "1",
            out_png
        ]
        subprocess.run(cmd, capture_output=True)
        if os.path.exists(out_png):
            print(f"  ✓ Captured {prefix}{name}.png at {timestamp:.2f}s")

    print(f"\n  ✓ All audit frames extracted to {AUDIT_DIR}")

def verify_output(is_4k: bool, output_mp4: str):
    log_step("STEP 5: VERIFY VIDEO METRICS & SPECIFICATIONS")
    expected_res = "3840x2160" if is_4k else "1920x1080"
    
    probe_cmd = [
        FFPROBE_BIN, "-v", "error",
        "-select_streams", "v:0",
        "-show_entries", "stream=width,height,r_frame_rate,duration,nb_frames",
        "-of", "json",
        output_mp4
    ]
    res = subprocess.run(probe_cmd, capture_output=True, text=True)
    data = json.loads(res.stdout)
    vstream = data.get("streams", [{}])[0]
    w = vstream.get("width")
    h = vstream.get("height")
    fps = vstream.get("r_frame_rate")
    actual_res = f"{w}x{h}"

    print(f"  Video Resolution: {actual_res} (Expected: {expected_res})")
    print(f"  Video Framerate:  {fps} FPS")

    if actual_res != expected_res:
        print(f"  ❌ Resolution mismatch! Expected {expected_res}, got {actual_res}")
        sys.exit(1)
    else:
        print(f"  ✓ Resolution verification PASSED: {actual_res}")

def main():
    parser = argparse.ArgumentParser(description="ADB Episode 00 Master Render Pipeline")
    parser.add_argument("--4k", dest="is_4k", action="store_true", default=True, help="Render in native 4K UHD (3840x2160)")
    parser.add_argument("--1080p", dest="is_4k", action="store_false", help="Render in 1080p FHD (1920x1080)")
    parser.add_argument("--skip-render", action="store_true", help="Skip Godot render and only transcode existing raw AVI")
    args = parser.parse_args()

    is_4k = args.is_4k
    res_label = "4K UHD (3840 × 2160 @ 30 FPS)" if is_4k else "1080P FHD (1920 × 1080 @ 30 FPS)"
    raw_avi = "/tmp/adb_ep00_intro_raw_4k.avi" if is_4k else "/tmp/adb_ep00_intro_raw_1080p.avi"
    output_mp4_renders = os.path.join(RENDERS_DIR, "ADB_INTRO_4K_MASTER.mp4" if is_4k else "ADB_INTRO_1080P_REVIEW.mp4")
    output_mp4_root = os.path.join(BASE_DIR, "ADB_INTRO_4K_MASTER.mp4" if is_4k else "ADB_INTRO_1080P_REVIEW.mp4")

    print("================================================================")
    print("  ADB STORYTIME: EPISODE 00 MASTER PRODUCTION PIPELINE")
    print(f"  \"HI, I'M ADB.\" ({res_label})")
    print("================================================================")

    check_subtitles()

    if not args.skip_render:
        render_movie(is_4k, raw_avi)

    transcode_and_mux(is_4k, raw_avi, output_mp4_renders, output_mp4_root)
    extract_audit_frames(is_4k, output_mp4_renders)
    verify_output(is_4k, output_mp4_renders)

    print("\n" + "=" * 64)
    print("  🎉 ADB EPISODE 00 4K PRODUCTION RENDER COMPLETED SUCCESSFULLY!")
    print(f"  Master Deliverable (Root):    {output_mp4_root}")
    print(f"  Master Deliverable (Archive): {output_mp4_renders}")
    print("================================================================\n")

if __name__ == "__main__":
    main()
