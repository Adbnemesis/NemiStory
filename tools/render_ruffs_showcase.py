#!/usr/bin/env python3
"""
tools/render_ruffs_showcase.py
Renders the complete Colonel Ruffs character animation showcase:
1. Uses Godot MovieWriter mode at 30 FPS to record all 25 test steps.
2. Transcodes to high-quality 1080p MP4.
3. Saves to renders/ruffs_showcase_1080p.mp4 (Single canonical render file).
"""

import os
import sys
import subprocess
import time

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

RENDERS_DIR = os.path.join(BASE_DIR, "renders")
os.makedirs(RENDERS_DIR, exist_ok=True)

RAW_AVI = "/tmp/ruffs_showcase.avi"
OUTPUT_MP4 = os.path.join(RENDERS_DIR, "ruffs_showcase_1080p.mp4")
SCENE_PATH = "res://brawl_stars/scenes/RuffsShowcase.tscn"

# 25 steps at 1.2s each = 30.0s -> ~900 frames @ 30 FPS
TOTAL_FRAMES = 900

def main():
    print("============================================================")
    print("  RENDERING COLONEL RUFFS CHARACTER ANIMATION SHOWCASE")
    print("  (Ruffs Brawl Stars Native 2D Illustrated System)")
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
    
    print(f"\n[1/2] Executing Godot MovieWriter rendering ({TOTAL_FRAMES} frames @ 30 FPS)...")
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
    
    print("\n[2/2] Transcoding to 1080p H.264 MP4 with FFmpeg...")
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
    
    if os.path.exists(RAW_AVI):
        os.remove(RAW_AVI)
        
    print(f"\n[✓] Colonel Ruffs showcase video rendered successfully to: {OUTPUT_MP4}")

if __name__ == "__main__":
    main()
