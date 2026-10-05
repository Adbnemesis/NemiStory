"""Build the variable-length eight-Short review gallery from selected checked revisions."""
from pathlib import Path
import json,re,ast
from layout import checked_specs
ROOT=Path(__file__).resolve().parents[2]
BATCH=ROOT/'shorts/review/upgrade02'
order=['my-song','wrong-class','quick-doodle','different-energy','act-natural','adb-big-idea','nemi-tiny-cat','duo-matching-moment']
subs={
'my-song':'A shy start becomes her own music video.',
'wrong-class':'All that confidence… at the wrong classroom.',
'quick-doodle':'The sketchbook grows into a cute cat reveal.',
'different-energy':'Nemi goes all in. ADB finally joins in his own way.',
'act-natural':'Her poses work. The photographer loses his composure.',
'adb-big-idea':'One stubborn idea becomes a little flash of inspiration.',
'nemi-tiny-cat':'A moon doodle turns into a sleepy little friend.',
'duo-matching-moment':'Two different poses become one tiny matching moment.'}
tracks={x['id']:x for x in json.loads((ROOT/'shorts/assets/music/batch01/catalog.json').read_text())}
entries=[]
for p in checked_specs(ROOT, order):
 name=p.parent.name
 if not p.exists() or not (p.parent/'review/current.json').exists():continue
 c=json.loads(p.read_text());selected=json.loads((p.parent/'review/current.json').read_text());revision=selected['revision']
 folder='/'+str(p.parent.relative_to(ROOT));t=tracks[Path(c['music']['file']).stem]
 url=folder+f'/render/{c["id"]}_{revision}_1080x1920.mp4'
 entries.append({'title':c['title'],'subtitle':subs.get(name,c["title"]),'artist':t['artist'],'track':t['title'],'url':url,'poster':folder+'/review/poster.jpg','direction':folder+'/DIRECTION.md','download':url,'source':t['catalogUrl'],'cuts':[[s['frame']/30,f'{s["frame"]/30:.2f}s'] for s in c['shots']],'duration':c['frames']/30,'number':str(len(entries)+1).zfill(2),'group':'REVISED' if name in order[:5] else 'NEW STORY'})
# Established gallery layout; keep the old five-Short builder independent and reproducible.
template=ROOT/'shorts/godot/review_template.html'
if not template.exists():
 tree=ast.parse((ROOT/'shorts/godot/build_review.py').read_text())
 page=next(ast.literal_eval(n.value) for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='page' for t in n.targets))
 template.write_text(page)
page=template.read_text()
page=page.replace('Five ink edits',f'{len(entries)} ink edits').replace('Five songs. Five moods.','New motion. Same ink.').replace('INK EDITS · 01','INK EDITS · 02').replace('15-second edits · hand-authored ink, shading & doodles','Five revised edits + three new stories · poses, music & doodles')
page=page.replace('/shorts/godot/batch01/README.md','/shorts/review/upgrade02/README.md').replace('/shorts/godot/WORKFLOW.md','/shorts/godot/V3_WORKFLOW.md').replace('/shorts/godot/batch01/review/QA.md','/shorts/review/upgrade02/QA.md').replace('/shorts/godot/batch01/review/ISOLATION.md','/shorts/review/upgrade02/ISOLATION.md')
page=page.replace("document.getElementById('clock').textContent='0.00 / 15.00 s'","document.getElementById('clock').textContent='0.00 / '+e.duration.toFixed(2)+' s'")
page=page.replace("'+e.number+' / 15 SEC","'+e.number+' / '+e.duration+' SEC · '+e.group+'")
page=page.replace('.list{display:flex;', '.list{max-height:68vh;overflow:auto;padding-right:8px;display:flex;')
page=page.replace('<div class="footer">','<div class="footer"><a href="/shorts/review/upgrade02/SKILLS.md">Three ink-edit skills</a>')
page=page.replace('__DATA__',json.dumps(entries,ensure_ascii=False).replace('</','<\\/'))
out=ROOT/'shorts/review/upgrade02';out.mkdir(exist_ok=True)
(out/'index.html').write_text(page);(out/'catalog.json').write_text(json.dumps(entries,ensure_ascii=False,indent=2)+'\n')
(ROOT/'shorts/review/index.html').write_text(page)
print(f'{len(entries)} checked selections: {out}/index.html')
