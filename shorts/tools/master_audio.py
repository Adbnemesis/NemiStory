"""Measure actual AAC latency, correct the audio clock, finish levels without video re-encoding."""
from pathlib import Path
import argparse,json,subprocess
from audio_mix import measure
p=argparse.ArgumentParser();p.add_argument('raw',type=Path);p.add_argument('output',type=Path);p.add_argument('timeline',type=Path);a=p.parse_args()
if a.output.exists():raise SystemExit('Preserve prior export: choose a new revision')
c=json.loads(a.timeline.read_text())
if not c.get('music') and not c['dialogue'] and not c['sfx']:
 subprocess.run(['ffmpeg','-v','error','-i',str(a.raw),'-c:v','copy','-an','-t',str(c['duration']),'-movflags','+faststart',str(a.output)],check=True)
 print(json.dumps({'raw':str(a.raw),'method':'Intentional silent visual export; video copied, no fabricated audio'}));raise SystemExit(0)
latency=measure(c,a.raw)
if latency['reconstructionCorrelation']<.92 or any(not s['sourceAtExpectedTimeDetected'] for s in latency['stems']):raise SystemExit('Raw mix does not match scheduled sources; inspect before mastering: '+json.dumps(latency))
delay=latency['delaySeconds']
if delay<-.001 or delay>.09:raise SystemExit('Unexpected source clock; inspect '+str(delay))
delay=max(0,delay);clock=f'atrim=start={delay},asetpts=PTS-STARTPTS'
scan=subprocess.run(['ffmpeg','-hide_banner','-i',str(a.raw),'-af',clock+',loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json','-f','null','-'],capture_output=True,text=True,check=True).stderr
data=json.loads(scan[scan.rfind('{'):scan.rfind('}')+1]);f=clock+f",loudnorm=I=-16:TP=-1.5:LRA=11:measured_I={data['input_i']}:measured_TP={data['input_tp']}:measured_LRA={data['input_lra']}:measured_thresh={data['input_thresh']}:offset={data['target_offset']}:linear=true"
subprocess.run(['ffmpeg','-v','error','-i',str(a.raw),'-c:v','copy','-af',f,'-t',str(c['duration']),'-c:a','aac','-b:a','192k','-ar','48000','-movflags','+faststart',str(a.output)],check=True)
print(json.dumps({'raw':str(a.raw),'targetLUFS':-16,'targetTruePeakDb':-1.5,'analysis':data,'latencyCorrection':latency,'method':'Source-correlated audio latency trim + two-pass loudnorm; video copied; encoded final measured separately'}))
