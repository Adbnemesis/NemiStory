"""Prepare measured original Aiden recordings; no identity or tempo changes."""
import sys
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FOLDER = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))
from tools.storytime.prepare_voice import prepare

records = json.loads((FOLDER / 'voice/source_r1/source_words.json').read_text())
placements = {'opening': 0.0, 'name': 3.54, 'truth': 6.06, 'ambition': 9.5, 'ending': 18.56}
clips = []
turns = []
for record in records:
    words = []
    raw = record['words']
    i = 0
    while i < len(raw):
        word = dict(word=raw[i]['word'].strip(), start=raw[i]['start'], end=raw[i]['end'])
        # Whisper split compounds; preserve measured union bounds.
        if word['word'].lower() == 'story' and i + 1 < len(raw) and raw[i + 1]['word'].strip().lower() in {'-time', 'time'}:
            word.update(word='storytime', end=raw[i + 1]['end'])
            i += 1
        if word['word'].lower() == 'under' and i + 1 < len(raw) and raw[i + 1]['word'].strip().lower() == 'watch.':
            word.update(word='underwatched.', end=raw[i + 1]['end'])
            i += 1
        words.append(word)
        i += 1
    end = {'opening': 2.52, 'ambition': 4.8}.get(record['key'], record['duration'])
    at = placements[record['key']]
    clips.append(dict(author='adb', file=record['file'], sha256=record['sha256'], at=at, start=0.0, end=end, tempo=1.0, words=words))
    turns.append(dict(actor='adb', start=at, end=round(at+end, 6), text=record['text']))
plan = dict(version=1, duration=25.0, clips=clips)
(FOLDER / 'voice_plan_r2.json').write_text(json.dumps(plan, indent=2) + '\n')
temporary = ROOT / 'renders/message_to_storytime_adb/audio_r2'
if not temporary.exists():
    prepare(plan, temporary)
destination = FOLDER / 'voice/prepared_r2'
if not destination.exists():
    shutil.copytree(temporary, destination)
(FOLDER / 'voice/turns_r2.json').write_text(json.dumps(turns, indent=2) + '\n')
print(destination / 'timeline.json')
