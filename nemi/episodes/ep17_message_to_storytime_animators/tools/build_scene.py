"""Prepare EP17 from recorded Sohee words and the measured 25-second reference edit."""
import json,sys,hashlib,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]; F=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from tools.storytime.prepare_voice import prepare
R={p.stem:json.loads(p.read_text()) for p in (F/'audio/source').glob('*.json')}
# Explicit source bounds preserve words/breaths; only the long sentence gap is shortened.
placements=[('00_hook',0.0,0.0,2.56),('09_name_clean',3.54,0.0,.96),('07_identity_short',6.06,0.0,1.28),('03_challenge',9.24,0.0,2.32),('04_ambition',11.58,0.0,2.65),('05_ending',18.56,0.0,1.28),('05_ending',19.87,1.84,4.02)]
clips=[]
for stem,at,start,end in placements:
 r=R[stem]; words=[{k:w[k] for k in ('word','start','end')} for w in r['words'] if w['start']>=start and w['end']<=end]
 clips.append(dict(author='nemi',file=r['file'],sha256=r['sha256'],at=at,start=start,end=end,tempo=1.0,words=words))
plan=dict(version=1,duration=25,clips=clips);(F/'voice_plan.json').write_text(json.dumps(plan,indent=2)+'\n')
out=ROOT/'renders/message_to_storytime_nemi/audio_r1'
if not out.exists():prepare(plan,out)
prepared=F/'audio/prepared_r1';prepared.mkdir(exist_ok=True)
for n in ['narration.wav','timeline.json']:shutil.copyfile(out/n,prepared/n)
timeline=json.loads((prepared/'timeline.json').read_text());words=timeline['words']
# Nemi's canonical local proportions stay fixed relative to the drawing studio.
position=[960,570];scale=1.75
bounds=[0,76/30,117/30,145/30,192/30,228/30,290/30,430/30,459/30,486/30,498/30,540/30,566/30,663/30,25]
ids=['room_open','insert_confide','room_name','insert_close','room_identity','insert_ambition','room_boast','insert_desk','insert_stories','insert_detail','insert_triumph','insert_shrug','room_payoff','black_tail']
rooms={'room_open','room_name','room_identity','room_boast','room_payoff'}
shots=[]
for i,id in enumerate(ids):
 start,end=bounds[i:i+2];bg='nemi_creator_studio' if id in rooms else ('black' if id=='black_tail' else 'paper')
 cam={'center':[960,331],'zoom':2.17}
 if id=='insert_confide':cam={'center':[960,340],'zoom':2.6}
 if id=='insert_close':cam={'center':[960,390],'zoom':2.35}
 if id=='insert_ambition':cam={'center':[960,510],'zoom':1.18}
 if id=='insert_desk':cam={'center':[1120,530],'zoom':1.25}
 if id=='insert_stories':cam={'center':[1140,460],'zoom':1.45}
 if id=='insert_detail':cam={'center':[1290,480],'zoom':2.05}
 if id=='insert_triumph':cam={'center':[960,450],'zoom':1.6}
 if id=='insert_shrug':cam={'center':[960,430],'zoom':1.8}
 shot_position=[620,570] if id in rooms else position
 if id in rooms:cam['center'][0]=620
 shots.append(dict(id=id,start=start,end=end,background=bg,actors={} if id in {'insert_detail','black_tail'} else {'nemi':dict(position=shot_position,scale=scale)},camera=cam))
performances=[
 dict(at=0,recipe='deadpan',gaze=[0,0]),
 dict(at=76/30,recipe='school_confide',motion='snap',gaze=[0,0]),
 dict(at=117/30,recipe='deadpan',motion='snap',gaze=[0,0]),
 dict(at=145/30,recipe='uncertain',motion='snap',gaze=[-.35,-.2]),
 dict(at=192/30,recipe='deadpan',motion='snap',gaze=[0,0]),
 dict(at=228/30,recipe='prop_present',motion='snap',gaze=[.4,0],hands={'left':'open_palm_up','right':'pointing'}),
 dict(at=290/30,recipe='deadpan',motion='snap',gaze=[0,0]),
 dict(at=430/30,recipe='explaining',motion='snap',gaze=[.5,.15],hands={'right':'pointing'}),
 dict(at=459/30,recipe='prop_present',motion='snap',gaze=[.65,0]),
 dict(at=498/30,recipe='pleased',motion='snap',gaze=[0,0]),
 dict(at=540/30,recipe='soft_shrug',motion='snap',gaze=[0,0]),
 dict(at=566/30,recipe='deadpan',motion='snap',gaze=[0,0]),
]
# Word-aligned existing vowel choices and explicit closures. These are approximate word cues, not phoneme claims.
mouths=[]
for w in words:
 t=w['word'].lower().strip('.,!?');a=w['start'];b=w['end']
 shape='o_u' if any(v in t for v in ('you','to','world','now','over')) else ('ae' if any(v in t for v in ('a','name','time','story')) else 'small_open')
 if b-a>.09:
  mouths.append(dict(start=round(a+.015,6),end=round(b-.035,6),shape=shape))
  mouths.append(dict(start=round(b-.035,6),end=b,shape='closed'))
script=[]
for c in timeline['clips']:
 ww=[w for w in words if c['at']<=w['start']<c['end_at']]
 script.append(dict(actor='nemi',start=c['at'],end=c['end_at'],text=' '.join(w['word'] for w in ww)))
overlays=[]
opening=[w for w in words if w['start']<2.56]
for i,w in enumerate(opening):
 overlays.append(dict(start=w['start'],end=min(opening[i+1]['start'] if i+1<len(opening) else 76/30,76/30),text=' '.join(x['word'] for x in opening[:i+1]),style='red_intro',size=110,position=[120,735]))
for w in words:
 for shot in shots:
  if shot['id'] not in {'room_name','room_identity','room_boast'}:continue
  a=max(w['start'],shot['start']);b=min(w['end'],shot['end'])
  if a<b:overlays.append(dict(start=a,end=b,text=w['word'].strip('.,!?').upper(),style='red_serif'))
overlays.sort(key=lambda x:x['start'])
for shot in shots:
 if shot['id'] in {'room_name','room_identity','room_boast'}:
  cards=[c for c in overlays if c['style']=='red_serif' and shot['start']<=c['start']<shot['end']]
  for i,c in enumerate(cards):c['end']=cards[i+1]['start'] if i+1<len(cards) else shot['end']
props=[]
def art(kind,at,end,pos,sc,shot,**kw):
 d=dict(author='nemi',kind=kind,at=at,end=end,position=pos,scale=sc,mode='hold',shots=[shot]);d.update(kw);props.append(d)
# The reference's short object gag becomes an animator's growing story stack.
art('desk',430/30,459/30,[1450,602],[1.65,1.65],'insert_desk',layer=0)
art('laptop',430/30,459/30,[1450,551.6],[.8,.8],'insert_desk')
art('creator_story_pages',459/30,486/30,[1270,440],[1,1],'insert_stories')
art('creator_story_pages',486/30,498/30,[1290,480],[1.2,1.2],'insert_detail')
art('creator_story_pages',498/30,540/30,[1260,440],[1.1,1.1],'insert_triumph')
# Record exact event choices rather than noisy accents on every edit.
events=[dict(id='story_stack',at=459/30,intent='The first story stack replaces the reference food gag.'),dict(id='story_detail',at=486/30,intent='Quick story stack insert.'),dict(id='triumph',at=498/30,intent='Nemi confidently presents the stories before the dry confession.')]
sfx=[dict(file='res://common/audio/sfx/paper/paper_book_open_01.ogg',at=459/30,duration=.7,gain_db=-8,event='story_stack'),dict(file='res://common/audio/sfx/paper/paper_page_flip_01.ogg',at=486/30,duration=.75,gain_db=-12,event='story_detail')]
beats=[(0,76/30,'Address the animation community','Direct face and progressive red hook','Studio portrait','Immediate address.'),(76/30,145/30,'Introduce Nemi','Face then red name','Confiding bright insert then studio','Mirror reference alternation.'),(145/30,228/30,'Claim an unimpressive profession','Concerned face and overthinker word','Bright closeup then deadpan studio','Set up self-aware contrast.'),(228/30,430/30,'Make a comically grand challenge','One gesture then giant red words','Bright pose then locked studio','Escalate confidence without extra clutter.'),(430/30,566/30,'The stories are ready','Laptop and story stack','Brief bright object gag and full pose','Animator-specific visual counterpoint.'),(566/30,663/30,'The obstacle is still overthinking','Deadpan face','Studio return','Pay off the identity admission.'),(663/30,25,'Let the joke end','Black','Empty tail','Preserve reference end timing.')]
direction=dict(promise='Nemi sends a bold message to storytime animators.',want='Become the biggest storytime animator.',choice='Announce a confident challenge.',consequence='The prepared stories still meet an overthinking habit.',payoff='Her biggest rival is her own hesitation.',beats=[dict(start=a,end=b,thought=t,focus=f,visual=v,intent=i) for a,b,t,f,v,i in beats])
spec=dict(version=2,title='A Message To Every Storytime Animator — Nemi',duration=25,fps=30,caption_size=52,audio='res://'+str((prepared/'narration.wav').relative_to(ROOT)),audio_metadata='res://'+str((prepared/'timeline.json').relative_to(ROOT)),direction=direction,events=events,actors=[dict(id='nemi',author='nemi',performances=performances,mouths=mouths)],shots=shots,drawings=[],props=props,vfx=[],sfx=sfx,music=[dict(at=0,file='res://renders/message_to_storytime_reference/audio/reference_music_bed_hybrid.wav',duration=25,gain_db=-6)],script=script,captions=[],overlays=overlays)
(F/'scene.json').write_text(json.dumps(spec,indent=2)+'\n')
(F/'timing_reference.json').write_text(json.dumps(timeline,indent=2)+'\n')
print('EP17 source plan and scene saved; verify and calibrate next.')
