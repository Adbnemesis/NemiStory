import shutil
import subprocess
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]

class PreviewKeyboardTests(unittest.TestCase):
    @unittest.skipUnless(shutil.which('node'),'Node is needed to exercise the actual page listeners')
    def test_real_page_keyboard_listeners(self):
        result=subprocess.run(['node',str(ROOT/'tests/preview_keyboard_check.js'),str(ROOT/'previews/index.html')],
            text=True,capture_output=True)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)

if __name__=='__main__':unittest.main()
