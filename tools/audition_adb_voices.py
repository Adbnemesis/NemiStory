#!/usr/bin/env python3
"""
Audition Qwen3-TTS CustomVoice Predefined Voice Actors for ADB
Generates multi-segment samples for each official Qwen male voice actor to evaluate:
- Vocal consistency
- Calm, cool, dry wit delivery
- Natural young-adult conversational tone matching ADB's visual identity
"""

import os
import sys
import numpy as np
import soundfile as sf

WORKSPACE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if WORKSPACE not in sys.path:
    sys.path.insert(0, WORKSPACE)

MODEL_ID = "mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16"
OUTPUT_DIR = os.path.join(WORKSPACE, "audio", "adb", "auditions", "custom_actors")

TEST_LINES = [
    {
        "id": "line1_intro",
        "text": "Look, I wasn't gonna say anything. But if you think drawing a 2D shirt collar takes ten minutes... sit down, because we need to talk.",
        "instruct": "Calm, confident young adult male around 24, cool, relaxed conversational delivery, subtle smirk."
    },
    {
        "id": "line2_story",
        "text": "I spent three whole days fixing the physics on a virtual sleeve. It was supposed to look relaxed and oversized. Instead, I looked like an origami kite.",
        "instruct": "Casually telling a funny story, deadpan comedic timing, dry amusement, relaxed."
    },
    {
        "id": "line3_outro",
        "text": "Okay, but listen—the animation in episode four was actually insane! The sakuga, the hair physics... wait, why are you smiling like that?",
        "instruct": "Genuinely excited and passionate about anime, transitioning suddenly to slightly flustered embarrassment."
    }
]

# Candidate male actors in Qwen3-TTS CustomVoice
ACTORS = ["aiden", "ryan", "dylan", "eric"]

def main():
    print("=" * 60)
    print("AUDITIONING QWEN3-TTS PREDEFINED VOICE ACTORS FOR ADB")
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
            # Add 0.4s pause between lines
            combined_audio.append(np.zeros(int(0.40 * sample_rate), dtype=np.float32))
            
        if combined_audio:
            showcase_path = os.path.join(OUTPUT_DIR, f"{actor}_full_showcase.wav")
            full_track = np.concatenate(combined_audio)
            sf.write(showcase_path, full_track, sample_rate, subtype="PCM_16")
            tot_dur = len(full_track) / sample_rate
            print(f"  ★ Full Showcase: {showcase_path} ({tot_dur:.2f}s)")

if __name__ == "__main__":
    main()
