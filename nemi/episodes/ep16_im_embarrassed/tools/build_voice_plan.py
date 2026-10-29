#!/usr/bin/env python3
"""Assemble EP16 R1 voice plan with explicit thought pauses and unchanged source identities.

No automatic gap removal: every internal source pause/breath is retained. Four
explanatory thoughts use modest pitch-preserving tempo; emotional thoughts keep
their original pace. Each output refuses replacement.
"""
import hashlib
import json
import math
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'tools/storytime'))
from prepare_voice import prepare

EP = Path(__file__).resolve().parent.parent
records = json.loads((EP / 'source_words.json').read_text())
tempos = [1.04, 1.08, 1.05, 1.05, 1.06, 1.08, 1.05, 1.02, 1.04]
pauses = [0.60, 0.70, 0.80, 0.70, 0.65, 0.70, 0.70, 0.80, 1.50]
out_plan = EP / 'voice_plan_r1.json'
out_timing = EP / 'timing_reference_r1.json'
out_lines = EP / 'timing_lines_r1.json'
out_audio = EP / 'voice/narration_r1.wav'
work = ROOT / 'renders/nemi_ep16_voice_r1'

for path in [out_plan, out_timing, out_lines, out_audio, work]:
    if path.exists():
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()

current = 0.50
clips = []
line_map = []
word_index = 0
for index, record in enumerate(records):
    words = [{'word': word['word'].strip(), 'start': round(word['start'], 6), 'end': round(word['end'], 6)}
             for word in record['words']]
    clip = {'author': 'nemi', 'file': record['file'], 'sha256': record['sha256'],
            'at': round(current, 6), 'start': 0.0, 'end': record['duration'],
            'tempo': tempos[index], 'words': words}
    clips.append(clip)
    end_at = current + record['duration'] / tempos[index]
    line_map.append({'source_line': index, 'script': record['text'],
                     'measured_transcript': ' '.join(word['word'] for word in words),
                     'at': clip['at'], 'end_at': round(end_at, 6),
                     'first_word_at': round(current + words[0]['start'] / tempos[index], 6),
                     'last_word_end_at': round(current + words[-1]['end'] / tempos[index], 6),
                     'tempo': tempos[index], 'pause_after': pauses[index],
                     'word_count': len(words), 'word_start_index': word_index,
                     'word_end_index_exclusive': word_index + len(words)})
    word_index += len(words)
    current = end_at + pauses[index]

duration = math.ceil(current * 30) / 30
if not 100 <= duration <= 130:
    raise RuntimeError(f'Runtime outside target range: {duration}')
plan = {'version': 1, 'duration': duration, 'clips': clips}
timeline = prepare(plan, work)
out_plan.write_text(json.dumps(plan, indent=2) + '\n')
shutil.copyfile(work / 'timeline.json', out_timing)
shutil.copyfile(work / 'narration.wav', out_audio)
out_lines.write_text(json.dumps({'version': 1, 'duration': duration,
                                'audio_sha256': hashlib.sha256(out_audio.read_bytes()).hexdigest(),
                                'word_count': word_index, 'lines': line_map}, indent=2) + '\n')
print(f'EP16 narration R1: {duration:.3f}s; {word_index} words; {len(clips)} whole-source clips')
for line in line_map:
    print(f"line {line['source_line']:02d}: {line['at']:.3f}–{line['end_at']:.3f}, "
          f"{line['tempo']:.2f}×, {line['word_count']} words, hold {line['pause_after']:.1f}s")
