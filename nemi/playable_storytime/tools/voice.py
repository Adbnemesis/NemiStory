#!/usr/bin/env python3
"""Generate and align canonical Nemi narration without writing outside this project.

Run with the existing project .venv/bin/python. Model preparation copies already
cached weights; it never downloads a replacement or changes a voice setting.
"""
from __future__ import annotations

import argparse
from dataclasses import asdict
import hashlib
import json
import math
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
from source_edits import (read_source_edit_plan, validate_source_edits,
                          kept_sample_ranges, processed_stem)

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
CACHE = ROOT / '.cache'
MODELS = CACHE / 'models'
MODEL_NAMES = {
    'qwen': 'mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16',
    'whisper': 'mlx-community/whisper-tiny',
}
CANONICAL_SHA256 = {
    'config.py': 'e40065f248800836e45e48b95af92a745bf1564c17552c1a2eb4a87956223e66',
    'engine.py': '768dc188162a50884d1d8f97bc4614ffc3b9294a8bb526edec39fef7dbe9736a',
    'pacing.py': '74112e48deb29eb30cf60a26afb11346d56594cb5b0de8f42429bf566022404f',
}


def setup_environment():
    """Constrain caches and temp files before importing any ML packages."""
    paths = {
        'TMPDIR': CACHE / 'tmp',
        'XDG_CACHE_HOME': CACHE / 'xdg',
        'HF_HOME': CACHE / 'huggingface',
        'HF_HUB_CACHE': CACHE / 'huggingface/hub',
        'HUGGINGFACE_HUB_CACHE': CACHE / 'huggingface/hub',
        'TRANSFORMERS_CACHE': CACHE / 'transformers',
        'TORCH_HOME': CACHE / 'torch',
        'NUMBA_CACHE_DIR': CACHE / 'numba',
        'MPLCONFIGDIR': CACHE / 'matplotlib',
        'PYTHONPYCACHEPREFIX': CACHE / 'pycache',
    }
    for key, path in paths.items():
        path.mkdir(parents=True, exist_ok=True)
        os.environ[key] = str(path)
    os.environ['PYTHONDONTWRITEBYTECODE'] = '1'
    os.environ['HF_HUB_OFFLINE'] = '1'
    os.environ['TRANSFORMERS_OFFLINE'] = '1'
    os.environ['HF_HUB_DISABLE_TELEMETRY'] = '1'
    os.environ['TOKENIZERS_PARALLELISM'] = 'false'
    sys.dont_write_bytecode = True
    tempfile.tempdir = str(CACHE / 'tmp')
    sys.path.insert(0, str(ROOT))


def sha(path):
    digest = hashlib.sha256()
    with Path(path).open('rb') as source:
        for block in iter(lambda: source.read(4 * 1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def save(path, data):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + '.tmp')
    temporary.write_text(json.dumps(data, indent=2) + '\n')
    temporary.replace(path)


def safe(path):
    resolved = Path(path).resolve()
    if not resolved.is_relative_to(ROOT):
        raise ValueError('All new voice outputs must remain inside playable_storytime.')
    return resolved


def res(path):
    return 'res://' + str(safe(path).relative_to(ROOT))


def prepare_models():
    """Copy the existing exact snapshots, dereferencing original cache links."""
    records = {}
    source_cache = Path.home() / '.cache/huggingface/hub'
    MODELS.mkdir(parents=True, exist_ok=True)
    for label, repo_id in MODEL_NAMES.items():
        snapshots = source_cache / ('models--' + repo_id.replace('/', '--')) / 'snapshots'
        candidates = sorted(p for p in snapshots.glob('*') if p.is_dir())
        if not candidates:
            raise FileNotFoundError(f'Existing cached {repo_id} snapshot is absent; no download attempted.')
        source = candidates[-1]
        destination = MODELS / label
        old_record_path = MODELS / f'{label}.provenance.json'
        if destination.exists():
            if not old_record_path.is_file():
                raise ValueError(f'Unrecorded model folder {destination}; preserve and inspect it before reuse.')
            record = json.loads(old_record_path.read_text())
            for entry in record['files']:
                target = destination / entry['path']
                if not target.is_file() or sha(target) != entry['sha256']:
                    raise ValueError(f'Copied model file changed: {target}')
            records[label] = record
            print(f'VERIFIED MODEL {label}', flush=True)
            continue
        staging = MODELS / f'.{label}.copying'
        if staging.exists():
            raise ValueError(f'Previous model copy remains at {staging}; inspect rather than overwrite.')
        shutil.copytree(source, staging, symlinks=False)
        files = []
        for copied in sorted(staging.rglob('*')):
            if copied.is_file():
                relative = copied.relative_to(staging)
                original = source / relative
                digest = sha(copied)
                if digest != sha(original):
                    raise RuntimeError(f'Model copy hash mismatch: {relative}')
                files.append({'path': str(relative), 'bytes': copied.stat().st_size, 'sha256': digest})
        staging.rename(destination)
        record = {'repo_id': repo_id, 'source_snapshot': str(source), 'snapshot_revision': source.name,
                  'destination': str(destination.relative_to(ROOT)), 'method': 'existing local snapshot; dereferenced byte-identical copy; no download',
                  'files': files}
        save(old_record_path, record)
        records[label] = record
        print(f'COPIED MODEL {label}: {sum(f["bytes"] for f in files)} bytes', flush=True)
    return records


def read_dialogue(episode):
    episode = safe(ROOT / episode)
    data = json.loads((episode / 'scripts/dialogue.json').read_text())
    duration = data.get('duration', 300)
    if not isinstance(duration, (int, float)) or not math.isfinite(duration) or duration <= 0:
        raise ValueError('Dialogue duration must be a finite positive number.')
    clips = data.get('clips')
    if not isinstance(clips, list) or not clips:
        raise ValueError('dialogue.json needs a nonempty clips list.')
    previous_end = 0
    ids = set()
    for clip in clips:
        required = {'id', 'text', 'at', 'window_end', 'tempo'}
        if set(clip) != required:
            raise ValueError(f'Dialogue clip fields must be {sorted(required)}: {clip.get("id")}')
        if not re.fullmatch(r'[a-zA-Z0-9_-]+', clip['id']) or clip['id'] in ids:
            raise ValueError('Clip IDs must be unique safe filenames.')
        ids.add(clip['id'])
        if not isinstance(clip['text'], str) or not clip['text'].strip():
            raise ValueError(f'Empty spoken text: {clip["id"]}')
        if any(isinstance(clip[k], bool) or not isinstance(clip[k], (int, float)) or not math.isfinite(clip[k]) for k in ['at', 'window_end', 'tempo']):
            raise ValueError(f'Nonfinite clip timing: {clip["id"]}')
        if not previous_end <= clip['at'] < clip['window_end'] <= duration:
            raise ValueError(f'Overlapping or out-of-range spoken window: {clip["id"]}')
        previous_end = clip['window_end']
        if not 1 <= clip['tempo'] <= 1.15:
            raise ValueError('Storytime tempo must remain 1.00–1.15; audition all pacing.')
    return episode, data, float(duration)


def align(path, model_path):
    import mlx_whisper
    result = mlx_whisper.transcribe(str(path), path_or_hf_repo=str(model_path), language='en',
                                    word_timestamps=True, verbose=False, condition_on_previous_text=False)
    raw = [word for segment in result['segments'] for word in segment.get('words', [])]
    if not raw:
        raise ValueError(f'No measured word alignment for {path.name}; no guessed fractions were written.')
    # The recognizer may return zero-length punctuation tokens. Retain them in
    # raw_words for review; only genuine positive intervals drive visible cues.
    words = []
    previous = 0.0
    for word in raw:
        start, end = float(word['start']), float(word['end'])
        if not word['word'].strip() or end <= start:
            continue
        if start < previous - .001:
            raise ValueError(f'Overlapping ASR word intervals in {path.name}; review required.')
        words.append({'actor': 'nemi', 'word': word['word'].strip(), 'start': start, 'end': end,
                      'confidence': float(word.get('probability', 0))})
        previous = end
    if not words:
        raise ValueError(f'Only zero-length alignment intervals for {path.name}.')
    return {'audio_sha256': sha(path), 'alignment_kind': 'local Whisper Tiny measured approximate word boundaries; not phonemes',
            'review_required': True, 'transcript': result.get('text', ''), 'raw_words': raw, 'words': words}


def generate(episode_arg):
    for name, expected in CANONICAL_SHA256.items():
        if sha(ROOT / 'engine/voice/canonical' / name) != expected:
            raise ValueError(f'Canonical voice implementation changed: {name}; no unapproved voice generated.')
    import numpy as np
    import soundfile as sf
    from engine.voice.canonical.config import NemiVoiceConfig
    from engine.voice.canonical.engine import QwenVoiceDesignEngine
    from engine.voice.canonical.pacing import tempo_array

    episode, dialogue, duration = read_dialogue(episode_arg)
    edit_plan_hash, edit_entries = read_source_edit_plan(episode, [c['id'] for c in dialogue['clips']])
    for label in MODEL_NAMES:
        if not (MODELS / label).is_dir() or not (MODELS / f'{label}.provenance.json').is_file():
            raise ValueError('Run voice.py setup-models first; no download or fallback is permitted.')
    folder = episode / 'audio'
    source_folder = folder / 'source'
    processed_folder = folder / 'processed'
    source_folder.mkdir(parents=True, exist_ok=True)
    processed_folder.mkdir(parents=True, exist_ok=True)
    narration_path = folder / 'narration.wav'
    timeline_path = folder / 'timeline.json'
    dialogue_hash = sha(episode / 'scripts/dialogue.json')
    if narration_path.exists() or timeline_path.exists():
        if narration_path.is_file() and timeline_path.is_file():
            existing = json.loads(timeline_path.read_text())
            if (existing.get('dialogue_sha256') == dialogue_hash
                    and existing.get('source_edit_plan_sha256') == edit_plan_hash
                    and existing.get('audio_sha256') == sha(narration_path)):
                print(f'REUSING VERIFIED NARRATION {narration_path}', flush=True)
                return existing
        raise ValueError('Narration exists for another revision; preserve it and choose a new episode/audio revision.')
    config = NemiVoiceConfig()
    identity = asdict(config)
    config.repo_id = str(MODELS / 'qwen')
    engine = None
    timeline = {'version': 1, 'duration': duration, 'dialogue_sha256': dialogue_hash,
                'source_edit_plan_sha256': edit_plan_hash,
                'identity_policy': 'new canonical Sohee recordings; unchanged model weights/speaker/instruction; only explicit quiet-gap source cuts and pitch-preserving tempo',
                'alignment_kind': 'independent local Whisper Tiny alignment of final processed clips; approximate words, not phonemes',
                'review_required': True, 'clips': [], 'words': []}
    narration = np.zeros(round(duration * config.sample_rate), dtype=np.float32)
    failures = []
    for i, clip in enumerate(dialogue['clips']):
        key = hashlib.sha256((clip['text'] + json.dumps(identity, sort_keys=True)).encode()).hexdigest()[:12]
        stem = f'{clip["id"]}_{key}'
        source_path = source_folder / f'{stem}.wav'
        source_meta = source_folder / f'{stem}.json'
        if source_path.exists() and source_meta.exists():
            record = json.loads(source_meta.read_text())
            if record['text'] != clip['text'] or record['sha256'] != sha(source_path):
                raise ValueError(f'Existing source changed: {clip["id"]}')
        elif source_path.exists() or source_meta.exists():
            raise ValueError(f'Incomplete source record for {clip["id"]}; inspect preserved artifacts.')
        else:
            if engine is None:
                engine = QwenVoiceDesignEngine(config)
            engine.synthesize_to_file(clip['text'], str(source_path), speed=1.0)
            record = {'id': clip['id'], 'author': 'nemi', 'text': clip['text'], 'file': res(source_path),
                      'sha256': sha(source_path), 'identity': identity,
                      'model_provenance': '.cache/models/qwen.provenance.json',
                      'source_tempo': 1.0, 'new_recording': True, 'listening_review': 'pending'}
            save(source_meta, record)
        source_samples, rate = sf.read(source_path, dtype='float32')
        if rate != config.sample_rate or source_samples.ndim != 1:
            raise ValueError('Canonical source must be mono 24000Hz.')
        source_alignment = source_path.with_suffix('.words.json')
        if not source_alignment.exists():
            save(source_alignment, align(source_path, MODELS / 'whisper'))
        elif json.loads(source_alignment.read_text())['audio_sha256'] != record['sha256']:
            raise ValueError('Source alignment hash is stale.')
        measured_source = json.loads(source_alignment.read_text())
        edits = validate_source_edits(edit_entries.get(clip['id']), record['sha256'],
                                      source_samples, rate, measured_source['words'])
        edited_source = (np.concatenate([source_samples[a:b] for a, b in
                         kept_sample_ranges(len(source_samples), edits)]) if edits else source_samples)
        paced_stem = processed_stem(stem, clip['tempo'], edit_plan_hash, bool(edits))
        processed_path = processed_folder / f'{paced_stem}.wav'
        if not processed_path.exists():
            paced = tempo_array(edited_source, rate, clip['tempo'])
            sf.write(processed_path, paced, rate, subtype='FLOAT')
        final, final_rate = sf.read(processed_path, dtype='float32')
        if final_rate != rate:
            raise ValueError('Pacing altered sample rate.')
        actual_duration = len(final) / rate
        source_duration = len(source_samples) / rate
        final_alignment_path = processed_path.with_suffix('.words.json')
        if not final_alignment_path.exists():
            save(final_alignment_path, align(processed_path, MODELS / 'whisper'))
        final_alignment = json.loads(final_alignment_path.read_text())
        if final_alignment['audio_sha256'] != sha(processed_path):
            raise ValueError('Final alignment hash is stale.')
        clip_record = {'id': clip['id'], 'author': 'nemi', 'file': res(source_path), 'sha256': record['sha256'],
                       'text': clip['text'], 'at': clip['at'], 'start': 0, 'end': source_duration,
                       'tempo': clip['tempo'], 'end_at': round(clip['at'] + actual_duration, 6),
                       'window_end': clip['window_end'], 'processed_file': res(processed_path),
                       'processed_sha256': sha(processed_path), 'source_duration': source_duration,
                       'edited_source_duration': len(edited_source) / rate,
                       'source_edit_plan_sha256': edit_plan_hash,
                       'source_edits': edits,
                       'final_duration': actual_duration, 'alignment': res(final_alignment_path),
                       'listening_review': 'pending', 'pace_review': 'pending'}
        timeline['clips'].append(clip_record)
        if clip['at'] + actual_duration > clip['window_end'] + .001:
            failures.append({'id': clip['id'], 'measured_seconds': round(actual_duration, 4),
                             'available_seconds': round(clip['window_end'] - clip['at'], 4),
                             'overrun_seconds': round(clip['at'] + actual_duration - clip['window_end'], 4)})
        else:
            offset = round(clip['at'] * rate)
            narration[offset:offset + len(final)] += final
            for word in final_alignment['words']:
                timeline['words'].append({'actor': 'nemi', 'word': word['word'],
                    'start': round(clip['at'] + word['start'], 6), 'end': round(clip['at'] + word['end'], 6),
                    'confidence': word['confidence'], 'clip_id': clip['id']})
        save(folder / 'generation_progress.json', {'dialogue_sha256': dialogue_hash, 'completed': i + 1,
             'total': len(dialogue['clips']), 'clips': timeline['clips'], 'overruns': failures,
             'listening_review': 'pending'})
        print(f'VOICE {i+1}/{len(dialogue["clips"])} {clip["id"]}: source {source_duration:.3f}s, final {actual_duration:.3f}s, window {clip["window_end"]-clip["at"]:.3f}s', flush=True)
    if failures:
        save(folder / 'overruns.json', failures)
        raise ValueError('Measured dialogue does not fit authored windows; no truncated narration saved: ' + json.dumps(failures))
    if np.max(np.abs(narration)) >= 1:
        raise ValueError('Narration exceeds full scale; inspect sources before mixing.')
    sf.write(narration_path, narration, config.sample_rate, subtype='FLOAT')
    timeline['audio_sha256'] = sha(narration_path)
    save(timeline_path, timeline)
    save(folder / 'voice_provenance.json', {'identity': identity, 'copied_model': '.cache/models/qwen.provenance.json',
        'source_edit_plan_sha256': edit_plan_hash,
        'source_edit_policy': 'Only explicit hash-bound quiet-gap ranges; 60ms measured word edges and energy limits; independently realigned final processed audio',
        'copied_alignment_model': '.cache/models/whisper.provenance.json', 'dialogue_sha256': dialogue_hash,
        'audio_sha256': timeline['audio_sha256'], 'duration': duration, 'sample_rate': config.sample_rate,
        'channels': 1, 'no_pitch_formant_eq_or_identity_change': True, 'listening_review': 'pending',
        'alignment_review': 'pending; ASR words are approximate and can differ from script',
        'canonical_copies': {name: sha(ROOT / 'engine/voice/canonical' / name) for name in ['config.py','engine.py','pacing.py']}})
    print(f'COMPLETE NARRATION {narration_path}', flush=True)
    return timeline


def check(episode_arg):
    """Revalidate saved hashes, media and timing without loading a voice model."""
    episode, dialogue, duration = read_dialogue(episode_arg)
    edit_plan_hash, edit_entries = read_source_edit_plan(episode, [c['id'] for c in dialogue['clips']])
    folder = episode / 'audio'
    timeline = json.loads((folder / 'timeline.json').read_text())
    narration = folder / 'narration.wav'
    if timeline.get('dialogue_sha256') != sha(episode / 'scripts/dialogue.json'):
        raise ValueError('Dialogue changed after narration assembly; rebuild this audio revision.')
    if timeline.get('audio_sha256') != sha(narration):
        raise ValueError('Narration changed after alignment.')
    if timeline.get('source_edit_plan_sha256') != edit_plan_hash:
        raise ValueError('Source edit plan changed after narration assembly.')
    for name, expected in CANONICAL_SHA256.items():
        if sha(ROOT / 'engine/voice/canonical' / name) != expected:
            raise ValueError(f'Canonical voice copy changed: {name}')
    probe = json.loads(subprocess.check_output(['ffprobe', '-v', 'error', '-show_streams', '-show_format', '-of', 'json', str(narration)]))
    stream = probe['streams'][0]
    if int(stream['sample_rate']) != 24000 or int(stream['channels']) != 1 or stream['codec_name'] != 'pcm_f32le':
        raise ValueError('Narration must be mono 24000Hz floating-point PCM WAV.')
    if abs(float(probe['format']['duration']) - duration) > 1 / 24000:
        raise ValueError('Narration duration differs from the complete authored timeline.')
    if len(timeline['clips']) != len(dialogue['clips']):
        raise ValueError('Narration clip count differs from dialogue.')
    for clip, scripted in zip(timeline['clips'], dialogue['clips']):
        if any(clip[key] != scripted[key] for key in ['id', 'text', 'at', 'tempo', 'window_end']):
            raise ValueError(f'Stale clip placement or text: {clip["id"]}')
        for key, hash_key in [('file', 'sha256'), ('processed_file', 'processed_sha256')]:
            path = safe(ROOT / clip[key].removeprefix('res://'))
            if sha(path) != clip[hash_key]:
                raise ValueError(f'Voice source changed: {clip["id"]}')
        source = safe(ROOT / clip['file'].removeprefix('res://'))
        source_alignment = json.loads(source.with_suffix('.words.json').read_text())
        if source_alignment['audio_sha256'] != clip['sha256']:
            raise ValueError('Source word alignment hash is stale.')
        import soundfile as sf
        source_samples, source_rate = sf.read(source, dtype='float32')
        edits = validate_source_edits(edit_entries.get(clip['id']), clip['sha256'],
                                      source_samples, source_rate, source_alignment['words'])
        if clip.get('source_edit_plan_sha256') != edit_plan_hash or clip.get('source_edits', []) != edits:
            raise ValueError('Saved source edit evidence differs from the current plan/recording.')
        expected_stem = processed_stem(source.stem, clip['tempo'], edit_plan_hash, bool(edits))
        if Path(clip['processed_file']).stem != expected_stem:
            raise ValueError('Processed recording does not match the current edit plan.')
        alignment = json.loads(safe(ROOT / clip['alignment'].removeprefix('res://')).read_text())
        if alignment['audio_sha256'] != clip['processed_sha256']:
            raise ValueError(f'Stale final alignment: {clip["id"]}')
        if clip['end_at'] > clip['window_end'] + .001:
            raise ValueError(f'Clip exceeds its authored window: {clip["id"]}')
    previous = 0
    for word in timeline['words']:
        if not previous <= word['start'] < word['end'] <= duration or word['actor'] != 'nemi':
            raise ValueError('Final measured words overlap or exceed the scene clock.')
        previous = word['end']
    result = {'passed': True, 'duration': duration, 'sample_rate': 24000, 'channels': 1,
              'clips': len(timeline['clips']), 'words': len(timeline['words']),
              'audio_sha256': timeline['audio_sha256'], 'dialogue_sha256': timeline['dialogue_sha256'],
              'source_edit_plan_sha256': edit_plan_hash,
              'explicit_source_cuts': sum(len(c.get('source_edits', [])) for c in timeline['clips']),
              'checks': ['canonical implementation hashes', 'dialogue text and placement', 'source and final audio hashes',
                         'processed alignment hashes', 'explicit quiet-gap cut bounds/word edges/energy/hash',
                         'authored window fit', 'ordered measured scene-clock words', 'full-duration PCM format'],
              'listening_review': 'pending; automated checks do not establish perceptual quality'}
    save(folder / 'voice_check.json', result)
    print(json.dumps(result, indent=2), flush=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    commands.add_parser('setup-models', help='Copy and verify the already installed local model snapshots.')
    generate_parser = commands.add_parser('generate', help='Generate unchanged Sohee, align and assemble an episode.')
    generate_parser.add_argument('--episode', default='episodes/episode_001')
    check_parser = commands.add_parser('check', help='Verify existing narration, provenance and measured timing without ML loading.')
    check_parser.add_argument('--episode', default='episodes/episode_001')
    args = parser.parse_args()
    setup_environment()
    try:
        if args.command == 'setup-models':
            prepare_models()
        elif args.command == 'check':
            check(args.episode)
        else:
            generate(args.episode)
    except (ValueError, FileNotFoundError, RuntimeError) as error:
        parser.exit(1, str(error) + '\n')


if __name__ == '__main__':
    main()
