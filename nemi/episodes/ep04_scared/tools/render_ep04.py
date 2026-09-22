#!/usr/bin/env python3
"""
tools/render_ep04.py
Production Render Pipeline for NEMI — Episode 04: "Guys, I'm Scared."

Supports:
  - Individual beat rendering (--mode beat --beat beat01)
  - Full master 1080p render (--mode all)
  - Audit frame extraction (--mode audit)

Pipeline: Godot MovieWriter (30 FPS AVI) → FFmpeg transcode (H.264 1080p) → Mux with master audio
"""

import os
import sys
import subprocess
import time
import argparse
import shutil

EP04_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE_DIR = os.path.abspath(os.path.join(EP04_DIR, "..", "..", ".."))
GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"

PREVIEWS_DIR = os.path.join(EP04_DIR, "previews")
RENDERS_DIR = os.path.join(EP04_DIR, "renders")
SFX_MASTER_AUDIO = os.path.join(EP04_DIR, "audio", "EP04_audio_sfx_master.wav")
VOICE_AUDIO = os.path.join(EP04_DIR, "audio", "EP04_voice.wav")
MASTER_AUDIO = SFX_MASTER_AUDIO if os.path.exists(SFX_MASTER_AUDIO) else VOICE_AUDIO
TOTAL_DURATION = 73.20

BEATS = [
    {
        "id": "beat01",
        "name": "RawConfession",
        "scene": "res://nemi/episodes/ep04_scared/beats/Beat01_RawConfession.tscn",
        "duration": 9.92,
    },
    {
        "id": "beat02",
        "name": "NotHorror",
        "scene": "res://nemi/episodes/ep04_scared/beats/Beat02_NotHorror.tscn",
        "duration": 7.23,
    },
    {
        "id": "beat03",
        "name": "ObsessingFrames",
        "scene": "res://nemi/episodes/ep04_scared/beats/Beat03_ObsessingFrames.tscn",
        "duration": 7.18,
    },
    {
        "id": "beat04",
        "name": "Refresh2AM",
        "scene": "res://nemi/episodes/ep04_scared/beats/Beat04_Refresh2AM.tscn",
        "duration": 9.09,
    },
    {
        "id": "beat05",
        "name": "OverthinkingDoubts",
        "scene": "res://nemi/episodes/ep04_scared/beats/Beat05_OverthinkingDoubts.tscn",
        "duration": 7.79,
    },
    {
        "id": "beat06",
        "name": "ProdigiesAndChaos",
        "scene": "res://nemi/episodes/ep04_scared/beats/Beat06_ProdigiesAndChaos.tscn",
        "duration": 7.52,
    },
    {
        "id": "beat07",
        "name": "BecauseICare",
        "scene": "res://nemi/episodes/ep04_scared/beats/Beat07_BecauseICare.tscn",
        "duration": 6.90,
    },
    {
        "id": "beat08",
        "name": "GroundedDetermination",
        "scene": "res://nemi/episodes/ep04_scared/beats/Beat08_GroundedDetermination.tscn",
        "duration": 7.17,
    },
    {
        "id": "beat09",
        "name": "CasualSignoff",
        "scene": "res://nemi/episodes/ep04_scared/beats/Beat09_CasualSignoff.tscn",
        "duration": 10.40,
    },
]

# Key frames to extract for visual audit
AUDIT_POINTS = [
    ("01_b1_candid_opening.png",       "00:00:02.00"),
    ("02_b1_terrified_confession.png",  "00:00:08.50"),
    ("03_b2_ghost_storycard.png",       "00:00:11.00"),
    ("04_b2_ghost_crossout.png",        "00:00:13.50"),
    ("05_b3_heart_doodle.png",          "00:00:20.00"),
    ("06_b3_tablet_timeline.png",       "00:00:22.50"),
    ("07_b4_views_card.png",            "00:00:27.00"),
    ("08_b4_phone_callout.png",         "00:00:30.50"),
    ("09_b4_deadpan_seven_views.png",   "00:00:29.00"),
    ("10_b5_brain_spiral.png",          "00:00:35.50"),
    ("11_b5_never_get_better.png",      "00:00:39.50"),
    ("12_b6_star_emphasis.png",         "00:00:43.00"),
    ("13_b6_chaos_timeline.png",        "00:00:46.00"),
    ("14_b7_hand_on_heart.png",         "00:00:50.00"),
    ("15_b7_heart_storycard.png",       "00:00:52.50"),
    ("16_b8_shrug_overthinking.png",    "00:00:57.00"),
    ("17_b8_next_video_card.png",       "00:01:00.00"),
    ("18_b9_casual_wave.png",           "00:01:08.50"),
    ("19_b9_final_smile.png",           "00:01:11.00"),
]


def write_override_cfg(width=3840, height=2160):
    override_path = os.path.join(BASE_DIR, "override.cfg")
    content = f"""[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/size/window_width_override={width}
window/size/window_height_override={height}
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"
"""
    with open(override_path, "w") as f:
        f.write(content)


def remove_override_cfg():
    override_path = os.path.join(BASE_DIR, "override.cfg")
    if os.path.exists(override_path):
        os.remove(override_path)


def render_beat(beat, force=False, is_4k=False):
    """Render a single beat using Godot MovieWriter → FFmpeg transcode."""
    tag = "4k" if is_4k else "1080p"
    w, h = (3840, 2160) if is_4k else (1920, 1080)
    crf = "17" if is_4k else "18"
    out_dir = PREVIEWS_DIR
    os.makedirs(out_dir, exist_ok=True)

    out_mp4 = os.path.join(out_dir, f"EP04_{beat['name']}_{tag}.mp4")
    raw_avi = f"/tmp/ep04_{beat['id']}_{tag}.avi"

    if not force and os.path.exists(out_mp4) and os.path.getsize(out_mp4) > 10000:
        print(f"  [SKIPPED] {beat['id'].upper()} already rendered: {os.path.basename(out_mp4)}", flush=True)
        return out_mp4

    print(f"\n>>> RENDERING {beat['id'].upper()} ({beat['name']}) — {beat['duration']:.2f}s @ 30 FPS {tag.upper()} ({w}x{h})...", flush=True)
    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    try:
        if is_4k:
            write_override_cfg(3840, 2160)
        else:
            remove_override_cfg()

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
    finally:
        remove_override_cfg()

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

    size_mb = os.path.getsize(out_mp4) / (1024 * 1024)
    print(f"  ✓ {beat['id'].upper()} rendered: {os.path.basename(out_mp4)} ({size_mb:.2f} MB)", flush=True)

    # Clean up raw AVI
    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    return out_mp4


def render_master_scene(force=False, is_4k=False):
    """Render the full master scene EP04_Scared.tscn directly via MovieWriter."""
    tag = "4k" if is_4k else "1080p"
    w, h = (3840, 2160) if is_4k else (1920, 1080)
    crf = "17" if is_4k else "18"
    audio_bitrate = "320k" if is_4k else "192k"
    os.makedirs(PREVIEWS_DIR, exist_ok=True)
    os.makedirs(RENDERS_DIR, exist_ok=True)

    output_path = os.path.join(RENDERS_DIR, f"EP04_Guys_Im_Scared_{tag.upper()}_Master.mp4")
    raw_avi = f"/tmp/ep04_master_{tag}.avi"

    if not force and os.path.exists(output_path) and os.path.getsize(output_path) > 50000:
        print(f"  [SKIPPED] Master already rendered: {output_path}", flush=True)
        return output_path

    print(f"\n{'='*60}", flush=True)
    print(f"  RENDERING EP04 MASTER SCENE ({TOTAL_DURATION:.2f}s @ 30 FPS {tag.upper()} - {w}x{h})", flush=True)
    print(f"{'='*60}", flush=True)

    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    try:
        if is_4k:
            write_override_cfg(3840, 2160)
        else:
            remove_override_cfg()

        cmd_godot = [
            GODOT_BIN,
            "--path", BASE_DIR,
            "--write-movie", raw_avi,
            "--fixed-fps", "30",
            "res://nemi/episodes/ep04_scared/EP04_Scared.tscn"
        ]
        t0 = time.time()
        res = subprocess.run(cmd_godot, cwd=BASE_DIR, capture_output=True, text=True)
        dt = time.time() - t0
        print(f"  Godot Movie Maker completed in {dt:.1f}s (Exit code: {res.returncode})", flush=True)
    finally:
        remove_override_cfg()

    if res.returncode != 0 or not os.path.exists(raw_avi):
        print(f"  ERROR: Master render failed!\nStdout:\n{res.stdout}\nStderr:\n{res.stderr}", flush=True)
        return None

    # Transcode AVI → MP4 with master audio mux
    audio_args = []
    audio_map = []
    if os.path.exists(MASTER_AUDIO):
        audio_args = ["-i", MASTER_AUDIO]
        audio_map = ["-map", "0:v", "-map", "1:a", "-c:a", "aac", "-b:a", audio_bitrate]
    else:
        audio_map = ["-an"]
        print("  WARNING: Master audio not found, rendering video-only!", flush=True)

    cmd_ffmpeg = [
        FFMPEG_BIN, "-y",
        "-i", raw_avi,
        *audio_args,
        "-t", f"{TOTAL_DURATION:.2f}",
        "-vf", f"scale={w}:{h}:flags=lanczos",
        "-c:v", "libx264", "-crf", crf, "-preset", "fast",
        "-pix_fmt", "yuv420p",
        *audio_map,
        output_path
    ]

    res_ff = subprocess.run(cmd_ffmpeg, capture_output=True, text=True)
    if res_ff.returncode != 0:
        print(f"  ERROR: FFmpeg master transcode failed!\n{res_ff.stderr}", flush=True)
        return None

    # Copy to previews
    preview_copy = os.path.join(PREVIEWS_DIR, os.path.basename(output_path))
    if os.path.abspath(output_path) != os.path.abspath(preview_copy):
        shutil.copy2(output_path, preview_copy)

    # Clean up raw AVI
    if os.path.exists(raw_avi):
        os.remove(raw_avi)

    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"  ✓ {tag.upper()} Master Created: {output_path} ({size_mb:.2f} MB)", flush=True)
    return output_path


def assemble_from_beats(beat_mp4s, force=False, is_4k=False):
    """Concatenate individual beat MP4s + master audio into final video."""
    tag = "4k" if is_4k else "1080p"
    audio_bitrate = "320k" if is_4k else "192k"
    os.makedirs(RENDERS_DIR, exist_ok=True)
    output_path = os.path.join(RENDERS_DIR, f"EP04_Guys_Im_Scared_{tag.upper()}_Master.mp4")
    crf = "17" if is_4k else "18"

    if not force and os.path.exists(output_path) and os.path.getsize(output_path) > 50000:
        print(f"  [SKIPPED] Master already assembled: {output_path}", flush=True)
        return output_path

    # Build trim filters and concat filter for frame-accurate alignment
    input_args = []
    trim_filters = []
    concat_inputs = []

    for idx, (beat, mp4_file) in enumerate(zip(BEATS, beat_mp4s)):
        input_args.extend(["-i", mp4_file])
        trim_filters.append(f"[{idx}:v]trim=0:{beat['duration']:.2f},setpts=PTS-STARTPTS[v{idx}]")
        concat_inputs.append(f"[v{idx}]")

    # Add audio input
    if os.path.exists(MASTER_AUDIO):
        input_args.extend(["-i", MASTER_AUDIO])
    else:
        print("  WARNING: No master audio found!", flush=True)

    filter_complex = ";".join(trim_filters) + f";{''.join(concat_inputs)}concat=n={len(BEATS)}:v=1:a=0[v]"

    print(f"\n>>> Muxing Final {tag.upper()} Version ({output_path})...", flush=True)
    cmd_mux = [
        FFMPEG_BIN, "-y",
        *input_args,
        "-filter_complex", filter_complex,
        "-map", "[v]",
        "-map", f"{len(beat_mp4s)}:a",
        "-c:v", "libx264", "-crf", crf, "-preset", "fast", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", audio_bitrate,
        "-t", f"{TOTAL_DURATION:.2f}",
        output_path
    ]
    res = subprocess.run(cmd_mux, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"ERROR assembling {tag.upper()} video:\n{res.stderr}", flush=True)
        return None

    # Copy to previews
    preview_copy = os.path.join(PREVIEWS_DIR, os.path.basename(output_path))
    if os.path.abspath(output_path) != os.path.abspath(preview_copy):
        shutil.copy2(output_path, preview_copy)

    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"  ✓ {tag.upper()} Master Created: {output_path} ({size_mb:.2f} MB)", flush=True)
    return output_path


def extract_audit_frames(video_path, tag="1080p"):
    """Extract key audit frames from the rendered master for visual QA."""
    audit_dir = os.path.join(PREVIEWS_DIR, f"audit_{tag}")
    os.makedirs(audit_dir, exist_ok=True)

    print("\n============================================================", flush=True)
    print(f"  EXTRACTING AUDIT FRAMES FOR EP04 {tag.upper()} MASTER", flush=True)
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
    parser = argparse.ArgumentParser(description="Render Nemi Episode 04: Guys, I'm Scared")
    parser.add_argument("--mode", choices=["all", "beats", "master", "audit", "beat"], default="all")
    parser.add_argument("--beat", help="Beat ID to render if mode=beat (e.g. beat01)")
    parser.add_argument("--force", action="store_true", help="Force rerender of existing files")
    parser.add_argument("--direct", action="store_true", help="Render via master scene instead of concatenating beats")
    parser.add_argument("--4k", dest="is_4k", action="store_true", help="Render in 4K UHD (3840x2160)")
    parser.add_argument("--resolution", choices=["1080p", "4k"], default=None, help="Target resolution (1080p or 4k)")
    args = parser.parse_args()

    is_4k = args.is_4k or (args.resolution == "4k")
    tag = "4k" if is_4k else "1080p"

    os.makedirs(PREVIEWS_DIR, exist_ok=True)
    os.makedirs(RENDERS_DIR, exist_ok=True)

    print("============================================================")
    print("  NEMI EPISODE 04: \"GUYS, I'M SCARED.\"")
    print(f"  Duration: {TOTAL_DURATION:.2f}s | Beats: {len(BEATS)} | Voice: Sohee | Res: {tag.upper()}")
    print("============================================================")

    if args.mode == "beat":
        if not args.beat:
            print("ERROR: --beat required when --mode beat")
            sys.exit(1)
        matched = [b for b in BEATS if b['id'] == args.beat.lower()]
        if not matched:
            print(f"ERROR: Unknown beat '{args.beat}'. Choices: {[b['id'] for b in BEATS]}")
            sys.exit(1)
        render_beat(matched[0], force=args.force, is_4k=is_4k)
        return

    if args.mode == "audit":
        master_path = os.path.join(RENDERS_DIR, f"EP04_Guys_Im_Scared_{tag.upper()}_Master.mp4")
        if not os.path.exists(master_path):
            print(f"ERROR: Master video not found at {master_path}. Run --mode all first.")
            sys.exit(1)
        extract_audit_frames(master_path, tag=tag)
        return

    if args.direct or args.mode == "master":
        # Render via the master scene directly
        master_path = render_master_scene(force=args.force, is_4k=is_4k)
        if master_path and args.mode == "all":
            extract_audit_frames(master_path, tag=tag)
        return

    # Default: render beats individually then assemble for robust 4K frame-exact timing
    rendered_mp4s = []
    for beat in BEATS:
        mp4 = render_beat(beat, force=args.force, is_4k=is_4k)
        if not mp4:
            print(f"ABORTING: Failed to render {beat['id']}")
            sys.exit(1)
        rendered_mp4s.append(mp4)

    master_path = assemble_from_beats(rendered_mp4s, force=args.force, is_4k=is_4k)
    if master_path:
        extract_audit_frames(master_path, tag=tag)

    print("\n============================================================")
    print(f"  EP04 {tag.upper()} RENDER PIPELINE COMPLETE")
    print("============================================================")


if __name__ == "__main__":
    main()

