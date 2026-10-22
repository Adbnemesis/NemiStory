"""EP17 directs existing Nemi controls from the protected final narration clock."""
import json,re,sys
from pathlib import Path
EP=Path(__file__).resolve().parent.parent;ROOT=EP.parents[2]
sys.path.insert(0,str(ROOT/'tools/storytime'))
from validate_scene import validate
from audio_mix import calibrate_mix
from sfx_assets import validate_asset
story=json.loads((EP/'story.json').read_text());timeline=json.loads((EP/'timing_reference_r3.json').read_text())
lines=json.loads((EP/'timing_lines_r3.json').read_text())['lines'];words=timeline['words'];duration=timeline['duration']
assert 90<=duration<=120
G=[words[x['word_start_index']:x['word_end_index_exclusive']] for x in lines]
starts=[g[0]['start'] for g in G];ends=[g[-1]['end'] for g in G]
def r(t):return round(float(t),6)
def clean(s):return re.sub(r'[^a-z0-9]','',s.lower())
def key(i,p,occ=0):
 q=[clean(x) for x in p.split()];g=G[i]
 m=[j for j in range(len(g)-len(q)+1) if [clean(w['word']) for w in g[j:j+len(q)]]==q]
 if len(m)<=occ:raise ValueError(f'Anchor missing line{i}:{p}: '+str([w['word'] for w in g]))
 return g[m[occ]]['start']
events=[]
def ev(name,t,why):events.append(dict(id=name,at=r(t),intent=why));return r(t)
E={
 'upgrade':ev('upgrade',key(0,'unlock'),'Milestone imagined as an upgrade.'),
 'posture':ev('posture',key(0,'posture'),'Small self-aware posture gesture, then settle.'),
 'excuse':ev('excuse',key(1,'excuse'),'Notebook holds the old excuse.'),
 'reached':ev('reached',key(2,'reached'),'Retrospective milestone joy, one chime.'),
 'morning':ev('morning',starts[3],'Return to the same actual desk and scale.'),
 'hand':ev('hand',key(3,'hand'),'Concrete unfinished amateur hand drawing.'),
 'bananas':ev('bananas',key(3,'bananas'),'The hand silhouette delivers the visual punchline.'),
 'update':ev('update',key(4,'update'),'Deadpan missing software update metaphor.'),
 'nobody':ev('nobody',key(5,'nobody'),'Old fear: no audience.'),
 'people':ev('people',key(5,'people'),'New fear: audience expectation.'),
 'worthy':ev('worthy',key(6,'worthy'),'Next drawing must be worthy of a thousand.'),
 'redrew':ev('redrew',key(6,'redrew'),'Counterproductive drawn revision appears live.'),
 'progress':ev('progress',key(6,'Excellent'),'Dry reaction to worse drawing.'),
 'smaller':ev('smaller',key(7,'smaller'),'False promise of smaller work.'),
 'no':ev('no',key(7,'no'),'Live revision rejects the false promise.'),
 'digits':ev('digits',key(8,'digits'),'Digits are given a human meaning.'),
 'stories':ev('stories',key(8,'stories'),'People choosing the stories, symbolic illustration.'),
 'empty':ev('empty',key(9,'empty'),'The same room carries a changed meaning.'),
 'frame':ev('frame',key(10,'frame'),'Next frame modestly begun.'),
 'help':ev('help',key(10,'hand'),'Final amateur-hand callback.'),
 'confidence':ev('confidence',key(10,'confidence'),'Clear all supporting art for quiet face.'),
 'you':ev('you',key(10,'you'),'Quiet direct final connection without an extra accent.')}
cuts=[
(0,'opening','portrait','Personal admission before milestone insert.'),
(E['upgrade'],'upgrade_fantasy','medium','1000card promises a magical new self.'),
(key(0,'Same'),'same_face','portrait','Same face, less panic: let eyes and posture carry it.'),
(starts[1]-.12,'old_excuse','wide','Establish same drawing desk and planted fullbody.'),
(key(1,'Once'),'once_i_get_there','medium','Future certainty is a handwritten promise.'),
(starts[2]-.12,'milestone_joy','medium','Milestone card, open warm gesture.'),
(key(2,'quietly'),'number_might_leave','portrait','Small nervous glance acknowledges joy.'),
(starts[3]-.12,'same_studio','wide','Morning after uses identical studio geometry.'),
(key(3,'unfinished'),'unfinished_insert','insert','Read concrete unfinished paper evidence.'),
(E['hand'],'banana_hand','medium','Read Nemi and the hand page together.'),
(starts[4]-.12,'missing_update','portrait','Dry question: where is the upgrade?'),
(key(4,'tutorial'),'tutorial_character','medium','Notebook checkpoint metaphor, no fake walking.'),
(starts[5]-.12,'new_problem','portrait','Eyes register the new anxiety.'),
(E['nobody'],'nobody_watches','medium','First fear held in one short phrase.'),
(E['people'],'people_watch','portrait','Fear reversal belongs on Nemi face.'),
(starts[6]-.12,'worthy_drawing','wide','Return to grounded working place.'),
(E['redrew'],'worse_redraw','medium','Live redraw develops one piece of evidence.'),
(E['progress'],'excellent_progress','portrait','Quiet deadpan after the drawing has settled.'),
(starts[7]-.12,'smaller_work','medium','False promise revisited as one drawing.'),
(E['no'],'actually_no','medium','Scratch and replacement form the thought change.'),
(starts[8]-.12,'real_change','portrait','Soft realization with no comic effects.'),
(E['digits'],'digits_to_people','medium','1000 card yields to symbolic viewers sequentially.'),
(starts[9]-.12,'same_work','wide','Same desk, same unfinished task, different meaning.'),
(E['empty'],'not_empty','portrait','An audience connection is personal, not a dashboard.'),
(starts[10]-.12,'next_frame','wide','One modest next frame beside unchanged desk.'),
(E['help'],'hand_callback','medium','The same amateur hand remains funny.'),
(key(10,'Apparently'),'final_face','portrait','Clear evidence, hold quiet face through final line.')]
frames={'portrait':dict(center=[570,365],zoom=2.05),'medium':dict(center=[900,505],zoom=1.18),'wide':dict(center=[960,540],zoom=1.0),'insert':dict(center=[1300,485],zoom=2.05)}
shots=[];camplan=[]
for j,(a,name,frame,why) in enumerate(cuts):
 a=r(a);b=r(cuts[j+1][0] if j+1<len(cuts) else duration);camera=frames[frame].copy()
 if name in ['old_excuse','same_work']:
  camera['path']=[dict(at=a,center=[960,540],zoom=1),dict(at=r(a+.6),center=[960,540],zoom=1),dict(at=r(min(a+1.8,b-.1)),center=[940,525],zoom=1.04)]
 shots.append(dict(id=name,start=a,end=b,background='nemi_creator_studio',actors={'nemi':dict(position=[570,533.25],scale=1.75)},camera=camera))
 camplan.append(dict(start=a,end=b,spoken_anchor=next((w['word'] for w in words if w['start']>=a),'opening pause'),focus=why,framing=frame,return_or_hold='Hold until next measured thought; no idle camera.'))
P=[]
def act(t,recipe,gaze=(0,0),hands=None,face=None,motion='smooth',d=.38):
 c=dict(at=r(t),recipe=recipe,duration=d,gaze=list(gaze),hands=hands or {'left':'relaxed','right':'relaxed'})
 if face:c['face']=face
 if motion!='smooth':c['motion']=motion
 if motion=='stepped':c['step_fps']=12
 P.append(c)
act(0,'school_confide',face={'eye_openness':1.03})
act(E['upgrade'],'pleased',gaze=(.4,-.1),hands={'left':'open_palm_up','right':'relaxed'})
act(key(0,'Same'),'skeptical',face={'left_brow_offset':[0,-2]},motion='snap')
act(E['posture'],'recover',d=.3)
act(starts[1]-.12,'prop_present',gaze=(.3,.1),hands={'left':'relaxed','right':'hold_prop'},motion='snap')
act(key(1,'Once'),'school_explain',gaze=(.4,-.05),hands={'left':'open_palm_up','right':'relaxed'},motion='snap')
act(starts[2],'pleased',face={'eye_openness':1.12},hands={'left':'open_palm_up','right':'open_palm_up'})
act(key(2,'quietly'),'uncertain',gaze=(.3,.1),face={'left_brow_offset':[0,-1.4]})
act(starts[3],'school_explain',gaze=(.4,.1),hands={'left':'relaxed','right':'open_palm_up'})
act(key(3,'Same desk'),'deadpan',motion='snap')
act(E['hand'],'skeptical',gaze=(.5,.2),hands={'left':'relaxed','right':'pointing'},motion='stepped')
act(starts[4],'deadpan',motion='snap')
act(key(4,'checkpoint'),'school_question',gaze=(.3,-.1),hands={'left':'open_palm_up','right':'relaxed'})
act(starts[5],'quiet_recoil',face={'eye_openness':.96})
act(E['nobody'],'uncertain',gaze=(-.2,.05))
act(E['people'],'embarrassed',gaze=(-.2,.18),face={'eye_openness':1.05},motion='stepped')
act(starts[6],'school_resolve',gaze=(.4,.1),hands={'left':'open_palm_up','right':'relaxed'})
act(E['redrew'],'school_point',gaze=(.45,.2),hands={'left':'relaxed','right':'pointing'})
act(E['progress'],'deadpan',motion='snap')
act(starts[7],'soft_shrug',hands={'left':'open_palm_up','right':'relaxed'})
act(E['no'],'realization',gaze=(.4,.1),face={'left_brow_offset':[0,-1.6]})
act(key(7,'audience'),'embarrassed',gaze=(-.15,.15))
act(starts[8],'recover',face={'eye_openness':.93},d=.5)
act(key(8,'People'),'school_present',gaze=(.3,.05),hands={'left':'open_palm_up','right':'relaxed'})
act(starts[9],'school_confide',face={'eye_openness':.94})
act(E['empty'],'lean_in',face={'eye_openness':1.02},d=.45)
act(starts[10],'school_explain',hands={'left':'relaxed','right':'open_palm_up'})
act(E['help'],'skeptical',gaze=(.4,.1),face={'left_brow_offset':[0,-1]})
act(key(10,'Apparently'),'soft_shrug',d=.35)
act(key(10,'But'),'pleased',face={'eye_openness':.98},d=.44)
P.sort(key=lambda c:c['at'])
# Thought boundary blinks only; no periodic idle timers.
for j,c in enumerate(P):
 if j%4==0:
  nxt=P[j+1]['at'] if j+1<len(P) else duration
  if nxt-c['at']>.8:c['blinks']=[r(c['at']+.62)]
D=[];props=[]
def art(kind,a,b,pos=(1260,485),scale=(1,1),mode='hold',drawdur=1.2,shotids=None,group=D,**kw):
 c=dict(author='nemi',kind=kind,at=r(a),end=r(b),position=list(pos),scale=list(scale),mode=mode)
 if mode=='live':c['duration']=drawdur
 if shotids:c['shots']=shotids
 c.update(kw);group.append(c)
def text(txt,a,b,pos=(1100,350),size=66,mode='hold',**kw):art('text',a,b,pos,mode=mode,text=txt,size=size,**kw)
art('milestone_1000_card',E['upgrade'],key(0,'Same'))
# A held notebook is introduced at a cut, with a continuous existing grip.
art('notebook',starts[1]-.12,key(1,'Once'),scale=(.55,.55),group=props,layer=0,attach=dict(actor='nemi',hand='right',grip=[0,30],angle=-6))
text('once I get there',key(1,'Once'),starts[2]-.12,pos=(1035,390),size=36)
art('underline',key(1,'know'),starts[2]-.12,pos=(1270,460),scale=(2.0,1.6),mode='live',drawdur=.8)
art('milestone_1000_card',starts[2]-.12,key(2,'quietly'))
art('laptop',starts[3]-.12,key(3,'unfinished'),pos=(1330,668),scale=(.7,.7),group=props,layer=0)
art('milestone_bad_hand',key(3,'unfinished'),starts[4]-.12)
art('question',E['update'],key(4,'tutorial'),pos=(1170,390),scale=(2.8,2.8),mode='live',drawdur=.8)
art('notebook',key(4,'tutorial'),starts[5]-.12,pos=(1230,475),scale=(1.6,1.6))
text('still learning',key(4,'tutorial')+.25,starts[5]-.12,pos=(1110,500),size=40,mode='live',drawdur=1.2)
text('nobody watching',E['nobody'],E['people'],pos=(1030,400),size=40)
art('milestone_one_frame',starts[6]-.12,E['redrew'])
art('milestone_one_frame',E['redrew'],E['progress'],mode='live',drawdur=1.35)
art('circle',E['redrew']+1.55,E['progress'],pos=(1233,440),scale=(.45,.48),mode='live',drawdur=.65)
art('scratch',E['redrew']+2.3,E['progress'],pos=(1262,502),scale=(.65,.8),mode='live',drawdur=.7)
text('less work?',starts[7]-.12,E['no']+1.4,pos=(1090,365),size=64)
art('scratch',E['no'],E['no']+1.4,pos=(1260,395),scale=(2.1,1.9),mode='live',drawdur=.6)
text('more pressure',E['no']+.65,starts[8]-.12,pos=(1040,515),size=44,mode='live',drawdur=1.1)
art('milestone_1000_card',E['digits'],key(8,'People'))
art('creator_viewers',key(8,'People'),starts[9]-.12,pos=(1260,485),scale=(1.2,1.2),mode='live',drawdur=1.6)
art('milestone_bad_hand',starts[9]-.12,E['empty'])
art('milestone_one_frame',starts[10]-.12,E['help'],mode='live',drawdur=1.4)
art('milestone_bad_hand',E['help'],key(10,'Apparently'))
# Mouth intervals are word-derived vowel/labial approximations, not phoneme-perfect.
mouths=[]
for w in words:
 a,b=w['start'],w['end'];token=clean(w['word'])
 if b-a<.045:continue
 onset=.035 if token.startswith(('m','b','p')) else .012;close=.035 if b-a>.1 else .015
 if b-a<=onset+close+.005:continue
 if onset>.02:mouths.append(dict(start=r(a),end=r(a+onset),shape='closed'))
 vowel='o_u' if re.search(r'(oo|ou|ow|you|too)',token) else 'ae' if re.search(r'(a|ai|ei)',token) else 'small_open'
 mouths.extend([dict(start=r(a+onset),end=r(b-close),shape=vowel),dict(start=r(b-close),end=r(b),shape='closed')])
C=[];begin=0;count=0
for i,w in enumerate(words):
 count+=len(w['word'].split());last=i==len(words)-1
 gap=last or words[i+1]['start']-w['end']>=.35
 nextcount=0 if last else len(words[i+1]['word'].split())
 if count+nextcount>5 or gap or w['word'].endswith(('.',',','?','!',';',':')):
  C.append(dict(actor='nemi',words=[begin,i],start=words[begin]['start'],end=w['end'],text=' '.join(x['word'] for x in words[begin:i+1])))
  begin=i+1;count=0
script=[dict(actor='nemi',start=r(max(0,g[0]['start']-.01)),end=r(g[-1]['end']+.01),text=story['lines'][i]) for i,g in enumerate(G)]
catalog=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text());assets=catalog['assets'] if isinstance(catalog,dict) else catalog
# Existing real recordings, chosen by their visible event and actual source level.
picks=[('upgrade','viral_chime',1.6,-10),('excuse','paper_book_open_01',.55,-9),('reached','sting_achievement_bell_01',1.0,-10),('morning','computer_mouse_click_close_01',.32,-7),('bananas','viral_bruh',.817,-22),('update','viral_error',.7,-12),('people','sting_question_chime_01',.7,-11),('worthy','paper_book_paging_single_01',1.3,-6),('redrew','drawing_pencil_sketch_01',1.6,-14),('no','drawing_scratch_scribble_01',.139,-16),('stories','paper_page_turn_crisp_01',.7,-10),('frame','drawing_pencil_sketch_01',1.0,-11)]
sfx=[];soundplan=[]
for event,id,length,gain in picks:
 a=next(x for x in assets if x['id']==id);validate_asset(a,ROOT)
 at=E[event]
 # External commentary follows bananas rather than masking the spoken punchword.
 if event=='bananas':at=ends[3]+.06
 offset=r(at-E[event]);c=dict(file='res://'+a['relative_path'],at=r(at),duration=length,gain_db=gain,event=event)
 if offset:c['event_offset']=offset
 sfx.append(c);soundplan.append(dict(event=event,id=id,at=r(at),duration=length,gain_db=gain,file=c['file'],sha256=__import__('hashlib').sha256((ROOT/a['relative_path']).read_bytes()).hexdigest(),source=a.get('source'),license=a.get('license'),intended_prominence='Recognizable finite action accent beneath clear voice'))
vfx=[dict(author='nemi',kind='realization',actor='nemi',offset=[95,-65],at=E['upgrade'],end=r(E['upgrade']+.6),strength=.5,event='upgrade'),dict(author='nemi',kind='sweat',actor='nemi',offset=[80,-55],at=E['people'],end=r(E['people']+.65),strength=.45,event='people')]
thoughts=[('A milestone promises a better self.','Face then1000card','Held milestone then posture reaction','Set the false expectation.'),('An unfinished drawing has a convenient excuse.','Notebook and same studio','Held grip, future claim underline','Show the excuse concretely.'),('Reaching1000 is real joy.','Milestone card then face','Open warm gesture, nervous glance','Allow joy without claiming current count.'),('The next morning looks exactly the same.','Same desk and unfinished hand','Wide, insert, banana-hand reveal','Physical evidence defeats fantasy.'),('There was no personality update.','Dry reaction and learning notebook','Question then tutorial metaphor','Let the checkpoint joke land.'),('Being watched creates a new fear.','Changing eyes and posture','Sequential fear phrase then portrait','Reverse old anxiety into audience pressure.'),('Trying to be worthy makes the drawing worse.','Counterproductive redraw','Live page revision then settled deadpan','Let a specific choice produce cost.'),('The workload did not shrink.','False promise scratched out','Sequential scratch and replacement','Recognize self-created pressure.'),('Digits are people choosing another story.','Warm face then symbolic viewers','Quiet recognition, anonymous illustration','Give milestone a human meaning.'),('The same work has company.','Stable desk and face','Grounded wide then personal portrait','Room means something different.'),('The next frame still needs work.','Hand callback then final face','Same unfinished hand, clear to quiet portrait','Confidence absent, connection present.')]
beats=[dict(start=0 if i==0 else r(starts[i]-.12),end=duration if i==10 else r(starts[i+1]-.12),thought=x[0],focus=x[1],visual=x[2],intent=x[3]) for i,x in enumerate(thoughts)]
spec=dict(version=2,title=story['title'],duration=duration,fps=30,caption_size=52,audio='res://'+str((EP/'voice/narration_r3.wav').relative_to(ROOT)),audio_metadata='res://'+str((EP/'timing_reference_r3.json').relative_to(ROOT)),direction=dict(promise='A thousand subscribers seemed to promise a different self.',want='Feel confident enough to make the next story.',choice='Make the next drawing worthy of a thousand viewers.',consequence='The unchanged task gains an imagined larger audience for self doubt.',payoff='The milestone did not include confidence, but it included real connection.',beats=beats),actors=[dict(id='nemi',author='nemi',performances=P,mouths=mouths)],shots=shots,drawings=D,props=props,vfx=vfx,sfx=sorted(sfx,key=lambda c:c['at']),events=events,script=script,captions=C)
spec['mix']=calibrate_mix(spec,ROOT)
(EP/'scene_r6_1080p.json').write_text(json.dumps(spec,indent=2)+'\n');validate(EP/'scene_r6_1080p.json')
(EP/'camera_plan.json').write_text(json.dumps(camplan,indent=2)+'\n');(EP/'sound_plan.json').write_text(json.dumps(dict(cues=soundplan,intentional_silence=['Milestone happiness aftermath','Larger audience self-doubt admission','Real change opening','Empty room admission','Final confidence/Butyou were portrait']),indent=2)+'\n')
print('EP17 valid',duration,'seconds',len(shots),'shots',len(P),'acting',len(D),'art',len(C),'captions',len(sfx),'SFX')
