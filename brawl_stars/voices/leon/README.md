# Leon Voice Performance Bible (Cutenemi / Brawl Stars)

> **Vocal Identity**: Young, agile, fast-talking male voice actor with high comedic pitch agility, expressive cadences, frantic justifications, con-artist persuasiveness, and sudden cracking panic shouts (*"I'LL DO ANYTHING! LOOK, I'M DOING A BACKFLIP RIGHT NOW!"*). Sounds like a genuine human comedic actor performing with energetic comedic timing and high entertainment value.
>
> 📖 **Writing Comedy Dialogue?** Refer to the [Brawl Stars Comedy Scriptwriting Bible](file:///Users/talus/Documents/adb/brawl_stars/voices/COMEDY_SCRIPTWRITING_GUIDE.md) for scene formulas and formatting tricks.

---

## 1. Master Reference Anchors

Leon's voice is cloned from the master comedic performance anchor (`leon_anchor_master.wav`).

Master anchor files are located in [`brawl_stars/voices/leon/selected/`](file:///Users/talus/Documents/adb/brawl_stars/voices/leon/selected/):

1. **Master Anchor**: [`leon_anchor_master.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/leon/selected/leon_anchor_master.wav) (3.45s)
   - *Verbatim*: *"Wait! Come on, I'm telling you, I'm the guy you're looking for, me! Articuno! There's no one else worth using a Master Ball after this!"*
2. **Fast Persuasive Anchor**: [`leon_anchor_fast_persuasive.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/leon/selected/leon_anchor_fast_persuasive.wav) (2.25s)
   - *Verbatim*: *"Wait! Come on, I'm telling you, I'm the guy you're looking for, me!"*
3. **Screaming Plea Anchor**: [`leon_anchor_screaming_plea.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/leon/selected/leon_anchor_screaming_plea.wav) (2.65s)
   - *Verbatim*: *"I'll do anything! I'll wear a little hat! I'll do a backflip! Look, I'm doing a backflip right now!"*

---

## 2. Emotional Acting Presets

Defined in [`brawl_stars/voices/leon/config/leon_presets.json`](file:///Users/talus/Documents/adb/brawl_stars/voices/leon/config/leon_presets.json):

| Preset | Energy | Instruction | Best For | Example Line |
|---|---|---|---|---|
| `fast_talk` | High | `Fast-talking, animated, persuasive con-artist cadence, rapid justification.` | Persuading teammates, rapid plans | `"Trust me! I jump in, I hit the gadget, free trophies!"` |
| `sudden_shock` | Extreme | `Sudden explosive shock, fast high pitch, shouting in utter disbelief and alarm.` | Ambush, sudden death | `"NO—WHAT ARE YOU DOING?!"` |
| `screaming_panic` | Extreme | `Genuine loss of composure, sudden desperate shout, cracking with exasperation.` | Trapped, panic jumping | `"I WON'T DIE! WATCH ME! I'M JUMPING RIGHT NOW!"` |
| `casual` | Normal | `Casual, fast-paced throwaway remark, conversational speech among gaming buddies.` | Moving across the map, baseline | `"Yeah, that's probably fine."` |
| `dry_sarcasm` | Normal | `Understated dry sarcasm, flat comedic cynicism, subtle mocking deadpan.` | Cynical observations | `"Oh, great. Awesome. Exactly what I wanted."` |
| `annoyance` | Normal | `Tired, disappointed annoyance, short exasperated tone, fed up with teammate.` | Teammate misses trickshot | `"Bro. Come on."` |
| `laughing` | High | `Spontaneous bursting laughter before speaking, genuine chuckles, hilarious disbelief.` | Watching opponent fail | `"PFFT—HAHAHAHA—bro, there's no way."` |
| `deadpan` | Low | `Deadpan, completely flat matter-of-fact delivery, zero drama, totally calm.` | Contrast comedy | `"He died."` |
| `whisper_disbelief` | Low | `Soft breathy whisper of utter existential disbelief, stunned confusion.` | Shocked whisper | `"...why?"` |

---

## 3. How to Generate Leon Dialogue

Use [`brawl_stars/voices/leon/config/generate_leon.py`](file:///Users/talus/Documents/adb/brawl_stars/voices/leon/config/generate_leon.py):

### Single Line Generation
```bash
# High energy / persuasive line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/leon/config/generate_leon.py \
  --text "Trust me! I jump in, I hit the gadget, they're dead before they can react!" \
  --emotion fast_talk \
  --output leon_hype.wav

# Screaming panic
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/leon/config/generate_leon.py \
  --text "I WON'T DIE! WATCH ME! I'M JUMPING RIGHT NOW!" \
  --emotion screaming_panic \
  --output leon_scream.wav

# Pitch modulation (e.g. +1.5 semitones for younger / squeakier sound)
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/leon/config/generate_leon.py \
  --text "Watch this trickshot!" \
  --pitch +1.5 \
  --output leon_young.wav
```

### Script Batch Generation
Create a JSON file:
```json
[
  { "text": "Trust me, it's free trophies!", "emotion": "fast_talk", "output": "scene_01.wav" },
  { "text": "I WON'T DIE! WATCH ME!", "emotion": "screaming_panic", "output": "scene_02.wav" }
]
```
Then run:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/leon/config/generate_leon.py --script scene.json
```
