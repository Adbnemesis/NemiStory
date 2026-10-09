"""Generate tightened EP02 dialogue with canonical Aiden; preserve sources and extract word timings."""
import os, sys, json, hashlib, re
from pathlib import Path

os.environ['HF_HUB_OFFLINE'] = '1'
os.environ['TOKENIZERS_PARALLELISM'] = 'false'

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT))

from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import ADBVoiceConfig
import mlx_whisper

FOLDER = Path(__file__).resolve().parents[1]
OUT = ROOT / 'renders/adb_meet_girlfriend/source_voice_r2'
OUT.mkdir(parents=True, exist_ok=True)

paragraphs = (FOLDER / 'narration.txt').read_text().strip().split('\n\n')
assert len(paragraphs) == 25, f"Expected 25 paragraphs, got {len(paragraphs)}"

ranges = [
    (0, 2),   # 00: Hook callback (intro potato)
    (2, 3),   # 01: Name reveal (Nemi)
    (3, 4),   # 02: Prepare to be disappointed
    (4, 5),   # 03: 2020 Middle of Covid
    (5, 6),   # 04: Black Zoom squares & zero percent
    (6, 7),   # 05: Dorm mystery punch
    (7, 8),   # 06: Thermodynamics in corner
    (8, 9),   # 07: Nemi approach and math question
    (9, 10),  # 08: ADB survival instincts reply
    (10, 11), # 09: Handing the red cup
    (11, 12), # 10: Mistake number one
    (12, 13), # 11: One drink turned into three
    (13, 14), # 12: Midnight animation vs table tennis debate
    (14, 15), # 13: Balcony floor until 4 AM
    (15, 16), # 14: Talking about college stress & anime
    (16, 17), # 15: And then things happened
    (17, 18), # 16: Drunk honest and kissed
    (18, 19), # 17: Next morning mild panic
    (19, 20), # 18: Mature adults won't make it weird
    (20, 21), # 19: Totally normal friends
    (21, 22), # 20: That was five years ago
    (22, 23), # 21: Together ever since
    (23, 24), # 22: Stealing hoodies & roasting posture
    (24, 25), # 23: Best mistake I ever made
]

engine = None
records = []
config = ADBVoiceConfig()

for i, (a, b) in enumerate(ranges):
    text = ' '.join(paragraphs[a:b])
    wav = OUT / f'{i:02d}_adb.wav'
    meta = wav.with_suffix('.json')
    
    if not wav.exists():
        if engine is None:
            engine = QwenVoiceDesignEngine(config)
        duration = engine.synthesize_to_file(text, str(wav), speed=1.0)
        print(f'GENERATED {i:02d} ({round(duration, 3)}s): {text[:50]}...', flush=True)
    
    digest = hashlib.sha256(wav.read_bytes()).hexdigest()
    
    if meta.exists():
        record = json.loads(meta.read_text())
        assert record['sha256'] == digest and record['text'] == text
    else:
        result = mlx_whisper.transcribe(
            str(wav),
            path_or_hf_repo='mlx-community/whisper-tiny',
            language='en',
            word_timestamps=True,
            verbose=False
        )
        words = [w for s in result['segments'] for w in s.get('words', [])]
        record = {
            'author': 'adb',
            'text': text,
            'file': 'res://' + str(wav.relative_to(ROOT)),
            'sha256': digest,
            'speaker': config.speaker,
            'model': config.repo_id,
            'identity_prompt': config.voice_design_prompt,
            'tempo': 1.0,
            'words': words,
            'alignment_review_required': True
        }
        meta.write_text(json.dumps(record, indent=2) + '\n')
    
    records.append(record)
    print(f'READY {i:02d}: {record["text"][:50]}...', flush=True)

(FOLDER / 'source_words.json').write_text(json.dumps(records, indent=2) + '\n')
print(f'Successfully processed all {len(records)} voice clips into source_words.json!')
