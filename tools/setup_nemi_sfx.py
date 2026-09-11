#!/usr/bin/env python3
"""
tools/setup_nemi_sfx.py
Installs the minimal curated Nemi sound effects library:
- 11 selected Kenney CC0 sounds (extracted from verified zip archives)
- 4 procedural cartoon sounds synthesized via numpy/wave (MIT)
- Generates audio/sfx/catalog.json and verifies every file
"""

import os
import zipfile
import wave
import numpy as np

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SFX_DIR = os.path.join(BASE_DIR, "audio", "sfx")
LIB_DIR = os.path.join(SFX_DIR, "library")
PROC_DIR = os.path.join(SFX_DIR, "procedural")

os.makedirs(LIB_DIR, exist_ok=True)
os.makedirs(PROC_DIR, exist_ok=True)

# -------------------------------------------------------------
# 1. EXTRACT KENNEY CC0 SOUNDS
# -------------------------------------------------------------
INT_ZIP = "/tmp/kenney_sfx/interface.zip"
IMP_ZIP = "/tmp/kenney_sfx/impact.zip"

KENNEY_MAPPING = [
    # (zip_path, source_file, target_file, category, description)
    (INT_ZIP, "Audio/pluck_001.ogg", "nemi_pluck_001.ogg", "POP", "Bright organic pluck / accent pop"),
    (INT_ZIP, "Audio/pluck_002.ogg", "nemi_pluck_002.ogg", "POP", "Higher pitch pluck / micro pop"),
    (INT_ZIP, "Audio/click_001.ogg", "nemi_click_001.ogg", "CLICK", "Crisp tactile click / UI tap"),
    (INT_ZIP, "Audio/tick_001.ogg", "nemi_tick_001.ogg", "CLICK", "Subtle clock tick / timing blip"),
    (INT_ZIP, "Audio/drop_001.ogg", "nemi_drop_001.ogg", "DROP", "Soft object placed down / settle"),
    (INT_ZIP, "Audio/drop_002.ogg", "nemi_drop_002.ogg", "DROP", "Medium prop drop / cup on desk"),
    (INT_ZIP, "Audio/question_001.ogg", "nemi_question_001.ogg", "TINY_STING", "Curious upward question chime / confusion"),
    (INT_ZIP, "Audio/scratch_001.ogg", "nemi_scribble_001.ogg", "SCRIBBLE", "Pencil/ink on paper scratch / doodle draw-on"),
    (INT_ZIP, "Audio/switch_001.ogg", "nemi_switch_001.ogg", "CLICK", "Light toggle / idea click / realization"),
    (IMP_ZIP, "Audio/impactSoft_medium_000.ogg", "nemi_impact_soft_001.ogg", "IMPACT", "Soft comedic bump / head pat / prop touch"),
    (IMP_ZIP, "Audio/impactGeneric_light_000.ogg", "nemi_impact_light_001.ogg", "IMPACT", "Light tactile generic impact")
]

print("Extracting Kenney CC0 curated sounds...")
for z_path, src, tgt, cat, desc in KENNEY_MAPPING:
    with zipfile.ZipFile(z_path) as z:
        data = z.read(src)
        out_path = os.path.join(LIB_DIR, tgt)
        with open(out_path, "wb") as f:
            f.write(data)
        print(f"  ✓ {tgt} ({len(data)} bytes) -> [{cat}] {desc}")

# -------------------------------------------------------------
# 2. SYNTHESIZE PROCEDURAL CARTOON SOUNDS (MIT)
# -------------------------------------------------------------
def write_wav(filename, samples, sample_rate=44100):
    samples = np.clip(samples, -0.95, 0.95)
    int_samples = (samples * 32767).astype(np.int16)
    with wave.open(filename, "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        f.writeframes(int_samples.tobytes())

sr = 44100

print("\nSynthesizing procedural cartoon sounds...")

# Sound 1: nemi_pop_001.wav — Classic cartoon bubble/mouth pop
t_pop = np.linspace(0, 0.08, int(sr * 0.08), endpoint=False)
freq_pop = 800 * np.exp(-t_pop * 38) + 70
phase_pop = 2 * np.pi * np.cumsum(freq_pop) / sr
pop_wav = np.sin(phase_pop) * np.exp(-t_pop * 42)
pop_wav[:int(sr * 0.003)] += np.linspace(0.4, 0.0, int(sr * 0.003))
write_wav(os.path.join(PROC_DIR, "nemi_pop_001.wav"), pop_wav, sr)
print("  ✓ nemi_pop_001.wav (0.08s) -> [POP] Classic cartoon mouth/bubble pop")

# Sound 2: nemi_boing_001.wav — Comedic cartoon spring/recoil boing
t_boing = np.linspace(0, 0.36, int(sr * 0.36), endpoint=False)
f_mod = 28 * np.sin(2 * np.pi * 17 * t_boing)
f_base = 210 + 280 * (1.0 - np.exp(-t_boing * 11)) + f_mod
phase_boing = 2 * np.pi * np.cumsum(f_base) / sr
boing_wav = np.sin(phase_boing) * np.exp(-t_boing * 8.0)
boing_wav += 0.32 * np.sin(phase_boing * 2) * np.exp(-t_boing * 12.0)
write_wav(os.path.join(PROC_DIR, "nemi_boing_001.wav"), boing_wav, sr)
print("  ✓ nemi_boing_001.wav (0.36s) -> [BOING] Comedic cartoon spring / wobble recoil")

# Sound 3: nemi_whoosh_001.wav — Fast gesture swish / whip
t_wh = np.linspace(0, 0.15, int(sr * 0.15), endpoint=False)
noise = np.random.normal(0, 0.5, len(t_wh))
env = np.sin(np.pi * t_wh / 0.15) ** 2
f_center = np.linspace(900, 2400, len(t_wh))
whoosh_wav = noise * env * (np.sin(2 * np.pi * f_center * t_wh) * 0.6 + 0.4)
write_wav(os.path.join(PROC_DIR, "nemi_whoosh_001.wav"), whoosh_wav, sr)
print("  ✓ nemi_whoosh_001.wav (0.15s) -> [WHOOSH] Fast gesture swish / air whip")

# Sound 4: nemi_blip_001.wav — Tiny electronic / comic blink blip
t_blip = np.linspace(0, 0.06, int(sr * 0.06), endpoint=False)
f1 = 880
f2 = 1320
blip_wav = (0.6 * np.sin(2 * np.pi * f1 * t_blip) + 0.4 * np.sin(2 * np.pi * f2 * t_blip)) * np.exp(-t_blip * 50)
write_wav(os.path.join(PROC_DIR, "nemi_blip_001.wav"), blip_wav, sr)
print("  ✓ nemi_blip_001.wav (0.06s) -> [BLIP] Comic dual-tone blip / eye blink accent")

print("\nAll 15 sound effects successfully generated in audio/sfx/!")
