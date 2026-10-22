"""Direct EP16 on the final edited recording through the shared v2 stage."""
import json,re,sys
from pathlib import Path
EP=Path(__file__).resolve().parent.parent
ROOT=EP.parents[2]
sys.path.insert(0,str(ROOT/'tools/storytime'))
from validate_scene import validate
from audio_mix import calibrate_mix
from sfx_assets import validate_asset
story=json.loads((EP/'story.json').read_text())
timeline=json.loads((EP/'timing_reference_r1.json').read_text())
line_map=json.loads((EP/'timing_lines_r1.json').read_text())['lines']
words=timeline['words']; duration=timeline['duration']
assert 90<=duration<=120,f'Hard runtime cap: {duration}'
groups=[words[x['word_start_index']:x['word_end_index_exclusive']] for x in line_map]
starts=[x[0]['start'] for x in groups]; ends=[x[-1]['end'] for x in groups]
def clean(s):return re.sub('[^a-z0-9]','',s.lower())
def key(line,phrase,occurrence=0):
 target=[clean(x) for x in phrase.split()];g=groups[line]
 indexes=[i for i in range(len(g)-len(target)+1) if [clean(w['word']) for w in g[i:i+len(target)]]==target]
 if len(indexes)<=occurrence:raise ValueError(f'Missing measured anchor line{line}: {phrase}; '+ ' '.join(w['word'] for w in g))
 return g[indexes[occurrence]]['start']
def r(t):return round(float(t),6)
events=[]
def event(name,t,intent):events.append(dict(id=name,at=r(t),intent=intent));return r(t)
E={
 'question':event('question',key(0,'what do you do'),'Offscreen listener asks; eyes lead embarrassed thought.'),
 'electricity':event('electricity',key(1,'electricity'),'Dry hold after a uselessly vague answer.'),
 'creative':event('creative',key(2,'creative stuff'),'The evasive label grows more vague.'),
 'repeat':event('repeat',key(2,'creative stuff',1),'Repeat the label as a question, then cross it out.'),
 'animator':event('animator',key(3,'animator'),'The answer Nemi could have given.'),
 'blink':event('blink',key(3,'blink'),'Confident private explanation contrasts public hesitation.'),
 'computer':event('computer',key(3,'computer activities'),'Public answer collapses to computer activities.'),
 'phone':event('phone',key(4,'phone'),'Phone becomes the evidence Nemi fears showing.'),
 'video':event('video',key(5,'video'),'Open the completed story video as an evidence insert.'),
 'hair':event('hair',key(5,'hair'),'A small draft illustration replaces apologetic explanation.'),
 'tour':event('tour',key(6,'emergency exits'),'Deadpan over-explanation, hold without literal exit icons.'),
 'joke':event('joke',key(7,'joke'),'Listener laughs at the intended joke; Nemi registers it.'),
 'not_me':event('not_me',key(7,'not at me'),'Quiet personal recognition, no reaction meme.'),
 'made':event('made',key(8,'made that'),'Read the follow-up on Nemi’s face.'),
 'wandered':event('wandered',key(8,'wandered'),'Dry look at the held story pages; no walking metaphor.'),
 'yeah':event('yeah',key(9,'yeah'),'Commit to the answer with a small grounded weight change.'),
 'stories':event('stories',key(9,'animated stories'),'Short animated stories lettering completes the honest answer.'),
 'operating':event('operating',key(9,'cafe'),'Return wide; cafe remains ordinary and quiet.'),
 'next':event('next',key(10,'next bit'),'Viewer wanted the next part, rather than a certificate.'),
 'audition':event('audition',key(10,'audition'),'Reflective portrait; stop criticizing the work first.'),
 'claim':event('claim',key(11,'animator'),'Claim the word animator with quiet pride.'),
 'hands':event('hands',key(11,'hands'),'One held notebook callback to continued learning.'),
 'finished':event('finished',key(11,'finished'),'Settle and hold the final soft face.')}
# Each cut is a measured thought or pause. Constant actor scale preserves set size.
cuts=[
 (0,'opening','attachment_cafe_r5','portrait','Start directly in the uncomfortable question.'),
 (key(0,'I was'),'cafe_establish','attachment_cafe_r5','wide','Establish real cafe furniture and room geography.'),
 (key(0,'apparently'),'lawyer_hold','attachment_cafe_r5','portrait','Quiet embarrassed face carries the metaphor.'),
 (starts[1]-.10,'computer_answer','attachment_cafe_r5','medium','First evasive answer; listener eyeline right.'),
 (key(1,'so does'),'card_machine','attachment_cafe_r5','wide','Keep the ordinary cafe in view while the comparison lands.'),
 (E['electricity'],'electricity_hold','attachment_cafe_r5','portrait','Dry camera lock, no active doodles.'),
 (starts[2]-.10,'followup','attachment_cafe_r5','portrait','Hear the next question before the shoulders react.'),
 (E['creative'],'creative_label','attachment_cafe_r5','medium','A short label is the evasive answer.'),
 (key(2,'excellent'),'candles_hold','attachment_cafe_r5','portrait','Understated embarrassment; no literal candle distraction.'),
 (starts[3]-.10,'could_say','attachment_cafe_r5','medium','Reveal the one word Nemi could have used.'),
 (key(3,'at home'),'private_confidence','nemi_creator_studio','medium','Contrast with confidence at the actual drawing desk.'),
 (key(3,'in public'),'public_collapse','attachment_cafe_r5','portrait','Snap to the social freeze and hold.'),
 (starts[4]-.10,'show_request','attachment_cafe_r5','wide','Re-establish the cafe before evidence enters.'),
 (E['phone'],'phone_fear','attachment_cafe_r5','phone','Keep the held phone and anxious face together.'),
 (starts[5]-.10,'open_video','attachment_cafe_r5','medium','Show Nemi and the story video evidence.'),
 (key(5,'then immediately'),'apology_tour','attachment_cafe_r5','portrait','The apologetic explanation takes over the face.'),
 (E['hair'],'old_drafts','attachment_cafe_r5','medium','Two small draft pages show the imperfect work.'),
 (starts[6]-.10,'emergency_tour','attachment_cafe_r5','portrait','Still dry delivery, no extra exit diagram.'),
 (starts[7]-.10,'listener_laugh','attachment_cafe_r5','phone','Gaze to the listener, then register the intended joke.'),
 (E['not_me'],'not_at_me','attachment_cafe_r5','portrait','Quiet recognition in eyes and brow.'),
 (key(7,'an entire evening'),'evening_work','nemi_creator_studio','medium','A held page represents the effort; no clock montage.'),
 (starts[8]-.10,'terrifying_followup','attachment_cafe_r5','portrait','Return to the question with restrained surprise.'),
 (key(8,'I almost'),'sort_of','attachment_cafe_r5','medium','The old self-minimizing answer almost returns.'),
 (E['wandered'],'wandered_hold','attachment_cafe_r5','portrait','Hold the sheepish look without literal wandering drawings.'),
 (starts[9]-.10,'honest_answer','attachment_cafe_r5','phone','Keep listener eyeline and held work while Nemi says yes.'),
 (E['stories'],'claim_stories','attachment_cafe_r5','medium','The honest two-word label replaces the vague answers.'),
 (E['operating'],'cafe_operates','attachment_cafe_r5','wide','Ordinary room callback: nothing catastrophic happened.'),
 (starts[10]-.10,'no_certificate','attachment_cafe_r5','medium','The page, not a credential, is the evidence.'),
 (E['audition'],'self_audition','attachment_cafe_r5','portrait','Quiet face admits who was doing the judging.'),
 (starts[11]-.10,'next_time','nemi_creator_studio','wide','Narrator returns home with the same grounded scale.'),
 (E['claim'],'im_animator','nemi_creator_studio','medium','Short handwritten animator settles beside Nemi.'),
 (key(11,'apparently'),'before_finished','nemi_creator_studio','portrait','End on the personal admission and a settled soft face.')]
cuts=[(r(a),b,c,d,e) for a,b,c,d,e in cuts]
assert all(cuts[i][0]<cuts[i+1][0] for i in range(len(cuts)-1))
shots=[];camera_plan=[]
for i,(a,name,bg,frame,intent) in enumerate(cuts):
 b=cuts[i+1][0] if i+1<len(cuts) else duration
 cam={'wide':dict(center=[960,540],zoom=1),'medium':dict(center=[900,485],zoom=1.16),'portrait':dict(center=[570,365],zoom=2.0),'phone':dict(center=[690,420],zoom=1.5)}[frame]
 if name in ('cafe_establish','next_time') and b-a>2:
  cam['path']=[dict(at=a,center=[960,540],zoom=1),dict(at=r(a+.65),center=[960,540],zoom=1),dict(at=r(min(b-.05,a+1.65)),center=[940,530],zoom=1.03)]
 shots.append(dict(id=name,start=a,end=b,background=bg,actors={'nemi':dict(position=[570,533.25],scale=1.75)},camera=cam))
 camera_plan.append(dict(start=a,end=b,spoken_anchor=next((w['word'] for w in words if w['start']>=a),'opening pause'),focus=intent,framing=frame,reason=intent,return_or_hold='Hold after settling until the next thought.'))
def shot(name):return next(s for s in shots if s['id']==name)
def end(name):return shot(name)['end']
phone_start=E['phone'];phone_end=shot('next_time')['start']
performances=[]
def act(t,recipe,gaze=(0,0),hands=None,face=None,d=.35,motion='smooth',ev=None):
 cue=dict(at=r(t),recipe=recipe,duration=d,gaze=list(gaze),hands=hands or {'left':'relaxed','right':'relaxed'})
 if face:cue['face']=face
 if motion!='smooth':cue['motion']=motion
 if motion=='stepped':cue['step_fps']=12
 if ev:cue['event']=ev
 performances.append(cue)
act(0,'listening',gaze=(.55,0),face={'eye_openness':1.02})
act(E['question'],'embarrassed',gaze=(-.3,.2),ev='question')
act(key(0,'normal'),'recover',gaze=(0,0))
act(key(0,'lawyer'),'deadpan',motion='snap')
act(starts[1],'uncertain',gaze=(.5,0),hands={'left':'open_palm_up','right':'relaxed'})
act(key(1,'so does'),'skeptical',gaze=(.3,.05))
act(E['electricity'],'deadpan',motion='snap',ev='electricity')
act(starts[2],'listening',gaze=(.6,0))
act(E['creative'],'soft_shrug',gaze=(.5,-.05),hands={'left':'open_palm_up','right':'relaxed'},ev='creative')
act(E['repeat'],'quiet_recoil',gaze=(.1,.15),ev='repeat')
act(key(2,'excellent'),'deadpan',motion='snap')
act(key(2,'suspicious'),'embarrassed',gaze=(-.25,.2))
act(starts[3],'school_confide',gaze=(0,0))
act(key(3,'at home'),'school_explain',gaze=(.35,-.05),hands={'left':'open_palm_up','right':'pointing'})
act(E['blink'],'lean_in',gaze=(.4,-.05),hands={'left':'relaxed','right':'pointing'},ev='blink')
act(key(3,'in public'),'deadpan',motion='snap')
act(starts[4],'listening',gaze=(.55,0))
act(phone_start,'prop_present',gaze=(.3,.2),hands={'left':'relaxed','right':'hold_prop'},motion='snap',ev='phone')
act(key(4,'bad hand'),'embarrassed',gaze=(.25,.3),hands={'left':'hand_to_cheek','right':'hold_prop'})
act(starts[5],'school_present',gaze=(.45,.15),hands={'left':'open_palm_up','right':'hold_prop'})
act(key(5,'then immediately'),'school_explain',gaze=(.4,.05),hands={'left':'pointing','right':'hold_prop'})
act(E['hair'],'uncertain',gaze=(.35,.12),hands={'left':'open_palm_up','right':'hold_prop'},ev='hair')
act(key(5,'timing'),'skeptical',gaze=(.15,.1),hands={'left':'relaxed','right':'hold_prop'})
act(starts[6],'deadpan',hands={'left':'relaxed','right':'hold_prop'},motion='snap')
act(starts[7],'listening',gaze=(.55,0),hands={'left':'relaxed','right':'hold_prop'})
act(E['joke'],'realization',gaze=(.4,0),hands={'left':'relaxed','right':'hold_prop'},ev='joke')
act(E['not_me'],'school_relief',gaze=(0,0),hands={'left':'relaxed','right':'hold_prop'},ev='not_me')
act(key(7,'an entire evening'),'pleased',gaze=(.35,.05),hands={'left':'open_palm_up','right':'hold_prop'})
act(starts[8],'quiet_recoil',gaze=(.5,0),hands={'left':'relaxed','right':'hold_prop'})
act(E['made'],'listening',gaze=(.55,0),hands={'left':'relaxed','right':'hold_prop'},ev='made')
act(key(8,'sort of'),'embarrassed',gaze=(-.2,.2),hands={'left':'hand_to_chest','right':'hold_prop'})
act(E['wandered'],'deadpan',hands={'left':'relaxed','right':'hold_prop'},motion='snap',ev='wandered')
act(E['yeah'],'weight_shift',gaze=(.45,0),hands={'left':'relaxed','right':'hold_prop'},ev='yeah')
act(E['stories'],'school_resolve',gaze=(.45,0),hands={'left':'open_palm_up','right':'hold_prop'},ev='stories')
act(key(9,'tiny wobble'),'embarrassed',gaze=(-.2,.1),hands={'left':'relaxed','right':'hold_prop'})
act(E['operating'],'deadpan',hands={'left':'relaxed','right':'hold_prop'},motion='snap',ev='operating')
act(starts[10],'soft_shrug',gaze=(0,0),hands={'left':'open_palm_up','right':'hold_prop'})
act(E['next'],'pleased',gaze=(.5,.1),hands={'left':'relaxed','right':'hold_prop'},ev='next')
act(E['audition'],'school_confide',hands={'left':'hand_to_chest','right':'hold_prop'},ev='audition')
act(phone_end,'recover',gaze=(0,0),motion='snap')
act(E['claim'],'school_resolve',hands={'left':'relaxed','right':'open_palm_up'},ev='claim')
act(key(11,'still learning'),'soft_shrug',hands={'left':'open_palm_up','right':'relaxed'})
act(key(11,'apparently'),'school_confide',d=.45)
act(E['finished'],'school_relief',face={'eye_openness':.94},d=.55,ev='finished')
performances.sort(key=lambda x:x['at'])
for i,c in enumerate(performances):
 nxt=performances[i+1]['at'] if i+1<len(performances) else duration
 c['duration']=r(min(c['duration'],max(0,nxt-c['at']-.01)))
 if c['duration']<.06:c['duration']=0;c['motion']='snap'
 if nxt-c['at']>2.8:c['blinks']=[r(c['at']+2.05)]
# Already held on the cut, continuously attached until a narrator location cut.
# No pickup/drop is implied. Return both fingers/wrist ownership at the cut.
hand_paths={'right':[dict(at=phone_start,position=[75,-35],angle=-8),dict(at=E['joke'],position=[75,-35],angle=-8),dict(at=r(E['not_me']+.4),position=[68,-20],angle=-2,bend=[4,-2]),dict(at=phone_end,position=[68,-20],angle=-2)]}
props=[dict(author='nemi',kind='phone',at=phone_start,end=phone_end,position=[0,0],scale=[.66,.66],mode='hold',layer=0,attach=dict(actor='nemi',hand='right',grip=[0,11],socket=[0,8],angle=0))]
# Cafe cups meet the world-coordinate tabletop; they are held scenery.
for s in shots:
 if s['background']=='attachment_cafe_r5':
  for kind in ['attachment_cafe_cup_one','attachment_cafe_cup_two']:
   props.append(dict(author='nemi',kind=kind,at=s['start'],end=s['end'],position=[0,0],scale=[1,1],mode='hold',layer=0,shots=[s['id']]))
drawings=[]
def art(kind,a,b,pos=(1190,490),scale=1,mode='hold',text=None,size=56,draw=.7,shots_filter=None,ev=None,offset=0):
 item=dict(author='nemi',kind=kind,at=r(a),end=r(b),position=list(pos),scale=[scale,scale],mode=mode)
 if mode=='live':item['duration']=draw
 if text is not None:item.update(text=text,size=size)
 if shots_filter:item['shots']=shots_filter
 if ev:item['event']=ev
 if offset:item['event_offset']=offset
 drawings.append(item);return item
art('text',shot('computer_answer')['start'],end('computer_answer'),pos=(900,180),text='computer\nwork',size=51)
art('text',E['creative'],end('creative_label'),pos=(900,180),text='creative\nstuff',size=54,mode='live',draw=.95,ev='creative')
art('scratch',E['repeat'],end('creative_label'),pos=(1080,245),scale=2.25,mode='live',draw=.65,ev='repeat')
art('text',E['animator'],end('could_say'),pos=(800,245),text='animator',size=66,mode='hold',ev='animator')
art('creator_story_pages',shot('private_confidence')['start'],end('private_confidence'),pos=(1320,490),scale=1.0)
art('underline',E['blink'],end('private_confidence'),pos=(1320,640),scale=1.5,mode='live',ev='blink')
art('creator_upload',E['video'],end('open_video'),pos=(1290,440),scale=1.1,ev='video')
art('creator_draft_choices',E['hair'],end('old_drafts'),pos=(1280,450),scale=1.05,ev='hair')
art('creator_story_pages',shot('evening_work')['start'],end('evening_work'),pos=(1310,490),scale=1.0)
art('text',shot('sort_of')['start'],end('sort_of'),pos=(900,245),text='sort of?',size=56)
art('text',E['stories'],end('claim_stories'),pos=(900,180),text='animated\nstories',size=50,mode='live',draw=.9,ev='stories')
art('creator_story_pages',shot('no_certificate')['start'],end('no_certificate'),pos=(1280,460),scale=1.05)
art('text',E['claim'],end('im_animator'),pos=(1080,400),text='animator',size=67,mode='live',draw=.85,ev='claim')
art('underline',E['claim']+.9,end('im_animator'),pos=(1230,485),scale=2.0,mode='live',draw=.6,ev='claim',offset=.9)
art('notebook',E['hands'],end('im_animator'),pos=(1260,635),scale=.75,ev='hands')
vfx=[dict(kind='sweat',author='nemi',actor='nemi',at=E['question'],end=r(E['question']+.65),strength=.45,offset=[92,-70],event='question'),dict(kind='realization',author='nemi',actor='nemi',at=E['joke'],end=r(E['joke']+.65),strength=.5,offset=[93,-75],event='joke')]
# Exact existing source selection with honest provenance; no procedural assets.
catalog=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())
assets=catalog['assets'] if isinstance(catalog,dict) else catalog
picks=[('question','sting_question_chime_01',.65,-16,'A quiet inquisitive accent at the actual question.'),('creative','drawing_pencil_sketch_01',.95,-11,'The short evasive label is visibly written.'),('repeat','drawing_scratch_scribble_01',.65,-13,'The inadequate description is crossed out.'),('computer','viral_bruh',.816,-12,'One external comic aside after the public answer.'),('phone','viral_pop',.4,-9,'Phone/evidence reveal on its first held cut.'),('video','viral_click',.365,-8,'Opening the story video.'),('hair','paper_page_flip_01',.6,-8,'Two old draft pages appear sequentially.'),('joke','ui_confirm_chime_01',.6,-16,'Recognition that the joke worked, then silence.'),('next','paper_book_paging_single_01',.6,-10,'Turn attention to the next part of the story.'),('claim','drawing_pencil_sketch_01',.85,-10,'The word animator is finally claimed.'),('hands','paper_page_flip_03',.6,-6,'Small notebook callback to ongoing learning.')]
sfx=[];sound_plan=[]
for name,asset_id,length,gain,intent in picks:
 asset=next(x for x in assets if x['id']==asset_id);validate_asset(asset,ROOT)
 delta=0
 if name=='computer':delta=min(1.6,max(.1,ends[3]+.08-E[name]))
 at=r(E[name]+delta)
 cue=dict(file='res://'+asset['relative_path'],at=at,duration=length,gain_db=gain,event=name)
 if delta:cue['event_offset']=r(delta)
 sfx.append(cue)
 sound_plan.append(dict(event=name,at=at,source_id=asset_id,file=cue['file'],duration=length,gain_db=gain,reason=intent,source=asset.get('source'),license=asset.get('license'),sha256=asset.get('sha256')))
script=[dict(actor='nemi',start=r(max(0,g[0]['start']-.01)),end=r(g[-1]['end']+.01),text=story['lines'][i]) for i,g in enumerate(groups)]
captions=[];begin=0
for i,w in enumerate(words):
 last=i==len(words)-1;gap=last or words[i+1]['start']-w['end']>=.35;punct=w['word'].rstrip().endswith(('.',',','?','!',':',';'))
 if i-begin+1>=5 or gap or punct:
  captions.append(dict(actor='nemi',words=[begin,i],start=words[begin]['start'],end=w['end'],text=' '.join(x['word'] for x in words[begin:i+1])));begin=i+1
mouths=[]
for w in words:
 a,b=w['start'],w['end'];token=clean(w['word'])
 if b-a<.045:continue
 onset=.035 if token.startswith(('m','b','p')) else .012
 close=.035 if b-a>.10 else .015
 if onset+close>=b-a:continue
 if onset>.02:mouths.append(dict(start=r(a),end=r(a+onset),shape='closed'))
 vowel='o_u' if re.search('(oo|ou|ow|you|too|phone)',token) else 'ae' if re.search('(a|ai|ei)',token) else 'small_open'
 mouths.append(dict(start=r(a+onset),end=r(b-close),shape=vowel));mouths.append(dict(start=r(b-close),end=r(b),shape='closed'))
thoughts=[('A normal question causes a disproportionate freeze.','Nemi’s face then cafe geography','Cafe wide and quiet portrait, no literal lawyer art.','Make the social tension immediate.'),('The first evasion is almost useless.','Evasive label then dry face','Computer work clears; cafe stays ordinary.','Let the electricity line land.'),('A second evasion becomes more suspicious.','One handwritten creative label','Write, question and cross out only the current answer.','The attempted escape causes the next awkward thought.'),('Private expertise becomes public hesitation.','Creator desk then social freeze','Story pages and brief underline contrast with a deadpan return.','Keep Nemi capable rather than helpless.'),('Showing work feels like revealing every flaw.','Held phone and worried face','Already-held phone has continuous supported grip.','Make the stakes concrete.'),('Nemi apologizes before the video plays.','Video evidence then draft pages','One upload card clears before two old drafts.','The evidence contradicts the need to apologize.'),('Explaining flaws has become an escape route.','Dry face','No extra illustration, sound or movement.','Earn a clean comedic hold.'),('The listener laughs at the intended joke.','Listening eyes then relief','Quiet recognition and held story page at the studio.','Let work connect with a person.'),('The old minimizing answer almost comes back.','Face and short sort-of label','The label clears before the honest answer.','Prepare the choice without another panic burst.'),('Nemi says what she actually makes.','Honest face then ordinary cafe','Short animated stories lettering settles, then wide quiet room.','Answer the opening question.'),('The listener only wants the next part.','Story page then reflective face','Turn one page and hold the admission.','Keep the judgment inside Nemi rather than inventing an adversary.'),('The title animator can be claimed while learning.','Full body then final face','One word and notebook callback clear for the quiet ending.','End on small earned pride, not a lecture.')]
beats=[dict(start=0 if i==0 else r(starts[i]-.10),end=duration if i==11 else r(starts[i+1]-.10),thought=t,focus=f,visual=v,intent=q) for i,(t,f,v,q) in enumerate(thoughts)]
spec=dict(version=2,title=story['title'],duration=duration,fps=30,caption_size=52,audio='res://'+str((EP/'voice/narration_r1.wav').relative_to(ROOT)),audio_metadata='res://'+str((EP/'timing_reference_r1.json').relative_to(ROOT)),direction=dict(promise='A harmless cafe question becomes difficult because Nemi cannot quite say what matters.',want='Answer without exposing unfinished work to judgment.',choice='Evade twice, then show a story video while explaining its flaws.',consequence='The evasions make the encounter harder; the intended joke works anyway.',payoff='Nemi claims animator while still learning.',beats=beats),actors=[dict(id='nemi',author='nemi',performances=performances,mouths=mouths,hand_paths=hand_paths,hand_path_window=[phone_start,phone_end])],shots=shots,drawings=drawings,props=props,vfx=vfx,sfx=sorted(sfx,key=lambda x:x['at']),events=events,script=script,captions=captions)
spec['mix']=calibrate_mix(spec,ROOT)
(EP/'scene.json').write_text(json.dumps(spec,indent=2)+'\n')
(EP/'camera_plan.json').write_text(json.dumps(camera_plan,indent=2)+'\n')
(EP/'sound_plan.json').write_text(json.dumps(dict(cues=sound_plan,intentional_silence=['Electricity aftermath','Emergency exits dry line','Not at me personal recognition','Honest yeah and cafe continues','Final personal admission']),indent=2)+'\n')
(EP/'SCRIPT_AND_BEATS.md').write_text('# EP16 — measured script and thought beats\n\n'+f'Runtime {duration:.3f}s, hard cap120s. Fictionalized dramatization. Canonical Sohee.\n\n'+'\n\n'.join(f"## {i+1}. {b['start']:.3f}–{b['end']:.3f}s\n\n{story['lines'][i]}\n\nFocus: {b['focus']}. {b['visual']} {b['intent']}" for i,b in enumerate(beats))+'\n')
validate(EP/'scene.json')
print(f'EP16 validated: {duration:.3f}s, {len(words)} words, {len(shots)} shots, {len(performances)} acting cues, {len(sfx)} SFX.')
