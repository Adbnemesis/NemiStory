# NEMI TTS PROVENANCE & TECHNICAL SPECIFICATION

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
* **Architecture**: arm64
* **Unified Memory**: 48 GB Unified RAM
* **Operating System**: macOS 26.6.2 (Darwin 25.6.0)
* **Acceleration Backend**: Apple Metal Performance Shaders (MPS) / Apple Neural Engine via MLX
* **Python Runtime**: Python 3.11.15 (`/opt/homebrew/bin/python3.11`)
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
 
* **Voice Actor**: **Sohee** (Official Qwen Pretrained Speaker Embedding: `2864`)
* **Model Type**: Pretrained CustomVoice (Fixed neural weights — zero identity drift)
* **Voice Directive Prompt**:
  > *"Warm, natural young adult woman around 24, relaxed conversational speech, friendly, casual, intelligent, slightly playful."*
* **Target Audio Format**: Uncompressed 16-bit PCM WAV
* **Native Sampling Rate**: 24,000 Hz
* **Channels**: Mono (1 channel)
* **Pacing Policy**: Contextual Thought Segmentation (0.20s–0.45s conversational gaps, 1.50s–1.80s deadpan holds)
* **Generation Method**: Local offline inference via `model.generate_custom_voice(speaker='sohee', instruct=...)`

---

## 4. Architectural Separation (Kokoro Retirement)

* **Previous Architecture**: Kokoro-82M (`af_heart`).
* **Retirement Rationale**: Formally rejected due to perceived artificial cadence, synthetic robotic artifacts, and unnatural sentence silence gaps.
* **Current Status**: All Kokoro scripts, voice configurations, and audio files have been completely purged from the active Nemi pipeline. Legacy audio files are quarantined in `archive/rejected/kokoro/` and strictly ignored.
