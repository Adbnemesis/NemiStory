# Nemi Qwen3-TTS CustomVoice Pipeline — Local Setup & Operations Guide

## 1. System Overview
Nemi's voice pipeline runs 100% locally and offline on Apple Silicon (M4 Mac) using **Qwen3-TTS 1.7B CustomVoice** powered by the **MLX** framework (`mlx-audio`) with official voice actor **Sohee** (`spk_id: 2864`).

Using official predefined voice actors locks the speaker's physical timbre and vocal tract across all segments, ensuring 100% identity consistency while supporting dynamic emotion and delivery directives.

```
NEMI SCRIPT (script.md)
       │
       ▼
[ScriptSegmenter] (extracts 26 spoken lines without modifying text)
       │
       ▼
[QwenVoiceEngine] (mlx-audio / Apple Silicon GPU & Neural Engine: SOHEE)
       │
       ▼
SEGMENTED WAVs (001.wav – 026.wav @ 24 kHz)
       │
       ▼
[AudioConcatenator] (Contextual Pause Engine)
       ├── Master Audio: nemi_intro_voice_master.wav
       ├── Timing JSON: nemi_intro_timing.json
       ├── Timing Markdown: Nemi_Intro_Voice_Timing.md
       └── Metadata JSON: voice_metadata.json
       │
       ▼
ANIMATION ASSET SYNC (animations/ep00_introduction/voiceover/)
```

---

## 2. Environment Architecture & Isolation

To prevent dependency collisions and ensure zero impact on global packages or other projects on this Mac, the Nemi TTS pipeline is isolated inside a project-local virtual environment:

* **Location**: `/Users/talus/Documents/adb/.venv`
* **Python Runtime**: Python 3.11 (`/opt/homebrew/bin/python3.11`)
* **Framework**: Apple MLX (`mlx 0.32.2`, `mlx-metal 0.32.2`, `mlx-audio 0.5.3`)
* **Audio Processing**: `soundfile`, `scipy`, `numpy`
* **Model Checkpoint**: `mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16` (Voice Actor: Sohee)

### Setup Commands
To recreate or verify this environment from scratch:

```bash
# 1. Create project-local virtual environment
/opt/homebrew/bin/python3.11 -m venv .venv

# 2. Upgrade pip
.venv/bin/pip install --upgrade pip

# 3. Install Apple Silicon MLX TTS dependencies
.venv/bin/pip install mlx-audio transformers soundfile scipy numpy
```

---

## 3. Running Candidate Auditions

To generate comparative audition samples across all 8 predefined VoiceDesign candidates:

```bash
# Run all 8 candidate auditions + emotion tests
.venv/bin/python tools/audition_voices.py

# Run a specific candidate (e.g. candidate 1)
.venv/bin/python tools/audition_voices.py --candidates candidate_01_warm_conversational
```

Outputs are placed in `audio/nemi/auditions/`:
* `audition_<candidate_id>.wav`: Full Section 27 audition script.
* `emotions_<candidate_id>.wav`: Emotion stress tests (Deadpan, Excitement, Awkwardness, Shock).

---

## 4. Generating the Official Voiceover

To synthesize the complete introduction script (`ep00_introduction`) into individual segments and assemble the master audio using official voice actor **Sohee**:

```bash
# Generate using the official voice actor Sohee
.venv/bin/python tools/generate_nemi_voice.py \
  --script animations/ep00_introduction/script/script.md \
  --output audio/nemi/intro \
  --anim-voiceover-dir animations/ep00_introduction/voiceover \
  --speaker sohee
```

### Generated Files
1. **Dialogue Segments**: `audio/nemi/intro/segments/001.wav` through `026.wav` (and synced to `animations/ep00_introduction/voiceover/segments/`).
2. **Master Voice Track**: `audio/nemi/intro/master/nemi_intro_voice_master.wav` (and synced to `animations/ep00_introduction/voiceover/voiceover.wav`). Duration: 2:28 (148.08s).
3. **Machine-Readable Timing**: `audio/nemi/intro/timing/nemi_intro_timing.json` (used by future Godot subtitle and lipsync systems).
4. **Human-Readable Timing**: `audio/nemi/intro/timing/Nemi_Intro_Voice_Timing.md`.
5. **Provenance Metadata**: `audio/nemi/intro/metadata/voice_metadata.json`.

---

## 5. Customizing or Changing Voice Design

To experiment with custom VoiceDesign prompts without modifying code:

```bash
.venv/bin/python tools/generate_nemi_voice.py \
  --prompt "A natural-sounding young adult woman around 24, warm feminine voice, medium pitch, relaxed conversational speech, intelligent and approachable, slightly playful, telling a story to a friend."
```

Or configure defaults permanently in [`tools/tts/config.py`](file:///Users/talus/Documents/adb/tools/tts/config.py).

---

## 6. Contextual Pause Engine

The pipeline implements an intelligent contextual pause policy to eliminate robotic silences while supporting comedic deadpan beats:

| Pause Type | Duration | Context |
| :--- | :--- | :--- |
| `short_pause` | 0.20s | Rapid conversational transitions, thought flow, commas |
| `medium_pause` | 0.35s | Standard sentence completion |
| `thought_pause` | 0.45s | Reflective shift to a new thought |
| `dramatic_pause` | 0.80s | Comedic punchline anticipation (e.g., "...In slow motion.") |
| `deadpan_pause` | 1.50s–1.80s | Rigid statue freeze hold (e.g., "Half. A. Second.") |
| `stinger_pause` | 0.20s | Rapid panicked outro pacing |

---

## 7. Troubleshooting & Verification

* **Verify Clean Architecture (No Kokoro)**:
  ```bash
  grep -rnI -E "(kokoro|Kokoro-82M|af_heart|af_bella|af_sky|af_sarah)" tools/ docs/ audio/ animations/
  ```
  *(Expected: Zero active pipeline references)*

* **Verify Apple Silicon Metal / Neural Engine Acceleration**:
  ```bash
  .venv/bin/python -c "import mlx.core as mx; print('MLX Device:', mx.default_device())"
  ```
