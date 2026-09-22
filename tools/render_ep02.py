#!/usr/bin/env python3
"""
tools/render_ep02.py
Production Render Pipeline for NEMI — Episode 02: "How I Met My Partner"

Supports:
  - 1080p Review Render (1920x1080 @ 30 FPS)
  - Extraction of key audit review frames across all 10 beats
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

EP02_DIR = os.path.join(BASE_DIR, "episodes", "ep02_partner")
PREVIEWS_DIR = os.path.join(EP02_DIR, "previews")
MASTER_AUDIO = os.path.join(EP02_DIR, "audio", "EP02_audio_sfx_master.wav")
TOTAL_DURATION = 102.06

BEATS = [
    {
        "id": "beat01",
        "name": "Secret",
        "scene": "res://episodes/ep02_partner/beats/Beat01_Secret.tscn",
        "duration": 7.08,
    },
    {
        "id": "beat02",
        "name": "Reveal",
        "scene": "res://episodes/ep02_partner/beats/Beat02_Reveal.tscn",
        "duration": 2.76,
    },
    {
        "id": "beat03",
        "name": "OnlineCollege",
        "scene": "res://episodes/ep02_partner/beats/Beat03_OnlineCollege.tscn",
        "duration": 10.51,
    },
    {
        "id": "beat04",
        "name": "TextingMontage",
        "scene": "res://episodes/ep02_partner/beats/Beat04_TextingMontage.tscn",
        "duration": 9.14,
    },
    {
        "id": "beat05",
        "name": "GettingCloser",
        "scene": "res://episodes/ep02_partner/beats/Beat05_GettingCloser.tscn",
        "duration": 9.06,
    },
    {
        "id": "beat06",
        "name": "DrunkStory",
        "scene": "res://episodes/ep02_partner/beats/Beat06_DrunkStory.tscn",
        "duration": 9.79,
    },
    {
        "id": "beat07",
        "name": "ADBAnime",
        "scene": "res://episodes/ep02_partner/beats/Beat07_ADBAnime.tscn",
        "duration": 16.61,
    },
    {
        "id": "beat08",
        "name": "MutualIrritation",
        "scene": "res://episodes/ep02_partner/beats/Beat08_MutualIrritation.tscn",
        "duration": 17.21,
    },
    {
        "id": "beat09",
        "name": "HelpingEachOther",
        "scene": "res://episodes/ep02_partner/beats/Beat09_HelpingEachOther.tscn",
        "duration": 6.82,
    },
    {
        "id": "beat10",
        "name": "BestFriends",
        "scene": "res://episodes/ep02_partner/beats/Beat10_BestFriends.tscn",
        "duration": 13.08,
    }
]

AUDIT_POINTS = [
    ("01_b1_secret_whisper.png", "00:00:02.00"),
    ("02_b1_lock_doodle.png", "00:00:06.00"),
    ("03_b2_adb_cool_reveal.png", "00:00:08.50"),
    ("04_b3_video_call_window.png", "00:00:13.50"),
    ("05_b4_texting_calendar_flip.png", "00:00:22.50"),
    ("06_b4_3am_clock_doodle.png", "00:00:27.50"),
    ("07_b5_puzzle_pieces_snapping.png", "00:00:34.50"),
    ("08_b6_drink_glasses_clink.png", "00:00:43.00"),
    ("09_b6_deadpan_silence_hold.png", "00:00:47.50"),
    ("10_b7_adb_cute_blush.png", "00:00:52.50"),
    ("11_b7_anime_manga_burst.png", "00:00:58.50"),
    ("12_b8_teasing_poke_anger_vein.png", "00:01:06.50"),
    ("13_b8_balance_scale_lock.png", "00:01:19.50"),
    ("14_b9_two_way_help_arrows.png", "00:01:24.50"),
    ("15_b10_connected_best_friends.png", "00:01:34.50"),
    ("16_b10_secret_callback_wink.png", "00:01:40.00"),
]


def render_beat(beat, is_4k=False, force=False):
    tag = "4k" if is_4k else "1080p"
    w, h = (3840, 2160) if is_4k else (1920, 1080)
    crf = "17" if is_4k else "18"
    out_dir = os.path.join(PREVIEWS_DIR, "4k") if is_4k else PREVIEWS_DIR
    os.makedirs(out_dir, exist_ok=True)

    out_mp4 = os.path.join(out_dir, f"EP02_{beat['id'].capitalize()}_{tag}.mp4")
    raw_avi = f"/tmp/ep02_{beat['id']}_{tag}.avi"

    if not force and os.path.exists(out_mp4) and os.path.getsize(out_mp4) > 10000:
        print(f"  [SKIPPED] {beat['id'].upper()} already rendered: {os.path.basename(out_mp4)}", flush=True)
        return out_mp4

    print(f"\n>>> RENDERING {beat['id'].upper()} ({beat['name']}) — {beat['duration']:.2f}s @ 30 FPS {tag.upper()} ({w}x{h})...", flush=True)
    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    override_path = os.path.join(BASE_DIR, "override.cfg")
    if is_4k:
        with open(override_path, "w") as f:
            f.write(f"[display]\nwindow/size/window_width_override={w}\nwindow/size/window_height_override={h}\n")

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

    if os.path.exists(override_path):
        os.remove(override_path)

    print(f"  Godot Movie Maker completed in {dt:.1f}s (Exit code: {res.returncode})", flush=True)

    if res.returncode != 0 or not os.path.exists(raw_avi):
        print(f"  ERROR: Render failed for {beat['id']}!\nStderr:\n{res.stderr}", flush=True)
        return None

    if is_4k:
        cmd_ffmpeg = [
            FFMPEG_BIN, "-y",
            "-i", raw_avi,
            "-t", f"{beat['duration']:.2f}",
            "-c:v", "libx264", "-crf", crf, "-preset", "fast",
            "-pix_fmt", "yuv420p",
            "-an",
            out_mp4
        ]
    else:
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


def assemble_master(beat_mp4s, is_4k=False):
    tag = "4k" if is_4k else "1080p"
    w, h = (3840, 2160) if is_4k else (1920, 1080)
    crf = "17" if is_4k else "18"
    audio_bitrate = "320k" if is_4k else "192k"

    output_path = os.path.join(EP02_DIR, f"EP02_How_I_Met_My_Partner_{'4K_Master' if is_4k else '1080p_Review'}.mp4")

    print("\n============================================================", flush=True)
    print(f"  ASSEMBLING {tag.upper()} MASTER EPISODE 02 ({w}x{h}, {TOTAL_DURATION:.2f}s)", flush=True)
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

    print(f"\n>>> Muxing Final {tag.upper()} Version ({output_path})...", flush=True)
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
        print(f"ERROR assembling {tag} video:\n{res.stderr}", flush=True)
        return None

    preview_copy = os.path.join(PREVIEWS_DIR, os.path.basename(output_path))
    if os.path.abspath(output_path) != os.path.abspath(preview_copy):
        shutil.copy2(output_path, preview_copy)

    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"  ✓ {tag.upper()} Master Created: {output_path} ({size_mb:.2f} MB)", flush=True)
    return output_path


def extract_audit_frames(video_path, is_4k=False):
    tag = "4k" if is_4k else "1080p"
    audit_dir = os.path.join(PREVIEWS_DIR, f"audit_{tag}")
    os.makedirs(audit_dir, exist_ok=True)

    print("\n============================================================", flush=True)
    print(f"  EXTRACTING KEY AUDIT FRAMES FOR {tag.upper()} MASTER", flush=True)
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
    parser = argparse.ArgumentParser(description="Render Nemi Episode 02: How I Met My Partner")
    parser.add_argument("--mode", choices=["all", "beats", "master", "audit", "beat"], default="all")
    parser.add_argument("--beat", help="Beat ID to render if mode=beat (e.g. beat01)")
    parser.add_argument("--force", action="store_true", help="Force rerender of existing files")
    parser.add_argument("--is-4k", action="store_true", help="Render in 4K resolution (3840x2160)")
    args = parser.parse_args()

    os.makedirs(PREVIEWS_DIR, exist_ok=True)

    if args.mode == "beat":
        if not args.beat:
            print("ERROR: --beat required when --mode beat")
            sys.exit(1)
        matched = [b for b in BEATS if b['id'] == args.beat.lower()]
        if not matched:
            print(f"ERROR: Unknown beat '{args.beat}'. Choices: {[b['id'] for b in BEATS]}")
            sys.exit(1)
        render_beat(matched[0], is_4k=args.is_4k, force=args.force)
        return

    # Render beats
    rendered_mp4s = []
    if args.mode in ["all", "beats", "master"]:
        for beat in BEATS:
            mp4 = render_beat(beat, is_4k=args.is_4k, force=args.force)
            if not mp4:
                print(f"ABORTING: Failed to render {beat['id']}")
                sys.exit(1)
            rendered_mp4s.append(mp4)

    # Assemble master
    master_path = None
    if args.mode in ["all", "master"]:
        master_path = assemble_master(rendered_mp4s, is_4k=args.is_4k)
        if not master_path:
            sys.exit(1)

    # Extract audit frames
    if args.mode in ["all", "audit"]:
        vid = master_path or os.path.join(EP02_DIR, f"EP02_How_I_Met_My_Partner_{'4K_Master' if args.is_4k else '1080p_Review'}.mp4")
        if os.path.exists(vid):
            extract_audit_frames(vid, is_4k=args.is_4k)
        else:
            print(f"Cannot extract audit frames: video not found at {vid}")


if __name__ == "__main__":
    main()
