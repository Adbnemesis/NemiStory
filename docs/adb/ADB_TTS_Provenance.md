# ADB TTS PROVENANCE & TECHNICAL SPECIFICATION
## Authoritative Architecture, Hardware Stack, and Vocal Embedding Specification

**Document Status**: LOCKED & AUTHORITATIVE MASTER SPECIFICATION  
**Character**: ADB (Independent Storyteller & Creator)  
**Channel**: Independent ADB YouTube Storytime Channel  
**Voice Actor**: **Aiden** (Official Predefined Speaker Embedding)  
**Engine**: Qwen3-TTS 1.7B CustomVoice (`mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`)  
**Location**: [`adb/docs/ADB_TTS_PROVENANCE.md`](file:///Users/talus/Documents/adb/adb/docs/ADB_TTS_PROVENANCE.md)  

---

## 1. Model Identification & Origin

* **Model Name**: **Qwen3-TTS 1.7B CustomVoice**
* **Model Checkpoint**: `mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`
* **Base Architecture**: Alibaba Qwen3-TTS (1.7 Billion Parameters, 12 Hz Tokenizer)
* **Precision**: bfloat16 (`bf16`)
* **Hugging Face Repository**: [`mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`](https://huggingface.co/mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16)
* **Upstream Official Repository**: [`Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice`](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice)
* **License**: Qwen Community License / Apache 2.0 (Permits commercial and creator usage with standard attribution)

---

## 2. Hardware & Runtime Environment

* **Target Hardware**: Apple Silicon Mac (Apple M4 Pro)
* **Architecture**: `arm64`
* **Unified Memory**: 48 GB Unified RAM
* **Operating System**: macOS (Darwin)
* **Acceleration Backend**: Apple Metal Performance Shaders (MPS) / Apple Neural Engine via MLX
* **Python Runtime**: Python 3.11 (`/opt/homebrew/bin/python3.11`)
* **Isolated Environment**: `/Users/talus/Documents/adb/.venv`

### Package Manifest
* `mlx`: `0.32.2`
* `mlx-metal`: `0.32.2`
* `mlx-audio`: `0.5.3`
* `transformers`: `5.17.0`
* `soundfile`: `0.14.0`
* `scipy`: `1.17.1`
* `numpy`: `2.4.6`

---

## 3. Approved Official Voice Actor & Configuration

* **Voice Actor**: **Aiden** (Official Qwen Pretrained Speaker Embedding)
* **Model Type**: Pretrained CustomVoice (Fixed neural codebook weights — zero identity drift)
* **Voice Directive Prompt**:
  > *"Cool, relaxed young adult male around 24, calm conversational speech, confident, subtle dry wit, understated and natural."*
* **Target Audio Format**: Uncompressed 16-bit PCM WAV
* **Native Sampling Rate**: 24,000 Hz
* **Channels**: Mono (1 channel)
* **Median Pitch (F0)**: **147.7 Hz** (Natural, resonant young adult male chest voice)
* **Target RMS Level**: `0.08 – 0.12` (Normalized to `-1.5 dBFS` peak)
* **Pacing Policy**:
  - `short_pause`: `0.20s` (Natural commas and breath)
  - `medium_pause`: `0.35s` (Sentence completion)
  - `smug_pause`: `0.60s` (Ironic beat hold)
  - `deadpan_pause`: `1.40s` (0-velocity comedic freeze)
* **Generation Method**: Local offline inference via `model.generate_custom_voice(speaker='aiden', instruct=...)`
* **Golden Audio Reference Anchor**: [`audio/adb/reference/adb_golden_reference.wav`](file:///Users/talus/Documents/adb/audio/adb/reference/adb_golden_reference.wav)
* **Golden Reference Transcript**: [`audio/adb/reference/adb_golden_reference.txt`](file:///Users/talus/Documents/adb/audio/adb/reference/adb_golden_reference.txt)

---

## 4. Architectural Separation from Nemi

| Character | Universe / Channel | Voice Actor | Pitch (F0) | Cadence / Energy | CLI Tool |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **Nemi** | `nemi/` | **Sohee** | `~210 Hz` | Energetic, rapid-fire, bright | [`tools/generate_nemi_voice.py`](file:///Users/talus/Documents/adb/tools/generate_nemi_voice.py) |
| **ADB** | `adb/` | **Aiden** | `~148 Hz` | Cool, relaxed, dry deadpan | [`tools/generate_adb_voice.py`](file:///Users/talus/Documents/adb/tools/generate_adb_voice.py) |

Both characters run on the identical local Qwen3-TTS 1.7B engine while remaining **100% decoupled** in script parsing, directory hierarchy, pause policies, and vocal identities.
