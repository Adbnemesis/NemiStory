# Fang Voice Performance Bible (Brawl Stars)

> **Vocal Identity**: Hyperactive Martial Arts Fanboy / Cinema Enthusiast
> **Base Archetype**: Derived from `leon` with `+1.0` semitones pitch modulation.
> **Acoustic Anchor**: Uses `voices/leon/selected/leon_anchor_master.wav`

---

## 1. Personality & Vocal Dynamics
- **Tone**: High energy martial arts movie fanboy, rapid-fire cadence, loud and excited, shouting comedic sound effects.
- **Pitch Shift**: `+1.0` semitones.
- **Comedic Role**: Plays directly against Edgar's cynicism and Leon's frantic con-man energy in long-form YouTube episodes.

---

## 2. How to Generate Fang Dialogue

```bash
# Generate a line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/fang/config/generate_fang.py \
  --text "Your dialogue line goes here." \
  --emotion casual \
  --output fang_line.wav
```

Or use the universal generator:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler fang \
  --text "Your dialogue line goes here." \
  --output fang_line.wav
```
