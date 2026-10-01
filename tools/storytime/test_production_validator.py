import copy
import json
from validate_scene import ROOT,validate_data
from validate_production import validate_production
base=json.loads((ROOT/'common/storytime/examples/storytime_direction_10s.json').read_text())
validate_production(base,ROOT,validate_data,check_assets=False)
cases=[]
def case(edit):
 spec=copy.deepcopy(base);edit(spec);cases.append(spec)
case(lambda s:s['shots'][1].update(start=3.9))
case(lambda s:s['shots'][1].update(background='invented'))
case(lambda s:s['shots'][0]['actors'].update(ghost={'position':[0,0],'scale':1}))
case(lambda s:s['props'][0].update(mode='live'))
case(lambda s:s['drawings'][0].update(mode='fade'))
case(lambda s:s['drawings'][3].pop('duration'))
case(lambda s:s['props'][-1]['attach'].update(actor='nemi'))
case(lambda s:s['actors'][1]['performances'][1].update(hands={'right':'hold_prop'}))
case(lambda s:s['actors'][0]['mouths'][0].update(start=5,end=5.2))
case(lambda s:s['sfx'][0].update(gain_db=0))
case(lambda s:s['sfx'][0].update(duration=4))
case(lambda s:s['vfx'][0].update(end=8))
case(lambda s:s['drawings'][0].update(shots=['missing_shot']))
case(lambda s:s['actors'][0]['performances'][1].update(gaze=[2,0]))
case(lambda s:s['sfx'][-1].update(at=6.2))
case(lambda s:s['actors'][0]['performances'][1].update(motion='random'))
case(lambda s:s['actors'][0]['performances'][1].update(motion='stepped',step_fps=60))
case(lambda s:s['actors'][0]['performances'][1].update(face={'voice_pitch':1.2}))
case(lambda s:s['actors'][1]['performances'][1].update(face={'eye_openness_left':9}))
case(lambda s:s['actors'][0].update(hand_paths={'right':[{'at':2,'position':[80,-10]},{'at':1,'position':[100,-20]}]}))
case(lambda s:s['props'][-1].update(attach_start=6,attach_end=5))
case(lambda s:s['shots'][0]['camera'].update(path=[{'at':0,'center':[960,540],'zoom':4}]) if 'camera' in s['shots'][0] else s['shots'][0].update(camera={'path':[{'at':0,'center':[960,540],'zoom':4}]}))
case(lambda s:s.update(mix={'master_gain_db':0,'target_lufs':-18,'peak_dbfs':0}))
case(lambda s:s['drawings'][0].update(event_offset=-.2))
case(lambda s:s['actors'][0].update(hand_path_window=[3,2]))
for spec in cases:
 try:validate_production(spec,ROOT,validate_data,check_assets=False)
 except (ValueError,KeyError,TypeError):continue
 raise AssertionError('Invalid production accepted')
proof=json.loads((ROOT/'common/storytime/examples/refinement_10s/scene.json').read_text())
validate_production(proof,ROOT,validate_data,check_assets=False)
metadata=ROOT/proof['audio_metadata'].removeprefix('res://')
if metadata.exists():
 validate_data(proof)
 broken=copy.deepcopy(proof);broken['captions'][0]['start']+=.2
 try:validate_data(broken)
 except ValueError:pass
 else:raise AssertionError('Caption drift accepted')
 print('PASS: local audio identity and caption drift rejection')
else:
 print('SKIP: audio identity/caption checks need local approved proof recordings')
print('PASS: production structure, new directing proof and 25 rejected direction mistakes')
