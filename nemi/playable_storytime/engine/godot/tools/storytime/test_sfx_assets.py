"""Protect exact user-selected clip identity and exclude procedural substitutes."""
import copy,json,unittest
from pathlib import Path
from sfx_assets import validate_asset
ROOT=Path(__file__).resolve().parents[2]
class ExistingAssets(unittest.TestCase):
    def setUp(self):self.catalog={a['id']:a for a in json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']}
    def test_exact_root_clip_and_tampering(self):
        original=self.catalog['viral_bruh'];self.assertEqual(validate_asset(original,ROOT),ROOT/'common/audio/sfx/bruh.mp3')
        altered=copy.deepcopy(original);altered['sha256']='0'*64
        with self.assertRaises(ValueError):validate_asset(altered,ROOT)
        altered=copy.deepcopy(original);altered['relative_path']='common/audio/sfx/get-out.mp3'
        with self.assertRaises(ValueError):validate_asset(altered,ROOT)
    def test_library_recording_and_procedural_substitute(self):
        self.assertTrue(validate_asset(self.catalog['comedic_record_scratch_01'],ROOT).is_file())
        with self.assertRaises(ValueError):validate_asset(self.catalog['cartoon_boing_spring_01'],ROOT)
if __name__=='__main__':unittest.main()
