"""Validate explicit musical phrases against the final measured scene clock."""
from __future__ import annotations

import math
import re


def number(value, name, low, high, *, integer=False):
    if (isinstance(value, bool) or not isinstance(value, (int, float))
            or not math.isfinite(value) or not low <= value <= high
            or integer and not isinstance(value, int)):
        raise ValueError(f'{name} must be a finite {"integer " if integer else ""}value from {low} to {high}.')
    return value


def validated_plan_notes(plan, timeline):
    allowed = {'version', 'title', 'narration_sha256', 'phrases', 'silent_ranges'}
    if not isinstance(plan, dict) or set(plan) - allowed or type(plan.get('version')) is not int or plan['version'] != 1:
        raise ValueError('Score plan needs version 1 and only documented fields.')
    if not isinstance(plan.get('title'), str) or not plan['title'].strip():
        raise ValueError('Score plan needs a title.')
    if plan.get('narration_sha256') != timeline.get('audio_sha256') or not timeline.get('audio_sha256'):
        raise ValueError('Score plan is bound to another narration recording.')
    phrases = plan.get('phrases')
    if not isinstance(phrases, list) or not phrases:
        raise ValueError('Score plan needs explicit musical phrases.')
    duration = timeline['duration']
    silences = plan.get('silent_ranges', [])
    if not isinstance(silences, list):
        raise ValueError('silent_ranges must be an explicit list.')
    for quiet in silences:
        if not isinstance(quiet, dict) or set(quiet) != {'start', 'end', 'reason'}:
            raise ValueError('Silent range needs start, end and reason.')
        number(quiet['start'], 'Silence start', 0, duration)
        number(quiet['end'], 'Silence end', 0, duration)
        if quiet['end'] <= quiet['start'] or not isinstance(quiet['reason'], str) or not quiet['reason'].strip():
            raise ValueError('Silent range needs positive duration and a directing reason.')
    ids, notes = set(), []
    clean = lambda value: re.sub(r'[^a-z0-9]', '', value.lower())
    for phrase in phrases:
        if not isinstance(phrase, dict) or set(phrase) - {'id', 'at', 'anchor', 'intent', 'notes'}:
            raise ValueError('Musical phrase contains unknown fields.')
        pid = phrase.get('id')
        if not isinstance(pid, str) or not re.fullmatch(r'[a-zA-Z0-9_-]+', pid) or pid in ids:
            raise ValueError('Musical phrase IDs must be unique and safe.')
        ids.add(pid)
        at = number(phrase.get('at'), 'Phrase start', 0, duration)
        if not isinstance(phrase.get('intent'), str) or not phrase['intent'].strip():
            raise ValueError('Musical phrase needs a story intention.')
        if 'anchor' in phrase:
            anchor = phrase['anchor']
            if not isinstance(anchor, dict) or set(anchor) - {'clip_id', 'word', 'occurrence', 'offset'}:
                raise ValueError('Musical anchor contains unknown fields.')
            if not isinstance(anchor.get('word'), str) or not isinstance(anchor.get('clip_id'), str):
                raise ValueError('Musical anchor needs a measured clip ID and word.')
            occurrence = number(anchor.get('occurrence', 0), 'Anchor occurrence', 0, 10000, integer=True)
            offset = number(anchor.get('offset', 0), 'Anchor offset', -2, 2)
            matches = [w for w in timeline.get('words', []) if w['clip_id'] == anchor['clip_id'] and clean(w['word']) == clean(anchor['word'])]
            if len(matches) <= occurrence or abs(at - matches[occurrence]['start'] - offset) > .001:
                raise ValueError('Musical phrase does not match its final measured word anchor.')
        pn = phrase.get('notes')
        if not isinstance(pn, list) or not pn:
            raise ValueError('Musical phrase needs explicitly authored notes.')
        previous = -1
        for note in pn:
            if not isinstance(note, dict) or set(note) - {'offset', 'midi', 'duration', 'velocity', 'pan'}:
                raise ValueError('Musical note contains unknown fields.')
            offset = number(note.get('offset'), 'Note offset', 0, duration)
            midi = number(note.get('midi'), 'Piano MIDI pitch', 21, 108, integer=True)
            length = number(note.get('duration'), 'Note duration', .1, 8)
            velocity = number(note.get('velocity'), 'Linear musical velocity', .001, .6)
            pan = number(note.get('pan', 0), 'Note pan', -1, 1)
            start, end = at + offset, at + offset + length
            if offset < previous or end > duration + 1e-8:
                raise ValueError('Musical notes must be ordered and fit the scene clock.')
            if any(start < quiet['end'] and end > quiet['start'] for quiet in silences):
                raise ValueError('Musical note overlaps a protected comic silence.')
            notes.append(dict(phrase=pid, at=round(start, 6), midi=midi, duration=length, velocity=velocity, pan=pan))
            previous = offset
    return notes
