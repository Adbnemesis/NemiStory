#!/usr/bin/env python3
"""Render the live-doodling proof with the existing recorded voices."""
from pathlib import Path
import argparse
import json
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default=os.environ.get('GODOT_BIN'))
    args = parser.parse_args()
    candidates = [args.godot, shutil.which('godot'),
                  str(Path.home() / 'Downloads/Godot.app/Contents/MacOS/Godot'),
                  '/Applications/Godot.app/Contents/MacOS/Godot']
    godot = next((p for p in candidates if p and Path(p).is_file()), None)
    if not godot or not shutil.which('ffmpeg') or not shutil.which('ffprobe'):
        parser.error('Godot, FFmpeg, and FFprobe are required. Set --godot to your existing Godot executable.')
    output = ROOT / 'renders/live_doodle/Live_Doodling_Proof.mp4'
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='live-doodle-') as temp:
        raw = Path(temp) / 'proof.avi'
        subprocess.run([godot, '--path', str(ROOT), '--fixed-fps', '30',
                        '--write-movie', str(raw), '--script', 'tools/render_live_doodle.gd', '--', '--movie'],
                       cwd=ROOT, check=True)
        probe = subprocess.run(['ffprobe', '-v', 'error', '-show_entries',
                                'format=duration', '-of', 'json', str(raw)],
                               capture_output=True, text=True, check=True)
        duration = float(json.loads(probe.stdout)['format']['duration'])
        if abs(duration - 29.03) > 0.15:
            raise RuntimeError(f'Incomplete render ({duration:.2f}s); expected 29.03s. Existing preview preserved.')
        mix = ('[1:a]atrim=start=5.57:end=17.84,asetpts=PTS-STARTPTS,'
               'adelay=8000:all=1[a];'
               '[2:a]atrim=start=38.808:end=47.568,asetpts=PTS-STARTPTS,'
               'adelay=20270:all=1[n];'
               '[0:a][a][n]amix=inputs=3:duration=first:normalize=0[out]')
        subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y',
                        '-i', str(raw),
                        '-i', str(ROOT / 'adb/episodes/ep00_intro/audio/ADB_Intro_voice.wav'),
                        '-i', str(ROOT / 'nemi/episodes/ep08_forced_bf_channel/audio/EP08_voice.wav'),
                        '-filter_complex', mix, '-map', '0:v', '-map', '[out]',
                        '-c:v', 'libx264', '-preset', 'medium', '-crf', '18',
                        '-pix_fmt', 'yuv420p', '-c:a', 'aac', '-b:a', '192k',
                        '-movflags', '+faststart', str(output)], check=True)
    print(output)


if __name__ == '__main__':
    main()
