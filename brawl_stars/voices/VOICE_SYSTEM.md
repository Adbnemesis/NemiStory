# Brawl Stars Comedy Voice System & Character Derivation Guide

> **Core Philosophy**: Authentic comedy voice acting relies on sharp comedic contrast, believable timing, imperfect speech rhythms, and distinct archetypes. Rather than creating generic AI voices, our system is anchored by **two core comedic human voice actor archetypes** extracted and cloned from master reference comedy performances:
>
> 🎥 **Original Source & Provenance**: Cloned from the viral animated comedy short:
> * **Title**: *"The Pokemon that wants to WASTE your Master Ball"* by **Gumbino**
> * **YouTube Video**: [`https://www.youtube.com/watch?v=FIvcwFBM2hg`](https://www.youtube.com/watch?v=FIvcwFBM2hg)
> * **Voice Cloning Engine**: `mlx-community/Qwen3-TTS-12Hz-1.7B-Base-bf16` (Apple Silicon MLX offline zero-shot voice cloning)
> * **Archetype 1 (Leon)**: Cloned from the manic, fast-talking **Articuno** performance.
> * **Archetype 2 (Edgar)**: Cloned from the unbothered, cynical **Trainer** performance.
>
> 📖 **Writing Comedy Scripts?** See the full [Brawl Stars Comedy Scriptwriting Bible (Gumbino & Solid jj Method)](file:///Users/talus/Documents/adb/brawl_stars/voices/COMEDY_SCRIPTWRITING_GUIDE.md) for scene structure, 5-beat rhythm, dialogue rules, and ready-to-render templates!

---

## 1. The Two Foundational Comedy Archetypes

```
                               ┌──────────────────────────────────────────────────────────┐
                               │             BRAWLER VOICE ARCHITECTURE                   │
                               └──────────────────────────────────────────────────────────┘
                                                            │
                            ┌───────────────────────────────┴───────────────────────────────┐
                            ▼                                                               ▼
        ┌───────────────────────────────────────┐                       ┌───────────────────────────────────────┐
        │       ARCHETYPE 1: LEON               │                       │       ARCHETYPE 2: EDGAR              │
        │  (Fast-Talking Manic Agitator)        │                       │  (Deadpan Cynical Skeptic)            │
        ├───────────────────────────────────────┤                       ├───────────────────────────────────────┤
        │ • Pitch: 180–320 Hz dynamic range     │                       │ • Pitch: 110–145 Hz flat baseline     │
        │ • Cadence: 5.2–6.5 syllables/sec      │                       │ • Cadence: 3.8–4.5 syllables/sec      │
        │ • Delivery: Persuasive, con-artist,   │                       │ • Delivery: Skeptical gamer, unbothered│
        │   pleading, cracking shouts, panic    │                       │   flat deadpan, quiet disbelief       │
        │ • Master Anchor:                      │                       │ • Master Anchor:                      │
        │   voices/leon/selected/               │                       │   voices/edgar/selected/              │
        │   leon_anchor_master.wav              │                       │   edgar_anchor_master.wav             │
        └───────────────────────────────────────┘                       └───────────────────────────────────────┘
                            │                                                               │
                            ▼                                                               ▼
                 DERIVED BRAWLERS:                                               DERIVED BRAWLERS:
                 • Fang   (+1.0 semitone)                                        • Colt  (+2.0 semitones)
                 • Crow   (-2.0 semitones)                                       • Bull  (-4.0 semitones)
                 • Gus    (+3.0 semitones)                                       • Frank (-5.0 semitones)
```

---

## 2. Acoustic Characteristics Comparison

| Acoustic Feature | Archetype 1: Leon (Articuno style) | Archetype 2: Edgar (Trainer style) |
|---|---|---|
| **Vocal Pitch Range** | Wide excursion (180 Hz to 320 Hz) | Narrow baseline (110 Hz to 145 Hz) |
| **Speaking Rate** | Rapid (5.2 – 6.5 syllables/second) | Relaxed / deliberate (3.8 – 4.5 syllables/second) |
| **Comedic Specialty** | Manic justifications, panic shouts, fast-talking con-man | Flat deadpan observations, sarcastic quips, dry sighs |
| **Pre-Utterance Pause** | Short, breathless entry (`0.05s – 0.15s`) | Stunned pre-speech hesitation (`0.3s – 0.5s`) |
| **Sentence Endings** | Upward comedic pitch inflection or cracking exclamation | Flat downwards drop into indifferent silence |
| **Energy Explosions** | High-frequency screaming: `"NO—WHAT ARE YOU DOING?!"` | Quiet understated remarks: `"He died."` |

---

## 3. Master Golden Anchor Directory

All reference anchors are clean 24kHz 16-bit PCM WAVs with verbatim reference transcripts:

### Leon Master Anchors (`brawl_stars/voices/leon/selected/`)
1. [`leon_anchor_master.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/leon/selected/leon_anchor_master.wav) (3.45s) — *"Wait! Come on, I'm telling you, I'm the guy you're looking for, me! Articuno! There's no one else worth using a Master Ball after this!"*
2. [`leon_anchor_fast_persuasive.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/leon/selected/leon_anchor_fast_persuasive.wav) (2.25s) — *"Wait! Come on, I'm telling you, I'm the guy you're looking for, me!"*
3. [`leon_anchor_screaming_plea.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/leon/selected/leon_anchor_screaming_plea.wav) (2.65s) — *"I'll do anything! I'll wear a little hat! I'll do a backflip! Look, I'm doing a backflip right now!"*

### Edgar Master Anchors (`brawl_stars/voices/edgar/selected/`)
1. [`edgar_anchor_master.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/edgar/selected/edgar_anchor_master.wav) (4.10s) — *"But you're level 50, I'm pretty sure the main legendary Pokemon is usually like level 70 or something. Yeah, I'm not using my Master Ball on you."*
2. [`edgar_anchor_casual.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/edgar/selected/edgar_anchor_casual.wav) (3.30s) — *"Yeah, and I'll catch you with an Ultra Ball instead, wait."*
3. [`edgar_anchor_annoyed.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/edgar/selected/edgar_anchor_annoyed.wav) (1.60s) — *"Hey, can you please stop flying around me?"*

### Cloning Model & Hyperparameters
* **Model ID**: `mlx-community/Qwen3-TTS-12Hz-1.7B-Base-bf16`
* **Inference Runtime**: Apple Silicon MLX GPU (`mlx-audio`)
* **Voice Cloning Mode**: Zero-shot prompt-guided voice cloning via reference audio WAV + transcription TXT
* **Default Hyperparameters**:
  * `temperature`: `0.85`
  * `top_p`: `0.95`
  * `top_k`: `50`
  * `repetition_penalty`: `1.05`
  * `sample_rate`: `24,000 Hz` (PCM 16-bit uncompressed WAV)
  * `target_peak_normalization`: `0.92`
  * `seed`: `42`

---

## 4. Master 11-Brawler Derivation Matrix

All 11 Brawlers are derived directly from the two authentic comedic voice actor anchors (`leon` and `edgar`), ensuring identical high-standard comedic timing and performance fidelity:

| Brawler Name | Base Actor | Pitch Shift | Gender / Register | Comedy Archetype & Vocal Performance |
|---|---|---|---|---|
| **Edgar** | `edgar` | `0.0` st | Male (Low-Mid) | Flat cynical deadpan, unbothered gamer, quiet existential roasts |
| **Leon** | `leon` | `0.0` st | Male (Mid-High) | Fast-talking manic agitator, dynamic pitch swings, con-artist kid |
| **Colt** | `edgar` | `+2.0` st | Male (Bright) | Cocky pretty-boy gamer, cheerful vanity, anime protagonist complex |
| **Shelly** | `leon` | `+2.5` st | Female (Tough) | Tough, aggressive, no-nonsense shotgunner, sharp combat authority |
| **Cosmo** | `leon` | `-0.5` st | Male (Quirky) | Eccentric Starr Park astronomer, fast-talking scientific rambler |
| **Kenji** | `edgar` | `-1.5` st | Male (Stoic) | Disciplined sushi chef samurai, deadpan anime swordsman, honorable |
| **Mortis** | `leon` | `-1.5` st | Male (Theatrical) | Melodramatic Victorian vampire aristocrat who dashes into walls |
| **Crow** | `leon` | `-2.0` st | Male (Gritty) | Cynical raspy rogue assassin, snappy aggressive rhythm, sharp bite |
| **Fang** | `leon` | `+1.0` st | Male (Excited) | Hyperactive kung-fu movie fanboy, loud martial arts sound effects |
| **Piper** | `leon` | `+4.0` st | Female (High) | High-pitched Southern belle sniper, sugary polite passive-aggressive |
| **Melodie** | `leon` | `+3.5` st | Female (Sassy) | Sassy K-pop idol popstar, snappy rhythmic speech, teen diva attitude |

---

## 5. Universal Brawler CLI Generator

Use [`brawl_stars/voices/generate_brawler.py`](file:///Users/talus/Documents/adb/brawl_stars/voices/generate_brawler.py):

```bash
# 1. Generate Leon line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler leon \
  --text "TRUST ME! I'M TELLING YOU IT'S FREE TROPHIES!" \
  --emotion sudden_shock \
  --output leon_shout.wav

# 2. Generate Edgar line
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler edgar \
  --text "He died." \
  --emotion deadpan \
  --output edgar_deadpan.wav

# 3. Generate Crow (Leon base with -2.0 semitone pitch shift)
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler crow \
  --text "Don't mess with my crew." \
  --output crow_line.wav

# 4. Generate Colt (Edgar base with +2.0 semitone pitch shift)
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --brawler colt \
  --text "Watch and learn, amateurs." \
  --output colt_line.wav

# 5. Create a Custom Brawler on the Fly
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/generate_brawler.py \
  --base leon \
  --pitch +1.5 \
  --instruct "Hyperactive mischievous gremlin, snickering" \
  --text "You can't catch me!" \
  --output custom_line.wav
```
