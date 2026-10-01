#!/usr/bin/env python3
"""
speed_up_nemi_audio.py
Applies 1.15x speedup (tempo stretch preserving pitch) to Nemi's voice segments
while keeping ADB's cool, dry delivery at 1.0x.
Shortens pauses for brisk, energetic storytime pacing.
Reassembles master EP08_voice.wav and updates ep08_raw_timing.json.
"""

import os
import sys
import shutil
import subprocess
import json
import numpy as np
import soundfile as sf

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO_DIR = os.path.join(BASE_DIR, "audio")
SEGMENTS_DIR = os.path.join(AUDIO_DIR, "segments")
BACKUP_DIR = os.path.join(AUDIO_DIR, "segments_orig_1x")
TIMING_DIR = os.path.join(BASE_DIR, "timing")
RAW_TIMING_FILE = os.path.join(TIMING_DIR, "ep08_raw_timing.json")

FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"
FFPROBE_BIN = "/opt/homebrew/bin/ffprobe"
NEMI_SPEED = 1.15

def main():
    print("============================================================")
    print("  SPEED UP NEMI VOICE LINES (1.15x) & REASSEMBLE MASTER")
    print("============================================================")

    # 1. Ensure backup directory exists and backup original files
    os.makedirs(BACKUP_DIR, exist_ok=True)
    with open(RAW_TIMING_FILE, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    # Back up original files once if not already backed up
    for seg in raw_data["segments"]:
        seg_id = seg["id"]
        orig_file = os.path.join(SEGMENTS_DIR, f"{seg_id}.wav")
        bkp_file = os.path.join(BACKUP_DIR, f"{seg_id}.wav")
        if not os.path.exists(bkp_file) and os.path.exists(orig_file):
            shutil.copy2(orig_file, bkp_file)

    sample_rate = 24000
    updated_segments = []
    master_chunks = []
    current_time = 0.0

    print(f"\n[Processing segments: Nemi @ {NEMI_SPEED}x, ADB @ 1.0x]...")

    for seg in raw_data["segments"]:
        seg_id = seg["id"]
        char = seg.get("character", "nemi")
        bkp_file = os.path.join(BACKUP_DIR, f"{seg_id}.wav")
        out_file = os.path.join(SEGMENTS_DIR, f"{seg_id}.wav")

        if char == "nemi":
            # Speed up using high quality ffmpeg atempo
            cmd = [
                FFMPEG_BIN, "-y",
                "-i", bkp_file,
                "-filter:a", f"atempo={NEMI_SPEED}",
                "-ar", str(sample_rate),
                "-ac", "1",
                out_file
            ]
            res = subprocess.run(cmd, capture_output=True)
            if res.returncode != 0:
                print(f"Error processing {seg_id}: {res.stderr.decode('utf-8')}")
                sys.exit(1)
            # Snappy pause after Nemi's lines
            pause = max(0.24, round(seg["pause_after"] * 0.85, 3))
        else:
            # ADB stays at original 1.0x speed
            shutil.copy2(bkp_file, out_file)
            pause = seg["pause_after"]

        audio_data, sr = sf.read(out_file)
        if sr != sample_rate:
            raise ValueError(f"Sample rate mismatch: {sr} != {sample_rate}")

        seg_len = len(audio_data) / float(sample_rate)
        start_t = current_time
        end_t = start_t + seg_len

        seg_entry = dict(seg)
        seg_entry["start_time"] = round(start_t, 3)
        seg_entry["end_time"] = round(end_t, 3)
        seg_entry["duration"] = round(seg_len, 3)
        seg_entry["pause_after"] = pause
        updated_segments.append(seg_entry)

        master_chunks.append(audio_data)
        current_time = end_t

        pause_samples = int(pause * sample_rate)
        if pause_samples > 0:
            master_chunks.append(np.zeros(pause_samples, dtype=np.float32))
            current_time += pause

        status = f"⚡ {NEMI_SPEED}x" if char == "nemi" else "  1.0x"
        print(f"  [{status}] {seg_id:30s} -> {seg_len:5.2f}s (pause: {pause:.2f}s)")

    full_master_audio = np.concatenate(master_chunks)
    total_duration = len(full_master_audio) / float(sample_rate)

    raw_data["segments"] = updated_segments
    raw_data["total_duration"] = round(total_duration, 3)

    master_wav_path = os.path.join(AUDIO_DIR, "EP08_voice.wav")
    sf.write(master_wav_path, full_master_audio, sample_rate, subtype="PCM_16")
    print(f"\n  ✓ Written new master audio: {master_wav_path} ({total_duration:.2f}s)")

    with open(RAW_TIMING_FILE, "w", encoding="utf-8") as f:
        json.dump(raw_data, f, indent=2)
    print(f"  ✓ Updated raw timing file: {RAW_TIMING_FILE}")

    # Now execute process_ep08_audio_timing.py
    timing_script = os.path.join(BASE_DIR, "tools", "process_ep08_audio_timing.py")
    subprocess.run([sys.executable, timing_script], check=True)
    print("  ✓ Executed process_ep08_audio_timing.py successfully!")

if __name__ == "__main__":
    main()
