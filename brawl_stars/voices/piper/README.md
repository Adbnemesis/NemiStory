# Piper Voice Performance Bible (Brawl Stars)

> **Vocal Identity**: Southern Belle Sniper / Sugary Polite Passive-Aggressive
> **Base Archetype**: Derived from `leon` with `+4.0` semitones pitch modulation.
> **Acoustic Anchor**: Uses `voices/leon/selected/leon_anchor_master.wav`

---

## 1. Personality & Vocal Dynamics
- **Tone**: High-pitched feminine Southern belle sniper, sugary sweet polite tone hiding cold passive-aggressive condescension.
- **Pitch Shift**: `+4.0` semitones.
- **Comedic Role**: Plays directly against Edgar's cynicism and Leon's frantic con-man energy in long-form YouTube episodes.

---

## 2. How to Generate Piper Dialogue

```bash
# Generate a line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/piper/config/generate_piper.py \
  --text "Your dialogue line goes here." \
  --emotion casual \
  --output piper_line.wav
```

Or use the universal generator:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler piper \
  --text "Your dialogue line goes here." \
  --output piper_line.wav
```
