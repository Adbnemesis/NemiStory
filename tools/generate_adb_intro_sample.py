#!/usr/bin/env python3
"""
Generate ADB Intro Sample using Qwen3-TTS CustomVoice (Actor: Aiden)
Synthesizes polished variations of ADB's introduction line.
"""

import os
import sys
import numpy as np
import soundfile as sf

WORKSPACE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if WORKSPACE not in sys.path:
    sys.path.insert(0, WORKSPACE)

MODEL_ID = "mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16"
OUTPUT_DIR = os.path.join(WORKSPACE, "audio", "adb", "samples")

TAKES = [
    {
        "id": "adb_intro_take1_casual",
        "title": "Take 1: Casual & Relatable",
        "text": "Hey. I'm ADB. I love playing games—probably way more than I should—and telling ridiculous stories about it. Welcome.",
        "instruct": "Cool, relaxed young adult male around 24, calm conversational speech, subtle dry wit, natural and friendly."
    },
    {
        "id": "adb_intro_take2_deadpan_smug",
        "title": "Take 2: Cool & Dry Wit",
        "text": "Hey, I'm ADB. I play video games, I overthink game lore, and occasionally... I remember to go outside. Welcome to my channel.",
        "instruct": "Calm, confident young adult male, relaxed delivery with subtle deadpan comedic timing and a faint smirk."
    },
    {
        "id": "adb_intro_take3_direct_charming",
        "title": "Take 3: Direct & Charming",
        "text": "Hey everyone, I'm ADB. I love playing games, staying up way too late analyzing mechanics, and having fun with you guys. Welcome.",
        "instruct": "Warm, natural young adult male, friendly, engaging, relaxed conversational pacing."
    }
]

def main():
    print("=" * 60)
    print("GENERATING ADB INTRO SAMPLES (VOICE: AIDEN)")
    print(f"Model: {MODEL_ID}")
    print(f"Output: {OUTPUT_DIR}")
    print("=" * 60)
    
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    from mlx_audio.tts.utils import load_model
    print(f"\n[Loading model {MODEL_ID}...]")
    model = load_model(MODEL_ID)
    print("✓ Model loaded.")
    
    sample_rate = 24000
    
    for item in TAKES:
        take_id = item["id"]
        title = item["title"]
        text = item["text"]
        instruct = item["instruct"]
        out_file = os.path.join(OUTPUT_DIR, f"{take_id}.wav")
        
        print(f"\nSynthesizing [{title}]...")
        print(f"  Text: \"{text}\"")
        results = list(model.generate_custom_voice(
            text=text,
            speaker="aiden",
            language="English",
            instruct=instruct,
            temperature=0.7,
            top_k=50,
            top_p=0.95,
            repetition_penalty=1.05
        ))
        
        if not results or not hasattr(results[0], 'audio'):
            print(f"  ✗ Failed to synthesize {take_id}")
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
        print(f"  ✓ Saved ({dur:.2f}s) -> {out_file}")

if __name__ == "__main__":
    main()
