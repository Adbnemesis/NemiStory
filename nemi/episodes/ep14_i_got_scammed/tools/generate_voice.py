"""Generate canonical Sohee voice for EP14 I Got Scammed with Whisper word timestamps."""
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
folder = EP / 'voice/source'
folder.mkdir(parents=True, exist_ok=True)
story = json.loads((EP / 'story.json').read_text())

config = NemiVoiceConfig()
engine = None
records = []

for i, text in enumerate(story['lines']):
    path = folder / f'{i:02d}_nemi.wav'
    meta = path.with_suffix('.json')
    needs_gen = not path.exists()
    if meta.exists():
        try:
            old_rec = json.loads(meta.read_text())
            if old_rec.get('text') != text:
                needs_gen = True
        except Exception:
            needs_gen = True
    else:
        needs_gen = True

    if needs_gen:
        if engine is None:
            engine = QwenVoiceDesignEngine(config)
        print(f"Synthesizing line {i}: {text[:40]}...")
        engine.synthesize_to_file(text, str(path), speed=1.0)
        if meta.exists():
            meta.unlink()
    
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    record = None
    if meta.exists():
        try:
            r = json.loads(meta.read_text())
            if r.get('sha256') == digest and r.get('text') == text:
                record = r
        except Exception:
            pass

    if record is None:
        print(f"Transcribing line {i} with Whisper...")
        result = mlx_whisper.transcribe(
            str(path),
            path_or_hf_repo='mlx-community/whisper-tiny',
            language='en',
            word_timestamps=True,
            verbose=False
        )
        words = [w for seg in result['segments'] for w in seg.get('words', [])]
        record = dict(
            author='nemi',
            text=text,
            file='res://' + str(path.relative_to(ROOT)),
            sha256=digest,
            speaker=config.speaker,
            identity_prompt=config.voice_design_prompt,
            words=words,
            duration=sf.info(path).duration,
            alignment_review_required=True
        )
        meta.write_text(json.dumps(record, indent=2) + '\n')
    
    records.append(record)
    (EP / 'source_words.json').write_text(json.dumps(records, indent=2) + '\n')
    print('READY', i, round(record['duration'], 2), text[:35], flush=True)

print("All voice sources generated and transcribed successfully!")
