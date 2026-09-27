#!/usr/bin/env python3
"""
tools/render_pokemon_ep01.py
Renders Cutenemi Pokemon Episode 01: "Get in the Ball, Pikachu"
1. Runs Godot MovieWriter mode at 30 FPS to record all 24 beats.
2. Transcodes raw AVI to high-quality 1080p MP4.
3. Extracts key verification screenshots into scratch/pokemon_ep01_verification/.
"""

import os
import sys
import subprocess
import time

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

RENDERS_DIR = os.path.join(BASE_DIR, "renders")
AUDIT_DIR = os.path.join(BASE_DIR, "scratch", "pokemon_ep01_verification")
os.makedirs(RENDERS_DIR, exist_ok=True)
os.makedirs(AUDIT_DIR, exist_ok=True)

RAW_AVI = "/tmp/pokemon_ep01_raw.avi"
OUTPUT_MP4 = os.path.join(RENDERS_DIR, "pokemon_ep01_get_in_the_ball.mp4")
SCENE_PATH = "res://pokemon/episodes/ep01_get_in_the_ball/Ep01GetInTheBall.tscn"

def main():
    print("============================================================")
    print("  RENDERING CUTENEMI POKÉMON EPISODE 01: GET IN THE BALL")
    print("  (Ash & Pikachu - Solid JJ Natural Dialogue System)")
    print("============================================================")
    
    if os.path.exists(RAW_AVI):
        os.remove(RAW_AVI)
        
    cmd_godot = [
        GODOT_BIN,
        "--path", BASE_DIR,
        "--write-movie", RAW_AVI,
        "--fixed-fps", "30",
        SCENE_PATH,
        "--",
        "--quit-on-finish"
    ]
    
    print("\n[1/3] Executing Godot MovieWriter rendering...")
    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0
    print(f"  Godot render completed in {dt:.1f}s (Exit code: {res.returncode})")
    
    if not os.path.exists(RAW_AVI):
        print(f"  ERROR: MovieWriter AVI file not found!\nStdout:\n{res.stdout}\nStderr:\n{res.stderr}")
        sys.exit(1)
        
    raw_size_mb = os.path.getsize(RAW_AVI) / (1024 * 1024)
    print(f"  Raw AVI captured: {raw_size_mb:.1f} MB")
    
    print("\n[2/3] Transcoding to 1080p H.264 MP4 with FFmpeg...")
    cmd_ffmpeg = [
        FFMPEG_BIN, "-y",
        "-i", RAW_AVI,
        "-c:v", "libx264", "-crf", "18", "-preset", "fast",
        "-c:a", "aac", "-b:a", "192k",
        "-vf", "scale=1920:1080",
        "-pix_fmt", "yuv420p",
        OUTPUT_MP4
    ]
    subprocess.run(cmd_ffmpeg, capture_output=True, text=True, check=True)
    
    mp4_size_mb = os.path.getsize(OUTPUT_MP4) / (1024 * 1024)
    print(f"  Exported Master Video: {OUTPUT_MP4} ({mp4_size_mb:.2f} MB)")
    
    print("\n[3/3] Extracting key verification screenshots...")
    # Exact timestamps matching cumulative audio durations
    sample_timestamps = [
        (1.5, "beat_01_hotel_lobby.jpg"),
        (5.0, "beat_02_pika_refusal.jpg"),
        (9.0, "beat_03_pet_fee.jpg"),
        (15.0, "beat_04_dragonite_combat.jpg"),
        (22.0, "beat_05_zoning_whiteboard.jpg"),
        (25.5, "beat_06_weaponized_silence.jpg"),
        (28.5, "beat_07_phone_scroll.jpg"),
        (31.7, "beat_08_oak_comfort.jpg"),
        (38.0, "beat_09_pokeball_void.jpg"),
        (47.5, "beat_10_twelve_dollars.jpg"),
        (50.8, "beat_11_sleep_outside.jpg"),
        (55.5, "beat_12_prestige_drama.jpg"),
        (61.2, "beat_13_silence_inspect.jpg"),
        (62.7, "beat_14_standard_ball.jpg"),
        (64.1, "beat_15_ash_yeah.jpg"),
        (67.0, "beat_16_pika_speedlines.jpg"),
        (72.0, "beat_17_whiteboard_pidgey_math.jpg"),
        (78.0, "beat_18_bike_roast.jpg"),
        (82.3, "beat_19_truth_bomb_freeze.jpg"),
        (85.0, "beat_20_desperate_plea.jpg"),
        (87.8, "beat_21_counterpoint.jpg"),
        (89.4, "beat_22_thunderbolt_explosion.jpg"),
        (91.5, "beat_23_charred_ash.jpg"),
        (94.5, "beat_24_defeat_invoice.jpg")
    ]

    
    for ss, fname in sample_timestamps:
        out_jpg = os.path.join(AUDIT_DIR, fname)
        cmd_extract = [
            FFMPEG_BIN, "-y",
            "-ss", str(ss),
            "-i", OUTPUT_MP4,
            "-vframes", "1",
            "-q:v", "2",
            out_jpg
        ]
        subprocess.run(cmd_extract, capture_output=True)
        if os.path.exists(out_jpg):
            print(f"  ✓ Frame captured: {fname}")
            
    print("\n✓ Full production render pipeline finished successfully!")

if __name__ == "__main__":
    main()
