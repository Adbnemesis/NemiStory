# NemiStory — 2D Animated Storytelling Production Engine

[![Engine: Godot 4.x](https://img.shields.io/badge/Engine-Godot%204.x-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Python: 3.10+](https://img.shields.io/badge/Python-3.10%2B-blue?logo=python&logoColor=white)](https://python.org)
[![Voice: Qwen3--TTS (MLX)](https://img.shields.io/badge/Voice-Qwen3--TTS%20(Sohee)-green)](docs/nemi/Nemi_Voice_Profile.md)
[![Aesthetic: Hand--Drawn 2D](https://img.shields.io/badge/Style-Pen%20%26%20Ink%20Illustration-orange)](docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md)

**NemiStory** is an end-to-end 2D animated storytime production engine built on **Godot 4.x**, **Python**, and **local offline Qwen3-TTS**. It powers the illustrated YouTube storytelling channel starring **Nemi**—a 24-year-old creative, observant, and subtly chaotic storyteller learning 2D animation and sharing personal life experiences.

---

## 1. Prerequisites (New Device Setup)

To set up and run this project on a new computer, ensure the following software is installed:

### 1. Godot Engine 4.x
* **Recommended Version**: Godot 4.3 or 4.4 (Standard Edition, 64-bit).
* **Download**: [godotengine.org/download](https://godotengine.org/download)
* **macOS Installation**:
  - Download `Godot_v4.x-stable_macos.universal.zip`.
  - Move `Godot.app` to `/Applications/` (or `~/Applications/`).
  - Add to PATH or create an alias (optional but convenient):
    ```bash
    echo 'alias godot="/Applications/Godot.app/Contents/MacOS/Godot"' >> ~/.zshrc
    source ~/.zshrc
    ```

### 2. FFmpeg
Required for high-speed offline video transcoding, audio/video muxing, and 4K MovieWriter exports.
* **macOS (Homebrew)**:
  ```bash
  brew install ffmpeg
  ```
* **Ubuntu / Debian**:
  ```bash
  sudo apt update && sudo apt install -y ffmpeg
  ```
* **Windows (Chocolatey / Scoop)**:
  ```bash
  choco install ffmpeg
  ```

### 3. Python 3.10+ / 3.11+
Used for automated 4K rendering pipelines, local voice synthesis, and SFX mixing.
* **macOS (Homebrew)**:
  ```bash
  brew install python@3.11
  ```

---

## 2. Quick Start: Fresh Machine Setup

### Step 1: Clone Repository
```bash
git clone https://github.com/Adbnemesis/NemiStory.git
cd NemiStory
```

### Step 2: Set Up Python Virtual Environment
```bash
# Create local virtual environment
python3 -m venv .venv

# Activate environment
source .venv/bin/activate    # On Windows: .venv\Scripts\activate

# Upgrade pip & install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

> [!NOTE]
> On Apple Silicon Macs (M1/M2/M3/M4), `requirements.txt` installs `mlx-audio` for local offline voice synthesis using the official Sohee voice actor. On non-macOS systems, Godot rendering and SFX mixing function normally with standard dependencies.

### Step 3: Open in Godot Engine
1. Launch **Godot Engine**.
2. Click **Import** $\longrightarrow$ navigate to the cloned `NemiStory/` directory.
3. Select `project.godot` and click **Import & Edit**.
4. Godot will import and cache project resources into `.godot/` (this takes ~15–30 seconds on first launch).

---

## 3. Project Architecture

```
NemiStory/
├── characters/
│   └── nemi/                       # Canonical character rig & systems
│       ├── Nemi.tscn               # Root character scene & API
│       ├── Nemi.gd                 # Directorial interface
│       ├── actor/                  # Skeleton2D, bone solvers, eyes, brows, mouth
│       ├── documentation/          # Rig specifications & acting guides
│       └── fx/                     # Procedural vector reaction FX toolkit
│
├── world/                          # Illustrated storytelling environment
│   ├── doodles/                    # Real-time ink drawing & annotation system
│   ├── props/                      # Reusable props library (laptop, dumbbell, etc.)
│   ├── camera/                     # StoryCamera2D (snap-cuts & punch-zooms)
│   ├── composition/                # Rule-of-thirds staging & z-index layers
│   └── backgrounds/                # Canvas wash & room environments
│
├── episodes/                       # Production episodes
│   └── ep00_introduction/          # Episode 00: "Wait, Listen to Me"
│       ├── beats/                  # Beat01_Hook through Beat07_Outro
│       ├── cutaways/               # Flashcards & comic inset illustrations
│       ├── props/                  # Episode-specific illustrated props
│       ├── Episode00Subtitles.gd   # Subtitle engine (≤5 words per card)
│       └── manifests/              # SFX & visual event manifests
│
├── audio/                          # Audio repository
│   ├── nemi/intro/                 # Master voiceover WAV & aligned segment files
│   └── sfx/                        # Curated CC0 event sound effects library
│
├── docs/                           # Master Documentation Suite
│   ├── animation/                  # Master Production Bible & docs index
│   ├── audio/                      # SFX catalog, mix guides & license registry
│   └── nemi/                       # Character Bible, Voice Profile & TTS guides
│
├── tools/                          # CLI automation scripts
│   ├── render_ep00_v3_3.py         # 4K 60FPS MovieWriter rendering pipeline
│   ├── generate_nemi_voice.py      # Offline Qwen3-TTS voiceover generation
│   ├── mix_ep00_sfx.py             # Audio mastering & SFX timeline mixer
│   └── requirements.txt            # Python dependencies
│
└── project.godot                   # Godot 4.x project configuration (Canvas Items 4K)
```

---

## 4. Key Workflows & Commands

### A. Previewing Beats in Godot
To run and inspect any beat scene interactively:
1. Open the project in Godot.
2. In the FileSystem dock, open:
   `episodes/ep00_introduction/beats/`
3. Select any beat (e.g. `Beat01_Hook.tscn` or `Beat05_RabbitHole.tscn`).
4. Press **F6** (or click **Play Current Scene**) to run the scene with live character acting and real-time subtitles.

### B. Rendering an Episode in Native 4K (Offline MovieWriter)
The rendering script runs Godot in deterministic frame-capture mode (MovieWriter) at 60 FPS, transcodes raw frames to high-bitrate H.264 MP4, and multiplexes master audio with sample accuracy:

```bash
# Configure Godot binary path if not default
export GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
export FFMPEG_BIN="ffmpeg"

# Execute the 4K rendering pipeline
python3 tools/render_ep00_v3_3.py
```
* **Output**: `episodes/ep00_introduction/previews/EP00_Introduction_V3_3_preview.mp4`
* **Resolution**: 3840×2160 (Native 4K) @ 60 FPS.
* **Audit Frames**: Automatically extracts audit frames into `v3_3_audit/` for frame-by-frame visual QA.

### C. Voiceover Synthesis (Offline Local Qwen3-TTS)
Generates voiceover segments using Apple Silicon MLX with the canonical **Sohee** voice actor:
```bash
python3 tools/generate_nemi_voice.py
```
* **Outputs**:
  - `audio/nemi/intro/segments/*.wav` (individual spoken lines @ 24 kHz)
  - `audio/nemi/intro/master/nemi_intro_voice_master.wav` (master audio track)
  - `audio/nemi/intro/timing/nemi_intro_timing.json` (authoritative word alignment data)

### D. Mixing SFX Audio
Mixes the 43-cue SFX timeline against the voiceover track with calibrated headroom:
```bash
python3 tools/mix_ep00_sfx.py
```
* **Output**: `episodes/ep00_introduction/audio/EP00_audio_sfx_master.wav`

---

## 5. Official Nemi Voice Profile (Qwen3-TTS CustomVoice: Sohee)

> [!IMPORTANT]
> **Kokoro was auditioned and rejected** in early prototyping due to mechanical cadence, unnatural sentence body flattening, and speaker drift.  
> The **authoritative, permanent voice engine** for Nemi is **Qwen3-TTS 1.7B CustomVoice** running locally and offline via **Apple MLX** (`mlx-audio`), locked to the official predefined voice actor **Sohee** (`spk_id: 2864`).

### Character Voice Specifications
* **Engine**: Qwen3-TTS 1.7B CustomVoice (`mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`)
* **Voice Actor**: **Sohee** (Predefined Speaker Embedding: `2864`)
* **Perceived Age**: **Around 24 years old** (young adult woman in her mid-20s). Must never sound like an anime child, high-pitched mascot, or corporate audiobook narrator.
* **Pitch & Register**: **Natural medium chest-to-mid register**. Authentic feminine vocal range without artificial head-voice squeakiness.
* **Tone & Persona**: **Warm, intelligent, approachable, authentic**. Sounds like a real friend sitting across a table sharing an embarrassing anecdote.
* **Humor & Cadence**: **Deadpan honesty, conversational wit, and understatement**. Relies on natural pauses ($1.2\text{s}\text{--}1.8\text{s}$) rather than clownish pitch theatrics.
* **Zero Identity Drift**: The neural speaker embedding (`2864`) is hardcoded into the talker weights, guaranteeing that Segment 001, Segment 026, and all future episodes maintain identical vocal tract acoustics.

### Performance Directives & Emotional Modes
| Emotional Mode | Speed | Pause | Vocal Characteristic | Example Script Line |
|---|---|---|---|---|
| **Baseline Conversational** | `1.00x` | `0.30s–0.40s` | Calm, relaxed, warm, friendly. | *"Hi. I’m Nemi. I’m 24."* |
| **The Hook** | `1.05x` | `0.20s–0.25s` | Urgent, scroll-stopping, intimate. | *"Wait, wait, wait—listen to me."* |
| **Excited / Hyperfocus** | `1.10x` | `0.20s–0.30s` | Brisk, forward-leaning, bright. | *"'How hard could that possibly be?'"* |
| **Deadpan Realization** | `0.90x` | `1.20s–1.80s` | Flat, dry, restrained, lingering pause. | *"Half. A. Second."* / *"...In slow motion."* |
| **Embarrassed Confession** | `0.95x` | `0.40s–0.60s` | Soft, hesitant, sheepish half-laugh. | *"...Except last Tuesday when the window was open..."* |
| **Shock / Panic** | `1.15x` | `0.15s–0.25s` | Abrupt, sharp stop, rising tension. | *"Wait—did I leave the mic gain at 200%?!"* |
| **Sincere / Outro** | `0.98x` | `0.35s–0.45s` | Soft, measured, direct eye contact. | *"If that sounds like something you’d enjoy... I’d love it if you stayed."* |

For full acoustic benchmarks, scorecards, and setup commands, see:
* **[`docs/nemi/Nemi_Voice_Profile.md`](docs/nemi/Nemi_Voice_Profile.md)**: Canonical vocal profile specification.
* **[`docs/nemi/Nemi_TTS_Setup.md`](docs/nemi/Nemi_TTS_Setup.md)**: Local MLX setup and inference guide.
* **[`docs/nemi/Nemi_Voice_Audition_Scorecard.md`](docs/nemi/Nemi_Voice_Audition_Scorecard.md)**: Comparative evaluation leading to Sohee's selection.

---

## 6. Core Production Principles (The Non-Negotiables)

Before animating or modifying any episode, review the **[Nemi Animation Production Bible](docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md)**. The key immutable laws are:

1. **Nemi is a Storyteller, Not an Avatar**: Visuals exist to support the narration, not for meaningless decorative motion.
2. **Live Rig Only (No AI Images)**: Nemi is animated strictly via her live Godot bone rig (`Skeleton2D`). **Never** generate Nemi poses, sprites, or expressions using image diffusion models.
3. **Voice is the Master Clock**: All timing (lip-sync, subtitles, acting poses, camera snaps, and SFX) derives directly from the aligned audio waveform. Never guess timing from character counts.
4. **Subtitles $\le 5$ Words**: Every subtitle card is strictly restricted to **maximum 5 words** (ideal: 2–4 words). Zero paragraph walls; no word-by-word karaoke bouncing.
5. **Event SFX Restraint**: Sound effects are audio punctuation ($0.1\text{s}\text{--}2.0\text{s}$). Never run a continuous 30-second typing audio bed underneath dialogue.
6. **BGM OFF by Default**: The canonical sound design is **Voice + Selective SFX + Intentional Silence**. Silence ($0.8\text{s}\text{--}1.8\text{s}$) is an active comedic punchline.
7. **Progressive Inking for Doodles**: Doodles reveal along organic ink paths ($0\% \rightarrow \text{partial} \rightarrow 100\%$) with authored curves and zero per-frame random jitter.

---

## 7. Master Documentation Index

| Document | Path | Description |
|---|---|---|
| **Animation Production Bible** | [`docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md`](docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md) | Universal master standard for directing, acting, timing, subtitles, SFX, and QA. |
| **Character Bible** | [`docs/Nemi_Character_Bible.md`](docs/Nemi_Character_Bible.md) | Canonical character design, psychology, voice, comedic dynamics, and boundaries. |
| **Official Voice Profile** | [`docs/nemi/Nemi_Voice_Profile.md`](docs/nemi/Nemi_Voice_Profile.md) | Qwen3-TTS Sohee vocal parameters, register, pitch, and performance directives. |
| **Acting System Guide** | [`characters/nemi/documentation/NEMI_ACTING_SYSTEM_GUIDE.md`](characters/nemi/documentation/NEMI_ACTING_SYSTEM_GUIDE.md) | Procedural bone micro-acting, posture shifts, head tilts, and eye darts. |
| **Expression FX Guide** | [`characters/nemi/documentation/NEMI_EXPRESSION_FX_GUIDE.md`](characters/nemi/documentation/NEMI_EXPRESSION_FX_GUIDE.md) | Reaction Toolkit, intensity scaling ($1\text{--}5$), and skeleton socket anchors. |
| **Subtitle Visual Guide** | [`docs/Nemi_Subtitle_Visual_Guide.md`](docs/Nemi_Subtitle_Visual_Guide.md) | Typographic formatting and the $\le 5$-word card chunking standard. |
| **SFX System Guide** | [`docs/audio/SFX_System_Guide.md`](docs/audio/SFX_System_Guide.md) | Event sound principles, mixing standards, and category registry. |
| **SFX License Registry** | [`docs/audio/SFX_License_Registry.md`](docs/audio/SFX_License_Registry.md) | Complete CC0 / Public Domain provenance catalog for every audio asset. |
| **Local TTS Setup Guide** | [`docs/nemi/Nemi_TTS_Setup.md`](docs/nemi/Nemi_TTS_Setup.md) | Apple Silicon MLX voice generation pipeline with Sohee configuration. |

---

## 8. License & Asset Provenance

* **Code & Architecture**: MIT License.
* **Character Design & World IP**: Copyright © 2026 NemiStory. All rights reserved.
* **Voice Model**: Qwen3-TTS CustomVoice (Apache 2.0 / Open Weights).
* **Audio & Sound Effects**: Verified CC0 1.0 Universal / Public Domain (see [`docs/audio/SFX_License_Registry.md`](docs/audio/SFX_License_Registry.md)).
