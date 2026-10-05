"""Check the encoded native-Godot Shorts mix against its exact recorded sources.

Usage: python verify_audio.py short.json movie.mp4 review/audio.json

This is a read-only media check. It does not alter a movie, source recording or
spec. Latency comes from waveform correlation; no codec-delay offset is assumed.
SFX presence is tested in the decoded export, not inferred from the cue metadata.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import subprocess

import numpy as np
from scipy.signal import correlate, correlation_lags

from validate_ink import ROOT, validate

SAMPLE_RATE = 48_000
EPSILON = 1e-12


def decode(path: Path, start: float = 0, duration: float | None = None) -> np.ndarray:
    """Decode with the same accurate input seek used by the native muxer."""
    command = ['ffmpeg', '-v', 'error', '-ss', str(start), '-i', str(path)]
    if duration is not None:
        command += ['-t', str(duration)]
    command += ['-vn', '-ac', '2', '-ar', str(SAMPLE_RATE), '-f', 'f32le', 'pipe:1']
    pcm = subprocess.check_output(command)
    return np.frombuffer(pcm, dtype='<f4').reshape(-1, 2)


def rms(samples: np.ndarray) -> float:
    return float(np.sqrt(np.mean(np.square(samples.astype(np.float64))))) if samples.size else 0.0


def db(value: float) -> float:
    return float(20 * np.log10(max(abs(value), EPSILON)))


def coefficient(target: np.ndarray, template: np.ndarray) -> float:
    target = target.astype(np.float64).ravel()
    template = template.astype(np.float64).ravel()
    return float(np.dot(target, template) / max(float(np.dot(template, template)), EPSILON))


def correlation(a: np.ndarray, b: np.ndarray) -> float:
    a = a.astype(np.float64).ravel()
    b = b.astype(np.float64).ravel()
    a = a - a.mean()
    b = b - b.mean()
    denominator = np.sqrt(np.dot(a, a) * np.dot(b, b))
    return float(np.dot(a, b) / max(float(denominator), EPSILON))


def source_stem(source: dict, count: int, at_sample: int = 0) -> np.ndarray:
    """Place an independently decoded recorded clip on the expected scene clock."""
    recording = decode(ROOT / source['file'], source['sourceStart'], source['duration'])
    stem = np.zeros((count, 2), dtype=np.float32)
    available = min(len(recording), count - at_sample)
    if available > 0:
        stem[at_sample:at_sample + available] = recording[:available] * 10 ** (source['gainDb'] / 20)
    return stem


def reconstruct(config: dict) -> tuple[np.ndarray, list[np.ndarray], list[dict]]:
    count = round(config['frames'] / config['fps'] * SAMPLE_RATE)
    music = source_stem(config['music'], count)
    stems = [music]
    records = [{'kind': 'music', **config['music'], 'scheduledAt': 0.0, 'sample': 0}]
    events = {event['id']: event for event in config.get('events', [])}
    for source in config['sfx']:
        frame = events[source['event']]['at'] + source.get('offsetFrames', 0)
        # render_ink.py rounds adelay to integer milliseconds, before amix.
        milliseconds = round(frame * 1000 / config['fps'])
        sample = round(milliseconds * SAMPLE_RATE / 1000)
        stem = source_stem(source, count, sample)
        stems.append(stem)
        records.append({
            'kind': 'sfx', **source,
            'eventFrame': events[source['event']]['at'],
            'scheduledFrame': frame,
            'scheduledAt': milliseconds / 1000,
            'sample': sample,
            'scheduleRoundingMs': milliseconds - frame * 1000 / config['fps'],
        })
    return np.sum(stems, axis=0), stems, records


def estimate_delay(actual: np.ndarray, expected: np.ndarray) -> dict:
    """Measure lag within ±100 ms; positive means the export is later."""
    a = actual.mean(axis=1).astype(np.float64)
    b = expected.mean(axis=1).astype(np.float64)
    cross = correlate(a - a.mean(), b - b.mean(), method='fft')
    lags = correlation_lags(len(a), len(b))
    indices = np.flatnonzero(np.abs(lags) <= round(SAMPLE_RATE * .1))
    index = int(indices[np.argmax(cross[indices])])
    lag = int(lags[index])
    fraction = 0.0
    if 0 < index < len(cross) - 1:
        left, center, right = cross[index - 1:index + 2]
        denominator = left - 2 * center + right
        if denominator:
            fraction = float(.5 * (left - right) / denominator)
    return {
        'integerSamples': lag,
        'subsampleEstimate': fraction,
        'samples': lag + fraction,
        'milliseconds': (lag + fraction) * 1000 / SAMPLE_RATE,
        'method': 'FFT waveform cross-correlation, stereo mean, ±100 ms search, parabolic local interpolation',
        'assumedCodecDelaySamples': 0,
    }


def align(actual: np.ndarray, stems: list[np.ndarray], lag: int) -> tuple[np.ndarray, list[np.ndarray]]:
    """Align solely for comparison; the measured lag still controls the pass/fail."""
    actual_start = max(lag, 0)
    expected_start = max(-lag, 0)
    count = min(len(actual) - actual_start, len(stems[0]) - expected_start)
    return actual[actual_start:actual_start + count], [stem[expected_start:expected_start + count] for stem in stems]


def loudness(movie: Path, duration: float) -> dict:
    command = [
        'ffmpeg', '-hide_banner', '-i', str(movie), '-t', str(duration),
        '-vn', '-af', 'loudnorm=I=-14:TP=-2:LRA=11:print_format=json',
        '-f', 'null', '-',
    ]
    result = subprocess.run(command, stderr=subprocess.PIPE, text=True, check=True)
    text = result.stderr
    measured = json.loads(text[text.rfind('{'):text.rfind('}') + 1])
    return {
        'integratedLufs': float(measured['input_i']),
        'truePeakDbTP': float(measured['input_tp']),
        'loudnessRangeLu': float(measured['input_lra']),
        'method': 'FFmpeg loudnorm input measurements; output is discarded, movie unchanged',
    }


def cue_metrics(record: dict, index: int, actual: np.ndarray, stems: list[np.ndarray]) -> dict:
    effect = stems[index]
    strength = np.sqrt(np.mean(effect.astype(np.float64) ** 2, axis=1))
    active = strength > max(float(strength.max()) * .05, 1e-6)
    if not active.any():
        return {**record, 'encodedPresenceVerified': False, 'reason': 'The selected recorded segment has no measurable active samples.'}

    # Compare the exact active clip samples, with the other configured stems held
    # in both hypotheses. AAC noise remains in the decoded residual.
    target = actual[active]
    clip = effect[active]
    music = stems[0][active]
    without = np.sum([stem[active] for i, stem in enumerate(stems) if i != index], axis=0)
    residual_without = target - without
    residual_with = residual_without - clip
    error_without = rms(residual_without)
    error_with = rms(residual_with)
    improvement = db(error_without) - db(error_with)
    detected_coefficient = coefficient(residual_without, clip)
    residual_correlation = correlation(residual_without, clip)
    ratio = db(rms(clip)) - db(rms(music))
    detected = detected_coefficient > .25 and residual_correlation > .25 and improvement > 1.0
    return {
        **record,
        'activeSamples': int(active.sum()),
        'activeSeconds': int(active.sum()) / SAMPLE_RATE,
        'sfxRmsDbFS': db(rms(clip)),
        'musicRmsDbFSInSameSamples': db(rms(music)),
        'sfxToMusicRmsDb': ratio,
        'exportErrorWithSfxDbFS': db(error_with),
        'exportErrorWithoutSfxDbFS': db(error_without),
        'reconstructionImprovementDb': improvement,
        'residualToSfxCorrelation': residual_correlation,
        'detectedSfxGainCoefficient': detected_coefficient,
        'encodedPresenceVerified': detected,
        'balanceReview': 'low relative level: listen closely' if ratio < -24 else 'check exported playback at phone volume',
        'interpretation': 'Measured evidence of the recorded clip in decoded AAC; relative level is reported, perceptual audibility also requires playback review.',
    }


def verify(config_path: Path, movie: Path) -> dict:
    config = validate(config_path)
    duration = config['frames'] / config['fps']
    expected, stems, records = reconstruct(config)
    actual_full = decode(movie)
    expected_count = len(expected)
    if len(actual_full) < expected_count - round(SAMPLE_RATE / config['fps']):
        raise ValueError('Exported audio is shorter than the expected scene by more than one frame.')
    actual = actual_full[:expected_count]
    expected = expected[:len(actual)]
    stems = [stem[:len(actual)] for stem in stems]
    delay = estimate_delay(actual, expected)
    aligned, aligned_stems = align(actual, stems, delay['integerSamples'])
    aligned_expected = np.sum(aligned_stems, axis=0)
    residual = aligned - aligned_expected
    similarity = correlation(aligned, aligned_expected)
    level_error = db(rms(aligned)) - db(rms(aligned_expected))
    reconstruction_gain = coefficient(aligned, aligned_expected)
    source_relative_error = rms(residual) / max(rms(aligned_expected), EPSILON)
    source_presence = [cue_metrics(record, i, aligned, aligned_stems) for i, record in enumerate(records) if i]
    levels = loudness(movie, duration)
    clipped = int(np.count_nonzero(np.abs(actual) >= .999999))
    checks = {
        'sourceHashesAndRangesValid': True,
        'waveformCorrelationAtLeast097': similarity >= .97,
        'delayWithinOnePictureFrame': abs(delay['milliseconds']) <= 1000 / config['fps'],
        'mixLevelWithinOneDb': abs(level_error) <= 1.0,
        'relativeReconstructionErrorAtMost020': source_relative_error <= .20,
        'allRecordedSfxPresentInDecodedExport': all(cue['encodedPresenceVerified'] for cue in source_presence),
        'noClippedDecodedSamples': clipped == 0,
        'truePeakAtMostMinusOneDbTP': levels['truePeakDbTP'] <= -1,
    }
    return {
        'version': 1,
        'passed': all(checks.values()),
        'checks': checks,
        'config': str(config_path.resolve()),
        'configSha256': hashlib.sha256(config_path.read_bytes()).hexdigest(),
        'movie': str(movie.resolve()),
        'movieSha256': hashlib.sha256(movie.read_bytes()).hexdigest(),
        'duration': duration,
        'sampleRate': SAMPLE_RATE,
        'channels': 2,
        'expectedSamplesPerChannel': expected_count,
        'decodedSamplesPerChannelBeforeSceneTrim': len(actual_full),
        'delay': delay,
        'reconstructionCorrelation': similarity,
        'reconstructionGainCoefficient': reconstruction_gain,
        'mixRmsLevelErrorDb': level_error,
        'relativeReconstructionError': source_relative_error,
        'residualRmsDbFS': db(rms(residual)),
        'exportRmsDbFS': db(rms(actual)),
        'exportSamplePeakDbFS': db(float(np.abs(actual).max())),
        'clippedDecodedSampleCount': clipped,
        'loudness': levels,
        'musicSource': records[0],
        'sfx': source_presence,
        'method': 'Independent exact-source PCM reconstruction at48kHz, measured decoded latency, active-window SFX omission comparisons; no fixed codec-delay correction, ducking, synthesis or master-level adjustment.',
        'limits': 'STFT visual beat mapping is separate. AAC is lossy, so residual samples need not be zero. Presence checks establish encoded source contribution; exported playback must still be heard for creative sound balance.',
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('config', type=Path)
    parser.add_argument('movie', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    report = verify(args.config, args.movie)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2, allow_nan=False) + '\n')
    print(f'{"PASS" if report["passed"] else "FAIL"}: correlation {report["reconstructionCorrelation"]:.5f}, measured delay {report["delay"]["milliseconds"]:.4f} ms, {len(report["sfx"])} recorded SFX checked. {args.output}')
    if not report['passed']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
