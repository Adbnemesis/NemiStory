#!/usr/bin/env python3
"""Pace approved recordings into a NEW narration; never resynthesize a voice.

Plan: version=1, duration, clips[{author,file,sha256,at,start,end,tempo,words}].
Each word is {word,start,end} in source-file seconds. Pause placement is explicit
through clip.at. Clip boundaries are authored, never automatically silence-cut.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import subprocess
import sys
import tempfile
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools.tts.pacing import check_tempo


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def number(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value)


def prepare(plan, destination):
    destination = Path(destination).resolve()
    if not destination.is_relative_to(ROOT/'renders') or destination.exists():
        raise ValueError('Choose a new, nonexistent audio folder under renders/; recordings are protected.')
    if set(plan) != {'version', 'duration', 'clips'} or plan['version'] != 1 or not number(plan['duration']) or plan['duration'] <= 0:
        raise ValueError('Plan requires version=1, positive duration, clips')
    if not isinstance(plan['clips'], list) or not plan['clips']:
        raise ValueError('At least one approved voice clip is required')
    timeline = {'version': 1, 'duration': plan['duration'], 'identity_policy': 'original-recordings; tempo-only; no synthesis, pitch shift, EQ or voice replacement',
                'alignment_kind': 'source_word_times_transformed; review against final recording', 'clips': [], 'words': []}
    previous = 0
    checked = []
    for clip in plan['clips']:
        if set(clip) != {'author', 'file', 'sha256', 'at', 'start', 'end', 'tempo', 'words'}:
            raise ValueError('Unknown or missing voice clip fields')
        if clip['author'] not in {'nemi', 'adb'} or not isinstance(clip['file'], str) or not clip['file'].startswith('res://'):
            raise ValueError('Clip needs nemi/adb and a res:// source')
        source = (ROOT/clip['file'][6:]).resolve()
        if not source.is_relative_to(ROOT) or not source.is_file() or digest(source) != clip['sha256']:
            raise ValueError('Voice source missing or changed; approve and annotate the exact original recording')
        tempo = check_tempo(clip['tempo'])
        if not 1 <= tempo <= 1.15:
            raise ValueError('New storytime pacing accepts 1.00–1.15; keep identity and audition modest changes')
        probe = json.loads(subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'json', str(source)]))
        if not all(number(clip[k]) for k in ['at', 'start', 'end']) or not 0 <= clip['start'] < clip['end'] <= float(probe['format']['duration']) + .001:
            raise ValueError('Invalid source clip bounds')
        length = (clip['end'] - clip['start']) / tempo
        if clip['at'] < previous or clip['at'] + length > plan['duration']:
            raise ValueError('Voice clips overlap or extend beyond the scene')
        previous = clip['at'] + length
        word_end = clip['start']
        if not clip['words']:
            raise ValueError('Supply measured source word times; never estimate by sentence fractions')
        for word in clip['words']:
            if set(word) != {'word', 'start', 'end'} or not isinstance(word['word'], str) or not word['word'].strip() or not all(number(word[k]) for k in ['start', 'end']) or not word_end <= word['start'] < word['end'] <= clip['end'] or word['start'] < clip['start']:
                raise ValueError('Word times must be ordered, nonoverlapping and inside their source clip')
            word_end = word['end']
            timeline['words'].append({'actor': clip['author'], 'word': word['word'].strip(),
                                      'start': round(clip['at'] + (word['start'] - clip['start']) / tempo, 6),
                                      'end': round(clip['at'] + (word['end'] - clip['start']) / tempo, 6)})
        checked.append((clip, source, length))
    # All inputs are checked before writing. Build atomically; no half-complete output.
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='approved-voice-', dir=destination.parent) as folder:
        work = Path(folder); inputs = []; filters = []; labels = []
        for i, (clip, source, length) in enumerate(checked):
            result = work/f'{i:02d}_{clip["author"]}.wav'
            chain = f'atrim=start={clip["start"]}:end={clip["end"]},asetpts=PTS-STARTPTS'
            if clip['tempo'] != 1: chain += f',atempo={clip["tempo"]}'
            chain += f',apad,atrim=duration={length}'
            subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', str(source), '-af', chain, '-c:a', 'pcm_f32le', str(result)], check=True)
            record = dict(clip); record.pop('words'); record.update(end_at=round(clip['at']+length, 6), processed_sha256=digest(result))
            timeline['clips'].append(record)
            inputs += ['-i', str(result)]
            filters.append(f'[{i}:a]adelay={round(clip["at"]*1000)}:all=1[v{i}]'); labels.append(f'[v{i}]')
        filters.append(''.join(labels) + f'amix=inputs={len(labels)}:normalize=0:duration=longest,apad,atrim=duration={plan["duration"]}[out]')
        narration = work/'narration.wav'
        subprocess.run(['ffmpeg', '-v', 'error', '-y', *inputs, '-filter_complex', ';'.join(filters), '-map', '[out]', '-c:a', 'pcm_f32le', str(narration)], check=True)
        timeline['audio_sha256'] = digest(narration)
        (work/'timeline.json').write_text(json.dumps(timeline, indent=2)+'\n')
        Path(folder).rename(destination)
    return timeline


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    try: prepare(json.loads(args.plan.read_text()), args.output)
    except (ValueError, KeyError) as error: parser.exit(1, str(error)+'\n')
    print(args.output/'timeline.json')
