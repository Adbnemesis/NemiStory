"""Generate this new promo with ADB's unchanged canonical CustomVoice settings."""
import os
import sys
import json
import hashlib
from pathlib import Path

os.environ['HF_HUB_OFFLINE'] = '1'
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))
from tools.tts.config import ADBVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine
import mlx_whisper
import soundfile as sf

FOLDER = Path(__file__).resolve().parent / 'voice' / 'source_r1'
FOLDER.mkdir(parents=True, exist_ok=True)
LINES = [
    ('opening', 'A message to every storytime animator.'),
    ('name', 'My name is ADB.'),
    ('truth', "I'm dangerously underwatched."),
    ('ambition', "And I'm gonna steal your watch time. By becoming the biggest storytime animator in the world."),
    ('ending', "I've got the stories. Now, where's the audience?"),
]
config = ADBVoiceConfig()
engine = None
records = []
for key, text in LINES:
    path = FOLDER / f'{key}.wav'
    record_path = path.with_suffix('.json')
    if not path.exists():
        if engine is None:
            engine = QwenVoiceDesignEngine(config)
        engine.synthesize_to_file(text, str(path), speed=1.0)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if record_path.exists():
        record = json.loads(record_path.read_text())
        assert record['sha256'] == digest and record['text'] == text
    else:
        result = mlx_whisper.transcribe(str(path), path_or_hf_repo='mlx-community/whisper-tiny', language='en', word_timestamps=True, verbose=False)
        words = [w for seg in result['segments'] for w in seg.get('words', [])]
        info = sf.info(path)
        record = dict(key=key, author='adb', text=text, file='res://' + str(path.relative_to(ROOT)), sha256=digest, speaker=config.speaker, identity_prompt=config.voice_design_prompt, sample_rate=info.samplerate, duration=info.duration, words=words, alignment_review_required=True)
        record_path.write_text(json.dumps(record, indent=2) + '\n')
    records.append(record)
    print('READY', key, round(record['duration'], 3), text, flush=True)
(FOLDER / 'source_words.json').write_text(json.dumps(records, indent=2) + '\n')
