"""Inspect decoded EP09 frames, including late cuts that catch a stale viewport."""
import argparse,json,math,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('video',type=Path)
a=p.parse_args()
s=json.loads((ROOT/'nemi/episodes/ep09_sf_accident/scene.json').read_text())
b=subprocess.check_output(['ffmpeg','-v','error','-i',str(a.video),'-vf','crop=2:2:20:20','-pix_fmt','rgb24','-f','rawvideo','-'])
assert len(b)//12==round(s['duration']*s['fps']), 'Wrong decoded frame count'
colors={'studio_nemi':(250,246,237),'sf_street':(204,224,225),'tech_auditorium':(220,227,223),'sf_bridge':(234,222,210),'car_cabin':(224,223,211)}
checked=[]
for i,q in enumerate(s['shots']):
 if i and q['background']==s['shots'][i-1]['background']:continue
 if q['background'] not in colors:continue
 f=math.ceil(q['start']*s['fps']-1e-8);actual=b[f*12:f*12+3]
 assert max(abs(v-e) for v,e in zip(actual,colors[q['background']]))<=4, f"Stale/misaligned background at {q['id']}: {list(actual)}"
 checked.append({'shot':q['id'],'frame':f})
print(json.dumps({'decoded_frames':len(b)//12,'verified_background_boundaries':checked},indent=2))
