#!/usr/bin/env python3
"""
render_ep08_master.py
Master Production Render Pipeline for Episode 08:
"I FORCED MY BF TO CREATE A CHANNEL"
1080p Full HD (1920x1080 @ 30 FPS progressive), Nemi 1.15x tempo, ADB 1.0x tempo.

Follows the repository standard multi-beat render & assembly architecture (from render_ep03.py):
1. Subtitle audit: strictly <= 5 words per card.
2. Render each beat individually at native 1080p 30 FPS MovieWriter.
3. Transcode each beat with frame-accurate duration trimming.
4. Assemble all beats with FFmpeg concat and mux with crystal-clear master audio.
5. Extract 21 visual QA audit frames for inspection.
"""

import os
import sys
import time
import subprocess
import json

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
EP08_DIR = os.path.join(BASE_DIR, "nemi", "episodes", "ep08_forced_bf_channel")

GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/Cellar/ffmpeg/8.1.2/bin/ffmpeg" if os.path.exists("/opt/homebrew/Cellar/ffmpeg/8.1.2/bin/ffmpeg") else "/opt/homebrew/bin/ffmpeg"

RENDERS_DIR = os.path.join(EP08_DIR, "renders")
PREVIEWS_DIR = os.path.join(EP08_DIR, "previews")
AUDIT_DIR = os.path.join(PREVIEWS_DIR, "audit_frames")

os.makedirs(RENDERS_DIR, exist_ok=True)
os.makedirs(PREVIEWS_DIR, exist_ok=True)
os.makedirs(AUDIT_DIR, exist_ok=True)

MASTER_AUDIO = os.path.join(EP08_DIR, "audio", "EP08_voice.wav")
OUTPUT_MP4 = os.path.join(RENDERS_DIR, "EP08_Forced_BF_Channel_1080p.mp4")

TOTAL_DURATION = 95.405 # Master duration in seconds

BEATS = [
    {
        "id": "beat01",
        "name": "The Hook",
        "scene": "res://nemi/episodes/ep08_forced_bf_channel/beats/Beat01_Hook.tscn",
        "duration": 6.707,
    },
    {
        "id": "beat02",
        "name": "Old ADB Callback",
        "scene": "res://nemi/episodes/ep08_forced_bf_channel/beats/Beat02_OldADBCallback.tscn",
        "duration": 7.652,
    },
    {
        "id": "beat03",
        "name": "Hated Design",
        "scene": "res://nemi/episodes/ep08_forced_bf_channel/beats/Beat03_HatedDesign.tscn",
        "duration": 6.749,
    },
    {
        "id": "beat04",
        "name": "New ADB Reveal",
        "scene": "res://nemi/episodes/ep08_forced_bf_channel/beats/Beat04_NewADBReveal.tscn",
        "duration": 10.021,
    },
    {
        "id": "beat05",
        "name": "The Terrible Idea",
        "scene": "res://nemi/episodes/ep08_forced_bf_channel/beats/Beat05_TerribleIdea.tscn",
        "duration": 7.679,
    },
    {
        "id": "beat06",
        "name": "Asking ADB",
        "scene": "res://nemi/episodes/ep08_forced_bf_channel/beats/Beat06_AskingADB.tscn",
        "duration": 8.763,
    },
    {
        "id": "beat07",
        "name": "Two Channels",
        "scene": "res://nemi/episodes/ep08_forced_bf_channel/beats/Beat07_TwoChannels.tscn",
        "duration": 14.264,
    },
    {
        "id": "beat08",
        "name": "ADB Introduction",
        "scene": "res://nemi/episodes/ep08_forced_bf_channel/beats/Beat08_ADBIntro.tscn",
        "duration": 19.427,
    },
    {
        "id": "beat09",
        "name": "Outro Takeover",
        "scene": "res://nemi/episodes/ep08_forced_bf_channel/beats/Beat09_OutroTakeover.tscn",
        "duration": 14.143,
    }
]

def log_step(title: str):
    print("\n" + "=" * 64)
    print(f"  {title}")
    print("=" * 64)

def check_subtitles():
    log_step("STEP 1: SUBTITLE WORD COUNT AUDIT")
    subtitles_path = os.path.join(EP08_DIR, "Episode08Subtitles.gd")
    if not os.path.exists(subtitles_path):
        print(f"  ❌ Subtitles file not found: {subtitles_path}")
        sys.exit(1)

    with open(subtitles_path, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.splitlines()
    violations = []
    card_count = 0

    for l in lines:
        if '"text":' in l:
            card_count += 1
            start_quote = l.find('"text": "') + 9
            end_quote = l.find('"', start_quote)
            txt = l[start_quote:end_quote]
            words = [w for w in txt.split() if w.strip()]
            if len(words) > 5:
                violations.append((txt, len(words)))

    print(f"  Total Subtitle Cards Audited: {card_count}")
    if violations:
        print(f"  ❌ FATAL: Found {len(violations)} cards exceeding 5 words!")
        for txt, cnt in violations:
            print(f"    - [{cnt} words] \"{txt}\"")
        sys.exit(1)
    print("  ✓ 100% of subtitle cards satisfy STRICTLY <= 5 words rule!")

def render_beat(beat_dict, force=False):
    bid = beat_dict["id"]
    bname = beat_dict["name"]
    bscene = beat_dict["scene"]
    bdur = beat_dict["duration"]

    raw_avi = f"/tmp/ep08_{bid}_raw.avi"
    out_mp4 = f"/tmp/ep08_{bid}_1080p.mp4"

    if not force and os.path.exists(out_mp4) and os.path.getsize(out_mp4) > 50000:
        print(f"  [CACHE] {bid.upper()} ({bname}) already rendered.")
        return out_mp4

    print(f"\n>>> RENDERING {bid.upper()}: {bname} ({bdur:.2f}s @ 30 FPS 1080p)...")
    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    cmd_godot = [
        GODOT_BIN,
        "--path", BASE_DIR,
        "--write-movie", raw_avi,
        "--fixed-fps", "30",
        bscene
    ]

    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0

    print(f"  Godot Movie Maker completed in {dt:.1f}s (Exit code: {res.returncode})")
    if res.returncode != 0 or not os.path.exists(raw_avi):
        print(f"  ❌ Render failed for {bid}!\nStderr:\n{res.stderr}")
        sys.exit(1)

    # Transcode to intermediate high-quality MP4 trimmed to exact duration
    cmd_ffmpeg = [
        FFMPEG_BIN, "-y",
        "-i", raw_avi,
        "-t", f"{bdur:.3f}",
        "-vf", "scale=1920:1080:flags=lanczos",
        "-c:v", "libx264", "-crf", "16", "-preset", "fast",
        "-pix_fmt", "yuv420p",
        out_mp4
    ]
    res_ff = subprocess.run(cmd_ffmpeg, capture_output=True, text=True)
    if res_ff.returncode != 0:
        print(f"  ❌ FFmpeg transcode failed for {bid}!\n{res_ff.stderr}")
        sys.exit(1)

    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    sz_mb = os.path.getsize(out_mp4) / (1024 * 1024)
    print(f"  ✓ {bid.upper()} ready: {sz_mb:.2f} MB")
    return out_mp4

def assemble_master(beat_mp4s):
    log_step("STEP 3: CONCATENATION & AUDIO MUX")
    print(f"  Master Audio: {MASTER_AUDIO}")
    print(f"  Output MP4:   {OUTPUT_MP4}")

    if not os.path.exists(MASTER_AUDIO):
        print(f"  ❌ Master audio not found: {MASTER_AUDIO}")
        sys.exit(1)

    input_args = []
    filter_parts = []
    concat_inputs = []

    for idx, (b, mp4_file) in enumerate(zip(BEATS, beat_mp4s)):
        input_args.extend(["-i", mp4_file])
        filter_parts.append(f"[{idx}:v]setpts=PTS-STARTPTS[v{idx}]")
        concat_inputs.append(f"[v{idx}]")

    # Add master audio
    audio_idx = len(BEATS)
    input_args.extend(["-i", MASTER_AUDIO])

    filter_complex = ";".join(filter_parts) + f";{''.join(concat_inputs)}concat=n={len(BEATS)}:v=1:a=0[vcat];[{audio_idx}:a]volume=2.2,alimiter=limit=0.98[vox]"

    cmd_mux = [
        FFMPEG_BIN, "-y",
        *input_args,
        "-filter_complex", filter_complex,
        "-map", "[vcat]",
        "-map", "[vox]",
        "-c:v", "libx264",
        "-preset", "slow",
        "-crf", "17",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac",
        "-b:a", "320k",
        "-shortest",
        OUTPUT_MP4
    ]

    t0 = time.time()
    res = subprocess.run(cmd_mux, capture_output=True, text=True)
    dt = time.time() - t0

    if res.returncode != 0:
        print(f"  ❌ Mux failed!\n{res.stderr}")
        sys.exit(1)

    mp4_mb = os.path.getsize(OUTPUT_MP4) / (1024 * 1024)
    print(f"  ✓ Pristine Master 1080p MP4 assembled in {dt:.1f}s ({mp4_mb:.1f} MB)")

def extract_audit_frames():
    log_step("STEP 4: VISUAL QA AUDIT FRAMES EXTRACTION")
    timestamps = [
        (2.5, "beat01_hook_problem"),
        (9.0, "beat02_old_adb_reveal"),
        (12.5, "beat02_circle_old_adb"),
        (16.0, "beat03_awkward_understand_why"),
        (19.5, "beat03_sheepish_why"),
        (23.5, "beat04_redesign_sketch"),
        (29.8, "beat04_new_adb_reveal"),
        (33.0, "beat05_idea_lightbulb"),
        (37.0, "beat05_persuasion"),
        (39.5, "beat06_adb_said_no_1"),
        (42.0, "beat06_adb_said_no_2"),
        (46.5, "beat06_adb_made_channel"),
        (52.5, "beat07_two_channels_badges"),
        (60.0, "beat07_rivalry_sparks"),
        (65.0, "beat08_nemi_introduce_yourself"),
        (68.0, "beat08_adb_im_adb"),
        (74.0, "beat08_adb_overshare"),
        (79.5, "beat08_adb_link_description"),
        (83.5, "beat09_suspiciously_normal"),
        (90.5, "beat09_check_out_channel"),
        (94.2, "beat09_please_make_worth_it")
    ]

    for ts, label in timestamps:
        out_jpg = os.path.join(AUDIT_DIR, f"{label}.jpg")
        cmd = [
            FFMPEG_BIN, "-y",
            "-i", OUTPUT_MP4,
            "-ss", str(ts),
            "-frames:v", "1",
            "-q:v", "2",
            out_jpg
        ]
        subprocess.run(cmd, capture_output=True)
        if os.path.exists(out_jpg):
            print(f"  ✓ Frame @ {ts:5.1f}s -> {label}.jpg")

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Master Production Render for Episode 08")
    parser.add_argument("--force", action="store_true", help="Force re-render all beats")
    args = parser.parse_args()

    print("================================================================")
    print("  NEMI EPISODE 08: MULTI-BEAT MASTER PRODUCTION RENDER")
    print("  'I FORCED MY BF TO CREATE A CHANNEL' (1080P @ 30 FPS)")
    print("================================================================")
    t_start = time.time()

    check_subtitles()

    log_step("STEP 2: RENDER ALL 9 BEATS INDIVIDUALLY")
    beat_mp4s = []
    for b in BEATS:
        mp4 = render_beat(b, force=args.force)
        beat_mp4s.append(mp4)

    assemble_master(beat_mp4s)
    extract_audit_frames()

    total_time = time.time() - t_start
    print("\n" + "=" * 64)
    print(f"  🎉 PRODUCTION PIPELINE COMPLETED IN {total_time:.1f}s")
    print(f"  MASTER 1080P: {OUTPUT_MP4}")
    print(f"  AUDIT FRAMES: {AUDIT_DIR}")
    print("=" * 64 + "\n")

if __name__ == "__main__":
    main()
