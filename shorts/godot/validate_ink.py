"""Strict separate Godot music-edit specs; original storytime libraries are read-only."""
import json,re,hashlib,math,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def validate(path):
 c=json.loads(Path(path).read_text())
 def keys(obj,allowed):
  assert isinstance(obj,dict), 'Expected an object'
  assert not set(obj)-set(allowed.split()),f'Unknown fields: {set(obj)-set(allowed.split())}'
 def num(x,lo=-1e6,hi=1e6):
  assert isinstance(x,(int,float)) and not isinstance(x,bool) and math.isfinite(x) and lo<=x<=hi,f'Invalid number {x}'
 def pair(x,lo=-1e6,hi=1e6):
  assert isinstance(x,list) and len(x)==2
  for n in x:num(n,lo,hi)
 def audio_file(b):
  p=(ROOT/b['file']).resolve();assert p.is_relative_to(ROOT) and p.is_file()
  assert hashlib.sha256(p.read_bytes()).hexdigest()==b['sourceHash'],f'Audio hash mismatch: {p}'
  d=float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','default=nw=1:nk=1',str(p)]))
  num(b['sourceStart'],0,d);num(b['duration'],.001,d)
  assert b['sourceStart']+b['duration']<=d+.001,'Audio section exceeds source'
  num(b['gainDb'],-40,12)
  return p
 keys(c,'version id title fps width height frames premise music sfx actors shots theme events')
 assert c['version'] in [1,2,3] and c['fps']==30 and c['width']==1080 and c['height']==1920 and isinstance(c['frames'],int)
 v3=c['version']==3
 assert (360<=c['frames']<=750) if v3 else (240<=c['frames']<=660),'Version 3 edits must run 12–25 seconds'
 assert isinstance(c['premise'],str) and len(c['premise'])<=100
 keys(c['music'],'file sourceHash sourceStart duration gainDb');audio_file(c['music'])
 assert c['music']['duration']==c['frames']/c['fps']
 v2=c['version']>=2
 if v2:
  assert re.fullmatch(r'[a-z0-9-]+',c['id'])
  keys(c['theme'],'signature paper ink shade accent shading')
  assert c['theme']['signature'] in ['sound','runway','doodle','duo','camera']
  for k in ['paper','ink','shade','accent']:assert re.fullmatch(r'#[0-9a-fA-F]{6}',c['theme'][k])
  num(c['theme'].get('shading',.28),0,.6)
 else:assert not c['sfx'] and not c.get('events')
 ids=set()
 for a in c['actors']:
  keys(a,'id author cues'+(' motion' if v3 else ''));assert a['id'] not in ids;ids.add(a['id']);assert a['author'] in ['adb','nemi']
  lib=ROOT/('nemi/characters/nemi/NemiPose.gd' if a['author']=='nemi' else 'adb/poses/ADBPoseLibrary.gd')
  poses=set()
  for line in lib.read_text().splitlines():
   if re.match(r'^\s*"[a-z_]+"(?:,\s*"[a-z_]+")*:',line):poses.update(re.findall(r'"([a-z_]+)"',line))
  last=-1
  for cue in a['cues']:
   keys(cue,'frame pose expression gaze eyes head motion duration blinks view emotion'+(' action' if v2 else ''))
   assert isinstance(cue['frame'],int) and last<cue['frame']<c['frames'];last=cue['frame']
   assert cue['pose'] in poses,f'Unknown {a["author"]} pose {cue["pose"]}'
   pair(cue['gaze'],-1,1);num(cue.get('eyes',.95),0,1.3);num(cue.get('head',0),-30,30);num(cue.get('duration',.2),.001,2)
   assert cue.get('motion','snap') in ['snap','smooth','stepped']
   assert cue.get('view','front') in ['front','threequarter','profile','back']
   assert cue.get('emotion','shy') in ['shy','smile','shock','cover','deadpan']
   assert cue.get('action','rest') in ['rest','listen','glasses','peace','wave','phone','sketch','point']+(['thumbsup','heart_hand','shrug','hip','arms_open','chin','phone_up','book_show'] if v3 else [])
   if v2 and cue.get('view')=='back':assert cue.get('action','rest') in (['rest','listen'] if a['author']=='nemi' else ['rest']),'No invented back contact pose'
  assert a['cues'][0]['frame']==0
  if v3:
   assert a.get('motion'),'Author visible finite motion for every actor'
   last=-1
   for m in a['motion']:
    keys(m,'frame head look eyes lean gesture')
    assert isinstance(m['frame'],int) and last<m['frame']<c['frames'];last=m['frame']
    for k,lo,hi in [('head',-10,10),('look',-1,1),('eyes',0,1),('lean',-5,5),('gesture',0,1)]:num(m[k],lo,hi)
   assert a['motion'][0]['frame']==0
 last=-1
 for s in c['shots']:
  keys(s,'frame zoom center actors move angle settle'+(' direction palette stage' if v2 else '')+(' travel' if v3 else ''))
  assert isinstance(s['frame'],int) and last<s['frame']<c['frames'];last=s['frame']
  num(s['zoom'],.5,3);pair(s['center']);num(s.get('angle',0),-20,20);num(s.get('settle',5),1,15)
  assert s['move'] in ['cut','punch','pull','whip'] and set(s['actors'])<=ids and s['actors']
  assert s.get('direction',1) in [-1,1] and s.get('palette','paper') in ['paper','ink']
  assert s.get('stage','plain') in ['plain','door','columns','page','viewfinder','runway']
  if 'travel' in s:
   t=s['travel'];keys(t,'pan zoom end');pair(t['pan'],-60,60);num(t['zoom'],.97,1.03)
   assert isinstance(t['end'],int) and s['frame']<t['end']<c['frames']
  for b in s['actors'].values():
   keys(b,'position scale'+(' flip' if v2 else ''));pair(b['position']);num(b['scale'],.1,5);assert b.get('flip',1) in [-1,1]
 assert c['shots'][0]['frame']==0
 event_ids={}
 for e in c.get('events',[]):
  keys(e,'id at end kind position scale rotation accent'+(' animation' if v3 else ''))
  assert e['id'] not in event_ids;event_ids[e['id']]=e
  assert isinstance(e['at'],int) and isinstance(e['end'],int) and 0<=e['at']<e['end']<=c['frames']
  assert e['kind'] in ['stars','arcs','notes','heart','zigzag','brackets','moon','cloud','leaf','rays','dash','pencil','flash']+(['flower','spiral','ring','confetti','speedlines','cat','spark_trail'] if v3 else [])
  assert e.get('animation','pop') in ['pop','draw','orbit','burst','wipe']
  pair(e['position']);num(e.get('scale',1),.1,3);num(e.get('rotation',0),-360,360)
  if e['kind']=='flash':assert e['end']-e['at']<=2,'Flash must be brief'
  if v3 and e.get('animation') in ['orbit','burst','wipe']:assert e['end']-e['at']<=45,'Moving VFX must finish within 1.5 seconds'
 if v3:
  for i,s in enumerate(c['shots']):
   end=c['shots'][i+1]['frame'] if i+1<len(c['shots']) else c['frames']
   if 'travel' in s:assert s['travel']['end']<end,'Travel may not continue through a cut'
  # A production plan needs frequent deliberate changes. Decoded-pixel pacing QA is separate.
  changes={0,c['frames']}
  for s in c['shots']:changes.add(s['frame'])
  for a in c['actors']:
   previous=None
   for q in a['cues']:
    state=tuple(q.get(k) for k in ['view','emotion','action'])
    if state!=previous:changes.add(q['frame'])
    previous=state
   previous=None
   for m in a['motion']:
    state=tuple(m[k] for k in ['head','look','eyes','lean','gesture'])
    if state!=previous:changes.add(m['frame'])
    previous=state
  for e in c['events']:changes.add(e['at'])
  points=sorted(changes)
  assert max(b-a for a,b in zip(points,points[1:]))<=45,'Plan has an unchanging span longer than 1.5 seconds'
 for s in c['sfx']:
  keys(s,'event file sourceHash sourceStart duration gainDb offsetFrames')
  assert s['event'] in event_ids and isinstance(s.get('offsetFrames',0),int)
  p=audio_file(s);assert p.is_relative_to(ROOT/'common/audio/sfx'),'Use original recorded SFX only'
  onset=event_ids[s['event']]['at']+s.get('offsetFrames',0);assert 0<=onset<c['frames']
 return c
if __name__=='__main__':
 import sys
 c=validate(sys.argv[1]);print(f'Validated {c["title"]}: {len(c["shots"])} shots / {c["frames"]} frames, source audio hashes and event-linked drawings')
