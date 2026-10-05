"""Local source copies with exact hashes. No original mutation or synthetic SFX."""
from pathlib import Path
import hashlib,json,shutil,subprocess
ROOT=Path(__file__).resolve().parents[2];SHORTS=ROOT/'shorts'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(src,dst):
 dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
 return {'source':str(src.relative_to(ROOT)),'file':str(dst.relative_to(SHORTS)),'sha256':sha(src),'copyHash':sha(dst)}
manifest=[]
for f in ['Impact.ttf','GochiHand-Regular.ttf','PatrickHand-Regular.ttf']:
 manifest.append(copy(ROOT/'assets/fonts'/f,SHORTS/'public/fonts'/f))
assets=json.loads((ROOT/'common/audio/sfx/root_sfx_inventory.json').read_text())['assets']
sfx=[]
for asset in assets:
 if asset['filename'] not in ['pop.mp3','whoosh.mp3','click.mp3','error.mp3','chime.mp3','bruh.mp3','key-press.mp3','ping.mp3']:continue
 src=ROOT/asset['relative_path']
 if sha(src)!=asset['sha256']:raise ValueError('SFX source changed: '+str(src))
 dest=SHORTS/'public/audio/sfx'/asset['filename'];m=copy(src,dest);manifest.append(m)
 sfx.append({'id':asset['filename'].removesuffix('.mp3'),'file':'audio/sfx/'+asset['filename'],'duration':asset['duration_seconds'],'source':m['source'],'sha256':m['sha256'],'provenance':'Existing exact root clip; no newly asserted license','category':{'whoosh':'transitions','error':'UI','click':'UI','key-press':'UI','chime':'cartoon','pop':'pops','bruh':'meme','ping':'UI'}.get(asset['filename'].removesuffix('.mp3'),'reactions')})
audit=SHORTS/'review/SFX_AUDIT.json'
if audit.exists():
 timing={a['id']:a for a in json.loads(audit.read_text())}
 for a in sfx:
  if a['id'] in timing:a.update({k:timing[a['id']][k] for k in ['activeOnset','rmsPeakAt','recommendedSourceStart','placementLead']})
(SHORTS/'shared/audio/sfx-catalog.json').write_text(json.dumps(sfx,indent=2))
for ref,ident in [('ref01','campus-reference'),('ref04','trust-reference')]:
 src=SHORTS/'review/references'/ref/'audio.wav';dst=SHORTS/'public/audio/music'/(ident+'.wav');m=copy(src,dst);m['creatorProvidedReference']=ref;manifest.append(m)
for author in ['adb','nemi']:
 folder=SHORTS/author/'assets/voice'
 if folder.exists():
  for p in folder.glob('*.wav'):manifest.append(copy(p,SHORTS/'public/audio/voice'/p.name))
(SHORTS/'review/ASSET_MANIFEST.json').write_text(json.dumps(manifest,indent=2))
geo=[]
for p in ['adb/characters/adb/ADBGeometry.gd','adb/characters/adb/ADBStyle.gd','nemi/characters/nemi/NemiGeometry.gd','nemi/characters/nemi/NemiProportions.gd','nemi/characters/nemi/NemiStyle.gd']:
 geo.append({'source':p,'sha256':sha(ROOT/p),'role':'read-only source geometry/palette snapshot'})
(SHORTS/'review/GEOMETRY_PROVENANCE.json').write_text(json.dumps(geo,indent=2))
print('Prepared',len(manifest),'exact local assets;',len(sfx),'root SFX')
