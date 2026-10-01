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
for spec in cases:
 try:validate_production(spec,ROOT,validate_data,check_assets=False)
 except (ValueError,KeyError,TypeError):continue
 raise AssertionError('Invalid production accepted')
print('PASS: production structure and 15 rejected direction mistakes')
