# NEMI TTS PROVENANCE & LICENSING RECORD (V1)
## Verification of Model Heritage, Licensing, and Local Offline Architecture

---

## 1. Engine & Model Provenance

* **Model Name**: **Kokoro-82M**
* **Model Version**: `v1.0` (`kokoro-v1_0.pth`, 82 Million Parameters)
* **Architecture**: StyleTTS 2 + ISTFTNet architecture with phonemizer front-end (`misaki`)
* **Primary Repository**: [`hexgrad/Kokoro-82M`](https://huggingface.co/hexgrad/Kokoro-82M)
* **Model Author / Creator**: Hexgrad
* **License**: **Apache License 2.0** (Permissive commercial and non-commercial use)
* **Installation Date**: September 10, 2026

---

## 2. Voice Provenance & Heritage

* **Primary Voice Asset**: `af_heart.pt`
* **Voice Category**: American Female (`af_*`)
* **Source Repository**: `hexgrad/Kokoro-82M/voices/af_heart.pt`
* **License**: Apache 2.0 (bundled directly with official Kokoro model distribution)
* **Alternate Official Voices Auditioned**:
  * `af_bella.pt` (Apache 2.0, official distribution)
  * `af_sky.pt` (Apache 2.0, official distribution)
  * `af_sarah.pt` (Apache 2.0, official distribution)

---

## 3. Local Runtime & Infrastructure Environment

* **Inference Pipeline**: `kokoro` (v0.9.4 official PyTorch package)
* **Python Runtime**: Python 3.11.15 (`/opt/homebrew/bin/python3.11`)
* **Core Dependencies**:
  * `torch` 2.6.0
  * `torchaudio` 2.6.0
  * `soundfile` 0.14.0
  * `misaki` 0.9.4 (phonemizer)
  * `spacy` 3.8.16 / `en_core_web_sm` 3.8.0
* **Execution Target**: Local CPU (Apple Silicon ARM64)
* **Audio Output Format**: 24,000 Hz, 16-bit PCM Linear WAV, Mono

---

## 4. Privacy & Offline Compliance

* **Cloud API Usage**: **NONE (0%)**.
* **Third-Party Telemetry**: **NONE**.
* **Data Transmission**: All phonemization, model weight evaluation, waveform synthesis, and segment concatenation execute 100% locally and offline on the user's host machine.
* **Reproducibility**: Identical text strings paired with consistent voice configurations yield bit-reproducible waveforms with zero stochastic drifting.
