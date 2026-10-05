"""Meaningful rejection checks for the separate v2 Shorts validator."""
from copy import deepcopy
import json
from pathlib import Path
import tempfile
import unittest

from validate_ink import ROOT, validate


class ShortsValidatorTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = ROOT / "shorts/godot/batch01/art-study/short.json"
        cls.base = validate(cls.source)

    def check_rejected(self, edit):
        spec = deepcopy(self.base)
        edit(spec)
        with tempfile.TemporaryDirectory(prefix="shorts-validator-") as directory:
            path = Path(directory) / "short.json"
            path.write_text(json.dumps(spec))
            with self.assertRaises(AssertionError):
                validate(path)

    def test_current_v2_example_is_valid(self):
        self.assertEqual(validate(self.source)["version"], 2)

    def test_unknown_root_field_is_rejected(self):
        self.check_rejected(lambda spec: spec.update({"autoWalk": True}))

    def test_changed_music_hash_is_rejected(self):
        self.check_rejected(lambda spec: spec["music"].update({"sourceHash": "0" * 64}))

    def test_sfx_requires_named_visual_event(self):
        self.check_rejected(lambda spec: spec["sfx"].append({"event": "missing-event"}))

    def test_back_contact_pose_cannot_fall_back(self):
        self.check_rejected(lambda spec: spec["actors"][0]["cues"][0].update({"view": "back", "action": "phone"}))

    def test_unknown_original_pose_is_rejected(self):
        self.check_rejected(lambda spec: spec["actors"][0]["cues"][0].update({"pose": "invented_pose"}))

    def test_event_cannot_live_past_movie_end(self):
        self.check_rejected(lambda spec: spec["events"][0].update({"end": spec["frames"] + 1}))

    def test_flash_is_limited_to_two_frames(self):
        self.check_rejected(lambda spec: spec["events"][0].update({"kind": "flash", "at": 0, "end": 3}))


if __name__ == "__main__":
    unittest.main()
