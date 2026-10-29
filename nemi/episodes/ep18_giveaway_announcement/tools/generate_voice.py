"""Create EP18 source recordings with unchanged canonical Nemi identity."""
import os, sys, json, hashlib
from pathlib import Path
os.environ['HF_HUB_OFFLINE'] = '1'
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT))
from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import NemiVoiceConfig
import mlx_whisper

FOLDER = Path(__file__).resolve().parents[1]
LINES = [
    ('00_intro', "Stop scrolling, you guys! We are officially hosting a Halloween giveaway!"),
    ('01_theme_drumroll', "And the prizes are amazing! Drumroll please!"),
    ('02_prizes', "Three prizes! A custom Halloween PFP, a personalized doodle drawn by me, and an official channel shoutout!"),
    ('03_requirements', "Entering is super simple! Join our Discord, say hi in introductions, subscribe on YouTube, and keep your DMs open!"),
    ('04_rules', "Rules: one entry each! No shadow clones or burner alts, I will find you! And winners have 48 hours to claim."),
    ('05_outro', "No spamming, be nice, and good luck everyone! Happy Halloween!"),
]

config = NemiVoiceConfig()
engine = None
records = []
source_dir = FOLDER / 'audio/source'
source_dir.mkdir(parents=True, exist_ok=True)

for stem, text in LINES:
    path = source_dir / f'{stem}.wav'
    meta = path.with_suffix('.json')
    if not path.exists():
        if engine is None:
            engine = QwenVoiceDesignEngine(config)
        duration = engine.synthesize_to_file(text, str(path), speed=1.0)
        print('SYNTHESIZED', stem, round(duration, 3), flush=True)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if meta.exists():
        record = json.loads(meta.read_text())
        assert record['sha256'] == digest and record['text'] == text
    else:
        result = mlx_whisper.transcribe(
            str(path),
            path_or_hf_repo='mlx-community/whisper-tiny',
            language='en',
            word_timestamps=True,
            verbose=False
        )
        words = [w for seg in result['segments'] for w in seg.get('words', [])]
        record = {
            'author': 'nemi',
            'text': text,
            'file': 'res://' + str(path.relative_to(ROOT)),
            'sha256': digest,
            'speaker': config.speaker,
            'identity_prompt': config.voice_design_prompt,
            'words': words,
            'alignment_review_required': True
        }
        meta.write_text(json.dumps(record, indent=2) + '\n')
    records.append(record)
    print('READY', stem, text, flush=True)

(FOLDER / 'source_words.json').write_text(json.dumps(records, indent=2) + '\n')
print("Successfully generated all voice lines and source_words.json!")
