#!/usr/bin/env python3
"""Build calibrated voice plan for EP14 I Got Scammed (R4) with tight, authentic conversational flow."""
import json
import math
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'tools/storytime'))

from prepare_voice import prepare

EP = Path(__file__).resolve().parent.parent

source_words = json.loads((EP / 'source_words.json').read_text())

# Pacing between 1.05x - 1.12x (EP11 R10 upper-middle balance)
tempos = {
    0: 1.08,
    1: 1.10,
    2: 1.12,  # Drop morning frenzy
    3: 1.08,  # Bad idea denial
    4: 1.10,  # Resale forum
    5: 1.10,  # Full FBI mode
    6: 1.08,  # Smug Sherlock genius
    7: 1.10,  # 5-minute timer pressure
    8: 1.10,  # Sending $300 savings
    9: 1.05,  # Shock: Red exclamation mark
    10: 1.05, # Deadpan: Blocked, $12 left
    11: 1.08  # Moral of the story
}

# Specific authored internal pause overrides (line_idx, word_index_after_which_gap_occurs) -> new_pause_seconds
# Default for any other internal gap > 0.32s is tightened to 0.20s (natural conversational breathing)
custom_internal_gaps = {
    (9, 7): 0.35,   # Line 9: tickets? -> Two seconds later (anticipation)
    (10, 3): 0.35,  # Line 10: avatar -> Blocked
    (10, 4): 0.45,  # Line 10: Blocked -> The post was deleted (comedic silence)
    (11, 10): 0.45, # Line 11: internet -> Moral of the story
}

# Crisp, natural inter-line pauses (no drag, maintaining lively conversation)
inter_line_pauses = {
    0: 0.25,
    1: 0.25,
    2: 0.25,
    3: 0.25,
    4: 0.25,
    5: 0.25,
    6: 0.25,
    7: 0.25,
    8: 0.30,
    9: 0.40,  # Shock after getting blocked
    10: 0.40, # Staring at the $12 balance
    11: 0.30
}

all_subclips = []
current_time = 0.25  # Clean opening lead buffer

for line_idx, record in enumerate(source_words):
    words = record['words']
    if not words:
        continue
    tempo = tempos.get(line_idx, 1.08)
    file_path = record['file']
    sha = record['sha256']
    dur = record['duration']
    
    # Identify internal dead pauses (> 0.32s) to split into clean sub-clips
    split_indices = []
    gaps_after = []
    
    for i in range(len(words) - 1):
        gap = words[i+1]['start'] - words[i]['end']
        if gap > 0.32:
            split_indices.append(i + 1)
            p = custom_internal_gaps.get((line_idx, i), 0.20)
            gaps_after.append(p)
            
    # Form chunks of words
    chunks = []
    prev_idx = 0
    for split_idx in split_indices:
        chunks.append(words[prev_idx:split_idx])
        prev_idx = split_idx
    chunks.append(words[prev_idx:])
    
    for c_idx, chunk in enumerate(chunks):
        c_first = chunk[0]['start']
        c_last = chunk[-1]['end']
        
        # Authored bounds with tiny safety pad (preserving natural consonant attack & room decay)
        b_start = round(max(0.0, c_first - 0.04), 3)
        b_end = round(min(dur, c_last + 0.05), 3)
        if b_start > c_first:
            b_start = round(c_first, 3)
        if b_end < c_last:
            b_end = round(c_last, 3)
        
        # Word ordering & clamping strictly inside bounds
        clip_words = []
        last_we = b_start
        for w in chunk:
            ws = max(last_we, round(w['start'], 3))
            we = max(ws + 0.04, round(w['end'], 3))
            if we > b_end:
                b_end = round(we + 0.02, 3)
            clip_words.append({
                'word': w['word'].strip(),
                'start': ws,
                'end': we
            })
            last_we = we
            
        dur_clip = (b_end - b_start) / tempo
        all_subclips.append({
            'author': 'nemi',
            'file': file_path,
            'sha256': sha,
            'at': round(current_time, 3),
            'start': b_start,
            'end': b_end,
            'tempo': tempo,
            'words': clip_words
        })
        
        if c_idx < len(chunks) - 1:
            pause = gaps_after[c_idx]
        else:
            pause = inter_line_pauses.get(line_idx, 0.25)
            
        current_time = round(current_time + dur_clip + pause, 3)

total_scene_duration = math.ceil(current_time * 30) / 30

plan = {
    'version': 1,
    'duration': total_scene_duration,
    'clips': all_subclips
}

(EP / 'voice_plan.json').write_text(json.dumps(plan, indent=2) + '\n')
print(f"Generated voice_plan.json with {len(all_subclips)} subclips, total duration: {total_scene_duration:.2f}s")

# Execute narration assembly and timing reference build using prepare_voice under renders/
dest_dir = ROOT / 'renders/nemi_ep14/voice_r4'
if dest_dir.exists():
    shutil.rmtree(dest_dir)

result = prepare(plan, dest_dir)

# Promote to episode canonical locations
out_wav = EP / 'voice/narration.wav'
out_timing = EP / 'timing_reference.json'
shutil.copyfile(dest_dir / 'narration.wav', out_wav)
shutil.copyfile(dest_dir / 'timeline.json', out_timing)

print(f"Prepared narration.wav ({out_wav.stat().st_size} bytes) and timing_reference.json ({len(result['words'])} words)")

