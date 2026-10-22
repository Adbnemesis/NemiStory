"""Measure exact event levels; numeric audibility is not acoustic listening."""
import hashlib,json,math,subprocess
from pathlib import Path
import numpy as np
import soundfile as sf
EP=Path(__file__).resolve().parent.parent;ROOT=EP.parents[2]
s=json.loads((EP/'scene_r4_1080p.json').read_text())
x,sr=sf.read(ROOT/s['audio'][6:],dtype='float32');x=x if x.ndim==1 else x.mean(axis=1)
def db(v):return round(20*math.log10(max(float(v),1e-9)),2)
def rms(x):return float(np.sqrt(np.mean(x*x))) if len(x) else 0
checks=[]
for q in s['sfx']:
 f=ROOT/q['file'][6:];raw=subprocess.check_output(['ffmpeg','-hide_banner','-loglevel','error','-t',str(q['duration']),'-i',str(f),'-f','f32le','-ac','1','-ar',str(sr),'-'])
 fx=np.frombuffer(raw,dtype=np.float32)*10**(q['gain_db']/20)
 near=x[int(max(0,q['at']-.25)*sr):int(min(len(x)/sr,q['at']+max(.8,q['duration']))*sr)]*10**(-2/20)
 checks.append(dict(event=q['event'],at=q['at'],file=q['file'],source_sha256=hashlib.sha256(f.read_bytes()).hexdigest(),source_gain_db=q['gain_db'],duration=q['duration'],sfx_rms_dbfs=db(rms(fx)),sfx_peak_dbfs=db(np.max(np.abs(fx))),nearby_voice_rms_dbfs=db(rms(near)),sfx_rms_relative_to_nearby_voice_db=round(db(rms(fx))-db(rms(near)),2)))
out=dict(narration_sha256=hashlib.sha256((ROOT/s['audio'][6:]).read_bytes()).hexdigest(),method='Decode each selected exact source at original rate; apply declared source gain; compare to nearby narration after fixed-2dB voice mixer gain. Master constant affects both equally.',limits='This does not establish perceptual audibility or replace listening. No synthesis, processing or alternate mix was made.',cues=checks)
(EP/'review/audio/event_levels_r4.json').write_text(json.dumps(out,indent=2)+'\n')
for q in checks:print(q['event'],q['sfx_rms_dbfs'],q['sfx_rms_relative_to_nearby_voice_db'])
