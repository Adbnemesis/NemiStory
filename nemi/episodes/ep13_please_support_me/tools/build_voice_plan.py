#!/usr/bin/env python3
"""Build calibrated voice plan for EP13 Please Support Me (R3) with explicit sentence boundaries and safe margins."""
import json
import math
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'tools/storytime'))

from prepare_voice import prepare, digest

EP = Path(__file__).resolve().parent.parent

source_words = json.loads((EP / 'source_words.json').read_text())

# Pacing between 1.08x - 1.12x (well within 1.00 - 1.15 cap)
tempos = {
    0: 1.10,
    1: 1.12,
    2: 1.10,
    3: 1.10,
    4: 1.10,
    5: 1.10,
    6: 1.08,  # Sincere, unhurried gratitude
    7: 1.10,
    8: 1.08   # Warm concluding pace
}

# Explicit cuts ONLY at full-sentence/phrase transitions:
# Each cut is (left_word_end, right_word_start, target_thought_pause)
# Preserves +0.18s source tail and -0.12s lead around each split so words never get clipped.
cuts = {
    0: [(0.58, 1.58, 0.25)],
    1: [(2.74, 3.58, 0.28)],
    2: [(1.12, 1.84, 0.25)],
    3: [(0.80, 1.72, 0.25), (4.68, 5.16, 0.25)],
    4: [(5.72, 7.06, 0.25), (8.18, 9.20, 0.28)],
    5: [(6.70, 7.74, 0.28)],
    6: [(2.42, 3.32, 0.28)],
    7: [(5.72, 6.50, 0.28)],
    8: [(2.34, 3.32, 0.28)]
}

line_pauses = {
    0: 0.25,
    1: 0.25,
    2: 0.25,
    3: 0.25,
    4: 0.25,
    5: 0.25,
    6: 0.28,
    7: 0.25,
    8: 0.35
}

clips = []
current_time = 0.20  # Opening buffer

for line_idx, record in enumerate(source_words):
    raw_words = record['words']
    if not raw_words:
        continue
    
    tempo = tempos.get(line_idx, 1.10)
    file_path = record['file']
    sha = record['sha256']
    dur = record['duration']
    
    # Clean words to ensure non-overlapping order
    cleaned_words = []
    prev_end = 0.0
    for w in raw_words:
        ws = max(round(w['start'], 3), prev_end)
        we = round(max(w['end'], ws + 0.04), 3)
        token = w['word'].strip()
        cleaned_words.append({
            'word': token,
            'start': ws,
            'end': we
        })
        prev_end = we

    # Explicit phrase bounds with decay/attack safety margins (+0.18s, -0.12s)
    c_list = cuts.get(line_idx, [])
    bounds = []
    begin = 0.0
    for left, right, gap in c_list:
        end = min(dur, round(left + 0.18, 3))
        bounds.append((begin, end, gap))
        begin = max(0.0, round(right - 0.12, 3))
    bounds.append((begin, dur, 0.0))
    
    for b_start, b_end, gap in bounds:
        selected_words = [w for w in cleaned_words if b_start <= w['start'] and w['end'] <= b_end]
        assert selected_words, f"Line {line_idx} clip ({b_start}, {b_end}) has no words!"
        
        clip_duration = (b_end - b_start) / tempo
        clip_entry = {
            'author': 'nemi',
            'file': file_path,
            'sha256': sha,
            'at': round(current_time, 6),
            'start': round(b_start, 6),
            'end': round(b_end, 6),
            'tempo': tempo,
            'words': selected_words
        }
        clips.append(clip_entry)
        current_time += clip_duration + gap
        
    # Natural pause after line
    current_time += line_pauses.get(line_idx, 0.25)

final_duration = math.ceil(current_time * 30.0) / 30.0
assert final_duration <= 100.0, f"Runtime {final_duration:.2f}s exceeds target 100.0s cap!"

plan = {
    'version': 1,
    'duration': round(final_duration, 3),
    'clips': clips
}

plan_path = EP / 'voice_plan.json'
plan_path.write_text(json.dumps(plan, indent=2) + '\n')
print(f"Voice plan saved to {plan_path}")
print(f"Total clips: {len(clips)}, Final scene duration: {final_duration:.2f}s (~{final_duration/60:.2f} mins)")

scratch = ROOT / 'renders/nemi_ep13/audio_r3'
if scratch.exists():
    shutil.rmtree(scratch)

timeline = prepare(plan, scratch)
shutil.copyfile(scratch / 'narration.wav', EP / 'voice/narration_r3.wav')
(EP / 'timing_reference.json').write_text(json.dumps(timeline, indent=2) + '\n')
print("Successfully generated voice/narration_r3.wav and timing_reference.json!")
