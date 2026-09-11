# NemiStory — 2D Animated Storytelling Production Engine

[![Engine: Godot 4.x](https://img.shields.io/badge/Engine-Godot%204.x-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Python: 3.10+](https://img.shields.io/badge/Python-3.10%2B-blue?logo=python&logoColor=white)](https://python.org)
[![Audio: Kokoro / MLX Qwen3--TTS](https://img.shields.io/badge/Voice-Offline%20TTS%20(Sohee)-green)](docs/nemi/Nemi_TTS_Setup.md)
[![Aesthetic: Hand--Drawn 2D](https://img.shields.io/badge/Style-Pen%20%26%20Ink%20Illustration-orange)](docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md)

**NemiStory** is an end-to-end 2D animated storytime production engine built on **Godot 4.x**, **Python**, and **local offline TTS**. It powers the illustrated YouTube storytelling channel starring **Nemi**—a 24-year-old creative, observant, and subtly chaotic storyteller learning 2D animation and sharing personal life experiences.

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
│   └── nemi/                       # Character Bible & TTS audition guides
│
├── tools/                          # CLI automation scripts
│   ├── render_ep00_v3_3.py         # 4K 60FPS MovieWriter rendering pipeline
│   ├── generate_nemi_voice.py      # Offline TTS voiceover generation
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

### C. Voiceover Synthesis (Offline Local TTS)
Generates voiceover segments using Apple Silicon MLX with the canonical Sohee voice actor:
```bash
python3 tools/generate_nemi_voice.py
```
* **Outputs**:
  - `audio/nemi/intro/segments/*.wav` (individual spoken lines)
  - `audio/nemi/intro/master/nemi_intro_voice_master.wav` (master audio track)
  - `audio/nemi/intro/timing/nemi_intro_timing.json` (authoritative word alignment data)

### D. Mixing SFX Audio
Mixes the 43-cue SFX timeline against the voiceover track with calibrated headroom:
```bash
python3 tools/mix_ep00_sfx.py
```
* **Output**: `episodes/ep00_introduction/audio/EP00_audio_sfx_master.wav`

---

## 5. Core Production Principles (The Non-Negotiables)

Before animating or modifying any episode, review the **[Nemi Animation Production Bible](docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md)**. The key immutable laws are:

1. **Nemi is a Storyteller, Not an Avatar**: Visuals exist to support the narration, not for meaningless decorative motion.
2. **Live Rig Only (No AI Images)**: Nemi is animated strictly via her live Godot bone rig (`Skeleton2D`). **Never** generate Nemi poses, sprites, or expressions using image diffusion models.
3. **Voice is the Master Clock**: All timing (lip-sync, subtitles, acting poses, camera snaps, and SFX) derives directly from the aligned audio waveform. Never guess timing from character counts.
4. **Subtitles $\le 5$ Words**: Every subtitle card is strictly restricted to **maximum 5 words** (ideal: 2–4 words). Zero paragraph walls; no word-by-word karaoke bouncing.
5. **Event SFX Restraint**: Sound effects are audio punctuation ($0.1\text{s}\text{--}2.0\text{s}$). Never run a continuous 30-second typing audio bed underneath dialogue.
6. **BGM OFF by Default**: The canonical sound design is **Voice + Selective SFX + Intentional Silence**. Silence ($0.8\text{s}\text{--}1.8\text{s}$) is an active comedic punchline.
7. **Progressive Inking for Doodles**: Doodles reveal along organic ink paths ($0\% \rightarrow \text{partial} \rightarrow 100\%$) with authored curves and zero per-frame random jitter.

---

## 6. Master Documentation Index

| Document | Path | Description |
|---|---|---|
| **Animation Production Bible** | [`docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md`](docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md) | Universal master standard for directing, acting, timing, subtitles, SFX, and QA. |
| **Character Bible** | [`docs/Nemi_Character_Bible.md`](docs/Nemi_Character_Bible.md) | Canonical character design, psychology, voice, comedic dynamics, and boundaries. |
| **Acting System Guide** | [`characters/nemi/documentation/NEMI_ACTING_SYSTEM_GUIDE.md`](characters/nemi/documentation/NEMI_ACTING_SYSTEM_GUIDE.md) | Procedural bone micro-acting, posture shifts, head tilts, and eye darts. |
| **Expression FX Guide** | [`characters/nemi/documentation/NEMI_EXPRESSION_FX_GUIDE.md`](characters/nemi/documentation/NEMI_EXPRESSION_FX_GUIDE.md) | Reaction Toolkit, intensity scaling ($1\text{--}5$), and skeleton socket anchors. |
| **Subtitle Visual Guide** | [`docs/Nemi_Subtitle_Visual_Guide.md`](docs/Nemi_Subtitle_Visual_Guide.md) | Typographic formatting and the $\le 5$-word card chunking standard. |
| **SFX System Guide** | [`docs/audio/SFX_System_Guide.md`](docs/audio/SFX_System_Guide.md) | Event sound principles, mixing standards, and category registry. |
| **SFX License Registry** | [`docs/audio/SFX_License_Registry.md`](docs/audio/SFX_License_Registry.md) | Complete CC0 / Public Domain provenance catalog for every audio asset. |
| **Local TTS Setup Guide** | [`docs/nemi/Nemi_TTS_Setup.md`](docs/nemi/Nemi_TTS_Setup.md) | Apple Silicon MLX voice generation pipeline with Sohee configuration. |

---

## 7. License & Asset Provenance

* **Code & Architecture**: MIT License.
* **Character Design & World IP**: Copyright © 2026 NemiStory. All rights reserved.
* **Audio & Sound Effects**: Verified CC0 1.0 Universal / Public Domain (see [`docs/audio/SFX_License_Registry.md`](docs/audio/SFX_License_Registry.md)).
