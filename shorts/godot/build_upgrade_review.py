"""Build the variable-length eight-Short review gallery from selected checked revisions."""
from pathlib import Path
import json,re,ast,argparse
from layout import checked_specs
ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output',default='motion04',choices=('upgrade02','revision03','motion04'))
parser.add_argument('--revision',help='Preview an exported revision without changing the selected review record.')
parser.add_argument('--revisions-json',type=Path,help='Preview a per-Short id→revision map without changing selected records.')
args=parser.parse_args()
if args.revision and not args.revision.isalnum():parser.error('Use an alphanumeric revision.')
if args.revision and args.revisions_json:parser.error('Choose a single revision or a per-Short map.')
preview_revisions=json.loads(args.revisions_json.read_text()) if args.revisions_json else {}
if not isinstance(preview_revisions,dict) or any(not isinstance(v,str) or not v.isalnum() for v in preview_revisions.values()):parser.error('Revision maps need alphanumeric string values.')
BATCH=ROOT/'shorts/review'/args.output
order=['my-song','wrong-class','quick-doodle','different-energy','act-natural','adb-big-idea','nemi-tiny-cat','duo-matching-moment']
subs={
'my-song':'A shy start becomes her own music video.',
'wrong-class':'All that confidence… at the wrong classroom.',
'quick-doodle':'The sketchbook grows into a cute cat reveal.',
'different-energy':'Nemi goes all in. ADB finally joins in his own way.',
'act-natural':'Trying to look natural ends in one honest candid.',
'adb-big-idea':'One stubborn idea becomes a little flash of inspiration.',
'nemi-tiny-cat':'A moon doodle turns into a sleepy little friend.',
'duo-matching-moment':'Two different poses become one tiny matching moment.'}
tracks={x['id']:x for x in json.loads((ROOT/'shorts/assets/music/batch01/catalog.json').read_text())}
entries=[]
for p in checked_specs(ROOT, order):
 name=p.parent.name
 if not p.exists() or not (p.parent/'review/current.json').exists():continue
 c=json.loads(p.read_text());selected=json.loads((p.parent/'review/current.json').read_text());revision=preview_revisions.get(c['id'],args.revision or selected['revision'])
 if not (p.parent/'render'/f'{c["id"]}_{revision}_1080x1920.mp4').exists():raise FileNotFoundError(f'Missing export for {name}: {revision}')
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
page=page.replace("'+e.number+' / 15 SEC","'+e.number+' / '+Number(e.duration.toFixed(2))+' SEC · '+e.group+'")
page=page.replace('.list{display:flex;', '.list{max-height:68vh;overflow:auto;padding-right:8px;display:flex;')
page=page.replace('<div class="footer">','<div class="footer"><a href="/shorts/review/upgrade02/SKILLS.md">Three ink-edit skills</a>')
page=page.replace('__DATA__',json.dumps(entries,ensure_ascii=False).replace('</','<\\/'))
if args.output=='revision03':
 page=page.replace('/shorts/review/upgrade02/','/shorts/review/revision03/').replace('New motion. Same ink.','Same ink. Stronger poses.').replace('INK EDITS · 02','INK EDITS · 03').replace('Five revised edits + three new stories · poses, music & doodles','Eight recuts · whole-body poses, music-led transitions & ink accents')
 # Keep the historical batch gallery and its manifest intact.
 page=page.replace('REVISED','RECUT').replace('NEW STORY','RECUT')
elif args.output=='motion04':
 page=page.replace('/shorts/review/upgrade02/','/shorts/review/motion04/').replace('New motion. Same ink.','Ink with rhythm.').replace('INK EDITS · 02','INK EDITS · 04').replace('Five revised edits + three new stories · poses, music & doodles','Eight motion edits · camera, acting & sound on one music clock')
 page=page.replace('REVISED','MOTION EDIT').replace('NEW STORY','MOTION EDIT')
out=BATCH;out.mkdir(exist_ok=True)
(out/'index.html').write_text(page);(out/'catalog.json').write_text(json.dumps(entries,ensure_ascii=False,indent=2)+'\n')
(ROOT/'shorts/review/index.html').write_text(page)
print(f'{len(entries)} checked selections: {out}/index.html')
