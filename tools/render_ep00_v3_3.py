#!/usr/bin/env python3
"""
tools/render_ep00_v3_3.py
Renders Nemi Episode 00 V3.3 ("4K Ultra HD Doodle & Ink Storytelling Master Edition"):
1. Renders all 7 beat scenes with Godot Movie Maker mode in native 4K (3840x2160 @ 60fps).
2. Transcodes raw AVI movies to pristine 4K H.264 MP4s.
3. Conforms and concatenates the 7 beats with the master audio (voiceover + SFX mix).
4. Exports: episodes/ep00_introduction/previews/EP00_Introduction_V3_3_preview.mp4
5. Extracts key verification frames into v3_3_audit/ for visual audit.
"""

import os
import sys
import subprocess
import time

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"
PREVIEWS_DIR = os.path.join(BASE_DIR, "episodes", "ep00_introduction", "previews")
AUDIT_DIR = os.path.join(PREVIEWS_DIR, "v3_3_audit")
os.makedirs(PREVIEWS_DIR, exist_ok=True)
os.makedirs(AUDIT_DIR, exist_ok=True)

MASTER_AUDIO = os.path.join(BASE_DIR, "episodes", "ep00_introduction", "EP00_audio_sfx_master.wav")
FINAL_OUTPUT = os.path.join(PREVIEWS_DIR, "EP00_Introduction_V3_3_preview.mp4")

BEATS = [
    {
        "id": "beat01",
        "scene": "res://episodes/ep00_introduction/beats/Beat01_Hook.tscn",
        "duration": 14.70,
        "raw_avi": "/tmp/beat01_v3_3.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP00_Beat01_V3_3.mp4")
    },
    {
        "id": "beat02",
        "scene": "res://episodes/ep00_introduction/beats/Beat02_Identity.tscn",
        "duration": 16.84,
        "raw_avi": "/tmp/beat02_v3_3.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP00_Beat02_V3_3.mp4")
    },
    {
        "id": "beat03",
        "scene": "res://episodes/ep00_introduction/beats/Beat03_Struggle.tscn",
        "duration": 19.77,
        "raw_avi": "/tmp/beat03_v3_3.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP00_Beat03_V3_3.mp4")
    },
    {
        "id": "beat04",
        "scene": "res://episodes/ep00_introduction/beats/Beat04_Hobbies.tscn",
        "duration": 26.41,
        "raw_avi": "/tmp/beat04_v3_3.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP00_Beat04_V3_3.mp4")
    },
    {
        "id": "beat05",
        "scene": "res://episodes/ep00_introduction/beats/Beat05_RabbitHole.tscn",
        "duration": 27.46,
        "raw_avi": "/tmp/beat05_v3_3.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP00_Beat05_V3_3.mp4")
    },
    {
        "id": "beat06",
        "scene": "res://episodes/ep00_introduction/beats/Beat06_ChannelVision.tscn",
        "duration": 9.31,
        "raw_avi": "/tmp/beat06_v3_3.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP00_Beat06_V3_3.mp4")
    },
    {
        "id": "beat07",
        "scene": "res://episodes/ep00_introduction/beats/Beat07_Outro.tscn",
        "duration": 10.61,
        "raw_avi": "/tmp/beat07_v3_3.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP00_Beat07_V3_3.mp4")
    }
]

def render_beat(beat):
    print(f"\n>>> RENDERING {beat['id'].upper()} ({beat['duration']}s)...")
    if os.path.exists(beat['raw_avi']):
        os.remove(beat['raw_avi'])
        
    cmd_godot = [
        GODOT_BIN,
        "--path", BASE_DIR,
        "--write-movie", beat['raw_avi'],
        "--fixed-fps", "60",
        beat['scene']
    ]
    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0
    print(f"  Godot render finished in {dt:.1f}s (Exit code: {res.returncode})")
    
    if res.returncode != 0 or not os.path.exists(beat['raw_avi']):
        print(f"  ERROR: Render failed for {beat['id']}! Stderr:\n{res.stderr}")
        return False
        
    # Transcode to H.264 MP4
    cmd_ffmpeg = [
        FFMPEG_BIN, "-y",
        "-i", beat['raw_avi'],
        "-c:v", "libx264", "-crf", "18", "-preset", "fast",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        beat['mp4']
    ]
    subprocess.run(cmd_ffmpeg, capture_output=True, text=True)
    if os.path.exists(beat['raw_avi']):
        os.remove(beat['raw_avi'])
    print(f"  Transcoded to: {os.path.basename(beat['mp4'])} ({os.path.getsize(beat['mp4'])/1024/1024:.2f} MB)")
    return True

def assemble_master():
    print("\n============================================================")
    print("  ASSEMBLING MASTER EPISODE 00 V3.3 WITH 48kHz MASTER AUDIO")
    print("============================================================")
    
    input_args = []
    trim_filters = []
    concat_inputs = []
    
    for idx, beat in enumerate(BEATS):
        input_args.extend(["-i", beat['mp4']])
        trim_filters.append(f"[{idx}:v]trim=0:{beat['duration']},setpts=PTS-STARTPTS[v{idx}]")
        concat_inputs.append(f"[v{idx}]")
        
    input_args.extend(["-i", MASTER_AUDIO])
    
    filter_complex = ";".join(trim_filters) + f";{''.join(concat_inputs)}concat=n={len(BEATS)}:v=1:a=0[v]"
    
    cmd_master = [
        FFMPEG_BIN, "-y",
        *input_args,
        "-filter_complex", filter_complex,
        "-map", "[v]",
        "-map", f"{len(BEATS)}:a",
        "-c:v", "libx264", "-crf", "18", "-preset", "fast", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        "-t", "125.10",
        FINAL_OUTPUT
    ]
    
    res = subprocess.run(cmd_master, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"ERROR assembling master video:\n{res.stderr}")
        return False
        
    size_mb = os.path.getsize(FINAL_OUTPUT) / (1024 * 1024)
    print(f"✓ Master V3.3 Output Created: {FINAL_OUTPUT} ({size_mb:.2f} MB)")
    return True

def extract_audit_frames():
    print("\n============================================================")
    print("  EXTRACTING KEY AUDIT FRAMES FOR VISUAL VERIFICATION (V3.3)")
    print("============================================================")
    
    audit_points = [
        ("01_b1_teacup_arrow_doodle.png", "00:00:06.50"),
        ("02_b1_ginger_root_label.png", "00:00:13.20"),
        ("03_b2_age_24_doodle.png", "00:00:16.00"),
        ("04_b2_brain_bad_idea.png", "00:00:27.50"),
        ("05_b3_timeline_arm_doodle.png", "00:00:38.50"),
        ("06_b3_banana_peel_cutaway.png", "00:00:47.20"),
        ("07_b4_gym_leg_day_strain.png", "00:01:00.60"),
        ("08_b4_car_music_notes.png", "00:01:05.00"),
        ("09_b5_bridge_research_accumulation.png", "00:01:24.00"),
        ("10_b5_half_a_second_typography.png", "00:01:34.95"),
        ("11_b5_clean_monochrome_silence.png", "00:01:36.25"),
        ("12_b6_channel_vision_warmth.png", "00:01:50.00"),
        ("13_b7_outro_farewell.png", "00:02:04.20")
    ]
    
    for filename, timestamp in audit_points:
        out_path = os.path.join(AUDIT_DIR, filename)
        cmd = [
            FFMPEG_BIN, "-y",
            "-ss", timestamp,
            "-i", FINAL_OUTPUT,
            "-vframes", "1",
            out_path
        ]
        subprocess.run(cmd, capture_output=True)
        if os.path.exists(out_path):
            print(f"  Extracted {filename} at {timestamp} ({os.path.getsize(out_path)/1024:.1f} KB)")

def main():
    print("============================================================")
    print("  NEMI EPISODE 00 V3.3 — 4K ULTRA HD PRODUCTION PIPELINE (3840x2160)")
    print("============================================================")
    
    for beat in BEATS:
        if not render_beat(beat):
            print(f"Failed to render {beat['id']}, aborting.")
            sys.exit(1)
            
    if not assemble_master():
        print("Failed to assemble master video.")
        sys.exit(1)
        
    extract_audit_frames()
    print("\n============================================================")
    print("  EPISODE 00 V3.3 PREVIEW PRODUCTION COMPLETE!")
    print(f"  Master File: {FINAL_OUTPUT}")
    print("============================================================")

if __name__ == "__main__":
    main()
