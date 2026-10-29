"""Build complete EP18 Giveaway Announcement scene.json from prepared audio and direction."""
import json
import sys
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
F = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

prepared = F / 'audio/prepared_r5'
timeline = json.loads((prepared / 'timeline.json').read_text())
words = timeline['words']
duration = 40.0

# 1. Direction and Thought Beats
direction = {
    "promise": "Nemi excites the community with a high-energy, hilarious Halloween giveaway announcement.",
    "want": "Reward true community members with personalized, hand-crafted artwork and channel recognition.",
    "choice": "Deliver clear rules with playful comedic banter ('no shadow clones or burner alts!') so it feels like a real creator event.",
    "consequence": "Hyped community participation, clean fair entries, and active Discord introductions.",
    "payoff": "A joyful, memorable storytime community celebration full of warmth and festive Halloween cheer.",
    "beats": [
        {
            "start": 0.0,
            "end": 5.40,
            "thought": "Stop scrolling hook",
            "focus": "Direct enthusiastic eye contact and welcoming announcement wave",
            "visual": "nemi_creator_studio; energetic portrait",
            "intent": "Immediately hook the audience and establish the Halloween giveaway."
        },
        {
            "start": 5.40,
            "end": 18.10,
            "thought": "Drum roll & 3 Spooky Prizes",
            "focus": "Comedic anticipation buildup leading to excited fanfare unveiling the 3 prizes",
            "visual": "nemi_creator_studio; wide creator staging with tablet and prize popups",
            "intent": "Build dramatic, playful tension before unveiling the three creative gifts."
        },
        {
            "start": 18.10,
            "end": 24.10,
            "thought": "Frictionless steps to enter",
            "focus": "Dynamic checklist: Discord, introductions, YouTube sub, DMs open",
            "visual": "nemi_creator_studio; engaging community checklist",
            "intent": "Give clear, frictionless instructions for entering."
        },
        {
            "start": 24.10,
            "end": 33.40,
            "thought": "The rules & shadow clones comedy",
            "focus": "Close-up squint into the camera lens with playful suspicion and urgency timer",
            "visual": "nemi_creator_studio; intimate comedic close-up",
            "intent": "Enforce fair rules with genuine humor and character personality."
        },
        {
            "start": 33.40,
            "end": 40.00,
            "thought": "Warm Halloween sendoff",
            "focus": "Beaming smile, two-handed wave, floating hearts and sparkles",
            "visual": "nemi_creator_studio; warm festive wide",
            "intent": "Leave the community hyped, happy, and wishing everyone good luck."
        }
    ]
}

# 2. Events
events = [
    {"id": "ev_pop_intro", "at": 0.20, "intent": "Audible pop for announcement opener"},
    {"id": "ev_reveal_giveaway", "at": 2.30, "intent": "Chime reveal for Halloween theme"},
    {"id": "ev_drumroll_rise", "at": 6.90, "intent": "Riser buildup for dramatic drumroll"},
    {"id": "ev_fanfare_prizes", "at": 9.00, "intent": "Fanfare bells for the 3 prizes"},
    {"id": "ev_prize_pfp", "at": 11.15, "intent": "Chime for custom PFP reveal"},
    {"id": "ev_prize_doodle", "at": 13.65, "intent": "Chime for spooky doodle reveal"},
    {"id": "ev_prize_shoutout", "at": 16.35, "intent": "Chime for channel shoutout reveal"},
    {"id": "ev_req_discord", "at": 18.50, "intent": "Pop cue for Discord checklist item"},
    {"id": "ev_req_youtube", "at": 21.60, "intent": "Pop cue for YouTube sub checklist item"},
    {"id": "ev_rules_warn", "at": 28.15, "intent": "Comedy error accent for shadow clones rule"},
    {"id": "ev_rules_clock", "at": 31.20, "intent": "Ticking clock for 48 hours countdown"},
    {"id": "ev_outro_cheer", "at": 38.00, "intent": "Celebratory bells for happy Halloween outro"}
]

# 3. Shots (Cut boundaries placed strictly during silent inter-clip pauses)
shots = [
    {
        "id": "shot_01_hook",
        "start": 0.0,
        "end": 5.40,
        "background": "nemi_creator_studio",
        "actors": {
            "nemi": {"position": [620, 580], "scale": 1.7}
        },
        "camera": {"center": [620, 370], "zoom": 1.65}
    },
    {
        "id": "shot_02_prizes",
        "start": 5.40,
        "end": 18.10,
        "background": "nemi_creator_studio",
        "actors": {
            "nemi": {"position": [460, 580], "scale": 1.6}
        },
        "camera": {"center": [960, 500], "zoom": 1.05}
    },
    {
        "id": "shot_03_requirements",
        "start": 18.10,
        "end": 24.10,
        "background": "nemi_creator_studio",
        "actors": {
            "nemi": {"position": [460, 580], "scale": 1.6}
        },
        "camera": {"center": [960, 500], "zoom": 1.05}
    },
    {
        "id": "shot_04_rules",
        "start": 24.10,
        "end": 33.40,
        "background": "nemi_creator_studio",
        "actors": {
            "nemi": {"position": [480, 580], "scale": 1.6}
        },
        "camera": {"center": [960, 500], "zoom": 1.08}
    },
    {
        "id": "shot_05_outro",
        "start": 33.40,
        "end": 40.00,
        "background": "nemi_creator_studio",
        "actors": {
            "nemi": {"position": [960, 580], "scale": 1.7}
        },
        "camera": {"center": [960, 480], "zoom": 1.3}
    }
]

# 4. Performances
performances = [
    # Shot 1: Hook (0.0 - 5.40)
    {
        "at": 0.0,
        "recipe": "pleased",
        "motion": "snap",
        "gaze": [0.0, 0.0],
        "hands": {"left": "relaxed", "right": "relaxed"},
        "face": {"eye_openness": 1.15, "pupil_scale": 1.1}
    },
    {
        "at": 0.20,
        "recipe": "school_gasp",
        "motion": "snap",
        "gaze": [0.0, -0.1],
        "hands": {"left": "open_palm_up", "right": "splayed_fingers"}
    },
    {
        "at": 2.29,
        "recipe": "pleased",
        "motion": "snap",
        "gaze": [0.1, 0.0],
        "hands": {"left": "hand_to_chest", "right": "open_palm_up"}
    },
    # Shot 2: Prizes & Drumroll (5.40 - 18.10)
    {
        "at": 5.40,
        "recipe": "lean_in",
        "motion": "snap",
        "gaze": [0.0, 0.0],
        "hands": {"left": "open_palm_up", "right": "open_palm_up"}
    },
    {
        "at": 6.90,
        "recipe": "school_brace",
        "motion": "snap",
        "gaze": [0.0, -0.2],
        "hands": {"left": "hands_together", "right": "hands_together"},
        "face": {"eye_openness": 0.2, "pupil_scale": 0.9}
    },
    {
        "at": 9.00,
        "recipe": "prop_present",
        "motion": "snap",
        "gaze": [0.35, 0.0],
        "hands": {"left": "open_palm_up", "right": "pointing"}
    },
    {
        "at": 11.15,
        "recipe": "school_point",
        "motion": "snap",
        "gaze": [0.4, -0.1],
        "hands": {"left": "relaxed", "right": "finger_count_one"}
    },
    {
        "at": 13.65,
        "recipe": "prop_present",
        "motion": "snap",
        "gaze": [0.4, 0.0],
        "hands": {"left": "open_palm_up", "right": "finger_count_two"}
    },
    {
        "at": 16.35,
        "recipe": "pleased",
        "motion": "snap",
        "gaze": [0.3, 0.0],
        "hands": {"left": "finger_count_three", "right": "open_palm_up"}
    },
    # Shot 3: Requirements (18.10 - 24.10)
    {
        "at": 18.10,
        "recipe": "explaining",
        "motion": "snap",
        "gaze": [0.3, 0.1],
        "hands": {"left": "open_palm_up", "right": "open"}
    },
    {
        "at": 18.74,
        "recipe": "school_explain",
        "motion": "snap",
        "gaze": [0.35, 0.0],
        "hands": {"left": "relaxed", "right": "pointing"}
    },
    {
        "at": 20.30,
        "recipe": "school_explain",
        "motion": "snap",
        "gaze": [0.35, 0.1],
        "hands": {"left": "open_palm_up", "right": "relaxed"}
    },
    {
        "at": 21.63,
        "recipe": "school_point",
        "motion": "snap",
        "gaze": [0.35, 0.0],
        "hands": {"left": "relaxed", "right": "pointing"}
    },
    {
        "at": 22.93,
        "recipe": "lean_in",
        "motion": "snap",
        "gaze": [0.1, 0.0],
        "hands": {"left": "open_palm_up", "right": "open_palm_up"}
    },
    # Shot 4: Rules (24.10 - 33.40)
    {
        "at": 24.10,
        "recipe": "school_resolve",
        "motion": "snap",
        "gaze": [0.0, 0.0],
        "hands": {"left": "relaxed", "right": "finger_count_one"}
    },
    {
        "at": 28.14,
        "recipe": "skeptical",
        "motion": "snap",
        "gaze": [0.35, 0.0],
        "hands": {"left": "relaxed", "right": "pointing"},
        "face": {"eye_openness": 0.65, "pupil_scale": 0.85}
    },
    {
        "at": 31.07,
        "recipe": "school_resolve",
        "motion": "snap",
        "gaze": [0.3, 0.0],
        "hands": {"left": "finger_count_two", "right": "relaxed"}
    },
    # Shot 5: Outro (33.40 - 40.00)
    {
        "at": 33.40,
        "recipe": "soft_shrug",
        "motion": "snap",
        "gaze": [0.0, 0.0],
        "hands": {"left": "open_palm_up", "right": "open_palm_up"}
    },
    {
        "at": 35.21,
        "recipe": "school_relief",
        "motion": "snap",
        "gaze": [0.0, 0.0],
        "hands": {"left": "open", "right": "open"},
        "face": {"eye_openness": 1.2, "pupil_scale": 1.15}
    },
    {
        "at": 38.00,
        "recipe": "pleased",
        "motion": "snap",
        "gaze": [0.0, 0.0],
        "hands": {"left": "open_palm_up", "right": "open_palm_up"}
    },
    {
        "at": 39.00,
        "recipe": "pleased",
        "motion": "smooth",
        "duration": 0.4,
        "gaze": [0.0, 0.0],
        "hands": {"left": "relaxed", "right": "relaxed"}
    }
]

# 5. Script (Spoken Turns)
script = []
for i, c in enumerate(timeline['clips']):
    ww = [w for w in words if c['at'] <= w['start'] < c['end_at'] + 0.05]
    t_start = round(c['at'], 3)
    next_at = timeline['clips'][i + 1]['at'] if i + 1 < len(timeline['clips']) else duration
    t_end = min(next_at - 0.02, round(c['end_at'] + 0.04, 3))
    script.append({
        "actor": "nemi",
        "start": t_start,
        "end": t_end,
        "text": ' '.join(w['word'] for w in ww)
    })

# 6. Mouths
mouths = []
for turn in script:
    turn_words = [w for w in words if turn['start'] - 0.01 <= w['start'] < turn['end']]
    prev_m_end = turn['start']
    for w in turn_words:
        w_text = w['word'].lower().strip('.,!?":;')
        start = max(prev_m_end, round(w['start'], 3))
        end = min(turn['end'], round(w['end'], 3))
        if end <= start + 0.02:
            continue
        
        if any(k in w_text for k in ['scrol', 'offici', 'pfp', 'ghost', 'spook']):
            shape = 'open_excited'
        elif any(k in w_text for k in ['prize', 'three', 'guy', 'hi', 'alts', 'find', 'claim']):
            shape = 'wide'
        elif any(k in w_text for k in ['hal', 'amaz', 'doodl', 'youtub', 'happi']):
            shape = 'smile_wide'
        elif any(k in w_text for k in ['drum', 'rule', 'two', 'you', 'who', 'hour']):
            shape = 'o_u'
        elif any(k in w_text for k in ['enter', 'intro', 'subscri', 'everi']):
            shape = 'ae'
        else:
            shape = 'small_open'
            
        mouths.append({
            "start": round(start, 3),
            "end": round(end, 3),
            "shape": shape
        })
        prev_m_end = round(end, 3)

# 7. Props
props = [
    {
        "author": "nemi",
        "kind": "sparkle_stars",
        "position": [780, 240],
        "scale": [0.8, 0.8],
        "at": 0.20,
        "end": 5.30,
        "mode": "hold",
        "layer": 3,
        "shots": ["shot_01_hook"]
    },
    {
        "author": "nemi",
        "kind": "embarrassed_tablet_work",
        "position": [1350, 620],
        "scale": [0.75, 0.75],
        "at": 5.50,
        "end": 18.00,
        "mode": "hold",
        "layer": 2,
        "shots": ["shot_02_prizes"]
    },
    {
        "author": "nemi",
        "kind": "school_chat_phone",
        "position": [1420, 480],
        "scale": [0.65, 0.65],
        "at": 18.20,
        "end": 24.00,
        "mode": "hold",
        "layer": 2,
        "shots": ["shot_03_requirements"]
    },
    {
        "author": "nemi",
        "kind": "confusion_marks",
        "position": [440, 260],
        "scale": [0.85, 0.85],
        "at": 28.14,
        "end": 31.00,
        "mode": "hold",
        "layer": 3,
        "shots": ["shot_04_rules"]
    },
    {
        "author": "nemi",
        "kind": "scam_urgency_timer",
        "position": [1400, 480],
        "scale": [0.7, 0.7],
        "at": 31.00,
        "end": 33.30,
        "mode": "hold",
        "layer": 3,
        "shots": ["shot_04_rules"]
    },
    {
        "author": "nemi",
        "kind": "sparkle_stars",
        "position": [660, 240],
        "scale": [0.7, 0.7],
        "at": 33.50,
        "end": 40.00,
        "mode": "hold",
        "layer": 3,
        "shots": ["shot_05_outro"]
    },
    {
        "author": "nemi",
        "kind": "heart_doodle",
        "position": [1260, 240],
        "scale": [0.8, 0.8],
        "at": 35.00,
        "end": 40.00,
        "mode": "hold",
        "layer": 3,
        "shots": ["shot_05_outro"]
    }
]

# 8. Drawings (Authored Inking & Lettering)
drawings = [
    # Shot 1: Giveaway Hook
    {
        "author": "nemi",
        "kind": "text",
        "position": [280, 120],
        "at": 2.30,
        "duration": 0.35,
        "end": 5.30,
        "size": 32,
        "text": "HALLOWEEN GIVEAWAY!",
        "accent": True,
        "mode": "live",
        "layer": 4,
        "shots": ["shot_01_hook"]
    },
    # Shot 2: The 3 Prizes
    {
        "author": "nemi",
        "kind": "text",
        "position": [780, 240],
        "at": 9.00,
        "duration": 0.35,
        "end": 18.00,
        "size": 36,
        "text": "3 HALLOWEEN PRIZES!",
        "accent": True,
        "mode": "live",
        "layer": 4,
        "shots": ["shot_02_prizes"]
    },
    {
        "author": "nemi",
        "kind": "underline",
        "position": [980, 275],
        "scale": [1.4, 1.0],
        "at": 9.25,
        "duration": 0.25,
        "end": 18.00,
        "accent": True,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_02_prizes"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [780, 340],
        "at": 11.15,
        "duration": 0.3,
        "end": 18.00,
        "size": 30,
        "text": "- 1. CUSTOM PFP",
        "accent": False,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_02_prizes"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [780, 430],
        "at": 13.65,
        "duration": 0.3,
        "end": 18.00,
        "size": 30,
        "text": "- 2. SPOOKY DOODLE",
        "accent": False,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_02_prizes"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [780, 520],
        "at": 16.35,
        "duration": 0.3,
        "end": 18.00,
        "size": 30,
        "text": "- 3. CHANNEL SHOUTOUT",
        "accent": False,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_02_prizes"]
    },
    {
        "author": "nemi",
        "kind": "spark",
        "position": [1240, 520],
        "scale": [1.2, 1.2],
        "at": 16.55,
        "duration": 0.2,
        "end": 18.00,
        "accent": True,
        "mode": "live",
        "layer": 4,
        "shots": ["shot_02_prizes"]
    },
    # Shot 3: The 4 Requirements
    {
        "author": "nemi",
        "kind": "text",
        "position": [760, 240],
        "at": 18.35,
        "duration": 0.35,
        "end": 24.00,
        "size": 36,
        "text": "HOW TO ENTER:",
        "accent": True,
        "mode": "live",
        "layer": 4,
        "shots": ["shot_03_requirements"]
    },
    {
        "author": "nemi",
        "kind": "underline",
        "position": [900, 275],
        "scale": [1.2, 1.0],
        "at": 18.60,
        "duration": 0.25,
        "end": 24.00,
        "accent": True,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_03_requirements"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [760, 330],
        "at": 18.75,
        "duration": 0.3,
        "end": 24.00,
        "size": 28,
        "text": "- JOIN NEMI DISCORD",
        "accent": False,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_03_requirements"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [760, 410],
        "at": 20.30,
        "duration": 0.3,
        "end": 24.00,
        "size": 28,
        "text": "- SAY HI IN INTROS",
        "accent": False,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_03_requirements"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [760, 490],
        "at": 21.65,
        "duration": 0.3,
        "end": 24.00,
        "size": 28,
        "text": "- SUBSCRIBE ON YOUTUBE",
        "accent": False,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_03_requirements"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [760, 570],
        "at": 22.95,
        "duration": 0.3,
        "end": 24.00,
        "size": 28,
        "text": "- KEEP YOUR DMS OPEN",
        "accent": False,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_03_requirements"]
    },
    {
        "author": "nemi",
        "kind": "arrow",
        "position": [1200, 570],
        "scale": [0.9, 0.9],
        "at": 23.10,
        "duration": 0.2,
        "end": 24.00,
        "accent": True,
        "mode": "live",
        "layer": 4,
        "shots": ["shot_03_requirements"]
    },
    # Shot 4: Rules & Warning
    {
        "author": "nemi",
        "kind": "text",
        "position": [780, 240],
        "at": 24.30,
        "duration": 0.3,
        "end": 33.30,
        "size": 36,
        "text": "FAIR RULES:",
        "accent": True,
        "mode": "live",
        "layer": 4,
        "shots": ["shot_04_rules"]
    },
    {
        "author": "nemi",
        "kind": "underline",
        "position": [890, 275],
        "scale": [1.1, 1.0],
        "at": 24.50,
        "duration": 0.25,
        "end": 33.30,
        "accent": True,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_04_rules"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [780, 330],
        "at": 25.45,
        "duration": 0.3,
        "end": 33.30,
        "size": 28,
        "text": "- 1 ENTRY PER PERSON",
        "accent": False,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_04_rules"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [780, 410],
        "at": 28.15,
        "duration": 0.3,
        "end": 33.30,
        "size": 30,
        "text": "- NO SHADOW CLONES!",
        "accent": True,
        "mode": "live",
        "layer": 4,
        "shots": ["shot_04_rules"]
    },
    {
        "author": "nemi",
        "kind": "text",
        "position": [780, 490],
        "at": 31.05,
        "duration": 0.3,
        "end": 33.30,
        "size": 28,
        "text": "- 48 HOURS TO CLAIM",
        "accent": False,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_04_rules"]
    },
    # Shot 5: Outro
    {
        "author": "nemi",
        "kind": "text",
        "position": [640, 130],
        "at": 38.00,
        "duration": 0.35,
        "end": 40.00,
        "size": 38,
        "text": "HAPPY HALLOWEEN!",
        "accent": True,
        "mode": "live",
        "layer": 4,
        "shots": ["shot_05_outro"]
    },
    {
        "author": "nemi",
        "kind": "circle",
        "position": [960, 130],
        "scale": [3.2, 1.2],
        "at": 38.30,
        "duration": 0.3,
        "end": 40.00,
        "accent": True,
        "mode": "live",
        "layer": 3,
        "shots": ["shot_05_outro"]
    }
]

# 9. SFX Cues (all from root inventory common/audio/sfx/)
sfx = [
    {
        "file": "res://common/audio/sfx/pop.mp3",
        "at": 0.20,
        "duration": 0.8,
        "gain_db": -6.0,
        "event": "ev_pop_intro"
    },
    {
        "file": "res://common/audio/sfx/chime.mp3",
        "at": 2.30,
        "duration": 1.2,
        "gain_db": -8.0,
        "event": "ev_reveal_giveaway"
    },
    {
        "file": "res://common/audio/sfx/riser.mp3",
        "at": 6.90,
        "duration": 1.6,
        "gain_db": -6.0,
        "event": "ev_drumroll_rise"
    },
    {
        "file": "res://common/audio/sfx/stings/sting_happy_bells_01.wav",
        "at": 9.00,
        "duration": 1.5,
        "gain_db": -7.0,
        "event": "ev_fanfare_prizes"
    },
    {
        "file": "res://common/audio/sfx/chime.mp3",
        "at": 11.15,
        "duration": 1.0,
        "gain_db": -8.0,
        "event": "ev_prize_pfp"
    },
    {
        "file": "res://common/audio/sfx/chime.mp3",
        "at": 13.65,
        "duration": 1.0,
        "gain_db": -8.0,
        "event": "ev_prize_doodle"
    },
    {
        "file": "res://common/audio/sfx/chime.mp3",
        "at": 16.35,
        "duration": 1.0,
        "gain_db": -8.0,
        "event": "ev_prize_shoutout"
    },
    {
        "file": "res://common/audio/sfx/pop.mp3",
        "at": 18.50,
        "duration": 0.8,
        "gain_db": -7.0,
        "event": "ev_req_discord"
    },
    {
        "file": "res://common/audio/sfx/pop.mp3",
        "at": 21.60,
        "duration": 0.8,
        "gain_db": -7.0,
        "event": "ev_req_youtube"
    },
    {
        "file": "res://common/audio/sfx/error.mp3",
        "at": 28.15,
        "duration": 1.2,
        "gain_db": -8.0,
        "event": "ev_rules_warn"
    },
    {
        "file": "res://common/audio/sfx/clock-ticking.mp3",
        "at": 31.20,
        "duration": 1.8,
        "gain_db": -9.0,
        "event": "ev_rules_clock"
    },
    {
        "file": "res://common/audio/sfx/stings/sting_happy_bells_01.wav",
        "at": 38.00,
        "duration": 2.0,
        "gain_db": -6.0,
        "event": "ev_outro_cheer"
    }
]

# 10. Captions (all <= 5 words)
chunk_defs = [
    (0, 3, "Stop scrolling, you guys!"),
    (4, 7, "We are officially hosting"),
    (8, 11, "a massive Halloween giveaway!"),
    (12, 13, "The prizes?"),
    (14, 16, "Drum roll, please!"),
    (17, 19, "Three spooky prizes:"),
    (20, 23, "A custom Halloween PFP,"),
    (24, 26, "a personalized doodle"),
    (27, 29, "drawn by me,"),
    (30, 33, "and a shout out"),
    (34, 37, "in my next video!"),
    (38, 42, "To enter, join our Discord,"),
    (43, 46, "say hi and introductions,"),
    (47, 49, "subscribe on YouTube,"),
    (50, 54, "and keep your DMs open!"),
    (55, 56, "Rule 1:"),
    (57, 61, "Only one entry per person!"),
    (62, 64, "No shadow clones"),
    (65, 67, "or burner ults,"),
    (68, 71, "and you have 48"),
    (72, 74, "hours to claim!"),
    (75, 76, "No spamming,"),
    (77, 78, "be nice,"),
    (79, 82, "and good luck everyone!"),
    (83, 84, "Happy Halloween!")
]

captions = []
for w_start, w_end, text in chunk_defs:
    selected = words[w_start:w_end + 1]
    t_start = selected[0]['start']
    next_start = words[w_end + 1]['start'] if w_end + 1 < len(words) else duration
    t_end = min(selected[-1]['end'] + 0.04, next_start)
    if t_end < selected[-1]['end']:
        t_end = selected[-1]['end']
    captions.append({
        "actor": "nemi",
        "words": [w_start, w_end],
        "start": t_start,
        "end": t_end,
        "text": text
    })

# 11. Complete Spec
spec = {
    "version": 2,
    "title": "Halloween Giveaway Announcement — Nemi",
    "duration": duration,
    "fps": 30,
    "caption_size": 48,
    "audio": "res://" + str((prepared / 'narration.wav').relative_to(ROOT)),
    "audio_metadata": "res://" + str((prepared / 'timeline.json').relative_to(ROOT)),
    "direction": direction,
    "events": events,
    "actors": [
        {
            "id": "nemi",
            "author": "nemi",
            "performances": performances,
            "mouths": mouths
        }
    ],
    "shots": shots,
    "drawings": drawings,
    "props": props,
    "vfx": [],
    "sfx": sfx,
    "music": [],
    "script": script,
    "captions": captions,
    "overlays": [],
    "mix": {
        "master_gain_db": 5.8,
        "target_lufs": -18.0,
        "peak_dbfs": -2.0
    }
}

(F / 'scene.json').write_text(json.dumps(spec, indent=2) + '\n')
print(f"Successfully generated scene.json ({duration}s, {len(shots)} shots, {len(performances)} performances, {len(drawings)} drawings, {len(props)} props, {len(captions)} captions)!")
