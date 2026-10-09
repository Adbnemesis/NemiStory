"""Review framing fixes; retained paper-theme direction and exact narration."""
import json,sys
from pathlib import Path
EP=Path(__file__).resolve().parent.parent;ROOT=EP.parents[2]
sys.path.insert(0,str(ROOT/'tools/storytime'))
from validate_scene import validate
s=json.loads((EP/'scene_r6_1080p.json').read_text())
for shot in s['shots']:
    if shot['id']=='r4_12_2':
        shot['camera']=dict(center=[980,460],zoom=1.25,path=[dict(at=67.33,center=[980,460],zoom=1.25),dict(at=67.6024,center=[980,460],zoom=1.25),dict(at=68.4524,center=[980,450],zoom=1.3)])
for item in s['drawings']:
    if item.get('text')=='outside':
        item['position']=[895,550]
        item['shots']=[shot for shot in item['shots'] if shot!='r4_13_3']  # Cut cleanly to the face reaction.
path=EP/'scene_r7_1080p.json';path.write_text(json.dumps(s,indent=2)+'\n')
validate(path)
(EP/'scene.json').write_bytes(path.read_bytes())
camera=json.loads((EP/'camera_plan_r6.json').read_text())
for cue in camera:
    if cue['shot']=='r4_12_2':
        cue['camera']=next(shot['camera'] for shot in s['shots'] if shot['id']==cue['shot'])
        cue['finish']='Hold the entire message card and clock within frame, with Nemi visible.'
for name in ['camera_plan_r7.json','camera_plan.json']:(EP/name).write_text(json.dumps(camera,indent=2)+'\n')
(EP/'sound_plan_r7.json').write_bytes((EP/'sound_plan_r6.json').read_bytes())
print('R7 prepared: 137 seconds; long-night message and outside annotation fit; no 4K approval.')
