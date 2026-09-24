#!/usr/bin/env python3
"""
render_benchmark.py
Renders the Nemi Humanization Benchmark Test:
- Resolution: 1920x1080 @ 30 FPS progressive (strictly NOT 4K as requested)
- Length: 11.50 seconds
- Voice: Sohee canonical voice slice
- Extracts 10 keyframes corresponding to SHOTS A through J for exhaustive visual QA
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

SCENE_PATH = "res://nemi/benchmark/HumanizationBenchmark.tscn"
VOICE_AUDIO = os.path.join(BENCHMARK_DIR, "benchmark_voice.wav")
OUTPUT_DIR = os.path.join(BENCHMARK_DIR, "renders")
KEYFRAMES_DIR = os.path.join(BENCHMARK_DIR, "keyframes")
ARTIFACT_DIR = "/Users/talus/.gemini/antigravity-ide/brain/1ebfdae0-dec0-4e65-9cb3-f4e827d7f12c"

SHOTS = [
    {"id": "shot_a", "name": "SHOT_A_Conversational_Baseline", "time": 0.60},
    {"id": "shot_b", "name": "SHOT_B_Attention_Leads_Head", "time": 1.80},
    {"id": "shot_c", "name": "SHOT_C_Weight_Shift_Contrapposto", "time": 3.10},
    {"id": "shot_d", "name": "SHOT_D_Storytelling_Live_Doodle", "time": 4.40},
    {"id": "shot_e", "name": "SHOT_E_Comedic_Shock_Recoil", "time": 5.60},
    {"id": "shot_f", "name": "SHOT_F_Hand_Gesture_Climax_Three", "time": 6.80},
    {"id": "shot_g", "name": "SHOT_G_Embarrassed_Confession", "time": 8.10},
    {"id": "shot_h", "name": "SHOT_H_Settle_Secondary_Motion", "time": 9.40},
    {"id": "shot_i", "name": "SHOT_I_Sustained_Stillness_Hold", "time": 10.50},
    {"id": "shot_j", "name": "SHOT_J_Subtle_Micro_Reaction", "time": 11.20},
]

def render_benchmark():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(KEYFRAMES_DIR, exist_ok=True)

    raw_avi = "/tmp/nemi_benchmark_raw.avi"
    final_mp4 = os.path.join(OUTPUT_DIR, "Nemi_Humanization_Benchmark_1080p.mp4")

    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    print("============================================================")
    print("STEP 1: RENDERING BENCHMARK SCENE VIA GODOT MOVIEW RITER")
    print(f"Scene: {SCENE_PATH}")
    print(f"Resolution: 1920x1080 @ 30 FPS progressive")
    print(f"Duration: 11.5 seconds (345 frames)")
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
        print(f"ERROR: Godot render failed!\nStderr:\n{res.stderr}")
        sys.exit(1)

    print("\n============================================================")
    print("STEP 2: ENCODING MASTER 1080p MP4 WITH AUDIO VIA FFMPEG")
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
        "-t", "11.50",
        final_mp4
    ]

    subprocess.run(cmd_ffmpeg, check=True)
    print(f"Encoded 1080p Master: {final_mp4} ({os.path.getsize(final_mp4)/1024/1024:.2f} MB)")

    print("\n============================================================")
    print("STEP 3: EXTRACTING 10 SHOT KEYFRAMES FOR VISUAL QA")
    print("============================================================")

    extracted_frames = []
    for shot in SHOTS:
        frame_name = f"{shot['name']}.png"
        frame_path = os.path.join(KEYFRAMES_DIR, frame_name)
        cmd_extract = [
            FFMPEG_BIN, "-y",
            "-ss", str(shot["time"]),
            "-i", final_mp4,
            "-vframes", "1",
            "-q:v", "2",
            frame_path
        ]
        subprocess.run(cmd_extract, capture_output=True, check=True)
        print(f"  [KEYFRAME] {shot['id'].upper()} ({shot['time']:.2f}s): {frame_name}")
        extracted_frames.append(frame_path)

        # Copy to artifact dir for inspectability
        artifact_frame_path = os.path.join(ARTIFACT_DIR, f"benchmark_{frame_name}")
        shutil.copy2(frame_path, artifact_frame_path)

    # Also copy the video to the artifact directory
    artifact_mp4_path = os.path.join(ARTIFACT_DIR, "Nemi_Humanization_Benchmark_1080p.mp4")
    shutil.copy2(final_mp4, artifact_mp4_path)
    print(f"\nCopied master video and 10 keyframes to artifact directory: {ARTIFACT_DIR}")

    return final_mp4, extracted_frames

if __name__ == "__main__":
    render_benchmark()
