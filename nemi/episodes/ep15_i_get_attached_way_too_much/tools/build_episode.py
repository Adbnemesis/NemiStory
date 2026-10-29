"""Direct EP15 from the final canonical Sohee recording, using the shared v2 stage."""
import json
import re
import sys
from pathlib import Path

EP = Path(__file__).resolve().parent.parent
ROOT = EP.parents[2]
sys.path.insert(0, str(ROOT / 'tools/storytime'))
from validate_scene import validate
from audio_mix import calibrate_mix

story = json.loads((EP / 'story.json').read_text())
timeline = json.loads((EP / 'timing_reference_r1.json').read_text())
records = json.loads((EP / 'source_words.json').read_text())
words = timeline['words']
duration = timeline['duration']
assert 150 <= duration <= 180, f'Runtime outside user range: {duration}'
groups = []
offset = 0
for record in records:
    n = len(record['words'])
    groups.append(words[offset:offset+n])
    offset += n
assert offset == len(words)
starts = [g[0]['start'] for g in groups]
ends = [g[-1]['end'] for g in groups]

def clean(s):
    return re.sub(r'[^a-z0-9]', '', s.lower())

def key(line, phrase, occurrence=0):
    target = [clean(x) for x in phrase.split()]
    g = groups[line]
    matches = [i for i in range(len(g)-len(target)+1)
               if [clean(w['word']) for w in g[i:i+len(target)]] == target]
    if len(matches) <= occurrence:
        raise ValueError(f'Measured anchor missing in line {line}: {phrase}; ' + ' '.join(w['word'] for w in g))
    return g[matches[occurrence]]['start']

def r(t):
    return round(float(t), 6)

events = []
def event(name, at, intent):
    events.append(dict(id=name, at=r(at), intent=intent))
    return r(at)

E = {
    'contract': event('contract', key(0,'lifetime'), 'Nemi mentally overcommits; notebook contract metaphor.'),
    'reunion': event('reunion', key(0,'reunion'), 'Dry reveal of the imagined reunion.'),
    'city': event('city', key(1,'city'), 'Establish the unnamed city visited with family.'),
    'invite': event('invite', key(2,'asked'), 'Nemi sends an invitation to the two old friends.'),
    'daydream': event('daydream', key(2,'in my head'), 'The imagined catch-up becomes a cafe vignette.'),
    'busy': event('busy', key(3,'busy'), 'Two anonymous busy replies replace the imagined day.'),
    'stare': event('stare', key(3,'stared'), 'Eyes find the phone before the shoulders lower.'),
    'hurt': event('hurt', key(4,'hurting'), 'Let the hurt land without comic sound or marks.'),
    'missed': event('missed', key(5,'missed'), 'Personal admission; hold the face quietly.'),
    'school': event('school', key(6,'school'), 'Return to the earlier classroom memory.'),
    'typing': event('typing', key(6,'text'), 'Enthusiastic outgoing school messages.'),
    'small_reply': event('small_reply', key(6,'small'), 'Small reply contrasts with the outgoing enthusiasm.'),
    'mistake': event('mistake', key(7,'spelling mistake'), 'She treats her own excitement as something to edit.'),
    'neeko': event('neeko', key(8,'neeko'), 'Neeko memory portrait; warm and quiet, no loss tragedy.'),
    'family': event('family', key(8,'family'), 'The attachment persists after Neeko finds a family.'),
    'remember': event('remember', key(9,'remember'), 'A remembered bond is held as one warm illustration.'),
    'storage': event('storage', key(9,'storage'), 'One dry storage-plan aside releases the tension.'),
    'less': event('less', key(10,'matter less'), 'Reject the equation between quiet replies and worth.'),
    'phone_down': event('phone_down', key(11,'phone down'), 'A phone rests while Nemi reclaims her attention.'),
    'self': event('self', key(11,'for myself'), 'Return to the face and hold the personal choice.')
}

# Shot changes are measured spoken thoughts, never a fixed-rate layout cycle.
cuts = [
 (0,'hook','attachment_home','portrait','Unequal attachment is a personal admission.'),
 (key(0,'someone'),'contract','attachment_home','medium','Show the lifetime-contract metaphor beside the storyteller.'),
 (key(0,'they were'),'ordinary_conversation','attachment_home','portrait','Dry contrast with the other person having a conversation.'),
 (key(0,'planning'),'planned_reunion','attachment_home','medium','Reveal the disproportionate imagined reunion.'),
 (starts[1]-.12,'city_arrival','attachment_city','wide','Establish a real city street and grounded suitcase.'),
 (key(1,'so obviously'),'excited','attachment_city','portrait','Read the hopeful face.'),
 (starts[2]-.12,'invitation','attachment_city','medium','Read the held phone and inviting gesture together.'),
 (E['daydream'],'imagined_catchup','attachment_city','medium','Let the cafe reunion take the primary focus.'),
 (starts[3]-.12,'busy_replies','attachment_city','medium','Replace the imagined afternoon with two replies.'),
 (E['stare'],'phone_stare','attachment_city','portrait','Reaction after the evidence, with room for silence.'),
 (key(3,'so far'),'far_away','attachment_city','wide','The suitcase makes the journey tangible.'),
 (starts[4]-.12,'unsaid','attachment_city','portrait','Distinguish the thought she wanted to say from an invented confrontation.'),
 (key(4,'work'),'their_lives','attachment_city','medium','Release the grip and acknowledge other lives.'),
 (key(4,'stop'),'still_hurts','attachment_city','portrait','Quiet sadness, without mocking the friends.'),
 (starts[5]-.12,'empty_afternoon','attachment_city','medium','The same empty cafe chairs now mean disappointment.'),
 (key(5,'id missed'),'missed_too','attachment_city','portrait','Leave the vulnerable admission on the face.'),
 (starts[6]-.12,'school_memory','school_corridor_r4','wide','Establish the earlier school corridor with grounded lockers and a door.'),
 (E['typing'],'school_messages','school_corridor_r4','medium','Compare enthusiastic outgoing lines to a short reply.'),
 (starts[7]-.12,'feeling_silly','school_corridor_r4','portrait','Embarrassed down-right glance.'),
 (key(7,'read my'),'editing_excitement','school_corridor_r4','medium','The excitement becomes an imagined spelling correction.'),
 (key(7,'maybe'),'said_less','school_corridor_r4','portrait','Hold the doubt after the illustration clears.'),
 (starts[8]-.12,'animal_attachment','attachment_home','medium','Neeko memory has its own warm space.'),
 (key(8,'cared'),'neeko_care','attachment_home','portrait','Read the warmth rather than decorating the cat.'),
 (key(8,'even after'),'neeko_memory','attachment_home','medium','Keep the cat portrait after the adoption reference.'),
 (starts[9]-.12,'carried_memories','attachment_home','medium','A heart thread connects remembered bonds.'),
 (key(9,'sometimes'),'storage_aside','attachment_home','medium','One compact storage-plan joke, then clear it.'),
 (starts[10]-.12,'figuring_out','attachment_home','portrait','No claim of having solved attachment.'),
 (key(10,'quiet reply'),'worth_revision','attachment_home','medium','Cross out the worth inference with a visible authored pen action.'),
 (starts[11]-.12,'put_phone_down','attachment_home','medium','Phone at rest provides the opening callback.'),
 (key(11,'whole day'),'own_day','attachment_home','wide','Return to a grounded room with space around Nemi.'),
 (key(11,'ill probably'),'care_for_self','attachment_home','portrait','End on a soft face, without extra moral captions or sound.')
]
cuts = [(r(t),name,bg,frame,reason) for t,name,bg,frame,reason in cuts]
assert all(cuts[i][0]<cuts[i+1][0] for i in range(len(cuts)-1))
shots = []
camera_plan = []
for i,(a,name,bg,frame,reason) in enumerate(cuts):
    b = cuts[i+1][0] if i+1<len(cuts) else duration
    camera = {'portrait':dict(center=[570,365],zoom=2.05),
              'medium':dict(center=[900,505],zoom=1.18),
              'wide':dict(center=[960,540],zoom=1.0)}[frame]
    # Two deliberate settling reframes; emotional portraits otherwise hold.
    if name in ('city_arrival','own_day'):
        camera['path'] = [dict(at=a,center=camera['center'],zoom=camera['zoom']),
                              dict(at=r(a+.7),center=camera['center'],zoom=camera['zoom']),
                              dict(at=r(min(b-.1,a+2.0)),center=[940,530],zoom=1.03)]
    shots.append(dict(id=name,start=a,end=b,background=bg,
        actors={'nemi':dict(position=[570,533.25],scale=1.75)},camera=camera))
    camera_plan.append(dict(start=a,end=b,spoken_anchor=next((w['word'] for w in words if w['start']>=a),'opening pause'),
        focus=reason,framing=frame,reason=reason,return_or_hold='Hold until the next named thought.'))

# Nemi's local foot anchors are 206.14 units below root; root y533.25 places
# them near the shared y894 ground. Proof stills verify the actual shoes.
performances=[]
def act(at, recipe, gaze=(0,0), hands=None, face=None, duration=.38, motion='smooth', event_id=None):
    c=dict(at=r(at),recipe=recipe,duration=duration,gaze=list(gaze),hands=hands or {'left':'relaxed','right':'relaxed'})
    if face:c['face']=face
    if motion!='smooth':c['motion']=motion
    if motion=='stepped':c['step_fps']=12
    if event_id:c['event']=event_id
    performances.append(c)

act(0,'school_confide',face={'eye_openness':.94,'left_brow_offset':[0,-1]})
act(key(0,'brain'),'realization',gaze=(.3,-.1))
act(key(0,'conversation'),'deadpan',motion='snap')
act(key(0,'planning'),'pleased',gaze=(.45,0))
act(starts[1],'school_explain',hands={'left':'open_palm_up','right':'relaxed'})
act(key(1,'two or three'),'school_question',gaze=(-.2,-.1))
act(key(1,'excited'),'pleased',face={'eye_openness':1.08})
phone_start=cuts[6][0]
phone_end=cuts[11][0]
act(phone_start,'prop_present',gaze=(.25,.2),hands={'left':'relaxed','right':'hold_prop'},motion='snap')
act(E['daydream'],'school_explain',gaze=(.5,-.05),hands={'left':'open_palm_up','right':'hold_prop'})
act(E['busy'],'quiet_recoil',gaze=(.3,.25),hands={'left':'relaxed','right':'hold_prop'},event_id='busy')
act(E['stare'],'overwhelmed',gaze=(.2,.3),hands={'left':'relaxed','right':'hold_prop'},duration=.5)
act(key(3,'one day'),'skeptical',hands={'left':'finger_count_one','right':'hold_prop'},motion='stepped')
act(phone_end,'school_confide',gaze=(-.15,.12),motion='snap')
act(key(4,'work'),'soft_shrug',hands={'left':'open_palm_up','right':'open_palm_up'})
act(E['hurt'],'overwhelmed',gaze=(-.12,.2),duration=.55,event_id='hurt')
act(starts[5],'school_question',gaze=(.35,.05))
act(key(5,'not have'),'quiet_recoil',gaze=(.1,.15))
act(key(5,'wanted'),'school_confide',face={'eye_openness':.87,'left_brow_offset':[0,-1.6]})
act(starts[6],'recover')
act(E['typing'],'school_present',gaze=(.45,.1),hands={'left':'relaxed','right':'open_palm_up'})
act(key(6,'so much'),'lean_in',gaze=(.3,0))
act(E['small_reply'],'embarrassed',gaze=(-.3,.2),duration=.42,event_id='small_reply')
act(starts[7],'school_shame',gaze=(-.25,.2))
act(key(7,'read my'),'school_question',gaze=(.45,.15))
act(key(7,'maybe'),'uncertain',gaze=(-.2,.2),face={'eye_openness':.9})
act(starts[8],'school_explain',hands={'left':'open_palm_up','right':'relaxed'})
act(E['neeko'],'pleased',gaze=(.45,.05),duration=.5,event_id='neeko')
act(key(8,'cared'),'school_confide',gaze=(0,0),face={'eye_openness':.92})
act(E['family'],'school_relief',gaze=(.4,.05),event_id='family')
act(starts[9],'school_confide')
act(key(9,'carry'),'prop_present',gaze=(.4,0),hands={'left':'relaxed','right':'open_palm_up'})
act(key(9,'slightly'),'skeptical',gaze=(.35,-.05))
act(E['storage'],'deadpan',motion='snap',event_id='storage')
act(starts[10],'uncertain',duration=.45)
act(key(10,'dont want'),'school_resolve',hands={'left':'relaxed','right':'open_palm_up'})
act(E['less'],'quiet_recoil',gaze=(.45,0),event_id='less')
act(E['less']+1.2,'recover',gaze=(0,0),duration=.5)
act(starts[11],'school_relief',duration=.45)
act(E['phone_down'],'recover',gaze=(.35,.15),event_id='phone_down')
act(key(11,'without'),'school_resolve',gaze=(0,0))
act(key(11,'ill probably'),'soft_shrug',hands={'left':'open_palm_up','right':'relaxed'})
act(E['self'],'school_relief',face={'eye_openness':.93},duration=.6,event_id='self')
performances.sort(key=lambda c:c['at'])
for i,c in enumerate(performances):
    if i+1<len(performances):c['duration']=r(min(c['duration'],performances[i+1]['at']-c['at']-.005))
    if c['duration']<.06:c['duration']=0;c['motion']='snap'
    next_at=performances[i+1]['at'] if i+1<len(performances) else duration
    # Deliberate blinks during settled phrases; no repeated timer or mouth trigger.
    if next_at-c['at']>3.0:c['blinks']=[r(c['at']+2.15)]

drawings=[]
props=[]
def art(kind,a,b,pos=(1190,490),scale=1.0,mode='hold',draw_duration=.8,text=None,size=52,accent=False,shots_filter=None,event_id=None,layer=2):
    item=dict(author='nemi',kind=kind,at=r(a),end=r(b),position=list(pos),scale=[scale,scale],mode=mode,layer=layer)
    if mode=='live':item['duration']=draw_duration
    if text is not None:item.update(text=text,size=size,accent=accent)
    if shots_filter:item['shots']=shots_filter
    if event_id:item['event']=event_id
    drawings.append(item)
    return item

def cut(name):return next(s for s in shots if s['id']==name)
def end(name):return cut(name)['end']

art('notebook',E['contract'],end('contract'),pos=(1190,480),scale=1.55,event_id='contract')
art('text',E['contract'],end('contract'),pos=(1045,460),text='lifetime?',size=48)
art('underline',E['contract'],end('contract'),pos=(1190,535),scale=1.8,mode='live',draw_duration=.65,event_id='contract')
art('attachment_reunion',key(0,'planning'),end('planned_reunion'),scale=.9)
art('suitcase',cut('city_arrival')['start'],end('city_arrival'),pos=(815,853),scale=.95,layer=0)
art('suitcase',cut('far_away')['start'],end('far_away'),pos=(815,853),scale=.95,layer=0)
art('attachment_invite',E['invite'],E['daydream'],event_id='invite')
art('attachment_reunion',E['daydream'],end('imagined_catchup'),scale=1.05,event_id='daydream')
art('attachment_busy',E['busy'],end('busy_replies'),event_id='busy')
art('text',E['busy'],end('busy_replies'),pos=(1110,350),text='busy',size=47,accent=True)
art('text',E['busy']+.65,end('busy_replies'),pos=(1200,555),text='busy',size=47)
art('attachment_reunion',cut('empty_afternoon')['start'],end('empty_afternoon'),scale=.95)
art('attachment_messages',E['typing'],end('school_messages'),event_id='typing')
art('underline',E['small_reply'],end('school_messages'),pos=(1320,600),scale=1.05,mode='live',draw_duration=.55,event_id='small_reply')
art('attachment_invite',cut('editing_excitement')['start'],E['mistake'],scale=.88)
art('text',E['mistake'],end('editing_excitement'),pos=(1000,445),text='too excited?',size=52,accent=True,event_id='mistake')
art('underline',E['mistake']+.6,end('editing_excitement'),pos=(1180,530),scale=2.1,mode='live',draw_duration=.7)
art('attachment_neeko',E['neeko'],end('animal_attachment'),pos=(1200,505),scale=1.0,event_id='neeko')
art('attachment_neeko',cut('neeko_memory')['start'],end('neeko_memory'),pos=(1200,505),scale=1.0)
art('attachment_heart_thread',cut('carried_memories')['start'],end('carried_memories'),pos=(1190,490))
art('tabs',cut('storage_aside')['start'],end('storage_aside'),pos=(1200,485),scale=1.1)
art('text',E['storage'],end('storage_aside'),pos=(1070,660),text='storage full',size=44,event_id='storage')
art('text',cut('worth_revision')['start'],end('worth_revision'),pos=(1010,400),text='i matter less',size=50,accent=True)
revision=art('scratch',E['less']+.65,end('worth_revision'),pos=(1200,440),scale=2.5,mode='live',draw_duration=.5,event_id='less')
revision['event_offset']=.65
art('text',E['less']+1.2,end('worth_revision'),pos=(1070,535),text='still me',size=56,mode='live',draw_duration=.75)
resting_phone=art('phone',E['phone_down'],end('own_day'),pos=(1430,612),scale=1.1,event_id='phone_down')
resting_phone['tilt']=90

# A phone is already in Nemi's hand on the invitation cut. The grip is continuous
# through the city reply, then is cleared with the next cut; no false pickup.
props.append(dict(author='nemi',kind='phone',at=phone_start,end=phone_end,mode='hold',
    position=[0,0],scale=[.66,.66],layer=0,
    attach=dict(actor='nemi',hand='right',grip=[0,11],socket=[0,8],angle=0)))
hand_paths={'right':[dict(at=phone_start,position=[75,-35],angle=-8),
    dict(at=E['busy'],position=[75,-35],angle=-8),
    dict(at=r(E['stare']+.5),position=[68,-12],angle=0,bend=[6,0]),
    dict(at=phone_end,position=[68,-12],angle=0)]}

script=[]
for i,g in enumerate(groups):
    script.append(dict(actor='nemi',start=r(max(0,g[0]['start']-.01)),end=r(g[-1]['end']+.01),text=story['lines'][i]))

# Cards respect measured pauses and punctuation, with at most five words.
captions=[]
begin=0
for i,w in enumerate(words):
    last=i==len(words)-1
    gap=last or words[i+1]['start']-w['end']>=.35
    punct=w['word'].rstrip().endswith(('.', '?', '!', ',', ';', ':'))
    if i-begin+1>=5 or gap or punct:
        captions.append(dict(actor='nemi',words=[begin,i],start=words[begin]['start'],end=w['end'],
                             text=' '.join(x['word'] for x in words[begin:i+1])))
        begin=i+1

# Existing mouth vocabulary: word-derived vowels plus explicit labial closures.
# These are authored approximations from measured words, not phoneme analysis.
mouths=[]
for w in words:
    a,b=w['start'],w['end']
    token=clean(w['word'])
    if b-a<.045:continue
    onset=.035 if token.startswith(('m','b','p')) else .012
    vowel='o_u' if re.search(r'(oo|ou|ow|you|too|phone)',token) else 'ae' if re.search(r'(a|ai|ei)',token) else 'small_open'
    if onset>.02:mouths.append(dict(start=r(a),end=r(a+onset),shape='closed'))
    close=.035 if b-a>.10 else .015
    mouths.append(dict(start=r(a+onset),end=r(b-close),shape=vowel))
    mouths.append(dict(start=r(b-close),end=r(b),shape='closed'))

palette=json.loads((EP/'sound_palette.json').read_text())
sound_plan=[]
sfx=[]
for pick in palette['cues']:
    name={'lifetime_contract_underline':'contract','reunion_daydream_reveal':'reunion',
          'city_location_reveal':'city','city_invitation_send':'invite','city_busy_reply':'busy',
          'school_excited_typing':'typing','school_small_reply':'small_reply',
          'reread_excitement_correction':'mistake','remember_people_card':'remember',
          'storage_plan_comic_aside':'storage','self_worth_live_correction':'less',
          'phone_resting_contact':'phone_down'}[pick['event']]
    if name not in E:raise ValueError('Unknown sound event '+name)
    # The external comic voice follows the storage phrase in the actual gap.
    delta=r(ends[9]+.12-E[name]) if name=='storage' else .65 if name=='less' else 0
    at=E[name]+delta
    cue=dict(file=pick['file'],at=r(at),duration=1.2 if name=='less' else pick['duration'],gain_db=pick['gain_db'],event=name)
    if delta:cue['event_offset']=delta
    sfx.append(cue)
    record=dict(pick)
    record.update(at=r(at),event=name,source_palette_event=pick['event'],duration=cue['duration'],event_offset=delta)
    sound_plan.append(record)

vfx=[dict(author='nemi',kind='realization',actor='nemi',offset=[100,-80],at=E['contract'],end=r(E['contract']+.65),strength=.55,event='contract'),
     dict(author='nemi',kind='tension',actor='nemi',offset=[100,-60],at=E['busy'],end=r(E['busy']+.6),strength=.55,event='busy'),
     dict(author='nemi',kind='relief',actor='nemi',offset=[80,-50],at=E['self'],end=r(E['self']+.7),strength=.45,event='self')]

thoughts=[
 ('A friendly conversation becomes a lifetime bond.','Nemi and contract metaphor','Notebook appears, dry portrait, imagined reunion clears.','Show her self-awareness immediately.'),
 ('The city trip offers a reunion after years.','City and hopeful face','Street wide, suitcase, then an excited portrait.','Give the anticipation a specific place.'),
 ('She imagines the whole catch-up before it happens.','Held phone then imagined cafe','Continuous phone grip and a cafe vignette.','Let hope create the stakes.'),
 ('Both friends are busy.','Reply evidence then hurt reaction','Two replies replace the imagined day; face then suitcase wide.','Respect the disappointment without inventing motives.'),
 ('Understanding other lives does not erase hurt.','Quiet face and open hands','Release the phone at a cut, acknowledge their plans, settle.','Keep emotional complexity.'),
 ('She wanted to feel missed too.','Empty chairs then portrait','Cafe callback changes meaning, quiet admission.','Let the central hurt land.'),
 ('The same unequal energy happened in school.','Outgoing versus incoming message','School corridor wide then message evidence, small underline.','Connect the present to the older pattern.'),
 ('She edits her own excitement in her head.','Embarrassed face then imagined correction','Down-right glance, text revision metaphor, clear it.','Keep the comedy on her overthinking.'),
 ('Neeko mattered beyond the time they shared.','Neeko portrait and warm face','Canonical cream/ginger cat memory; no tragedy claim.','Show the caring side of attachment.'),
 ('Memories stay after life moves forward.','Heart thread then one storage aside','Held warm metaphor then compact dry joke.','Release tension without trivializing care.'),
 ('A quiet reply does not define her worth.','Personal doubt and live correction','Matter-less text is crossed out, still-me lettering settles.','Show a tentative choice rather than a cure.'),
 ('She can care while keeping some care for herself.','Resting phone then final face','Phone callback, room wide, gentle final portrait.','Resolve the opening without a lecture.')]
beats=[]
for i,(thought,focus,visual,intent) in enumerate(thoughts):
    beats.append(dict(start=0 if i==0 else r(starts[i]-.12),end=duration if i==11 else r(starts[i+1]-.12),
        thought=thought,focus=focus,visual=visual,intent=intent))
spec=dict(version=2,title=story['title'],duration=duration,fps=30,caption_size=52,
    audio='res://'+str((EP/'voice/narration_r1.wav').relative_to(ROOT)),
    audio_metadata='res://'+str((EP/'timing_reference_r1.json').relative_to(ROOT)),
    direction=dict(promise='A short reply hurts because Nemi has already imagined shared excitement.',
        want='Feel the care and excitement she gives coming back.',choice='Invite two old friends to meet during a family city visit.',
        consequence='Both are busy, recalling unequal school messages and lasting attachments.',
        payoff='Keep caring while putting the phone down and saving some care for herself.',beats=beats),
    actors=[dict(id='nemi',author='nemi',performances=performances,mouths=mouths,hand_paths=hand_paths,hand_path_window=[phone_start,phone_end])],
    shots=shots,drawings=drawings,props=props,vfx=vfx,sfx=sorted(sfx,key=lambda c:c['at']),events=events,script=script,captions=captions)

spec['mix']=calibrate_mix(spec,ROOT)
(EP/'scene.json').write_text(json.dumps(spec,indent=2)+'\n')
(EP/'camera_plan.json').write_text(json.dumps(camera_plan,indent=2)+'\n')
(EP/'sound_plan.json').write_text(json.dumps(dict(cues=sound_plan,intentional_silence=[
    'Unsaid disappointment, line 4','Wanted to feel missed too, line 5','Neeko cared/adoption reflection, line 8','Final care-for-myself hold']),indent=2)+'\n')
body=['# I Get Attached Way Too Much — script and measured beats','',f'Runtime: {duration:.3f}s, hard cap 180s. Canonical Sohee.','']
for i,b in enumerate(beats):
    body.extend([f"## {i+1}. {b['start']:.3f}–{b['end']:.3f}s — {b['thought']}",'',story['lines'][i],'',f"Focus: {b['focus']}. {b['visual']} {b['intent']}",''])
(EP/'SCRIPT_AND_BEATS.md').write_text('\n'.join(body))
validate(EP/'scene.json')
print(f'Validated EP15: {duration:.3f}s, {len(words)} measured words, {len(shots)} shots, {len(performances)} acting cues, {len(sfx)} sound accents.')
