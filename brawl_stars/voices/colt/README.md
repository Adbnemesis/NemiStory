# Colt Voice Performance Bible (Brawl Stars)

> **Vocal Identity**: Cocky Show-Off Gamer / Delusional Anime Protagonist
> **Base Archetype**: Derived from `edgar` with `+2.0` semitones pitch modulation.
> **Acoustic Anchor**: Uses `voices/edgar/selected/edgar_anchor_master.wav`

---

## 1. Personality & Vocal Dynamics
- **Tone**: Confident, slightly flashy show-off gamer, brighter tone, cheerful comedic vanity, anime protagonist complex.
- **Pitch Shift**: `+2.0` semitones.
- **Comedic Role**: Plays directly against Edgar's cynicism and Leon's frantic con-man energy in long-form YouTube episodes.

---

## 2. How to Generate Colt Dialogue

```bash
# Generate a line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/colt/config/generate_colt.py \
  --text "Your dialogue line goes here." \
  --emotion casual \
  --output colt_line.wav
```

Or use the universal generator:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler colt \
  --text "Your dialogue line goes here." \
  --output colt_line.wav
```
