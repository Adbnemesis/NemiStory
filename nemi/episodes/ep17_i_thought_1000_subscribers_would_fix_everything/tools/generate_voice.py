"""Generate protected canonical Sohee source recordings and measured ASR word times.

Existing audio is never overwritten. Identity and synthesis settings come from
the shared canonical NemiVoiceConfig unchanged. Models are cache-only.
"""
import hashlib
import json
import os
import sys
from pathlib import Path

os.environ['HF_HUB_OFFLINE'] = '1'
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT))

from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import NemiVoiceConfig
import soundfile as sf
import mlx_whisper

EP = Path(__file__).resolve().parent.parent
FOLDER = EP / 'voice/source'
FOLDER.mkdir(parents=True, exist_ok=True)
story = json.loads((EP / 'story.json').read_text())
config = NemiVoiceConfig()
engine = None
records = []

for index, text in enumerate(story['lines']):
    path = FOLDER / f'{index:02d}_nemi_r1.wav'
    meta = path.with_suffix('.json')
    if path.exists() and not meta.exists():
        raise RuntimeError(f'Existing audio without provenance: {path}; preserve and inspect before continuing.')
    if meta.exists():
        record = json.loads(meta.read_text())
        if record['text'] != text or hashlib.sha256(path.read_bytes()).hexdigest() != record['sha256']:
            raise RuntimeError(f'Protected source changed: {path}. Create a new revision rather than overwrite.')
    else:
        if engine is None:
            engine = QwenVoiceDesignEngine(config)
        print(f'SYNTHESIZING {index}: {text}', flush=True)
        engine.synthesize_to_file(text, str(path), speed=1.0)
        # Persist synthesis provenance before alignment, so interrupted ASR can resume safely.
        record = dict(author='nemi', text=text, file='res://' + str(path.relative_to(ROOT)),
                      sha256=hashlib.sha256(path.read_bytes()).hexdigest(), speaker=config.speaker,
                      model=config.repo_id, identity_prompt=config.voice_design_prompt,
                      synthesis_tempo=1.0, duration=sf.info(path).duration,
                      alignment_review_required=True)
        meta.write_text(json.dumps(record, indent=2) + '\n')
    if 'words' not in record:
        print(f'ALIGNING {index}', flush=True)
        result = mlx_whisper.transcribe(str(path), path_or_hf_repo='mlx-community/whisper-tiny',
                                       language='en', word_timestamps=True, verbose=False)
        record['words'] = [word for segment in result['segments'] for word in segment.get('words', [])]
        record['asr_text'] = result['text']
        meta.write_text(json.dumps(record, indent=2) + '\n')
    records.append(record)
    (EP / 'source_words.json').write_text(json.dumps(records, indent=2) + '\n')
    print(f'READY {index} {record["duration"]:.3f}s {len(record["words"])} words', flush=True)

print(f'ALL SOURCES READY {sum(r["duration"] for r in records):.3f}s', flush=True)
