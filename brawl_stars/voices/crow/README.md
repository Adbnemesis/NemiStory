# Crow Voice Performance Bible (Brawl Stars)

> **Vocal Identity**: Cynical Raspy Rogue Biker / Toxic Assassin
> **Base Archetype**: Derived from `leon` with `-2.0` semitones pitch modulation.
> **Acoustic Anchor**: Uses `voices/leon/selected/leon_anchor_master.wav`

---

## 1. Personality & Vocal Dynamics
- **Tone**: Slightly raspy vocal fry, cynical rogue assassin, snappy aggressive rhythm, sharp comedic bite, impatient.
- **Pitch Shift**: `-2.0` semitones.
- **Comedic Role**: Plays directly against Edgar's cynicism and Leon's frantic con-man energy in long-form YouTube episodes.

---

## 2. How to Generate Crow Dialogue

```bash
# Generate a line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/crow/config/generate_crow.py \
  --text "Your dialogue line goes here." \
  --emotion casual \
  --output crow_line.wav
```

Or use the universal generator:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler crow \
  --text "Your dialogue line goes here." \
  --output crow_line.wav
```
