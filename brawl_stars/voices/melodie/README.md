# Melodie Voice Performance Bible (Brawl Stars)

> **Vocal Identity**: Sassy K-pop Popstar Diva / Hyper-Expressive Teen Idol
> **Base Archetype**: Derived from `leon` with `+3.5` semitones pitch modulation.
> **Acoustic Anchor**: Uses `voices/leon/selected/leon_anchor_master.wav`

---

## 1. Personality & Vocal Dynamics
- **Tone**: Energetic, sassy feminine K-pop idol popstar, snappy rhythmic speech, hyper-expressive teen diva attitude.
- **Pitch Shift**: `+3.5` semitones.
- **Comedic Role**: Plays directly against Edgar's cynicism and Leon's frantic con-man energy in long-form YouTube episodes.

---

## 2. How to Generate Melodie Dialogue

```bash
# Generate a line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/melodie/config/generate_melodie.py \
  --text "Your dialogue line goes here." \
  --emotion casual \
  --output melodie_line.wav
```

Or use the universal generator:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler melodie \
  --text "Your dialogue line goes here." \
  --output melodie_line.wav
```
