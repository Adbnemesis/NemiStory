#!/usr/bin/env python3
"""Decode a delivery, verify frame clock, and report actual audio/video evidence."""
import argparse,hashlib,json,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def run(command):return subprocess.run(command,capture_output=True,text=True,check=True)
def main():
    p=argparse.ArgumentParser();p.add_argument('video',type=Path);p.add_argument('--output',type=Path,required=True);p.add_argument('--sphere',action='store_true');p.add_argument('--duration',type=float,default=300);p.add_argument('--fps',type=int,default=30);a=p.parse_args()
    video=a.video.resolve();output=a.output.resolve()
    if not video.is_relative_to(ROOT) or not output.is_relative_to(ROOT):p.error('Use isolated project paths.')
    data=json.loads(run(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(video)]).stdout)
    v=next(x for x in data['streams'] if x['codec_type']=='video');au=next(x for x in data['streams'] if x['codec_type']=='audio')
    expected=(2160,1080) if a.sphere else (1920,1080)
    if v['width']==3840 and a.sphere:expected=(3840,1920)
    checks=dict(h264=v['codec_name']=='h264',aac=au['codec_name']=='aac',resolution=(v['width'],v['height'])==expected,
        fps=v['avg_frame_rate']==f'{a.fps}/1',frames=int(v['nb_read_frames'])==round(a.duration*a.fps),
        duration=abs(float(data['format']['duration'])-a.duration)<.1,pixel_format=v['pix_fmt'] in {'yuv420p','yuvj420p'},audio_48k=au['sample_rate']=='48000')
    log=run(['ffmpeg','-hide_banner','-v','info','-i',str(video),'-vf','blackdetect=d=0.3:pix_th=0.02,freezedetect=n=-50dB:d=3','-af','silencedetect=noise=-48dB:d=2,ebur128=peak=true','-f','null','-']).stderr
    black=[line.strip() for line in log.splitlines() if 'black_start:' in line]
    frozen=[line.strip() for line in log.splitlines() if 'freeze_' in line]
    silence=[line.strip() for line in log.splitlines() if 'silence_start:' in line or 'silence_end:' in line]
    summary=log.rsplit('Summary:',1)[-1]
    loud=float(re.search(r'I:\s*([-\d.]+) LUFS',summary)[1]);peak=float(re.search(r'Peak:\s*([-\d.]+) dBFS',summary)[1])
    checks['no_black_gaps']=not black;checks['headroom']=peak<=-1
    checks['decoded_to_end']='Error while decoding' not in log and 'Invalid data found' not in log
    report=dict(video=str(video.relative_to(ROOT)),sha256=hashlib.sha256(video.read_bytes()).hexdigest(),bytes=video.stat().st_size,checks=checks,passed=all(checks.values()),
        resolution=[v['width'],v['height']],duration=data['format']['duration'],frames=v['nb_read_frames'],pixel_format=v['pix_fmt'],color_range=v.get('color_range'),
        audio=dict(integrated_lufs=loud,true_peak_dbfs=peak,silence_events=silence),black_events=black,freeze_events=frozen,
        interpretation='Freeze and silence events are evidence for directed review; deliberate holds are not automatically failures.',
        perceptual_audio_review='pending; numeric checks do not prove pleasant delivery or SFX prominence',youtube_verified=False)
    output.parent.mkdir(parents=True,exist_ok=True);output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))
    if not report['passed']:raise SystemExit(1)
if __name__=='__main__':main()
