#!/usr/bin/env python3
"""
tools/render_pokemon_showcase.py
Renders the complete Pikachu + Ash Ketchum character animation showcase:
1. Uses Godot MovieWriter mode at 30 FPS to record all 28 test steps.
2. Transcodes to high-quality 1080p MP4.
3. Extracts frame captures into scratch/pokemon_verification/ for visual inspection.
"""

import os
import sys
import subprocess
import time

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

RENDERS_DIR = os.path.join(BASE_DIR, "renders")
AUDIT_DIR = os.path.join(BASE_DIR, "scratch", "pokemon_verification")
os.makedirs(RENDERS_DIR, exist_ok=True)
os.makedirs(AUDIT_DIR, exist_ok=True)

RAW_AVI = "/tmp/pokemon_showcase.avi"
OUTPUT_MP4 = os.path.join(RENDERS_DIR, "pokemon_showcase_1080p.mp4")
SCENE_PATH = "res://pokemon/scenes/PokemonShowcase.tscn"

# 28 steps at 1.2s each = 33.6s -> 1010 frames @ 30 FPS
TOTAL_FRAMES = 1010

def main():
    print("============================================================")
    print("  RENDERING POKÉMON CHARACTER ANIMATION SHOWCASE")
    print("  (Pikachu + Ash Ketchum Native 2D Illustrated System)")
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
        "--step-duration=1.2",
        "--quit-on-finish"
    ]
    
    print(f"\n[1/3] Executing Godot MovieWriter rendering ({TOTAL_FRAMES} frames)...")
    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0
    print(f"  Godot render completed in {dt:.1f}s (Exit code: {res.returncode})")
    
    if res.returncode != 0 and not os.path.exists(RAW_AVI):
        print(f"  ERROR: Godot render failed!\nStdout:\n{res.stdout}\nStderr:\n{res.stderr}")
        sys.exit(1)
    
    if not os.path.exists(RAW_AVI):
        print("  ERROR: MovieWriter AVI file not found at " + RAW_AVI)
        sys.exit(1)
        
    raw_size_mb = os.path.getsize(RAW_AVI) / (1024 * 1024)
    print(f"  Raw AVI captured: {raw_size_mb:.1f} MB")
    
    print("\n[2/3] Transcoding to 1080p H.264 MP4 with FFmpeg...")
    cmd_ffmpeg = [
        FFMPEG_BIN, "-y",
        "-i", RAW_AVI,
        "-c:v", "libx264", "-crf", "18", "-preset", "fast",
        "-vf", "scale=1920:1080",
        "-pix_fmt", "yuv420p",
        OUTPUT_MP4
    ]
    subprocess.run(cmd_ffmpeg, capture_output=True, text=True, check=True)
    
    mp4_size_mb = os.path.getsize(OUTPUT_MP4) / (1024 * 1024)
    print(f"  Exported: {OUTPUT_MP4} ({mp4_size_mb:.2f} MB)")
    
    print("\n[3/3] Extracting audit frames for visual QA...")
    # Sample key audit moments across the 28 tests
    audit_cues = [
        ("01_pika_neutral", "00:00:00.600"),
        ("02_pika_happy", "00:00:01.800"),
        ("03_pika_curious", "00:00:03.000"),
        ("06_pika_shocked", "00:00:06.600"),
        ("08_pika_excited", "00:00:09.000"),
        ("10_pika_deadpan", "00:00:11.400"),
        ("11_ash_neutral", "00:00:12.600"),
        ("12_ash_happy", "00:00:13.800"),
        ("16_ash_shocked", "00:00:18.600"),
        ("17_ash_embarrassed", "00:00:19.800"),
        ("20_ash_deadpan", "00:00:23.400"),
        ("21_inter_eye_contact", "00:00:24.600"),
        ("22_inter_pika_sparks", "00:00:25.800"),
        ("23_inter_battle_stance", "00:00:27.000"),
        ("24_inter_pokeball_focus", "00:00:28.200"),
        ("25_inter_doodle_ink", "00:00:29.400"),
        ("26_inter_pokeball_open", "00:00:30.600"),
        ("27_inter_deadpan_hold", "00:00:31.800"),
        ("28_inter_monochrome", "00:00:33.000"),
    ]
    
    for name, ts in audit_cues:
        out_img = os.path.join(AUDIT_DIR, f"{name}.png")
        cmd_extract = [
            FFMPEG_BIN, "-y",
            "-i", OUTPUT_MP4,
            "-ss", ts,
            "-vframes", "1",
            "-q:v", "2",
            out_img
        ]
        subprocess.run(cmd_extract, capture_output=True, text=True)
        if os.path.exists(out_img):
            print(f"  Captured audit frame: {os.path.basename(out_img)}")
    
    if os.path.exists(RAW_AVI):
        os.remove(RAW_AVI)
        
    print("\n============================================================")
    print("  SHOWCASE RENDER & AUDIT EXTRACTION COMPLETE!")
    print(f"  Video: {OUTPUT_MP4}")
    print(f"  Audit Frames: {AUDIT_DIR}")
    print("============================================================")

if __name__ == "__main__":
    main()
