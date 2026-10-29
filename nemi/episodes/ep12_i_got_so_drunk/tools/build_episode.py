"""EP12 I Got So Drunk: Build full production scene on the shared v2 stage."""
import json
import math
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'tools/storytime'))

from audio_mix import calibrate_mix
from sfx_assets import validate_asset
from sfx_levels import choose_gain, pcm
from validate_scene import validate

EP = Path(__file__).resolve().parent.parent

# Load source words, story, and timing reference
records = json.loads((EP / 'source_words.json').read_text())
story = json.loads((EP / 'story.json').read_text())
timeline = json.loads((EP / 'timing_reference.json').read_text())

# Frame-aligned duration (exact 30 fps boundary)
duration = math.ceil(timeline['duration'] * 30) / 30
words = timeline['words']

# Count words per line from source_words
line_word_counts = []
for idx, r in enumerate(records):
    raw_w = r['words']
    cleaned = []
    prev_end = 0.0
    for w in raw_w:
        ws = max(round(w['start'], 3), prev_end)
        we = round(max(w['end'], ws + 0.04), 3)
        cleaned.append(w['word'].strip())
        prev_end = we
    line_word_counts.append(len(cleaned))

assert sum(line_word_counts) == len(words), f"{sum(line_word_counts)} != {len(words)}"

offset = 0
groups = []
starts = []
ends = []
for count in line_word_counts:
    grp = words[offset:offset+count]
    groups.append(grp)
    starts.append(grp[0]['start'])
    ends.append(grp[-1]['end'])
    offset += count

def key(i, phrase, n=0):
    clean = lambda x: re.sub(r'\W', '', x.lower())
    found = [w['start'] for w in groups[i] if clean(w['word']) == clean(phrase)]
    assert found, f"Line {i}: word '{phrase}' not found in {[w['word'] for w in groups[i]]}"
    return found[n]

def art(kind, a, b, pos, scale=1, **kw):
    x = dict(author='nemi', kind=kind, at=round(a, 6), end=round(b, 6), position=pos, scale=[scale, scale], mode='hold')
    x.update(kw)
    return x

focus = [
    "The Friday Confession Hook",
    "Two Friends and False Responsibility",
    "The Two Bottles Vodka Pre-Game",
    "Arrival at ADB's Living Room",
    "Chinese Takeout and Shot Glasses",
    "ADB Calm vs Ascending Dimension",
    "The Drunk Pictionary Warning",
    "The Depressed Potato-Horse Debate",
    "The 11 PM Clubbing Eureka",
    "Inside the Club: Floor Bass & Bar Shots",
    "Dancing Like Rent Is Due",
    "3 AM Carpet Gaming Session",
    "5 AM: The Vodka Collects Its Debt",
    "The Cold Porcelain Bowl Epiphany",
    "The Morning Hangover: 10/10 Never Again"
]

recipes_nemi = [
    "explaining",
    "pleased",
    "school_point",
    "school_explain",
    "school_present",
    "school_confide",
    "skeptical",
    "embarrassed",
    "realization",
    "school_gasp",
    "school_resolve",
    "quiet_recoil",
    "school_brace",
    "school_shame",
    "deadpan"
]

frames = [
    "portrait",
    "medium",
    "medium",
    "wide",
    "medium",
    "wide",
    "medium",
    "medium",
    "portrait",
    "wide",
    "medium",
    "wide",
    "portrait",
    "medium",
    "portrait"
]

backgrounds = [
    "studio_nemi",
    "studio_nemi",
    "studio_nemi",
    "studio_adb",
    "studio_adb",
    "studio_adb",
    "studio_adb",
    "studio_adb",
    "thought",
    "adb_dorm_party",
    "adb_dorm_party",
    "room",
    "thought",
    "paper",
    "room"
]

shots = []
perform_nemi = []
perform_adb = []
camera_plan = []
beats = []
props = []
drawings = []
events = []
vfx = []

def event(name, t, why):
    events.append(dict(id=name, at=round(t, 6), intent=why))
    return name

# Build 15 primary beat shots covering 0 to duration
for i in range(len(records)):
    a = 0.0 if i == 0 else round(starts[i] - 0.12, 6)
    b = duration if i == len(records) - 1 else round(starts[i+1] - 0.12, 6)
    sid = f"beat_{i:02d}"
    
    bg = backgrounds[i]
    if frames[i] == "portrait":
        center, zoom = [620, 365], 2.05
    elif frames[i] == "medium":
        center, zoom = [860, 505], 1.25
    else:
        center, zoom = [960, 530], 1.08
        
    cam = dict(center=center, zoom=zoom)
    
    # Smooth subtle camera paths for pivotal emotional/comedic beats
    if i == 0:
        cam['path'] = [
            dict(at=a, center=center, zoom=zoom),
            dict(at=round(a + 0.8, 6), center=center, zoom=zoom),
            dict(at=round(a + 2.2, 6), center=[620, 355], zoom=2.15)
        ]
    elif i == 12: # 5 AM room spin
        cam['path'] = [
            dict(at=a, center=center, zoom=zoom),
            dict(at=round(a + 0.6, 6), center=center, zoom=zoom),
            dict(at=round(a + 2.5, 6), center=[645, 375], zoom=2.0)
        ]
    elif i == 14: # Morning verdict
        cam['path'] = [
            dict(at=a, center=center, zoom=zoom),
            dict(at=round(a + 0.8, 6), center=center, zoom=zoom),
            dict(at=round(a + 3.0, 6), center=[620, 355], zoom=2.12)
        ]

    # Actors placement in shot
    if i in [3, 4, 5, 6, 7]:
        # Living room two-shot: Nemi and ADB
        shot_actors = {
            'nemi': dict(position=[480, 580], scale=1.45),
            'adb': dict(position=[860, 580], scale=1.45)
        }
    else:
        # Solitary Nemi
        pos = [620, 570] if frames[i] == "portrait" else [620, 580]
        scale = 1.75 if frames[i] == "portrait" else 1.5
        shot_actors = {'nemi': dict(position=pos, scale=scale)}

    shots.append(dict(id=sid, start=a, end=b, background=bg, actors=shot_actors, camera=cam))
    camera_plan.append(dict(shot=sid, at=a, spoken_cue=groups[i][0]['word'], spoken_at=groups[i][0]['start'], focus=focus[i], framing=frames[i], camera=cam, reason=focus[i], finish='Settle and hold.'))
    
    # Nemi performance cue at beat start
    face = {'eye_openness': 0.96, 'pupil_scale': 1.0}
    if i in [0, 6, 7, 12]:
        face.update(left_brow_offset=[0, -1.5], right_brow_offset=[0, 0.8])
    elif i == 13:
        face.update(left_brow_offset=[0, -2.5], right_brow_offset=[0, 2.5], eye_openness=0.6, pupil_scale=0.8)
    
    b1 = round(min(a + 2.2, b - 0.35), 6)
    b2 = round(min(a + 5.5, b - 0.25), 6)
    blinks = [b1] if b1 < b2 else [b1]
    if b2 > b1 + 1.2 and b2 < b - 0.2:
        blinks.append(b2)
        
    gaze = [0, 0]
    if i in [5, 6, 12]:
        gaze = [0.25, 0.1]
    elif i == 13:
        gaze = [0.15, 0.25]
        
    hands = {}
    if i in [0, 3, 4]:
        hands = {'left': 'relaxed', 'right': 'open_palm_up'}
    elif i == 13:
        hands = {'left': 'hand_to_mouth', 'right': 'relaxed'}
        
    perform_nemi.append(dict(
        at=a,
        recipe=recipes_nemi[i],
        duration=0.45,
        gaze=gaze,
        face=face,
        blinks=blinks,
        hands=hands
    ))
    
    beats.append(dict(
        start=a,
        end=b,
        thought=focus[i],
        focus=focus[i],
        visual=f"{frames[i]}; {bg}",
        intent=f"Let the audience register {focus[i].lower()}."
    ))

# Exact-word Nemi reactions inside thoughts (tied to narrative turns)
nemi_reactions = [
    (0, 'decisions', 'realization', [0, 0]),
    (1, 'responsible', 'soft_shrug', [0.2, -0.1]),
    (2, 'start', 'deadpan', [0, 0]),
    (3, 'starving', 'overwhelmed', [0, 0.1]),
    (4, 'shots', 'prop_present', [0.2, 0]),
    (5, 'dimension', 'overwhelmed', [0.3, -0.1]),
    (6, 'it', 'school_confide', [0, 0]),
    (7, 'toaster', 'school_recoil', [-0.2, 0]),
    (7, 'minutes', 'deadpan', [0, 0]),
    (8, 'earth', 'school_explain', [0, 0]),
    (9, 'bar', 'school_question', [0.2, 0]),
    (10, 'disaster', 'overwhelmed', [0, 0.1]),
    (11, 'carpet', 'school_relief', [0, 0]),
    (12, 'carousel', 'overwhelmed', [0.2, 0.1]),
    (13, 'dinner', 'quiet_recoil', [0.15, 0.2]),
    (14, 'again', 'school_confide', [0, 0])
]

for li, w, r, g in nemi_reactions:
    t = key(li, w)
    perform_nemi.append(dict(
        at=round(t, 6),
        recipe=r,
        duration=0.38,
        gaze=g,
        blinks=[],
        hands={'left': 'relaxed', 'right': 'relaxed'} if r in ['deadpan', 'school_relief'] else {}
    ))

# ADB performance cues (must start at at=0, and cover living room presence)
adb_cues = [
    (0.0, 'listening', 0.35, [0, 0]),
    (starts[3], 'listening', 0.4, [-0.3, 0]),
    (key(3, 'choices'), 'weight_shift', 0.4, [-0.25, 0]),
    (starts[4], 'prop_present', 0.4, [-0.3, 0]),
    (starts[5], 'deadpan', 0.45, [0, 0]), # ADB completely calm while others ascend
    (key(5, 'calm'), 'dry_annoyance', 0.4, [-0.2, 0]),
    (starts[6], 'skeptical', 0.4, [-0.35, 0.05]),
    (starts[7], 'dry_annoyance', 0.4, [-0.3, 0]), # looking at potato horse
    (key(7, 'toaster'), 'self_impressed', 0.4, [0, 0]) # someone screamed toaster
]

for t, r, d, g in adb_cues:
    perform_adb.append(dict(
        at=round(t, 6),
        recipe=r,
        duration=d,
        gaze=g,
        blinks=[round(t + 1.5, 6)] if t + 2.0 < duration else []
    ))

# Clean and sort performances
perform_nemi.sort(key=lambda c: c['at'])
for j, c in enumerate(perform_nemi):
    lim = perform_nemi[j+1]['at'] if j+1 < len(perform_nemi) else duration
    c['duration'] = round(min(c['duration'], max(0, lim - c['at'] - 0.001)), 6)
    c['blinks'] = [round(b, 6) for b in c.get('blinks', []) if c['at'] <= b and b + 0.14 <= lim]

perform_adb.sort(key=lambda c: c['at'])
for j, c in enumerate(perform_adb):
    lim = perform_adb[j+1]['at'] if j+1 < len(perform_adb) else duration
    c['duration'] = round(min(c['duration'], max(0, lim - c['at'] - 0.001)), 6)
    c['blinks'] = [round(b, 6) for b in c.get('blinks', []) if c['at'] <= b and b + 0.14 <= lim]

# Props and Drawings (Held art, live ink)
# Beat 0: Desk in Nemi's room
props.append(art('desk', shots[0]['start'], shots[0]['end'], [1260, 717], 1.0, layer=0, shots=['beat_00']))
drawings.append(art('text', round(key(0, 'friday'), 6), shots[0]['end'], [1080, 260], text='Friday 8 PM', size=50, shots=['beat_00']))

# Beat 1: Two friends arrive at Nemi's place (Nemi storytelling about friends)
drawings.append(art('text', round(key(1, 'friends'), 6), shots[1]['end'], [1140, 260], text='chill night', size=52, mode='live', duration=1.2, shots=['beat_01']))

# Beat 2: Two bottles of vodka pre-game (desk with bottles + side characters appearing specifically for the 3 people)
props.append(art('desk', shots[2]['start'], shots[2]['end'], [1260, 717], 1.0, layer=0, shots=['beat_02']))
props.append(art('school_friend', round(key(2, 'bottles'), 6), shots[2]['end'], [280, 890], 1.3, layer=0, shots=['beat_02']))
props.append(art('school_classmate_laugh', round(key(2, 'bottles'), 6), shots[2]['end'], [920, 890], 1.3, layer=0, shots=['beat_02']))
props.append(art('red_cup', round(key(2, 'bottles'), 6), shots[2]['end'], [1200, 715], 1.1, shots=['beat_02']))
drawings.append(art('text', round(key(2, 'bottles'), 6), shots[2]['end'], [1140, 260], text='vodka x 2', size=58, mode='live', duration=1.25, shots=['beat_02']))

# Beat 3: ADB's living room - 6 people total crammed in (Nemi, ADB, plus 4 friends)
props.append(art('school_friend_smile', shots[3]['start'], shots[3]['end'], [180, 890], 1.25, layer=0, shots=['beat_03']))
props.append(art('school_classmate', shots[3]['start'], shots[3]['end'], [320, 890], 1.25, layer=0, shots=['beat_03']))
props.append(art('school_classmate_laugh', shots[3]['start'], shots[3]['end'], [1140, 890], 1.25, layer=0, shots=['beat_03']))
props.append(art('school_friend_laugh', shots[3]['start'], shots[3]['end'], [1320, 890], 1.25, layer=0, shots=['beat_03']))
drawings.append(art('text', round(key(3, 'people'), 6), shots[3]['end'], [1220, 260], text='6 people total', size=48, shots=['beat_03']))

# Beat 4: Chinese takeout mountain & vodka shots on ADB's table
props.append(art('lunch_box', shots[4]['start'], shots[4]['end'], [670, 660], 1.1, layer=0, shots=['beat_04']))
props.append(art('red_cup', round(key(4, 'shots'), 6), shots[4]['end'], [750, 630], 0.85, shots=['beat_04']))
drawings.append(art('text', round(key(4, 'takeout'), 6), shots[4]['end'], [1200, 260], text='takeout mountain', size=46, shots=['beat_04']))

# Beat 5: Ascending dimension while ADB sits calm
ev_dim = event('dimension_spark', key(5, 'dimension'), 'Ascending to another dimension')
vfx.append(dict(kind='realization', author='nemi', actor='nemi', offset=[90, -65], at=round(key(5, 'dimension'), 6), end=round(key(5, 'dimension') + 1.0, 6), shots=['beat_05'], strength=0.5, event=ev_dim))

# Beat 6: Pictionary warning with ADB
props.append(art('notebook', shots[6]['start'], shots[6]['end'], [1280, 570], 1.2, shots=['beat_06']))
drawings.append(art('text', round(key(6, 'blasted'), 6), shots[6]['end'], [1180, 260], text='DO NOT DO IT', size=52, mode='live', duration=1.0, shots=['beat_06']))

# Beat 7: Potato horse debate & ADB staring at sketch
props.append(art('potato_chart', round(key(7, 'horse'), 6), shots[7]['end'], [1320, 530], 1.1, shots=['beat_07']))
drawings.append(art('text', round(key(7, 'horse'), 6), round(key(7, 'toaster'), 6), [1260, 260], text='horse??', size=54, mode='live', duration=1.0, shots=['beat_07']))
drawings.append(art('scratch', round(key(7, 'toaster'), 6), shots[7]['end'], [1320, 530], 1.0, mode='live', duration=0.6, shots=['beat_07']))
drawings.append(art('text', round(key(7, 'toaster'), 6), shots[7]['end'], [1280, 320], text='toaster!', size=54, accent=True, shots=['beat_07']))

# Beat 8: 11 PM Clubbing
ev_club = event('club_eureka', key(8, 'clubbing'), 'The drunken epiphany to go clubbing')
vfx.append(dict(kind='realization', author='nemi', actor='nemi', offset=[88, -68], at=round(key(8, 'clubbing'), 6), end=round(key(8, 'clubbing') + 1.1, 6), shots=['beat_08'], strength=0.6, event=ev_club))
drawings.append(art('text', round(key(8, 'clubbing'), 6), shots[8]['end'], [1080, 300], text='CLUBBING!', size=66, mode='live', duration=1.2, shots=['beat_08']))
drawings.append(art('spark', round(key(8, 'clubbing') + 0.3, 6), shots[8]['end'], [1260, 230], 1.2, mode='live', duration=0.6, shots=['beat_08']))

# Beat 9: Club floor bass & bar shots
props.append(art('red_cup', round(key(9, 'shots'), 6), shots[9]['end'], [950, 620], 1.1, shots=['beat_09']))
drawings.append(art('text', round(key(9, 'floor'), 6), shots[9]['end'], [1160, 260], text='BASS', size=62, shots=['beat_09']))
ev_bass = event('club_bass', key(9, 'floor'), 'Sub bass vibrating through the floor')
vfx.append(dict(kind='impact', author='nemi', actor='nemi', offset=[85, -60], at=round(key(9, 'floor'), 6), end=round(key(9, 'floor') + 0.8, 6), shots=['beat_09'], strength=0.55, event=ev_bass))

# Beat 10: Dancing like rent is due
drawings.append(art('spark', round(key(10, 'dance'), 6), shots[10]['end'], [980, 340], 1.35, mode='live', duration=0.7, shots=['beat_10']))
ev_hair = event('hair_disaster', key(10, 'disaster'), 'Hair disaster after chaotic dancing')
vfx.append(dict(kind='sweat', author='nemi', actor='nemi', offset=[90, -68], at=round(key(10, 'disaster'), 6), end=round(key(10, 'disaster') + 0.85, 6), shots=['beat_10'], strength=0.5, event=ev_hair))

# Beat 11: 3 AM carpet gaming
props.append(art('laptop', shots[11]['start'], shots[11]['end'], [800, 780], 0.9, layer=0, shots=['beat_11']))
drawings.append(art('text', round(key(11, '3am'), 6), shots[11]['end'], [1160, 260], text='3:00 AM', size=52, shots=['beat_11']))

# Beat 12: 5 AM room spin debt
props.append(art('confusion_marks', round(key(12, 'room'), 6), shots[12]['end'], [720, 340], 1.1, shots=['beat_12']))
props.append(art('sweat_drops', round(key(12, 'room'), 6), shots[12]['end'], [530, 360], 1.0, layer=2, shots=['beat_12']))
drawings.append(art('circle', round(key(12, 'room'), 6), shots[12]['end'], [1080, 360], 1.4, mode='live', duration=1.2, shots=['beat_12']))
ev_dizzy = event('room_spin', key(12, 'carousel'), 'Room starts spinning like a carousel')
vfx.append(dict(kind='tension', author='nemi', actor='nemi', offset=[92, -68], at=round(key(12, 'carousel'), 6), end=round(key(12, 'carousel') + 1.2, 6), shots=['beat_12'], strength=0.6, event=ev_dizzy))

# Beat 13: Bathroom porcelain bowl aftermath (medium framing: toilet, tissues, takeout container, sick sweat & live doodles)
props.append(art('porcelain_bowl', shots[13]['start'], shots[13]['end'], [940, 720], 1.1, layer=0, shots=['beat_13']))
props.append(art('tissue_box', round(key(13, 'bathroom'), 6), shots[13]['end'], [1140, 750], 0.95, layer=0, shots=['beat_13']))
props.append(art('lunch_box', round(key(13, 'bathroom'), 6), shots[13]['end'], [1240, 740], 0.9, layer=0, shots=['beat_13']))
props.append(art('sweat_drops', round(key(13, 'bathroom'), 6), shots[13]['end'], [530, 360], 1.05, layer=2, shots=['beat_13']))
drawings.append(art('text', round(key(13, 'bathroom'), 6), shots[13]['end'], [980, 230], text='5:30 AM', size=48, mode='live', duration=0.8, shots=['beat_13']))
drawings.append(art('scratch', round(key(13, 'bowl'), 6), shots[13]['end'], [940, 620], 1.0, mode='live', duration=0.6, shots=['beat_13']))
drawings.append(art('text', round(key(13, 'lost'), 6), shots[13]['end'], [980, 310], text='RIP NOODLES', size=50, mode='live', duration=0.8, accent=True, shots=['beat_13']))
ev_sick = event('lost_dinner', key(13, 'dinner'), 'Losing dinner to the porcelain bowl')
vfx.append(dict(kind='tears', author='nemi', actor='nemi', offset=[88, -65], at=round(key(13, 'dinner'), 6), end=round(min(shots[13]['end'], key(13, 'dinner') + 0.4), 6), shots=['beat_13'], strength=0.5, event=ev_sick))

# Beat 14: Morning hangover verdict
props.append(art('mug', shots[14]['start'], shots[14]['end'], [1120, 630], 1.0, shots=['beat_14']))
drawings.append(art('text', round(key(14, 'night'), 6), shots[14]['end'], [1100, 310], text='10 / 10', size=64, mode='live', duration=1.1, accent=True, shots=['beat_14']))
drawings.append(art('text', round(key(14, 'again'), 6), shots[14]['end'], [1060, 420], text='never again', size=48, mode='live', duration=0.8, shots=['beat_14']))

# Ensure overlays are layered above held props
for item in drawings:
    if item['kind'] in {'circle', 'scratch', 'spark', 'text'}:
        item['layer'] = 3

# Captions (at most 5 words per card, strictly non-overlapping, indexing word spans)
captions = []
mouths = []
offset = 0
prev_caption_end = 0.0
prev_mouth_end = 0.0

for gi, group in enumerate(groups):
    card = []
    for j, w in enumerate(group):
        card.append((offset + j, w))
        pause = (j == len(group) - 1) or (group[j+1]['start'] - w['end'] >= 0.35)
        if len(card) == 5 or w['word'].endswith(('.', '?', '!', ':')) or pause:
            c_start = max(prev_caption_end, card[0][1]['start'])
            c_end = max(c_start + 0.04, card[-1][1]['end'])
            c_text = ' '.join(v['word'] for _, v in card)
            captions.append(dict(
                actor='nemi',
                words=[card[0][0], card[-1][0]],
                start=round(c_start, 6),
                end=round(c_end, 6),
                text=c_text
            ))
            prev_caption_end = c_end
            card = []
            
        token = w['word'].lower().strip('.,?!\"\':;')
        span = w['end'] - w['start']
        a = max(prev_mouth_end, w['start'] + 0.01)
        b = w['end'] - 0.015
        if b - a > 0.04:
            if token.startswith(('m', 'b', 'p')) and span > 0.12 and (b - a > 0.08):
                c_end = round(a + 0.03, 5)
                mouths.append(dict(start=round(a, 5), end=c_end, shape='closed'))
                a = c_end
            shape = 'o_u' if re.search(r'oo|you|who|hope|more|know|four|two|vodka', token) else 'ae' if re.search(r'a|e|i', token) and len(token) > 2 else 'small_open'
            mid = min(b, a + 0.22)
            mouths.append(dict(start=round(a, 5), end=round(mid, 5), shape=shape))
            prev_mouth_end = round(mid, 5)
            if b - mid > 0.05:
                mouths.append(dict(start=round(mid, 5), end=round(b, 5), shape='small_open'))
                prev_mouth_end = round(b, 5)
                
    offset += len(group)

# Sound design & calibration
assets = json.loads((ROOT / 'common/audio/sfx/sfx_catalog.json').read_text())['assets']
palette = {a['id']: a for a in assets}
voice_audio = pcm(EP / 'voice/narration.wav')
sounds = []
sound_detail = []

# Choices: (line_idx, word_key, asset_id, duration, prominence, rationale)
sfx_choices = [
    (0, 'decisions', 'ui_click_tactile_01', 0.22, 'surface', 'Friday evening decision hook'),
    (1, 'friends', 'ui_confirm_chime_03', 0.8, 'accent', 'College friends arrival warmth'),
    (2, 'bottles', 'impact_glass_tap_01', 0.45, 'surface', 'Setting down vodka bottles on desk'),
    (2, 'pre', 'food_glasses_clinking_01', 0.65, 'accent', 'Pre-game clinking toast'),
    (3, 'choices', 'movement_footstep_wood_01', 0.35, 'surface', 'Packing up and walking'),
    (3, 'place', 'impact_wood_tap_01', 0.3, 'surface', 'Entering ADB apartment'),
    (4, 'takeout', 'paper_slide_desk_01', 0.65, 'surface', 'Chinese takeout boxes sliding onto coffee table'),
    (4, 'shots', 'food_glasses_clinking_01', 0.65, 'accent', 'Pouring and clinking shot glasses'),
    (5, 'multiplying', 'food_drink_quick_sip_01', 0.4, 'surface', 'Taking another shot'),
    (5, 'dimension', 'sting_magic_sparkle_chime_01', 0.9, 'accent', 'Ascending to another dimension'),
    (6, 'dictionary', 'paper_page_flip_01', 0.76, 'surface', 'Flipping open the Pictionary pad'),
    (6, 'blasted', 'impact_generic_light_01', 0.3, 'surface', 'Comedic warning emphasis'),
    (7, 'draw', 'drawing_scratch_scribble_01', 0.85, 'surface', 'Live drawing the potato horse'),
    (7, 'toaster', 'cartoon_pop_dry_01', 0.35, 'accent', 'Someone screams toaster revelation'),
    (7, 'argued', 'comedic_record_scratch_01', 0.55, 'accent', 'Arguing for ten straight minutes'),
    (8, '11', 'reaction_female_gasp_surprised_01', 0.45, 'accent', 'Sudden 11 PM clubbing impulse'),
    (8, 'clubbing', 'whoosh_fast_transition_01', 0.65, 'accent', 'Transitioning out to the club'),
    (9, 'floor', 'impact_cinematic_deep_whoosh_01', 1.1, 'accent', 'Sub bass vibrating through the club floor'),
    (9, 'shots', 'food_glasses_clinking_01', 0.65, 'surface', 'Taking shots at the club bar'),
    (10, 'dance', 'whoosh_air_clean_01', 0.5, 'accent', 'Hitting the dance floor with rent-due energy'),
    (10, 'disaster', 'impact_generic_light_01', 0.3, 'surface', 'Hair disaster recoil'),
    (11, 'house', 'impact_drop_soft_01', 0.5, 'surface', 'Slumping down onto the carpet at 3 AM'),
    (11, 'games', 'computer_mouse_click_multi_01', 0.4, 'surface', 'Booting up video games on the floor'),
    (12, 'debt', 'comedic_record_slowdown_01', 0.95, 'accent', 'Vodka collecting its 5 AM debt'),
    (12, 'carousel', 'suspense_glass_hit_cinematic_01', 0.8, 'accent', 'Room starts spinning like a carousel'),
    (13, 'sprinted', 'reaction_female_gasp_astonished_01', 0.5, 'accent', 'Sprinting to the bathroom in panic'),
    (13, 'bowl', 'impact_generic_light_02', 0.35, 'surface', 'Gripping the cold porcelain bowl'),
    (14, 'sunrise', 'food_water_pour_01', 0.9, 'surface', 'Morning hangover water glass poured'),
    (14, 'night', 'ui_confirm_chime_03', 0.8, 'accent', 'Immortal 10 out of 10 verdict chime'),
    (14, 'again', 'paper_book_close_01', 0.5, 'surface', 'Final quiet closure: never doing it again')
]

for li, w, aid, length, prom, why in sfx_choices:
    t = key(li, w)
    asset = palette[aid]
    path = validate_asset(asset, ROOT)
    gain, levels = choose_gain(path, voice_audio, t, length, prom)
    ev = event(f"sfx_{li}_{w}_{aid}", t, why)
    sounds.append(dict(
        file='res://' + asset['relative_path'],
        at=round(t, 6),
        duration=length,
        gain_db=gain,
        event=ev
    ))
    sound_detail.append(dict(
        beat=li,
        at=round(t, 6),
        spoken_cue=w,
        id=aid,
        source=asset['source'],
        license=asset['license'],
        reason=why,
        gain_db=gain,
        duration=length,
        **levels
    ))

# Script turns (strictly non-overlapping, with Nemi as actor)
script_turns = []
for i, r in enumerate(records):
    t_start = round(max(0.0, groups[i][0]['start'] - 0.02), 6)
    t_end = round(min(duration, groups[i][-1]['end'] + 0.02), 6)
    script_turns.append(dict(
        actor='nemi',
        start=t_start,
        end=t_end,
        text=r['text']
    ))

# Build spec v2
spec = dict(
    version=2,
    title=story['title'],
    duration=duration,
    fps=30,
    caption_size=52,
    audio='res://' + str((EP / 'voice/narration.wav').relative_to(ROOT)),
    audio_metadata='res://' + str((EP / 'timing_reference.json').relative_to(ROOT)),
    direction=dict(
        promise="Understand how a supposedly 'chill' Friday night with college friends and ADB spiraled into legendary drunken chaos.",
        want="Have a relaxed, responsible night catching up with friends.",
        choice="Pre-game two full bottles of vodka, order Chinese takeout, take vodka shots, play drunken Pictionary, go clubbing, and play games until sunrise.",
        consequence="Each stop escalates the chaos until the room spins at 5 AM and dinner is lost to the bathroom porcelain.",
        payoff="A comatose twelve-hour recovery sleep, a skull-crushing hangover, and the immortal storytime conclusion: 'Ten out of ten night. Never doing it again.'",
        beats=beats
    ),
    actors=[
        dict(id='nemi', author='nemi', performances=perform_nemi, mouths=mouths),
        dict(id='adb', author='adb', performances=perform_adb)
    ],
    shots=shots,
    drawings=drawings,
    props=props,
    events=events,
    vfx=vfx,
    sfx=sounds,
    script=script_turns,
    captions=captions
)

spec['mix'] = calibrate_mix(spec, ROOT)

# Save scene.json
scene_path = EP / 'scene.json'
scene_path.write_text(json.dumps(spec, indent=2) + '\n')
print(f"scene.json saved to {scene_path}")

# Validate scene
validate(scene_path)
print("Scene validation passed 100%!")

# Save plans and documentation
(EP / 'camera_plan.json').write_text(json.dumps(camera_plan, indent=2) + '\n')
(EP / 'sound_plan.json').write_text(json.dumps(dict(
    cues=sound_detail,
    beats=[dict(beat=i, thought=f, choice=next((x['reason'] for x in sound_detail if x['beat']==i), 'Silent comedic hold')) for i, f in enumerate(focus)],
    policy='No BGM; existing recordings only; no meme commentary.'
), indent=2) + '\n')

print(f"READY: {duration:.2f}s, {len(shots)} shots, {len(perform_nemi)} Nemi cues, {len(perform_adb)} ADB cues, {len(sounds)} SFX")
