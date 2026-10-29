"""Build the wider, 48-second integrated review story using the shared stage."""
import json,subprocess,re
from pathlib import Path
from prepare_voice import ROOT,prepare,digest
from audio_mix import calibrate_mix
from validate_scene import validate_data
folder=ROOT/'common/storytime/examples/story_review_48s';folder.mkdir(parents=True,exist_ok=True)
source=json.loads((folder/'source_words.json').read_text())
placements=[(0,.7,1),(6,4.8,1.08),(1,11.9,1),(2,15.2,1.05),(7,20.5,1),(3,24.5,1),(8,28.6,1.08),(4,33.9,1),(5,38.1,1),(9,42.5,1)]
clips=[]
for index,at,tempo in placements:
 r=source[index];path=ROOT/r['file'][6:]
 duration=float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','default=nw=1:nk=1',str(path)]))
 words=[dict(word=w['word'].strip(),start=w['start'],end=min(w['end'],duration)) for w in r['words'] if w['start']<min(w['end'],duration)]
 clips.append(dict(author=r['author'],file=r['file'],sha256=r['sha256'],at=at,start=0,end=duration,tempo=tempo,words=words))
plan=dict(version=1,duration=48,clips=clips)
audio=ROOT/'renders/storytime_review_48s/audio'
if audio.exists():
 timeline=json.loads((audio/'timeline.json').read_text());assert timeline['audio_sha256']==digest(audio/'narration.wav')
 assert len(timeline['clips'])==len(clips)
 for saved,wanted in zip(timeline['clips'],clips):
  assert all(saved[k]==wanted[k] for k in ['file','sha256','at','start','end','tempo'])
else:timeline=prepare(plan,audio)
(folder/'voice_plan.json').write_text(json.dumps(plan,indent=2)+'\n')
(folder/'timing_reference.json').write_text(json.dumps(timeline,indent=2)+'\n')
words=timeline['words']
def word_time(text,after=0):
 return next(w['start'] for w in words if re.sub(r'\W','',w['word'].lower())==text and w['start']>=after)
def cue(at,recipe,**kw):return dict(at=at,recipe=recipe,**kw)
def pos(x,y,scale):return dict(position=[x,y],scale=scale)
shots=[dict(id='promise',start=0,end=4.5,background='studio_nemi',actors={'nemi':pos(510,570,1.85)}),
 dict(id='setup',start=4.5,end=11.6,background='studio_nemi',actors={'nemi':pos(510,570,1.85)}),
 dict(id='plan',start=11.6,end=15,background='studio_adb',actors={'adb':pos(510,540,1.85)}),
 dict(id='inventory',start=15,end=20.2,background='thought',actors={'nemi':pos(510,570,1.85)}),
 dict(id='coffee',start=20.2,end=28.3,background='studio_adb',actors={'adb':pos(580,550,1.85)}),
 dict(id='draw',start=28.3,end=33.6,background='room',actors={'nemi':pos(510,570,1.85)}),
 dict(id='circle',start=33.6,end=37.8,background='room',actors={'nemi':pos(510,570,1.85)}),
 dict(id='verdict',start=37.8,end=42.3,background='paper',actors={'adb':pos(510,540,1.85)}),
 dict(id='payoff',start=42.3,end=48,background='evening',actors={'nemi':pos(470,600,1.65),'adb':pos(930,575,1.7)})]
nemi=[cue(0,'pleased'),cue(2.8,'lean_in',duration=.35),cue(4.5,'explaining',duration=.45),cue(8.4,'uncertain',duration=.4,blinks=[10.9]),cue(15,'prop_present',duration=.45),cue(18.3,'quiet_recoil',duration=.3),cue(28.3,'recover',duration=.45),cue(30,'explaining',duration=.4,hands={'right':'pointing'}),cue(33.6,'pleased',duration=.4),cue(36.8,'uncertain',duration=.3),cue(42.3,'embarrassed',duration=.4,blinks=[43.8]),cue(45.6,'pleased',duration=.45)]
adb=[cue(0,'listening'),cue(11.6,'explaining',duration=.45),cue(13.4,'skeptical',duration=.35,blinks=[14.3]),cue(20.2,'weight_shift',duration=.45),cue(22.2,'deadpan',motion='snap'),cue(24.2,'listening',duration=.3,hands={'right':'relaxed'}),cue(24.7,'listening',motion='snap',hands={'right':'holding_cup'}),cue(26.1,'skeptical',duration=.35,hands={'right':'holding_cup'}),cue(27.5,'listening',motion='snap',hands={'right':'relaxed'}),cue(37.8,'soft_shrug',duration=.4),cue(40.3,'deadpan',motion='snap',blinks=[41.9]),cue(42.3,'explaining',duration=.4),cue(45.7,'pleased',duration=.35)]
# Both arms retain their authored lengths; left is an independent quiet counterpose.
hand_paths={'right':[{'at':0,'position':[75,30],'angle':0},{'at':24.2,'position':[75,30],'angle':0},{'at':24.7,'position':[105,-10],'angle':-90,'bend':[5,-8]},{'at':25.35,'position':[123,-58],'angle':-90,'bend':[7,-4]},{'at':26.5,'position':[123,-58],'angle':-90},{'at':27.5,'position':[105,-10],'angle':-90,'bend':[8,0]},{'at':28.05,'position':[75,30],'angle':0}]}
# Hand paths only own the coffee action interval. Outside it recipes own arms.
# New bounded path support is supplied through actor.hand_path_window.
actors=[dict(id='nemi',author='nemi',performances=nemi,mouths=[]),dict(id='adb',author='adb',performances=adb,mouths=[],hand_paths=hand_paths,hand_path_window=[20.2,28.3])]
script=[];captions=[];offset=0
for (index,at,tempo),clip in zip(placements,clips):
 r=source[index];end=at+clip['end']/tempo
 script.append(dict(actor=r['author'],start=at,end=end,text=r['text']))
 selected=words[offset:offset+len(clip['words'])]
 # Phrase/punctuation boundaries matter more than always filling five words.
 group=[]
 for j,w in enumerate(selected):
  group.append((offset+j,w))
  if len(group)==5 or w['word'].endswith(('.', '?', '!')) or j==len(selected)-1:
   captions.append(dict(actor=r['author'],words=[group[0][0],group[-1][0]],start=group[0][1]['start'],end=group[-1][1]['end'],text=' '.join(x[1]['word'] for x in group)));group=[]
  span=w['end']-w['start']
  if span>.045:
   shape=('o_u' if re.search(r'oo|o[ru]|one',w['word'],re.I) else 'small_open') if r['author']=='nemi' else ('talk_round' if 'o' in w['word'].lower() else 'talk_open')
   actors[0 if r['author']=='nemi' else 1]['mouths'].append(dict(start=w['start']+.01,end=w['end']-.025,shape=shape))
 offset+=len(selected)
drawings=[];props=[];vfx=[];sfx=[]
def art(group,author,kind,at,end,position,scale=1,**kw):
 item=dict(author=author,kind=kind,at=at,end=end,position=position,scale=[scale,scale],mode='hold',**kw);group.append(item);return item
def text(author,label,at,end,position,size=56,**kw):
 return art(drawings,author,'text',at,end,position,text=label,size=size,**kw)
text('nemi','one tiny drawing',0,4.5,[1000,140],64)
art(props,'nemi','notebook',0,4.5,[1280,555],1.5)
# The workstation builds around the intention; props stay finished when introduced.
art(props,'nemi','desk',4.5,11.6,[1250,660],1.25,layer=0)
art(props,'nemi','laptop',word_time('setup'),11.6,[1220,583],1.2)
art(props,'nemi','mug',word_time('apparently'),11.6,[1515,642],1.1)
text('nemi','the perfect setup',5.3,11.6,[995,140],56)
text('adb','plan',11.6,15,[1100,310],66)
text('adb','plan the plan',12.5,15,[1040,560],60)
art(drawings,'adb','arrow',12.3,15,[1240,490],1.2,**{'duration':.65,'event':'planning','event_offset':-.1})['mode']='live'
for kind,key,xy,sz in [('notebook','notebook',[1040,550],1.25),('mug','coffee',[1410,540],1.55),('tabs','tabs',[1320,600],1.7)]:
 at=word_time(key,15)
 art(props,'nemi',kind,at,20.2,xy,sz)
text('nemi','essentials',15,18.4,[1030,140],60)
art(drawings,'nemi','scratch',18.4,20.2,[1210,185],2,duration=.3, event='too_many',event_offset=-.933333)['mode']='live'
text('nemi','somehow necessary',18.8,20.2,[960,760],54)
# Mug handle grip: wrist (-90 degrees) + local palm [8,6] == mug handle [35,-18].
art(props,'adb','desk',20.2,28.3,[1020,565],1.45,layer=0)['scale']=[1.45,1.85]
art(props,'adb','mug',20.2,28.3,[727.075,546.67],.9,layer=0,attach=dict(actor='adb',hand='right',grip=[35,-18],angle=90),attach_start=24.7,attach_end=27.5)
art(props,'adb','laptop',20.2,28.3,[1160,473],1.35)
text('adb','drawing: pending',20.2,28.3,[1020,140],58)
art(props,'adb','tabs',word_time('window',24),28.3,[1500,370],.8)
line=word_time('line',28)
art(drawings,'nemi','circle',line-.2,42.3,[1260,540],2.5,duration=2.0,event='first_line',event_offset=-.2)['mode']='live'
text('nemi','no more planning',28.3,33.6,[990,140],56)
text('nemi','a circle',33.6,37.8,[1100,140],60)
text('adb','40 minutes later',37.8,42.3,[1040,210],55)
art(drawings,'nemi','circle',42.3,48,[1500,570],1.7)
eyes=word_time('eyes',42)
for x in [1458,1538]:art(drawings,'nemi','circle',eyes,48,[x,545],.12,duration=.35,event='eyes')['mode']='live'
art(drawings,'nemi','underline',eyes+.45,48,[1490,603],.45,duration=.4)['mode']='live'
text('adb','hired',word_time('career',42),48,[1400,760],60,duration=.75)['mode']='live'
for author,kind,at,end in [('nemi','tension',19.4,20.15),('adb','focus',22.6,23.25),('nemi','realization',36.7,37.4),('nemi','relief',45.7,46.45)]:
 vfx.append(dict(author=author,kind=kind,actor=author,offset=[90,-40],at=at,end=end,strength=1))
for at,file,duration,gain in [(word_time('setup'),'computer/computer_mouse_fast_double_01.wav',.18,-25),(line-.2,'drawing/drawing_scratch_scribble_01.ogg',.139,-27),(word_time('window',24),'computer/computer_mouse_fast_double_01.wav',.18,-27),(eyes,'drawing/drawing_scratch_scribble_01.ogg',.139,-28),(27.5,'impacts/impact_glass_clink_01.ogg',.45,-24)]:
 sfx.append(dict(file='res://common/audio/sfx/'+file,at=at,duration=duration,gain_db=gain))
# Name events with final measured words; offsets express preparation explicitly.
events=[dict(id='planning',at=12.4,intent='The plan acquires its own plan.'),dict(id='too_many',at=19.333333,intent='Preparation becomes excessive.'),dict(id='first_line',at=line,intent='The first actual mark.'),dict(id='eyes',at=eyes,intent='Turn the imperfect circle into a character.'),dict(id='mug_down',at=27.5,intent='The mug returns to the desktop.')]
for sound in sfx:
 if abs(sound['at']-(line-.2))<.001:sound.update(event='first_line',event_offset=-.2)
 if abs(sound['at']-eyes)<.001:sound.update(event='eyes')
 if sound['at']==27.5:sound.update(event='mug_down')
briefs=[('I can do one small thing.','Nemi and the blank notebook','Held art','Establish a modest promise.'),('The workspace must be perfect.','Desk and Nemi','Props appear as decisions','Reveal preparation replacing action.'),('Even the plan needs a plan.','ADB and his margin diagram','One live arrow','Show his dry interpretation.'),('Everything is necessary.','Notebook, coffee, tabs','Held props and a correction','Escalate the distraction.'),('The coffee is real; the drawing is not.','ADB hand, mug and face','Full pickup and putdown','Make contact and bodily acting inspectable.'),('Actually begin.','Nemi and emerging line','Live drawing','Let the creation take visible time.'),('That is all?','Nemi expression and finished mark','Still doodle','Let pride become doubt.'),('A professional potato.','ADB and the same mark','Held art and dry reaction','Reinterpret the work.'),('Give the mistake a purpose.','Both characters and the face doodle','Eyes, smile, hiring label','Complete the callback with a changed meaning.')]
direction=dict(promise='A tiny drawing should be easy.',want='Make one drawing before bed.',choice='Prepare the perfect workspace first.',consequence='The preparation becomes the entire project.',payoff='The imperfect circle gets a face and a career.',beats=[dict(start=s['start'],end=s['end'],thought=b[0],focus=b[1],visual=b[2],intent=b[3]) for s,b in zip(shots,briefs)])
spec=dict(version=2,title='The Perfect Setup — 48 second integrated review',duration=48,fps=30,caption_size=48,audio='res://renders/storytime_review_48s/audio/narration.wav',audio_metadata='res://renders/storytime_review_48s/audio/timeline.json',direction=direction,actors=actors,shots=shots,drawings=drawings,props=props,vfx=vfx,sfx=sfx,events=events,script=script,captions=captions)
spec['mix']=calibrate_mix(spec,ROOT);validate_data(spec)
(folder/'scene.json').write_text(json.dumps(spec,indent=2)+'\n')
print(folder/'scene.json')
