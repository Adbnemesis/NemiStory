# Kenji Voice Performance Bible (Brawl Stars)

> **Vocal Identity**: Disciplined Sushi Chef Samurai / Stoic Anime Swordsman
> **Base Archetype**: Derived from `edgar` with `-1.5` semitones pitch modulation.
> **Acoustic Anchor**: Uses `voices/edgar/selected/edgar_anchor_master.wav`

---

## 1. Personality & Vocal Dynamics
- **Tone**: Disciplined stoic sushi chef samurai, deadpan anime swordsman, low serious register, sharp honorable focus.
- **Pitch Shift**: `-1.5` semitones.
- **Comedic Role**: Plays directly against Edgar's cynicism and Leon's frantic con-man energy in long-form YouTube episodes.

---

## 2. How to Generate Kenji Dialogue

```bash
# Generate a line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/kenji/config/generate_kenji.py \
  --text "Your dialogue line goes here." \
  --emotion casual \
  --output kenji_line.wav
```

Or use the universal generator:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler kenji \
  --text "Your dialogue line goes here." \
  --output kenji_line.wav
```
