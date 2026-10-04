"""Author the measured ADB school story through the existing version-2 stage."""
import sys,json,re,math,hashlib,subprocess,copy
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];sys.path.insert(0,str(ROOT));sys.path.insert(0,str(ROOT/'tools/storytime'))
from prepare_voice import prepare,digest
from audio_mix import calibrate_mix
from sfx_assets import validate_asset
from sfx_levels import pcm,choose_gain,levels as measure_levels
EP=Path(__file__).resolve().parents[1]
source=json.loads((EP/'source_words_selected.json').read_text())
# Source files are never trimmed; these explicit inter-phrase holds preserve every original pause.
gaps=[.5,.45,.55,.45,.3,.55,.55,.35,.6,.12,.12,1.55,.45,.35,.5,.7,.45,1.1]
clips=[];at=.35;cleaned=[]
for i,r in enumerate(source):
    path=ROOT/r['file'][6:]
    duration=float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','default=nw=1:nk=1',str(path)]))
    words=[];pending=''
    for w in r['words']:
        label=w['word'].strip().replace('“','').replace('”','')
        if not re.search(r'\w',label):
            if words:words[-1]['word']+=label
            continue
        end=min(float(w['end']),duration);start=float(w['start'])
        if end<=start:
            pending+=label+' ';continue
        if pending:label=pending+label;pending=''
        # DTW estimates can overlap by a rounding tick; preserve actual boundary, not sentence fractions.
        if words and start<words[-1]['end']:start=words[-1]['end']
        if start<end:words.append(dict(word=label,start=start,end=end))
    if pending:raise ValueError('Unplaced source word: '+pending)
    clip=dict(author='adb',file=r['file'],sha256=r['sha256'],at=round(at,6),start=0,end=duration,tempo=1.0,words=words)
    clips.append(clip);cleaned.append(words);at+=duration+gaps[i]
duration=math.ceil(at*30)/30
plan=dict(version=1,duration=duration,clips=clips)
audio=ROOT/'renders/adb_school_crush/audio_r1'
if audio.exists():
    timeline=json.loads((audio/'timeline.json').read_text())
    assert timeline['audio_sha256']==digest(audio/'narration.wav')
    assert [{k:v for k,v in c.items() if k not in ['words']} for c in clips]==[{k:v for k,v in c.items() if k not in ['processed_sha256','end_at']} for c in timeline['clips']]
else:timeline=prepare(plan,audio)
(EP/'voice_plan.json').write_text(json.dumps(plan,indent=2)+'\n')
(EP/'timing_reference.json').write_text(json.dumps(timeline,indent=2)+'\n')
words=timeline['words'];starts=[c['at'] for c in clips];ends=[c['end_at'] for c in timeline['clips']]
indexes=[];offset=0
for r in cleaned:indexes.append(list(range(offset,offset+len(r))));offset+=len(r)
def clean(s):return re.sub(r'[^\w\s]','',s.lower())
def wt(i,label,n=0):
    result=[words[j]['start'] for j in indexes[i] if clean(label) in clean(words[j]['word'])]
    return result[n]
def cue(t,recipe,d=.4,**kw):return dict(at=round(t,6),recipe=recipe,duration=d,**kw)
def event(ident,t,intent):
    events.append(dict(id=ident,at=round(t,6),intent=intent));return round(t,6)
# All school blocking keeps ADB at 1.7, feet y=894. Portraits reframe this same world.
block={'position':[610,591.4],'scale':1.7}
shots=[]
def shot(ident,t,bg='school_classroom',center=(960,540),zoom=1,visible=True):
    shots.append(dict(id=ident,start=round(t,6),end=0,background=bg,actors={'adb':copy.deepcopy(block)} if visible else {},camera=dict(center=list(center),zoom=zoom)))
shot('hook',0,'studio_adb',(610,430),2.15)
shot('school',starts[1],center=(960,540),zoom=1)
shot('school_detail',wt(1,'homework'),center=(1080,585),zoom=1.4)
shot('rumor',starts[2],'school_corridor',(950,530),1)
shot('friends',wt(2,'yeah'), 'school_corridor',(620,460),1.8)
shot('likes',wt(2,'no'), 'school_corridor',(950,530),1.12)
shot('louder',wt(2,'apparently'), 'school_corridor',(610,430),2)
shot('doubt',starts[3],'school_classroom',(670,450),1.75)
shot('serious',starts[4],'school_classroom',(940,530),1.08)
shot('tell_me',starts[5],'school_classroom',(610,440),1.85)
shot('confession',wt(5,'actually')-.2,'school_classroom',(940,485),1.3)
shot('belief',starts[6],'school_classroom',(610,430),2.2)
shot('replay',starts[7],'thought',(960,540),1)
shot('lunch_clue',wt(7,'sharing')-.15,'thought',(1170,510),1.4,False)
shot('homework_clue',wt(7,'borrowing')-.15,'thought',(960,510),1.15)
shot('charming',starts[8],'thought',(610,430),2.15)
shot('answer',starts[9],'school_classroom',(880,495),1.4)
shot('laugh',starts[10],'school_classroom',(980,485),1.3)
shot('prank',starts[11],'school_classroom',(610,435),2)
shot('accomplice',starts[12],'school_classroom',(950,530),1)
shot('group_project',wt(12,'right'),'school_classroom',(610,445),1.9)
shot('staring',starts[13],'school_classroom',(900,510),1.18)
shot('upset',starts[14],'school_classroom',(930,515),1.05)
shot('speech',wt(14,'wondering'),'school_classroom',(610,450),1.85)
shot('sanction',starts[15],'school_classroom',(1160,575),1.55,False)
shot('one_day',starts[16],'school_classroom',(610,430),2)
shot('science',starts[17],'school_classroom',(900,510),1.13)
for i,s in enumerate(shots):s['end']=shots[i+1]['start'] if i+1<len(shots) else duration
S={s['id']:s for s in shots}
events=[]
rumor=event('rumor',wt(2,'bro'),'Classmate introduces the rumor.')
likes=event('likes',wt(2,'no'),'Repeated word changes ADB interpretation.')
event('doubt_question',wt(3,'why'),'Question the source of relationship advice.')
serious=event('serious',wt(4,'serious'),'Seriousness disarms disbelief.')
belief=event('belief',starts[6],'A small hopeful smile.')
clue=event('clue',S['homework_clue']['start'],'A practical favor becomes imagined evidence.')
reveal=event('reveal',starts[11],'The apparent confession is exposed as a prank.')
revision=event('revision',ends[11]+.25,'His hopeful interpretation gets corrected.')
sanction=event('sanction',starts[15],'Attempted homework sanction.')
payoff=event('payoff',starts[17],'He needs her notes after all.')
performances=[cue(0,'explaining',0),cue(starts[1],'pleased',.45),cue(starts[2],'listening',.4,gaze=[.5,0]),cue(wt(2,'yeah'),'soft_shrug',.4),cue(likes,'skeptical',.4,event='likes'),cue(wt(2,'apparently'),'deadpan',0,motion='snap',blinks=[wt(2,'everything')+.25]),cue(starts[3],'skeptical',.4),cue(starts[4],'listening',.45,gaze=[.55,0]),cue(wt(4,'did'),'uncertain',.4),cue(starts[5],'uncertain',.4),cue(wt(5,'actually'),'quiet_recoil',.35),cue(belief,'pleased',.5,face={'blush_intensity':.16},event='belief'),cue(starts[7],'realization',.4),cue(clue,'prop_present',.4,hands={'right':'holding_cup'},event='clue'),cue(starts[8],'pleased',.5,face={'blush_intensity':.25}),cue(starts[9],'lean_in',.45),cue(starts[10],'listening',.3),cue(reveal,'quiet_recoil',.28,event='reveal'),cue(ends[11]+.1,'deadpan',0,motion='snap',blinks=[ends[11]+1.15]),cue(starts[12],'skeptical',.4,gaze=[.8,0]),cue(wt(12,'right'),'deadpan',0,motion='snap'),cue(starts[13],'embarrassed',.45,gaze=[.4,.65]),cue(starts[14],'listening',.4,gaze=[.65,0]),cue(wt(14,'wondering'),'explaining',.45),cue(starts[15],'deadpan',0,motion='snap'),cue(starts[16],'deadpan',0,motion='snap'),cue(starts[17],'soft_shrug',.45),cue(ends[17],'pleased',.4,blinks=[ends[17]+.55])]
# A held homework page is already in his existing grip at the insert cut.
# No invented pickup or root-motion walk. This bounded path raises the page and settles.
hp={'right':[{'at':clue,'position':[93,20],'angle':-90},{'at':clue+.7,'position':[110,-15],'angle':-90,'bend':[4,-6]},{'at':S['charming']['start'],'position':[110,-15],'angle':-90}]}
actor=dict(id='adb',author='adb',performances=performances,mouths=[],hand_paths=hp,hand_path_window=[clue,S['charming']['start']])
script=[];captions=[]
# Existing mouth shapes are authored from measured word spans; vowel/closure subdivisions
# are editorial annotations, not automatically measured phoneme boundaries.
round_words={'you','no','school','so','knew','who','would','group','homework','told','once','over','borrowed','borrowing','notes'}
wide_words={'she','me','we','he','yeah','believed','needed','serious','science','likes','like','day','friends'}
for i,(r,c) in enumerate(zip(source,clips)):
    script.append(dict(actor='adb',start=c['at'],end=ends[i],text=r['text']))
    group=[]
    for j in indexes[i]:
        w=words[j];label=w['word'];group.append(j)
        next_count=len(' '.join(words[q]['word'] for q in group).split())
        gap=words[j+1]['start']-w['end'] if j+1<len(words) else 0
        if next_count>=4 or re.search(r'[.!?—]$',label) or gap>.32 or j==indexes[i][-1]:
            captions.append(dict(actor='adb',words=[group[0],group[-1]],start=words[group[0]]['start'],end=words[group[-1]]['end'],text=' '.join(words[q]['word'] for q in group)));group=[]
        span=w['end']-w['start'];token=clean(label).strip();a=w['start'];b=w['end']
        segments=[]
        if span>.05:
            # Consonant closures are short, explicit, and leave silence between words closed.
            vowel='talk_round' if token in round_words else 'talk_wide' if token in wide_words else 'talk_open'
            if re.match(r'^(m|b|p)',token):segments.append((a,a+min(.06,span*.22),'neutral'));a=segments[-1][1]
            if span>.3 and token in {'charming','honestly','apparently','relationship','understand','actually','conversation','contributed'}:
                mid=a+(b-a)*.55
                segments.extend([(a,mid,vowel),(mid+.015,b-.025,'talk_wide')])
            else:segments.append((a+.008,b-.02,vowel))
            for a,b,shape in segments:
                if b<=a:continue
                for s in shots:
                    left=max(a,s['start']);right=min(b,s['end'])
                    if 'adb' in s['actors'] and right>left:actor['mouths'].append(dict(start=round(left,6),end=round(right,6),shape=shape))
actor['mouths'].sort(key=lambda m:m['start'])
drawings=[];props=[];vfx=[];sfx=[]
def art(kind,ids,xy,scale=1,group=drawings,**kw):
    ids=[ids] if isinstance(ids,str) else ids
    t=min(S[x]['start'] for x in ids);end=max(S[x]['end'] for x in ids)
    item=dict(author='adb',kind=kind,at=t,end=end,position=list(xy),scale=[scale,scale],mode='hold',shots=ids,**kw);group.append(item);return item
def text(label,ids,xy,size=54,**kw):return art('text',ids,xy,text=label,size=size,**kw)
school_ids=[s['id'] for s in shots if s['background']=='school_classroom']
# School clock/foreground desk remain anchored identically through every classroom reframe.
art('school_clock',school_ids,(686,205),.75,layer=-1)
art('desk',school_ids,(1180,735),1.16,group=props,layer=0)['scale']=[1.3,.9]
art('homework_notes',school_ids,(1190,697),.31,group=props,layer=0,tilt=-7)
art('lunch_box',['school','school_detail'],(1035,699),.6,group=props,layer=0)
art('school_friend_smile',['school','school_detail'],(1360,894),1.65,layer=0)
art('school_classmate',['rumor','likes'],(1270,894),1.65,layer=0)
art('school_friend',['serious','confession','answer'],(1310,894),1.65,layer=0)
art('school_friend_laugh','laugh',(1310,894),1.65,layer=0)
art('school_friend_smile',['accomplice','staring','upset','science'],(1300,894),1.65,layer=0)
art('school_classmate_laugh','accomplice',(1530,894),1.58,layer=0)
# Held recollections make his dubious evidence concrete.
art('lunch_box',['replay','lunch_clue'],(1160,560),1.5,group=props)
text('JUST FRIENDS',['replay','lunch_clue'],(1000,285),56)
# Initial live question starts on the thought, then finished geometry holds.
a=art('question','homework_clue',(1400,365),2.0);a.update(at=clue,duration=.75,mode='live',event='clue')
text('A SIGN?','homework_clue',(1090,275),58)
notes=art('homework_notes','homework_clue',(0,0),.45,group=props,layer=0)
notes.update(attach={'actor':'adb','hand':'right','grip':[85,45],'angle':90},at=clue,end=S['charming']['start'])
# Reveal correction is small and peripheral; face remains the focus.
text('A CRUSH?','prank',(825,352),36)
a=art('scratch','prank',(957,372),.8);a.update(at=revision,duration=.42,mode='live',event='revision')
a=text('A PRANK.','prank',(835,420),36);a.update(at=revision+.44,duration=.65,mode='live')
text('1 DAY','sanction',(1050,430),65)
text('SCIENCE','science',(1075,653),24)
# Event-linked, finite VFX; no continual marks or tears for an ordinary embarrassment.
vfx=[dict(author='adb',kind='realization',actor='adb',offset=[105,-40],at=likes,end=likes+.65,event='likes',strength=.6),dict(author='adb',kind='sweat',actor='adb',offset=[83,-25],at=starts[5],end=starts[5]+.8,strength=.6),dict(author='adb',kind='tension',actor='adb',offset=[100,-40],at=reveal,end=reveal+.55,event='reveal',strength=.6)]
catalog=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']
voice=pcm(audio/'narration.wav');sound_records=[]
def sound(ident,t,seconds,prominence,event_id=None):
    asset=next(a for a in catalog if a['id']==ident);path=validate_asset(asset,ROOT)
    gain,levels=choose_gain(path,voice,t,seconds,prominence)
    if ident=='viral_bruh':
        gain=-10
        srms,speak=measure_levels(pcm(path,duration=seconds))
        vrms,vpeak=measure_levels(voice[int(starts[11]*16000):int(ends[11]*16000)])
        levels={'sfx_rms_dbfs':round(srms+gain,1),'sfx_peak_dbfs':round(speak+gain,1),'nearby_voice_rms_dbfs':round(vrms-2,1),'relative_rms_db':round(srms+gain-(vrms-2),1),'prominence':prominence,'dialogue_reference':[starts[11],ends[11]]}
    item=dict(file='res://'+asset['relative_path'],at=round(t,6),duration=seconds,gain_db=gain)
    if event_id:item.update(event=event_id,event_offset=round(t-next(e['at'] for e in events if e['id']==event_id),6))
    sfx.append(item);sound_records.append(dict(id=ident,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),source=asset['source'],license=asset.get('license'),cue=item,levels=levels))
sound('viral_pop',likes+.22,.72,'accent','likes')
sound('sting_question_chime_01',wt(3,'why')+.18,.45,'accent','doubt_question')
sound('drawing_scratch_scribble_05',clue,.325,'surface','clue')
sound('viral_bruh',ends[11]+.6,.816979,'hero','reveal')
sound('drawing_scratch_scribble_01',revision,.139,'surface','revision')
sound('viral_click',sanction+.1,.365688,'accent','sanction')
sound('sting_question_chime_01',payoff+.12,.45,'accent','payoff')
# Hold-only artwork never receives fake movement Foley.
brief=dict(promise='An ordinary best friendship suddenly seems romantic.',want='Understand the confession without making the friendship awkward.',choice='Dismiss the rumor, then trust her serious delivery and start a sincere answer.',consequence='The prank catches him just as his guard drops.',payoff='His homework sanction lasts only until he needs her science notes.',beats=[])
thoughts={
'hook':('This got unexpectedly personal.','ADB face','Portrait','Open the question.'),'school':('We were ordinary best friends.','Shared school desk','Held classroom art','Establish school and friendship.'),'school_detail':('Practical favors were normal.','Lunch and homework','Desk insert','Plant the callback.'),'rumor':('He must be joking.','Classmate beside ADB','Corridor two-shot','Introduce rumor.'),'friends':('Of course she likes her friend.','ADB shrug','Reaction','Reveal innocent interpretation.'),'likes':('He means something else.','ADB eyebrow','Finite reaction','Change the implication.'),'louder':('Louder is not clearer.','ADB deadpan','Still portrait','Land dry repetition joke.'),'doubt':('This source is unreliable.','ADB doubtful gaze','Portrait','Dismiss evidence.'),'serious':('She looks sincere.','Friend serious face','Classroom two-shot','Change credibility.'),'tell_me':('Buy five seconds.','ADB uncertainty','Portrait','Make hesitation visible.'),'confession':('She confirms it.','Friend beside ADB','Two-shot','Let the apparent confession feel real.'),'belief':('Maybe this is possible.','ADB private smile','Portrait','Show vulnerability.'),'replay':('Reinterpret our history.','Lunch recollection','Held art','Enter his thought.'),'lunch_clue':('Maybe lunch was evidence.','Lunch box','Object insert','Show ordinary favor acquiring meaning.'),'homework_clue':('Maybe homework was evidence.','Held homework page','Bounded hand path and live question','Make mistaken deduction tangible.'),'charming':('Perhaps I am charming.','ADB modest blush','Portrait','Peak hopeful self-image.'),'answer':('Try an honest answer.','ADB commitment','Lean then settle','Let him choose vulnerability.'),'laugh':('She breaks character.','Friend laugh illustration','Expression cut','Reverse sincerity.'),'prank':('I believed the setup.','ADB stopped face','Deadpan and compact correction','Protect quiet recognition.'),'accomplice':('He was involved too.','Classmate laughing','Classroom wide','Reveal teamwork.'),'group_project':('They finally did the work.','ADB dry gaze','Portrait','Reframe embarrassment as joke.'),'staring':('Pretend I am fine.','ADB downcast gaze','Desk reaction','Give aftermath time.'),'upset':('She checks on me.','Friend beside ADB','Two-shot','Keep relationship warm.'),'speech':('A dry comeback will do.','ADB explaining gesture','Portrait','Recover composure.'),'sanction':('Remove borrowing privileges.','Homework notebook','Object callback','Attempt dignity.'),'one_day':('It did not last.','ADB steady gaze','Still portrait','Undercut sanction.'),'science':('I need her notes too.','ADB and school desk','Warm return and final hold','Resolve friendship callback.')}
for s in shots:
    event('camera_'+s['id'],s['start'],thoughts[s['id']][3])
    th,focus,visual,intent=thoughts[s['id']];brief['beats'].append(dict(start=s['start'],end=s['end'],thought=th,focus=focus,visual=visual,intent=intent))
spec=dict(version=2,title='My Best Friend Had a Crush on Me',duration=duration,fps=30,caption_size=50,audio='res://'+str((audio/'narration.wav').relative_to(ROOT)),audio_metadata='res://'+str((audio/'timeline.json').relative_to(ROOT)),direction=brief,actors=[actor],shots=shots,drawings=drawings,props=props,vfx=vfx,sfx=sfx,events=events,script=script,captions=captions)
spec['mix']=calibrate_mix(spec,ROOT)
(EP/'scene.json').write_text(json.dumps(spec,indent=2)+'\n')
(EP/'review/sfx_cues.json').write_text(json.dumps(sound_records,indent=2)+'\n')
(EP/'camera_plan.json').write_text(json.dumps([dict(event='camera_'+s['id'],at=s['start'],spoken_anchor=' '.join(w['word'] for w in words[next((i for i,w in enumerate(words) if w['start']>=s['start']-.06),len(words)-1):][:4]),camera=s['camera'],focus=thoughts[s['id']][1],intent=thoughts[s['id']][3]) for s in shots],indent=2)+'\n')
print('Scene',duration,'seconds;',len(shots),'shots;',len(words),'measured word spans;',len(captions),'caption cards;',len(actor['mouths']),'authored mouth intervals.')
