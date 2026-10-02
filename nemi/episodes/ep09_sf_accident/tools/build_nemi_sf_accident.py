"""Build Nemi's San Francisco solo trip and accident storytime episode (120s)."""
import json
import subprocess
import re
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
import sys
sys.path.insert(0, str(ROOT))

from tools.storytime.prepare_voice import prepare, digest
from tools.storytime.audio_mix import calibrate_mix
from tools.storytime.validate_scene import validate_data

folder = ROOT / 'nemi/episodes/ep09_sf_accident'
folder.mkdir(parents=True, exist_ok=True)
if (folder/'scene_antigravity_rebuild.json').exists(): raise ValueError('Historical rebuild exists; preserve it.')

source = json.loads((folder / 'source_words.json').read_text())

# Pacing schedule: 18 clips targeting 120.0s total duration
tempos = [1.12, 1.15, 1.15, 1.10, 1.10, 1.14, 1.14, 1.14, 1.15, 1.15, 1.12, 1.12, 1.05, 1.14, 1.12, 1.12, 1.05, 1.15]

current_at = 0.5
clips = []
placements = []

for i, (r, tempo) in enumerate(zip(source, tempos)):
    path = ROOT / r['file'][6:]
    dur = float(subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=nw=1:nk=1', str(path)]))

    # Clean words to ensure nonoverlapping, ordered, and within [0, dur]
    raw_words = r['words']
    cleaned_words = []
    prev_end = 0.0
    for w in raw_words:
        word_text = w['word'].strip()
        if not word_text:
            continue
        start = max(round(w['start'], 3), prev_end)
        end = max(round(min(w['end'], dur), 3), start + 0.04)
        if end > dur:
            end = dur
            if start >= end:
                start = max(0.0, end - 0.04)
        cleaned_words.append({'word': word_text, 'start': start, 'end': end})
        prev_end = end

    length = dur / tempo
    at = round(current_at, 2)
    placements.append((i, at, tempo, dur, length))

    clips.append({
        'author': r['author'],
        'file': r['file'],
        'sha256': r['sha256'],
        'at': at,
        'start': 0,
        'end': dur,
        'tempo': tempo,
        'words': cleaned_words
    })

    # Natural pause
    pause = 0.25 if i not in [11, 12, 16] else 0.55
    current_at += length + pause

TOTAL_DURATION = 120.0
plan = {'version': 1, 'duration': TOTAL_DURATION, 'clips': clips}

audio_dest = ROOT / 'renders/nemi_sf_accident/audio'
if audio_dest.exists():
    try:
        timeline = json.loads((audio_dest / 'timeline.json').read_text())
        assert timeline['audio_sha256'] == digest(audio_dest / 'narration.wav')
        assert len(timeline['clips']) == len(clips)
        for saved, wanted in zip(timeline['clips'], clips):
            assert all(saved[k] == wanted[k] for k in ['file', 'sha256', 'at', 'start', 'end', 'tempo'])
        print('Existing narration matches plan.')
    except Exception as e:
        raise ValueError('Original narration no longer matches the historical plan; use a separate audio revision folder.') from e
else:
    timeline = prepare(plan, audio_dest)

(folder / 'voice_plan_antigravity_rebuild.json').write_text(json.dumps(plan, indent=2) + '\n')
(folder / 'timing_antigravity_rebuild.json').write_text(json.dumps(timeline, indent=2) + '\n')

words = timeline['words']
print(f'Total words in timeline: {len(words)}')

# Shots definition
shots = [
    {'id': 'hook', 'start': 0.0, 'end': 8.46, 'background': 'studio_nemi', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'san_francisco', 'start': 8.46, 'end': 17.06, 'background': 'studio_nemi', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'activities', 'start': 17.06, 'end': 25.94, 'background': 'thought', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'apple_event', 'start': 25.94, 'end': 30.77, 'background': 'thought', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'golden_gate', 'start': 30.77, 'end': 35.75, 'background': 'evening', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'waymo_intro', 'start': 35.75, 'end': 42.59, 'background': 'room', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'ghost_driver', 'start': 42.59, 'end': 47.76, 'background': 'thought', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'waymo_panic', 'start': 47.76, 'end': 53.55, 'background': 'thought', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'waymo_relief', 'start': 53.55, 'end': 61.10, 'background': 'room', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'heading_airport', 'start': 61.10, 'end': 67.96, 'background': 'paper', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'five_minutes', 'start': 67.96, 'end': 72.57, 'background': 'paper', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'sudden_brake', 'start': 72.57, 'end': 80.48, 'background': 'studio_nemi', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'deadpan_pause', 'start': 80.48, 'end': 85.50, 'background': 'paper', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'rear_end_crash', 'start': 85.50, 'end': 93.18, 'background': 'thought', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'police_arrive', 'start': 93.18, 'end': 97.71, 'background': 'evening', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'investigation', 'start': 97.71, 'end': 103.32, 'background': 'evening', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'crying_breakdown', 'start': 103.32, 'end': 109.81, 'background': 'studio_nemi', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}},
    {'id': 'payoff', 'start': 109.81, 'end': 120.0, 'background': 'studio_nemi', 'actors': {'nemi': {'position': [510, 570], 'scale': 1.85}}}
]

# Nemi performances
performances = [
    {'at': 0.0, 'recipe': 'explaining'},
    {'at': 3.5, 'recipe': 'lean_in', 'duration': 0.35, 'blinks': [4.8]},
    {'at': 8.46, 'recipe': 'pleased', 'duration': 0.4},
    {'at': 13.0, 'recipe': 'soft_shrug', 'duration': 0.35, 'blinks': [14.2]},
    {'at': 17.06, 'recipe': 'explaining', 'duration': 0.4},
    {'at': 22.0, 'recipe': 'pleased', 'duration': 0.35, 'blinks': [23.5]},
    {'at': 25.94, 'recipe': 'realization', 'duration': 0.4},
    {'at': 30.77, 'recipe': 'pleased', 'duration': 0.35},
    {'at': 35.75, 'recipe': 'explaining', 'duration': 0.4},
    {'at': 39.5, 'recipe': 'uncertain', 'duration': 0.35, 'blinks': [40.8]},
    {'at': 42.59, 'recipe': 'skeptical', 'duration': 0.4},
    {'at': 47.76, 'recipe': 'quiet_recoil', 'duration': 0.35, 'hands': {'left': 'fist', 'right': 'fist'}},
    {'at': 53.55, 'recipe': 'recover', 'duration': 0.4, 'blinks': [55.0]},
    {'at': 57.5, 'recipe': 'pleased', 'duration': 0.35},
    {'at': 61.10, 'recipe': 'listening', 'duration': 0.4},
    {'at': 67.96, 'recipe': 'lean_in', 'duration': 0.35},
    {'at': 72.57, 'recipe': 'explaining', 'duration': 0.4},
    {'at': 76.5, 'recipe': 'quiet_recoil', 'duration': 0.35, 'event': 'brake_event'},
    {'at': 80.48, 'recipe': 'deadpan', 'motion': 'snap'},
    {'at': 85.50, 'recipe': 'quiet_recoil', 'duration': 0.25, 'event': 'crash_event'},
    {'at': 89.0, 'recipe': 'uncertain', 'duration': 0.35, 'blinks': [90.5]},
    {'at': 93.18, 'recipe': 'listening', 'duration': 0.4},
    {'at': 97.71, 'recipe': 'embarrassed', 'duration': 0.35},
    {'at': 103.32, 'recipe': 'embarrassed', 'duration': 0.4, 'face': {'eye_openness': 0.7, 'pupil_scale': 0.8}, 'hands': {'left': 'hand_to_cheek'}, 'event': 'tears_event'},
    {'at': 109.81, 'recipe': 'soft_shrug', 'duration': 0.35},
    {'at': 114.5, 'recipe': 'pleased', 'duration': 0.4, 'blinks': [116.0]}
]

# Build Script, Captions and Mouths
script = []
captions = []
mouths = []
word_offset = 0

for (idx, at, tempo, dur, length), clip in zip(placements, clips):
    src_rec = source[idx]
    end_time = at + length
    script.append({
        'actor': 'nemi',
        'start': at,
        'end': end_time,
        'text': src_rec['text']
    })

    clip_words = words[word_offset:word_offset + len(clip['words'])]

    # Captions: group max 5 words
    group = []
    for j, w in enumerate(clip_words):
        global_idx = word_offset + j
        group.append((global_idx, w))

        # Split condition: 5 words or punctuation or last word in clip
        is_punct = w['word'].endswith(('.', '?', '!', '...'))
        if len(group) == 5 or is_punct or j == len(clip_words) - 1:
            captions.append({
                'actor': 'nemi',
                'words': [group[0][0], group[-1][0]],
                'start': group[0][1]['start'],
                'end': group[-1][1]['end'],
                'text': ' '.join(x[1]['word'] for x in group)
            })
            group = []

        # Mouth shape
        span = w['end'] - w['start']
        if span > 0.045:
            w_text = w['word'].lower()
            if re.search(r'oo|o[ru]|one|you|to|who', w_text):
                shape = 'o_u'
            elif re.search(r'a[et]|ha|wa|ca', w_text):
                shape = 'ae'
            elif re.search(r'i|ee|ea', w_text):
                shape = 'smile'
            else:
                shape = 'small_open'

            m_start = max(at, round(w['start'] + 0.008, 3))
            m_end = min(end_time, round(w['end'] - 0.015, 3))
            if m_end > m_start + 0.02:
                mouths.append({
                    'start': m_start,
                    'end': m_end,
                    'shape': shape
                })

    word_offset += len(clip_words)

actors = [{
    'id': 'nemi',
    'author': 'nemi',
    'performances': performances,
    'mouths': mouths
}]

# Events
events = [
    {'id': 'brake_event', 'at': 76.5, 'intent': 'The driver slams the brakes at high speed.'},
    {'id': 'crash_event', 'at': 85.5, 'intent': 'The car behind plows straight into our rear bumper.'},
    {'id': 'tears_event', 'at': 103.32, 'intent': 'Nemi breaks down crying during the police investigation.'}
]

# Props and Drawings
props = [
    {'author': 'nemi', 'kind': 'desk', 'position': [1250, 660], 'scale': [1.25, 1.25], 'at': 0.0, 'end': 17.06, 'mode': 'hold', 'layer': 0},
    {'author': 'nemi', 'kind': 'notebook', 'position': [1280, 555], 'scale': [1.5, 1.5], 'at': 0.0, 'end': 8.46, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'phone', 'position': [1250, 580], 'scale': [1.4, 1.4], 'at': 8.46, 'end': 17.06, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'laptop', 'position': [1220, 580], 'scale': [1.3, 1.3], 'at': 25.94, 'end': 30.77, 'mode': 'hold'}
]

drawings = [
    {'author': 'nemi', 'kind': 'text', 'text': 'a solo trip', 'position': [1020, 150], 'size': 60, 'at': 0.0, 'end': 8.46, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'text', 'text': 'san francisco', 'position': [1040, 150], 'size': 58, 'at': 8.46, 'end': 17.06, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'spark', 'position': [1420, 360], 'scale': [1.5, 1.5], 'at': 11.0, 'duration': 0.6, 'end': 17.06, 'mode': 'live'},
    {'author': 'nemi', 'kind': 'text', 'text': '20,000 steps', 'position': [1060, 150], 'size': 56, 'at': 17.06, 'end': 25.94, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'arrow', 'position': [1260, 480], 'scale': [1.3, 1.3], 'at': 20.0, 'duration': 0.7, 'end': 25.94, 'mode': 'live'},
    {'author': 'nemi', 'kind': 'text', 'text': 'the year 2040', 'position': [1050, 150], 'size': 58, 'at': 25.94, 'end': 30.77, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'text', 'text': 'golden gate', 'position': [1060, 150], 'size': 60, 'at': 30.77, 'end': 35.75, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'spark', 'position': [1380, 320], 'scale': [1.6, 1.6], 'at': 32.5, 'duration': 0.5, 'end': 35.75, 'mode': 'live'},
    {'author': 'nemi', 'kind': 'text', 'text': 'a waymo', 'position': [1080, 150], 'size': 62, 'at': 35.75, 'end': 42.59, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'question', 'position': [1350, 420], 'scale': [1.8, 1.8], 'at': 38.0, 'duration': 0.6, 'end': 42.59, 'mode': 'live'},
    {'author': 'nemi', 'kind': 'text', 'text': 'ghost driver', 'position': [1050, 150], 'size': 58, 'at': 42.59, 'end': 47.76, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'circle', 'position': [1300, 460], 'scale': [2.0, 2.0], 'at': 44.0, 'duration': 1.0, 'end': 47.76, 'mode': 'live'},
    {'author': 'nemi', 'kind': 'text', 'text': 'final day', 'position': [1080, 150], 'size': 60, 'at': 47.76, 'end': 53.55, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'scratch', 'position': [1300, 200], 'scale': [1.8, 1.8], 'at': 50.0, 'duration': 0.5, 'end': 53.55, 'mode': 'live'},
    {'author': 'nemi', 'kind': 'text', 'text': 'survived', 'position': [1080, 150], 'size': 62, 'at': 53.55, 'end': 61.10, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'underline', 'position': [1220, 210], 'scale': [1.5, 1.5], 'at': 55.5, 'duration': 0.5, 'end': 61.10, 'mode': 'live'},
    {'author': 'nemi', 'kind': 'text', 'text': 'heading to sfo', 'position': [1050, 150], 'size': 56, 'at': 61.10, 'end': 67.96, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'text', 'text': '5 minutes away', 'position': [1050, 150], 'size': 58, 'at': 67.96, 'end': 72.57, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'text', 'text': 'high speed', 'position': [1080, 150], 'size': 60, 'at': 72.57, 'end': 80.48, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'text', 'text': 'definitely not', 'position': [1060, 150], 'size': 58, 'at': 80.48, 'end': 85.50, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'text', 'text': 'CRASH', 'position': [1080, 200], 'size': 72, 'at': 85.50, 'end': 93.18, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'scratch', 'position': [1240, 250], 'scale': [2.0, 2.0], 'at': 87.0, 'duration': 0.4, 'end': 93.18, 'mode': 'live'},
    {'author': 'nemi', 'kind': 'text', 'text': 'highway patrol', 'position': [1050, 150], 'size': 58, 'at': 93.18, 'end': 97.71, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'text', 'text': 'investigation', 'position': [1060, 150], 'size': 56, 'at': 97.71, 'end': 103.32, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'text', 'text': 'total breakdown', 'position': [1040, 150], 'size': 58, 'at': 103.32, 'end': 109.81, 'mode': 'hold'},
    {'author': 'nemi', 'kind': 'circle', 'position': [1350, 450], 'scale': [1.8, 1.8], 'at': 105.0, 'duration': 0.8, 'end': 109.81, 'mode': 'live'},
    {'author': 'nemi', 'kind': 'text', 'text': 'robot: 0 vs cab: 1', 'position': [1020, 150], 'size': 56, 'at': 109.81, 'end': 120.0, 'mode': 'hold'}
]

# VFX
vfx = [
    {'author': 'nemi', 'kind': 'tension', 'actor': 'nemi', 'offset': [80, -40], 'at': 49.5, 'end': 51.5, 'strength': 1.0},
    {'author': 'nemi', 'kind': 'relief', 'actor': 'nemi', 'offset': [80, -40], 'at': 55.0, 'end': 57.0, 'strength': 1.0},
    {'author': 'nemi', 'kind': 'tension', 'actor': 'nemi', 'offset': [80, -40], 'at': 76.5, 'end': 78.5, 'strength': 1.2, 'event': 'brake_event'},
    {'author': 'nemi', 'kind': 'impact', 'actor': 'nemi', 'offset': [80, -40], 'at': 85.5, 'end': 87.0, 'strength': 1.5, 'event': 'crash_event'},
    {'author': 'nemi', 'kind': 'sweat', 'actor': 'nemi', 'offset': [80, -40], 'at': 103.32, 'end': 105.32, 'strength': 1.2, 'event': 'tears_event'},
    {'author': 'nemi', 'kind': 'realization', 'actor': 'nemi', 'offset': [80, -40], 'at': 115.0, 'end': 117.0, 'strength': 0.9}
]

# SFX
sfx = [
    {'file': 'res://common/audio/sfx/stings/sting_fairy_sparkle_arcade_01.wav', 'at': 11.0, 'duration': 0.8, 'gain_db': -24.0},
    {'file': 'res://common/audio/sfx/transitions/transition_camera_shutter_01.wav', 'at': 27.5, 'duration': 0.6, 'gain_db': -22.0},
    {'file': 'res://common/audio/sfx/stings/sting_fairy_sparkle_arcade_01.wav', 'at': 32.5, 'duration': 0.8, 'gain_db': -24.0},
    {'file': 'res://common/audio/sfx/ui/ui_click_tactile_01.ogg', 'at': 38.0, 'duration': 0.15, 'gain_db': -22.0},
    {'file': 'res://common/audio/sfx/drawing/drawing_scratch_scribble_01.ogg', 'at': 44.0, 'duration': 0.14, 'gain_db': -26.0},
    {'file': 'res://common/audio/sfx/drawing/drawing_scratch_scribble_01.ogg', 'at': 50.0, 'duration': 0.14, 'gain_db': -26.0},
    {'file': 'res://common/audio/sfx/impacts/impact_soft_thud_01.ogg', 'at': 76.5, 'duration': 0.35, 'gain_db': -20.0, 'event': 'brake_event'},
    {'file': 'res://common/audio/sfx/impacts/impact_punch_medium_01.ogg', 'at': 85.5, 'duration': 0.5, 'gain_db': -16.0, 'event': 'crash_event'},
    {'file': 'res://common/audio/sfx/reaction/reaction_female_gasp_surprised_01.wav', 'at': 103.32, 'duration': 0.4, 'gain_db': -22.0, 'event': 'tears_event'}
]

# Direction brief and thought beats
direction = {
    'promise': 'Surviving the futuristic danger of a solo trip does not protect you from ordinary life.',
    'want': 'Enjoy San Francisco, experience the sights and driverless tech, and catch the flight home safely.',
    'choice': 'Take an ordinary human-driven airport cab after safely surviving a driverless Waymo.',
    'consequence': 'The cab driver slams the brakes on the highway and gets rear-ended five minutes from SFO.',
    'payoff': 'The futuristic robot car was harmless, but a five-minute human taxi ride ended in police reports and tears.',
    'beats': [
        {'start': 0.0, 'end': 8.46, 'thought': 'Surviving the impossible only makes the ordinary more dangerous.', 'focus': 'Nemi talking directly to viewer', 'visual': 'Studio setup, held notebook', 'intent': 'Establish the comedic paradox hook.'},
        {'start': 8.46, 'end': 17.06, 'thought': 'A solo trip is liberating and exciting.', 'focus': 'Nemi with phone photo', 'visual': 'Held phone, live sparkle mark', 'intent': 'Ground the story in her genuine enthusiasm.'},
        {'start': 17.06, 'end': 25.94, 'thought': 'I packed every possible activity into this trip.', 'focus': 'Walking counter and steps', 'visual': 'Live arrow, mental illustration', 'intent': 'Build comedic momentum.'},
        {'start': 25.94, 'end': 30.77, 'thought': 'The Apple event felt completely futuristic.', 'focus': 'Held laptop and tech vibes', 'visual': 'Held tech prop, realization pose', 'intent': 'Establish the high-tech theme.'},
        {'start': 30.77, 'end': 35.75, 'thought': 'The Golden Gate Bridge was breathtaking.', 'focus': 'Warm evening skyline', 'visual': 'Live sparkle, gaze up', 'intent': 'Show the scenic high point.'},
        {'start': 35.75, 'end': 42.59, 'thought': 'Riding a Waymo sounded like a wild idea.', 'focus': 'App screen and question mark', 'visual': 'Live question mark doodle', 'intent': 'Introduce the robot car tension.'},
        {'start': 42.59, 'end': 47.76, 'thought': 'A ghost is literally steering this vehicle.', 'focus': 'Turning steering wheel doodle', 'visual': 'Live circle steering wheel', 'intent': 'Escalate the technological dread.'},
        {'start': 47.76, 'end': 53.55, 'thought': 'I genuinely believed today was my last day on earth.', 'focus': 'Clutching hands and recoil', 'visual': 'Fist clench, tension VFX', 'intent': 'Reach the comedic peak of Waymo terror.'},
        {'start': 53.55, 'end': 61.10, 'thought': 'I survived the robot car unscathed.', 'focus': 'Relieved posture and underline', 'visual': 'Live underline, relief VFX', 'intent': 'Set up the false sense of security.'},
        {'start': 61.10, 'end': 67.96, 'thought': 'Time to head to the airport in a boring normal taxi.', 'focus': 'Paper route to SFO', 'visual': 'Held text and route', 'intent': 'Transition to the real conflict.'},
        {'start': 67.96, 'end': 72.57, 'thought': 'Only five minutes until safety.', 'focus': 'Five minute milestone text', 'visual': 'Lean in posture', 'intent': 'Heighten dramatic irony.'},
        {'start': 72.57, 'end': 80.48, 'thought': 'Why is the driver slamming the brakes at full speed?!', 'focus': 'Sudden recoil and brake sound', 'visual': 'Brake recoil, tension VFX', 'intent': 'Deliver the sudden physical shock.'},
        {'start': 80.48, 'end': 85.50, 'thought': 'We stopped... but what about the car behind us?', 'focus': 'Deadpan camera stare', 'visual': 'Instant 0-velocity hold', 'intent': 'The agonizing comedic anticipation pause.'},
        {'start': 85.50, 'end': 93.18, 'thought': 'We just got violently rear-ended.', 'focus': 'CRASH doodle and impact effect', 'visual': 'Impact VFX, live scratch', 'intent': 'The chaotic climax lands.'},
        {'start': 93.18, 'end': 97.71, 'thought': 'Highway patrol is here and this is now an official investigation.', 'focus': 'Flashing emergency atmosphere', 'visual': 'Evening backdrop, listening pose', 'intent': 'Escalate into bureaucratic absurdity.'},
        {'start': 97.71, 'end': 103.32, 'thought': 'Officers with clipboards are taking official statements.', 'focus': 'Inspection and crushed bumper', 'visual': 'Embarrassed retreat posture', 'intent': 'Show the overwhelming reality.'},
        {'start': 103.32, 'end': 109.81, 'thought': 'I cannot handle this adult situation and I am crying.', 'focus': 'Tears, hand on cheek', 'visual': 'Sweat VFX, facepalm gesture', 'intent': 'Vulnerable human breakdown.'},
        {'start': 109.81, 'end': 120.0, 'thought': 'The robot taxi was harmless; the human cab destroyed me.', 'focus': 'Final sheepish smile', 'visual': 'Quiet hold, soft shrug', 'intent': 'Land the final comedic payoff.'}
    ]
}

spec = {
    'version': 2,
    'title': 'I Had An Accident in San Francisco',
    'duration': TOTAL_DURATION,
    'fps': 30,
    'caption_size': 50,
    'audio': 'res://renders/nemi_sf_accident/audio/narration.wav',
    'audio_metadata': 'res://renders/nemi_sf_accident/audio/timeline.json',
    'direction': direction,
    'actors': actors,
    'shots': shots,
    'drawings': drawings,
    'props': props,
    'vfx': vfx,
    'sfx': sfx,
    'events': events,
    'script': script,
    'captions': captions
}

spec['mix'] = calibrate_mix(spec, ROOT)
validate_data(spec)

(folder / 'scene_antigravity_rebuild.json').write_text(json.dumps(spec, indent=2) + '\n')
print('scene.json built and validated successfully!')
