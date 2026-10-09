#!/usr/bin/env python3
"""Author EP03 from the exact prepared Aiden recording and measured word clock.

No voice synthesis, frame export, private player, or changes to existing rigs.
Run from any directory with the project's existing Python runtime.
"""
from pathlib import Path
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[4]
FOLDER = ROOT / 'adb/episodes/ep03_my_school_found_my_youtube_channel'
sys.path.insert(0, str(ROOT / 'tools/storytime'))
from audio_mix import calibrate_mix
from sfx_assets import validate_asset
from sfx_levels import pcm, choose_gain
from validate_scene import validate

AUDIO = ROOT / 'renders/adb_school_youtube/audio_r1'
SCALE = 1.35
# Standing solver fixes the cuff at178; unchanged shoe tread continues14units.
ROOT_Y = round(894 - 192 * SCALE, 4)
STUDIO = 'adb_creator_studio_ep03'
LAB = 'adb_computer_lab'

def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + '\n')

def token(value):
    return re.sub(r'[^\w]', '', value.lower())

def build():
    timeline = json.loads((AUDIO / 'timeline.json').read_text())
    narration = AUDIO / 'narration.wav'
    assert timeline['audio_sha256'] == hashlib.sha256(narration.read_bytes()).hexdigest()
    duration = timeline['duration']
    assert 120 <= duration <= 180, f'Runtime outside the approved 2–3 minute brief: {duration}'
    paragraphs = [p.strip() for p in (FOLDER / 'narration.txt').read_text().split('\n\n') if p.strip()]
    clips = timeline['clips']
    words = timeline['words']
    assert len(clips) == len(paragraphs) == 18
    # Prepared clips preserve the 18 paragraph order; no guessed sentence timing.
    paragraph_words = []
    for clip in clips:
        paragraph_words.append([(i, w) for i, w in enumerate(words)
                                if clip['at'] <= w['start'] < w['end'] <= clip['end_at'] + .000001])
    assert sum(len(p) for p in paragraph_words) == len(words)
    timing_reference = json.loads((FOLDER / 'timing_reference_r1.json').read_text())
    boundaries = [p['beat_start'] for p in timing_reference['paragraphs']] + [duration]
    assert timing_reference['audio_sha256'] == timeline['audio_sha256']
    def word(p, wanted, occurrence=0, edge='start'):
        found = [w for _, w in paragraph_words[p] if token(w['word']) == token(wanted)]
        if len(found) <= occurrence:
            raise ValueError(f'Measured paragraph {p}: missing anchor {wanted!r}/{occurrence}; review actual transcript')
        return found[occurrence][edge]

    events = []
    anchor_references = {}
    anchors = [
        ('class_hook', 0, 'class', 0), ('hook_regret', 0, 'regret', 0),
        ('old_channel', 1, 'older', 0), ('real_face', 1, 'face', 0),
        ('dubsmash', 2, 'Dubsmash', 0), ('lipsync', 2, 'lip-sync', 0), ('performance_life', 2, 'life', 0),
        ('full_commitment', 3, 'commitment', 0), ('remember_later', 3, 'remember', 0),
        ('first_thousand', 4, 'thousand', 0), ('voluntary_audience', 4, 'voluntarily', 0),
        ('one_friend', 5, 'friend', 0), ('only_one', 5, 'One', 1), ('reasonable', 5, 'reasonable', 0),
        ('computer_period', 6, 'computer', 0), ('internet_access', 6, 'Internet', 0), ('equipped_friend', 6, 'equipped', 0),
        ('open_channel', 7, 'opened', 0), ('play_video', 7, 'played', 0),
        ('whole_class', 8, 'whole', 0), ('every_expression', 8, 'expression', 0),
        ('class_laughs', 9, 'laughing', 0), ('felt_stupid', 9, 'stupid', 0), ('who_i_am', 9, 'who', 0),
        ('public_upload', 10, 'publicly', 0), ('imaginary_internet', 10, 'imaginary', 0), ('classmates_here', 10, 'classmates', 0),
        ('thinking_now', 11, 'now', 0), ('not_mean', 11, 'mean', 0), ('videos_funny', 11, 'funny', 0),
        ('impressed', 12, 'impressed', 0), ('missing_praise', 12, 'embarrassed', 0),
        ('kind_of_cute', 13, 'cute', 0), ('accidental_audience', 13, 'audience', 0),
        ('stricter', 14, 'stricter', 0), ('work_piled', 14, 'work', 0), ('channel_dropped', 14, 'dropped', 0),
        ('youtube_again', 15, 'again', 0), ('drawn_face', 16, 'drawing', 0), ('development', 16, 'development', 0),
        ('find_this_one', 17, 'find', 0), ('committed_bit', 17, 'bit', 0),
    ]
    for name, p, exact, occurrence in anchors:
        selected = [(i,w) for i,w in paragraph_words[p] if token(w['word']) == token(exact)][occurrence]
        anchor_references[name] = dict(word=selected[1]['word'], word_index=selected[0], paragraph=p+1, start=selected[1]['start'], end=selected[1]['end'])
        events.append(dict(id=name, at=word(p, exact, occurrence), intent=f'Paragraph {p+1}, measured word “{exact}”: authored thought accent.'))
    event_map = {e['id']: e['at'] for e in events}
    # A single external commentary accent in the authored gap after the play line.
    bruh_at = round(paragraph_words[7][-1][1]['end'] + .04, 6)
    events.append(dict(id='play_aftermath', at=bruh_at, intent='The play click has happened; a short dry commentary accent fills the authored gap.'))
    event_map['play_aftermath'] = bruh_at
    def E(name, offset=0): return round(event_map[name] + offset, 6)

    shots = []
    camera_plan = []
    def shot(name, p, start, end, background, framing, center, zoom, x=750, reason='', anchor=None, path=None):
        item = dict(id=name, start=round(start,6), end=round(end,6), background=background,
                    actors={'adb': dict(position=[x, ROOT_Y], scale=SCALE)},
                    camera=dict(center=center, zoom=zoom))
        if path: item['camera']['path'] = path
        shots.append(item)
        camera_plan.append(dict(shot=name, start=item['start'], end=item['end'], paragraph=p+1,
                                exact_spoken_cue=anchor_references[anchor]['word'] if anchor in anchor_references else paragraphs[p].split('.')[0],
                                measured_word=anchor_references.get(anchor), sentence_context=paragraphs[p], event=anchor if anchor in event_map else None,
                                focus=framing, center=center, zoom=zoom, reason=reason,
                                finish='Hold the settled image until the next measured thought/cut.', path=path or []))
    def B(p): return boundaries[p]
    def N(p): return boundaries[p+1]
    # First image already fulfills the title: class, old video, exposed narrator.
    shot('hook_lab',0,B(0),E('hook_regret'),LAB,'ADB, monitor and watching class',[1090,570],1.0,reason='Immediate evidence of the central embarrassment.',anchor='class_hook')
    shot('hook_portrait',0,E('hook_regret'),N(0),LAB,'Dry face and one delayed blink',[750,510],2.0,reason='Regret lands as a personal punchline.',anchor='hook_regret')
    shot('older_channel',1,B(1),E('real_face'),STUDIO,'ADB with the old symbolic face-video phone',[990,575],1.0,reason='Separate old channel from this channel.',anchor='old_channel')
    shot('actual_face',1,E('real_face'),N(1),STUDIO,'Phone evidence and ADB reaction',[1060,550],1.27,reason='Face-revealing videos are the source of vulnerability.',anchor='real_face')
    shot('dubsmash_setup',2,B(2),E('lipsync'),STUDIO,'ADB and held phone, approximate date',[1030,565],1.04,reason='Explain the remembered format without actual stolen video/audio.',anchor='dubsmash')
    shot('lipsync_mechanism',2,E('lipsync'),N(2),STUDIO,'Symbolic phone performance and two compact live marks',[1060,555],1.18,reason='One arrow/underline clarifies lip-syncing; finished art stays still.',anchor='lipsync')
    shot('commitment',3,B(3),E('remember_later'),STUDIO,'Full ADB body in a knowingly self-impressed stance',[1010,590],1.04,reason='Full commitment is shown in stance; hands and shoes visible.',anchor='full_commitment')
    shot('remembering',3,E('remember_later'),N(3),STUDIO,'Private realization portrait',[750,510],1.95,reason='Later regret is a small reaction, followed by a still hold.',anchor='remember_later')
    shot('thousand',4,B(4),E('voluntary_audience'),STUDIO,'The roughly 1,000 subscriber evidence card and proud ADB',[1070,575],1.05,reason='Concrete evidence gives the achievement its scale.',anchor='first_thousand')
    shot('voluntary',4,E('voluntary_audience'),N(4),STUDIO,'ADB admitting that people chose this',[750,510],1.9,reason='A restrained open shrug lets the dry line land.',anchor='voluntary_audience')
    shot('confide',5,B(5),E('only_one'),LAB,'ADB and one anonymous friend, all feet visible',[1080,600],.97,reason='Establish the private disclosure at school.',anchor='one_friend')
    shot('one',5,E('only_one'),N(5),LAB,'ADB and friend with one small emphasis',[1060,555],1.18,reason='One audience member feels manageable.',anchor='only_one')
    shot('lab_establish',6,B(6),E('internet_access'),LAB,'Wide rows of desks and open ADB standing area',[1050,570],.98,reason='Recognizable computer period; scale remains consistent.',anchor='computer_period')
    shot('equipped',6,E('internet_access'),N(6),LAB,'The friend and hero monitor; ADB sees the problem',[1100,560],1.12,reason='Computers and access make the earlier choice consequential.',anchor='internet_access')
    shot('opening',7,B(7),E('play_video'),LAB,'Browser page opens in the actual monitor',[1130,590],1.23,reason='The click is shown against the real desk, with ADB visible.',anchor='open_channel')
    shot('playing',7,E('play_video'),N(7),LAB,'ADB recoil beside the revealed old video',[1090,590],1.22,reason='Eyes register the play click before the body withdraws.',anchor='play_video')
    shot('class_reveal',8,B(8),E('every_expression'),LAB,'Wide class watching the hero monitor and ADB',[1100,570],.98,reason='Audience expands visibly; no fabricated mockery or dialogue.',anchor='whole_class')
    shot('expressions',8,E('every_expression'),N(8),LAB,'Old phone video and present embarrassed face',[1080,590],1.28,reason='Hold on the face video as the remembered expressions land.',anchor='every_expression')
    shot('embarrassment',9,B(9),N(9),LAB,'Vulnerable face and shoulder portrait',[750,510],2.12,reason='Quiet downcast hold; no comic stack on the emotional consequence.',anchor='felt_stupid')
    shot('imaginary',10,B(10),E('classmates_here'),STUDIO,'Private/public counterpoint beside a full-body explanation',[1040,570],1.05,reason='An authored illustration distinguishes abstract internet from known classmates.',anchor='public_upload')
    shot('right_here',10,E('classmates_here'),N(10),LAB,'ADB, actual desk and nearby peers',[1100,570],1.0,reason='Return to concrete people in the room.',anchor='classmates_here')
    shot('hindsight',11,B(11),E('videos_funny'),STUDIO,'Thoughtful face, quiet gaze returning to viewer',[750,515],2.0,reason='Tentative adult interpretation has room to be sincere.',anchor='thinking_now')
    shot('funny',11,E('videos_funny'),N(11),STUDIO,'Held old phone illustration; ADB softens',[1020,560],1.1,reason='The same videos become a deliberate joke instead of evidence of failure.',anchor='videos_funny')
    shot('praise',12,B(12),E('missing_praise'),LAB,'Subscriber evidence and friendly anonymous peers',[1080,575],1.02,reason='Their apparent admiration becomes visible without invented quotes.',anchor='impressed')
    shot('missed_part',12,E('missing_praise'),N(12),LAB,'Small embarrassed smile portrait',[750,510],1.98,reason='He recognizes what he could not notice then.',anchor='missing_praise')
    shot('cute_revision',13,B(13),E('accidental_audience'),STUDIO,'The memory label is revised live, then rests',[1040,555],1.05,reason='Compact authored ink changes the emotional reading.',anchor='kind_of_cute')
    shot('accidental_class',13,E('accidental_audience'),N(13),LAB,'Whole grounded class picture revisited warmly',[1080,590],.99,reason='The opening room now feels like an accidental audience.',anchor='accidental_audience')
    shot('workload',14,B(14),E('channel_dropped'),STUDIO,'Channel archive and purposeful work-paper sequence',[1070,575],1.04,reason='Broad remembered reasons are symbolic; no invented policy violation.',anchor='work_piled')
    shot('close_archive',14,E('channel_dropped'),N(14),STUDIO,'Archive closes; lowered hand releases the thought',[1050,560],1.17,reason='A final page/close cue gives the old channel an ending.',anchor='channel_dropped')
    shot('return',15,B(15),N(15),STUDIO,'Current creator desk and ADB full-body recovery',[1000,570],1.04,reason='Return to present-day YouTubing is the story reversal.',anchor='youtube_again',path=[dict(at=B(15),center=[1040,590],zoom=1.0),dict(at=E('youtube_again')-.15,center=[1040,590],zoom=1.0),dict(at=min(E('youtube_again')+.5,N(15)),center=[1000,570],zoom=1.04)])
    shot('then_now',16,B(16),E('development'),STUDIO,'Old face-video/current illustrated-face comparison',[1030,565],1.13,reason='The picture supplies the character-development joke.',anchor='drawn_face')
    shot('development',16,E('development'),N(16),STUDIO,'Still direct-to-viewer deadpan',[750,510],2.0,reason='Allow the dry callback to land without another effect.',anchor='development')
    shot('callback',17,B(17),E('committed_bit'),STUDIO,'ADB and old/current channel card held together',[1030,555],1.06,reason='Return of the original exposure now reflects commitment.',anchor='find_this_one')
    shot('last_hold',17,E('committed_bit'),N(17),STUDIO,'Meaningful final face hold, eyes to viewer',[750,510],2.0,reason='End on the narrator owning the same bit; no appended moral or outro.',anchor='committed_bit')

    performances = []
    acting_plan = []
    def cue(at, recipe, event=None, offset=0, intent='', **kw):
        c=dict(at=round(at,6),recipe=recipe, duration=kw.pop('duration',.42),**kw)
        if event: c.update(event=event,event_offset=offset)
        performances.append(c)
        acting_plan.append(dict(at=c['at'],recipe=recipe,intent=intent,event=event,detail=kw))
    cue(0,'embarrassed',duration=.42,gaze=[.48,.1],face={'blush_intensity':.35},intent='Exposed by the opening image, still composed enough to narrate.')
    cue(E('hook_regret'),'deadpan','hook_regret',motion='snap',intent='Freeze on the upload-regret joke.')
    cue(B(1),'explaining',gaze=[0,0],hands={'right':'open_palm','left':'relaxed'},intent='Return to the viewer to distinguish the channels.')
    cue(E('real_face'),'shy_confession','real_face',face={'blush_intensity':.42},intent='Real face is the private vulnerability.')
    cue(B(2),'prop_present',gaze=[.55,-.08],intent='Indicate the finished phone illustration.')
    cue(E('lipsync'),'explaining','lipsync',hands={'right':'pointing','left':'relaxed'},intent='Economical explanation of the old format.')
    cue(E('performance_life'),'self_impressed','performance_life',duration=.36,intent='Brief knowingly self-serious memory.')
    cue(B(3),'self_impressed',gaze=[0,0],intent='Hold the committed performance silhouette.')
    cue(E('remember_later'),'quiet_recoil','remember_later',duration=.35,face={'blush_intensity':.34},intent='Small recoil toward the thought of remembering it.')
    cue(B(4),'pleased',gaze=[.5,-.04],intent='A thousand subscribers is a small private triumph.')
    cue(E('first_thousand'),'clue_point','first_thousand',intent='Point to evidence once, settle and hold.')
    cue(E('voluntary_audience'),'open_shrug','voluntary_audience',intent='Asymmetric admission that they chose these videos.')
    cue(B(5),'lean_in',gaze=[.7,0],hands={'right':'open_palm','left':'relaxed'},intent='Confide to one friend.')
    cue(E('only_one'),'deadpan','only_one',motion='snap',intent='One. Lock the emphasis.')
    cue(E('reasonable'),'recover','reasonable',intent='Reasonable choice resumes composed confidence.')
    cue(B(6),'listening',gaze=[.55,-.1],intent='Register the computer room before any reaction.')
    cue(E('internet_access'),'skeptical','internet_access',gaze=[.7,-.05],intent='Computers and internet point toward trouble.')
    cue(E('equipped_friend'),'nervous_wait','equipped_friend',face={'sweat_intensity':.35,'blush_intensity':.22},intent='Hands gather; knowledge is now dangerous.')
    cue(B(7),'listening',gaze=[.65,-.1],hands={'right':'relaxed','left':'relaxed'},intent='Eyes already on the screen; no false mouse grip.')
    cue(E('play_video'),'quiet_recoil','play_video',duration=.4,motion='stepped',step_fps=12,face={'blush_intensity':.45},intent='One bounded shock response.')
    cue(B(8),'nervous_answer',gaze=[.65,-.02],face={'sweat_intensity':.3,'blush_intensity':.5},intent='Sustained exposed posture while the room sees the videos.')
    cue(E('every_expression'),'embarrassed','every_expression',duration=.45,gaze=[-.2,.28],face={'blush_intensity':.56},intent='Withdraw as each expression is remembered.')
    cue(B(9),'hurt_composure',gaze=[.08,.55],face={'blush_intensity':.6,'sweat_intensity':0},intent='Quiet vulnerability; shoulders and gaze descend.')
    cue(E('who_i_am'),'deadpan','who_i_am',motion='snap',face={'blush_intensity':.52,'eye_openness_left':.78,'eye_openness_right':.8},intent='A frozen attempt to accept what the classmates now know.')
    cue(B(10),'explaining',gaze=[.4,-.02],hands={'right':'open_palm','left':'relaxed'},face={'blush_intensity':.2},intent='Analyze public posting versus a known audience.')
    cue(E('imaginary_internet'),'soft_shrug','imaginary_internet',intent='The internet felt imaginary; acknowledge the mismatch.')
    cue(E('classmates_here'),'hurt_composure','classmates_here',face={'blush_intensity':.35},intent='Return to the concrete classmates and small posture.')
    cue(B(11),'uncertain',gaze=[-.2,-.15],face={'blush_intensity':.12},intent='Tentative hindsight; no invented certainty about their intent.')
    cue(E('not_mean'),'weight_shift','not_mean',gaze=[0,0],face={'blush_intensity':.1},intent='Eyes return outward before the body loosens.')
    cue(E('videos_funny'),'pleased','videos_funny',gaze=[.38,-.05],intent='Recognize the purpose of those funny videos.')
    cue(B(12),'recover',gaze=[.55,-.03],intent='Let the remembered praise register.')
    cue(E('impressed'),'pleased','impressed',face={'blush_intensity':.18},intent='A small smile for the achievement.')
    cue(E('missing_praise'),'shy_confession','missing_praise',face={'blush_intensity':.35},gaze=[-.25,.25],intent='Admit that embarrassment hid the good part.')
    cue(B(13),'pleased',gaze=[.4,-.1],face={'blush_intensity':.15},intent='Warmth leads the changed reading of the memory.')
    cue(E('accidental_audience'),'open_shrug','accidental_audience',intent='Small open palms own the accidental classroom audience.')
    cue(B(14),'explaining',hands={'right':'open_palm','left':'relaxed'},gaze=[.48,-.02],intent='Broad reasons for leaving; no platform-policy specifics.')
    cue(E('work_piled'),'weight_shift','work_piled',gaze=[.45,.05],intent='Work overtakes the old channel.')
    cue(E('channel_dropped'),'listening','channel_dropped',gaze=[.35,.2],hands={'right':'relaxed','left':'relaxed'},intent='Lower both hands as the page closes; no empty grip.')
    cue(B(15),'recover',gaze=[0,0],intent='Return to current creator composure.')
    cue(E('youtube_again'),'lean_in','youtube_again',hands={'right':'open_palm','left':'relaxed'},intent='A small forward commitment to making videos again.')
    cue(B(16),'prop_present',gaze=[.5,-.02],hands={'right':'pointing','left':'relaxed'},intent='Present the old/new face comparison.')
    cue(E('development'),'deadpan','development',motion='snap',intent='The drawing-face joke gets a clean still hold.')
    cue(B(17),'skeptical',gaze=[.45,-.04],hands={'right':'relaxed','left':'relaxed'},intent='Consider the classmates finding this channel too.')
    cue(E('committed_bit'),'deadpan','committed_bit',motion='snap',face={'blush_intensity':.12},intent='Final ownership of the bit with direct eye contact.')
    performances.sort(key=lambda c:c['at'])
    # Explicit one-off blinks at settled thought boundaries, never timers.
    for p in [0,1,3,4,5,6,8,9,11,12,13,14,16,17]:
        at=round(clips[p]['end_at']+.04,6)
        if at+.14 < N(p):
            active=max((c for c in performances if c['at']<=at),key=lambda c:c['at'])
            active.setdefault('blinks',[]).append(at)
    for i,c in enumerate(performances):
        nxt=performances[i+1]['at'] if i+1<len(performances) else duration
        if c.get('motion')=='snap': c['duration']=0
        else: c['duration']=round(min(c['duration'],max(.08,nxt-c['at']-.01)),6)

    drawings=[]; props=[]; vfx=[]
    def art(kind, at, end, position, scale=1, shots_filter=None, live=None, event=None, offset=0, group=props, **kw):
        a=dict(author='adb',kind=kind,at=round(at,6),end=round(end,6),position=position,scale=[scale,scale],mode='live' if live else 'hold',**kw)
        if shots_filter: a['shots']=shots_filter
        if live: a['duration']=live
        if event: a.update(event=event,event_offset=offset)
        group.append(a); return a
    def text(label,at,end,xy,size=42,**kw):
        return art('text',at,end,xy,size=size,text=label,group=drawings,**kw)
    lab_shots=[s['id'] for s in shots if s['background']==LAB]
    screen_shots=[x for x in lab_shots if x not in ['confide','one','lab_establish','equipped','praise','missed_part']]
    art('school_youtube_browser',0,duration,[1400,542],.60,screen_shots,layer=0)
    for sid in ['hook_lab','class_reveal','right_here','accidental_class']:
        s=next(s for s in shots if s['id']==sid)
        art('school_youtube_peers',s['start'],s['end'],[1700,694],.78,[sid],layer=2)
    # Already drawn evidence, clearly separate from any recovered recording.
    art('school_youtube_phone',B(1),N(3),[1300,560],.92,
        ['older_channel','actual_face','dubsmash_setup','lipsync_mechanism','commitment'],layer=2)
    text('old channel',E('old_channel'),N(1),[1120,278],40,event='old_channel')
    text('around 2015',B(2),E('lipsync'),[1120,279],38)
    art('arrow',E('lipsync'),N(2),[1065,580],.95,['lipsync_mechanism'],live=.6,event='lipsync',group=drawings)
    art('underline',E('performance_life'),N(2),[1290,746],1.25,['lipsync_mechanism'],live=.38,event='performance_life',group=drawings)
    art('school_youtube_subscribers',E('first_thousand'),E('voluntary_audience'),[1320,550],1.0,['thousand'],event='first_thousand')
    art('underline',E('first_thousand',.3),E('voluntary_audience'),[1280,697],1.13,['thousand'],live=.45,event='first_thousand',offset=.3,group=drawings)
    art('school_classmate',B(5),N(6),[1035,894],1.23,['confide','one','equipped'],layer=1)
    art('arrow',E('one_friend'),E('only_one'),[893,525],.76,['confide'],live=.5,event='one_friend',group=drawings)
    text('one',E('only_one'),N(5),[900,312],42,event='only_one',shots_filter=['one'])
    art('school_youtube_private_public',B(10),E('classmates_here'),[1310,563],1.0,['imaginary'])
    art('arrow',E('imaginary_internet'),E('classmates_here'),[1110,735],.85,['imaginary'],live=.5,event='imaginary_internet',group=drawings)
    art('school_youtube_phone',E('videos_funny'),N(11),[1300,560],.88,['funny'])
    art('school_youtube_subscribers',E('impressed'),E('missing_praise'),[1310,550],.86,['praise'],event='impressed')
    art('school_youtube_peers',B(12),E('missing_praise'),[1690,694],.75,['praise'],layer=2)
    text('stupid',B(13),E('accidental_audience'),[1210,410],48,shots_filter=['cute_revision'])
    art('scratch',E('kind_of_cute',-.45),E('accidental_audience'),[1298,434],1.28,['cute_revision'],live=.32,event='kind_of_cute',offset=-.45,group=drawings)
    text('kind of cute',E('kind_of_cute'),E('accidental_audience'),[1142,509],44,shots_filter=['cute_revision'],live=.9,event='kind_of_cute')
    art('school_youtube_phone',B(13),E('kind_of_cute',-.45),[1300,600],.54,['cute_revision'])
    art('school_youtube_archive',B(14),N(14),[1330,560],.9,['workload','close_archive'])
    # Sequential symbolic reasons, never a specific invented platform violation.
    text('less time',E('work_piled'),E('channel_dropped'),[1180,325],40,event='work_piled',shots_filter=['workload'])
    art('homework_notes',E('work_piled'),E('channel_dropped'),[1570,663],.56,['workload'],event='work_piled',layer=2)
    art('school_youtube_then_now',B(15),E('development'),[1300,550],.88,['return','then_now'])
    art('arrow',E('drawn_face'),E('development'),[1310,752],.9,['then_now'],live=.5,event='drawn_face',group=drawings)
    art('school_youtube_then_now',B(17),E('committed_bit'),[1320,535],.82,['callback'])
    for event,kind,length,strength in [('play_video','realization',.65,.65),('every_expression','sweat',.9,.6),('impressed','relief',.75,.55)]:
        vfx.append(dict(author='adb',kind=kind,at=E(event),end=E(event,length),actor='adb',offset=[65,-20],strength=strength,event=event))

    script=[]; captions=[]; mouths=[]
    vowel_map={'whole':'talk_round','school':'talk_round','youtube':'talk_round','face':'talk_wide','videos':'talk_wide',
               'thousand':'talk_open','subscribers':'talk_wide','drawing':'talk_open','development':'talk_wide','bit':'talk_wide',
               'class':'talk_open','computer':'talk_round','embarrassed':'talk_wide','cute':'talk_round','mean':'talk_wide'}
    for p,(clip,paragraph) in enumerate(zip(clips,paragraphs)):
        script.append(dict(actor='adb',start=clip['at'],end=clip['end_at'],text=paragraph))
        group=[]
        for j,(index,w) in enumerate(paragraph_words[p]):
            group.append((index,w))
            if len(group)==5 or re.search(r'[.!?]$',w['word']) or j==len(paragraph_words[p])-1:
                captions.append(dict(actor='adb',words=[group[0][0],group[-1][0]],start=group[0][1]['start'],end=group[-1][1]['end'],text=' '.join(w['word'] for _,w in group).replace('seriously, And accidentally','seriously, and accidentally')))
                group=[]
            start=w['start']+.008;end=w['end']-.012
            if end-start<.038: continue
            t=token(w['word']); shape=vowel_map.get(t)
            if not shape:
                if re.search(r'oo|ou|ow|or|you|who|to|do',t): shape='talk_round'
                elif re.search(r'ee|ea|i|ay',t): shape='talk_wide'
                else: shape='talk_open'
            # Measured word bounds + conservative authored consonant closures.
            # Vowels are broad expressive choices, not claimed phoneme alignment.
            if t.startswith(('m','b','p')) and end-start>.10:
                mouths.append(dict(start=round(start,6),end=round(start+.025,6),shape='neutral'));start+=.025
            if t.endswith(('m','b','p')) and end-start>.10:
                vowel_end=end-.028
                mouths.append(dict(start=round(start,6),end=round(vowel_end,6),shape=shape))
                mouths.append(dict(start=round(vowel_end,6),end=round(end,6),shape='neutral'))
            elif end-start>.65:
                middle=start+(end-start)*.6
                mouths.append(dict(start=round(start,6),end=round(middle,6),shape=shape))
                mouths.append(dict(start=round(middle,6),end=round(end,6),shape='talk_open' if shape!='talk_open' else 'talk_wide'))
            else: mouths.append(dict(start=round(start,6),end=round(end,6),shape=shape))

    catalog=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']
    assets={a['id']:a for a in catalog}
    voice=pcm(narration)
    sounds=[]; sound_rows=[]
    sound_choices=[
        ('hook_regret','viral_click',.365688,'accent','Upload-regret button accent; no fake old video audio.'),
        ('old_channel','paper_page_flip_02',.43,'surface','Turn toward the remembered old channel.'),
        ('real_face','cartoon_pop_dry_01',.305,'accent','The face-video evidence appears.'),
        ('lipsync','drawing_scratch_scribble_05',.325,'surface','One compact arrow clarifies the format.'),
        ('full_commitment','impact_wood_tap_01',.266,'accent','A restrained emphasis on complete commitment.'),
        ('first_thousand','ui_confirm_chime_02',.539,'accent','The subscriber achievement registers.'),
        ('one_friend','drawing_scratch_scribble_04',.325,'surface','The private disclosure arrow is inked.'),
        ('only_one','impact_wood_tap_01',.266,'accent','One. A dry count emphasis.'),
        ('computer_period','paper_page_turn_crisp_01',.452,'surface','Enter the recognizable remembered lab.'),
        ('internet_access','computer_laptop_typing_fast_01',1.25,'surface','Existing recording points to available computer access.'),
        ('open_channel','computer_mouse_fast_double_01',.465,'accent','The friend opens the channel page.'),
        ('play_video','viral_click',.365688,'hero','The visible play click causes the problem.'),
        ('play_aftermath','viral_bruh',.816979,'accent','One short external dry commentary after the play line.'),
        ('whole_class','cartoon_pop_dry_01',.305,'accent','Wider audience appears; no invented laugh recording.'),
        ('public_upload','paper_page_flip_03',.231,'surface','Switch into the abstract/private audience comparison.'),
        ('impressed','ui_confirm_chime_01',.29,'accent','Apparent admiration is a small positive recognition.'),
        ('kind_of_cute','drawing_pencil_sketch_01',1.868,'surface','Live revision to the warm interpretation.'),
        ('work_piled','paper_slide_desk_01',1.094,'surface','Work papers overtake available time.'),
        ('channel_dropped','paper_book_close_01',.231,'accent','The old channel closes as a chapter.'),
        ('youtube_again','computer_mouse_fast_double_01',.465,'accent','A deliberate return to making videos.'),
        ('drawn_face','drawing_scratch_scribble_04',.325,'surface','Compact arrow points to the illustrated face.'),
    ]
    for event,asset_id,length,prominence,reason in sound_choices:
        asset=assets[asset_id]
        path=validate_asset(asset,ROOT)
        at=E(event)
        gain,levels=choose_gain(path,voice,at,length,prominence)
        sounds.append(dict(file='res://'+asset['relative_path'],at=at,duration=length,gain_db=gain,event=event))
        sound_rows.append(dict(event=event,at=at,catalog_id=asset_id,file='res://'+asset['relative_path'],duration=length,gain_db=gain,
                               intended_prominence=prominence,reason=reason,levels=levels,source_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                               source=asset.get('source'),origin=asset.get('origin','existing_library_recording'),license=asset.get('license'),
                               source_provenance_validated=True,listening_review='pending actual mix playback'))
    silence=[dict(paragraph=p+1,start=B(p),end=N(p),reason=reason) for p,reason in
             [(9,'The personal embarrassment needs quiet shoulders, gaze and held image.'),
              (11,'Tentative adult hindsight lands without a joke sting.'),
              (17,'The final callback holds with no sound after the last word.')]]

    thoughts=[
        ('The class saw the old videos.','Monitor, audience and dry regret','Held class evidence then portrait','Make the central tension clear from the first frame.'),
        ('This was the old face-revealing channel.','Old phone and vulnerable narrator','Held symbolic reconstruction','Separate the remembered channel from present ADB.'),
        ('Dubsmash felt like a performance.','Phone and lip-sync explanation','Held phone, live compact arrow/underline','Show the mechanism without borrowed music or footage.'),
        ('I committed without thinking about later.','Self-impressed stance becoming small recoil','Full body then personal reaction','Let hindsight undermine teenage confidence.'),
        ('A thousand subscribers felt huge.','Subscriber evidence, small proud face','Held number card, one live underline','Give the old achievement its truthful approximate scale.'),
        ('One friend was a reasonable audience.','ADB and one anonymous friend','Grounded two-person illustration and one arrow','Make the choice that causes the reveal.'),
        ('The school computers changed the stakes.','Lab desks, monitor and informed friend','Recognizable location and measured eye turn','Connect information to access.'),
        ('He opened the channel and played the videos.','Play control and recoil','Object insert within a full scene','The action causes the exposure.'),
        ('Everyone saw every expression.','Class audience, monitor and ADB','Wide reveal then evidence reaction','Show the scale of the moment without inventing bullying.'),
        ('I felt stupid and exposed.','Vulnerable face, shoulders and gaze','Quiet sustained portrait','Give the remembered emotion room.'),
        ('The imaginary internet became real classmates.','Private/public contrast then actual room','Held visual counterpoint and return','Explain why familiar viewers felt different.'),
        ('Maybe they were enjoying what I meant to be funny.','Thoughtful face then same phone','Quiet gaze/body release','Keep the reinterpretation tentative and warm.'),
        ('They seemed impressed by the subscribers.','The same number evidence and friendly peers','Held achievement and small blush','Notice the good part hidden by embarrassment.'),
        ('Now the memory seems cute.','Compact revision then warm class picture','Live scratch/replacement, stable finished ink','Change the meaning of the opening image.'),
        ('Work and stricter YouTube ended that chapter.','Archive page and work papers','Sequential evidence, deliberate close','Use broad symbolic reasons without invented policies.'),
        ('Here I am making videos again.','Present-day creator and desk','Full-body recovery and bounded camera return','Fulfill the comeback reversal.'),
        ('This time my face is a drawing.','Old/current face comparison then deadpan','Held comparison and clean joke portrait','Let the picture supply character development.'),
        ('If they find me again, I own the bit.','Held callback, then direct eye contact','Deliberate final dry hold','End at the story payoff, with no appended moral.'),
    ]
    direction=dict(promise='My whole class finds my old face-revealing YouTube videos.',
                   want='Share a small achievement with one friend without becoming the class entertainment.',
                   choice='Tell the friend about the old channel.',consequence='The friend plays the videos in computer period and I feel exposed.',
                   payoff='Adult hindsight finds the memory sweet; I am back on YouTube through an illustrated face.',
                   beats=[dict(start=B(p),end=N(p),thought=t[0],focus=t[1],visual=t[2],intent=t[3]) for p,t in enumerate(thoughts)])
    spec=dict(version=2,title='My School Found My YouTube Channel',duration=duration,fps=30,caption_size=52,
              audio='res://renders/adb_school_youtube/audio_r1/narration.wav',audio_metadata='res://renders/adb_school_youtube/audio_r1/timeline.json',
              direction=direction,actors=[dict(id='adb',author='adb',performances=performances,mouths=mouths)],shots=shots,
              drawings=drawings,props=props,vfx=vfx,sfx=sounds,events=events,script=script,captions=captions)
    spec['mix']=calibrate_mix(spec,ROOT)
    scene=FOLDER/'scene_r2_1080p.json'
    write_json(scene,spec)
    validate(scene) # Full file-based preflight, all assets/provenance and timing.
    write_json(FOLDER/'scene.json',spec)
    write_json(FOLDER/'camera_plan.json',dict(version=1,clock='final prepared Aiden word clock',actor_scale=SCALE,actor_root_y=ROOT_Y,floor_y=894,shots=camera_plan))
    write_json(FOLDER/'sound_plan.json',dict(version=1,clock='final prepared Aiden word clock',mix=spec['mix'],cues=sound_rows,deliberate_silence=silence))
    write_json(FOLDER/'review/sfx_cues.json',dict(version=1,cues=sound_rows,deliberate_silence=silence,
                                               mixed_audio_review='pending root-coordinated audition',encoded_audio_review='pending video export'))
    write_json(FOLDER/'review/acting_plan_r2.json',dict(version=1,cues=acting_plan,
        mouth_method='Measured word-bounded broad vowel choices with conservative M/B/P closures; not phoneme-perfect. Portraits require final listening/playback review.',
        contact='No pickup/release or forced grip. The narrator indicates symbolic held evidence and monitor art; the friend action is an authored reconstruction.',
        geometry=dict(actor_scale=SCALE,actor_root_y=ROOT_Y,floor_y=894,feet='Planted existing actor-local cuff y178; unchanged shoe tread fill y192 lands at894',desk_top_y=694)))
    qa=dict(version=1,spec_sha256=hashlib.sha256(scene.read_bytes()).hexdigest(),audio_sha256=timeline['audio_sha256'],duration=duration,
            narration_paragraphs=18,shot_count=len(shots),caption_count=len(captions),mouth_interval_count=len(mouths),sfx_count=len(sounds),
            source_checks=dict(full_file_based_validator='passed',runtime_cap='passed <=180 seconds',caption_word_clock='hash-checked final timeline',
                               sfx_provenance='existing files validated; no synthesized/procedural substitutions'),
            pending=['fresh focused ten-second render','30–60-second integrated render','actual stills and full-speed playback','all portraits and both-arm anatomy review','final full-cut audio audition','encoded AAC peak review','user satisfaction with the full 1080p cut'],
            proof_suggestions=dict(focused_start=round(B(7),3),focused_duration=10,integrated_start=round(B(4),3),integrated_duration=round(min(60,N(10)-B(4)),3)))
    write_json(FOLDER/'review/source_qa_r2.json',qa)
    rows=['# ADB EP03 — My School Found My YouTube Channel','',f'Complete R2 review direction: {duration:.3f}s; approved runtime 120–180s, hard ceiling 180s.',
          '','Narration uses the unchanged canonical Aiden identity. All timing below is measured from the final prepared recording; no paragraph duration was guessed.',
          '','| Time | Spoken thought | Audience focus and picture | Performance/camera | Sound or deliberate silence |','|---|---|---|---|---|']
    for p,t in enumerate(thoughts):
        names=[r['catalog_id'] for r in sound_rows if B(p)<=r['at']<N(p)]
        rows.append(f'| {B(p):.3f}–{N(p):.3f} | {t[0]} | {t[1]}; {t[2]} | '+', '.join(s['id'] for s in shots if B(p)<=s['start']<N(p))+' | '+(', '.join(names) if names else 'Deliberate quiet face/body hold')+' |')
    rows += ['', 'The phone/browser face is symbolic hand-inked memory art, not the user’s real face or recovered video. No exact channel name, teacher punishment, classmate quotation or platform-policy violation is invented.',
             '', 'Completed ink holds still. Temporary reaction accents end. The narrator’s size stays consistent with desks and peers; portraits reframe the whole scene. No walking, forced pickup or empty gripping hand is authored.',
             '', 'Exact-word camera intentions, measured source gains and actual provenance are in camera_plan.json and sound_plan.json. Actual full-speed playback, listening and exported-picture QA are pending until root-coordinated proofs and the full movie exist.',
             '', 'The complete 1920×1080 cut is the first user delivery. No 4K movie or proof is authorized until explicit satisfaction with this exact full cut. Earlier previews and voices remain preserved during revision.']
    (FOLDER/'SCRIPT_AND_BEATS.md').write_text('\n'.join(rows)+'\n')
    print(json.dumps(dict(scene=str(scene),duration=duration,shots=len(shots),captions=len(captions),sfx=len(sounds),proofs=qa['proof_suggestions'],mix=spec['mix']),indent=2))

if __name__=='__main__':
    build()
