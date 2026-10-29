"""Direct EP16 R2 from the final canonical Sohee recording, using dynamic shot grammar and canonical 1.75 scale."""
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
assert 100 <= duration <= 130, f'Runtime outside target range: {duration}'

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
    'question': event('question', key(0, 'asks'), 'Off-screen speech bubble asks the career question.'),
    'soul_leaves': event('soul_leaves', key(0, 'soul'), 'Nemi freezes in internal panic.'),
    'real_jobs': event('real_jobs', key(1, 'real jobs'), 'Briefcase and corporate career symbols appear.'),
    'cartoons': event('cartoons', key(1, 'cartoons'), 'Nemi admits drawing cartoons with a sheepish shrug.'),
    'polite_nod': event('polite_nod', key(2, 'polite'), 'The awkward polite nod card appears.'),
    'unemployed': event('unemployed', key(2, 'unemployed'), 'Deadpan freeze on the brutal translation.'),
    'zero_dollars': event('zero_dollars', key(3, 'earnings'), 'Big $0.00 earnings card appears.'),
    'kofi_jar': event('kofi_jar', key(4, 'coffee'), 'Hand-drawn Ko-fi tip jar appears.'),
    'hardly_donates': event('hardly_donates', key(4, 'hardly'), 'Emphasis that hardly anyone donates.'),
    'tablet_work': event('tablet_work', key(5, '40 hours'), 'Drawing tablet timeline appears.'),
    'clock_40h': event('clock_40h', key(5, 'tablet'), 'Clock spinning 40 hours appears.'),
    'scary_night': event('scary_night', key(6, 'scary'), 'Evening transition as late-night doubt takes over.'),
    'flat_stats': event('flat_stats', key(6, 'stricter'), 'YouTube flatline stats card appears.'),
    'growing_up': event('growing_up', key(7, 'growing up'), 'Intimate portrait questioning her entire path.'),
    'care_anyway': event('care_anyway', key(8, 'care'), 'Small warm smile as she reconnects with her craft.'),
    'next_frame': event('next_frame', key(8, 'next frame'), 'Clean animation paper and pen ready for the next step.')
}

# 14 coherent visual shots covering 0.000 to duration without gaps
# Varied scenic environments: attachment_cafe_r5 (social), nemi_creator_studio (work), thought (evening dread)
# Nemi is consistently authored at scale 1.75 (standard storytime proportions)
cuts_data = [
    # Shot 1: Cafe Hook Establishing & question
    (0.0, 'cafe_hook', 'attachment_cafe_r5', [960, 540], 1.05,
     [{'at': 0.0, 'center': [960, 540], 'zoom': 1.05}, {'at': 3.5, 'center': [800, 520], 'zoom': 1.25}],
     [540, 560], 1.75, 'Establishing cafe setting; glide in toward Nemi as the question bubble appears.'),
    
    # Shot 2: Cafe Soul Punch-in
    (4.0, 'cafe_soul_freeze', 'attachment_cafe_r5', [540, 410], 1.65,
     None,
     [540, 560], 1.75, 'Intimate punch-in on Nemi frozen in panic as her soul leaves her body.'),

    # Shot 3: Real Jobs Comparison (Briefcase & Tie)
    (7.8, 'career_compare', 'attachment_cafe_r5', [960, 540], 1.15,
     [{'at': 7.8, 'center': [960, 540], 'zoom': 1.15}, {'at': 15.0, 'center': [960, 530], 'zoom': 1.15}],
     [540, 560], 1.75, 'Two-shot comparing respectable jobs (briefcase/tie) with corporate formality.'),

    # Shot 4: Derpy Cartoon Admission
    (18.5, 'cartoons_admission', 'attachment_cafe_r5', [880, 530], 1.20,
     None,
     [540, 560], 1.75, 'Nemi sheepishly admits making cartoons on the internet beside derpy doodle.'),

    # Shot 5: The Polite Nod Setup
    (22.7, 'polite_nod_card', 'attachment_cafe_r5', [960, 540], 1.15,
     None,
     [540, 560], 1.75, 'The polite pity smile card appears beside Nemi.'),

    # Shot 6: UNEMPLOYED Stamp Punch-in
    (29.0, 'unemployed_stamp', 'attachment_cafe_r5', [860, 440], 1.35,
     [{'at': 29.0, 'center': [860, 440], 'zoom': 1.35}, {'at': 31.5, 'center': [860, 430], 'zoom': 1.45}],
     [540, 560], 1.75, 'Dramatic punch-in as the UNEMPLOYED stamp confirms the brutal social translation.'),

    # Shot 7: Studio Reality ($0.00 statement)
    (31.9, 'studio_earnings', 'nemi_creator_studio', [960, 540], 1.10,
     [{'at': 31.9, 'center': [960, 540], 'zoom': 1.10}, {'at': 38.0, 'center': [980, 520], 'zoom': 1.18}],
     [540, 560], 1.75, 'Cut to creator studio; camera glides to the stark $0.00 earnings statement.'),

    # Shot 8: Empty Ko-fi Tip Jar
    (41.8, 'kofi_confession', 'nemi_creator_studio', [960, 530], 1.15,
     None,
     [540, 560], 1.75, 'Ko-fi tip jar with solitary coins and vulnerable admission that hardly anyone donates.'),

    # Shot 9: 40-Hour Tablet Work Grind
    (51.4, 'tablet_grind', 'nemi_creator_studio', [960, 540], 1.12,
     [{'at': 51.4, 'center': [960, 540], 'zoom': 1.12}, {'at': 62.0, 'center': [980, 510], 'zoom': 1.18}],
     [540, 560], 1.75, 'Studio wide view framing tablet timeline scrub and 40-hour spinning clock.'),

    # Shot 10: Algorithmic Dread (Evening Wash)
    (66.0, 'night_algorithm', 'thought', [960, 540], 1.15,
     [{'at': 66.0, 'center': [960, 540], 'zoom': 1.15}, {'at': 74.0, 'center': [980, 520], 'zoom': 1.20}],
     [540, 560], 1.75, 'Transition to cool evening wash; YouTube flatline stats and algorithm monster.'),

    # Shot 11: Imposter Storm Cloud Portrait
    (81.8, 'doubt_storm', 'thought', [540, 400], 1.65,
     [{'at': 81.8, 'center': [540, 400], 'zoom': 1.65}, {'at': 86.0, 'center': [540, 380], 'zoom': 1.75}],
     [540, 560], 1.75, 'Intimate portrait under scribbly doubt storm cloud: "What if I am wasting my time?"'),

    # Shot 12: Existential Pause
    (87.5, 'existential_hold', 'thought', [540, 380], 1.75,
     None,
     [540, 560], 1.75, 'Quiet emotional hold confronting deep creative imposter syndrome.'),

    # Shot 13: Care Anyway & Heart Spark
    (91.5, 'care_heart', 'nemi_creator_studio', [880, 530], 1.18,
     None,
     [540, 560], 1.75, 'Return to morning studio light; warm glowing heart spark appears beside Nemi.'),

    # Shot 14: Draw Next Frame Resolution
    (101.0, 'draw_next_frame', 'nemi_creator_studio', [960, 530], 1.15,
     [{'at': 101.0, 'center': [960, 530], 'zoom': 1.15}, {'at': 106.0, 'center': [960, 540], 'zoom': 1.08}],
     [540, 560], 1.75, 'Animation peg paper and stylus sketching next frame; serene determined resolution.')
]

shots = []
for i in range(len(cuts_data)):
    t_start, s_id, bg, center, zoom, path, actor_pos, actor_scale, desc = cuts_data[i]
    t_end = cuts_data[i+1][0] if i+1 < len(cuts_data) else duration
    cam = {'center': center, 'zoom': zoom}
    if path:
        cam['path'] = path
    shots.append({
        'id': s_id,
        'start': r(t_start),
        'end': r(t_end),
        'background': bg,
        'actors': {
            'nemi': {
                'position': actor_pos,
                'scale': actor_scale
            }
        },
        'camera': cam
    })

# Performances: grounded character acting matching each thought
performances_raw = [
    # 0. Hook: freeze on question, soul leaving
    (0.0, 'school_confide', {'gaze': (0, 0), 'face': {'eye_openness': 0.95}}),
    (E['question'], 'school_question', {'gaze': (0.2, -0.05), 'event_id': 'question'}),
    (E['soul_leaves'], 'quiet_recoil', {'motion': 'snap', 'gaze': (0.1, 0.1), 'event_id': 'soul_leaves'}),

    # 1. Career comparison: real jobs vs cartoons
    (starts[1], 'school_explain', {'gaze': (0.25, 0), 'hands': {'left': 'open_palm_up', 'right': 'relaxed'}}),
    (E['real_jobs'], 'school_present', {'gaze': (0.35, 0.05), 'event_id': 'real_jobs'}),
    (E['cartoons'], 'embarrassed', {'gaze': (-0.2, 0.15), 'face': {'eye_openness': 0.9}, 'event_id': 'cartoons'}),

    # 2. Polite nod & unemployed translation
    (starts[2], 'school_question', {'gaze': (0.25, 0)}),
    (E['polite_nod'], 'pleased', {'gaze': (0.3, 0.05), 'event_id': 'polite_nod'}),
    (E['unemployed'], 'deadpan', {'motion': 'snap', 'gaze': (0, 0), 'event_id': 'unemployed'}),

    # 3. $0.00 earnings confession
    (starts[3], 'school_shame', {'gaze': (-0.25, 0.2)}),
    (E['zero_dollars'], 'overwhelmed', {'gaze': (-0.1, 0.25), 'event_id': 'zero_dollars'}),

    # 4. Empty Ko-fi page
    (starts[4], 'school_explain', {'gaze': (0.35, 0.05), 'hands': {'left': 'relaxed', 'right': 'open_palm_up'}}),
    (E['kofi_jar'], 'soft_shrug', {'hands': {'left': 'open_palm_up', 'right': 'open_palm_up'}, 'event_id': 'kofi_jar'}),
    (E['hardly_donates'], 'deadpan', {'motion': 'snap', 'gaze': (0, 0), 'event_id': 'hardly_donates'}),

    # 5. 40 hours tablet labor
    (starts[5], 'school_explain', {'gaze': (0.2, 0)}),
    (E['tablet_work'], 'prop_present', {'gaze': (0.3, 0.1), 'hands': {'left': 'relaxed', 'right': 'open_palm_up'}, 'event_id': 'tablet_work'}),
    (E['clock_40h'], 'school_resolve', {'gaze': (0, 0), 'hands': {'left': 'fist', 'right': 'relaxed'}, 'event_id': 'clock_40h'}),

    # 6. Night dread & flat stats
    (starts[6], 'uncertain', {'gaze': (-0.15, 0.1)}),
    (E['scary_night'], 'quiet_recoil', {'gaze': (0.2, 0.15), 'event_id': 'scary_night'}),
    (E['flat_stats'], 'overwhelmed', {'gaze': (-0.2, 0.2), 'event_id': 'flat_stats'}),

    # 7. Existential imposter syndrome
    (starts[7], 'school_shame', {'gaze': (-0.2, 0.15)}),
    (E['growing_up'], 'school_confide', {'gaze': (0, 0), 'face': {'eye_openness': 0.92}, 'event_id': 'growing_up'}),

    # 8. Resolution: drawing next frame
    (starts[8], 'recover', {'gaze': (0, 0)}),
    (E['care_anyway'], 'school_relief', {'gaze': (0.2, 0.0), 'face': {'eye_openness': 1.05}, 'event_id': 'care_anyway'}),
    (E['next_frame'], 'school_resolve', {'gaze': (0, 0), 'hands': {'left': 'relaxed', 'right': 'open_palm_up'}, 'event_id': 'next_frame'})
]

performances_raw.sort(key=lambda x: x[0])
performances = []
for idx, (t, recipe, kw) in enumerate(performances_raw):
    t_val = r(t)
    next_t = r(performances_raw[idx+1][0]) if idx + 1 < len(performances_raw) else duration
    gap = next_t - t_val
    if gap <= 0.05:
        continue
    dur = 0.0 if kw.get('motion') == 'snap' else min(0.35, round(gap - 0.02, 3))
    c = {
        'at': t_val,
        'recipe': recipe,
        'duration': dur,
        'gaze': list(kw.get('gaze', (0, 0))),
        'hands': kw.get('hands', {'left': 'relaxed', 'right': 'relaxed'})
    }
    if 'face' in kw: c['face'] = kw['face']
    if kw.get('motion') and kw['motion'] != 'smooth': c['motion'] = kw['motion']
    if kw.get('motion') == 'stepped': c['step_fps'] = 12
    if 'event_id' in kw: c['event'] = kw['event_id']
    
    # Blinks: if gap is large enough (> 2.0s), add a natural blink
    if gap > 2.0 and kw.get('motion') != 'snap':
        blink_t = round(t_val + 1.2, 3)
        if blink_t + 0.14 <= next_t:
            c['blinks'] = [blink_t]
    performances.append(c)

# 14 Rich vector drawings & props across the sequence
drawings = []
def add_draw(kind, at, end, pos=(1240, 480), scale=(1.1, 1.1), mode='hold', dur=0.5, ev_id=None):
    d = {
        'author': 'nemi',
        'kind': kind,
        'at': r(at),
        'end': r(end),
        'position': list(pos),
        'scale': list(scale),
        'mode': mode,
        'duration': dur
    }
    if ev_id:
        d['event'] = ev_id
    drawings.append(d)

# Beat 1: Social question bubble
add_draw('embarrassed_question_bubble', E['question'], 7.3, pos=(1240, 420), scale=(1.15, 1.15), mode='live', dur=0.6, ev_id='question')

# Beat 2: Corporate jobs & derpy cartoon
add_draw('embarrassed_normal_jobs', E['real_jobs'], 20.0, pos=(1280, 460), scale=(1.1, 1.1), mode='hold', ev_id='real_jobs')
add_draw('embarrassed_derpy_cartoon', E['cartoons'], 22.7, pos=(1250, 450), scale=(1.15, 1.15), mode='live', dur=0.7, ev_id='cartoons')

# Beat 3: Polite nod & UNEMPLOYED stamp
add_draw('embarrassed_polite_smile', E['polite_nod'], 29.5, pos=(1260, 460), scale=(1.1, 1.1), mode='hold', ev_id='polite_nod')
add_draw('embarrassed_unemployed_stamp', E['unemployed'], 31.9, pos=(1160, 420), scale=(1.25, 1.25), mode='live', dur=0.4, ev_id='unemployed')

# Beat 4: Financial reality $0.00
add_draw('embarrassed_zero_earnings', E['zero_dollars'], 41.8, pos=(1250, 460), scale=(1.15, 1.15), mode='live', dur=0.8, ev_id='zero_dollars')

# Beat 5: Ko-fi jar
add_draw('embarrassed_kofi_jar', E['kofi_jar'], 51.4, pos=(1240, 480), scale=(1.2, 1.2), mode='live', dur=0.7, ev_id='kofi_jar')

# Beat 6: Tablet timeline & 40h clock
add_draw('embarrassed_tablet_work', E['tablet_work'], 66.0, pos=(1260, 530), scale=(1.1, 1.1), mode='hold', ev_id='tablet_work')
add_draw('embarrassed_clock_40h', E['clock_40h'], 66.0, pos=(1260, 260), scale=(1.1, 1.1), mode='live', dur=0.6, ev_id='clock_40h')

# Beat 7: YouTube Stats & Algorithm Monster
add_draw('embarrassed_youtube_stats', E['flat_stats'], 81.8, pos=(1250, 490), scale=(1.1, 1.1), mode='hold', ev_id='flat_stats')
add_draw('embarrassed_algorithm_monster', E['flat_stats'], 81.8, pos=(1250, 230), scale=(1.05, 1.05), mode='live', dur=0.8, ev_id='flat_stats')

# Beat 8: Doubt storm cloud
add_draw('embarrassed_doubt_cloud', E['scary_night'], 91.5, pos=(540, 140), scale=(1.2, 1.2), mode='live', dur=0.9, ev_id='scary_night')

# Beat 9: Heart spark & Next frame peg paper
add_draw('embarrassed_spark_heart', E['care_anyway'], duration, pos=(1180, 430), scale=(1.15, 1.15), mode='live', dur=0.6, ev_id='care_anyway')
add_draw('embarrassed_next_frame', E['next_frame'], duration, pos=(1250, 470), scale=(1.1, 1.1), mode='live', dur=0.8, ev_id='next_frame')

# SFX: 9 punctual event-linked effects (gain_db <= -6.0 dB)
sfx = [
    {'at': r(E['soul_leaves']), 'file': 'res://common/audio/sfx/comedic/comedic_fail_low_tone_01.wav', 'gain_db': -6.0, 'duration': 1.2, 'event': 'soul_leaves'},
    {'at': r(E['real_jobs']), 'file': 'res://common/audio/sfx/paper/paper_page_flip_02.ogg', 'gain_db': -8.0, 'duration': 0.8, 'event': 'real_jobs'},
    {'at': r(E['unemployed']), 'file': 'res://common/audio/sfx/comedic/comedic_record_scratch_01.wav', 'gain_db': -6.0, 'duration': 0.9, 'event': 'unemployed'},
    {'at': r(E['zero_dollars']), 'file': 'res://common/audio/sfx/error.mp3', 'gain_db': -6.0, 'duration': 1.0, 'event': 'zero_dollars'},
    {'at': r(E['kofi_jar']), 'file': 'res://common/audio/sfx/ping.mp3', 'gain_db': -7.0, 'duration': 0.7, 'event': 'kofi_jar'},
    {'at': r(E['clock_40h']), 'file': 'res://common/audio/sfx/drawing/drawing_scratch_scribble_01.ogg', 'gain_db': -7.0, 'duration': 1.2, 'event': 'clock_40h'},
    {'at': r(E['flat_stats']), 'file': 'res://common/audio/sfx/ambience/ambience_suspense_drone_01.wav', 'gain_db': -9.0, 'duration': 2.0, 'event': 'flat_stats'},
    {'at': r(E['care_anyway']), 'file': 'res://common/audio/sfx/chime.mp3', 'gain_db': -7.0, 'duration': 0.8, 'event': 'care_anyway'},
    {'at': r(E['next_frame']), 'file': 'res://common/audio/sfx/drawing/drawing_pencil_sketch_01.wav', 'gain_db': -6.0, 'duration': 1.0, 'event': 'next_frame'}
]

# VFX: 4 punctual event-linked visual effects
vfx = [
    {'kind': 'sweat', 'author': 'nemi', 'actor': 'nemi', 'at': r(E['question']), 'end': r(E['question'] + 1.5), 'strength': 0.8, 'offset': [80, -30], 'event': 'question'},
    {'kind': 'impact', 'author': 'nemi', 'actor': 'nemi', 'at': r(E['unemployed']), 'end': r(E['unemployed'] + 1.2), 'strength': 0.9, 'offset': [0, -50], 'event': 'unemployed'},
    {'kind': 'tension', 'author': 'nemi', 'actor': 'nemi', 'at': r(E['scary_night']), 'end': r(E['scary_night'] + 1.5), 'strength': 0.85, 'offset': [0, -40], 'event': 'scary_night'},
    {'kind': 'relief', 'author': 'nemi', 'actor': 'nemi', 'at': r(E['care_anyway']), 'end': r(E['care_anyway'] + 1.5), 'strength': 0.9, 'offset': [80, -30], 'event': 'care_anyway'}
]

# Captions (≤ 5 words per card)
captions = []
MAX_WORDS_PER_CARD = 4
for g in groups:
    i = 0
    while i < len(g):
        chunk = g[i:i+MAX_WORDS_PER_CARD]
        c_start = chunk[0]['start']
        c_end = chunk[-1]['end']
        c_text = ' '.join(w['word'] for w in chunk).strip()
        captions.append({
            'start': r(c_start),
            'end': r(c_end),
            'text': c_text,
            'actor': 'nemi'
        })
        i += len(chunk)

# Mouth shapes strictly inside speaker turns, using standard Nemi shapes
raw_mouths = []
for i, g in enumerate(groups):
    turn_start = starts[i]
    turn_end = ends[i]
    for w in g:
        a, b = w['start'], w['end']
        token = clean(w['word'])
        if b - a < 0.045:
            continue
        a_c = max(turn_start, a)
        b_c = min(turn_end, b)
        if b_c - a_c < 0.04:
            continue
        onset = 0.035 if token.startswith(('m', 'b', 'p')) else 0.012
        vowel = 'o_u' if re.search(r'(oo|ou|ow|you|too|phone)', token) else 'ae' if re.search(r'(a|ai|ei)', token) else 'small_open'
        if onset > 0.02 and a_c + onset < b_c:
            raw_mouths.append({'start': r(a_c), 'end': r(a_c + onset), 'shape': 'closed'})
        close = 0.035 if b_c - a_c > 0.10 else 0.015
        mid_start = a_c + onset if (onset > 0.02 and a_c + onset < b_c) else a_c
        mid_end = max(mid_start + 0.02, b_c - close)
        raw_mouths.append({'start': r(mid_start), 'end': r(mid_end), 'shape': vowel})
        if mid_end < b_c:
            raw_mouths.append({'start': r(mid_end), 'end': r(b_c), 'shape': 'closed'})

# Ensure mouth cues are non-overlapping and strictly increasing
mouths = []
last_m_end = 0.0
for m in raw_mouths:
    m_s = m['start']
    m_e = m['end']
    if m_s < last_m_end:
        m_s = last_m_end
    if m_e <= m_s + 0.01:
        continue
    mouths.append({'start': r(m_s), 'end': r(m_e), 'shape': m['shape']})
    last_m_end = r(m_e)

script = [
    {
        'actor': 'nemi',
        'start': r(starts[i]),
        'end': r(ends[i]),
        'text': records[i]['text']
    }
    for i in range(len(records))
]

direction = {
    'promise': 'Nemi honestly confesses the embarrassment of admitting $0 income from creative content, and finds grounded peace to keep drawing.',
    'want': 'To be seen as doing real, meaningful labor even when the revenue and views have not caught up.',
    'choice': 'Admit the full financial and social truth without defensive excuses.',
    'consequence': 'Confronts late-night algorithm dread and imposter syndrome.',
    'payoff': 'Chooses to sit down and draw the next frame with quiet, serene determination.',
    'beats': [
        {'start': 0.0, 'end': 8.5, 'thought': 'The dreaded social question in the cafe.', 'focus': 'Cafe setting and speech bubble', 'visual': 'Nemi frozen beside the career question bubble.', 'intent': 'Establish core social tension.'},
        {'start': 8.5, 'end': 23.7, 'thought': 'Contrasting corporate jobs with internet cartoons.', 'focus': 'Briefcase vs derpy cartoon', 'visual': 'Corporate symbols contrasted with funny cartoon doodle.', 'intent': 'Humorous self-deprecating honesty.'},
        {'start': 23.7, 'end': 34.0, 'thought': 'The polite nod and UNEMPLOYED stamp.', 'focus': 'Polite nod card and stamp', 'visual': 'Deadpan smile card stamped UNEMPLOYED.', 'intent': 'Highlight social awkwardness.'},
        {'start': 34.0, 'end': 45.1, 'thought': 'Admitting the financial truth ($0.00).', 'focus': '$0.00 earnings card and slump', 'visual': 'Studio desk, defeated posture beside zero statement.', 'intent': 'Total transparency.'},
        {'start': 45.1, 'end': 57.4, 'thought': 'The empty Ko-fi tip jar.', 'focus': 'Ko-fi jar and zero donations', 'visual': 'Tip jar with zero donations, embarrassed hold.', 'intent': 'Gentle vulnerable comedy.'},
        {'start': 57.4, 'end': 72.5, 'thought': 'The grueling invisible labor of animation.', 'focus': 'Tablet timeline & 40h clock', 'visual': 'Nemi at drawing desk, frame counter and spinning clock.', 'intent': 'Validating creative effort.'},
        {'start': 72.5, 'end': 88.7, 'thought': 'Late night algorithmic panic.', 'focus': 'Flatline stats card and algorithm monster', 'visual': 'Cool evening canvas, flat view graph, doubt storm.', 'intent': 'Honest emotional depth.'},
        {'start': 88.7, 'end': 99.1, 'thought': 'Deep existential imposter syndrome.', 'focus': 'Intimate portrait of self-doubt', 'visual': 'Close portrait, quiet brow asymmetry.', 'intent': 'Confronting core creative fear.'},
        {'start': 99.1, 'end': duration, 'thought': 'Choosing to draw anyway.', 'focus': 'Heart spark and next frame paper', 'visual': 'Small warm smile, stylus poised on peg sheet.', 'intent': 'Grounded quiet resolve.'}
    ]
}

scene = {
    'version': 2,
    'title': "Nemi EP16 — I'm Embarrassed",
    'duration': duration,
    'fps': 30,
    'caption_size': 52,
    'audio': 'res://nemi/episodes/ep16_im_embarrassed/voice/narration_r1.wav',
    'audio_metadata': 'res://nemi/episodes/ep16_im_embarrassed/timing_reference_r1.json',
    'direction': direction,
    'actors': [
        {
            'id': 'nemi',
            'author': 'nemi',
            'performances': performances,
            'mouths': mouths
        }
    ],
    'shots': shots,
    'drawings': drawings,
    'props': [],
    'vfx': vfx,
    'sfx': sfx,
    'events': events,
    'script': script,
    'captions': captions
}

scene['mix'] = calibrate_mix(scene, ROOT)

out_scene = EP / 'scene.json'
out_scene.write_text(json.dumps(scene, indent=2) + '\n')
print(f'Wrote scene.json with duration {duration:.3f}s, {len(shots)} shots, {len(drawings)} drawings, {len(sfx)} sfx, {len(captions)} captions.')

# Validate scene specification
validate(str(out_scene))
print('VALIDATION PASSED SUCCESSFULLY!')
