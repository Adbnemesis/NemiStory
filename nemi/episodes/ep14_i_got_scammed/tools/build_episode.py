#!/usr/bin/env python3
"""Build calibrated version-2 scene spec for EP14 I Got Scammed (R3, Conversational & Properly Scaled)."""
import json
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'tools/storytime'))

from validate_scene import validate
from audio_mix import calibrate_mix
from sfx_assets import validate_asset

EP = Path(__file__).resolve().parent.parent

# Load timing reference and source words
timing = json.loads((EP / 'timing_reference.json').read_text())
records = json.loads((EP / 'source_words.json').read_text())
duration = timing['duration']
words = timing['words']
clips = timing['clips']

# Group words by narrative line from source_words (records)
groups = []
word_offset = 0
for r in records:
    count = len(r['words'])
    groups.append(words[word_offset:word_offset + count])
    word_offset += count

starts = [g[0]['start'] for g in groups]
ends = [g[-1]['end'] for g in groups]

def key(line_idx, token):
    """Find start time of a word in a specific line."""
    tok = token.lower()
    for w in groups[line_idx]:
        clean = re.sub(r'[^a-z0-9]', '', w['word'].lower())
        if clean == tok:
            return w['start']
    for w in groups[line_idx]:
        clean = re.sub(r'[^a-z0-9]', '', w['word'].lower())
        if clean.startswith(tok):
            return w['start']
    print(f"WARNING: Token '{token}' not found in line {line_idx}, falling back to start")
    return starts[line_idx]

def art(kind, start, end, pos, scale=1.0, text=None, size=None, accent=False, layer=2):
    s_val = [scale, scale] if isinstance(scale, (int, float)) else scale
    e_time = round(min(duration - 0.01, end), 3)
    s_time = round(start, 3)
    if s_time >= e_time:
        s_time = max(0.0, round(e_time - 0.25, 3))
    d = {
        "author": "nemi",
        "kind": kind,
        "at": s_time,
        "end": e_time,
        "position": pos,
        "scale": s_val,
        "layer": layer
    }
    if text:
        d["text"] = text
    if size:
        d["size"] = size
    if accent:
        d["accent"] = True
    return d

focus = [
    "Admission: Common sense evaporating",
    "Tour Announcement & Obsession",
    "Drop Morning: Sold out in 12 seconds",
    "Denial: Buying in black",
    "Resale Forum: The VIP passes",
    "Private Investigator: Full FBI mode",
    "Smug Hubris: I am actually a genius",
    "The Trap: Five-minute urgency timer",
    "Panic Transfer: Savings sent",
    "The Block: Red exclamation mark",
    "Aftermath: Twelve dollars left",
    "Moral of the Story: Just stay home"
]

# 6 Cycling Environments across 12 Shots
backgrounds = [
    "nemi_creator_studio",
    "bedroom_evening_r4",
    "room",
    "thought",
    "lane_night_r4",
    "bedroom_evening_r4",
    "room",
    "evening",
    "thought",
    "lane_night_r4",
    "bedroom_evening_r4",
    "nemi_creator_studio"
]

# Framing: Alternating portrait and medium shots for dynamic visual rhythm
# Portrait: Nemi scale 1.75, pos [620, 570], cam center [620, 365], zoom 2.05
# Medium: Nemi scale 1.70, pos [680, 580], cam center [920, 505], zoom 1.28
frames = [
    "portrait",
    "medium",
    "medium",
    "portrait",
    "medium",
    "portrait",
    "medium",
    "portrait",
    "medium",
    "portrait",
    "medium",
    "portrait"
]

shots = []
beats = []

prev_shot_end = 0.0
for i in range(12):
    a = prev_shot_end
    b = duration if i == 11 else round(starts[i+1] - 0.15, 3)
    prev_shot_end = b
    s_id = f"shot_{i:02d}"
    
    # Camera staging and Actor placement matching EP11 R10 upper-middle balance
    if frames[i] == "portrait":
        cam = {"center": [620, 365], "zoom": 2.05}
        nemi_pos = [620, 570]
        nemi_scale = 1.75
    else:  # medium waist-up framing (no tiny doll, no visible floor legs)
        cam = {"center": [760, 420], "zoom": 1.60}
        nemi_pos = [540, 580]
        nemi_scale = 1.80
        
    shots.append({
        "id": s_id,
        "background": backgrounds[i],
        "start": a,
        "end": b,
        "camera": cam,
        "actors": {
            "nemi": {
                "position": nemi_pos,
                "scale": nemi_scale
            }
        }
    })
    
    beats.append({
        "thought": focus[i],
        "start": round(starts[i], 3),
        "end": round(ends[i], 3),
        "visual": f"{frames[i]}; {backgrounds[i]}",
        "focus": focus[i],
        "intent": f"Deliver beat {i+1} with high visual clarity and prominent character presence."
    })

# 38 Acting Performance Transitions (Eyes lead, brows shift, gestures settle)
performances = [
    # Shot 0: Admission (0.25 - 8.47s)
    {"at": 0.0, "recipe": "school_confide", "duration": 0.35, "gaze": [0.0, 0.0], "face": {"eye_openness": 0.95}},
    {"at": round(key(0, "common"), 3), "recipe": "explaining", "duration": 0.35, "gaze": [0.3, 0.0]},
    {"at": round(key(0, "badly") - 0.3, 3), "recipe": "soft_shrug", "duration": 0.35, "gaze": [-0.3, -0.15]},

    # Shot 1: Tour announcement (8.82 - 17.69s)
    {"at": round(starts[1], 3), "recipe": "pleased", "duration": 0.35, "gaze": [0.0, 0.0], "face": {"eye_openness": 1.05}},
    {"at": round(key(1, "city"), 3), "recipe": "school_point", "duration": 0.35, "gaze": [0.6, -0.1]},
    {"at": round(key(1, "emergency") - 0.5, 3), "recipe": "passenger_worried", "duration": 0.35, "gaze": [0.0, 0.1], "face": {"eye_openness": 1.15}},

    # Shot 2: Drop morning (18.05 - 28.19s)
    {"at": round(starts[2], 3), "recipe": "passenger_listening", "duration": 0.35, "gaze": [0.0, 0.1]},
    {"at": round(key(2, "laptops"), 3), "recipe": "passenger_worried", "duration": 0.35, "gaze": [0.2, 0.1]},
    {"at": round(key(2, "zero"), 3), "recipe": "passenger_deadpan", "duration": 0.35, "gaze": [0.0, 0.0]},
    {"at": round(key(2, "sold"), 3), "recipe": "school_recoil", "duration": 0.35, "gaze": [0.15, -0.1], "face": {"eye_openness": 1.25}},

    # Shot 3: Denial (28.59 - 42.22s)
    {"at": round(starts[3], 3), "recipe": "overwhelmed", "duration": 0.40, "gaze": [-0.2, 0.25]},
    {"at": round(key(3, "brain"), 3), "recipe": "realization", "duration": 0.35, "gaze": [0.0, -0.1], "face": {"eye_openness": 1.1}},
    {"at": round(key(3, "black"), 3), "recipe": "school_resolve", "duration": 0.35, "gaze": [0.0, 0.0], "face": {"pupil_scale": 1.15}},

    # Shot 4: Resale forum (42.57 - 52.68s)
    {"at": round(starts[4], 3), "recipe": "school_question", "duration": 0.35, "gaze": [0.45, -0.05]},
    {"at": round(key(4, "guy"), 3), "recipe": "skeptical", "duration": 0.35, "gaze": [0.65, -0.05]},
    {"at": round(key(4, "vip"), 3), "recipe": "prop_present", "duration": 0.35, "gaze": [0.35, 0.0]},

    # Shot 5: Full FBI mode (53.03 - 65.90s)
    {"at": round(starts[5], 3), "recipe": "school_resolve", "duration": 0.35, "gaze": [0.0, 0.0]},
    {"at": round(key(5, "smart"), 3), "recipe": "explaining", "duration": 0.35, "gaze": [0.3, 0.0]},
    {"at": round(key(5, "fbi"), 3), "recipe": "school_point", "duration": 0.35, "gaze": [0.6, 0.0]},

    # Shot 6: Smug genius (66.25 - 80.69s)
    {"at": round(starts[6], 3), "recipe": "pleased", "duration": 0.35, "gaze": [0.0, 0.0]},
    {"at": round(key(6, "matched"), 3), "recipe": "school_relief", "duration": 0.35, "gaze": [0.0, 0.0]},
    {"at": round(key(6, "genius"), 3), "recipe": "pleased", "duration": 0.35, "gaze": [0.0, 0.0], "face": {"eye_openness": 1.1}},

    # Shot 7: Urgency trap (81.09 - 96.51s)
    {"at": round(starts[7], 3), "recipe": "embarrassed", "duration": 0.35, "gaze": [-0.3, 0.2]},
    {"at": round(key(7, "texts"), 3), "recipe": "quiet_recoil", "duration": 0.35, "gaze": [0.0, -0.1]},
    {"at": round(key(7, "minutes"), 3), "recipe": "school_brace", "duration": 0.35, "gaze": [0.2, 0.1]},
    {"at": round(key(7, "gone"), 3), "recipe": "passenger_worried", "duration": 0.35, "gaze": [0.4, 0.15]},

    # Shot 8: Panic transfer (96.91 - 107.09s)
    {"at": round(starts[8], 3), "recipe": "uncertain", "duration": 0.35, "gaze": [0.0, 0.0]},
    {"at": round(key(8, "broke"), 3), "recipe": "school_shame", "duration": 0.40, "gaze": [-0.2, 0.3]},
    {"at": round(key(8, "send"), 3), "recipe": "school_brace", "duration": 0.35, "gaze": [0.0, 0.0]},

    # Shot 9: Shock & red exclamation (107.59 - 120.67s)
    {"at": round(starts[9], 3), "recipe": "school_relief", "duration": 0.35, "gaze": [0.0, 0.0]},
    {"at": round(key(9, "exclamation"), 3), "recipe": "school_recoil", "duration": 0.35, "gaze": [0.15, -0.08], "face": {"eye_openness": 1.25}},
    {"at": round(key(9, "message"), 3), "recipe": "school_gasp", "duration": 0.35, "gaze": [0.3, 0.0]},
    {"at": round(key(9, "found"), 3), "recipe": "deadpan", "duration": 0.0, "gaze": [0.0, 0.0]},

    # Shot 10: Blocked & $12 (121.32 - 132.78s)
    {"at": round(starts[10], 3), "recipe": "passenger_deadpan", "duration": 0.35, "gaze": [0.0, 0.0]},
    {"at": round(key(10, "blocked"), 3), "recipe": "overwhelmed", "duration": 0.45, "gaze": [-0.25, 0.3]},
    {"at": round(key(10, "account"), 3), "recipe": "deadpan", "duration": 0.50, "gaze": [0.0, 0.0]},

    # Shot 11: Moral & closing (133.53 - 151.42s)
    {"at": round(starts[11], 3), "recipe": "passenger_listening", "duration": 0.35, "gaze": [0.0, 0.1]},
    {"at": round(key(11, "paid"), 3), "recipe": "passenger_deadpan", "duration": 0.35, "gaze": [0.0, 0.0]},
    {"at": round(key(11, "home"), 3), "recipe": "soft_shrug", "duration": 0.40, "gaze": [0.0, 0.0]},
    {"at": round(key(11, "me"), 3), "recipe": "deadpan", "duration": 0.50, "gaze": [0.0, 0.0]}
]

# Script turns (strictly non-overlapping, with Nemi as actor)
script_turns = []
for i, r in enumerate(records):
    t_start = round(max(0.0, groups[i][0]['start'] - 0.02), 6)
    t_end = round(min(duration, groups[i][-1]['end'] + 0.02), 6)
    if script_turns and t_start <= script_turns[-1]['end']:
        t_start = round(script_turns[-1]['end'] + 0.005, 6)
        if t_end <= t_start:
            t_end = round(t_start + 0.05, 6)
    script_turns.append(dict(
        actor='nemi',
        start=t_start,
        end=t_end,
        text=r['text']
    ))

# Group words into cards (max 5 words, break on punctuation or pause)
raw_cards = []
offset = 0
for gi, group in enumerate(groups):
    card = []
    for j, w in enumerate(group):
        card.append((offset + j, w))
        pause = (j == len(group) - 1) or (group[j+1]['start'] - w['end'] >= 0.35)
        if len(card) == 5 or w['word'].endswith(('.', '?', '!', ':')) or pause:
            raw_cards.append(card)
            card = []
    offset += len(group)

# Build non-overlapping caption cards
captions = []
for i, card in enumerate(raw_cards):
    first = card[0][0]
    last = card[-1][0]
    sel = words[first:last+1]
    s0 = sel[0]['start']
    e1 = sel[-1]['end']
    s_next = raw_cards[i+1][0][1]['start'] if i + 1 < len(raw_cards) else duration
    slack = max(0.0, min(0.04, s_next - e1))
    c_start = s0
    c_end = e1 + slack
    c_text = ' '.join(v['word'] for _, v in card)
    captions.append({
        'actor': 'nemi',
        'words': [first, last],
        'start': round(c_start, 6),
        'end': round(c_end, 6),
        'text': c_text
    })

# Build mouth shapes strictly within turn bounds and non-overlapping
mouths = []
prev_mouth_end = 0.0
for gi, group in enumerate(groups):
    t_turn_start = script_turns[gi]['start']
    t_turn_end = script_turns[gi]['end']
    for j, w in enumerate(group):
        token = w['word'].lower().strip('.,?!"\'$:;')
        span = w['end'] - w['start']
        a = max(prev_mouth_end, max(t_turn_start, w['start'] + 0.005))
        b = min(t_turn_end, w['end'] - 0.005)
        if b - a > 0.04:
            if token.startswith(('m', 'b', 'p')) and span > 0.12 and (b - a > 0.08):
                c_end = round(a + 0.03, 6)
                mouths.append({'start': round(a, 6), 'end': c_end, 'shape': 'closed'})
                a = c_end
            shape = 'o_u' if re.search(r'oo|you|who|hope|more|know|four|two', token) else 'ae' if re.search(r'a|e|i', token) and len(token) > 2 else 'small_open'
            mid = min(b, a + 0.22)
            mouths.append({'start': round(a, 6), 'end': round(mid, 6), 'shape': shape})
            prev_mouth_end = round(mid, 6)
            if b - mid > 0.05:
                mouths.append({'start': round(mid, 6), 'end': round(b, 6), 'shape': 'small_open'})
                prev_mouth_end = round(b, 6)

# Drawings, Custom Props, and Live Doodles scaled properly with Nemi (scale 1.70-1.75)
drawings = [
    # Shot 0 (Portrait)
    art("tabs", starts[0] + 0.5, ends[0], [860, 320], 1.0),
    art("text", key(0, "common"), ends[0], [820, 480], 1.0, text="COMMON SENSE: 404", size=36, accent=True),
    art("scratch", key(0, "badly"), ends[0], [820, 480], 1.1),

    # Shot 1 (Medium)
    art("scam_concert_poster", starts[1] + 0.2, ends[1], [980, 380], 0.95),
    art("sparkle_stars", key(1, "tour"), ends[1], [980, 200], 1.0),
    art("text", key(1, "city"), ends[1], [980, 560], 1.0, text="1 NIGHT ONLY", size=40, accent=True),

    # Shot 2 (Medium)
    art("scam_sold_out_screen", starts[2] + 0.2, ends[2], [980, 380], 1.0),
    art("text", key(2, "sold"), ends[2], [980, 200], 1.0, text="SOLD OUT IN 12s", size=40, accent=True),

    # Shot 3 (Portrait)
    art("action_burst_mistake", key(3, "brain"), ends[3], [780, 320], 1.1),
    art("text", key(3, "black"), ends[3], [780, 450], 1.0, text="BUY IN BLACK", size=38, accent=True),
    art("underline", key(3, "black") + 0.3, ends[3], [780, 490], 1.1),

    # Shot 4 (Medium)
    art("scam_resale_listing", starts[4] + 0.2, ends[4], [980, 380], 1.0),
    art("arrow", key(4, "guy"), ends[4], [800, 380], 0.85),
    art("text", key(4, "vip"), ends[4], [980, 580], 1.0, text="2 VIP PASSES", size=40),

    # Shot 5 (Portrait)
    art("scam_detective_badge", starts[5] + 0.2, ends[5], [820, 320], 1.0),
    art("scam_sherlock_pipe", key(5, "smart"), ends[5], [440, 340], 0.9),
    art("text", key(5, "fbi"), ends[5], [820, 480], 1.0, text="FULL FBI MODE", size=38, accent=True),

    # Shot 6 (Medium)
    art("scam_concert_poster", starts[6] + 0.2, ends[6], [980, 380], 0.9),
    art("sparkle_stars", key(6, "matched"), ends[6], [980, 200], 1.0),
    art("text", key(6, "genius"), ends[6], [980, 580], 1.0, text="I'M A GENIUS", size=40, accent=True),

    # Shot 7 (Portrait)
    art("scam_urgency_timer", starts[7] + 0.2, ends[7], [820, 320], 1.05),
    art("sweat_drops", key(7, "texts"), ends[7], [480, 260], 1.0),
    art("text", key(7, "minutes"), ends[7], [820, 460], 1.0, text="5 MINUTES LEFT", size=36, accent=True),

    # Shot 8 (Medium)
    art("scam_bank_transfer", starts[8] + 0.2, ends[8], [980, 380], 1.0),
    art("text", key(8, "banking"), ends[8], [980, 580], 1.0, text="-300.00", size=44, accent=True),
    art("spark", key(8, "send"), ends[8], [980, 200], 1.0),

    # Shot 9 (Portrait punch)
    art("scam_blocked_alert", starts[9] + 0.2, ends[9], [620, 240], 1.1),
    art("text", key(9, "failed"), ends[9], [620, 480], 1.0, text="USER NOT FOUND", size=40, accent=True),

    # Shot 10 (Medium)
    art("scam_empty_wallet", starts[10] + 0.2, ends[10], [980, 380], 1.0),
    art("text", key(10, "account"), ends[10], [980, 580], 1.0, text="BALANCE: 12.00", size=40, accent=True),

    # Shot 11 (Portrait)
    art("desk", starts[11] - 0.1, duration, [620, 680], 1.4),
    art("mug", starts[11] + 0.2, duration, [780, 560], 1.0),
    art("scam_ghost_soul", key(11, "paid"), duration, [460, 280], 0.95),
    art("text", key(11, "home"), duration, [620, 460], 1.0, text="JUST STAY HOME", size=38, accent=True),
    art("underline", key(11, "me"), duration, [620, 500], 1.1)
]

# 18 Synchronized SFX Cues from Real Audio Inventory
sfx = [
    # Shot 0
    {"at": round(key(0, "badly"), 3), "file": "res://common/audio/sfx/click.mp3", "gain_db": -16.0},
    
    # Shot 1
    {"at": round(key(1, "tour"), 3), "file": "res://common/audio/sfx/chime.mp3", "gain_db": -18.0},
    {"at": round(key(1, "city"), 3), "file": "res://common/audio/sfx/ping.mp3", "gain_db": -16.0},

    # Shot 2
    {"at": round(key(2, "morning"), 3), "file": "res://common/audio/sfx/key-press.mp3", "gain_db": -18.0},
    {"at": round(key(2, "laptops"), 3), "file": "res://common/audio/sfx/click.mp3", "gain_db": -17.0},
    {"at": round(key(2, "zero"), 3), "file": "res://common/audio/sfx/clock-ticking.mp3", "gain_db": -20.0},
    {"at": round(key(2, "sold"), 3), "file": "res://common/audio/sfx/error.mp3", "gain_db": -15.0},

    # Shot 3
    {"at": round(key(3, "black"), 3), "file": "res://common/audio/sfx/ping.mp3", "gain_db": -16.0},

    # Shot 4
    {"at": round(key(4, "hunting"), 3), "file": "res://common/audio/sfx/notification.mp3", "gain_db": -18.0},

    # Shot 5
    {"at": round(key(5, "smart"), 3), "file": "res://common/audio/sfx/click.mp3", "gain_db": -18.0},
    {"at": round(key(5, "fbi"), 3), "file": "res://common/audio/sfx/chime.mp3", "gain_db": -18.0},

    # Shot 6
    {"at": round(key(6, "genius"), 3), "file": "res://common/audio/sfx/ping.mp3", "gain_db": -17.0},

    # Shot 7
    {"at": round(key(7, "texts"), 3), "file": "res://common/audio/sfx/notification.mp3", "gain_db": -17.0},
    {"at": round(key(7, "minutes"), 3), "file": "res://common/audio/sfx/clock-ticking.mp3", "gain_db": -19.0},

    # Shot 8
    {"at": round(key(8, "banking"), 3), "file": "res://common/audio/sfx/key-press.mp3", "gain_db": -18.0},
    {"at": round(key(8, "send"), 3), "file": "res://common/audio/sfx/click.mp3", "gain_db": -16.0},

    # Shot 9
    {"at": round(key(9, "exclamation"), 3), "file": "res://common/audio/sfx/error.mp3", "gain_db": -15.0},
    {"at": round(key(9, "failed"), 3), "file": "res://common/audio/sfx/bruh.mp3", "gain_db": -12.0},

    # Shot 10
    {"at": round(key(10, "account"), 3), "file": "res://common/audio/sfx/pop.mp3", "gain_db": -18.0},

    # Shot 11
    {"at": round(key(11, "home"), 3), "file": "res://common/audio/sfx/click.mp3", "gain_db": -18.0}
]

# Validate SFX assets
root_inv = json.loads((ROOT / 'common/audio/sfx/root_sfx_inventory.json').read_text())['assets']
inv_by_rel = {a['relative_path']: a for a in root_inv}

for s in sfx:
    rel = s['file'].removeprefix('res://')
    asset = inv_by_rel.get(rel)
    assert asset is not None, f"SFX {rel} not found in root inventory"
    validate_asset(asset, ROOT)
    s['duration'] = round(min(2.0, asset['duration_seconds']), 3)

# Construct scene spec
spec = {
    "version": 2,
    "title": "I Got Scammed",
    "duration": duration,
    "fps": 30,
    "caption_size": 42,
    "audio": "res://nemi/episodes/ep14_i_got_scammed/voice/narration.wav",
    "audio_metadata": "res://nemi/episodes/ep14_i_got_scammed/timing_reference.json",
    "direction": {
        "promise": "Understand how desperation and online ticket panic override common sense.",
        "want": "Get tickets to her favorite band's only tour date in the city.",
        "choice": "Trust a sketchy online reseller and pay money before receiving tickets.",
        "consequence": "The scammer takes the payment, deletes the listing, and blocks her instantly.",
        "payoff": "Face the empty bank account and share the hard-learned lesson to never buy in black.",
        "beats": beats
    },
    "shots": shots,
    "actors": [
        {
            "id": "nemi",
            "author": "nemi",
            "performances": performances,
            "mouths": mouths
        }
    ],
    "drawings": drawings,
    "captions": captions,
    "script": script_turns,
    "sfx": sfx
}

# Calibrate audio mix
spec['mix'] = calibrate_mix(spec, ROOT)

# Save scene.json
scene_path = EP / 'scene.json'
scene_path.write_text(json.dumps(spec, indent=2) + '\n')
print(f"Generated scene.json ({scene_path.stat().st_size} bytes)")

# Validate complete scene
validated = validate(scene_path)
print("VALIDATION PASSED 100%! Ready for Godot rendering.")
