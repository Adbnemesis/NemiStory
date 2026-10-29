"""EP13 Please Support Me (R3): Build full production scene on the shared v2 stage.
Fast opening, Discord games, and emphasized financial support (better device, family, independence).
"""
import json
import math
import re
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
    target = clean(phrase)
    found = [w['start'] for w in groups[i] if clean(w['word']) == target or target in clean(w['word'])]
    assert found, f"Line {i}: word '{phrase}' not found in {[w['word'] for w in groups[i]]}"
    return found[n]

def art(kind, a, b, pos, scale=1, **kw):
    if 'duration' in kw:
        max_dur = max(0.05, round((b - a) - 0.05, 3))
        kw['duration'] = round(min(kw['duration'], max_dur), 3)
    x = dict(author='nemi', kind=kind, at=round(a, 6), end=round(b, 6), position=pos, scale=[scale, scale], mode='hold')
    x.update(kw)
    return x

focus = [
    "Straight to the Point",
    "Drawing Until 3 AM",
    "The Lonely Animator Reality",
    "Introducing Nemi's Little Corner",
    "Play Games, Share Art & Chill",
    "Supporting Animations Financially",
    "Zero Pressure, Pure Gratitude",
    "Better Device, Family & Independence",
    "Links Below & See You Soon"
]

recipes_nemi = [
    "school_confide",
    "school_explain",
    "listening",
    "school_present",
    "explaining",
    "school_explain",
    "school_relief",
    "school_resolve",
    "school_present"
]

frames = [
    "portrait",
    "medium",
    "portrait",
    "medium",
    "medium",
    "portrait",
    "portrait",
    "medium",
    "portrait"
]

backgrounds = [
    "studio_nemi",
    "studio_nemi",
    "thought",
    "studio_nemi",
    "studio_nemi",
    "studio_nemi",
    "thought",
    "studio_nemi",
    "studio_nemi"
]

shots = []
perform_nemi = []
camera_plan = []
beats = []
props = []
drawings = []
events = []
vfx = []

def event(name, t, why):
    events.append(dict(id=name, at=round(t, 6), intent=why))
    return name

# Build 9 primary beat shots covering 0 to duration
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
    
    # Smooth subtle camera paths for pivotal beats
    if i == 0:
        cam['path'] = [
            dict(at=a, center=center, zoom=zoom),
            dict(at=round(a + 0.4, 6), center=center, zoom=zoom),
            dict(at=round(a + 1.8, 6), center=[620, 355], zoom=2.15)
        ]
    elif i == 3:  # Discord punch
        cam['path'] = [
            dict(at=a, center=center, zoom=zoom),
            dict(at=round(a + 0.5, 6), center=center, zoom=zoom),
            dict(at=round(a + 2.0, 6), center=[830, 490], zoom=1.35)
        ]
    elif i == 7:  # Family & independence resolve
        cam['path'] = [
            dict(at=a, center=center, zoom=zoom),
            dict(at=round(a + 0.5, 6), center=center, zoom=zoom),
            dict(at=round(a + 2.5, 6), center=[830, 490], zoom=1.32)
        ]
    elif i == 8:  # Final warm wave
        cam['path'] = [
            dict(at=a, center=center, zoom=zoom),
            dict(at=round(a + 0.6, 6), center=center, zoom=zoom),
            dict(at=round(a + 2.8, 6), center=[620, 355], zoom=2.12)
        ]

    # Actor placement in shot
    pos = [620, 570] if frames[i] == "portrait" else [620, 580]
    scale = 1.75 if frames[i] == "portrait" else 1.5
    shot_actors = {'nemi': dict(position=pos, scale=scale)}

    shots.append(dict(id=sid, start=a, end=b, background=bg, actors=shot_actors, camera=cam))
    camera_plan.append(dict(shot=sid, at=a, spoken_cue=groups[i][0]['word'], spoken_at=groups[i][0]['start'], focus=focus[i], framing=frames[i], camera=cam, reason=focus[i], finish='Settle and hold.'))
    
    # Nemi performance cue at beat start
    face = {'eye_openness': 0.96, 'pupil_scale': 1.0}
    if i in [0, 1]:
        face.update(left_brow_offset=[0, -1.2], right_brow_offset=[0, 0.8])
    elif i in [3, 4, 8]:
        face.update(left_brow_offset=[0, 1.2], right_brow_offset=[0, 1.2], pupil_scale=1.05)
    elif i in [5, 6, 7]:
        face.update(left_brow_offset=[0, 0.8], right_brow_offset=[0, 0.8], pupil_scale=1.02)
    
    b1 = round(min(a + 1.8, b - 0.35), 6)
    b2 = round(min(a + 4.5, b - 0.25), 6)
    blinks = [b1] if b1 < b2 else [b1]
    if b2 > b1 + 1.2 and b2 < b - 0.2:
        blinks.append(b2)
        
    gaze = [0, 0]
    if i in [0, 2]:
        gaze = [0.15, 0.08]
    elif i in [4, 6]:
        gaze = [0.0, 0.05]
        
    hands = {}
    if i in [0, 2]:
        hands = {'left': 'relaxed', 'right': 'relaxed'}
    elif i in [3, 8]:
        hands = {'left': 'relaxed', 'right': 'open_palm_up'}
    elif i == 6:
        hands = {'left': 'hand_to_mouth', 'right': 'relaxed'}
    elif i == 7:
        hands = {'left': 'hand_to_chest', 'right': 'open_palm_up'}
        
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
    (0, 'point', 'school_confide', [0.0, 0.0]),
    (1, 'drawing', 'school_point', [0.0, 0.0]),
    (1, 'desk', 'overwhelmed', [0.2, 0.1]),
    (2, 'lonely', 'soft_shrug', [0.15, 0.05]),
    (3, 'corner', 'pleased', [0.0, 0.05]),
    (4, 'games', 'pleased', [0.0, 0.0]),
    (4, 'art', 'school_relief', [0.0, 0.0]),
    (4, 'quietly', 'pleased', [0.0, 0.05]),
    (5, 'financially', 'school_confide', [0.0, 0.05]),
    (5, 'coffee', 'school_explain', [0.1, 0.05]),
    (6, 'watching', 'school_relief', [0.0, 0.05]),
    (6, 'world', 'pleased', [0.0, 0.0]),
    (7, 'device', 'school_point', [0.0, 0.0]),
    (7, 'family', 'school_confide', [0.0, 0.05]),
    (7, 'independent', 'school_resolve', [0.0, 0.0]),
    (8, 'below', 'school_present', [0.0, 0.1]),
    (8, 'story', 'pleased', [0.0, 0.0])
]

for li, w, r, g in nemi_reactions:
    t = key(li, w)
    perform_nemi.append(dict(
        at=round(t, 6),
        recipe=r,
        duration=0.38,
        gaze=g,
        blinks=[],
        hands={'left': 'relaxed', 'right': 'open_palm_up'} if r in ['school_present', 'pleased', 'school_resolve'] else {}
    ))

# Clean and sort performances
perform_nemi.sort(key=lambda c: c['at'])
for j, c in enumerate(perform_nemi):
    lim = perform_nemi[j+1]['at'] if j+1 < len(perform_nemi) else duration
    c['duration'] = round(min(c['duration'], max(0, lim - c['at'] - 0.001)), 6)
    c['blinks'] = [round(b, 6) for b in c.get('blinks', []) if c['at'] <= b and b + 0.14 <= lim]

# Props and Drawings (Held art, live ink)
# Beat 0: Desk setup & candid opener
props.append(art('desk', shots[0]['start'], shots[0]['end'], [1260, 717], 1.0, layer=0, shots=['beat_00']))
props.append(art('laptop', shots[0]['start'], shots[0]['end'], [1160, 640], 0.85, layer=0, shots=['beat_00']))
drawings.append(art('text', round(key(0, 'straight'), 6), shots[0]['end'], [1080, 260], text='straight to the point', size=50, mode='live', duration=1.0, shots=['beat_00']))

# Beat 1: Drawing until 3 AM (Fast & snappy)
props.append(art('desk', shots[1]['start'], shots[1]['end'], [1260, 717], 1.0, layer=0, shots=['beat_01']))
props.append(art('creator_draft_choices', shots[1]['start'], shots[1]['end'], [1240, 560], 0.9, layer=0, shots=['beat_01']))
drawings.append(art('text', round(key(1, 'drawing'), 6), shots[1]['end'], [1140, 260], text='3:00 AM', size=56, mode='live', duration=1.0, shots=['beat_01']))
drawings.append(art('scratch', round(key(1, 'desk'), 6), shots[1]['end'], [1240, 560], 1.0, mode='live', duration=0.6, shots=['beat_01']))

# Beat 2: The lonely animator reality
props.append(art('desk', shots[2]['start'], shots[2]['end'], [1260, 717], 1.0, layer=0, shots=['beat_02']))
props.append(art('mug', shots[2]['start'], shots[2]['end'], [1180, 640], 1.1, layer=0, shots=['beat_02']))
drawings.append(art('circle', round(key(2, 'lonely'), 6), shots[2]['end'], [1240, 320], 1.2, mode='live', duration=0.6, shots=['beat_02']))

# Beat 3: Introducing Nemi's Little Corner
props.append(art('creator_upload', shots[3]['start'], shots[3]['end'], [1240, 560], 0.9, layer=0, shots=['beat_03']))
drawings.append(art('text', round(key(3, 'corner'), 6), shots[3]['end'], [1040, 260], text="NEMI'S CORNER", size=54, mode='live', duration=1.2, accent=True, shots=['beat_03']))
drawings.append(art('spark', round(key(3, 'corner') + 0.3, 6), shots[3]['end'], [1260, 240], 1.3, mode='live', duration=0.6, shots=['beat_03']))

# Beat 4: Play games, share art & chill
props.append(art('creator_story_pages', shots[4]['start'], shots[4]['end'], [1180, 550], 0.95, layer=0, shots=['beat_04']))
drawings.append(art('text', round(key(4, 'games'), 6), shots[4]['end'], [1080, 260], text='games & art', size=50, mode='live', duration=1.0, shots=['beat_04']))
drawings.append(art('spark', round(key(4, 'quietly'), 6), shots[4]['end'], [1240, 280], 1.2, mode='live', duration=0.6, shots=['beat_04']))

# Beat 5: Supporting animations financially
props.append(art('desk', shots[5]['start'], shots[5]['end'], [1260, 717], 1.0, layer=0, shots=['beat_05']))
props.append(art('mug', shots[5]['start'], shots[5]['end'], [1180, 640], 1.15, layer=0, shots=['beat_05']))
drawings.append(art('text', round(key(5, 'financially'), 6), shots[5]['end'], [1080, 260], text='SUPPORT ME', size=54, mode='live', duration=1.0, accent=True, shots=['beat_05']))
drawings.append(art('circle', round(key(5, 'coffee'), 6), shots[5]['end'], [1180, 640], 1.2, mode='live', duration=0.8, shots=['beat_05']))

# Beat 6: Zero pressure & heartfelt gratitude
props.append(art('creator_comment', shots[6]['start'], shots[6]['end'], [1180, 540], 1.0, layer=0, shots=['beat_06']))
drawings.append(art('text', round(key(6, 'watching'), 6), shots[6]['end'], [1100, 260], text='thank you! <3', size=52, mode='live', duration=0.9, accent=True, shots=['beat_06']))
drawings.append(art('spark', round(key(6, 'world'), 6), shots[6]['end'], [1240, 230], 1.2, mode='live', duration=0.6, shots=['beat_06']))

# Beat 7: Better device, family & independence
props.append(art('desk', shots[7]['start'], shots[7]['end'], [1260, 717], 1.0, layer=0, shots=['beat_07']))
props.append(art('creator_draft_choices', shots[7]['start'], shots[7]['end'], [1240, 560], 0.9, layer=0, shots=['beat_07']))
drawings.append(art('text', round(key(7, 'device'), 6), shots[7]['end'], [1080, 240], text='better device', size=48, mode='live', duration=0.8, shots=['beat_07']))
drawings.append(art('text', round(key(7, 'family'), 6), shots[7]['end'], [1040, 310], text='family & independent', size=48, mode='live', duration=1.0, accent=True, shots=['beat_07']))
drawings.append(art('underline', round(key(7, 'independent'), 6), shots[7]['end'], [1180, 380], 1.2, mode='live', duration=0.6, shots=['beat_07']))

# Beat 8: Links below & see you soon
props.append(art('desk', shots[8]['start'], shots[8]['end'], [1260, 717], 1.0, layer=0, shots=['beat_08']))
props.append(art('laptop', shots[8]['start'], shots[8]['end'], [1160, 640], 0.85, layer=0, shots=['beat_08']))
drawings.append(art('arrow', round(key(8, 'below'), 6), shots[8]['end'], [1160, 480], 1.2, mode='live', duration=0.8, shots=['beat_08']))
drawings.append(art('text', round(key(8, 'below'), 6), shots[8]['end'], [1080, 250], text='links below!', size=50, mode='live', duration=0.8, shots=['beat_08']))
drawings.append(art('text', round(key(8, 'story'), 6), shots[8]['end'], [1060, 330], text='see you soon!', size=52, mode='live', duration=0.6, accent=True, shots=['beat_08']))

# Ensure overlays are layered above held props
for item in drawings:
    if item['kind'] in {'circle', 'scratch', 'spark', 'arrow', 'underline', 'text'}:
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
            shape = 'o_u' if re.search(r'oo|you|who|hope|more|know|four|two|coffee', token) else 'ae' if re.search(r'a|e|i', token) and len(token) > 2 else 'small_open'
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
voice_audio = pcm(EP / 'voice/narration_r3.wav')
sounds = []
sound_detail = []

# Choices: (line_idx, word_key, asset_id, duration, prominence, rationale)
sfx_choices = [
    (0, 'point', 'ui_click_tactile_01', 0.22, 'surface', 'Opening tactile click on straight to the point'),
    (1, 'drawing', 'drawing_pencil_sketch_01', 0.85, 'surface', 'Drawing frames by hand pencil sketch'),
    (1, 'morning', 'cartoon_pop_dry_01', 0.35, 'accent', '3 AM punchy comedic pop'),
    (2, 'lonely', 'impact_glass_tap_01', 0.45, 'surface', 'Late night room mug tap on desk'),
    (3, 'discord', 'viral_notification', 1.0, 'accent', 'Discord server announcement chime'),
    (3, 'corner', 'whoosh_fast_transition_01', 0.45, 'accent', 'Nemi Little Corner punch whoosh'),
    (4, 'games', 'ui_click_tactile_02', 0.25, 'surface', 'Play games with us tactile click'),
    (4, 'art', 'paper_page_turn_crisp_01', 0.45, 'surface', 'Sharing art page turn'),
    (4, 'quietly', 'ui_confirm_chime_01', 0.65, 'accent', 'Chill quietly welcoming chime'),
    (5, 'financially', 'impact_glass_clink_01', 0.55, 'accent', 'Support financially toast clink'),
    (5, 'coffee', 'whoosh_air_clean_01', 0.4, 'surface', 'Ko-fi page clean transition whoosh'),
    (6, 'watching', 'ui_confirm_chime_03', 0.8, 'accent', 'Warm gratitude chime for viewers'),
    (6, 'world', 'sting_magic_sparkle_chime_01', 0.85, 'accent', 'Means the world heartwarming sparkle'),
    (7, 'device', 'drawing_pencil_write_short_01', 0.6, 'surface', 'Better device for animation pencil tap'),
    (7, 'independent', 'sting_achievement_bell_01', 0.95, 'accent', 'Independent & supporting family achievement bell'),
    (8, 'below', 'whoosh_air_clean_01', 0.4, 'surface', 'Pointing down to description arrow'),
    (8, 'story', 'ui_confirm_chime_01', 0.65, 'accent', 'Warm concluding chime for next story')
]

for li, w, aid, length, prom, why in sfx_choices:
    t = key(li, w)
    length = min(length, max(0.1, round(duration - t - 0.05, 3)))
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
    audio='res://' + str((EP / 'voice/narration_r3.wav').relative_to(ROOT)),
    audio_metadata='res://' + str((EP / 'timing_reference.json').relative_to(ROOT)),
    direction=dict(
        promise="Straightforward, honest chat with Nemi about making animations solo, her Discord, and supporting her financially on Ko-fi.",
        want="Connect with viewers, build a cozy Discord community with games & art, upgrade her animation device, support her family, and become independent.",
        choice="Cut the fluff, be candid about the 3 AM grind, and invite viewers to Nemi's Little Corner and optional Ko-fi support.",
        consequence="A concise, deeply sincere ~1-minute video that feels personal, candid, and zero-pressure.",
        payoff="A clear, warm connection leaving the audience excited for the next story and knowing exactly how to support her.",
        beats=beats
    ),
    actors=[
        dict(id='nemi', author='nemi', performances=perform_nemi, mouths=mouths)
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

print(f"READY: {duration:.2f}s, {len(shots)} shots, {len(perform_nemi)} Nemi cues, {len(sounds)} SFX")
