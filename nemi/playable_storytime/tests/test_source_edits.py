"""Authored source cuts cannot remove words, breaths, or stale recordings."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('source_edits', ROOT/'tools/source_edits.py')
edits = importlib.util.module_from_spec(spec)
spec.loader.exec_module(edits)
DIGEST = 'a' * 64


def entry(ranges=None):
    return {'source_sha256': DIGEST, 'remove_ranges': ranges or [
        {'start': .8, 'end': 1.4, 'reason': 'Tighten the ordinary transition'}]}


class SourceEditTests(unittest.TestCase):
    def setUp(self):
        self.samples = [0.0] * 2500
        self.words = [{'word': 'before', 'start': .1, 'end': .5},
                      {'word': 'after', 'start': 1.8, 'end': 2.1}]

    def validate(self, value, samples=None, words=None):
        return edits.validate_source_edits(value, DIGEST, samples or self.samples,
                                            1000, words or self.words)

    def test_absent_plan_preserves_original_processing(self):
        self.assertEqual(self.validate(None), [])
        self.assertEqual(edits.processed_stem('take', 1.08, None, False), 'take_tempo1.080')

    def test_explicit_quiet_cut_keeps_every_other_sample(self):
        result = self.validate(entry())
        self.assertEqual(result[0]['start_sample'], 800)
        self.assertEqual(result[0]['end_sample'], 1400)
        self.assertAlmostEqual(result[0]['removed_seconds'], .6)
        self.assertEqual(edits.kept_sample_ranges(len(self.samples), result), [(0, 800), (1400, 2500)])
        self.assertEqual(result[0]['measured_gap']['after'], 'before')

    def test_plan_change_changes_edited_processed_filename(self):
        a = edits.processed_stem('take', 1.08, 'a'*64, True)
        b = edits.processed_stem('take', 1.08, 'b'*64, True)
        self.assertNotEqual(a, b)
        self.assertIn('_editaaaaaaaaaaaa_', a)

    def test_stale_recording_hash_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'another recording'):
            self.validate({**entry(), 'source_sha256': 'b'*64})

    def test_word_crossing_and_protected_edges_are_rejected(self):
        for start, end in [(.4, 1.4), (.559, 1.4), (.8, 1.741), (.8, 1.9)]:
            with self.subTest(start=start, end=end), self.assertRaisesRegex(ValueError, 'protected 60 ms'):
                self.validate(entry([{'start': start, 'end': end, 'reason': 'Explicit transition direction'}]))

    def test_exact_sixty_millisecond_edges_are_allowed(self):
        self.validate(entry([{'start': .56, 'end': 1.74, 'reason': 'Keep both measured word edges'}]))

    def test_outside_nonfinite_and_boolean_bounds_are_rejected(self):
        for start, end in [(0, 1), (-1, 1), (1, 3), (1, 1), (True, 1.4), (.8, float('nan'))]:
            with self.subTest(start=start, end=end), self.assertRaises(ValueError):
                self.validate(entry([{'start': start, 'end': end, 'reason': 'Explicit directing reason'}]))

    def test_overlapping_or_unordered_cuts_are_rejected(self):
        for ranges in [
            [(.7, 1.1), (1.0, 1.3)], [(1.2, 1.5), (.7, 1.0)]]:
            with self.assertRaisesRegex(ValueError, 'overlapping, unordered'):
                self.validate(entry([{'start': a, 'end': b, 'reason': 'An authored quiet transition'} for a,b in ranges]))

    def test_low_rms_but_audible_breath_peak_is_rejected(self):
        audio = self.samples.copy()
        audio[1000] = .02
        with self.assertRaisesRegex(ValueError, 'speech/breath energy'):
            self.validate(entry(), audio)

    def test_sustained_speech_energy_is_rejected(self):
        audio = self.samples.copy()
        audio[800:1400] = [.003] * 600
        with self.assertRaisesRegex(ValueError, 'speech/breath energy'):
            self.validate(entry(), audio)

    def test_missing_specific_reason_or_unknown_cut_fields_rejected(self):
        for extra in [{'reason': ''}, {'end': 1.4, 'automatic': True}]:
            value = entry(); value['remove_ranges'][0].update(extra)
            with self.assertRaises(ValueError): self.validate(value)

    def test_plan_schema_hash_and_unknown_clip_validation(self):
        parent = ROOT/'tests/source_edit_fixtures'; parent.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as temporary:
            episode = Path(temporary); (episode/'audio').mkdir()
            self.assertEqual(edits.read_source_edit_plan(episode, ['take']), (None, {}))
            plan = {'version': 1, 'clips': {'take': entry()}}
            path = episode/'audio/source_edit_plan.json'
            raw = (json.dumps(plan)+'\n').encode(); path.write_bytes(raw)
            digest, clips = edits.read_source_edit_plan(episode, ['take'])
            self.assertEqual(digest, hashlib.sha256(raw).hexdigest())
            self.assertEqual(clips['take'], entry())
            with self.assertRaisesRegex(ValueError, 'unknown dialogue clip'):
                edits.read_source_edit_plan(episode, ['different'])
            for bad in [{**plan, 'automatic_trim': True}, {'version': 2, 'clips': {}},
                        {'version': 1, 'clips': {'take': {'source_sha256': 'bad', 'remove_ranges': []}}}]:
                path.write_text(json.dumps(bad))
                with self.assertRaises(ValueError): edits.read_source_edit_plan(episode, ['take'])


if __name__ == '__main__': unittest.main()
