#!/usr/bin/env python3
"""
generate_shelly.py - Dialogue Generator for Shelly (Brawl Stars)
Base Actor: LEON | Pitch Shift: +2.5 semitones
"""

import os
import sys
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
VOICES_DIR = os.path.dirname(os.path.dirname(SCRIPT_DIR))
GEN_BRAWLER = os.path.join(VOICES_DIR, "generate_brawler.py")

cmd = [sys.executable, GEN_BRAWLER, "--brawler", "shelly"] + sys.argv[1:]
res = subprocess.run(cmd)
sys.exit(res.returncode)
