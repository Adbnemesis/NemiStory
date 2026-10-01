# ADB Qwen3-TTS CustomVoice Pipeline — Local Setup & Operations Guide

## 1. System Overview
ADB's voice pipeline runs 100% locally and offline on Apple Silicon (M4 Mac) using **Qwen3-TTS 1.7B CustomVoice** powered by the **MLX** framework (`mlx-audio`) with official voice actor **Aiden**.

```
ADB SCRIPT (script.md)
       │
       ▼
[ScriptSegmenter] (extracts spoken dialogue segments preserving original text)
       │
       ▼
[QwenVoiceEngine] (mlx-audio / Apple Silicon GPU & Neural Engine: AIDEN)
       │
       ▼
SEGMENTED WAVs (001.wav – 020.wav @ 24 kHz)
       │
       ▼
[AudioConcatenator] (ADB Contextual Pause Engine: Smug & Deadpan Holds)
       ├── Master Audio: adb_ep00_intro_voice_master.wav
       ├── Timing JSON: adb_ep00_intro_timing.json
       ├── Timing Markdown: adb_ep00_intro_voice_timing.md
       └── Metadata JSON: voice_metadata.json
       │
       ▼
ANIMATION ASSET SYNC (adb/episodes/ep00_intro/voiceover/)
```

---

## 2. Environment Architecture & Isolation

The ADB TTS pipeline shares the project-local virtual environment:

* **Location**: `/Users/talus/Documents/adb/.venv`
* **Python Runtime**: Python 3.11 (`/opt/homebrew/bin/python3.11`)
* **Framework**: Apple MLX (`mlx 0.32.2`, `mlx-metal 0.32.2`, `mlx-audio 0.5.3`)
* **Audio Processing**: `soundfile`, `scipy`, `numpy`
* **Model Checkpoint**: `mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16` (Voice Actor: **Aiden**)

---

## 3. Production Voiceover Generation Commands

### Standard Episode Voiceover Generation
```bash
./.venv/bin/python3 tools/generate_adb_voice.py \
  --script adb/episodes/ep00_intro/source/script.md \
  --output audio/adb/ep00_intro \
  --project-id adb_ep00_intro \
  --title "ADB Introduction"
```

### Auditioning Alternative Takes or Prompts
```bash
./.venv/bin/python3 tools/generate_adb_intro_sample.py
```

### Regenerating Full Voice Actor Audition Showcases
```bash
./.venv/bin/python3 tools/audition_adb_voices.py
```

---

## 4. Acoustic Calibration & Consistency Rules

To ensure permanent consistency across all future ADB YouTube videos:
1. **Never Change Speaker ID**: Always specify `--speaker aiden`. Never use random VoiceDesign seeds.
2. **Sampling Rate**: Always maintain `24,000 Hz` 16-bit PCM WAV.
3. **Normalization**: Audio segments are normalized to `-1.5 dBFS` peak to match Nemi's master broadcast loudness.
4. **Pause Engine**: Deadpan freezes default to `1.40s` silence holds; smug punchline pauses default to `0.60s`.
