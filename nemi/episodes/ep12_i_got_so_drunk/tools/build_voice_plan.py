#!/usr/bin/env python3
"""Build calibrated voice plan for EP12 I Got So Drunk using explicit sentence boundaries and safe margins."""
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
EP = Path(__file__).resolve().parent.parent

source_words = json.loads((EP / 'source_words.json').read_text())

# Pacing strictly within 1.10 - 1.14x (well within 1.00 - 1.15 cap)
tempos = {
    0: 1.12, 1: 1.12, 2: 1.14, 3: 1.14, 4: 1.14,
    5: 1.12, 6: 1.12, 7: 1.12, 8: 1.12, 9: 1.12,
    10: 1.12, 11: 1.14, 12: 1.12, 13: 1.12, 14: 1.14
}

# Explicit cuts ONLY at full-sentence/phrase transitions:
# Each cut is (left_word_end, right_word_start, target_thought_pause)
# We preserve +0.18s source tail and -0.12s lead around each split so words NEVER get cut off or collide.
cuts = {
    0: [(0.32, 0.80, 0.20)],                           # 'Wait,' -> 'please tell me'
    1: [(1.14, 1.60, 0.20)],                           # 'weekend,' -> 'two of my college friends'
    2: [(5.48, 5.98, 0.22), (6.68, 7.48, 0.25), (8.06, 9.08, 0.28)], # '-game.' -> 'Two bottles'; 'Two bottles.' -> 'For three'; 'people.' -> 'We looked'
    3: [(7.28, 7.86, 0.25)],                           # 'ADB place.' -> 'Suddenly we are six'
    4: [(3.60, 4.26, 0.24), (7.16, 7.90, 0.24)],      # '8pm.' -> 'Order'; 'takeout.' -> 'Open'
    5: [(3.18, 4.48, 0.28)],                           # 'multiplying.' -> 'ADB was'
    6: [(3.48, 4.84, 0.30), (8.78, 9.32, 0.26)],      # 'dictionary.' -> 'If you have never'; 'blasted.' -> 'Do not do it'
    7: [(1.44, 2.18, 0.25), (5.34, 6.04, 0.25), (8.06, 8.76, 0.28)], # 'horse.' -> 'It'; 'legs.' -> 'Someone'; 'Toaster!' -> 'We argued'
    8: [(3.76, 4.48, 0.28)],                           # 'clubbing.' -> 'And when you are drunk'
    9: [(0.90, 1.46, 0.22)],                           # 'inside,' -> 'base vibrating'
    10: [(3.34, 4.48, 0.28), (6.66, 7.44, 0.25)],     # 'due tomorrow.' -> 'Complete'; 'energy.' -> 'My hair'
    11: [(6.52, 7.64, 0.25), (9.10, 10.00, 0.24), (10.96, 12.06, 0.28)], # 'house.' -> 'Normal'; 'sleep' -> 'not us'; 'us.' -> 'We booted'
    12: [(3.48, 4.62, 0.26), (6.60, 7.76, 0.28)],     # '5 in the morning' -> 'the vodka'; 'debt.' -> 'The room'
    13: [(1.44, 2.26, 0.26)],                          # 'bathroom.' -> 'Hugged'
    14: [(6.76, 7.50, 0.24), (11.20, 12.38, 0.30), (12.88, 13.84, 0.26), (15.50, 16.22, 0.28)] # 'later' -> 'feeling'; 'skull.' -> 'Anyway'; 'Anyway' -> '10'; 'night' -> 'Never'
}

line_pauses = {
    0: 0.22, 1: 0.20, 2: 0.25, 3: 0.20, 4: 0.20,
    5: 0.22, 6: 0.25, 7: 0.25, 8: 0.20, 9: 0.20,
    10: 0.22, 11: 0.24, 12: 0.28, 13: 0.25, 14: 0.35
}

clips = []
current_time = 0.20  # Initial opening silence

for line_idx, record in enumerate(source_words):
    raw_words = record['words']
    if not raw_words:
        continue
    
    tempo = tempos.get(line_idx, 1.12)
    file_path = record['file']
    sha = record['sha256']
    dur = record['duration']
    
    # Clean words to ensure non-overlapping order
    cleaned_words = []
    prev_end = 0.0
    for w in raw_words:
        w_start = max(round(w['start'], 3), prev_end)
        w_end = round(max(w['end'], w_start + 0.04), 3)
        cleaned_words.append({
            'word': w['word'].strip(),
            'start': w_start,
            'end': w_end
        })
        prev_end = w_end

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
    current_time += line_pauses.get(line_idx, 0.22)

final_duration = math.ceil(current_time * 30.0) / 30.0
assert final_duration <= 150.0, f"Runtime {final_duration:.2f}s exceeds 150.0s cap!"

plan = {
    'version': 1,
    'duration': round(final_duration, 3),
    'clips': clips
}

plan_path = EP / 'voice_plan.json'
plan_path.write_text(json.dumps(plan, indent=2) + '\n')
print(f"Voice plan saved to {plan_path}")
print(f"Total clips: {len(clips)}, Final scene duration: {final_duration:.2f}s (Cap <= 150.0s)")
