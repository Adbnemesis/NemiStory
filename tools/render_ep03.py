#!/usr/bin/env python3
"""
tools/render_ep03.py
Production Render Pipeline for NEMI — Episode 03: "My Mom Scolded Me"

Supports:
  - 1080p Review & Master Render (1920x1080 @ 30 FPS)
  - Extraction of 21 key audit review frames across all 9 beats
  - Enforces Strict Development Rule: 1080p ONLY (No 4K before explicit user approval)
"""

import os
import sys
import subprocess
import time
import argparse
import shutil

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

EP03_DIR = os.path.join(BASE_DIR, "nemi", "episodes", "ep03_scolded")
PREVIEWS_DIR = os.path.join(EP03_DIR, "previews")
RENDERS_DIR = os.path.join(BASE_DIR, "renders", "ep03_scolded")
MASTER_AUDIO = os.path.join(EP03_DIR, "audio", "EP03_audio_sfx_master.wav")
TOTAL_DURATION = 110.89

BEATS = [
    {
        "id": "beat01",
        "name": "Hook",
        "scene": "res://nemi/episodes/ep03_scolded/beats/Beat01_Hook.tscn",
        "duration": 13.67,
    },
    {
        "id": "beat02",
        "name": "ThePlan",
        "scene": "res://nemi/episodes/ep03_scolded/beats/Beat02_ThePlan.tscn",
        "duration": 8.67,
    },
    {
        "id": "beat03",
        "name": "Overconfidence",
        "scene": "res://nemi/episodes/ep03_scolded/beats/Beat03_Overconfidence.tscn",
        "duration": 11.09,
    },
    {
        "id": "beat04",
        "name": "CreativeTrap",
        "scene": "res://nemi/episodes/ep03_scolded/beats/Beat04_CreativeTrap.tscn",
        "duration": 9.32,
    },
    {
        "id": "beat05",
        "name": "PanicArrival",
        "scene": "res://nemi/episodes/ep03_scolded/beats/Beat05_PanicArrival.tscn",
        "duration": 8.60,
    },
    {
        "id": "beat06",
        "name": "ThePermafrost",
        "scene": "res://nemi/episodes/ep03_scolded/beats/Beat06_ThePermafrost.tscn",
        "duration": 11.73,
    },
    {
        "id": "beat07",
        "name": "EmergencyDefrost",
        "scene": "res://nemi/episodes/ep03_scolded/beats/Beat07_EmergencyDefrost.tscn",
        "duration": 18.77,
    },
    {
        "id": "beat08",
        "name": "TheScolding",
        "scene": "res://nemi/episodes/ep03_scolded/beats/Beat08_TheScolding.tscn",
        "duration": 16.36,
    },
    {
        "id": "beat09",
        "name": "PayoffOutro",
        "scene": "res://nemi/episodes/ep03_scolded/beats/Beat09_PayoffOutro.tscn",
        "duration": 12.68,
    }
]

AUDIT_POINTS = [
    ("01_b1_hook_trauma_blink.png", "00:00:04.50"),
    ("02_b1_gavel_guilty_stamp.png", "00:00:11.00"),
    ("03_b1_nemi_sheepish_fault.png", "00:00:12.50"),
    ("04_b2_mom_departure_keys.png", "00:00:16.00"),
    ("05_b2_defrost_sticky_note.png", "00:00:20.50"),
    ("06_b3_responsible_adult_crown.png", "00:00:25.00"),
    ("07_b3_spinning_8hour_clock.png", "00:00:29.00"),
    ("08_b4_drawing_flow_state.png", "00:00:36.50"),
    ("09_b4_sudden_realization_freeze.png", "00:00:41.50"),
    ("10_b5_driveway_tires_soundwave.png", "00:00:46.50"),
    ("11_b5_panic_sprint_vignette.png", "00:00:49.50"),
    ("12_b6_prehistoric_frozen_chicken.png", "00:00:54.50"),
    ("13_b6_permafrost_gauge_knock.png", "00:01:00.50"),
    ("14_b7_microwave_electric_arcs.png", "00:01:14.00"),
    ("15_b7_hairdryer_blaster_action.png", "00:01:19.50"),
    ("16_b8_front_door_creak_freeze.png", "00:01:23.00"),
    ("17_b8_mom_judgment_radar_aura.png", "00:01:29.00"),
    ("18_b8_maternal_disappointment_wag.png", "00:01:36.50"),
    ("19_b9_cold_cereal_dinner.png", "00:01:40.00"),
    ("20_b9_chicken_watching_kitchen.png", "00:01:44.50"),
    ("21_b9_defrost_immediately_wink.png", "00:01:49.50"),
]


def render_beat(beat, force=False):
    tag = "1080p"
    w, h = (1920, 1080)
    crf = "18"
    out_dir = PREVIEWS_DIR
    os.makedirs(out_dir, exist_ok=True)

    out_mp4 = os.path.join(out_dir, f"EP03_{beat['id'].capitalize()}_{tag}.mp4")
    raw_avi = f"/tmp/ep03_{beat['id']}_{tag}.avi"

    if not force and os.path.exists(out_mp4) and os.path.getsize(out_mp4) > 10000:
        print(f"  [SKIPPED] {beat['id'].upper()} already rendered: {os.path.basename(out_mp4)}", flush=True)
        return out_mp4

    print(f"\n>>> RENDERING {beat['id'].upper()} ({beat['name']}) — {beat['duration']:.2f}s @ 30 FPS {tag.upper()} ({w}x{h})...", flush=True)
    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    cmd_godot = [
        GODOT_BIN,
        "--path", BASE_DIR,
        "--write-movie", raw_avi,
        "--fixed-fps", "30",
        beat['scene']
    ]
    t0 = time.time()
    res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
    dt = time.time() - t0

    print(f"  Godot Movie Maker completed in {dt:.1f}s (Exit code: {res.returncode})", flush=True)

    if res.returncode != 0 or not os.path.exists(raw_avi):
        print(f"  ERROR: Render failed for {beat['id']}!\nStderr:\n{res.stderr}", flush=True)
        return None

    cmd_ffmpeg = [
        FFMPEG_BIN, "-y",
        "-i", raw_avi,
        "-t", f"{beat['duration']:.2f}",
        "-vf", f"scale={w}:{h}:flags=lanczos",
        "-c:v", "libx264", "-crf", crf, "-preset", "fast",
        "-pix_fmt", "yuv420p",
        "-an",
        out_mp4
    ]

    res_ff = subprocess.run(cmd_ffmpeg, capture_output=True, text=True)
    if res_ff.returncode != 0:
        print(f"  ERROR: FFmpeg transcode failed for {beat['id']}!\n{res_ff.stderr}", flush=True)
        return None

    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    size_mb = os.path.getsize(out_mp4) / (1024 * 1024)
    print(f"  ✓ Transcoded {beat['id'].upper()} MP4 ({tag}): {size_mb:.2f} MB", flush=True)
    return out_mp4


def assemble_master(beat_mp4s):
    tag = "1080p"
    w, h = (1920, 1080)
    crf = "18"
    audio_bitrate = "192k"

    output_path = os.path.join(EP03_DIR, "EP03_Mom_Scolded_1080p_Master.mp4")
    os.makedirs(RENDERS_DIR, exist_ok=True)
    render_copy_path = os.path.join(RENDERS_DIR, "EP03_Mom_Scolded_1080p_Master.mp4")

    print("\n============================================================", flush=True)
    print(f"  ASSEMBLING 1080P MASTER EPISODE 03 ({w}x{h}, {TOTAL_DURATION:.2f}s)", flush=True)
    print("============================================================", flush=True)

    if not os.path.exists(MASTER_AUDIO):
        print(f"ERROR: Master audio track not found: {MASTER_AUDIO}", flush=True)
        return None

    input_args = []
    trim_filters = []
    concat_inputs = []

    for idx, (beat, mp4_file) in enumerate(zip(BEATS, beat_mp4s)):
        input_args.extend(["-i", mp4_file])
        trim_filters.append(f"[{idx}:v]trim=0:{beat['duration']:.2f},setpts=PTS-STARTPTS[v{idx}]")
        concat_inputs.append(f"[v{idx}]")

    input_args.extend(["-i", MASTER_AUDIO])
    filter_complex = ";".join(trim_filters) + f";{''.join(concat_inputs)}concat=n={len(BEATS)}:v=1:a=0[v]"

    print(f"\n>>> Muxing Final 1080p Version ({output_path})...", flush=True)
    cmd_mux = [
        FFMPEG_BIN, "-y",
        *input_args,
        "-filter_complex", filter_complex,
        "-map", "[v]",
        "-map", f"{len(BEATS)}:a",
        "-c:v", "libx264", "-crf", crf, "-preset", "fast", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", audio_bitrate,
        "-t", f"{TOTAL_DURATION:.2f}",
        output_path
    ]
    res = subprocess.run(cmd_mux, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"ERROR assembling 1080p video:\n{res.stderr}", flush=True)
        return None

    # Copy to renders/ep03_scolded and previews/
    shutil.copy2(output_path, render_copy_path)
    preview_copy = os.path.join(PREVIEWS_DIR, os.path.basename(output_path))
    if os.path.abspath(output_path) != os.path.abspath(preview_copy):
        shutil.copy2(output_path, preview_copy)

    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"  ✓ 1080p Master Created: {output_path} ({size_mb:.2f} MB)", flush=True)
    print(f"  ✓ Copied to: {render_copy_path}", flush=True)
    return output_path


def extract_audit_frames(video_path):
    audit_dir = os.path.join(PREVIEWS_DIR, "audit_1080p")
    os.makedirs(audit_dir, exist_ok=True)

    print("\n============================================================", flush=True)
    print("  EXTRACTING 21 KEY AUDIT FRAMES FOR 1080P MASTER", flush=True)
    print("============================================================", flush=True)

    for filename, timestamp in AUDIT_POINTS:
        out_path = os.path.join(audit_dir, filename)
        cmd = [
            FFMPEG_BIN, "-y",
            "-i", video_path,
            "-ss", timestamp,
            "-vframes", "1",
            out_path
        ]
        subprocess.run(cmd, capture_output=True)
        if os.path.exists(out_path):
            kb = os.path.getsize(out_path) / 1024
            print(f"  ✓ {filename} @ {timestamp} ({kb:.1f} KB)", flush=True)


def main():
    parser = argparse.ArgumentParser(description="Render Nemi Episode 03: My Mom Scolded Me")
    parser.add_argument("--mode", choices=["all", "beats", "master", "audit", "beat"], default="all")
    parser.add_argument("--beat", help="Beat ID to render if mode=beat (e.g. beat01)")
    parser.add_argument("--force", action="store_true", help="Force rerender of existing files")
    args = parser.parse_args()

    os.makedirs(PREVIEWS_DIR, exist_ok=True)
    os.makedirs(RENDERS_DIR, exist_ok=True)

    if args.mode == "beat":
        if not args.beat:
            print("ERROR: --beat required when --mode beat")
            sys.exit(1)
        matched = [b for b in BEATS if b['id'] == args.beat.lower()]
        if not matched:
            print(f"ERROR: Unknown beat '{args.beat}'. Choices: {[b['id'] for b in BEATS]}")
            sys.exit(1)
        render_beat(matched[0], force=args.force)
        return

    # Render beats
    rendered_mp4s = []
    if args.mode in ["all", "beats", "master"]:
        for beat in BEATS:
            mp4 = render_beat(beat, force=args.force)
            if not mp4:
                print(f"ABORTING: Failed to render {beat['id']}")
                sys.exit(1)
            rendered_mp4s.append(mp4)

    # Assemble master
    master_path = None
    if args.mode in ["all", "master"]:
        master_path = assemble_master(rendered_mp4s)
        if not master_path:
            sys.exit(1)

    # Extract audit frames
    if args.mode in ["all", "audit"]:
        vid = master_path or os.path.join(EP03_DIR, "EP03_Mom_Scolded_1080p_Master.mp4")
        if os.path.exists(vid):
            extract_audit_frames(vid)
        else:
            print(f"Cannot extract audit frames: video not found at {vid}")


if __name__ == "__main__":
    main()
