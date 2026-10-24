"""Episode-local performance retakes, preserving canonical voice identity/settings.

The exact identity prompt is prepended unchanged. Only a separately recorded
delivery direction is added in response to the user's explicit performance
correction. This does not modify shared configuration, speaker or model.
"""
import os
os.environ['HF_HUB_OFFLINE'] = '1'
import sys
import json
import hashlib
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT))
from tools.tts.config import NemiVoiceConfig, ADBVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine
import mlx.core as mx
import soundfile as sf

SCRIPTS = {
    'nemi': "A message to every storytime animator. My name's Nemi. I'm an undiscovered menace. And I'm gonna steal your watch time. By becoming the biggest storytime animator in the world. I'm already the most dramatic. Now I just gotta be the biggest.",
    'adb': "A message to every storytime animator. My name is A D B. I'm dangerously underwatched. And I'm gonna steal your watch time. By becoming the biggest storytime animator in the world. I've already got the stories. Now I just gotta be the biggest.",
}
DIRECTIONS = {
    'take_a': (
        "Performance direction for this promotional mock-challenge: Speak directly to other creators with cocky, mischievous confidence. "
        "This is a funny boast and playful threat, with real attitude and conviction. The opening is a firm pointed announcement. "
        "Say the name with proud swagger. Deliver the self-description with a knowing smirk. "
        "Lean hard into STEAL and YOUR WATCH TIME, then build with excited conviction through BIGGEST and IN THE WORLD. "
        "After that peak, snap into a drier, quieter, matter-of-fact comic payoff. Keep natural flowing connected speech, "
        "crisp consonants, strong stress contrasts and changing intonation. Avoid the evenly pitched explanatory narrator delivery. "
        "No singing, no vocal impersonation, no added words."
    ),
    'take_b': (
        "Acting direction for a short comedy challenge video: amused, daring, slightly confrontational, smiling through the threat. "
        "Speak briskly and naturally, as if you are certain you will win. Make the opening command attention. "
        "A tiny pause after the name lets the confidence land. The identity joke is deadpan but proud. "
        "AND I'M GONNA STEAL YOUR WATCH TIME is the bold challenge: emphasize steal, your, and watch time. "
        "BY BECOMING THE BIGGEST STORYTIME ANIMATOR IN THE WORLD builds intensity and lands decisively on world. "
        "The final two sentences suddenly turn casual and wry, with a slight incredulous lift in the final joke. "
        "Use clear emotional variation and punchy musical phrasing, not flat audiobook explanation. "
        "Keep your own natural voice. No shouting throughout, no singing, no added words."
    ),
    'take_c': (
        "Deliver a playful challenge to rival creators: cocky, amused, pointed, smiling with absolute self-belief. "
        "Crisp, brisk, connected speech. Punch 'steal your watch time'; rise with confidence into 'biggest storytime animator in the world'; "
        "drop suddenly to quiet mock-serious deadpan on the final two sentences. Natural changing emphasis. No announcer voice, no added words."
    ),
    'take_d': (
        "A cocky spoken mock-challenge, conversational and understated. Speak with brisk, connected phrasing and an amused self-assured smile. "
        "Build a playful threat at 'stealing your watch time', firmly stress 'biggest' and land 'world'. "
        "Finish lower and drier, with quiet absurd certainty. Short natural pauses, no stretched vowels, no announcer delivery or shouting."
    ),
}
FOLDERS = {
    'nemi': ROOT/'nemi/episodes/ep17_message_to_storytime_animators/audio/edit_r8',
    'adb': ROOT/'adb/episodes/ep08_message_to_storytime_animators/voice/edit_r8',
}

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

if __name__ == '__main__':
    engine = None
    for take_i, (take, direction) in enumerate(DIRECTIONS.items()):
        for author in ('nemi', 'adb'):
            folder = FOLDERS[author]
            folder.mkdir(parents=True, exist_ok=True)
            cfg = NemiVoiceConfig() if author == 'nemi' else ADBVoiceConfig()
            path = folder/f'{take}_full.wav'
            instruction = cfg.voice_design_prompt + '\n\n' + direction
            text = SCRIPTS[author]
            if take == 'take_d':
                text = text.replace("And I'm gonna steal your watch time. By becoming", "Stealing your watch time. Becoming")
            seed = 81700 + take_i*10 + (0 if author == 'nemi' else 1)
            if not path.exists():
                mx.random.seed(seed)
                if engine is None:
                    engine = QwenVoiceDesignEngine(cfg)
                engine.config = cfg
                print('GENERATING', author, take, flush=True)
                engine.synthesize_to_file(text, str(path), speaker=cfg.speaker, instruct=instruction, speed=1.0)
            info = sf.info(path)
            record = {
                'author': author, 'take': take, 'text': text,
                'path': str(path.relative_to(ROOT)), 'sha256': sha(path),
                'sample_rate': info.samplerate, 'duration': info.duration,
                'speaker': cfg.speaker, 'model_repo': cfg.repo_id,
                'identity_prompt_unchanged': cfg.voice_design_prompt,
                'delivery_direction_added_for_this_take': direction,
                'full_synthesis_instruction': instruction,
                'speed': 1.0, 'seed': seed,
                'canonical_config_sha256': sha(ROOT/'tools/tts/config.py'),
                'canonical_engine_sha256': sha(ROOT/'tools/tts/engine.py'),
                'authorization': "User rejected flat delivery and requested emotional performance matching the supplied reference, 2026-10-23.",
                'identity_processing': 'No pitch/formant/EQ changes; no voice replacement; unchanged speaker/model/base identity and engine defaults.',
                'subjective_listening': 'Not claimed by local speech/prosody measurements.'
            }
            path.with_suffix('.json').write_text(json.dumps(record, indent=2)+'\n')
            print('READY', author, take, round(info.duration, 3), str(path), flush=True)
