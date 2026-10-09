#!/usr/bin/env python3
"""Extract review stills from ADB EP02 render for visual inspection."""
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]

def extract_stills(video_path: Path, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    
    stills = [
        ("shot00_hook.jpg", 1.8),
        ("shot01_reveal_nemi.jpg", 9.2),
        ("shot02_potato_deadpan.jpg", 13.0),
        ("shot03_lockdown_study.jpg", 18.2),
        ("shot05_dorm_party.jpg", 30.5),
        ("shot07_nemi_approach.jpg", 42.0),
        ("shot10_mistake_burst.jpg", 59.8),
        ("shot12_nerd_debate.jpg", 68.5),
        ("shot13_balcony_4am.jpg", 77.0),
        ("shot14_deep_talk.jpg", 82.5),
        ("shot16_the_kiss.jpg", 89.0),
        ("shot17_morning_panic.jpg", 93.2),
        ("shot20_five_years.jpg", 105.8),
        ("shot22_hoodie_mine_now.jpg", 110.5),
        ("shot23_best_mistake.jpg", 116.0),
    ]
    
    for filename, t in stills:
        out_file = output_dir / filename
        cmd = [
            "ffmpeg", "-y",
            "-ss", str(t),
            "-i", str(video_path),
            "-vframes", "1",
            "-q:v", "2",
            str(out_file)
        ]
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if res.returncode == 0:
            print(f"Extracted {filename} at {t}s")
        else:
            print(f"Failed to extract {filename}: {res.stderr.decode()}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: extract_stills.py <video_path> <output_dir>")
        sys.exit(1)
    extract_stills(Path(sys.argv[1]), Path(sys.argv[2]))
