#!/usr/bin/env python3
"""
tools/render_ep01.py
Production Render Pipeline for NEMI — Episode 01: "I Used To Have A Cat"

Supports:
  - 1080p Review Render (1920x1080 @ 30 FPS)
  - 4K Master Render (3840x2160 @ 30 FPS, native Godot Movie Maker offline render)
  - Cleanup of obsolete intermediate files and caches
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

EP01_DIR = os.path.join(BASE_DIR, "episodes", "ep01_cat")
PREVIEWS_DIR = os.path.join(EP01_DIR, "previews")
MASTER_AUDIO = os.path.join(EP01_DIR, "audio", "EP01_audio_sfx_master.wav")
TOTAL_DURATION = 81.33

BEATS = [
    {
        "id": "beat01",
        "name": "Hook",
        "scene": "res://episodes/ep01_cat/beats/Beat01_Hook.tscn",
        "duration": 3.12,
    },
    {
        "id": "beat02",
        "name": "Clarification",
        "scene": "res://episodes/ep01_cat/beats/Beat02_Clarification.tscn",
        "duration": 8.94,
    },
    {
        "id": "beat03",
        "name": "Discovery",
        "scene": "res://episodes/ep01_cat/beats/Beat03_Discovery.tscn",
        "duration": 8.40,
    },
    {
        "id": "beat04",
        "name": "Care",
        "scene": "res://episodes/ep01_cat/beats/Beat04_Care.tscn",
        "duration": 11.79,
    },
    {
        "id": "beat05",
        "name": "Problem",
        "scene": "res://episodes/ep01_cat/beats/Beat05_Problem.tscn",
        "duration": 9.47,
    },
    {
        "id": "beat06",
        "name": "Shopkeeper",
        "scene": "res://episodes/ep01_cat/beats/Beat06_Shopkeeper.tscn",
        "duration": 14.96,
    },
    {
        "id": "beat07",
        "name": "Search",
        "scene": "res://episodes/ep01_cat/beats/Beat07_Search.tscn",
        "duration": 10.64,
    },
    {
        "id": "beat08",
        "name": "Payoff",
        "scene": "res://episodes/ep01_cat/beats/Beat08_Payoff.tscn",
        "duration": 7.80,
    },
    {
        "id": "beat09",
        "name": "Ending",
        "scene": "res://episodes/ep01_cat/beats/Beat09_Ending.tscn",
        "duration": 6.21,
    }
]

AUDIT_POINTS = [
    ("01_b1_hook_eye_dart.png", "00:00:01.20"),
    ("02_b2_defensive_shrug.png", "00:00:04.20"),
    ("03_b2_age_16_annotation.png", "00:00:06.50"),
    ("04_b2_mailboxes_sketch.png", "00:00:09.50"),
    ("05_b3_discovery_walk.png", "00:00:13.50"),
    ("06_b3_tiny_bracket_doodle.png", "00:00:15.50"),
    ("07_b3_box_shivering.png", "00:00:18.50"),
    ("08_b4_milk_saucer_slide.png", "00:00:22.50"),
    ("09_b4_shoelace_hiss.png", "00:00:26.00"),
    ("10_b4_blanket_loaf_purr.png", "00:00:30.00"),
    ("11_b5_pleading_heart.png", "00:00:34.50"),
    ("12_b5_collapse_no_pets.png", "00:00:39.80"),
    ("13_b6_shopkeeper_nod.png", "00:00:45.50"),
    ("14_b6_boss_neeko_register.png", "00:00:53.50"),
    ("15_b7_search_montage_houses.png", "60.00"),
    ("16_b7_asking_customers_shrug.png", "65.00"),
    ("17_b8_forever_home_payoff.png", "71.00"),
    ("18_b9_sincere_ending_gaze.png", "78.50"),
]


def render_beat(beat, is_4k=False, force=False):
    tag = "4k" if is_4k else "1080p"
    w, h = (3840, 2160) if is_4k else (1920, 1080)
    crf = "17" if is_4k else "18"
    out_dir = os.path.join(PREVIEWS_DIR, "4k") if is_4k else PREVIEWS_DIR
    os.makedirs(out_dir, exist_ok=True)

    out_mp4 = os.path.join(out_dir, f"EP01_{beat['id'].capitalize()}_{tag}.mp4")
    raw_avi = f"/tmp/ep01_{beat['id']}_{tag}.avi"

    if not force and os.path.exists(out_mp4) and os.path.getsize(out_mp4) > 100000:
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

    # Transcode raw AVI
    if is_4k:
        cmd_ffmpeg = [
            FFMPEG_BIN, "-y",
            "-i", raw_avi,
            "-c:v", "libx264", "-crf", crf, "-preset", "fast",
            "-pix_fmt", "yuv420p",
            "-an",
            out_mp4
        ]
    else:
        cmd_ffmpeg = [
            FFMPEG_BIN, "-y",
            "-i", raw_avi,
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

    output_path = os.path.join(EP01_DIR, f"EP01_Cat_{'4K_Master' if is_4k else '1080p_Review'}.mp4")

    print("\n============================================================", flush=True)
    print(f"  ASSEMBLING {tag.upper()} MASTER EPISODE 01 ({w}x{h}, {TOTAL_DURATION:.2f}s)", flush=True)
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

    # Also copy to previews dir for easy access
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
            "-ss", timestamp,
            "-i", video_path,
            "-vframes", "1",
            out_path
        ]
        subprocess.run(cmd, capture_output=True)
        if os.path.exists(out_path):
            kb = os.path.getsize(out_path) / 1024
            print(f"  ✓ {filename} @ {timestamp} ({kb:.1f} KB)", flush=True)


def cleanup_unnecessary_files():
    print("\n============================================================", flush=True)
    print("  CLEANING UP OBSOLETE & UNNECESSARY FILES", flush=True)
    print("============================================================", flush=True)

    files_to_remove = [
        # Old pre-revision renders
        os.path.join(EP01_DIR, "EP01_Cat_Final.mp4"),
        os.path.join(PREVIEWS_DIR, "EP01_Cat_Preview_V1.mp4"),
        # Raw AVIs in renders
        os.path.join(BASE_DIR, "renders", "raw_nemi_showcase.avi"),
        os.path.join(BASE_DIR, "renders", "raw_poc.avi"),
        os.path.join(BASE_DIR, "renders", "poc_storytime_demo.mp4"),
    ]

    # Obsolete 720p beat preview files
    for i in range(1, 10):
        files_to_remove.append(os.path.join(PREVIEWS_DIR, f"EP01_Beat{i:02d}.mp4"))

    # Obsolete scratch artifacts in workspace scratch/
    scratch_dir = os.path.join(BASE_DIR, "scratch")
    if os.path.exists(scratch_dir):
        for entry in os.listdir(scratch_dir):
            if entry.endswith((".wav", ".jpg", ".txt", ".swift", ".import", ".png")) or entry.startswith(("v1_", "v2_", "test_", "analysis_", "study_")):
                files_to_remove.append(os.path.join(scratch_dir, entry))

    dirs_to_remove = [
        os.path.join(PREVIEWS_DIR, "audit"), # old 720p audit
        os.path.join(scratch_dir, "analysis_video1"),
        os.path.join(scratch_dir, "analysis_video2"),
        os.path.join(scratch_dir, "v1_timeline"),
        os.path.join(scratch_dir, "v2_timeline"),
        os.path.join(scratch_dir, "study_color"),
        os.path.join(scratch_dir, "study_mono"),
    ]

    freed_bytes = 0
    for f in files_to_remove:
        if os.path.exists(f):
            try:
                sz = os.path.getsize(f)
                os.remove(f)
                freed_bytes += sz
                print(f"  Deleted file: {os.path.relpath(f, BASE_DIR)} ({sz / (1024*1024):.2f} MB)")
            except Exception as e:
                print(f"  Failed to delete {f}: {e}")

    for d in dirs_to_remove:
        if os.path.exists(d):
            try:
                shutil.rmtree(d)
                print(f"  Deleted directory: {os.path.relpath(d, BASE_DIR)}")
            except Exception as e:
                print(f"  Failed to delete dir {d}: {e}")

    print(f"\n✓ Cleanup complete! Freed ~{freed_bytes / (1024 * 1024):.1f} MB of disk space.")


def main():
    parser = argparse.ArgumentParser(description="Render EP01 Cat Pipeline")
    parser.add_argument("--4k", dest="is_4k", action="store_true", help="Render in 4K (3840x2160)")
    parser.add_argument("--beat", type=str, help="Render only a specific beat (e.g. beat01)")
    parser.add_argument("--skip-render", action="store_true", help="Skip beat rendering, only assemble")
    parser.add_argument("--force", action="store_true", help="Force re-rendering all beats")
    parser.add_argument("--clean", action="store_true", help="Clean obsolete files and caches")
    args = parser.parse_args()

    if args.clean:
        cleanup_unnecessary_files()
        if not args.is_4k and not args.force and not args.beat:
            return

    res_str = "4K (3840x2160 @ 30 FPS)" if args.is_4k else "1080P (1920x1080 @ 30 FPS)"
    print("============================================================", flush=True)
    print(f"  NEMI EPISODE 01 — {res_str} PRODUCTION RENDER")
    print("============================================================", flush=True)

    beat_mp4s = []
    beats_to_render = BEATS
    if args.beat:
        beats_to_render = [b for b in BEATS if b["id"] == args.beat]
        if not beats_to_render:
            print(f"Unknown beat ID: {args.beat}", flush=True)
            sys.exit(1)

    for beat in BEATS:
        tag = "4k" if args.is_4k else "1080p"
        out_dir = os.path.join(PREVIEWS_DIR, "4k") if args.is_4k else PREVIEWS_DIR
        mp4_path = os.path.join(out_dir, f"EP01_{beat['id'].capitalize()}_{tag}.mp4")

        if not args.skip_render and (not args.beat or beat["id"] == args.beat):
            mp4_path = render_beat(beat, is_4k=args.is_4k, force=args.force)
            if not mp4_path:
                print(f"Failed to render {beat['id']}, aborting.", flush=True)
                sys.exit(1)
        beat_mp4s.append(mp4_path)

    if not args.beat:
        master_output = assemble_master(beat_mp4s, is_4k=args.is_4k)
        if not master_output:
            print("Failed to assemble master video.", flush=True)
            sys.exit(1)

        extract_audit_frames(master_output, is_4k=args.is_4k)

        print("\n============================================================", flush=True)
        print(f"  EPISODE 01 {res_str} MASTER PRODUCTION COMPLETE!")
        print(f"  Master Deliverable: {master_output}")
        print("============================================================", flush=True)


if __name__ == "__main__":
    main()
