#!/usr/bin/env python3
"""
render_benchmark_v2.py
Renders the Nemi Human-Hand-Drawn Storytime Benchmark Test V2:
- Resolution: 1920x1080 @ 30 FPS progressive (strictly NOT 4K as requested)
- Length: 16.82 seconds (505 frames)
- Voice: Canonical Sohee voice slice (benchmark_v2_voice.wav)
- Live illustrative lip-sync, hand-drawn smartphone prop lifecycle, live doodles
- Extracts 10 keyframes corresponding to BEATS 1 through 10 for exhaustive visual QA
"""

import os
import sys
import subprocess
import time
import shutil

BENCHMARK_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.abspath(os.path.join(BENCHMARK_DIR, "..", ".."))
GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

SCENE_PATH = "res://nemi/benchmark/HumanizationBenchmarkV2.tscn"
VOICE_AUDIO = os.path.join(BENCHMARK_DIR, "benchmark_v2_voice.wav")
OUTPUT_DIR = os.path.join(BENCHMARK_DIR, "renders")
KEYFRAMES_DIR = os.path.join(BENCHMARK_DIR, "keyframes_v2")
ARTIFACT_DIR = "/Users/talus/.gemini/antigravity-ide/brain/1ebfdae0-dec0-4e65-9cb3-f4e827d7f12c"

SHOTS = [
    {"id": "beat_01", "name": "BEAT_01_Relaxed_Seated_Setup", "time": 1.00},
    {"id": "beat_02", "name": "BEAT_02_Prop_Pickup_Interaction", "time": 2.70},
    {"id": "beat_03", "name": "BEAT_03_Comedic_Shock_Freeze", "time": 4.40},
    {"id": "beat_04", "name": "BEAT_04_Reflective_Contrapposto_Shift", "time": 7.00},
    {"id": "beat_05", "name": "BEAT_05_Exhausted_Memory_Gesture", "time": 9.40},
    {"id": "beat_06", "name": "BEAT_06_Live_Doodle_Reveal", "time": 11.60},
    {"id": "beat_07", "name": "BEAT_07_Confession_Three_Finger_Count", "time": 13.50},
    {"id": "beat_08", "name": "BEAT_08_Sheepish_Phone_Confession", "time": 14.80},
    {"id": "beat_09", "name": "BEAT_09_Deadpan_Comedy_Hold", "time": 16.00},
    {"id": "beat_10", "name": "BEAT_10_Subtle_Micro_Reaction", "time": 16.50},
]

def render_benchmark():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(KEYFRAMES_DIR, exist_ok=True)

    raw_avi = "/tmp/nemi_benchmark_v2_raw.avi"
    final_mp4 = os.path.join(OUTPUT_DIR, "Nemi_Humanization_Benchmark_V2_1080p.mp4")

    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    print("============================================================")
    print("STEP 1: RENDERING BENCHMARK V2 SCENE VIA GODOT MOVIEWRITER")
    print(f"Scene: {SCENE_PATH}")
    print(f"Resolution: 1920x1080 @ 30 FPS progressive")
    print(f"Duration: 16.82 seconds (505 frames)")
    print("============================================================")

    cmd_godot = [
        GODOT_BIN,
        "--path", BASE_DIR,
        "--write-movie", raw_avi,
        "--fixed-fps", "30",
        SCENE_PATH
    ]

    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0
    print(f"Godot MovieWriter completed in {dt:.1f}s (Exit code: {res.returncode})")

    if res.returncode != 0 or not os.path.exists(raw_avi):
        print(f"ERROR: Godot render failed!\nStderr:\n{res.stderr}\nStdout:\n{res.stdout}")
        sys.exit(1)

    print(f"[Render] Raw AVI size: {os.path.getsize(raw_avi) / (1024*1024):.2f} MB")

    print("============================================================")
    print("STEP 2: ENCODING MASTER 1080P PROGRESSIVE MP4 + AUDIO MUX")
    print(f"Output: {final_mp4}")
    print("============================================================")

    cmd_ffmpeg = [
        FFMPEG_BIN, "-y",
        "-i", raw_avi,
        "-i", VOICE_AUDIO,
        "-map", "0:v:0",
        "-map", "1:a:0",
        "-c:v", "libx264",
        "-preset", "slow",
        "-crf", "18",
        "-pix_fmt", "yuv420p",
        "-vf", "scale=1920:1080:flags=lanczos",
        "-c:a", "aac",
        "-b:a", "192k",
        "-t", "16.82",
        final_mp4
    ]

    res = subprocess.run(cmd_ffmpeg, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        print("ERROR: FFmpeg encoding failed:")
        print(res.stderr)
        sys.exit(1)

    print(f"[Render] Final 1080p Master Video generated: {final_mp4}")
    print(f"[Render] File size: {os.path.getsize(final_mp4) / (1024*1024):.2f} MB")

    # Copy to artifact directory
    artifact_mp4 = os.path.join(ARTIFACT_DIR, "Nemi_Humanization_Benchmark_V2_1080p.mp4")
    shutil.copyfile(final_mp4, artifact_mp4)
    print(f"[Render] Copied master to artifact directory: {artifact_mp4}")

    print("============================================================")
    print("STEP 3: EXTRACTING 10 AUDIT KEYFRAMES FOR VISUAL QA")
    print("============================================================")

    for shot in SHOTS:
        out_png = os.path.join(KEYFRAMES_DIR, f"{shot['name']}.png")
        cmd_extract = [
            FFMPEG_BIN, "-y",
            "-ss", str(shot["time"]),
            "-i", final_mp4,
            "-vframes", "1",
            "-q:v", "2",
            out_png
        ]
        subprocess.run(cmd_extract, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # Copy to artifact directory
        art_png = os.path.join(ARTIFACT_DIR, f"benchmark_v2_{shot['name']}.png")
        if os.path.exists(out_png):
            shutil.copyfile(out_png, art_png)
            print(f"Extracted {shot['name']} at {shot['time']}s -> {art_png}")

    print("============================================================")
    print("BENCHMARK V2 RENDER & KEYFRAME EXTRACTION COMPLETE!")
    print("============================================================")

if __name__ == "__main__":
    render_benchmark()
