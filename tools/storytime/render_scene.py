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
from audio_mix import mix_audio, measure_audio

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--spec', type=Path, default=ROOT/'common/storytime/examples/two_authors_10s.json')
    parser.add_argument('--output', type=Path, default=ROOT/'renders/storytime_identity/Two_Drawing_Hands_10s.mp4')
    parser.add_argument('--start',type=float,default=0,help='Review window start on the original scene clock')
    parser.add_argument('--duration',type=float,help='Review window length; default is the remaining scene')
    parser.add_argument('--godot', default=os.environ.get('GODOT_BIN'))
    args = parser.parse_args()
    spec_path = args.spec.resolve()
    spec = validate(spec_path)
    output = args.output.resolve()
    start=args.start
    duration=args.duration if args.duration is not None else spec["duration"]-start
    if not (0<=start<spec["duration"] and 0<duration<=spec["duration"]-start):
        parser.error("Review window must fit inside the original scene clock.")
    for value in [start,duration]:
        if abs(value*spec["fps"]-round(value*spec["fps"]))>1e-5:
            parser.error("Review windows must align to frame boundaries.")
    if not output.is_relative_to(ROOT/'renders') or output.suffix != '.mp4':
        parser.error('Output must be a new .mp4 inside renders/. Episode outputs are protected.')
    if not spec_path.is_relative_to(ROOT):
        parser.error('Use a prepared spec inside this workspace.')
    if output.exists():
        parser.error('Output already exists; choose a new revision filename. Original renders are preserved.')
    candidates = [args.godot, shutil.which('godot'), str(Path.home()/'Downloads/Godot.app/Contents/MacOS/Godot'), '/Applications/Godot.app/Contents/MacOS/Godot']
    godot = next((p for p in candidates if p and Path(p).is_file()), None)
    if not godot or not shutil.which('ffmpeg') or not shutil.which('ffprobe'):
        parser.error('Existing Godot, FFmpeg, and FFprobe are required; use --godot if needed.')
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='storytime-') as folder:
        raw = Path(folder)/'scene.avi'
        subprocess.run([godot,'--path',str(ROOT),'--log-file',str(Path(folder)/'render.log'),'--fixed-fps',str(spec['fps']),'--write-movie',str(raw),'--script','tools/storytime/render_stage.gd','--',f'--spec=res://{spec_path.relative_to(ROOT)}',f'--start={start}',f'--duration={duration}'],check=True)
        log = (Path(folder)/'render.log').read_text()
        if any(token in log for token in ('SCRIPT ERROR:', 'Parse Error:', 'ERROR:')):
            raise RuntimeError('Godot reported a rendering error; final output was not replaced. ' + log[-1800:])
        if 'STORYTIME COMPLETE:' not in log:
            raise RuntimeError('Render completion marker is missing; final output was not replaced.')
        probe = subprocess.run(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=duration,nb_frames,nb_read_frames:format=duration','-of','json',str(raw)],capture_output=True,text=True,check=True)
        probe_data = json.loads(probe.stdout)
        streams = probe_data.get('streams', [])
        expected_frames=round(duration*spec['fps'])
        if not streams or int(streams[0].get('nb_read_frames',0)) not in range(expected_frames,expected_frames+3):
            raise RuntimeError('Decoded capture frame count does not match the authored window.')
        window_duration=duration
        raw_duration = None
        if streams:
            raw_duration = float(streams[0].get('duration') or 0.0)
            if not raw_duration and 'nb_frames' in streams[0]:
                raw_duration = float(streams[0]['nb_frames']) / spec['fps']
        if not raw_duration:
            raw_duration = float(probe_data.get('format', {}).get('duration', 0.0))
        if abs(raw_duration-window_duration) > 2/spec['fps']:
            raise RuntimeError(f'Incomplete render: {raw_duration}s; expected {window_duration}s')

        result = Path(folder)/'final.mp4'
        command = ['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(raw)]
        audio = mix_audio(spec,ROOT,Path(folder)/'mix.wav') if spec['version']==2 else (ROOT/spec['audio'].removeprefix('res://') if spec.get('audio') else None)
        if audio:
            command += ['-ss',str(start),'-i',str(audio),'-map','0:v:0','-map','1:a:0','-af',f'apad,atrim=duration={window_duration}']
        else:
            command += ['-map','0:v:0','-an']
        # The authored loop starts at scene time zero. This engine records an
        # extra trailing frame; dropping the first frame advances every visual
        # cue relative to the untouched narration. Keep the first N frames.
        command += ['-vf',f'trim=end_frame={round(window_duration*spec["fps"])},setpts=PTS-STARTPTS']
        command += ['-t',str(window_duration),'-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-c:a','aac','-movflags','+faststart',str(result)]
        subprocess.run(command,check=True)
        if 'mix' in spec and audio:
            measured=measure_audio(result)
            if measured['true_peak_dbfs']>-1.0:
                raise RuntimeError('Encoded audio exceeds -1 dB true peak; reduce master gain and render again')
        shutil.copyfile(result,output)
        output.with_suffix('.capture.log').write_text(log)
        if 'mix' in spec and audio:
            output.with_suffix('.audio_qa.json').write_text(json.dumps(measured,indent=2)+'\n')
    print(output)

if __name__ == '__main__':
    main()
