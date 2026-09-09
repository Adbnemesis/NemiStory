#!/usr/bin/env python3
"""
Nemi Voice Audition Utility
Renders a personality-aligned test script across multiple official Kokoro voices
to evaluate and compare candidates for Nemi's permanent voice.
"""

import os
import sys
import argparse
import soundfile as sf
import numpy as np

# Ensure workspace root is on sys.path
WORKSPACE_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, WORKSPACE_ROOT)

from tools.tts.config import NemiTTSConfig
from tools.tts.engine import KokoroTTSEngine

AUDITION_SCRIPT_SENTENCES = [
    # 1. Curious sentence
    "Wait, look at this.",
    # 2. Casual sentence
    "I found this sketchbook from three years ago, and honestly, it is pure domestic chaos.",
    # 3. Excited sentence
    "Like, on page seven I literally spent four hours designing an entire fantasy tournament arc!",
    # 4. Awkward sentence
    "...And then on page eight I tried to draw a horse and it looks like a deflated accordion.",
    # 5. Deadpan sentence
    "I was very proud of that horse. It was terrible.",
    # 6. Slightly emotional / sincere sentence
    "Still, looking at all those messy sketches... it makes me really glad I didn't stop drawing."
]

def run_audition(voices=None, output_dir=None):
    config = NemiTTSConfig()
    engine = KokoroTTSEngine(config)
    
    selected_voices = voices or ["af_heart", "af_bella", "af_sky", "af_sarah"]
    target_dir = output_dir or os.path.join(WORKSPACE_ROOT, "audio", "nemi", "auditions")
    os.makedirs(target_dir, exist_ok=True)
    
    print("============================================================")
    print("NEMI VOICE AUDITION SESSION")
    print(f"Candidate voices: {', '.join(selected_voices)}")
    print(f"Output directory: {target_dir}")
    print("============================================================")
    
    audition_report = []
    
    for voice_name in selected_voices:
        print(f"\nRendering audition for voice: [{voice_name}]...")
        voice_chunks = []
        
        for idx, sentence in enumerate(AUDITION_SCRIPT_SENTENCES, 1):
            audio = engine.synthesize(sentence, voice=voice_name, speed=1.0)
            voice_chunks.append(audio)
            
            # Sentence pauses
            pause_sec = 0.45 if idx != 5 else 1.2  # Deadpan pause after horse joke
            silence = np.zeros(int(config.sample_rate * pause_sec), dtype=np.float32)
            voice_chunks.append(silence)
            
        full_audio = np.concatenate(voice_chunks)
        duration = len(full_audio) / float(config.sample_rate)
        
        out_filename = f"audition_{voice_name}.wav"
        out_path = os.path.join(target_dir, out_filename)
        sf.write(out_path, full_audio, config.sample_rate, subtype="PCM_16")
        
        print(f"  ✓ Saved: {out_filename} ({duration:.2f}s)")
        audition_report.append((voice_name, out_filename, duration))
        
    print("\nAuditions complete! Summary:")
    for v_name, fn, dur in audition_report:
        print(f"  - {v_name}: {dur:.2f}s -> {os.path.join(target_dir, fn)}")

def main():
    parser = argparse.ArgumentParser(description="Audition Kokoro voices for Nemi")
    parser.add_argument("--voices", nargs="+", default=["af_heart", "af_bella", "af_sky", "af_sarah"], help="Voice names to audition")
    parser.add_argument("--output", default=None, help="Output directory for audition WAVs")
    args = parser.parse_args()
    
    run_audition(voices=args.voices, output_dir=args.output)

if __name__ == "__main__":
    main()
