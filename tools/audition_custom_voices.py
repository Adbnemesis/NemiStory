#!/usr/bin/env python3
"""
Audition Qwen3-TTS CustomVoice Predefined Voice Actors for Nemi
Generates multi-segment samples for each official Qwen voice actor to evaluate
naturalness, conversational warmth, and 100% vocal consistency across lines.
"""

import os
import sys
import numpy as np
import soundfile as sf

WORKSPACE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if WORKSPACE not in sys.path:
    sys.path.insert(0, WORKSPACE)

MODEL_ID = "mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16"
OUTPUT_DIR = os.path.join(WORKSPACE, "audio", "nemi", "auditions", "custom_actors")

TEST_LINES = [
    {
        "id": "line1_intro",
        "text": "Wait, wait, wait—listen to me. Please stop scrolling for literally two seconds. Hi, I'm Nemi. I'm 24.",
        "instruct": "Warm, natural young adult woman, relaxed conversational speech, casual, friendly."
    },
    {
        "id": "line2_story",
        "text": "I spent four hours yesterday inbetweening an arm movement. It looked like they were slipping on three invisible banana peels... in slow motion.",
        "instruct": "Casually telling a story to a friend, comedic timing, slightly amused."
    },
    {
        "id": "line3_outro",
        "text": "Thank you for watching my very first video. See you in the next one! Wait—did I leave the microphone gain at two hundred percent?!",
        "instruct": "Warm and sincere goodbye, followed by sudden panic and realization."
    }
]

# Female speakers in Qwen3-TTS CustomVoice
ACTORS = ["serena", "vivian", "sohee", "ono_anna"]

def main():
    print("=" * 60)
    print(f"AUDITIONING QWEN3-TTS PREDEFINED VOICE ACTORS")
    print(f"Model: {MODEL_ID}")
    print(f"Output: {OUTPUT_DIR}")
    print("=" * 60)
    
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    from mlx_audio.tts.utils import load_model
    print(f"\n[Loading model {MODEL_ID}...]")
    model = load_model(MODEL_ID)
    supported = model.get_supported_speakers()
    print(f"✓ Model loaded. Supported speakers: {supported}")
    
    for actor in ACTORS:
        if actor not in [s.lower() for s in supported]:
            print(f"⚠ Speaker {actor} not found in model supported speakers: {supported}")
            continue
            
        print(f"\n--- Auditioning Voice Actor: {actor.upper()} ---")
        actor_dir = os.path.join(OUTPUT_DIR, actor)
        os.makedirs(actor_dir, exist_ok=True)
        
        combined_audio = []
        sample_rate = 24000
        
        for item in TEST_LINES:
            line_id = item["id"]
            text = item["text"]
            instruct = item["instruct"]
            out_file = os.path.join(actor_dir, f"{actor}_{line_id}.wav")
            
            print(f"  Synthesizing [{line_id}]...")
            results = list(model.generate_custom_voice(
                text=text,
                speaker=actor,
                language="English",
                instruct=instruct,
                temperature=0.7,
                top_k=50,
                top_p=0.95,
                repetition_penalty=1.05
            ))
            
            if not results or not hasattr(results[0], 'audio'):
                print(f"  ✗ Failed on {line_id}")
                continue
                
            raw = results[0].audio
            if hasattr(raw, "as_numpy"):
                audio_np = raw.as_numpy()
            elif hasattr(raw, "numpy"):
                audio_np = raw.numpy()
            else:
                audio_np = np.array(raw, dtype=np.float32)
                
            if audio_np.ndim > 1:
                audio_np = audio_np.mean(axis=-1)
            audio_np = audio_np.astype(np.float32)
            
            peak = np.max(np.abs(audio_np))
            if peak > 0.98:
                audio_np = audio_np * (0.95 / peak)
                
            sf.write(out_file, audio_np, sample_rate, subtype="PCM_16")
            dur = len(audio_np) / sample_rate
            print(f"  ✓ {line_id} ({dur:.2f}s) -> {out_file}")
            
            combined_audio.append(audio_np)
            # Add 0.35s pause between lines
            combined_audio.append(np.zeros(int(0.35 * sample_rate), dtype=np.float32))
            
        if combined_audio:
            showcase_path = os.path.join(OUTPUT_DIR, f"{actor}_full_showcase.wav")
            full_track = np.concatenate(combined_audio)
            sf.write(showcase_path, full_track, sample_rate, subtype="PCM_16")
            tot_dur = len(full_track) / sample_rate
            print(f"  ★ Full Showcase: {showcase_path} ({tot_dur:.2f}s)")
            
    print("\n" + "=" * 60)
    print("AUDITIONS COMPLETE")
    print(f"Listen to files in: {OUTPUT_DIR}")
    print("=" * 60)

if __name__ == "__main__":
    main()
