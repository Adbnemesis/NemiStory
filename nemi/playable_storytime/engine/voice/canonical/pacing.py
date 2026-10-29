"""Pitch-preserving tempo only. Never changes speaker, prompt or sample rate."""
import math
from pathlib import Path
import subprocess
import tempfile


def check_tempo(value):
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value) or not .5 <= value <= 2:
        raise ValueError('Tempo must be a finite number from 0.5 to 2; audition 1.0–1.15 for storytime.')
    return float(value)


def tempo_array(audio, sample_rate, tempo):
    """Synthesis always uses the original identity settings; pace its result."""
    tempo = check_tempo(tempo)
    if tempo == 1:
        return audio
    import numpy as np
    import soundfile as sf
    with tempfile.TemporaryDirectory(prefix='voice-tempo-') as folder:
        source, result = Path(folder)/'source.wav', Path(folder)/'paced.wav'
        sf.write(source, audio, sample_rate, subtype='FLOAT')
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', str(source), '-af',
                        f'atempo={tempo}', '-c:a', 'pcm_f32le', str(result)], check=True)
        paced, rate = sf.read(result, dtype='float32')
        if rate != sample_rate:
            raise RuntimeError('Tempo processing changed sample rate')
        return np.asarray(paced, dtype=np.float32)
