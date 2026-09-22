# Mortis Voice Performance Bible (Brawl Stars)

> **Vocal Identity**: Melodramatic Victorian Vampire Aristocrat / Wall Dasher
> **Base Archetype**: Derived from `leon` with `-1.5` semitones pitch modulation.
> **Acoustic Anchor**: Uses `voices/leon/selected/leon_anchor_master.wav`

---

## 1. Personality & Vocal Dynamics
- **Tone**: Theatrical flamboyant Victorian vampire aristocrat, melodramatic cadence, pompous aristocratic ego, dramatic pauses.
- **Pitch Shift**: `-1.5` semitones.
- **Comedic Role**: Plays directly against Edgar's cynicism and Leon's frantic con-man energy in long-form YouTube episodes.

---

## 2. How to Generate Mortis Dialogue

```bash
# Generate a line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/mortis/config/generate_mortis.py \
  --text "Your dialogue line goes here." \
  --emotion casual \
  --output mortis_line.wav
```

Or use the universal generator:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler mortis \
  --text "Your dialogue line goes here." \
  --output mortis_line.wav
```
