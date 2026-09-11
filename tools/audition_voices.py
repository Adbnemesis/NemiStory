#!/usr/bin/env python3
"""
Nemi Voice Audition Utility — Qwen3-TTS VoiceDesign Edition
Synthesizes candidate voice designs based on natural-language descriptions (Sections 19–26)
using the exact same audition script (Section 27) and emotion tests (Sections 31–35).
Outputs are written to audio/nemi/auditions/ for comparative evaluation and scoring.
"""

import os
import sys
import argparse
import numpy as np
import soundfile as sf
from typing import Dict, List, Tuple

# Ensure workspace root is on sys.path
WORKSPACE_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, WORKSPACE_ROOT)

from tools.tts.config import NemiVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine

# The 8 Candidate Voice Designs from Prompt Sections 19–26
CANDIDATE_VOICE_DESIGNS: Dict[str, Dict[str, str]] = {
    "candidate_01_warm_conversational": {
        "title": "Candidate 1 — Warm Conversational",
        "prompt": (
            "A natural-sounding young adult woman around 24, warm feminine voice, medium pitch, "
            "relaxed conversational speech, clear but not overly polished, subtle friendliness, "
            "naturally expressive, intelligent and approachable, slightly playful, "
            "sounds like a real person casually telling a story to a friend rather than reading a script."
        )
    },
    "candidate_02_playful_charismatic": {
        "title": "Candidate 2 — Playful Charismatic",
        "prompt": (
            "Young adult woman around 24 with a naturally charismatic feminine voice, medium pitch, "
            "warm vocal tone, relaxed conversational speech, subtly playful and mischievous personality, "
            "confident but not overly polished, expressive enough for comedy, believable human storytelling, "
            "never sounding like a commercial narrator."
        )
    },
    "candidate_03_soft_warm": {
        "title": "Candidate 3 — Soft Warm",
        "prompt": (
            "Young adult woman around 24, soft warm feminine voice, medium pitch, gentle but confident, "
            "very natural conversational delivery, relaxed storytelling tone, subtle emotional variation, "
            "pleasant and charismatic, slightly playful, adult and youthful without sounding childish."
        )
    },
    "candidate_04_bright_natural": {
        "title": "Candidate 4 — Bright Natural",
        "prompt": (
            "Young adult woman around 24, naturally bright feminine voice, medium to medium-high pitch, "
            "lively but believable conversational energy, clear articulation, playful personality, "
            "expressive reactions, warm and human, never squeaky, never cartoonish."
        )
    },
    "candidate_05_confident_casual": {
        "title": "Candidate 5 — Confident Casual",
        "prompt": (
            "Young adult woman around 24, confident natural feminine voice, medium pitch, warm vocal texture, "
            "relaxed conversational delivery, subtly charismatic, slightly mischievous, comfortable with deadpan humor, "
            "believable casual storytelling, emotionally flexible, never sounding like an announcer."
        )
    },
    "candidate_06_storyteller": {
        "title": "Candidate 6 — Storyteller",
        "prompt": (
            "Young adult woman around 24, natural feminine storytelling voice, warm and engaging, "
            "medium pitch, conversational and intimate, clear but relaxed articulation, expressive when stories become exciting, "
            "restrained during jokes, capable of deadpan humor and genuine sincerity, sounds like a real person telling a funny personal story."
        )
    },
    "candidate_07_slightly_lower": {
        "title": "Candidate 7 — Slightly Lower",
        "prompt": (
            "Young adult woman around 24 with a slightly lower comfortable feminine pitch, warm natural timbre, "
            "confident conversational speech, calm but charismatic delivery, subtle playful humor, "
            "expressive without being theatrical, mature but youthful, believable and human."
        )
    },
    "candidate_08_light_playful": {
        "title": "Candidate 8 — Light / Playful",
        "prompt": (
            "Young adult woman around 24, naturally light feminine voice, medium-high pitch but never squeaky, "
            "warm and playful, conversational, approachable, expressive but understated, subtly mischievous, "
            "sounds like a real young adult casually telling stories."
        )
    }
}

# The Identical Audition Script from Section 27 (chunked into meaningful thoughts with pauses)
AUDITION_SCRIPT_CHUNKS: List[Tuple[str, float]] = [
    ("Wait, wait, wait—please stop for a second.", 0.25),
    ("I know you were probably just scrolling.", 0.25),
    ("Give me, like, thirty seconds.", 0.35),
    ("I'm Nemi, I'm twenty-four, and apparently I've decided that telling stories with animation is a good idea.", 0.40),
    ("Which sounds fun...", 0.30),
    ("until you actually have to animate something.", 0.50),
    ("I also sing, watch way too much anime, and occasionally convince myself that going to the gym counts as having my life together.", 0.60)
]

# Audition Emotion Test Lines from Sections 31–35
EMOTION_TEST_LINES: List[Tuple[str, str, float]] = [
    # (Category, Text, Pause After)
    ("DEADPAN_PART1", "That seemed like a good idea.", 0.60),
    ("DEADPAN_PART2", "It wasn't.", 0.80),
    ("EXCITED", "Wait, this actually worked?!", 0.60),
    ("AWKWARD", "Okay... that sounded better in my head.", 0.60),
    ("SHOCK", "Wait—what?", 0.60)
]

def run_audition(candidate_keys: List[str] = None, output_dir: str = None):
    config = NemiVoiceConfig()
    engine = QwenVoiceDesignEngine(config)
    
    target_keys = candidate_keys or list(CANDIDATE_VOICE_DESIGNS.keys())
    target_dir = output_dir or os.path.join(WORKSPACE_ROOT, "audio", "nemi", "auditions")
    os.makedirs(target_dir, exist_ok=True)
    
    print("============================================================")
    print("NEMI QWEN3-TTS VOICEDESIGN AUDITION SESSION")
    print(f"Candidates to audition: {len(target_keys)}")
    print(f"Output directory: {target_dir}")
    print("============================================================")
    
    audition_summary = []
    
    for c_key in target_keys:
        cand_info = CANDIDATE_VOICE_DESIGNS.get(c_key)
        if not cand_info:
            print(f"[Warning] Unknown candidate key: {c_key}")
            continue
            
        print(f"\nRendering [{cand_info['title']}]...")
        prompt = cand_info["prompt"]
        
        # 1. Render Identical Section 27 Audition Script
        audio_chunks = []
        for text_chunk, pause_sec in AUDITION_SCRIPT_CHUNKS:
            chunk_audio = engine.synthesize(text=text_chunk, instruct=prompt)
            audio_chunks.append(chunk_audio)
            if pause_sec > 0:
                silence = np.zeros(int(config.sample_rate * pause_sec), dtype=np.float32)
                audio_chunks.append(silence)
                
        full_audition = np.concatenate(audio_chunks)
        audition_file = f"audition_{c_key}.wav"
        audition_path = os.path.join(target_dir, audition_file)
        sf.write(audition_path, full_audition, config.sample_rate, subtype="PCM_16")
        audition_duration = len(full_audition) / float(config.sample_rate)
        print(f"  ✓ Saved Section 27 audition: {audition_file} ({audition_duration:.2f}s)")
        
        # 2. Render Emotion Tests (Sections 31–35)
        emotion_chunks = []
        for cat, text, pause_sec in EMOTION_TEST_LINES:
            emotion_audio = engine.synthesize(text=text, instruct=prompt)
            emotion_chunks.append(emotion_audio)
            if pause_sec > 0:
                silence = np.zeros(int(config.sample_rate * pause_sec), dtype=np.float32)
                emotion_chunks.append(silence)
                
        full_emotions = np.concatenate(emotion_chunks)
        emotions_file = f"emotions_{c_key}.wav"
        emotions_path = os.path.join(target_dir, emotions_file)
        sf.write(emotions_path, full_emotions, config.sample_rate, subtype="PCM_16")
        emotions_duration = len(full_emotions) / float(config.sample_rate)
        print(f"  ✓ Saved emotion test: {emotions_file} ({emotions_duration:.2f}s)")
        
        audition_summary.append({
            "key": c_key,
            "title": cand_info["title"],
            "audition_file": audition_file,
            "audition_duration": audition_duration,
            "emotions_file": emotions_file,
            "emotions_duration": emotions_duration
        })
        
    print("\n============================================================")
    print("AUDITIONS COMPLETE")
    for s in audition_summary:
        print(f"  - {s['title']}: {s['audition_file']} ({s['audition_duration']:.2f}s) | {s['emotions_file']} ({s['emotions_duration']:.2f}s)")
    print("============================================================")

def main():
    parser = argparse.ArgumentParser(description="Audition Qwen3-TTS VoiceDesign candidates for Nemi")
    parser.add_argument("--candidates", nargs="+", default=None, help="Candidate keys to audition (default: all 8)")
    parser.add_argument("--output", default=None, help="Output directory for audition WAV files")
    args = parser.parse_args()
    
    run_audition(candidate_keys=args.candidates, output_dir=args.output)

if __name__ == "__main__":
    main()
