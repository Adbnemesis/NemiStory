# Nemi Voice & Script Style Guide

## 1. Voice Identity & Audio Model Configuration
- **Model**: Qwen3-TTS CustomVoice (`1.7B`, `mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`).
- **Voice Actor**: **Sohee** (`spk_id: 2864`, official predefined speaker embedding, 100% identity consistency).
- **Sampling Rate**: 24kHz Mono 16-bit PCM WAV.
- **Inference Temperature**: `0.70`.

### Master Voice Design Prompt
```text
Warm, natural young adult woman around 24, relaxed conversational speech, friendly, casual, intelligent, slightly playful.
```

## 2. Scriptwriting & Dialogue Style Rules
1. **The "Voice Note" Rule**:
   Every sentence must sound like a real person sending an honest voice note to a close friend at 2:00 AM.
2. **Zero "AI Essay" Phrasing**:
   - ❌ Never use: "It is crucial to remember", "In the realm of animation", "Allow me to elaborate", "However, we must consider".
   - ✅ Always use: "Okay, so...", "Like, I actually care", "Just... what if?", "And my brain immediately goes...", "So yeah, wish me luck."
3. **Pacing and Hesitations**:
   - Use natural ellipses (`...`) and dashes (`—`) to create genuine conversational rhythm, micro-pauses, and vulnerability.
4. **On-Screen Subtitles Discontinued**:
   - On-screen subtitle labels are removed across storytime animation episodes to keep the visual focus entirely on the character acting and hand-drawn doodles.
   - Dialogue timing manifests are still generated internally for frame-accurate lip sync and beat orchestration.
5. **Zero Gendered Self-References**:
   - Strictly use `I`, `me`, `my`, `myself`. Never use `as a girl`, `as a guy`, `female animator`, etc.

