#!/usr/bin/env python3
"""
episodes/ep02_partner/tools/check_script_pronouns.py
Automated Quality Assurance Linter for Pronouns and Facts in Episode 02.

Strict Production Rules:
1. NEMI: First-person language ('I', 'my', 'we', 'our', 'us') only.
   FORBIDDEN for Nemi: 'she', 'her', 'hers', gender identifiers.
2. ADB: FORBIDDEN: 'he', 'him', 'his', 'she', 'her', 'hers', 'they', 'them', 'their', 'theirs'.
   ALLOWED: 'ADB', 'ADB\'s', 'my partner', 'the person I met', 'my best friend'.
3. SUBTITLES: Every card MUST be <= 5 words.
"""

import sys
import os
import re

FORBIDDEN_PATTERNS = [
    # Prohibited third person pronouns
    (r'\b(he|him|his)\b', "Prohibited pronoun: 'he/him/his'"),
    (r'\b(she|her|hers)\b', "Prohibited pronoun: 'she/her/hers'"),
    (r'\b(they|them|their|theirs)\b', "Prohibited pronoun: 'they/them/their/theirs'"),
]

def check_script(script_path: str) -> bool:
    print(f"--- Running Pronoun & Fact Linter on: {script_path} ---")
    if not os.path.exists(script_path):
        print(f"ERROR: File not found: {script_path}")
        return False

    with open(script_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    errors = []
    in_code_block = False
    in_dialogue = False

    for line_num, raw_line in enumerate(lines, 1):
        line = raw_line.strip()
        if line.startswith("```"):
            in_code_block = not in_code_block
            continue

        if in_code_block:
            # Check dialogue lines
            if line.startswith('"') and line.endswith('"'):
                dialogue_text = line[1:-1]
                for pattern, msg in FORBIDDEN_PATTERNS:
                    matches = re.finditer(pattern, dialogue_text, re.IGNORECASE)
                    for m in matches:
                        errors.append((line_num, dialogue_text, f"{msg} (found '{m.group(0)}')"))

    if errors:
        print(f"FAILED: Found {len(errors)} pronoun violation(s):")
        for line_num, text, msg in errors:
            print(f"  Line {line_num}: {msg}\n    Text: \"{text}\"")
        return False

    print("✓ PASSED: Zero prohibited pronouns found in dialogue.")
    return True

if __name__ == "__main__":
    script_file = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "EP02_Script.md"
    )
    success = check_script(script_file)
    sys.exit(0 if success else 1)
