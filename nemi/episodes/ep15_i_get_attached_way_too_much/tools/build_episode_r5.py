"""Direct EP15 from the final canonical Sohee recording, using the shared v2 stage."""
import json
import copy
import re
import sys
from pathlib import Path

EP = Path(__file__).resolve().parent.parent
ROOT = EP.parents[2]
sys.path.insert(0, str(ROOT / 'tools/storytime'))
from validate_scene import validate
from audio_mix import calibrate_mix

story = json.loads((EP / 'story.json').read_text())
timeline = json.loads((EP / 'timing_reference_r5.json').read_text())
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

# R5 uses settings, sequential visual consequences, and quieter portraits.
cuts = [
 (0,'hook','attachment_home','portrait','Confide before the first visual joke.'),
 (key(0,'someone'),'contract','attachment_home','medium','A contract grows and receives one heart seal.'),
 (key(0,'they were'),'ordinary_conversation','attachment_home','portrait','Dry response after the contract settles.'),
 (key(0,'planning'),'planned_reunion','attachment_cafe_r5','wide','Her premature imagined reunion becomes a whole place.'),
 (starts[1]-.12,'city_arrival','attachment_visit_r5','wide','A guest-room city window and travel bags ground the family visit.'),
 (key(1,'we hadnt'),'time_apart','attachment_visit_r5','medium','A small calendar stack shows two or three years.'),
 (key(1,'so obviously'),'excited','attachment_visit_r5','portrait','The expectation reads on her face.'),
 (starts[2]-.12,'invitation','attachment_visit_r5','medium','Show the physical held phone and invitation.'),
 (E['daydream'],'imagined_catchup','attachment_cafe_r5','wide','Three empty seats, cups, and conversation lines develop sequentially.'),
 (key(2,'talk'),'imagined_conversation','attachment_cafe_r5','cafe','Closer view of the growing imagined catch-up.'),
 (starts[3]-.12,'busy_replies','attachment_visit_r5','medium','Two anonymous busy replies replace the imagined afternoon.'),
 (E['stare'],'phone_stare','attachment_visit_r5','portrait','Eyes find the phone and shoulders settle.'),
 (key(3,'so far'),'far_away','attachment_visit_r5','wide','Travel bags and a route to two friends make the distance tangible.'),
 (key(3,'one day'),'one_day','attachment_visit_r5','medium','A single circled day underlines the unspoken request.'),
 (starts[4]-.12,'unsaid','attachment_visit_r5','portrait','Keep the complaint explicitly internal.'),
 (key(4,'work'),'their_lives','attachment_visit_r5','medium','One calendar and clock acknowledge independent lives.'),
 (key(4,'stop'),'still_hurts','attachment_visit_r5','portrait','Rest the illustration and let the hurt read.'),
 (starts[5]-.12,'empty_afternoon','attachment_cafe_r5','wide','Return to the imagined seats without conversation or cups.'),
 (key(5,'id missed'),'missed_too','attachment_visit_r5','portrait','Leave the central vulnerable admission on her face.'),
 (starts[6]-.12,'school_memory','attachment_school_nook_r5','wide','School architecture, bench, and bag establish the earlier pattern.'),
 (E['typing'],'school_messages','attachment_school_nook_r5','medium','The outgoing message develops before the tiny reply.'),
 (key(6,'so much'),'school_enthusiasm','attachment_school_nook_r5','message','Move closer as her message grows.'),
 (starts[7]-.12,'feeling_silly','attachment_school_nook_r5','portrait','Embarrassed inward gaze after the reply.'),
 (key(7,'read my'),'editing_excitement','attachment_school_nook_r5','medium','Reread a school message draft, with visible exclamation marks.'),
 (key(7,'maybe'),'said_less','attachment_school_nook_r5','portrait','The correction clears; leave the doubt on her face.'),
 (starts[8]-.12,'animal_attachment','attachment_home','medium','Neeko care is remembered through a cushion, bowl, and canonical cat.'),
 (key(8,'cared'),'neeko_care','attachment_home','portrait','Warm personal attention after the cat has registered.'),
 (key(8,'even after'),'neeko_memory','attachment_home','medium','Keep the memory after the truthful family reference.'),
 (starts[9]-.12,'carried_memories','attachment_home','medium','Recognizable keepsakes collect inside one drawer.'),
 (key(9,'even when'),'memories_stay','attachment_home','drawer','Move into the held memories while life moves on.'),
 (key(9,'sometimes'),'storage_aside','attachment_home','medium','A bounded drawer overflow becomes the dry joke.'),
 (starts[10]-.12,'figuring_out','attachment_home','portrait','Give the uncertainty one short quiet portrait.'),
 (key(10,'dont want'),'keep_caring','attachment_home','medium','Open hands preserve her caring impulse.'),
 (key(10,'quiet reply'),'worth_revision','attachment_home','medium','A tiny reply is visibly separated from her worth.'),
 (starts[11]-.12,'put_phone_down','attachment_home_care_r5','contact','The phone travels with the hand to a real resting surface.'),
 (key(11,'without'),'own_day','attachment_home_care_r5','room','The hand leaves the resting phone and her gaze returns outward.'),
 (key(11,'ill probably'),'care_for_self','attachment_home_care_r5','final','A soft face carries the ending after the physical choice.')
]
cuts = [(r(t),name,bg,frame,reason) for t,name,bg,frame,reason in cuts]
assert all(cuts[i][0]<cuts[i+1][0] for i in range(len(cuts)-1))
shots=[]
camera_plan=[]
for i,(a,name,bg,frame,reason) in enumerate(cuts):
    b=cuts[i+1][0] if i+1<len(cuts) else duration
    camera={'portrait':dict(center=[570,365],zoom=2.05),
      'medium':dict(center=[920,545],zoom=1.16),
      'wide':dict(center=[960,540],zoom=1.0),
      'cafe':dict(center=[1010,545],zoom=1.13),
      'message':dict(center=[1000,545],zoom=1.2),
      'drawer':dict(center=[1025,545],zoom=1.18),
      'contact':dict(center=[1160,550],zoom=1.17),
      'room':dict(center=[1120,540],zoom=1.0),
      'final':dict(center=[1110,365],zoom=2.05)}[frame]
    if name in ('city_arrival','imagined_catchup','school_memory','own_day'):
        camera['path']=[dict(at=a,center=camera['center'],zoom=camera['zoom']),
          dict(at=r(a+.55),center=camera['center'],zoom=camera['zoom']),
          dict(at=r(min(b-.05,a+1.65)),center=[camera['center'][0]-15,camera['center'][1]-8],zoom=round(camera['zoom']+.025,3))]
    position=[1110,533.25] if frame in ('contact','room','final') else [570,533.25]
    shots.append(dict(id=name,start=a,end=b,background=bg,actors={'nemi':dict(position=position,scale=1.75)},camera=camera))
    camera_plan.append(dict(start=a,end=b,spoken_anchor=next((w['word'] for w in words if w['start']>=a),'opening pause'),focus=reason,framing=frame,reason=reason,return_or_hold='Let the gesture and drawing settle before the next thought.'))

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
phone_start=next(c[0] for c in cuts if c[1]=='invitation')
phone_end=next(c[0] for c in cuts if c[1]=='unsaid')
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
act(starts[11]-.12,'school_relief',gaze=(.2,.25),hands={'left':'relaxed','right':'hold_prop'},duration=0,motion='snap')
act(E['phone_down'],'recover',gaze=(.35,.3),hands={'left':'relaxed','right':'hold_prop'},event_id='phone_down')
act(E['phone_down']+.29,'recover',gaze=(.3,.2),hands={'left':'relaxed','right':'relaxed'},duration=.12)
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

# Thought-specific stages replace one another instead of accumulating.
def new_art(kind,*args,**kwargs):
    return art('attachment_'+kind,*args,**kwargs)

def anchor_event(name,at,intent):
    E[name]=event(name,at,intent)
    return E[name]

anchor_event('calendar',key(1,'two or three'),'Calendar marks the years apart.')
anchor_event('cafe_cup',key(2,'catch up'),'A cup settles on the imagined cafe table.')
anchor_event('school_send',key(6,'same energy'),'The enthusiastic school message is sent.')
anchor_event('keepsake',key(9,'carry'),'Memories slide into one drawer.')
anchor_event('seal',E['contract']+.65,'The mental lifetime agreement receives a heart seal.')
new_art('contract_scroll',key(0,'brain'),end('contract'),mode='live',draw_duration=.95)
new_art('contract_seal',E['seal'],end('contract'),mode='live',draw_duration=.5,event_id='seal')
new_art('cafe_conversation',cut('planned_reunion')['start'],end('planned_reunion'),scale=.82,pos=(1300,395))
new_art('time_apart',cut('time_apart')['start'],end('time_apart'),mode='live',draw_duration=.9)
new_art('journey_friends',cut('city_arrival')['start'],end('city_arrival'),pos=(1210,450),scale=.78)
art('attachment_invite',E['invite'],E['daydream'],mode='live',draw_duration=.75,event_id='invite')
# The café is explicitly an imagination. Cups and conversation develop in turn.
for name,at in [('cafe_cup_one',E['cafe_cup']),('cafe_cup_two',key(2,'talk')),('cafe_cup_three',key(2,'forget'))]:
    cup=new_art(name,at,end('imagined_conversation'),pos=(0,0),mode='hold' if name=='cafe_cup_one' else 'live',draw_duration=.4)
    if name=='cafe_cup_one':cup['path']=[dict(at=r(at),position=[0,-24]),dict(at=r(at+.4),position=[0,0])]

new_art('cafe_conversation',key(2,'everything'),end('imagined_conversation'),pos=(1275,415),scale=.88,mode='live',draw_duration=1.1)
new_art('busy_first',E['busy'],end('busy_replies'),mode='live',draw_duration=.4,event_id='busy')
new_art('busy_second',E['busy']+.5,end('busy_replies'),mode='live',draw_duration=.4)
new_art('journey_friends',cut('far_away')['start'],end('far_away'),pos=(1210,450),scale=.84)
new_art('journey_route',cut('far_away')['start']+.3,end('far_away'),pos=(1210,450),scale=.84,mode='live',draw_duration=.9)
new_art('life_calendar',cut('one_day')['start'],end('one_day'),scale=.83)
art('text',cut('one_day')['start'],end('one_day'),pos=(1100,720),text='one day?',size=44)
new_art('life_calendar',cut('their_lives')['start'],end('their_lives'),mode='live',draw_duration=1.25)
# The imagined seats are empty for the missed-too admission. No comic accents.
new_art('school_message_frame',E['typing'],end('school_enthusiasm'),event_id='typing')
new_art('school_message_first',E['typing']+.1,end('school_enthusiasm'),mode='live',draw_duration=.7)
new_art('school_message_second',key(6,'hoping'),end('school_enthusiasm'),mode='live',draw_duration=.8)
art('arrow',E['school_send'],E['school_send']+.65,pos=(1340,690),scale=.6,mode='live',draw_duration=.3,event_id='school_send')
art('text',key(6,'so much'),E['small_reply'],pos=(1290,375),text='!!!',size=54,mode='live',draw_duration=.5)
new_art('school_message_reply',E['small_reply'],end('school_enthusiasm'),mode='live',draw_duration=.35,event_id='small_reply')
new_art('message_edit',cut('editing_excitement')['start'],end('editing_excitement'))
new_art('message_edit_crossout',E['mistake'],end('editing_excitement'),mode='live',draw_duration=.85,event_id='mistake')
art('text',E['mistake']+.5,end('editing_excitement'),pos=(1060,690),text='too much?',size=44)
new_art('neeko_care',E['neeko'],end('animal_attachment'),pos=(1220,500),event_id='neeko')
new_art('neeko_care',cut('neeko_memory')['start'],end('neeko_memory'),pos=(1220,500),scale=.95)
new_art('memory_drawer',E['remember'],end('storage_aside'),mode='live',draw_duration=.85,event_id='remember')
keepsakes=new_art('memory_keepsakes',E['keepsake'],end('storage_aside'),event_id='keepsake')
keepsakes['path']=[dict(at=E['keepsake'],position=[1190,458]),dict(at=r(E['keepsake']+.5),position=[1190,490])] 
new_art('memory_overflow',E['storage'],end('storage_aside'),mode='live',draw_duration=.6,event_id='storage')
art('text',E['storage']+.6,end('storage_aside'),pos=(1100,720),text='storage full',size=42)
art('attachment_heart_thread',cut('keep_caring')['start'],end('keep_caring'),pos=(1210,500),scale=.87,mode='live',draw_duration=1.0)
new_art('worth_reply',cut('worth_revision')['start'],end('worth_revision'),pos=(1190,350))
art('text',cut('worth_revision')['start'],end('worth_revision'),pos=(1005,520),text='i matter less?',size=42,accent=True)
revision=art('scratch',E['less']+.65,end('worth_revision'),pos=(1210,555),scale=2.5,mode='live',draw_duration=.5,event_id='less')
revision['event_offset']=.65
new_art('worth_heart',E['less']+1.2,end('worth_revision'),pos=(1190,350),mode='live',draw_duration=.65)
# Continuous held phone in the city. The final release has its own authored path.
props.append(dict(author='nemi',kind='phone',at=phone_start,end=phone_end,mode='hold',position=[0,0],scale=[.66,.66],layer=0,attach=dict(actor='nemi',hand='right',grip=[0,11],socket=[0,8],angle=0)))
release_start=cut('put_phone_down')['start']
release_at=E['phone_down']+.28
release_end=release_at+.65
# At rotation 90°, local phone bottom is 25*.66*1.75=28.875 below its origin.
# Hand/grip alignment is verified from the actual sampled Godot transforms.
rest_position=[1222.455,481.125]
props.append(dict(author='nemi',kind='phone',at=release_start,end=end('own_day'),mode='hold',position=rest_position,scale=[.66,.66],tilt=90,layer=0,
    attach=dict(actor='nemi',hand='right',grip=[0,11],socket=[0,8],angle=0),attach_start=release_start,attach_end=r(release_at)))
hand_paths={'right':[dict(at=release_start,position=[65,-55],angle=5),
    dict(at=r(E['phone_down']-.2),position=[65,-55],angle=5),
    dict(at=r(release_at),position=[65,-29.785714],angle=90,bend=[5,-7]),
    dict(at=r(release_end),position=[86.62292,30.3262],angle=-41,bend=[-6,-9])]}

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
    delta=r(ends[9]+.12-E[name]) if name=='storage' else .65 if name=='less' else .28 if name=='phone_down' else .65 if name=='contract' else 0
    at=E[name]+delta
    cue=dict(file=pick['file'],at=r(at),duration=1.2 if name=='less' else pick['duration'],gain_db=pick['gain_db'],event=name)
    if delta:cue['event_offset']=delta
    sfx.append(cue)
    record=dict(pick)
    record.update(at=r(at),event=name,source_palette_event=pick['event'],duration=cue['duration'],event_offset=delta)
    sound_plan.append(record)

# Additional details remain isolated audible events, using the existing library.
extra=json.loads((EP/'review/R5_SOUND_PROPOSAL.json').read_text())['cues']
extra_map={'contract_unfold':('contract',0),'time_apart_calendar':('calendar',0),
    'cafe_cup_contact':('cafe_cup',.4),'school_send':('school_send',0),
    'memory_photo_slide':('keepsake',0)}
for pick in extra:
    if pick['event'] not in extra_map:continue
    name,delta=extra_map[pick['event']]
    cue=dict(file=pick['file'],at=r(E[name]+delta),duration=pick['duration'],gain_db=pick['gain_db'],event=name)
    if delta:cue['event_offset']=delta
    sfx.append(cue)
    sound_plan.append(dict(pick,at=cue['at'],event=name,event_offset=delta))

vfx=[dict(author='nemi',kind='realization',actor='nemi',offset=[100,-80],at=E['contract'],end=r(E['contract']+.65),strength=.55,event='contract'),
     dict(author='nemi',kind='tension',actor='nemi',offset=[100,-60],at=E['busy'],end=r(E['busy']+.6),strength=.55,event='busy'),
     dict(author='nemi',kind='relief',actor='nemi',offset=[80,-50],at=E['self'],end=r(E['self']+.7),strength=.45,event='self')]

thoughts=[
 ('A friendly conversation becomes a lifetime bond.','Nemi and contract metaphor','A contract unfurls and receives one heart seal, then the imagined reunion becomes a cafe.','Show her self-awareness immediately.'),
 ('The city trip offers a reunion after years.','City and hopeful face','Guest-room city window, travel bags, years-apart calendar, and an excited portrait.','Give the anticipation a specific place.'),
 ('She imagines the whole catch-up before it happens.','Held phone then imagined cafe','Continuous phone grip; a full imagined cafe develops cups and conversation sequentially.','Let hope create the stakes.'),
 ('Both friends are busy.','Reply evidence then hurt reaction','Two replies arrive separately; face, travel route, and one circled day develop the hurt.','Respect the disappointment without inventing motives.'),
 ('Understanding other lives does not erase hurt.','Quiet face and open hands','Release the phone at a cut, calendar/clock acknowledgment, then quiet hurt.','Keep emotional complexity.'),
 ('She wanted to feel missed too.','Empty chairs then portrait','Cafe callback changes meaning, quiet admission.','Let the central hurt land.'),
 ('The same unequal energy happened in school.','Outgoing versus incoming message','A school bench and bag establish place; outgoing messages build, send, then the tiny reply arrives.','Connect the present to the older pattern.'),
 ('She edits her own excitement in her head.','Embarrassed face then imagined correction','Down-right glance, specific excited draft and crossed exclamation marks, then clear.','Keep the comedy on her overthinking.'),
 ('Neeko mattered beyond the time they shared.','Neeko portrait and warm face','Canonical cream/ginger cat with care belongings; no tragedy claim.','Show the caring side of attachment.'),
 ('Memories stay after life moves forward.','Heart thread then one storage aside','Recognizable photo/chat keepsakes slide into a drawer, then a compact overflow joke.','Release tension without trivializing care.'),
 ('A quiet reply does not define her worth.','Personal doubt and live correction','A tiny reply and an empty worth-heart implication are separated by a live correction; the heart completes.','Show a tentative choice rather than a cure.'),
 ('She can care while keeping some care for herself.','Resting phone then final face','Authored hand travel and release onto a real counter, hand withdrawal, room wide, gentle final portrait.','Resolve the opening without a lecture.')]
beats=[]
for i,(thought,focus,visual,intent) in enumerate(thoughts):
    beats.append(dict(start=0 if i==0 else r(starts[i]-.12),end=duration if i==11 else r(starts[i+1]-.12),
        thought=thought,focus=focus,visual=visual,intent=intent))
spec=dict(version=2,title=story['title'],duration=duration,fps=30,caption_size=52,
    audio='res://'+str((EP/'voice/narration_r5.wav').relative_to(ROOT)),
    audio_metadata='res://'+str((EP/'timing_reference_r5.json').relative_to(ROOT)),
    direction=dict(promise='A short reply hurts because Nemi has already imagined shared excitement.',
        want='Feel the care and excitement she gives coming back.',choice='Invite two old friends to meet during a family city visit.',
        consequence='Both are busy, recalling unequal school messages and lasting attachments.',
        payoff='Keep caring while putting the phone down and saving some care for herself.',beats=beats),
    actors=[dict(id='nemi',author='nemi',performances=performances,mouths=mouths,hand_paths=hand_paths,hand_path_window=[release_start,release_end])],
    shots=shots,drawings=drawings,props=props,vfx=vfx,sfx=sorted(sfx,key=lambda c:c['at']),events=events,script=script,captions=captions)

# A second stage instance of the unchanged Nemi rig gives the city phone its
# own bounded contact interval; only one instance is visible in any shot.
# This preserves the expressive left arm/body while the right wrist keeps grip.
city_actor=copy.deepcopy(spec['actors'][0])
city_actor.update(id='nemi_city',hand_path_window=[phone_start,phone_end],hand_paths={'right':[
    dict(at=phone_start,position=[75,-35],angle=-8),
    dict(at=E['busy'],position=[75,-35],angle=-8),
    dict(at=r(E['stare']+.5),position=[68,-12],angle=0,bend=[6,0]),
    dict(at=phone_end,position=[68,-12],angle=0)]})
city_actor['mouths']=[m for m in mouths if phone_start<=m['start']<phone_end]
spec['actors'][0]['mouths']=[m for m in mouths if not phone_start<=m['start']<phone_end]
spec['actors'].append(city_actor)
for shot in shots:
    if phone_start<=shot['start']<phone_end:shot['actors']['nemi_city']=shot['actors'].pop('nemi')
for cue in script+captions:
    if phone_start<=cue['start']<phone_end:cue['actor']='nemi_city'
for cue in vfx:
    if phone_start<=cue['at']<phone_end:cue['actor']='nemi_city'
props[0]['attach']['actor']='nemi_city'
scene_timing=copy.deepcopy(timeline)
for word in scene_timing['words']:
    if phone_start<=word['start']<phone_end:word['actor']='nemi_city'
(EP/'timing_reference_r5_scene.json').write_text(json.dumps(scene_timing,indent=2)+'\n')
spec['audio_metadata']='res://'+str((EP/'timing_reference_r5_scene.json').relative_to(ROOT))

spec['mix']=calibrate_mix(spec,ROOT)
(EP/'scene_r5.json').write_text(json.dumps(spec,indent=2)+'\n')
(EP/'camera_plan_r5.json').write_text(json.dumps(camera_plan,indent=2)+'\n')
(EP/'sound_plan_r5.json').write_text(json.dumps(dict(cues=sound_plan,intentional_silence=[
    'Unsaid disappointment, line 4','Wanted to feel missed too, line 5','Neeko cared/adoption reflection, line 8','Final care-for-myself hold']),indent=2)+'\n')
body=['# I Get Attached Way Too Much — script and measured beats','',f'Runtime: {duration:.3f}s, hard cap 180s. Canonical Sohee.','']
for i,b in enumerate(beats):
    body.extend([f"## {i+1}. {b['start']:.3f}–{b['end']:.3f}s — {b['thought']}",'',story['lines'][i],'',f"Focus: {b['focus']}. {b['visual']} {b['intent']}",''])
(EP/'SCRIPT_AND_BEATS_R5.md').write_text('\n'.join(body))
validate(EP/'scene_r5.json')
print(f'Validated EP15 R5: {duration:.3f}s, {len(words)} measured words, {len(shots)} shots, {len(performances)} acting cues, {len(sfx)} sound accents.')
