"""EP11 on the shared v2 stage; preserve canonical rig/voice and old episodes."""
import json,sys,math,re,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];sys.path.insert(0,str(ROOT/'tools/storytime'))
from prepare_voice import prepare,digest
from audio_mix import calibrate_mix
from sfx_assets import validate_asset
from sfx_levels import choose_gain,pcm
from validate_scene import validate
EP=Path(__file__).resolve().parent.parent
records=json.loads((EP/'source_words.json').read_text());story=json.loads((EP/'story.json').read_text())
clips=[];starts=[];ends=[];at=.2
for i,r in enumerate(records):
    words=[];previous=0
    for w in r['words']:
        a=max(previous,w['start']);b=min(w['end'],r['duration'])
        if b>a:
            token=w['word'].strip()
            if token.startswith(',000') and words:
                words[-1]['word']+=token;words[-1]['end']=b
            elif i==2 and token=='is' and words[-1]['word']=='video':
                # Recognizer split of the source script's spoken plural, retained span.
                words[-1]['word']='videos';words[-1]['end']=b
            else:words.append(dict(word=token,start=a,end=b))
            previous=b
    starts.append(round(at,6));ends.append(round(at+r['duration'],6))
    clips.append(dict(author='nemi',file=r['file'],sha256=r['sha256'],at=round(at,6),start=0,end=r['duration'],tempo=1.0,words=words))
    at+=r['duration']+({0:.35,1:.4,6:.5,7:.65,9:.4,12:.5,13:1.4}.get(i,.25))
duration=math.ceil(at*30)/30
assert 120<=duration<=150, f'Runtime {duration}; tighten script instead of rushing voice'
plan=dict(version=1,duration=duration,clips=clips);(EP/'voice_plan.json').write_text(json.dumps(plan,indent=2)+'\n')
scratch=ROOT/'renders/nemi_ep11/audio_r2'
if scratch.exists():
    timeline=json.loads((scratch/'timeline.json').read_text());assert timeline['audio_sha256']==digest(scratch/'narration.wav')
else:timeline=prepare(plan,scratch)
shutil.copyfile(scratch/'narration.wav',EP/'voice/narration_r1.wav');(EP/'timing_reference.json').write_text(json.dumps(timeline,indent=2)+'\n')
words=timeline['words'];groups=[];offset=0
for c in clips:groups.append(words[offset:offset+len(c['words'])]);offset+=len(c['words'])
def key(i,phrase,n=0):
    clean=lambda x:re.sub(r'\W','',x.lower())
    found=[w['start'] for w in groups[i] if clean(w['word'])==clean(phrase)]
    assert found,(i,phrase)
    return found[n]
def art(kind,a,b,pos,scale=1,**kw):
    x=dict(author='nemi',kind=kind,at=a,end=b,position=pos,scale=[scale,scale],mode='hold');x.update(kw);return x
focus=['The admission','The milestone felt real','Silence after the spike','Uncertainty after uploading','Searching for an explanation','The approaching deadline','The larger watch-hour climb','Fear about the future','The people still here','Comments reaching the creator','A practical invitation','Honest feedback and better stories','Gratitude alongside worry','There are more stories to tell']
recipe=['school_confide','school_relief','overwhelmed','uncertain','school_question','school_confide','school_explain','school_confide','listening','school_relief','lean_in','explaining','school_confide','school_relief']
frame=['portrait','medium','wide','portrait','medium','wide','medium','portrait','medium','portrait','medium','wide','portrait','portrait']
shots=[];perform=[];camera_plan=[];beats=[];props=[];drawings=[];events=[];vfx=[]
def event(name,t,why):events.append(dict(id=name,at=round(t,6),intent=why));return name
for i in range(len(clips)):
    a=0 if i==0 else starts[i]-.12;b=starts[i+1]-.12 if i<13 else duration
    a=round(a,6);b=round(b,6);sid=f'beat_{i:02d}'
    center,zoom=([620,365],2.05) if frame[i]=='portrait' else ([920,505],1.2) if frame[i]=='medium' else ([960,540],1.0)
    cam=dict(center=center,zoom=zoom)
    bg='nemi_creator_studio'
    # Moves finish early; remaining recording is a settled, readable hold.
    if i in [0,7,12]:
        cam['path']=[dict(at=a,center=center,zoom=zoom),dict(at=a+.7,center=center,zoom=zoom),dict(at=a+2,center=[620,355],zoom=2.15)]
    shots.append(dict(id=sid,start=a,end=b,background=bg,actors={'nemi':dict(position=[620,570],scale=1.75)},camera=cam))
    camera_plan.append(dict(shot=sid,at=a,spoken_cue=groups[i][0]['word'],spoken_at=groups[i][0]['start'],focus=focus[i],framing=frame[i],camera=cam,reason=focus[i],finish='Settle and hold; keep the face and chosen evidence clear.'))
    face={'eye_openness':.96,'pupil_scale':1.0}
    if i in [0,5,7,12]:face.update(left_brow_offset=[0,-1.5],right_brow_offset=[0,.6])
    perform.append(dict(at=a,recipe=recipe[i],duration=.5,gaze=[0,0] if i not in [2,4] else [.2,.15],face=face,blinks=[round(min(a+2.4,b-.3),6),round(min(a+5.9,b-.2),6)],hands={'left':'relaxed','right':'open_palm_up'} if i in [6,10,11] else {}))
    beats.append(dict(start=a,end=b,thought=focus[i],focus=focus[i],visual=frame[i]+'; '+bg,intent='Let the audience register '+focus[i].lower()+'.'))
# Useful exact-word reactions inside thoughts, without endless gesture loops.
for i,w,r,g in [(0,'worried','school_confide',[0,0]),(1,'people','realization',[0,0]),(1,'wanted','school_relief',[0,0]),(1,'happy','school_relief',[0,0]),(2,'lately','uncertain',[0,0]),(4,'time','soft_shrug',[.25,-.1]),(7,'scared','overwhelmed',[0,.08]),(8,'here','school_relief',[0,0]),(9,'read','school_confide',[0,0]),(11,'better','school_explain',[0,0]),(12,'grateful','school_relief',[0,0]),(12,'worried','school_confide',[0,0])]:
    t=key(i,w);perform.append(dict(at=t,recipe=r,duration=.4,gaze=g,blinks=[],hands={'left':'relaxed','right':'relaxed'} if r=='school_relief' else {}))
perform.sort(key=lambda c:c['at'])
for j,c in enumerate(perform):
    limit=perform[j+1]['at'] if j+1<len(perform) else duration
    c['duration']=round(min(c['duration'],max(0,limit-c['at']-.001)),6)
    c['blinks']=[t for t in c.get('blinks',[]) if c['at']<=t and t+.14<=limit]
# Milestone visual: one memory, two simple facts and one brief spark.
a=shots[1]['start'];b=shots[1]['end'];t=key(1,'2,000')
drawings += [art('text',t,b,[1090,335],text='2,000',size=90,mode='live',duration=1.25,shots=['beat_01']),art('text',t+1.35,b,[1045,445],text='in two days',size=55,shots=['beat_01'])]
event('milestone',t,'Remember the joy of finding real viewers')
vfx.append(dict(kind='relief',author='nemi',actor='nemi',offset=[88,-68],at=t,end=t+1,shots=['beat_01'],strength=.4,event='milestone'))
# Qualitative chart is explicitly conceptual; no invented counts or screenshots.
a=shots[2]['start'];b=shots[2]['end'];props.append(art('creator_reach_chart',a,b,[1320,540],1.25,shots=['beat_02']))
drawings.append(art('text',a,b,[1060,245],text='quieter lately',size=47,shots=['beat_02']))
# Work context: a bounded storyboard page on the already drawn desk.
a=shots[4]['start'];b=shots[4]['end'];props.append(art('creator_story_pages',a,b,[1330,651],.4,layer=0,shots=['beat_04']))
# Calendar, restrained rose selection, exact date; only this insert gets the label.
a=shots[5]['start'];b=shots[5]['end'];t=key(5,'deadline')
props.append(art('creator_calendar',t,b,[1280,575],1.12,shots=['beat_05'],path=[dict(at=t,position=[1280,605],tilt=3),dict(at=t+.5,position=[1280,575],tilt=0)]))
drawings.append(art('text',t,b,[1125,328],text='Feb 1, 2027',size=48,shots=['beat_05']))
event('deadline',t,'A date becomes a source of pressure')
# Watch-hours rise is revealed once, then held.
a=shots[6]['start'];b=shots[6]['end'];t4=key(6,'4,000');t8=key(6,'8,000')
drawings += [art('text',a,b,[1050,310],text='watch hours',size=46,shots=['beat_06']),art('text',t4,b,[1040,450],text='4,000',size=54,shots=['beat_06']),art('arrow',t8,b,[1345,463],.6,mode='live',duration=.65,shots=['beat_06']),art('text',t8+.65,b,[1365,450],text='8,000',size=54,mode='live',duration=1.2,accent=True,shots=['beat_06']),art('text',key(6,'subscriber'),b,[1090,600],text='1,000 subs stays',size=32,shots=['beat_06'])]
event('threshold',t8,'The long-form watch-hour requirement doubles for new applicants')
# Subscriber comments symbolize connection, never a made-up testimonial.
a=shots[8]['start'];b=shots[8]['end'];t=key(8,'comments')
props.append(art('creator_comment',a,b,[1280,520],1.12,shots=['beat_08'],path=[dict(at=a,position=[1280,555],tilt=-2),dict(at=a+.55,position=[1280,520],tilt=0)]))
event('comments',t,'Recognize the people still supporting the channel')
# Support request: one handwritten invitation, then remove it for the final thanks.
a=shots[10]['start'];b=shots[10]['end'];t=key(10,'share')
props.append(art('creator_story_pages',a,b,[1280,530],.95,shots=['beat_10']))
drawings.append(art('text',t,b,[1060,315],text='share a story',size=47,mode='live',duration=1.25,shots=['beat_10']))
event('share',t,'Invite a viewer to send a story to someone who relates')
for i,w,kind in [(7,'scared','tension'),(12,'grateful','relief')]:
    t=key(i,w);ev=event('feeling_'+str(i),t,'A brief '+kind+' accent, then let the face hold.')
    vfx.append(dict(kind=kind,author='nemi',actor='nemi',offset=[90,-68],at=t,end=t+.65,shots=[f'beat_{i:02d}'],strength=.3,event=ev))
# Secondary cut on the emotional turn; no repeating template cut rate.
for i,w,name,c in [(0,'worried','admission',[620,355]),(1,'happy','milestone_face',[620,355]),(8,'because','still_here',[620,355]),(9,'means','thanks_close',[620,355]),(13,'hope','last_hope',[620,355])]:
    t=key(i,w);old=next(s for s in shots if s['id']==f'beat_{i:02d}');new=json.loads(json.dumps(old));new.update(id=name,start=t,camera=dict(center=c,zoom=2.15));old['end']=t;shots.append(new)
    camera_plan.append(dict(shot=name,at=t,spoken_cue=w,spoken_at=t,focus=focus[i],framing='portrait',camera=new['camera'],reason='Return attention to the person at this turn.',finish='Hold through the remainder of the thought.'))
shots.sort(key=lambda s:s['start'])
# Retain art only in intended insert, not in the portrait continuation.
captions=[];mouths=[];offset=0
for gi,group in enumerate(groups):
    card=[]
    for j,w in enumerate(group):
        card.append((offset+j,w));pause=j==len(group)-1 or group[j+1]['start']-w['end']>=.35
        if len(card)==5 or w['word'].endswith(('.', '?','!')) or pause:
            captions.append(dict(actor='nemi',words=[card[0][0],card[-1][0]],start=card[0][1]['start'],end=card[-1][1]['end'],text=' '.join(v['word'] for _,v in card)));card=[]
        token=w['word'].lower().strip('.,?!');span=w['end']-w['start'];a=w['start']+.012;b=w['end']-.018
        if b-a>.045:
            # Word timing drives existing mouth vocabulary; consonant closures are editorial,
            # not a phoneme aligner. Review accuracy remains explicit in QA.
            if token.startswith(('m','b','p')) and span>.12:
                mouths.append(dict(start=a,end=a+.035,shape='closed'));a+=.035
            shape='o_u' if re.search(r'oo|you|who|hope|more|know|four|two',token) else 'ae' if re.search(r'a|e|i',token) and len(token)>2 else 'small_open'
            if gi in [0,2,3,5,7,12] and shape=='ae':shape='small_open'
            mid=min(b,a+.24)
            mouths.append(dict(start=a,end=mid,shape=shape))
            if b-mid>.06:
                mouths.append(dict(start=mid,end=min(mid+.035,b),shape='small_open'))
                if mid+.035<b:mouths.append(dict(start=mid+.035,end=b,shape=shape))
    offset+=len(group)
assets=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets'];palette={a['id']:a for a in assets}
voice=pcm(EP/'voice/narration_r1.wav');sounds=[];sound_detail=[]
choices=[(1,'2,000','ui_confirm_chime_03',.8,'accent','A small warm milestone accent, not fanfare'),(2,'uploading','computer_mouse_click_close_01',.25,'surface','An upload click, then quiet'),(4,'thumbnail','paper_page_flip_01',.76,'surface','Turning over a draft'),(5,'deadline','paper_book_paging_single_01',.65,'surface','The date page appears'),(6,'8,000','drawing_pencil_sketch_01',1.2,'accent','The larger requirement is written'),(8,'comments','ui_click_tactile_03',.22,'surface','A supportive comment noticed'),(10,'share','drawing_scratch_scribble_05',.325,'surface','A simple invitation written')]
for i,w,aid,length,prom,why in choices:
    t=key(i,w);a=palette[aid];path=validate_asset(a,ROOT);gain,levels=choose_gain(path,voice,t,length,prom);ev=event('sfx_'+str(i),t,why)
    sounds.append(dict(file='res://'+a['relative_path'],at=t,duration=length,gain_db=gain,event=ev));sound_detail.append(dict(beat=i,at=t,spoken_cue=w,id=aid,sha256=digest(path),source=a['source'],license=a['license'],reason=why,gain_db=gain,duration=length,**levels))
spec=dict(version=2,title=story['title'],duration=duration,fps=30,caption_size=52,audio='res://'+str((EP/'voice/narration_r1.wav').relative_to(ROOT)),audio_metadata='res://'+str((EP/'timing_reference.json').relative_to(ROOT)),direction=dict(promise='Understand the worry behind the request for help.',want='Keep building the channel and qualify before February.',choice='Admit uncertainty and ask the audience directly.',consequence='The milestone gives way to low reach and deadline pressure.',payoff='Thank the people still here and invite support for more stories.',beats=beats),actors=[dict(id='nemi',author='nemi',performances=perform,mouths=mouths)],shots=shots,drawings=drawings,props=props,events=events,vfx=vfx,sfx=sounds,script=[dict(actor='nemi',start=starts[i],end=ends[i],text=r['text']) for i,r in enumerate(records)],captions=captions)
spec['mix']=calibrate_mix(spec,ROOT)
for name in ['scene.json','scene_r6_1080p.json']:(EP/name).write_text(json.dumps(spec,indent=2)+'\n')
validate(EP/'scene.json');(EP/'camera_plan.json').write_text(json.dumps(camera_plan,indent=2)+'\n')
(EP/'sound_plan.json').write_text(json.dumps(dict(cues=sound_detail,beats=[dict(beat=i,thought=f,choice=next((x['reason'] for x in sound_detail if x['beat']==i),'Intentional silence: let the vulnerable words and face carry this thought.')) for i,f in enumerate(focus)],policy='No BGM; existing recordings only; no meme commentary.'),indent=2)+'\n')
(EP/'SCRIPT_AND_BEATS.md').write_text('# I Really Need Your Help — EP11\n\n'+f'Full review: {duration:.2f}s, 1080p first. Canonical Sohee, original pace 1.00.\n\n'+'\n\n'.join(f'{i+1}. {starts[i]:.2f}–{ends[i]:.2f}s — {focus[i]}\n\n{r["text"]}\n\nFraming: {frame[i]}; expression/gesture: {recipe[i]}.\n' for i,r in enumerate(records)))
print('READY',duration,'seconds',len(shots),'shots',len(perform),'performance cues',len(sounds),'SFX')
