"""Generate voice clips for Nemi's San Francisco solo trip and accident story."""
import json
import os
import sys
import hashlib
from pathlib import Path

os.environ['HF_HUB_OFFLINE'] = '1'
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT))

from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import NemiVoiceConfig
import mlx_whisper

folder = ROOT / 'renders/nemi_sf_accident/source_voice'
folder.mkdir(parents=True, exist_ok=True)

lines = [
    ('nemi', 'Wait. Do you know that feeling where you survive something genuinely terrifying... and then get completely taken out by the most normal thing on Earth?'),
    ('nemi', 'Okay, so I went on a solo trip to San Francisco. First time traveling completely by myself.'),
    ('nemi', 'And honestly? It was amazing. I walked twenty thousand steps a day and did literally every tourist activity.'),
    ('nemi', 'I went to the Apple event that happened recently. Felt like I was living in the year 2040.'),
    ('nemi', 'Then I visited the Golden Gate Bridge. Look at this view. Absolutely gorgeous.'),
    ('nemi', 'And then... I rode a Waymo. For context, it is a completely autonomous, driverless car.'),
    ('nemi', 'No driver in the front seat. The steering wheel was just turning by itself like a ghost.'),
    ('nemi', 'I was clutching the back seat the entire time thinking: this is it. This is my final day.'),
    ('nemi', 'But we arrived safely. Flawless ride. I thought the dangerous part of the trip was officially behind me.'),
    ('nemi', 'Trip is over. I am heading to the airport in a completely normal human-driven taxi.'),
    ('nemi', 'Five minutes. We are literally five minutes away from the departure terminal.'),
    ('nemi', "We are cruising down the highway at high speed, and out of nowhere, my driver slams the brakes."),
    ('nemi', 'We stop in time. But the car right behind us? Definitely did not.'),
    ('nemi', 'They plowed straight into our rear bumper. I was sitting in the back seat. My soul left my body.'),
    ('nemi', 'Two minutes later, highway patrol pulls up. Flashing red and blue lights everywhere.'),
    ('nemi', 'Officers walking around with flashlights, taking statements, inspecting the crushed bumper...'),
    ('nemi', 'And instead of being a calm, rational adult... I just completely broke down and started crying.'),
    ('nemi', 'Survive the futuristic driverless robot taxi without a scratch? Easy. Take a five-minute airport cab? Total disaster.')
]

engine = None
records = []
config = NemiVoiceConfig()

for i, (author, text) in enumerate(lines):
    path = folder / f'{i:02d}_{author}.wav'
    meta = path.with_suffix('.json')
    if not path.exists():
        if engine is None:
            engine = QwenVoiceDesignEngine(config)
        engine.config = config
        engine.synthesize_to_file(text, str(path), speed=1.0)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if meta.exists():
        record = json.loads(meta.read_text())
        assert record['sha256'] == digest and record['text'] == text
    else:
        result = mlx_whisper.transcribe(str(path), path_or_hf_repo='mlx-community/whisper-tiny', language='en', word_timestamps=True, verbose=False)
        words = [w for seg in result['segments'] for w in seg.get('words', [])]
        record = {
            'author': author,
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
    print(f'READY {i:02d} {author}: {text[:40]}...', flush=True)

(ROOT / 'nemi/episodes/ep09_sf_accident/source_words.json').write_text(json.dumps(records, indent=2) + '\n')
print('All voice records generated and saved to nemi/episodes/ep09_sf_accident/source_words.json')
