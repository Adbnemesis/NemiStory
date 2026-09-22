# Shelly Voice Performance Bible (Brawl Stars)

> **Vocal Identity**: Tough Latina Combat Veteran / No-Nonsense Shotgunner
> **Base Archetype**: Derived from `leon` with `+2.5` semitones pitch modulation.
> **Acoustic Anchor**: Uses `voices/leon/selected/leon_anchor_master.wav`

---

## 1. Personality & Vocal Dynamics
- **Tone**: Tough, aggressive, confident female brawler, sharp authoritative delivery, shotgun combat veteran, no-nonsense attitude.
- **Pitch Shift**: `+2.5` semitones.
- **Comedic Role**: Plays directly against Edgar's cynicism and Leon's frantic con-man energy in long-form YouTube episodes.

---

## 2. How to Generate Shelly Dialogue

```bash
# Generate a line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/shelly/config/generate_shelly.py \
  --text "Your dialogue line goes here." \
  --emotion casual \
  --output shelly_line.wav
```

Or use the universal generator:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler shelly \
  --text "Your dialogue line goes here." \
  --output shelly_line.wav
```
