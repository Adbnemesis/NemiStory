#!/usr/bin/env python3
"""Validate and render a NEW storytime scene; never render over episode output."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from validate_scene import ROOT, validate
from audio_mix import mix_audio

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--spec', type=Path, default=ROOT/'common/storytime/examples/two_authors_10s.json')
    parser.add_argument('--output', type=Path, default=ROOT/'renders/storytime_identity/Two_Drawing_Hands_10s.mp4')
    parser.add_argument('--godot', default=os.environ.get('GODOT_BIN'))
    args = parser.parse_args()
    spec_path = args.spec.resolve()
    spec = validate(spec_path)
    output = args.output.resolve()
    if not output.is_relative_to(ROOT/'renders') or output.suffix != '.mp4':
        parser.error('Output must be a new .mp4 inside renders/. Episode outputs are protected.')
    if not spec_path.is_relative_to(ROOT) or any(spec_path.is_relative_to(ROOT/p) for p in ('nemi/episodes','adb/episodes')):
        parser.error('Use a separate new spec inside this workspace.')
    candidates = [args.godot, shutil.which('godot'), str(Path.home()/'Downloads/Godot.app/Contents/MacOS/Godot'), '/Applications/Godot.app/Contents/MacOS/Godot']
    godot = next((p for p in candidates if p and Path(p).is_file()), None)
    if not godot or not shutil.which('ffmpeg') or not shutil.which('ffprobe'):
        parser.error('Existing Godot, FFmpeg, and FFprobe are required; use --godot if needed.')
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='storytime-') as folder:
        raw = Path(folder)/'scene.avi'
        subprocess.run([godot,'--path',str(ROOT),'--log-file',str(Path(folder)/'render.log'),'--fixed-fps',str(spec['fps']),'--write-movie',str(raw),'--script','tools/storytime/render_stage.gd','--',f'--spec=res://{spec_path.relative_to(ROOT)}'],check=True)
        log = (Path(folder)/'render.log').read_text()
        if any(token in log for token in ('SCRIPT ERROR:', 'Parse Error:', 'ERROR:')):
            raise RuntimeError('Godot reported a rendering error; final output was not replaced. ' + log[-1800:])
        if 'STORYTIME COMPLETE:' not in log:
            raise RuntimeError('Render completion marker is missing; final output was not replaced.')
        probe = subprocess.run(['ffprobe','-v','error','-show_entries','format=duration','-of','json',str(raw)],capture_output=True,text=True,check=True)
        duration = float(json.loads(probe.stdout)['format']['duration'])
        if abs(duration-spec['duration']) > 2/spec['fps']:
            raise RuntimeError(f'Incomplete render: {duration}s; expected {spec["duration"]}s')
        result = Path(folder)/'final.mp4'
        command = ['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(raw)]
        audio = mix_audio(spec,ROOT,Path(folder)/'mix.wav') if spec['version']==2 else (ROOT/spec['audio'].removeprefix('res://') if spec.get('audio') else None)
        if audio:
            command += ['-i',str(audio),'-map','0:v:0','-map','1:a:0','-af',f'apad,atrim=duration={spec["duration"]}']
        else:
            command += ['-map','0:v:0','-an']
        extra_frames = round(duration*spec['fps'])-round(spec['duration']*spec['fps'])
        if extra_frames > 0:
            # MovieMaker records a startup frame before the authored loop.
            command += ['-vf',f'trim=start_frame={extra_frames},setpts=PTS-STARTPTS']
        command += ['-t',str(spec['duration']),'-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-c:a','aac','-movflags','+faststart',str(result)]
        subprocess.run(command,check=True)
        shutil.copyfile(result,output)
    print(output)

if __name__ == '__main__':
    main()
