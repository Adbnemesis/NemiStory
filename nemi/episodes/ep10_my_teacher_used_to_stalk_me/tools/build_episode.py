"""Direct EP10 on the shared version-2 stage using measured approved recordings."""
raise SystemExit('Superseded long planning builder. Use tools/build_short.py: current delivery must stay at or below 150 seconds.')
import json,sys,math,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];sys.path.insert(0,str(ROOT/'tools/storytime'))
from prepare_voice import prepare,digest
from audio_mix import calibrate_mix
from sfx_assets import validate_asset
from sfx_levels import choose_gain,pcm
from validate_scene import validate
EP=Path(__file__).resolve().parent.parent
records=json.loads((EP/'source_words_final.json').read_text())
story=json.loads((EP/'story.json').read_text())
clips=[];at=.3;starts=[];turn_ends=[];word_groups=[]
for i,r in enumerate(records):
    words=[];previous=0
    for w in r['words']:
        # Keep recognizer boundaries; discard zero spans, never invent missing times.
        start=max(previous,w['start']);end=min(w['end'],r['duration'])
        if start<end:
            words.append(dict(word=w['word'].strip(),start=start,end=end));previous=end
    starts.append(round(at,6));turn_ends.append(round(at+r['duration'],6))
    clips.append(dict(author='nemi',file=r['file'],sha256=r['sha256'],at=round(at,6),start=0,end=r['duration'],tempo=1.0,words=words))
    # Preserve whole source pauses, then add explicitly chosen thought space.
    at+=r['duration']+({0:.85,11:.7,15:.8,17:.6,19:.8,20:.65,21:.85,23:.8,26:.75,27:1.5}.get(i,.3))
duration=math.ceil(at*30)/30
plan=dict(version=1,duration=duration,clips=clips)
(EP/'voice_plan.json').write_text(json.dumps(plan,indent=2)+'\n')
scratch=ROOT/'renders/nemi_ep10/audio_r1'
if scratch.exists():
    timeline=json.loads((scratch/'timeline.json').read_text());assert timeline['audio_sha256']==digest(scratch/'narration.wav')
else:timeline=prepare(plan,scratch)
# Keep approved voice and timing together in the episode, not the final movie folder.
import shutil
voice=EP/'voice';voice.mkdir(exist_ok=True)
shutil.copyfile(scratch/'narration.wav',voice/'narration_r1.wav')
(EP/'timing_reference.json').write_text(json.dumps(timeline,indent=2)+'\n')
allwords=timeline['words'];offset=0
for c in clips:word_groups.append(allwords[offset:offset+len(c['words'])]);offset+=len(c['words'])
def key(i,phrase):
    wanted=re.sub(r'\W','',phrase.lower())
    return next(w['start'] for w in word_groups[i] if re.sub(r'\W','',w['word'].lower())==wanted)
def art(kind,start,end,position,scale=1,**kw):
    item=dict(author='nemi',kind=kind,at=start,end=end,position=position,scale=[scale,scale],mode='hold');item.update(kw);return item
bg=['home_curtain','school_classroom','school_classroom','school_classroom','school_corridor','school_corridor','school_classroom','residential_lane','residential_lane','school_courtyard','stationery_shop','stationery_shop','residential_lane','home_curtain','paper','thought','school_classroom','school_classroom','home_curtain','residential_lane','home_curtain','home_curtain','school_office','school_office','school_courtyard','home_curtain','school_office','home_curtain']
framing=['portrait','wide','wide','medium','wide','medium','portrait','wide','wide','medium','wide','reaction','wide','medium','portrait','evidence','wide','portrait','medium','wide','wide','wide','wide','medium','wide','portrait','medium','portrait']
recipes=['uncertain','recover','explaining','pleased','uncertain','skeptical','embarrassed','realization','skeptical','soft_shrug','listening','quiet_recoil','uncertain','prop_present','embarrassed','quiet_recoil','overwhelmed','deadpan','listening','realization','overwhelmed','recover','recover','skeptical','listening','uncertain','quiet_recoil','deadpan']
focus=['A private detail','School geography','The ordinary trusted teacher','Being noticed','The empty corridor','Questions outside homework','Automatic politeness','A route he should not know','Car and hidden shortcut','A defensive joke','The distance across the street','Friend recognizes danger','Repeated car','The first message','Politeness under fear','Secrecy in messages','Soft threat in class','The chalkboard date','The lit window','What the road can see','Asking for help','The curtain closes','Corroboration','A question he cannot answer','Practical aftermath','Anxiety remains','The reasonable excuse','The opening confirmed']
shots=[];camera_plan=[];performances=[];drawings=[];props=[];events=[];vfx=[];sound_notes=[]
def event(name,t,intent):
    events.append(dict(id=name,at=round(t,6),intent=intent));return name
for i in range(len(clips)):
    start=0 if i==0 else starts[i]-.15
    end=starts[i+1]-.15 if i<len(clips)-1 else duration
    sid=f'beat_{i:02d}'
    camera={'center':[960,540],'zoom':1.0}
    if framing[i]=='portrait':camera={'center':[520,434],'zoom':2.10}
    elif framing[i]=='reaction':camera={'center':[520,463],'zoom':2.45}
    elif framing[i]=='medium':camera={'center':[775,488],'zoom':1.4}
    elif framing[i]=='evidence':camera={'center':[1030,492],'zoom':1.15}
    shots.append(dict(id=sid,start=round(start,6),end=round(end,6),background=bg[i],actors={'nemi':dict(position=[520,570],scale=1.75)},camera=camera))
    ev=event('camera_'+sid,start,'Cut on thought: '+focus[i])
    camera_plan.append(dict(at=start,spoken_cue=word_groups[i][0]['word'],spoken_at=word_groups[i][0]['start'],focus=focus[i],framing=framing[i],camera=camera,event=ev,finish='Hold settled composition until next thought; no constant zoom.'))
    cue=dict(at=round(start,6),recipe=recipes[i],duration=.36,gaze=[0,0],blinks=[round(min(start+2.6,end-.3),6)])
    if i in [4,5,7,10,11,12,16,19]:cue['gaze']=[.35,-.03]
    if i in [14,17,20,25]:cue['gaze']=[-.18,.18]
    if i in [0,7,11,15,19,26,27]:cue['face']={'eye_openness':1.1,'pupil_scale':.83,'left_brow_offset':[0,-2]}
    if i in [13,14,20]:cue['hands']={'right':'hold_prop'}
    if i==27:cue.update(motion='snap',duration=0,blinks=[])
    performances.append(cue)
    sound_notes.append(dict(beat=i,start=start,end=end,thought=focus[i],selection='Intentional silence: leave the account intelligible and the reaction unembellished.'))
    # One clear visual relationship per thought, with deliberate quiet portraits.
    if i in [2,3,4,5,16]:
        props.append(art('teacher_ordinary',start,end,[1360,894],1.0,layer=0,shots=[sid]))
    if i in [2,3,4,5,16,17,22,23,26]:
        props.append(art('desk',start,end,[1240,716],1.0,layer=0,shots=[sid]))
        props.append(art('school_notebook',start,end,[1220,689],.27,layer=2,shots=[sid]))
    if i in [7,8,10,12]:
        props.append(art('teacher_distant',start,end,[1340,759],.72,layer=0,shots=[sid]))
        props.append(art('car',start,end,[1650,843],.76,layer=0,shots=[sid]))
    if i==10:props.append(art('school_friend',start,end,[835,894],1.65,layer=0,shots=[sid]))
    if i in [0,18,19]:
        props.append(art('window_lit',start,end,[1260,394],1.25,layer=0,shots=[sid]))
    if i in [21,25,27]:
        props.append(art('curtain_closed',start,end,[1260,394],1.25,layer=0,shots=[sid]))
    if i in [20,21,22,23,26]:props.append(art('nemi_mother',start,end,[1120 if i<22 else 1010,894],1.0,layer=0,shots=[sid]))
    if i in [13,14,20]:props.append(art('phone',start,end,[0,0],.70,layer=0,shots=[sid],attach={'actor':'nemi','hand':'right','grip':[0,9]}))
    if i==15:
        props.append(art('evidence_phone',start,end,[1390,516],.83,shots=[sid]))
        drawings.append(art('text',start,end,[735,340],1,text="don't mention",size=52,shots=[sid]))
        drawings.append(art('text',start,end,[770,425],1,text='these chats',size=52,shots=[sid]))
    if i==12:
        drawings.append(art('text',start,end,[920,250],1,text='coincidence?',size=52,shots=[sid]))
        t=key(12,'kept');ev=event('pattern_recognition',t,'Explanations run out; revise coincidence into pattern')
        drawings.append(art('scratch',t,end,[1090,278],2,mode='live',duration=.65,shots=[sid],event=ev))
        drawings.append(art('text',t+.7,end,[925,360],1,text='a pattern',size=64,mode='live',duration=1.2,shots=[sid]))
    if i in [24]:props.append(art('school_gate',start,end,[1390,894],1.12,layer=0,shots=[sid]))
# A second thought inside the hook gets an exact-word reaction cut.
t=key(0,"hadn't")
first=shots[0];reaction=dict(first);reaction['id']='hook_private';reaction['start']=t;reaction['camera']={'center':[520,420],'zoom':2.35};first['end']=t
shots.insert(1,reaction)
for group in [drawings,props]:
    for a in group:
        if 'beat_00' in a.get('shots',[]):a['shots'].append('hook_private')
ev=event('private_detail',t,'Hold realization on the word had not told')
performances.insert(1,dict(at=t,recipe='quiet_recoil',duration=.25,event=ev,face={'eye_openness':1.16,'pupil_scale':.72}))
camera_plan.append(dict(at=t,spoken_cue="hadn't",focus='The information was private',framing='reaction',camera=reaction['camera'],event=ev,finish='Hold through silence'))
# Explicitly timed secondary reactions, not a loop or idle.
for i,word,recipe in [(7,'realized','quiet_recoil'),(11,'stopped','realization'),(15,'mention','skeptical'),(19,'suddenly','quiet_recoil'),(23,'secret','lean_in'),(26,'only','skeptical')]:
    t=key(i,word)
    performances.append(dict(at=t,recipe=recipe,duration=.32,gaze=[0,0],face={'eye_openness':1.03,'pupil_scale':.85}))
performances.sort(key=lambda x:x['at'])
for c in performances:
    if abs(c['at']-(starts[13]-.15))<.001:c['recipe']='uncertain'
phone_start=starts[13]-.15;phone_end=starts[15]-.15
hand_paths={'right':[dict(at=phone_start,position=[94,-2],angle=0),dict(at=phone_start+.6,position=[97,-67],angle=0,bend=[4,-8]),dict(at=starts[14]-.15,position=[97,-67],angle=0),dict(at=starts[14]+.65,position=[83,-5],angle=0)]}
# Keep last-brow hold and zero procedural animation after the final narration.
captions=[];mouths=[];offset=0
for i,c in enumerate(clips):
    selected=word_groups[i];group=[]
    for j,w in enumerate(selected):
        group.append((offset+j,w))
        next_pause=j==len(selected)-1 or (selected[j+1]['start']-w['end']>=.35)
        if len(group)==5 or w['word'].endswith(('.', '?', '!')) or next_pause:
            captions.append(dict(actor='nemi',words=[group[0][0],group[-1][0]],start=group[0][1]['start'],end=group[-1][1]['end'],text=' '.join(x[1]['word'] for x in group)));group=[]
        # Existing vowels with authored closures at m/b/p starts; approximate word alignment.
        span=w['end']-w['start'];text=w['word'].lower().strip('.,?!')
        if span>.06:
            shape='o_u' if re.search(r'oo|you|who|home|know|road|told',text) else 'ae' if re.search(r'a|e|i',text) and len(text)>3 else 'small_open'
            begin=w['start']+.012;finish=w['end']-.02
            if text.startswith(('m','b','p')) and span>.10:
                mouths.append(dict(start=begin,end=begin+.035,shape='closed'));begin+=.035
            if begin<finish:mouths.append(dict(start=begin,end=finish,shape=shape))
    offset+=len(selected)
catalog=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())
assets=catalog['assets'] if isinstance(catalog,dict) else catalog
palette={a['id']:a for a in assets}
voice_pcm=pcm(voice/'narration_r1.wav')
sfx=[];sound_detail=[]
def sound(i,word,asset_id,length,prominence,why):
    t=key(i,word);a=palette[asset_id];path=validate_asset(a,ROOT)
    gain,levels=choose_gain(path,voice_pcm,t,length,prominence)
    ev=event('sound_'+str(i)+'_'+word,t,why)
    sfx.append(dict(file='res://'+a['relative_path'],at=t,duration=length,gain_db=gain,event=ev))
    sound_detail.append(dict(beat=i,spoken_cue=word,at=t,id=asset_id,duration=length,gain_db=gain,reason=why,sha256=digest(path),source=a.get('source'),license=a.get('license'),**levels))
    sound_notes[i]['selection']=why
sound(1,'bell','sting_bell_dramatic_01',.65,'accent','Short familiar school bell establishes the ordinary location')
sound(4,'notebook','paper_book_close_01',.5,'accent','Notebook becomes a pretext for staying after class')
sound(8,'car','movement_backpack_strap_01',.4,'surface','Small bag-strapping accent under the route explanation')
sound(10,'teacher','suspense_glass_hit_cinematic_01',1.15,'hero','Brief recognition sting, then quiet across the street')
sound(12,'kept','drawing_scratch_scribble_01',.65,'accent','Live scratch changes coincidence into pattern')
sound(13,'message','viral_notification',1.25,'accent','The first personal message crosses the school boundary')
sound(14,'typed','viral_key_press',.4,'surface','Polite answer taps on phone')
sound(15,'stranger','viral_ping',.8,'accent','Another incoming message before secrecy; no meme dialogue')
sound(16,'notebook','paper_book_close_01',.45,'accent','Notebook lands before the soft threat')
sound(18,'message','viral_notification',1.2,'accent','Light message connects phone to the bedroom window')
sound(21,'curtain','movement_cloth_rustle_01',.75,'hero','Curtain rings/cloth accent accompanies practical protection')
sound(22,'screenshots','viral_click',.36,'accent','Saved evidence makes the account concrete')
sound(24,'stopped','ui_click_tactile_01',.30,'surface','Brief phone click as messages cease; leave aftermath quiet')
for i,word in [(7,'realized'),(11,'stopped'),(19,'suddenly')]:
    t=key(i,word);ev=event('recognition_'+str(i),t,focus[i]);vfx.append(dict(kind='tension',author='nemi',at=t,end=t+.75,actor='nemi',offset=[92,-68],strength=.45,event=ev))
beats=[dict(start=shots[0]['start'] if i==0 else starts[i]-.15,end=starts[i+1]-.15 if i<27 else duration,thought=focus[i],focus=focus[i],visual=framing[i]+' with held '+bg[i],intent='Change the audience understanding: '+focus[i]) for i in range(28)]
spec=dict(version=2,title=story['title'],duration=duration,fps=30,caption_size=52,audio='res://'+str((voice/'narration_r1.wav').relative_to(ROOT)),audio_metadata='res://'+str((EP/'timing_reference.json').relative_to(ROOT)),direction=dict(promise='Discover how the teacher knew private details.',want='Get through school without trouble.',choice='Rationalize boundary crossings until the window message.',consequence='Politeness becomes secrecy and fear.',payoff='The reasonable excuse confirms surveillance.',beats=beats),actors=[dict(id='nemi',author='nemi',performances=performances,mouths=mouths,hand_paths=hand_paths,hand_path_window=[phone_start,phone_end])],shots=shots,drawings=drawings,props=props,events=events,vfx=vfx,sfx=sfx,script=[dict(actor='nemi',start=starts[i],end=turn_ends[i],text=r['text']) for i,r in enumerate(records)],captions=captions)
# Measured master gain only. File-based validation includes episode preparation.
spec['mix']=calibrate_mix(spec,ROOT)
(EP/'scene.json').write_text(json.dumps(spec,indent=2)+'\n');validate(EP/'scene.json')
(EP/'camera_plan.json').write_text(json.dumps(camera_plan,indent=2)+'\n')
(EP/'sound_plan.json').write_text(json.dumps(dict(beats=sound_notes,cues=sound_detail,policy='Existing recordings only; no BGM; perceptual listening remains required.'),indent=2)+'\n')
(EP/'SCRIPT_AND_BEATS.md').write_text('# My Teacher Used to Stalk Me\n\nOriginal fictionalized Nemi story. Approved Sohee identity, tempo 1.00.\n\n'+'\n\n'.join(f'## {i+1:02d} — {starts[i]:.2f}–{turn_ends[i]:.2f}s\n\n{r["text"]}\n\nFocus: {focus[i]}. Framing: {framing[i]}. Sound: {sound_notes[i]["selection"]}' for i,r in enumerate(records))+'\n')
print('READY',duration,'seconds;',len(shots),'shots;',len(captions),'caption cards;',len(sfx),'sounds')
