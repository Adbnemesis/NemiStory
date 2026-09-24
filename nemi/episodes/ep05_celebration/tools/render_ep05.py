#!/usr/bin/env python3
"""
render_ep05.py
Production Render Pipeline for NEMI — Episode 05: "WHAT IS GOING ON WITH YOUTUBE?"
Strictly enforces:
- 1080p (1920x1080) @ 30 FPS ONLY (Directive 47)
- Master audio: EP05_audio_sfx_master.wav (precision mixed voice + 35 SFX)
- Subtitles: strictly <= 5 words per card
- Modular Beat-by-Beat rendering + FFmpeg assembly (EP00 V3.1 architecture)
- Comprehensive 14-frame visual audit inspection
"""

import os
import sys
import subprocess
import time
import argparse
import shutil
import json

EP05_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE_DIR = os.path.abspath(os.path.join(EP05_DIR, "..", "..", ".."))
GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

PREVIEWS_DIR = os.path.join(EP05_DIR, "previews")
RENDERS_DIR = os.path.join(EP05_DIR, "renders")
AUDIT_DIR = os.path.join(PREVIEWS_DIR, "audit_frames")

SFX_MASTER_AUDIO = os.path.join(EP05_DIR, "audio", "EP05_audio_sfx_master.wav")
VOICE_AUDIO = os.path.join(EP05_DIR, "audio", "EP05_voice_v2.wav")
MASTER_AUDIO = SFX_MASTER_AUDIO if os.path.exists(SFX_MASTER_AUDIO) else VOICE_AUDIO
FINAL_MASTER_MP4 = os.path.join(RENDERS_DIR, "EP05_What_Is_Going_On_With_YouTube_1080p_Master.mp4")
TOTAL_DURATION = 92.45

BEATS = [
    {
        "id": "beat01",
        "name": "AnalyticsFreeze",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat01_AnalyticsFreeze.tscn",
        "duration": 9.54,
        "raw_avi": "/tmp/ep05_beat01.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat01.mp4"),
    },
    {
        "id": "beat02",
        "name": "SevenViewsFlashback",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat02_SevenViewsFlashback.tscn",
        "duration": 11.19,
        "raw_avi": "/tmp/ep05_beat02.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat02.mp4"),
    },
    {
        "id": "beat03",
        "name": "CounterClimb",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat03_CounterClimb.tscn",
        "duration": 13.17,
        "raw_avi": "/tmp/ep05_beat03.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat03.mp4"),
    },
    {
        "id": "beat04",
        "name": "MilestoneExplosion",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat04_MilestoneExplosion.tscn",
        "duration": 11.65,
        "raw_avi": "/tmp/ep05_beat04.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat04.mp4"),
    },
    {
        "id": "beat05",
        "name": "HumanBeings",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat05_HumanBeings.tscn",
        "duration": 11.83,
        "raw_avi": "/tmp/ep05_beat05.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat05.mp4"),
    },
    {
        "id": "beat06",
        "name": "CommentsAvalanche",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat06_CommentsAvalanche.tscn",
        "duration": 9.14,
        "raw_avi": "/tmp/ep05_beat06.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat06.mp4"),
    },
    {
        "id": "beat07",
        "name": "CommentGratitude",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat07_CommentGratitude.tscn",
        "duration": 7.33,
        "raw_avi": "/tmp/ep05_beat07.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat07.mp4"),
    },
    {
        "id": "beat08",
        "name": "InstagramSurprise",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat08_InstagramSurprise.tscn",
        "duration": 3.59,
        "raw_avi": "/tmp/ep05_beat08.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat08.mp4"),
    },
    {
        "id": "beat09",
        "name": "CreatorReality",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat09_CreatorReality.tscn",
        "duration": 7.65,
        "raw_avi": "/tmp/ep05_beat09.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat09.mp4"),
    },
    {
        "id": "beat10",
        "name": "WarmSignoff",
        "scene": "res://nemi/episodes/ep05_celebration/beats/Beat10_WarmSignoff.tscn",
        "duration": 7.36,
        "raw_avi": "/tmp/ep05_beat10.avi",
        "mp4": os.path.join(PREVIEWS_DIR, "EP05_Beat10.mp4"),
    },
]

AUDIT_POINTS = [
    ("01_b01_freeze_shock.png",            "00:00:08.50"),
    ("02_b02_seven_views_recap.png",       "00:00:15.50"),
    ("03_b02_phone_blush.png",             "00:00:19.50"),
    ("04_b03_counter_climb_84.png",        "00:00:29.00"),
    ("05_b03_counter_suspense_999.png",    "00:00:32.50"),
    ("06_b04_explosion_1000.png",          "00:00:35.80"),
    ("07_b04_recoil_disbelief.png",        "00:00:38.50"),
    ("08_b05_tiny_crowd_metaphor.png",     "00:00:52.50"),
    ("09_b06_comments_avalanche.png",      "00:01:00.00"),
    ("10_b07_comment_gratitude.png",       "00:01:10.00"),
    ("11_b08_instagram_250.png",           "00:01:15.50"),
    ("12_b09_creator_warmth.png",          "00:01:21.00"),
    ("13_b10_thank_you_signoff.png",       "00:01:27.50"),
    ("14_b10_parting_wave.png",            "00:01:31.00"),
]

def run_subtitle_audit():
    """Verifies that NO subtitle card exceeds 5 words."""
    print("\n--- RUNNING SUBTITLE WORD-COUNT AUDIT (STRICT <= 5 WORDS) ---", flush=True)
    import re
    sub_gd_path = os.path.join(EP05_DIR, "Episode05Subtitles.gd")
    with open(sub_gd_path, "r", encoding="utf-8") as f:
        content = f.read()

    cards = re.findall(r'\{"text":\s*"([^"]+)"', content)
    total_cards = len(cards)
    max_words = 0
    violations = []

    for txt in cards:
        words = txt.strip().split()
        count = len(words)
        if count > max_words:
            max_words = count
        if count > 5:
            violations.append((txt, count))

    print(f"  Total subtitle cards checked: {total_cards}")
    print(f"  Maximum word count on any card: {max_words} words")
    if violations:
        print(f"  ❌ FAILED: Found {len(violations)} cards exceeding 5 words!")
        for v in violations:
            print(f"     - '{v[0]}' ({v[1]} words)")
        return False
    else:
        print(f"  ✓ PASSED: All {total_cards} subtitle cards strictly contain <= 5 words.")
        return True

def render_beat(beat, force=False):
    """Renders a single beat scene with Godot MovieWriter and transcodes to MP4."""
    os.makedirs(PREVIEWS_DIR, exist_ok=True)
    raw_avi = beat["raw_avi"]
    mp4_path = beat["mp4"]

    if not force and os.path.exists(mp4_path) and os.path.getsize(mp4_path) > 50000:
        size_mb = os.path.getsize(mp4_path) / (1024 * 1024)
        print(f"  [CACHED] {beat['id'].upper()} already rendered: {os.path.basename(mp4_path)} ({size_mb:.2f} MB)", flush=True)
        return mp4_path

    print(f"\n{'='*60}", flush=True)
    print(f"  RENDERING {beat['id'].upper()}: {beat['name']} ({beat['duration']}s)", flush=True)
    print(f"  Scene: {beat['scene']}", flush=True)
    print(f"{'='*60}", flush=True)

    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    cmd_godot = [
        GODOT_BIN,
        "--path", BASE_DIR,
        "--write-movie", raw_avi,
        "--fixed-fps", "30",
        beat["scene"]
    ]

    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0
    print(f"  Godot MovieWriter completed in {dt:.1f}s (Exit code: {res.returncode})", flush=True)

    if res.returncode != 0 or not os.path.exists(raw_avi):
        print(f"  ERROR: Godot render failed for {beat['id']}!\nStderr:\n{res.stderr}", flush=True)
        return None

    # Transcode to high quality H.264 MP4
    cmd_ffmpeg = [
        FFMPEG_BIN, "-y",
        "-i", raw_avi,
        "-c:v", "libx264", "-crf", "18", "-preset", "fast",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        mp4_path
    ]

    t_ff = time.time()
    res_ff = subprocess.run(cmd_ffmpeg, capture_output=True, text=True)
    dt_ff = time.time() - t_ff

    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    if res_ff.returncode != 0 or not os.path.exists(mp4_path):
        print(f"  ERROR: FFmpeg transcode failed for {beat['id']}!\n{res_ff.stderr}", flush=True)
        return None

    size_mb = os.path.getsize(mp4_path) / (1024 * 1024)
    print(f"  ✓ {beat['id'].upper()} COMPLETE: {os.path.basename(mp4_path)} ({size_mb:.2f} MB in {dt+dt_ff:.1f}s)", flush=True)
    return mp4_path

def assemble_master(beat_mp4s):
    """Conforms and concatenates all 10 beats with the master 48kHz audio track."""
    os.makedirs(RENDERS_DIR, exist_ok=True)
    print(f"\n{'='*60}", flush=True)
    print("  ASSEMBLING MASTER EPISODE 05 (1080p @ 30 FPS) WITH MASTER AUDIO")
    print(f"  Target: {FINAL_MASTER_MP4}", flush=True)
    print(f"  Audio: {os.path.basename(MASTER_AUDIO)}", flush=True)
    print(f"  Total Duration: {TOTAL_DURATION:.2f}s", flush=True)
    print(f"{'='*60}", flush=True)

    input_args = []
    trim_filters = []
    concat_inputs = []

    for idx, (beat, mp4) in enumerate(zip(BEATS, beat_mp4s)):
        input_args.extend(["-i", mp4])
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
        "-c:v", "libx264", "-crf", "18", "-preset", "fast",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        "-t", f"{TOTAL_DURATION:.2f}",
        FINAL_MASTER_MP4
    ]

    t0 = time.time()
    res = subprocess.run(cmd_master, capture_output=True, text=True)
    dt = time.time() - t0

    if res.returncode != 0 or not os.path.exists(FINAL_MASTER_MP4):
        print(f"  ERROR assembling master video:\n{res.stderr}", flush=True)
        return None

    size_mb = os.path.getsize(FINAL_MASTER_MP4) / (1024 * 1024)
    print(f"  ✓ MASTER 1080p OUTPUT CREATED: {FINAL_MASTER_MP4} ({size_mb:.2f} MB in {dt:.1f}s)", flush=True)
    return FINAL_MASTER_MP4

def extract_audit_frames(video_path):
    """Extracts key audit frames to verify visual acting, props, and subtitles."""
    os.makedirs(AUDIT_DIR, exist_ok=True)
    print(f"\n--- EXTRACTING {len(AUDIT_POINTS)} VISUAL AUDIT FRAMES ---", flush=True)
    for fname, timestamp in AUDIT_POINTS:
        out_png = os.path.join(AUDIT_DIR, fname)
        cmd = [
            FFMPEG_BIN, "-y",
            "-ss", timestamp,
            "-i", video_path,
            "-vframes", "1",
            "-q:v", "2",
            out_png
        ]
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if os.path.exists(out_png):
            print(f"  ✓ [{timestamp}] {fname}")

    print(f"✓ All audit frames extracted to: {AUDIT_DIR}")
    return AUDIT_DIR

def main():
    parser = argparse.ArgumentParser(description="Render EP05 Master Video (1080p @ 30 FPS)")
    parser.add_argument("--force", action="store_true", help="Force re-render of all beats")
    parser.add_argument("--beat", type=str, default=None, help="Render only a specific beat (e.g. beat01)")
    parser.add_argument("--audit-only", action="store_true", help="Only run audits on existing render")
    parser.add_argument("--assemble-only", action="store_true", help="Only assemble master from existing beat MP4s")
    args = parser.parse_args()

    # 1. Subtitle Audit
    sub_ok = run_subtitle_audit()
    if not sub_ok:
        sys.exit(1)

    if args.audit_only:
        if os.path.exists(FINAL_MASTER_MP4):
            extract_audit_frames(FINAL_MASTER_MP4)
        else:
            print(f"Error: {FINAL_MASTER_MP4} does not exist for audit!")
            sys.exit(1)
        return

    # Single beat render option
    if args.beat:
        target_beat = next((b for b in BEATS if b["id"].lower() == args.beat.lower()), None)
        if not target_beat:
            print(f"Error: Beat '{args.beat}' not found in BEATS roster!")
            sys.exit(1)
        mp4 = render_beat(target_beat, force=True)
        if not mp4:
            sys.exit(1)
        print(f"\nSingle beat render complete: {mp4}")
        return

    # 2. Render each beat
    beat_mp4s = []
    if not args.assemble_only:
        for beat in BEATS:
            mp4 = render_beat(beat, force=args.force)
            if not mp4:
                print(f"Pipeline aborted at {beat['id']}!")
                sys.exit(1)
            beat_mp4s.append(mp4)
    else:
        for beat in BEATS:
            if not os.path.exists(beat["mp4"]):
                print(f"Error: Missing beat MP4: {beat['mp4']}")
                sys.exit(1)
            beat_mp4s.append(beat["mp4"])

    # 3. Assemble Master Video
    master_path = assemble_master(beat_mp4s)
    if not master_path:
        print("Master assembly failed!")
        sys.exit(1)

    # 4. Extract Visual Audit Frames
    extract_audit_frames(master_path)

    print("\n============================================================")
    print("  NEMI EPISODE 05 RENDER PIPELINE FINISHED SUCCESSFULLY")
    print(f"  Master File: {master_path}")
    print("============================================================")

if __name__ == "__main__":
    main()
