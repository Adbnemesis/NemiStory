#!/usr/bin/env python3
"""
tools/render_episode_ruffs_revenge.py
Master Production Render Script:
"RUFFS' REVENGE" / "COSMO STOLE RUFFS' CHILDHOOD"
Brawl Stars Animated Storytelling Short (~94s, 1080p @ 30 FPS)

1. Executes Godot MovieWriter mode at 30 FPS to record all 12 Acts (34 shots).
2. Transcodes raw AVI recording to broadcast-quality 1080p H.264 MP4 with FFmpeg.
3. Produces single canonical output file: renders/ruffs_revenge_1080p.mp4
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

RAW_AVI = "/tmp/ruffs_revenge.avi"
OUTPUT_MP4 = os.path.join(RENDERS_DIR, "ruffs_revenge_1080p.mp4")
SCENE_PATH = "res://brawl_stars/episodes/ep01_ruffs_revenge/Ep01RuffsRevenge.tscn"

def main():
    print("============================================================")
    print("  RENDERING BRAWL STARS SHORT: 'RUFFS' REVENGE'")
    print("  'COSMO STOLE RUFFS' CHILDHOOD' (1080p @ 30 FPS)")
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
    
    print("\n[1/2] Executing Godot MovieWriter rendering (All 12 Acts / ~2850 frames @ 30 FPS)...")
    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0
    print(f"  Godot render finished in {dt:.1f}s (Exit code: {res.returncode})")
    
    if res.returncode != 0 and not os.path.exists(RAW_AVI):
        print(f"  ERROR: Godot render failed!\nStdout:\n{res.stdout}\nStderr:\n{res.stderr}")
        sys.exit(1)
        
    if not os.path.exists(RAW_AVI):
        print("  ERROR: MovieWriter AVI file not found at " + RAW_AVI)
        print("Stdout:", res.stdout)
        print("Stderr:", res.stderr)
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
    res_ffmpeg = subprocess.run(cmd_ffmpeg, capture_output=True, text=True)
    if res_ffmpeg.returncode != 0:
        print(f"  ERROR: FFmpeg transcoding failed!\nStderr:\n{res_ffmpeg.stderr}")
        sys.exit(1)
        
    mp4_size_mb = os.path.getsize(OUTPUT_MP4) / (1024 * 1024)
    print(f"  Exported: {OUTPUT_MP4} ({mp4_size_mb:.2f} MB)")
    
    if os.path.exists(RAW_AVI):
        os.remove(RAW_AVI)
        
    print(f"\n[✓] Episode 01 rendered successfully to canonical path:\n    {OUTPUT_MP4}")

if __name__ == "__main__":
    main()
