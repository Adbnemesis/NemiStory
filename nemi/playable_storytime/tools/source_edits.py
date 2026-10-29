"""Explicit, hash-bound quiet-gap edits for canonical source recordings.

This module never discovers or trims silence automatically. It validates only
the source ranges a director has written in audio/source_edit_plan.json.
"""
from __future__ import annotations

import hashlib
import json
import math

WORD_EDGE_SECONDS = 0.060
MAX_CUT_RMS_DBFS = -58.0
MAX_CUT_PEAK_DBFS = -45.0


def read_source_edit_plan(episode, clip_ids):
    path = episode / 'audio/source_edit_plan.json'
    if not path.exists():
        return None, {}
    raw = path.read_bytes()
    plan = json.loads(raw)
    if not isinstance(plan, dict) or set(plan) - {'version', 'clips', 'notes'}:
        raise ValueError('Source edit plan has unknown fields.')
    if plan.get('version') != 1 or not isinstance(plan.get('clips'), dict):
        raise ValueError('Source edit plan needs version 1 and a clips object.')
    if set(plan['clips']) - set(clip_ids):
        raise ValueError('Source edit plan references an unknown dialogue clip.')
    for entry in plan['clips'].values():
        if not isinstance(entry, dict) or set(entry) != {'source_sha256', 'remove_ranges'}:
            raise ValueError('Source edit entry needs source_sha256 and remove_ranges only.')
        digest = entry['source_sha256']
        if not isinstance(digest, str) or len(digest) != 64 or any(c not in '0123456789abcdef' for c in digest):
            raise ValueError('Source edit entry needs the exact SHA256 of its recording.')
        if not isinstance(entry['remove_ranges'], list) or not entry['remove_ranges']:
            raise ValueError('Source edit entry needs explicit nonempty remove_ranges.')
    return hashlib.sha256(raw).hexdigest(), plan['clips']


def validate_source_edits(entry, source_sha256, samples, sample_rate, words):
    """Return sample bounds and measured evidence; do not modify the recording.

    Each cut must lie in one independently measured inter-word gap with at
    least 60 ms left at both word edges. Peak and RMS limits reject audible
    speech/breath energy even when approximate ASR boundaries are inaccurate.
    """
    if entry is None:
        return []
    if entry['source_sha256'] != source_sha256:
        raise ValueError('Source edit plan is bound to another recording hash.')
    if not words or not sample_rate or len(samples) == 0:
        raise ValueError('Source edits need nonempty source audio and measured words.')
    result = []
    previous_end = 0
    for cut in entry['remove_ranges']:
        if not isinstance(cut, dict) or set(cut) != {'start', 'end', 'reason'}:
            raise ValueError('Every cut needs start, end and reason only.')
        start, end = cut['start'], cut['end']
        if any(isinstance(t, bool) or not isinstance(t, (int, float)) or not math.isfinite(t) for t in (start, end)):
            raise ValueError('Source edit bounds must be finite seconds.')
        if not isinstance(cut['reason'], str) or len(cut['reason'].strip()) < 8:
            raise ValueError('Every source edit needs a specific directing reason.')
        a, b = round(start * sample_rate), round(end * sample_rate)
        if not 0 < a < b < len(samples) or a < previous_end:
            raise ValueError('Source edit bounds are overlapping, unordered or outside the recording.')
        actual_start, actual_end = a / sample_rate, b / sample_rate
        gap = next(((left, right) for left, right in zip(words, words[1:])
                    if actual_start >= left['end'] + WORD_EDGE_SECONDS - 1e-8
                    and actual_end <= right['start'] - WORD_EDGE_SECONDS + 1e-8), None)
        if gap is None:
            raise ValueError('Source edit crosses a measured word or its protected 60 ms edge.')
        section = samples[a:b]
        energy = math.fsum(float(x) * float(x) for x in section) / len(section)
        peak = max(abs(float(x)) for x in section)
        rms_dbfs = 10 * math.log10(max(energy, 1e-24))
        peak_dbfs = 20 * math.log10(max(peak, 1e-12))
        if rms_dbfs > MAX_CUT_RMS_DBFS or peak_dbfs > MAX_CUT_PEAK_DBFS:
            raise ValueError('Source edit contains speech/breath energy; inspect rather than trim it.')
        result.append(dict(start=start, end=end, reason=cut['reason'],
                           start_sample=a, end_sample=b, removed_seconds=(b-a)/sample_rate,
                           rms_dbfs=round(rms_dbfs, 4), peak_dbfs=round(peak_dbfs, 4),
                           measured_gap=dict(after=gap[0]['word'], before=gap[1]['word'],
                                             start=gap[0]['end'], end=gap[1]['start'])))
        previous_end = b
    return result


def kept_sample_ranges(sample_count, edits):
    """Complement of the validated explicit cut bounds, preserving all else."""
    cursor = 0
    kept = []
    for cut in edits:
        kept.append((cursor, cut['start_sample']))
        cursor = cut['end_sample']
    kept.append((cursor, sample_count))
    return kept


def processed_stem(source_stem, tempo, plan_hash, has_edits):
    edition = '_edit' + plan_hash[:12] if has_edits else ''
    return f'{source_stem}{edition}_tempo{tempo:.3f}'
