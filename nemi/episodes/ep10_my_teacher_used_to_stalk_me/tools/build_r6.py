"""Current paper-theme review with foreground blocking corrections."""
import json,runpy,sys
from pathlib import Path
EP=Path(__file__).resolve().parent.parent;ROOT=EP.parents[2]
runpy.run_path(str(EP/'tools/build_r5.py'),run_name='__main__')
s=json.loads((EP/'scene_r5_1080p.json').read_text())
s['props']=[p for p in s['props'] if not (p['kind']=='teacher_ordinary' and 'r4_02_0' in p.get('shots',[]))]
for p in s['drawings']:
    if p['kind']=='school_notebook' and p.get('layer')==0:p['layer']=1
path=EP/'scene_r6_1080p.json';path.write_text(json.dumps(s,indent=2)+'\n')
sys.path.insert(0,str(ROOT/'tools/storytime'))
from validate_scene import validate
validate(path)
(EP/'scene.json').write_bytes(path.read_bytes())
for name in ['camera_plan','sound_plan']:
    (EP/(name+'_r6.json')).write_bytes((EP/(name+'_r5.json')).read_bytes())
    (EP/(name+'.json')).write_bytes((EP/(name+'_r6.json')).read_bytes())
print('R6 current review: 137 seconds, EP06 paper treatment, no 4K approval.')
