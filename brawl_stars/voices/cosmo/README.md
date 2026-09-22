# Cosmo Voice Performance Bible (Brawl Stars)

> **Vocal Identity**: Quirky Starr Park Astronomer / Fast-Talking Scientific Rambler
> **Base Archetype**: Derived from `leon` with `-0.5` semitones pitch modulation.
> **Acoustic Anchor**: Uses `voices/leon/selected/leon_anchor_master.wav`

---

## 1. Personality & Vocal Dynamics
- **Tone**: Quirky eccentric Starr Park astronomer, fast-talking scientific rambler, cosmic theories, erratic nerdy comedic energy.
- **Pitch Shift**: `-0.5` semitones.
- **Comedic Role**: Plays directly against Edgar's cynicism and Leon's frantic con-man energy in long-form YouTube episodes.

---

## 2. How to Generate Cosmo Dialogue

```bash
# Generate a line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/cosmo/config/generate_cosmo.py \
  --text "Your dialogue line goes here." \
  --emotion casual \
  --output cosmo_line.wav
```

Or use the universal generator:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler cosmo \
  --text "Your dialogue line goes here." \
  --output cosmo_line.wav
```
