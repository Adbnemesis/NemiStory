#!/usr/bin/env python3
"""Build the enriched, fully propped, live-doodled scene spec for ADB Ep02 Meet My Girlfriend.
Matches Ep00 color coding and rich environmental art direction.
"""
import copy
import hashlib
import json
import math
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'tools/storytime'))
from sfx_assets import validate_asset
from sfx_levels import choose_gain, pcm, levels as measure_levels
from audio_mix import calibrate_mix, mix_audio

ep_dir = ROOT / 'adb/episodes/ep02_meet_my_girlfriend'
audio_dir = ROOT / 'renders/adb_meet_girlfriend/audio_r2'

source = json.loads((ep_dir / 'source_words.json').read_text())
timeline = json.loads((audio_dir / 'timeline.json').read_text())
clips = timeline['clips']
duration = math.ceil(timeline['duration'] * 30.0) / 30.0

starts = [c['at'] for c in clips]
ends = [c['end_at'] for c in clips]

def wt(clip_idx, word_text):
    c = clips[clip_idx]
    s = source[clip_idx]
    w = next((item for item in s['words'] if word_text.lower() in item['word'].lower()), None)
    if w is None:
        return round(c['at'], 6)
    tempo = c.get('tempo', 1.0)
    return round(c['at'] + (w['start'] / tempo), 6)

def cue(t, recipe, dur=0.4, blinks=None, hands=None, gaze=None, motion='smooth', face=None, event_id=None, offset=0.0):
    item = dict(at=round(t, 6), recipe=recipe, duration=dur, motion=motion)
    if blinks:
        item['blinks'] = [round(b, 6) for b in blinks]
    if hands:
        item['hands'] = hands
    if gaze:
        item['gaze'] = gaze
    if face:
        item['face'] = face
    if event_id:
        item.update(event=event_id, event_offset=round(offset, 6))
    return item

events = []
def event(ident, t, summary):
    item = dict(id=ident, at=round(t, 6), intent=summary)
    events.append(item)
    return item

# Staging coordinates (world space)
# Solo ADB centered
adb_solo = {'position': [960, 591.4], 'scale': 1.7}
# Two-shot pair: ADB on right, Nemi on left, balanced two-shot
adb_pair = {'position': [1140, 591.4], 'scale': 1.7}
nemi_pair = {'position': [740, 615], 'scale': 1.65}
# Intimate close pair: for 4 AM balcony confession, first kiss, and final closing
adb_close = {'position': [1070, 591.4], 'scale': 1.7}
nemi_close = {'position': [830, 615], 'scale': 1.65}

shots = []
def shot(ident, t, bg='adb_studio_ep02', center=(960, 540), zoom=1.0, actors=None, cam_path=None):
    if actors is None:
        actors = {'adb': copy.deepcopy(adb_solo)}
    cam = dict(center=list(center), zoom=zoom)
    if cam_path:
        cam['path'] = cam_path
    shots.append(dict(
        id=ident,
        start=round(t, 6),
        end=0,
        background=bg,
        actors=actors,
        camera=cam
    ))

# 24 core shots with Ep00 balanced framing:
# - Steady base storytelling
# - Snappy comedic punches (cam_punch ~1.28x-1.30x) on jokes
# - Gentle cinematic pushes on intimate beats
# Shot 0: Hook - Studio setup with subtle opening push
shot('hook_studio', 0, 'adb_studio_ep02', (960, 520), 1.20, {'adb': copy.deepcopy(adb_solo)},
     cam_path=[{'at': 0.0, 'center': [960, 520], 'zoom': 1.15}, {'at': 2.8, 'center': [960, 500], 'zoom': 1.22}])

# Shot 1: Reveal - clean steady two-shot revealing Nemi standing beside ADB
shot('reveal_name', starts[1], 'adb_studio_ep02', (930, 520), 1.12, {'adb': copy.deepcopy(adb_pair), 'nemi': copy.deepcopy(nemi_pair)})

# Shot 2: Disappointment - comedic punch-in on ADB's deadpan expression (Ep00 style 1.28x)
shot('disappointment', starts[2], 'adb_studio_ep02', (960, 480), 1.28, {'adb': copy.deepcopy(adb_solo)},
     cam_path=[{'at': round(starts[2], 6), 'center': [960, 510], 'zoom': 1.15}, {'at': round(starts[2] + 0.25, 6), 'center': [960, 480], 'zoom': 1.28}])

# Shot 3: Covid flashback - warm dorm study setup
shot('covid_intro', starts[3], 'adb_dorm_party', (960, 520), 1.15, {'adb': copy.deepcopy(adb_solo)})

# Shot 4: Zoom virtual class fatigue
shot('zoom_boxes', starts[4], 'adb_dorm_party', (960, 520), 1.15, {'adb': copy.deepcopy(adb_solo)})

# Shot 5: Dorm party kicks off with neon mystery punch
shot('mystery_punch', starts[5], 'adb_dorm_party', (960, 520), 1.15, {'adb': copy.deepcopy(adb_solo)})

# Shot 6: ADB isolated in corner doing thermodynamics
shot('thermo_corner', starts[6], 'adb_dorm_party', (960, 520), 1.15, {'adb': copy.deepcopy(adb_solo)})

# Shot 7: Nemi approaches and challenges his homework
shot('nemi_approach', starts[7], 'adb_dorm_party', (930, 520), 1.12, {'adb': copy.deepcopy(adb_pair), 'nemi': copy.deepcopy(nemi_pair)})

# Shot 8: Panic survival instincts - comedic punch-in (1.28x)
shot('survival_instincts', starts[8], 'adb_dorm_party', (960, 480), 1.28, {'adb': copy.deepcopy(adb_solo)},
     cam_path=[{'at': round(starts[8], 6), 'center': [960, 510], 'zoom': 1.15}, {'at': round(starts[8] + 0.25, 6), 'center': [960, 480], 'zoom': 1.28}])

# Shot 9: Nemi offers the red party cup
shot('red_cup_offer', starts[9], 'adb_dorm_party', (930, 520), 1.12, {'adb': copy.deepcopy(adb_pair), 'nemi': copy.deepcopy(nemi_pair)})

# Shot 10: Mistake #1 punch-in (Ep00 style 1.30x)
shot('mistake_one', starts[10], 'adb_dorm_party', (960, 480), 1.30, {'adb': copy.deepcopy(adb_solo)},
     cam_path=[{'at': round(starts[10], 6), 'center': [960, 510], 'zoom': 1.15}, {'at': round(starts[10] + 0.25, 6), 'center': [960, 480], 'zoom': 1.30}])

# Shot 11: Three drinks in
shot('three_drinks', starts[11], 'adb_dorm_party', (960, 500), 1.20, {'adb': copy.deepcopy(adb_solo)})

# Shot 12: Passionate nerd debate
shot('nerd_debates', starts[12], 'adb_dorm_party', (930, 520), 1.12, {'adb': copy.deepcopy(adb_pair), 'nemi': copy.deepcopy(nemi_pair)})

# Shot 13: 4 AM balcony sitting - twilight night sky with stars and city skyline
shot('balcony_floor', starts[13], 'adb_balcony_4am', (930, 520), 1.12, {'adb': copy.deepcopy(adb_pair), 'nemi': copy.deepcopy(nemi_pair)})

# Shot 14: Deep intimate conversation on balcony - subtle intimate push
shot('deep_talk', starts[14], 'adb_balcony_4am', (940, 510), 1.22, {'adb': copy.deepcopy(adb_close), 'nemi': copy.deepcopy(nemi_close)},
     cam_path=[{'at': round(starts[14], 6), 'center': [940, 520], 'zoom': 1.15}, {'at': round(starts[14] + 3.2, 6), 'center': [940, 505], 'zoom': 1.22}])

# Shot 15: "And then things happened..." - comedic blush punch-in (1.28x)
shot('things_happened', starts[15], 'adb_balcony_4am', (960, 480), 1.28, {'adb': copy.deepcopy(adb_solo)},
     cam_path=[{'at': round(starts[15], 6), 'center': [960, 510], 'zoom': 1.15}, {'at': round(starts[15] + 0.25, 6), 'center': [960, 480], 'zoom': 1.28}])

# Shot 16: The first kiss - gentle intimate push
shot('the_kiss', starts[16], 'adb_balcony_4am', (940, 500), 1.24, {'adb': copy.deepcopy(adb_close), 'nemi': copy.deepcopy(nemi_close)},
     cam_path=[{'at': round(starts[16], 6), 'center': [940, 515], 'zoom': 1.16}, {'at': round(starts[16] + 3.0, 6), 'center': [940, 495], 'zoom': 1.24}])

# Shot 17: Morning reality check - sunbeams streaming in
shot('morning_panic', starts[17], 'adb_morning_panic', (940, 520), 1.16, {'adb': copy.deepcopy(adb_pair), 'nemi': copy.deepcopy(nemi_pair)})

# Shot 18: "Mature adults" speech - comedic rationalization punch-in (1.28x)
shot('mature_adults', starts[18], 'adb_morning_panic', (960, 480), 1.28, {'adb': copy.deepcopy(adb_solo)},
     cam_path=[{'at': round(starts[18], 6), 'center': [960, 510], 'zoom': 1.15}, {'at': round(starts[18] + 0.25, 6), 'center': [960, 480], 'zoom': 1.28}])

# Shot 19: The friendship pact
shot('normal_friends', starts[19], 'adb_morning_panic', (930, 520), 1.12, {'adb': copy.deepcopy(adb_pair), 'nemi': copy.deepcopy(nemi_pair)})

# Shot 20: 5 Years later timeline leap - snappy timeline punch (1.28x)
shot('five_years', starts[20], 'adb_studio_ep02', (960, 490), 1.28, {'adb': copy.deepcopy(adb_solo)},
     cam_path=[{'at': round(starts[20], 6), 'center': [960, 520], 'zoom': 1.15}, {'at': round(starts[20] + 0.3, 6), 'center': [960, 490], 'zoom': 1.28}])

# Shot 21: Present day studio punch
shot('together', starts[21], 'adb_studio_ep02', (930, 520), 1.12, {'adb': copy.deepcopy(adb_pair), 'nemi': copy.deepcopy(nemi_pair)})

# Shot 22: Hoodie roasting & banter
shot('hoodies_roasting', starts[22], 'adb_studio_ep02', (930, 520), 1.12, {'adb': copy.deepcopy(adb_pair), 'nemi': copy.deepcopy(nemi_pair)})

# Shot 23: Heartfelt payoff closing - gentle warm push
shot('best_mistake', starts[23], 'adb_studio_ep02', (940, 515), 1.20, {'adb': copy.deepcopy(adb_close), 'nemi': copy.deepcopy(nemi_close)},
     cam_path=[{'at': round(starts[23], 6), 'center': [940, 525], 'zoom': 1.14}, {'at': round(starts[23] + 3.0, 6), 'center': [940, 505], 'zoom': 1.20}])

for i, s in enumerate(shots):
    s['end'] = shots[i + 1]['start'] if i + 1 < len(shots) else duration
S = {s['id']: s for s in shots}

# Named Story Events
ev_hook = event('hook', wt(0, 'asking'), 'Intro callback on mystery girl.')
ev_shove = event('shove', wt(0, 'shoved'), 'Shoved onto screen callback.')
ev_potato = event('potato', wt(0, 'potato'), 'Potato doodle callback.')
ev_reveal = event('reveal', starts[1], 'Official reveal of Nemi.')
ev_covid = event('covid', starts[3], 'Establishing the Covid lockdown context.')
ev_party = event('party', starts[5], 'Dorm block party kickoff.')
ev_nemi_talk = event('nemi_talk', starts[7], 'Nemi initiates conversation.')
ev_mistake = event('mistake', starts[10], 'The turning point mistake number one.')
ev_debate = event('debate', starts[12], 'Passionate drunk nerd debates.')
ev_balcony = event('balcony', starts[13], 'Quiet balcony conversation till dawn.')
ev_kiss = event('kiss', starts[16], 'The first kiss.')
ev_morning = event('morning', starts[17], 'Morning reality and mutual panic.')
ev_truce = event('truce', starts[19], 'Agreed mature friendship truce.')
ev_five_years = event('five_years', starts[20], 'Five year timeline transition.')
ev_payoff = event('payoff', starts[23], 'Best mistake I ever made payoff.')

## Rich ADB Acting Performances with frequent nuances and reactive poses
adb_perfs = [
    cue(0, 'explaining', 0, hands={'right': 'pointing', 'left': 'relaxed'}, blinks=[2.5]),
    cue(4.2, 'clue_point', 0.35, hands={'right': 'open_palm', 'left': 'relaxed'}, blinks=[6.0]),
    cue(starts[1], 'prop_present', 0.4, gaze=[-0.4, 0], hands={'right': 'open_palm', 'left': 'relaxed'}),
    cue(starts[2], 'deadpan', 0, motion='snap', gaze=[-0.4, 0.1], blinks=[ends[2] - 0.4]),
    cue(starts[3], 'dry_annoyance', 0.4, hands={'right': 'relaxed', 'left': 'relaxed'}, blinks=[starts[3] + 1.8]),
    cue(starts[4], 'quiet_recoil', 0.4, gaze=[0.2, -0.2], hands={'right': 'hand_to_chin', 'left': 'relaxed'}),
    cue(starts[5], 'nervous_wait', 0.4, hands={'right': 'pointing', 'left': 'relaxed'}, blinks=[starts[5] + 2.0]),
    cue(starts[6], 'listening', 0.35, gaze=[-0.3, 0.3], hands={'right': 'relaxed', 'left': 'relaxed'}),
    cue(starts[7], 'nervous_answer', 0.4, gaze=[-0.4, 0], hands={'right': 'relaxed', 'left': 'relaxed'}),
    cue(starts[8], 'open_shrug', 0.4, hands={'right': 'shrug_open', 'left': 'relaxed'}, blinks=[starts[8] + 1.5]),
    cue(starts[9], 'uncertain', 0.4, gaze=[-0.4, 0.2], hands={'right': 'relaxed', 'left': 'relaxed'}),
    cue(starts[10], 'realization', 0, motion='snap', blinks=[ends[10] + 0.3]),
    cue(starts[11], 'self_impressed', 0.4, gaze=[0.2, 0], hands={'right': 'relaxed', 'left': 'relaxed'}),
    cue(starts[12], 'explaining', 0.45, gaze=[-0.4, 0], hands={'right': 'pointing', 'left': 'relaxed'}, blinks=[starts[12] + 2.4]),
    cue(starts[13], 'listening', 0.45, gaze=[-0.3, -0.1], hands={'right': 'relaxed', 'left': 'relaxed'}, blinks=[starts[13] + 2.0]),
    cue(starts[14], 'shy_confession', 0.45, gaze=[-0.3, 0.1], hands={'right': 'open_palm', 'left': 'relaxed'}, face={'blush_intensity': 0.35}),
    cue(starts[15], 'embarrassed', 0.45, gaze=[0.3, 0.2], hands={'right': 'hand_to_chin', 'left': 'relaxed'}, face={'blush_intensity': 0.55}),
    cue(starts[16], 'lean_in', 0.5, gaze=[-0.4, 0], hands={'right': 'relaxed', 'left': 'relaxed'}, face={'blush_intensity': 0.40}),
    cue(starts[17], 'quiet_recoil', 0.35, gaze=[0.4, 0.1], hands={'right': 'fist', 'left': 'relaxed'}, blinks=[starts[17] + 1.2]),
    cue(starts[18], 'explaining', 0.4, hands={'right': 'pointing', 'left': 'relaxed'}),
    cue(starts[19], 'nervous_answer', 0, motion='snap', gaze=[-0.3, 0], hands={'right': 'relaxed', 'left': 'relaxed'}, blinks=[ends[19] + 0.3]),
    cue(starts[20], 'self_impressed', 0.4, hands={'right': 'relaxed', 'left': 'relaxed'}),
    cue(starts[21], 'explaining', 0.4, gaze=[-0.3, 0], hands={'right': 'open_palm', 'left': 'relaxed'}),
    cue(starts[22], 'dry_annoyance', 0.45, gaze=[-0.4, 0], hands={'right': 'shrug_open', 'left': 'relaxed'}),
    cue(starts[23], 'shy_confession', 0.45, hands={'right': 'relaxed', 'left': 'relaxed'}, face={'blush_intensity': 0.30}, blinks=[starts[23] + 1.8])
]

# Rich, Natural Nemi Acting Performances (Poised, clean resting arms, no contorted pointing)
nemi_perfs = [
    cue(0, 'listening', 0, hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[1], 'pleased', 0.4, gaze=[0.3, 0], hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[1] + 1.8, 'pleased', 0.35, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.4, 0], blinks=[starts[1] + 2.5]),
    cue(starts[1] + 3.0, 'pleased', 0.3, hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[7], 'skeptical', 0.4, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.4, 0]),
    cue(starts[7] + 3.2, 'pleased', 0.4, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.4, 0]),
    cue(starts[7] + 6.0, 'pleased', 0.35, hands={'left': 'relaxed', 'right': 'relaxed'}, blinks=[starts[7] + 6.8]),
    cue(starts[9], 'prop_present', 0.4, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.4, 0]),
    cue(starts[9] + 2.0, 'pleased', 0.35, hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[12], 'explaining', 0.45, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.4, 0]),
    cue(starts[12] + 3.0, 'listening', 0.4, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.4, 0]),
    cue(starts[12] + 5.8, 'pleased', 0.35, hands={'left': 'relaxed', 'right': 'relaxed'}, blinks=[starts[12] + 6.5]),
    cue(starts[13], 'listening', 0.45, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.3, -0.1]),
    cue(starts[13] + 2.8, 'pleased', 0.4, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.3, 0], blinks=[starts[13] + 3.6]),
    cue(starts[14], 'listening', 0.45, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.3, 0]),
    cue(starts[14] + 2.8, 'pleased', 0.4, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.3, 0]),
    cue(starts[15], 'embarrassed', 0.45, gaze=[-0.2, 0.2], hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[16], 'lean_in', 0.45, gaze=[0.4, 0], hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[16] + 2.2, 'pleased', 0.35, hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[17], 'quiet_recoil', 0.35, hands={'left': 'relaxed', 'right': 'relaxed'}, blinks=[starts[17] + 1.0]),
    cue(starts[17] + 1.8, 'uncertain', 0.35, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.5, 0]),
    cue(starts[19], 'skeptical', 0.4, gaze=[0.4, 0], hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[19] + 2.2, 'pleased', 0.35, hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[21], 'pleased', 0.4, hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[22], 'pleased', 0.4, gaze=[0.4, 0], hands={'left': 'relaxed', 'right': 'relaxed'}),
    cue(starts[22] + 2.8, 'pleased', 0.35, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0.4, 0]),
    cue(starts[23], 'lean_in', 0.45, hands={'left': 'relaxed', 'right': 'relaxed'}, gaze=[0, 0])
]

def sanitize_blinks(perfs, end_time):
    for i, p in enumerate(perfs):
        if 'blinks' not in p or not p['blinks']:
            continue
        next_at = perfs[i+1]['at'] if i+1 < len(perfs) else end_time
        valid_blinks = []
        for b in p['blinks']:
            if p['at'] <= b and b + 0.14 <= next_at:
                valid_blinks.append(b)
            else:
                safe_b = round(min(next_at - 0.16, max(p['at'] + 0.05, (p['at'] + next_at) / 2.0)), 6)
                if p['at'] <= safe_b and safe_b + 0.14 <= next_at:
                    valid_blinks.append(safe_b)
        if valid_blinks:
            p['blinks'] = valid_blinks
        else:
            p.pop('blinks', None)

sanitize_blinks(adb_perfs, duration)
sanitize_blinks(nemi_perfs, duration)

adb_actor = dict(
    id='adb',
    author='adb',
    performances=adb_perfs,
    mouths=[]
)

nemi_actor = dict(
    id='nemi',
    author='nemi',
    performances=nemi_perfs,
    mouths=[]
)

script = []
captions = []

round_words = {'you', 'no', 'so', 'who', 'would', 'told', 'once', 'over', 'room', 'zoom', 'door', 'college', 'two', 'hoodies'}
wide_words = {'she', 'me', 'we', 'he', 'yeah', 'nemi', 'serious', 'like', 'day', 'friends', 'quiz', 'math', 'agreed', 'years'}

raw_mouths = []
temp_cards = []

for clip_idx, c in enumerate(clips):
    s = source[clip_idx]
    tempo = c.get('tempo', 1.0)
    w_list = s['words']
    
    script.append(dict(actor='adb', start=round(c['at'], 6), end=round(c['end_at'], 6), text=s['text']))
    
    # Process word mouth shapes
    for w in w_list:
        w_start = round(c['at'] + (w['start'] / tempo), 6)
        w_end = round(c['end_at'] if w is w_list[-1] else c['at'] + (w['end'] / tempo), 6)
        if w_end <= w_start:
            w_end = w_start + 0.08
        clean = ''.join(ch for ch in w['word'].lower() if ch.isalnum())
        shape = 'talk_round' if clean in round_words else ('talk_wide' if clean in wide_words else 'talk_open')
        raw_mouths.append((w_start, w_end, shape))
    
    # Chunk captions per spoken sentence clause
    chunk_size = 4
    for i in range(0, len(w_list), chunk_size):
        chunk = w_list[i:i + chunk_size]
        card_start = round(c['at'] + (chunk[0]['start'] / tempo), 6)
        card_end = round(c['at'] + (chunk[-1]['end'] / tempo), 6)
        if card_end <= card_start:
            card_end = card_start + 0.5
        card_text = ' '.join(item['word'].strip() for item in chunk)
        # Ensure display name is strictly "Nemi", never "Nemmi"
        card_text = card_text.replace('Nemmi', 'Nemi')
        temp_cards.append((card_start, card_end, card_text))

# Filter mouth intervals to shots where adb is active, strictly monotonic non-overlapping
sanitized_mouths = []
last_m_end = 0.0
for m_start, m_end, shape in sorted(raw_mouths, key=lambda x: x[0]):
    active_shot = next((s for s in shots if s['start'] <= m_start < s['end']), None)
    if active_shot and 'adb' in active_shot['actors']:
        start_c = max(m_start, last_m_end)
        end_c = max(start_c + 0.04, m_end)
        if end_c > active_shot['end']:
            end_c = active_shot['end']
        if start_c < end_c:
            sanitized_mouths.append(dict(start=round(start_c, 6), end=round(end_c, 6), shape=shape))
            last_m_end = end_c

adb_actor['mouths'] = sanitized_mouths

# Monotonic non-overlapping captions
last_c_end = 0.0
for card_start, card_end, card_text in sorted(temp_cards, key=lambda x: x[0]):
    c_start = max(card_start, last_c_end)
    c_end = max(c_start + 0.3, card_end)
    if c_end > duration:
        c_end = duration
    if c_start < c_end:
        captions.append(dict(start=round(c_start, 6), end=round(c_end, 6), text=card_text))
        last_c_end = c_end

props = []
drawings = []
vfx = []

adb_glyphs = json.loads((ROOT / 'common/storytime/profiles/adb_lettering.json').read_text())['glyphs']
nemi_glyphs = json.loads((ROOT / 'common/storytime/profiles/nemi_lettering.json').read_text())['glyphs']

def doodle_text(txt, ids, center_xy, size=36, author='adb', accent=False, tilt=0.0, mode='live', dur=0.35, **kw):
    glyphs = adb_glyphs if author == 'adb' else nemi_glyphs
    unit = size / 10.0
    w = sum(glyphs[c]['advance'] * unit if c in glyphs else size * 0.48 for c in txt)
    h = size * 1.45
    top_left_x = round(center_xy[0] - w * 0.5, 1)
    top_left_y = round(center_xy[1] - h * 0.5, 1)
    
    shot_map = {s['id']: s for s in shots}
    at = kw.pop('at', min(shot_map[sid]['start'] for sid in ids) if ids else 0.0)
    end = kw.pop('end', max(shot_map[sid]['end'] for sid in ids) if ids else duration)
    at_val = round(at, 6)
    end_val = duration if end >= duration - 0.001 else round(end, 6)
    if end_val > duration:
        end_val = duration
    
    item = dict(
        author=author,
        kind='text',
        text=txt,
        position=[top_left_x, top_left_y],
        size=size,
        accent=accent,
        tilt=tilt,
        mode=mode,
        duration=dur,
        shots=ids,
        at=at_val,
        end=end_val,
        layer=kw.pop('layer', 3),
        **kw
    )
    drawings.append(item)
    return item

def prop(kind, ids, xy, scale=1.0, author='adb', layer=0, **kw):
    shot_map = {s['id']: s for s in shots}
    at = kw.pop('at', min(shot_map[sid]['start'] for sid in ids) if ids else 0.0)
    end = kw.pop('end', max(shot_map[sid]['end'] for sid in ids) if ids else duration)
    at_val = round(at, 6)
    end_val = duration if end >= duration - 0.001 else round(end, 6)
    if end_val > duration:
        end_val = duration
    item = dict(
        kind=kind,
        author=author,
        position=list(xy),
        scale=[scale, scale],
        mode='hold',
        shots=ids,
        at=at_val,
        end=end_val,
        layer=layer,
        **kw
    )
    props.append(item)
    return item

# =========================================================================
# MIXED CLEAN STORYTIME PROPS & FLOATING HANDWRITTEN DOODLES (Ep 00 Aesthetic)
# Neither underdone nor overdone: perfectly balanced props, doodles, and accents.
# =========================================================================

# Shot 0: Hook - Studio setup with desk mug, framed photo, clean confusion marks, and title badge
prop('mug', ['hook_studio'], (1420, 610), 0.85)
prop('anniversary_photo', ['hook_studio'], (1540, 560), 0.85)
prop('confusion_marks', ['hook_studio'], (720, 280), 0.9)
doodle_text('MEET MY GF', ['hook_studio'], (1340, 230), size=44, author='adb', accent=True, tilt=-2.5, at=0.6, dur=0.38)

# Shot 1: Reveal - Nemi enters beside ADB; subtle golden sparkles celebrate the reveal
prop('sparkle_stars', ['reveal_name'], (720, 260), 1.0)
prop('sparkle_stars', ['reveal_name'], (1140, 260), 1.0)
prop('anniversary_photo', ['reveal_name'], (1540, 560), 0.85)
doodle_text('NEMI!', ['reveal_name'], (930, 230), size=46, author='nemi', accent=True, tilt=3.0, at=starts[1] + 0.3, dur=0.35)

# Shot 2: Disappointment - Comedic punch-in with Ep00 Potato Evolution Card and ADB sweat drop
# Placed cleanly below lower shelf at Y=600, with punchline text in open upper-right negative space
prop('potato_chart', ['disappointment'], (520, 600), 0.90)
prop('sweat_drops', ['disappointment'], (1050, 310), 1.0)
doodle_text('NOT A POTATO', ['disappointment'], (1380, 240), size=38, author='adb', accent=False, tilt=-3.5, at=starts[2] + 0.2, dur=0.35)

# Shot 3: Covid Lockdown - Dorm study desk with laptop and engineering diagram
# Text placed in open cream negative space above study desk, well clear of fairy lights
prop('thermo_laptop', ['covid_intro'], (520, 670), 0.9)
prop('thermo_diagram', ['covid_intro'], (700, 690), 0.8)
doodle_text('2020 LOCKDOWN', ['covid_intro'], (560, 250), size=42, author='adb', accent=True, tilt=-2.0, at=starts[3] + 0.3, dur=0.38)

# Shot 4: Zoom Fatigue - Dorm desk setup with fatigue confusion accent
prop('thermo_laptop', ['zoom_boxes'], (520, 670), 0.9)
prop('confusion_marks', ['zoom_boxes'], (1120, 280), 0.95)
doodle_text('ZOOM FATIGUE', ['zoom_boxes'], (1320, 250), size=38, author='adb', accent=False, tilt=2.5, at=starts[4] + 0.3, dur=0.35)

# Shot 5: Mystery Punch - Dorm party kickoff with party solo cups
prop('red_cup', ['mystery_punch'], (480, 680), 0.85)
prop('red_cup', ['mystery_punch'], (540, 685), 0.8)
prop('thermo_laptop', ['mystery_punch'], (720, 680), 0.8)
doodle_text('DORM PARTY', ['mystery_punch'], (1320, 250), size=42, author='adb', accent=True, tilt=2.0, at=starts[5] + 0.3, dur=0.35)

# Shot 6: Thermodynamics in Corner - ADB studying alone at the party
prop('thermo_laptop', ['thermo_corner'], (540, 670), 0.95)
prop('thermo_diagram', ['thermo_corner'], (720, 685), 0.85)
prop('red_cup', ['thermo_corner'], (440, 695), 0.75)
doodle_text('STUDYING AT A PARTY', ['thermo_corner'], (560, 250), size=38, author='adb', accent=False, tilt=-3.0, at=starts[6] + 0.2, dur=0.35)

# Shot 7: Nemi Approach - Nemi steps up to his study corner
prop('thermo_laptop', ['nemi_approach'], (1460, 680), 0.85)
prop('sparkle_stars', ['nemi_approach'], (540, 360), 0.9)
doodle_text('MATH AT A PARTY?!', ['nemi_approach'], (640, 250), size=36, author='nemi', accent=True, tilt=3.0, at=starts[7] + 0.4, dur=0.40)

# Shot 8: Survival Instincts - Comedic punch-in on ADB panicking
prop('sweat_drops', ['survival_instincts'], (1060, 310), 1.0)
prop('confusion_marks', ['survival_instincts'], (820, 280), 0.95)
doodle_text('AN ART FORM!', ['survival_instincts'], (1360, 270), size=40, author='adb', accent=True, tilt=-4.0, at=starts[8] + 0.2, dur=0.35)

# Shot 9: Red Cup Offer - Nemi offers the red cup of punch to ADB
prop('red_cup_offered', ['red_cup_offer'], (940, 520), 0.95)
doodle_text('JUST ONE CUP', ['red_cup_offer'], (660, 240), size=38, author='nemi', accent=True, tilt=2.0, at=starts[9] + 0.3, dur=0.35)

# Shot 10: Mistake #1 - Punch-in with dramatic comic action burst and centered punchline text
# Clean centered burst in negative space, no stray mid-air cup
prop('action_burst_mistake', ['mistake_one'], (560, 345), 1.05)
doodle_text('MISTAKE #1!', ['mistake_one'], (560, 345), size=38, author='adb', accent=True, tilt=-4.0, at=starts[10] + 0.15, dur=0.30, layer=4)

# Shot 11: Three Drinks - Three solo cups lined up on party table
prop('red_cup', ['three_drinks'], (460, 680), 0.8)
prop('red_cup', ['three_drinks'], (520, 680), 0.8)
prop('red_cup', ['three_drinks'], (580, 680), 0.85)
doodle_text('3 DRINKS LATER', ['three_drinks'], (1320, 250), size=40, author='adb', accent=False, tilt=2.0, at=starts[11] + 0.2, dur=0.35)

# Shot 12: Nerd Debates - Anime Action vs Table Tennis Spin debate card
prop('anime_vs_physics', ['nerd_debates'], (940, 460), 0.88)
doodle_text('ANIME VS PHYSICS', ['nerd_debates'], (600, 240), size=40, author='adb', accent=True, tilt=-2.0, at=starts[12] + 0.3, dur=0.38)

# Shot 13: 4 AM Balcony - Night skyline with party cups on the floor
# Floor cups shifted cleanly left to X=440 and X=480, clear of footsteps
prop('red_cup', ['balcony_floor'], (440, 815), 0.75)
prop('red_cup', ['balcony_floor'], (480, 815), 0.75)
doodle_text('4:00 AM', ['balcony_floor'], (940, 170), size=44, author='adb', accent=True, tilt=-3.0, at=starts[13] + 0.3, dur=0.35)

# Shot 14: Deep Talk - Intimate conversation under the stars
prop('sparkle_stars', ['deep_talk'], (940, 240), 0.95)
doodle_text('DEEP TALK', ['deep_talk'], (940, 160), size=38, author='adb', accent=False, tilt=1.5, at=starts[14] + 0.3, dur=0.35)

# Shot 15: Things Happened - Blushing punch-in with soft romantic heart
prop('heart_doodle', ['things_happened'], (720, 310), 1.1)
doodle_text('THINGS HAPPENED...', ['things_happened'], (1320, 250), size=42, author='adb', accent=True, tilt=3.0, at=starts[15] + 0.2, dur=0.38)

# Shot 16: The Kiss - First sunrise kiss with glowing heart and stars
prop('heart_doodle', ['the_kiss'], (940, 270), 1.25)
prop('sparkle_stars', ['the_kiss'], (720, 230), 1.0)
prop('sparkle_stars', ['the_kiss'], (1160, 230), 1.0)
doodle_text('FIRST KISS', ['the_kiss'], (940, 160), size=42, author='adb', accent=True, tilt=-2.0, at=starts[16] + 0.3, dur=0.35)

# Shot 17: Morning Panic - Bedroom reality check with panic sweat drops
prop('sweat_drops', ['morning_panic'], (1050, 310), 1.0)
prop('confusion_marks', ['morning_panic'], (880, 260), 1.05)
doodle_text('9:00 AM PANIC!', ['morning_panic'], (940, 160), size=44, author='adb', accent=True, tilt=-4.0, at=starts[17] + 0.2, dur=0.35)

# Shot 18: Mature Adults - Comedic punch-in on rationalizing
prop('confusion_marks', ['mature_adults'], (780, 280), 1.0)
prop('sweat_drops', ['mature_adults'], (1060, 310), 1.0)
doodle_text('MATURE ADULTS', ['mature_adults'], (1340, 260), size=40, author='adb', accent=False, tilt=3.0, at=starts[18] + 0.2, dur=0.35)

# Shot 19: Normal Friends - Friendship pact with nervous sweat
prop('sweat_drops', ['normal_friends'], (1080, 310), 0.9)
doodle_text('JUST NORMAL FRIENDS', ['normal_friends'], (940, 160), size=42, author='adb', accent=True, tilt=-3.0, at=starts[19] + 0.3, dur=0.40)

# Shot 20: 5 Years Later - Framed anniversary photo displayed on table
# Text placed in open upper-right negative space above studio desk
prop('anniversary_photo', ['five_years'], (560, 500), 1.1)
doodle_text('5 YEARS LATER', ['five_years'], (1340, 220), size=46, author='adb', accent=True, tilt=2.0, at=starts[20] + 0.2, dur=0.35)

# Shot 21: Present Day Together - Studio two-shot with framed photo on desk
prop('anniversary_photo', ['together'], (1540, 580), 0.85)
prop('sparkle_stars', ['together'], (540, 340), 0.95)
doodle_text('STILL TOGETHER', ['together'], (940, 160), size=40, author='adb', accent=False, tilt=-2.0, at=starts[21] + 0.2, dur=0.35)

# Shot 22: Hoodie Roasting - ADB's stolen green hoodie comic prop
# Text placed above top shelf in open wall space at Y=140
prop('stolen_hoodie', ['hoodies_roasting'], (780, 480), 1.05)
doodle_text('MINE NOW!', ['hoodies_roasting'], (580, 140), size=44, author='nemi', accent=True, tilt=4.0, at=starts[22] + 0.3, dur=0.35)

# Shot 23: Best Mistake Closing - Payoff with heart, sparkles, and anniversary photo
# Text placed in open upper-right negative space above studio desk
prop('heart_doodle', ['best_mistake'], (940, 270), 1.25)
prop('sparkle_stars', ['best_mistake'], (720, 230), 1.0)
prop('sparkle_stars', ['best_mistake'], (1160, 230), 1.0)
prop('anniversary_photo', ['best_mistake'], (1540, 580), 0.85)
doodle_text('BEST MISTAKE', ['best_mistake'], (1380, 220), size=44, author='adb', accent=True, tilt=-2.0, at=starts[23] + 0.3, dur=0.38)

# Finite event-linked VFX
vfx.append(dict(author='adb', kind='realization', actor='adb', offset=[105, -40], at=starts[10], end=starts[10] + 0.65, event='mistake', strength=0.7))
vfx.append(dict(author='adb', kind='sweat', actor='adb', offset=[83, -25], at=starts[17], end=starts[17] + 0.8, event='morning', strength=0.6))
vfx.append(dict(author='adb', kind='relief', actor='adb', offset=[100, -40], at=starts[23], end=starts[23] + 0.7, event='payoff', strength=0.6))

# =========================================================================
# 3. SOUND PASS (26 distinct, calibrated SFX cues)
# =========================================================================
catalog = json.loads((ROOT / 'common/audio/sfx/sfx_catalog.json').read_text())['assets']
voice = pcm(audio_dir / 'narration.wav')
sound_records = []
sfx = []

def sound(ident, t, seconds, prominence, event_id=None):
    asset = next(a for a in catalog if a['id'] == ident)
    path = validate_asset(asset, ROOT)
    prom_key = 'hero' if prominence == 'hero' else ('surface' if prominence == 'surface' else 'accent')
    gain, levels = choose_gain(path, voice, t, seconds, prom_key)
    item = dict(
        file='res://' + asset['relative_path'],
        at=round(t, 6),
        duration=round(seconds, 6),
        gain_db=gain
    )
    if event_id:
        ev = next((e for e in events if e['id'] == event_id), None)
        item.update(event=event_id, event_offset=round(t - ev['at'], 6) if ev else 0.0)
    sfx.append(item)
    rec = dict(
        id=ident,
        sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
        source=asset['source'],
        license=asset.get('license'),
        cue=item,
        levels=levels
    )
    sound_records.append(rec)
    return item

# Foley, comedic beats, and accents
sound('cartoon_pluck_pop_01', wt(0, 'shoved'), 0.28, 'accent', event_id='shove')
sound('viral_pop', wt(0, 'potato'), 0.22, 'accent', event_id='potato')
sound('viral_chime', starts[1], 0.45, 'accent', event_id='reveal')
sound('transition_camera_shutter_01', starts[1] + 1.2, 0.35, 'foley')
sound('viral_bruh', starts[2], 0.55, 'accent')
sound('paper_page_turn_crisp_01', starts[3], 0.38, 'foley', event_id='covid')
sound('ui_select_blip_01', starts[4], 0.22, 'accent')
sound('comedic_record_scratch_01', starts[5], 0.42, 'accent', event_id='party')
sound('viral_pop', starts[5] + 1.2, 0.22, 'accent')
sound('computer_laptop_typing_fast_01', starts[6], 0.35, 'foley')
sound('computer_laptop_typing_fast_01', starts[6] + 0.8, 0.32, 'foley')
sound('sting_bell_notification_01', starts[7], 0.38, 'accent', event_id='nemi_talk')
sound('whoosh_fast_transition_01', starts[8], 0.32, 'foley')
sound('food_drink_quick_sip_01', starts[9], 0.35, 'accent')
sound('comedic_wrong_buzzer_01', starts[10], 0.48, 'accent', event_id='mistake')
sound('cartoon_pluck_pop_01', starts[11], 0.22, 'accent')
sound('cartoon_pluck_pop_01', starts[11] + 0.9, 0.22, 'accent')
sound('cartoon_pluck_pop_01', starts[11] + 1.8, 0.22, 'accent')
sound('whoosh_air_clean_01', starts[12], 0.45, 'foley', event_id='debate')
sound('cartoon_boing_bounce_01', starts[12] + 4.5, 0.45, 'accent')
sound('ui_select_blip_01', starts[13], 0.22, 'accent', event_id='balcony')
sound('sting_magic_sparkle_chime_01', starts[16], 0.55, 'accent', event_id='kiss')
sound('comedic_fail_low_tone_01', starts[17], 0.65, 'foley', event_id='morning')
sound('cartoon_pop_cluster_01', starts[19], 0.28, 'accent', event_id='truce')
sound('viral_whoosh', starts[20], 0.35, 'foley', event_id='five_years')
sound('viral_chime', starts[23], 0.65, 'accent', event_id='payoff')

# Direction brief and thought beats
brief = dict(
    promise="ADB introduces his girlfriend Nemi and reveals how a 2020 dorm party turned into five years together.",
    want="Tell the story of how they met without looking like an embarrassing nerd.",
    choice="Stay up arguing anime and thermodynamics until 4 AM on the balcony.",
    consequence="They realized they were inseparable, leading to their first sunrise kiss.",
    payoff="Five years later, she still wears his oversized hoodies and roasts his drawings.",
    beats=[dict(start=s['start'], end=s['end'], thought=s['id'], focus=s['background'], visual=f"Shot {s['id']}", intent="Story progression") for s in shots]
)

# Final Scene Specification (Version 2)
scene = dict(
    version=2,
    title="Meet My Girlfriend",
    duration=duration,
    fps=30,
    caption_size=48,
    direction=brief,
    actors=[adb_actor, nemi_actor],
    shots=shots,
    events=events,
    drawings=drawings,
    props=props,
    vfx=vfx,
    captions=captions,
    script=script,
    audio="res://renders/adb_meet_girlfriend/audio_r2/narration.wav",
    audio_metadata="res://renders/adb_meet_girlfriend/audio_r2/timeline.json",
    sfx=sfx
)

# Calibrate mixed audio
scene['mix'] = calibrate_mix(scene, ROOT)
(ep_dir / 'review/sfx_cues.json').write_text(json.dumps(sound_records, indent=2) + '\n')
(ep_dir / 'scene.json').write_text(json.dumps(scene, indent=2) + '\n')
print(f'Successfully built complete scene spec for EP02 Meet My Girlfriend!')
print(f'Duration: {duration}s | Shots: {len(shots)} | Props: {len(props)} | Drawings: {len(drawings)} | SFX: {len(sound_records)}')
