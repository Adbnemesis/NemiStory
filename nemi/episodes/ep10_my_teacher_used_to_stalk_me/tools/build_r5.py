"""EP06 colour-treatment revision retaining the rich 137-second R4 direction."""
import json,runpy,sys
from pathlib import Path
EP=Path(__file__).resolve().parent.parent;ROOT=EP.parents[2]
runpy.run_path(str(EP/'tools/build_r4.py'),run_name='__main__')
spec=json.loads((EP/'scene_r4_1080p.json').read_text())
for beat in spec['direction']['beats']:
    beat['visual']='EP06 cream/ink location with selective focal colour; '+beat['focus']+' carried by contextual held/live drawings and body/camera direction'
    beat['intent']='Keep one audience focus using paper continuity and the evolving evidence: '+beat['focus']
path=EP/'scene_r5_1080p.json';path.write_text(json.dumps(spec,indent=2)+'\n')
sys.path.insert(0,str(ROOT/'tools/storytime'))
from validate_scene import validate
validate(path)
for name in ['camera_plan','sound_plan']:
    (EP/(name+'_r5.json')).write_bytes((EP/(name+'_r4.json')).read_bytes())
stats=json.loads((EP/'review/R4_DESIGN.json').read_text());stats.update(revision='r5_EP06_paper_theme',palette_reference='Original Nemi EP06 How I Animate 1080p',delivery='Full 1080p review only; 4K awaits explicit satisfaction')
(EP/'review/R5_DESIGN.json').write_text(json.dumps(stats,indent=2)+'\n')
print('R5 READY:',spec['duration'],'seconds, full 1080p review; unchanged narration.')
