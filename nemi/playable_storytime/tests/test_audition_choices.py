import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class AuditionChoiceTests(unittest.TestCase):
    @unittest.skipUnless(shutil.which('node'), 'Node is needed to exercise the actual audition controls')
    def test_local_audition_choices(self):
        result = subprocess.run(
            ['node', str(ROOT / 'tests/audition_choices_check.js'),
             str(ROOT / 'previews/audition_choices.js')],
            text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
