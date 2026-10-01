#!/usr/bin/env python3
"""Run meaningful Godot storytime checks; fail on runtime errors, not only exit code."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from validate_scene import ROOT
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--godot',default=os.environ.get('GODOT_BIN'))
args=parser.parse_args()
candidates=[args.godot,shutil.which('godot'),str(Path.home()/'Downloads/Godot.app/Contents/MacOS/Godot'),'/Applications/Godot.app/Contents/MacOS/Godot']
godot=next((p for p in candidates if p and Path(p).is_file()),None)
if not godot:parser.error('Set --godot or GODOT_BIN to the installed engine.')
with tempfile.TemporaryDirectory(prefix='storytime-check-') as folder:
 for script in ['tools/tests/test_live_ink.gd','tools/storytime/test_identity.gd','tools/storytime/test_production.gd','tools/storytime/test_refinement.gd','tools/storytime/test_review_story.gd']:
  result=subprocess.run([godot,'--headless','--path',str(ROOT),'--log-file',str(Path(folder)/'check.log'),'--script',script],capture_output=True,text=True,timeout=60)
  output=result.stdout+result.stderr
  # Known unrelated macOS certificate lookup diagnostic in headless mode.
  errors=[line for line in output.splitlines() if ('ERROR:' in line or 'Parse Error:' in line) and 'Condition "ret != noErr"' not in line]
  if result.returncode or errors or 'PASS' not in output.upper():
   raise SystemExit(f'{script} failed:\n{output[-4000:]}')
  print('Passed:',script)
