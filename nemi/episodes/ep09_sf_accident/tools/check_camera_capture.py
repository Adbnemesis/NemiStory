"""Check decoded full-cut pictures, word clock and unchanged physical scale."""
import json,math,subprocess
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[4];EP=ROOT/'nemi/episodes/ep09_sf_accident'
s=json.loads((EP/'scene.json').read_text());old=json.loads((EP/'scene_scale_revision.json').read_text());plan=json.loads((EP/'camera_plan.json').read_text())
assert s['audio']==old['audio'] and s['script']==old['script'] and s['captions']==old['captions']
for q in s['shots']:
 original=next(p for p in old['shots'] if p['start']<=q['start']<p['end'])
 assert q['actors']==original['actors'], 'Camera revision changed physical character scale/placement'
video=EP/'renders/EP09_SF_Accident_Sound_1080p.mp4'
if not video.exists():video=EP/'renders/EP09_SF_Accident_Camera_1080p.mp4'
b=subprocess.check_output(['ffmpeg','-v','error','-i',str(video),'-vf','scale=160:90','-pix_fmt','rgb24','-f','rawvideo','-'])
frames=np.frombuffer(b,dtype=np.uint8).reshape(-1,90,160,3)
assert len(frames)==3600
checked=[]
for cue in plan['cues']:
 assert next(e['at'] for e in s['events'] if e['id']==cue['event'])==cue['at']
 assert next(q['camera'] for q in s['shots'] if q['id']==cue['shot'])==cue['camera']
 if not cue['shot'].endswith('_reaction'):continue
 f=math.ceil(cue['at']*s['fps']-1e-8)
 delta=float(np.abs(frames[f].astype(float)-frames[f-1]).mean())
 assert delta>1, f"Missing visible camera cut: {cue['shot']} at frame {f}"
 checked.append({'shot':cue['shot'],'frame':f,'mean_pixel_change':round(delta,3)})
result={'decoded_frames':len(frames),'narration_script_captions':'Unchanged','actor_scale_placement':'Unchanged','camera_cuts':checked}
(EP/'review/camera_capture_qa.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
