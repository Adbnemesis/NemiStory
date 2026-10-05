"""Make measured accent candidates for the downloaded batch previews.

These are editorial candidates, not an assertion of musical downbeat phase.
Final cuts must be chosen and checked in the rendered edit.
"""
from pathlib import Path
import json
import numpy as np

OUT = Path(__file__).resolve().parent
CHOICES = {
    'cheri-cheri-lady': (.1393, 15., 60 / 114, 1, 'Crisp romantic disco; profile glances and heart doodles. Strong backbeat can support alternating shy/confident poses.'),
    'dancin-krono': (4.168, 15., .5, 1, 'Playful house groove; grounded head/shoulder gestures and quick full-body silhouette switches. Use a few held poses instead of changing picture every beat.'),
    'fashion': (.0108, 15., .5, 1, 'Runway swagger; pose freeze, garment hatching and angular flash doodles. The thinner texture around source 11–12 s gives room for one deliberate hold.'),
    'makeba': (.7546, 15., 120 / 116, 2, 'Percussive creative play; pen/hand accents and organic author doodles. Repeated strong accents roughly every two beats give contact/reaction opportunities.'),
    'memory-reboot': (10.3848, 15., 60 / 162, 1, 'Dramatic reveal; the preview texture thins around source 12–14 s and becomes stronger at14.3848 s, exactly scene4.0 s with this start. Build silhouette/shading, then reveal on that measured accent.'),
}

def prepare(slug, settings):
    start, duration, period, beat_multiplier, rationale = settings
    analysis = json.loads((OUT / f'{slug}.analysis.json').read_text())
    metadata = json.loads((OUT / f'{slug}.json').read_text())
    peaks = np.array(analysis['peaks'])
    numbers = np.round((peaks - peaks[0]) / period)
    good = np.abs(peaks - (period * numbers + peaks[0])) < .06
    for _ in range(3):
        slope, phase = np.polyfit(numbers[good], peaks[good], 1)
        good = np.abs(peaks - (slope * numbers + phase)) < .03
    bpm = 60 / slope * beat_multiplier
    accents = []
    for source_time in analysis['peaks']:
        scene_time = source_time - start
        if 0 <= scene_time < duration:
            frame = round(scene_time * 30)
            if frame >= round(duration * 30):
                continue
            accents.append({'sourceTime': source_time, 'sceneTime': round(scene_time, 4), 'frame30fps': frame, 'frameTime': round(frame / 30, 6), 'frameErrorMs': round((frame / 30 - scene_time) * 1000, 3)})
    onsets = []
    for source_time in analysis['onsets']:
        scene_time = source_time - start
        if 0 <= scene_time < duration:
            onsets.append({'sourceTime': source_time, 'sceneTime': round(scene_time, 4), 'frame30fps': round(scene_time * 30)})
    plan = {
        'id': slug,
        'file': metadata['file'],
        'sourceHash': metadata['sha256'],
        'sourceStart': start,
        'duration': duration,
        'fps': 30,
        'suggestedFrames': round(duration * 30),
        'bpm': round(float(bpm), 3),
        'bpmStatus': 'fit to recurring strong spectral-flux accents; metrical phase remains editorial',
        'pulsePeriod': round(float(slope), 7),
        'pulseFitPhaseInSource': round(float(phase), 7),
        'pulseFitSamples': int(good.sum()),
        'pulseFitMeanResidualMs': round(float(np.mean(np.abs(peaks[good] - (slope * numbers[good] + phase)))) * 1000, 3),
        'halfTimeBpm': round(float(bpm / 2), 3) if slug == 'memory-reboot' else None,
        'rationale': rationale,
        'status': 'measured candidate accents; awaiting selection and exported playback checks',
        'accentCandidates': accents,
        'onsetCandidates': onsets,
        'measurementResolutionMs': 256 / 22050 * 1000,
        'note': 'sourceStart is on the downloaded preview timeline, not the full-song timeline. The API does not provide a full-song preview offset. Quantized picture cues have an additional maximum16.67ms frame-grid error.',
    }
    if slug == 'memory-reboot':
        plan['revealCandidate'] = {'sourceTime': 14.3848, 'sceneTime': 4., 'frame30fps': 120, 'kind': 'measured accent at stronger section boundary; not automatically labelled a drop/downbeat'}
        plan['heldRevealCandidates'] = [a for a in accents if a['frame30fps'] in (120, 164, 208, 253, 297, 341, 385, 430)]
        plan['heldRevealNote'] = 'The selected measured anchors are about 1.475 seconds apart, roughly two half-time beats. They support longer silhouette holds after the scene 4 s arrival.'
    (OUT / f'{slug}.edit-plan.json').write_text(json.dumps(plan, ensure_ascii=False, indent=2) + '\n')
    metadata['measuredBpm'] = plan['bpm']
    metadata['bpm'] = plan['bpm']
    metadata['bpmStatus'] = plan['bpmStatus']
    metadata['editPlanFile'] = str((OUT / f'{slug}.edit-plan.json').relative_to(OUT.parents[3]))
    (OUT / f'{slug}.json').write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + '\n')
    return metadata, plan

if __name__ == '__main__':
    records = []
    for slug, settings in CHOICES.items():
        metadata, plan = prepare(slug, settings)
        records.append(metadata)
        print(slug, plan['bpm'], 'start', plan['sourceStart'], 'accent frames', [a['frame30fps'] for a in plan['accentCandidates']])
    (OUT / 'catalog.json').write_text(json.dumps(records, ensure_ascii=False, indent=2) + '\n')
