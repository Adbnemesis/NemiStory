# NemiStory — Multi-Universe 2D Animation & Voice Production Engine

[![Engine: Godot 4.x](https://img.shields.io/badge/Engine-Godot%204.x-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Python: 3.10+](https://img.shields.io/badge/Python-3.10%2B-blue?logo=python&logoColor=white)](https://python.org)
[![Voice: Qwen3--TTS (MLX)](https://img.shields.io/badge/Voice-Qwen3--TTS%20(Sohee)-green)](nemi/docs/Nemi_Voice_Profile.md)
[![Brawl Stars Voices](https://img.shields.io/badge/Brawl%20Stars-11%20Brawlers%20(Leon%20%26%20Edgar)-orange)](brawl_stars/voices/VOICE_SYSTEM.md)
[![Style: Illustrated 2D](https://img.shields.io/badge/Style-Vector%20%26%20Skeletal%20Rig-purple)](nemi/docs/NEMI_ANIMATION_PRODUCTION_BIBLE.md)

**NemiStory** is a complete, self-contained animated production engine built on **Godot 4.x**, **Python**, and **local offline neural TTS**. It powers three distinct animated production universes with unified illustrated assets, procedural skeletal rigs, and professional audio engineering:

1. **Nemi (`nemi/`)**: Illustrated YouTube storytelling channel starring Nemi—a 24-year-old creative, observant, and subtly chaotic storyteller learning 2D animation.
2. **Brawl Stars (`brawl_stars/`)**: Fast-paced animated comedy shorts featuring 11 Brawlers (Leon, Edgar, Colt, Shelly, Cosmo, Kenji, Mortis, Crow, Fang, Piper, Melodie) anchored by custom comedic voice actor models.
3. **Pokémon (`pokemon/`)**: Native Godot 2D illustrated character rigs and animation showcases for Ash Ketchum and Pikachu.
4. **Common Core (`common/`)**: Curated CC0 audio SFX vault (400+ cues) and shared Godot engine modules.

---

## 1. Prerequisites (New Device Setup)

To set up and run this entire production pipeline from scratch on any new machine:

### 1. Godot Engine 4.x
* **Version**: Godot 4.3 or 4.4 (Standard Edition, 64-bit).
* **Download**: [godotengine.org/download](https://godotengine.org/download)
* **macOS Setup**:
  - Download `Godot_v4.x-stable_macos.universal.zip`.
  - Move `Godot.app` to `/Applications/`.
  - Add to shell path (optional but recommended):
    ```bash
    echo 'alias godot="/Applications/Godot.app/Contents/MacOS/Godot"' >> ~/.zshrc
    source ~/.zshrc
    ```

### 2. FFmpeg
Used for automated video rendering (transcoding Godot MovieWriter raw output to 4K/1080p H.264 MP4) and audio multiplexing.
* **macOS (Homebrew)**:
  ```bash
  brew install ffmpeg
  ```
* **Ubuntu / Debian**:
  ```bash
  sudo apt update && sudo apt install -y ffmpeg
  ```
* **Windows (Chocolatey)**:
  ```bash
  choco install ffmpeg
  ```

### 3. Python 3.10+ / 3.11+
Powers the offline neural TTS pipelines, batch rendering, and audio mastering scripts.
* **macOS**: `brew install python@3.11`
* **Linux**: `sudo apt install -y python3 python3-venv python3-pip`

---

## 2. Quick Start: Fresh Machine Setup

### Step 1: Clone Repository
```bash
git clone https://github.com/Adbnemesis/NemiStory.git
cd NemiStory
```

### Step 2: Set Up Python Virtual Environment
```bash
python3 -m venv .venv
source .venv/bin/activate    # On Windows: .venv\Scripts\activate

pip install --upgrade pip
pip install -r requirements.txt
```

> [!TIP]
> On Apple Silicon Macs (M1/M2/M3/M4), `requirements.txt` installs `mlx` and `mlx-audio` for local, offline GPU-accelerated voice synthesis. On non-macOS systems (Linux/Windows), standard PyTorch `transformers` can be used for voice synthesis, while Godot rendering and SFX mixing function identically across all operating systems.

### Step 3: Open in Godot Engine
1. Launch **Godot Engine 4.x**.
2. Click **Import** $\longrightarrow$ navigate to the cloned `NemiStory/` folder.
3. Select `project.godot` and click **Import & Edit**.
4. Godot will automatically import, index, and cache all textures, scenes, and audio files into `.godot/` (takes ~15–30 seconds on first launch).

---

## 3. Production Universes & Architecture

```
NemiStory/
├── nemi/                           # NEMI STORYTIME PRODUCTION UNIVERSE
│   ├── characters/nemi/            # Nemi's canonical Skeleton2D rig, facial API & reaction FX
│   ├── episodes/                   # Production episodes
│   │   ├── ep00_introduction/      # Episode 00: "Wait, Listen to Me"
│   │   ├── ep01_cat/               # Episode 01: "The Cat That Walked In"
│   │   ├── ep02_partner/           # Episode 02: "Group Project Partner"
│   │   ├── ep03_scolded/           # Episode 03: "Getting Scolded in Public"
│   │   └── ep04_scared/            # Episode 04: "Guys, I'm Scared"
│   ├── world/                      # Doodles, illustrated props, StoryCamera2D, composition
│   ├── audio/nemi/                 # Canonical voiceover masters & dialogue segments
│   │   ├── auditions/custom_actors/sohee/  # Sohee golden audition showcase tracks
│   │   └── intro/                  # EP00 22-segment dialogue stems & 125s master track
│   └── docs/                       # Character Bible, Voice Profile & Production Guides
│
├── brawl_stars/                    # BRAWL STARS COMEDY UNIVERSE
│   ├── characters/                 # Illustrated brawler rigs (Leon, Ruffs, etc.)
│   ├── episodes/                   # Episode scenes (e.g. Ep01 Ruffs' Revenge)
│   └── voices/                     # 11-Brawler comedic voice system
│       ├── generate_brawler.py     # Universal Brawler voice generator CLI
│       ├── leon/selected/          # Archetype 1 Golden Anchors (Fast Manic Agitator)
│       ├── edgar/selected/         # Archetype 2 Golden Anchors (Deadpan Cynic)
│       └── [colt, crow, fang, ...] # Character configs & audition samples
│
├── pokemon/                        # POKÉMON ILLUSTRATED UNIVERSE
│   ├── characters/                 # Ash Ketchum & Pikachu native 2D skeletal rigs
│   ├── scenes/                     # PokemonShowcase.tscn (28-step animation test)
│   └── docs/                       # Ash & Pikachu rig specifications
│
├── common/                         # SHARED ASSETS & CORE LIBRARIES
│   ├── audio/sfx/                  # 400+ CC0 sound effects (cartoon, gym, ui, comedic)
│   └── engine/                     # Shared camera, annotation, and math utilities
│
├── tools/                          # CLI AUTOMATION SCRIPTS
│   ├── generate_nemi_voice.py      # Nemi offline Qwen3-TTS dialogue generation
│   ├── audition_custom_voices.py   # Voice audition & showcase generator
│   ├── mix_ep00_sfx.py             # Episode 00 audio mastering & SFX mixer
│   ├── render_ep00_v3_3.py         # Episode 00 4K 60FPS MovieWriter renderer
│   ├── render_episode_ruffs_revenge.py # Brawl Stars short 1080p renderer
│   └── render_pokemon_showcase.py  # Pokémon animation showcase renderer
│
├── requirements.txt                # Python dependencies
└── project.godot                   # Godot 4.x project configuration (Canvas Items 4K)
```

---

## 4. Voice System: How to Get Exact Voices on a New Device

### A. Nemi's Canonical Voice (Qwen3-TTS CustomVoice: Sohee)

Nemi's voice is **100% deterministic and permanently locked** to the official predefined voice actor **`sohee`** (`spk_id: 2864`) in Qwen3-TTS. It never suffers from speaker drift between takes or episodes.

#### Model Details:
* **Hugging Face Model ID**: `mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`
* **Runtime**: Apple Silicon MLX via `mlx-audio`
* **Speaker ID**: `sohee` (predefined embedding hardcoded into talker weights)
* **Sampling Rate**: `24,000 Hz` (PCM 16-bit uncompressed WAV)
* **Canonical Persona Prompt**:
  > *"Warm, natural young adult woman around 24, relaxed conversational speech, friendly, casual, intelligent, slightly playful."*

#### Sampling Parameters:
* `temperature`: `0.7`
* `top_k`: `50`
* `top_p`: `0.95`
* `repetition_penalty`: `1.05`

#### Generation Commands:
```bash
# 1. Audition the voice actors or regenerate Sohee test lines:
python3 tools/audition_custom_voices.py

# 2. Synthesize complete episode voiceover (e.g. Episode 00):
python3 tools/generate_nemi_voice.py \
  --script nemi/episodes/ep00_introduction/script/script.md \
  --output nemi/audio/nemi/intro \
  --speaker sohee
```
* On first run, the model weights (~3.4 GB) are automatically fetched from Hugging Face into `~/.cache/huggingface/hub/` and cached permanently offline.

---

### B. Brawl Stars Comedy Voices (Leon, Edgar & 11 Brawlers)

The Brawl Stars comedy shorts use a **two-archetype derivation architecture** based on authentic comedic timing cloned from a viral animated comedy short:

#### Source & Cloning Provenance:
* **Original Video**: *"The Pokemon that wants to WASTE your Master Ball"* by **Gumbino** ([Watch on YouTube](https://www.youtube.com/watch?v=FIvcwFBM2hg)).
* **Cloning Model**: `mlx-community/Qwen3-TTS-12Hz-1.7B-Base-bf16` (Apple Silicon MLX GPU zero-shot voice cloning with prompt + reference audio).
* **Archetype 1 — Leon**: Cloned from the **Articuno** character performance.
  - *Acoustic Profile*: Fast-talking manic agitator con-artist; rapid cadence (`5.2–6.5 syllables/sec`), dynamic pitch range (`180–320 Hz`), breathless entry (`0.05–0.15s`), cracking exclamations.
  - *Master Reference Audio*: [`brawl_stars/voices/leon/selected/leon_anchor_master.wav`](brawl_stars/voices/leon/selected/leon_anchor_master.wav) (3.45s)
  - *Reference Transcript*: *"Wait! Come on, I'm telling you, I'm the guy you're looking for, me! Articuno! There's no one else worth using a Master Ball after this!"*
* **Archetype 2 — Edgar**: Cloned from the **Trainer** character performance.
  - *Acoustic Profile*: Deadpan cynical skeptic; deliberate cadence (`3.8–4.5 syllables/sec`), flat baseline pitch (`110–145 Hz`), stunned pre-speech hesitation (`0.3–0.5s`), flat downward drop into indifferent silence.
  - *Master Reference Audio*: [`brawl_stars/voices/edgar/selected/edgar_anchor_master.wav`](brawl_stars/voices/edgar/selected/edgar_anchor_master.wav) (4.10s)
  - *Reference Transcript*: *"But you're level 50, I'm pretty sure the main legendary Pokemon is usually like level 70 or something. Yeah, I'm not using my Master Ball on you."*

#### Sampling & Cloning Parameters:
* `temperature`: `0.85`
* `top_p`: `0.95`
* `top_k`: `50`
* `repetition_penalty`: `1.05`
* `sample_rate`: `24,000 Hz` (PCM 16-bit uncompressed WAV)
* `target_peak_normalization`: `0.92`
* `seed`: `42`

All 11 Brawlers are derived via pitch shifts and emotion prompts using [`brawl_stars/voices/generate_brawler.py`](brawl_stars/voices/generate_brawler.py):

| Brawler | Base Anchor | Pitch Shift | Emotion / Style |
|---|---|---|---|
| **Leon** | `leon` | `0.0` st | Manic, fast, con-artist kid |
| **Edgar** | `edgar` | `0.0` st | Flat cynical deadpan, unbothered |
| **Colt** | `edgar` | `+2.0` st | Cocky pretty-boy gamer |
| **Shelly** | `leon` | `+2.5` st | Tough, aggressive combat authority |
| **Cosmo** | `leon` | `-0.5` st | Eccentric Starr Park astronomer |
| **Kenji** | `edgar` | `-1.5` st | Stoic samurai sushi chef |
| **Mortis** | `leon` | `-1.5` st | Theatrical melodramatic vampire |
| **Crow** | `leon` | `-2.0` st | Raspy gritty rogue assassin |
| **Fang** | `leon` | `+1.0` st | Hyperactive kung-fu movie fanboy |
| **Piper** | `leon` | `+4.0` st | Sugary polite Southern belle sniper |
| **Melodie** | `leon` | `+3.5` st | Sassy rhythmic K-pop diva |

#### Generation Commands:
```bash
# Generate a Leon line:
python3 brawl_stars/voices/generate_brawler.py \
  --brawler leon \
  --text "TRUST ME! I'M TELLING YOU IT'S FREE TROPHIES!" \
  --emotion sudden_shock \
  --output leon_shout.wav

# Generate an Edgar line:
python3 brawl_stars/voices/generate_brawler.py \
  --brawler edgar \
  --text "He died." \
  --emotion deadpan \
  --output edgar_deadpan.wav

# Generate Crow (Leon base with -2.0 semitones):
python3 brawl_stars/voices/generate_brawler.py \
  --brawler crow \
  --text "Don't mess with my crew." \
  --output crow_line.wav
```

---

## 5. Audio Mastering & Sound Design

Dialogue audio tracks are precision-mixed with sound effects using dedicated timeline mixers:

```bash
# Mix Episode 00 SFX (36 cues) against master voice:
python3 tools/mix_ep00_sfx.py

# Mix Episode 01 SFX:
python3 tools/mix_ep01_sfx.py

# Mix Episode 03 SFX:
python3 tools/mix_ep03_sfx.py
```
* **Master Outputs**: `res://nemi/episodes/epXX_name/audio/EPXX_audio_sfx_master.wav` (48 kHz 24-bit stereo).
* **Sound Effects Library**: 400+ CC0 / Public Domain sound effects categorized under `common/audio/sfx/` (cartoon, phone, food, gym, transitions, UI, comedic).

---

## 6. Video Rendering Pipelines (Godot MovieWriter)

To produce broadcast-ready MP4s at deterministic frame rates without dropped frames:

```bash
# 1. Render Nemi Episode 00 in Native 4K @ 60 FPS:
python3 tools/render_ep00_v3_3.py

# 2. Render Nemi Episode 01 (1080p @ 60 FPS):
python3 tools/render_ep01.py

# 3. Render Nemi Episode 03 (1080p @ 60 FPS):
python3 tools/render_ep03.py

# 4. Render Brawl Stars Short ("Ruffs' Revenge", 1080p @ 30 FPS):
python3 tools/render_episode_ruffs_revenge.py

# 5. Render Pokémon Character Showcase (1080p @ 30 FPS):
python3 tools/render_pokemon_showcase.py
```

Outputs are saved directly into `renders/`.

---

## 7. Master Documentation Directory

| Subject | Document | Path |
|---|---|---|
| **Nemi Animation** | Master Production Bible | [`nemi/docs/NEMI_ANIMATION_PRODUCTION_BIBLE.md`](nemi/docs/NEMI_ANIMATION_PRODUCTION_BIBLE.md) |
| **Nemi Character** | Character Bible & Lore | [`nemi/docs/Nemi_Character_Bible.md`](nemi/docs/Nemi_Character_Bible.md) |
| **Nemi Voice** | Canonical Sohee Voice Profile | [`nemi/docs/Nemi_Voice_Profile.md`](nemi/docs/Nemi_Voice_Profile.md) |
| **Nemi Voice Setup** | Local Offline MLX TTS Guide | [`nemi/docs/Nemi_TTS_Setup.md`](nemi/docs/Nemi_TTS_Setup.md) |
| **Brawl Stars Voices** | Voice System & Derivation Guide | [`brawl_stars/voices/VOICE_SYSTEM.md`](brawl_stars/voices/VOICE_SYSTEM.md) |
| **Brawl Stars Comedy** | Comedy Scriptwriting Guide | [`brawl_stars/voices/COMEDY_SCRIPTWRITING_GUIDE.md`](brawl_stars/voices/COMEDY_SCRIPTWRITING_GUIDE.md) |
| **Pokémon System** | Character System Guide | [`pokemon/docs/POKEMON_CHARACTER_SYSTEM_GUIDE.md`](pokemon/docs/POKEMON_CHARACTER_SYSTEM_GUIDE.md) |
| **Sound Effects** | CC0 License Provenance Registry | [`common/audio/sfx/SFX_License_Registry.md`](docs/audio/SFX_License_Registry.md) |

---

## 8. License & IP Provenance

* **Source Code & Pipelines**: MIT License.
* **Character Designs & Universes**: Copyright © 2026 NemiStory. All rights reserved.
* **Voice Model**: Qwen3-TTS CustomVoice (Apache 2.0 / Open Weights).
* **Audio Assets & SFX**: Verified CC0 1.0 Universal / Public Domain.
