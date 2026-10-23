"""Author the measured 25s edit using the shared version-2 production stage."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PREFIX = 'res://' + str(HERE.relative_to(ROOT)) + '/'
timeline = json.loads((HERE / 'voice/prepared_r2/timeline.json').read_text())
turns = json.loads((HERE / 'voice/turns_r2.json').read_text())
words = timeline['words']

def shot(key, start, end, background, camera, position=(960, 555.8), actor=True):
    result = dict(id=key, start=start, end=end, background=background,
                  actors={'adb': dict(position=list(position), scale=1.9)} if actor else {})
    if camera:
        result['camera'] = dict(center=camera[0], zoom=camera[1])
    return result

room = ([960, 250], 1.85)
portrait = ([960, 230], 2.1)
close = ([960, 230], 2.35)
wide = ([960, 540], 1.0)
cuts = [0, 76/30, 3.9, 145/30, 6.4, 7.6, 290/30, 430/30, 15.3, 16.2, 16.6, 18.0, 566/30, 22.1, 25.0]
shots = [
    shot('opening', cuts[0], cuts[1], 'studio_adb', room),
    shot('name_insert', cuts[1], cuts[2], 'paper', portrait),
    shot('name_room', cuts[2], cuts[3], 'studio_adb', room),
    shot('truth_insert', cuts[3], cuts[4], 'paper', close),
    shot('truth_room', cuts[4], cuts[5], 'studio_adb', room),
    shot('challenge_insert', cuts[5], cuts[6], 'paper', wide),
    shot('challenge_room', cuts[6], cuts[7], 'studio_adb', room),
    shot('stories', cuts[7], cuts[8], 'paper', ([960, 510], 1.05), (650,555.8)),
    shot('notebook_insert', cuts[8], cuts[9], 'paper', ([1030, 380], 1.6)),
    shot('workload_insert', cuts[9], cuts[10], 'paper', ([1210, 620], 2.1), actor=False),
    shot('proud_insert', cuts[10], cuts[11], 'paper', wide, (700,555.8)),
    shot('closing_insert', cuts[11], cuts[12], 'paper', portrait),
    shot('closing_room', cuts[12], cuts[13], 'studio_adb', room),
    shot('black_tail', cuts[13], cuts[14], 'black', None, actor=False),
]

performances = [
    dict(at=0, recipe='deadpan', gaze=[0,0]),
    dict(at=.22, recipe='explaining', duration=.34, gaze=[0,0]),
    dict(at=2.533333, recipe='uncertain', duration=.28, gaze=[.15,0], hands={'right':'hand_to_chin'}),
    dict(at=3.54, recipe='pleased', duration=.3, gaze=[0,0]),
    dict(at=4.833333, recipe='skeptical', duration=.26, gaze=[0,0], face={'brow_left_height':-2,'brow_right_height':1.4}),
    dict(at=6.32, recipe='deadpan', motion='snap', gaze=[0,0]),
    dict(at=7.6, recipe='realization', duration=.4, gaze=[0,0], hands={'left':'open_palm','right':'open_palm'}),
    dict(at=9.5, recipe='lean_in', duration=.28, gaze=[0,0], hands={'right':'pointing'}),
    dict(at=11.52, recipe='explaining', duration=.3, gaze=[0,0]),
    dict(at=12.18, recipe='pleased', duration=.3, gaze=[0,0], face={'brow_right_height':-1.2}),
    dict(at=14.333333, recipe='prop_present', duration=.3, gaze=[.6,.1], hands={'right':'open_palm'}),
    dict(at=15.3, recipe='prop_present', motion='snap', gaze=[0,0], hands={'right':'holding_cup'}),
    dict(at=16.2, recipe='recover', motion='snap', gaze=[0,0], hands={'right':'relaxed'}),
    dict(at=16.6, recipe='soft_shrug', duration=.35, gaze=[0,0]),
    dict(at=18, recipe='recover', duration=.3, gaze=[0,0]),
    dict(at=18.56, recipe='pleased', duration=.25, gaze=[0,0]),
    dict(at=19.84, recipe='listening', duration=.25, gaze=[.4,-.1], blinks=[20.0]),
    dict(at=20.46, recipe='uncertain', duration=.28, gaze=[-.35,0]),
    dict(at=21.62, recipe='deadpan', motion='snap', gaze=[0,0]),
]

# Explicit vowel choices on measured word windows, with consonant/rest closures.
# These are authored approximate articulation, not an automatic phoneme alignment.
shapes = {
    'a':['talk_open'], 'message':['talk_wide','talk_open'], 'to':['talk_round'],
    'every':['talk_wide','talk_wide'], 'storytime':['talk_round','talk_wide'],
    'animator':['talk_open','talk_wide'], 'my':['talk_wide'], 'name':['talk_wide'],
    'is':['talk_wide'], 'adb':['talk_wide','talk_wide'], "i'm":['talk_open'],
    'dangerously':['talk_wide','talk_round'], 'underwatched':['talk_open','talk_round'],
    'and':['talk_open'], 'gonna':['talk_open'], 'steal':['talk_wide'], 'your':['talk_round'],
    'watch':['talk_round'], 'time':['talk_wide'], 'by':['talk_wide'],
    'becoming':['talk_wide','talk_open'], 'the':['talk_open'], 'biggest':['talk_wide'],
    'in':['talk_wide'], 'world':['talk_round'], "i've":['talk_wide'],
    'got':['talk_round'], 'stories':['talk_round','talk_wide'], 'now':['talk_open'],
    "where's":['talk_wide'], 'audience':['talk_round','talk_wide']
}
mouths=[]
for word in words:
    text=word['word'].strip('.,?!').lower()
    start,end=word['start'],word['end']
    if end-start<.055:
        continue
    closed=.035 if end-start<.16 else .045
    # Labial beginnings visibly close before opening.
    onset=.025 if text.startswith(('m','b','p')) else .01
    if onset:
        mouths.append(dict(start=round(start,6),end=round(start+onset,6),shape='neutral'))
    vowels=shapes.get(text,['talk_open'])
    width=(end-closed-start-onset)/len(vowels)
    for i,shape in enumerate(vowels):
        mouths.append(dict(start=round(start+onset+i*width,6),end=round(start+onset+(i+1)*width,6),shape=shape))
    mouths.append(dict(start=round(end-closed,6),end=round(end,6),shape='neutral'))

props=[]
room_shots=['opening','name_room','truth_room','challenge_room','closing_room']
def prop(kind,at,end,position,scale,shots,layer=2):
    props.append(dict(author='adb',kind=kind,at=at,end=end,position=position,scale=[scale,scale],mode='hold',shots=shots,layer=layer))
prop('desk',0,22.1,[410,717],1.0,room_shots,0)
prop('laptop',0,22.1,[410,654],1.0,room_shots,0)
prop('desk',14.333333,16.6,[1210,715],1.0,['stories','workload_insert'],0)
prop('notebook',14.333333,15.3,[1210,640],1.0,['stories'])
props.append(dict(author='adb',kind='notebook',at=15.3,end=16.2,scale=[.70,.70],mode='hold',shots=['notebook_insert'],layer=0,attach=dict(actor='adb',hand='right',grip=[55,30],angle=0)))
prop('laptop',16.2,16.6,[1210,652],1.0,['workload_insert'])
prop('tabs',16.6,18,[1290,604.45],1.65,['proud_insert'])
prop('desk',16.6,18,[1350,715],1.0,['proud_insert'],0)

overlays=[]
opening=[w for w in words if w['start']<2.52]
for i,w in enumerate(opening):
    overlays.append(dict(start=w['start'],end=opening[i+1]['start'] if i+1<len(opening) else 76/30,text=' '.join(x['word'] for x in opening[:i+1]),style='red_intro',size=110,position=[120,735]))
for left,right in [(3.9,145/30),(6.4,7.6),(290/30,430/30)]:
    selected=[w for w in words if w['start']<right and w['end']>left]
    for i,w in enumerate(selected):
        end=min(right,selected[i+1]['start'] if i+1<len(selected) else w['end']+.12)
        overlays.append(dict(start=max(left,w['start']),end=end,text=w['word'].strip('.,?!').upper(),style='red_serif'))
overlays.sort(key=lambda x:x['start'])

events=[
    dict(id='first_insert',at=76/30,intent='First bright self-introduction cut.'),
    dict(id='stories_reveal',at=430/30,intent='Cut from grand ambition to real story pages.'),
    dict(id='workload_snap',at=16.2,intent='Abrupt laptop workload gag.'),
    dict(id='stack_snap',at=16.6,intent='Finished pages replace the laptop closeup.'),
]
sfx=[
    dict(file='res://common/audio/sfx/whoosh.mp3',at=76/30,duration=.32,gain_db=-12,event='first_insert'),
    dict(file='res://common/audio/sfx/paper/paper_page_turn_crisp_01.wav',at=430/30,duration=.6,gain_db=-8,event='stories_reveal'),
    dict(file='res://common/audio/sfx/click.mp3',at=16.2,duration=.3,gain_db=-9,event='workload_snap'),
    dict(file='res://common/audio/sfx/pop.mp3',at=16.6,duration=.35,gain_db=-10,event='stack_snap'),
]
direction=dict(
    promise='An unknown animator announces an absurdly confident challenge.',
    want='Find the audience for the stories ADB already wants to tell.',
    choice='Declare that he is coming for everyone’s watch time.',
    consequence='A grand ambition meets a very small audience and a real pile of drawings.',
    payoff='The confident challenger quietly asks where his audience is.',
    beats=[dict(start=0,end=2.533333,thought='Listen, fellow animators.',focus='ADB direct address',visual='Studio portrait and progressive red opener.',intent='Establish the audience and dry confidence.'),
           dict(start=2.533333,end=7.6,thought='This is ADB, and he is underwatched.',focus='ADB face and name',visual='Cream portraits alternate with studio word edits.',intent='Let the confidence meet its first honest admission.'),
           dict(start=7.6,end=14.333333,thought='I am coming for your watch time.',focus='ADB challenge',visual='Open-palmed wide, then room with giant replacement words.',intent='Escalate the ambition with the reference’s cut rhythm.'),
           dict(start=14.333333,end=18.56,thought='The stories and work are already here.',focus='Notebook and editing workload',visual='Cream story props and short insert gags.',intent='Ground the swagger in real creative work.'),
           dict(start=18.56,end=22.1,thought='Now where is the audience?',focus='ADB pause and face',visual='Quiet studio return; eye glance then dry hold.',intent='Let the request emerge beneath the bravado.'),
           dict(start=22.1,end=25,thought='Let the last line land.',focus='Black tail',visual='Empty black shot.',intent='Match the source ending and hold its punctuation.')])
spec=dict(version=2,title='A message to every storytime animator — ADB',duration=25.0,fps=30,
          audio=PREFIX+'voice/prepared_r2/narration.wav',audio_metadata=PREFIX+'voice/prepared_r2/timeline.json',
          direction=direction,events=events,actors=[dict(id='adb',author='adb',performances=performances,mouths=mouths)],
          shots=shots,props=props,drawings=[],vfx=[],sfx=sfx,script=turns,captions=[],overlays=overlays,
          music=[dict(at=0,file='res://renders/message_to_storytime_reference/audio/reference_music_bed_hybrid.wav',duration=25,gain_db=-6)])
(HERE/'scene.json').write_text(json.dumps(spec,indent=2)+'\n')
(HERE/'CAMERA_PLAN.json').write_text(json.dumps([dict(start=s['start'],end=s['end'],shot=s['id'],camera=s.get('camera'),focus=next((b['focus'] for b in direction['beats'] if b['start']<=s['start']<b['end']),'Black tail'),word_or_pause=next((w['word'] for w in words if w['start']<=s['start']<w['end']),'deliberate pause or cut'),reason='Repeat source studio announcement composition' if 'room' in s['id'] or s['id']=='opening' else 'Reveal complete notebook and visible wrapping hand' if s['id']=='notebook_insert' else 'Ground the prop on its desk in an actor-free object insert' if s['id']=='workload_insert' else 'Preserve a purposeful cream cutaway or black punctuation from the reference',finish='Fixed framing holds until the next hard cut; no automatic zoom or idle camera drift.') for s in shots],indent=2)+'\n')
(HERE/'SOUND_PLAN.json').write_text(json.dumps(dict(sfx=sfx,music=spec['music'],music_provenance='User-supplied reference video hybrid instrumental bed; review/hybrid_bed_provenance.json. Original soundtrack only in conservatively narrator-free cutaways, separated bed beneath narration. Preserve exact source dropouts and final impact; no loop.',voice='Canonical Aiden source_r1, 1.00×, no identity changes.'),indent=2)+'\n')
print(HERE/'scene.json')
