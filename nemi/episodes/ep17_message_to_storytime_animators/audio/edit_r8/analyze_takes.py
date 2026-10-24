"""Local ASR/word timing and reproducible acoustic measurements, not listening QA."""
import os
os.environ['HF_HUB_OFFLINE'] = '1'
from pathlib import Path
import sys
import json
import numpy as np
import soundfile as sf
from scipy import signal
ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_expressive import FOLDERS
import mlx_whisper

def acoustic_metrics(path):
    x, sr = sf.read(path)
    if x.ndim > 1:
        x = x.mean(axis=1)
    # 8 kHz is sufficient for broad F0 observation; no output audio is processed.
    x = signal.resample_poly(x, 8000, sr)
    sr = 8000
    frame_n, hop = 400, 80
    frames = np.lib.stride_tricks.sliding_window_view(x, frame_n)[::hop]
    rms = np.sqrt(np.mean(frames*frames, axis=1))
    threshold = max(float(np.max(rms))*0.08, 0.003)
    pitches = []
    for frame, energy in zip(frames, rms):
        if energy < threshold:
            continue
        y = frame-frame.mean()
        ac = signal.correlate(y, y, mode='full', method='fft')[frame_n-1:]
        ac /= np.maximum(ac[0], 1e-12)
        lo, hi = int(sr/600), int(sr/65)
        peaks, props = signal.find_peaks(ac[lo:hi], height=0.45)
        if not len(peaks):
            continue
        lags = peaks+lo
        # Pick earliest sufficiently strong peak, reducing octave-down doubling.
        values = ac[lags]
        candidates = lags[values >= max(0.55, values.max()*0.87)]
        if len(candidates):
            pitches.append(sr/float(candidates[0]))
    metrics = {'duration_s': len(x)/sr, 'active_energy_frames_s': float(np.sum(rms>=threshold)*hop/sr), 'pitch_method': '50ms autocorrelation, 10ms hop, strong earliest peak 65–600Hz; rough pitch evidence with octave ambiguity, not perceived emotion'}
    if pitches:
        p = np.percentile(pitches, [10, 50, 90])
        metrics.update({'f0_hz_p10_p50_p90': p.tolist(), 'f0_10_90_range_semitones': float(12*np.log2(p[2]/p[0])), 'voiced_frames': len(pitches)})
    active = rms[rms>=threshold]
    if len(active):
        metrics['active_rms_db_p10_p50_p90'] = (20*np.log10(np.percentile(active, [10,50,90])+1e-10)).tolist()
    return metrics

if __name__ == '__main__':
    summary = {}
    for author, folder in FOLDERS.items():
        records = []
        for path in sorted(folder.glob('take_*_full.wav')):
            record = json.loads(path.with_suffix('.json').read_text())
            analysis_path = path.with_name(path.stem+'_analysis.json')
            if analysis_path.exists():
                analysis = json.loads(analysis_path.read_text())
                assert analysis['sha256'] == record['sha256']
            else:
                result = mlx_whisper.transcribe(str(path), path_or_hf_repo='mlx-community/whisper-large-v3-turbo', language='en', word_timestamps=True, verbose=False, initial_prompt=record['text'])
                words = [word for seg in result['segments'] for word in seg.get('words', [])]
                analysis = {'file': record['path'], 'sha256':record['sha256'], 'expected_text':record['text'], 'recognized_text': result['text'], 'words': words, 'acoustic':acoustic_metrics(path), 'review_limit': 'ASR and rough pitch metrics do not certify audible emotional quality or exact phoneme boundaries.'}
                analysis_path.write_text(json.dumps(analysis, indent=2)+'\n')
            records.append(analysis)
            print(author, path.name, json.dumps({'recognized_text': analysis['recognized_text'], 'metrics':analysis['acoustic']}), flush=True)
        summary[author] = records
    # Reference separated vocal is used only as measured prosody reference.
    ref = ROOT/'renders/message_to_storytime_reference/audio/reference_vocals.wav'
    if ref.exists():
        summary['reference_vocal_acoustics'] = acoustic_metrics(ref)
    (FOLDERS['nemi']/'TAKE_ANALYSIS.json').write_text(json.dumps(summary,indent=2)+'\n')
