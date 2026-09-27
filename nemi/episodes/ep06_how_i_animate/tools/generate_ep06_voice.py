#!/usr/bin/env python3
"""
generate_ep06_voice.py
Generates Voiceover for NEMI EPISODE 06: "HOW I ACTUALLY MAKE STORYTIME ANIMATIONS"
- Model: mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16
- Voice Actor: Sohee (Qwen predefined speaker, spk_id: 2864, EP00/EP05 Parity)
- Voice Prompt: "Warm, natural young adult woman around 24, relaxed conversational speech, friendly, casual, intelligent, slightly playful."
- Output: 24kHz WAV segments in audio/segments/ and master EP06_voice.wav in audio/
- Also outputs initial timing and alignment json
"""

import os
import sys
import json
import time
import numpy as np
import soundfile as sf
import shutil

EP06_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKSPACE_ROOT = os.path.abspath(os.path.join(EP06_DIR, "..", "..", ".."))
if WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, WORKSPACE_ROOT)

from tools.tts.config import NemiVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine

EP00_VOICE_PROMPT = (
    "Warm, natural young adult woman around 24, relaxed conversational speech, "
    "friendly, casual, intelligent, slightly playful."
)

SEGMENTS_DEF = [
    # Beat 1: The Question (Hook)
    {
        "id": "seg01_people_asking",
        "beat": 1,
        "text": "People keep asking how I actually make these animations. Like... do they just magically pop out of my laptop?",
        "tts_text": "People keep asking how I actually make these animations. Like, do they just magically pop out of my laptop?",
        "pause_after": 0.35,
        "tone": "casual wry curiosity, conversational storytime hook"
    },
    {
        "id": "seg02_honestly_i_wish",
        "beat": 1,
        "text": "Honestly? I wish. But here's what actually happens.",
        "tts_text": "Honestly? I wish. But here's what actually happens.",
        "pause_after": 0.45,
        "tone": "amused chuckle, warm direct address to camera"
    },

    # Beat 2: The Real-Life Spark
    {
        "id": "seg03_step_one_stupid",
        "beat": 2,
        "text": "Step one: something stupid has to happen to me in real life. Usually last week, or yesterday.",
        "tts_text": "Step one: something stupid has to happen to me in real life. Usually last week, or yesterday.",
        "pause_after": 0.35,
        "tone": "casual storytelling setup, wry smile"
    },
    {
        "id": "seg04_suddenly_brain_goes",
        "beat": 2,
        "text": "I'll be standing there, and suddenly my brain goes... wait. This could be hilarious.",
        "tts_text": "I'll be standing there, and suddenly my brain goes... wait. This could be hilarious.",
        "pause_after": 0.50,
        "tone": "sudden realization, playful spark of excitement"
    },

    # Beat 3: The Script & The Notebook
    {
        "id": "seg05_then_comes_notebook",
        "beat": 3,
        "text": "Then comes the notebook. I sit down and write what actually happened, what made it funny, and cross out all the boring parts.",
        "tts_text": "Then comes the notebook. I sit down and write what actually happened, what made it funny, and cross out all the boring parts.",
        "pause_after": 0.35,
        "tone": "practical storytelling, focused and energetic"
    },
    {
        "id": "seg06_cross_out_boring",
        "beat": 3,
        "text": "If it doesn't make me laugh out loud at my desk, it gets crossed out.",
        "tts_text": "If it doesn't make me laugh out loud at my desk, it gets crossed out.",
        "pause_after": 0.45,
        "tone": "amused conviction, decisive chuckle"
    },

    # Beat 4: Recording The Voice
    {
        "id": "seg07_next_is_voice",
        "beat": 4,
        "text": "Next is the voice. The voice is the absolute backbone of everything. I record it, listen back, and that audio becomes the master clock.",
        "tts_text": "Next is the voice. The voice is the absolute backbone of everything. I record it, listen back, and that audio becomes the master clock.",
        "pause_after": 0.50,
        "tone": "warm studio narration, clear storytelling emphasis on master clock"
    },

    # Beat 5: Storytelling Beats (The Timeline)
    {
        "id": "seg08_storytelling_beats",
        "beat": 5,
        "text": "Then I don't just animate sentences. I break the voice into storytelling beats. Explain, reaction, joke, pause, cutaway.",
        "tts_text": "Then I don't just animate sentences. I break the voice into storytelling beats. Explain, reaction, joke, pause, cutaway.",
        "pause_after": 0.45,
        "tone": "enthusiastic breakdown, clear rhythmic delivery of beats"
    },

    # Beat 6: Why Beats Matter
    {
        "id": "seg09_secret_explain",
        "beat": 6,
        "text": "Because here's the secret: animation has to follow the beat. Over here, I'm calmly explaining something.",
        "tts_text": "Because here's the secret: animation has to follow the beat. Over here, I'm calmly explaining something.",
        "pause_after": 0.30,
        "tone": "calm gentle explanation, conspiratorial whisper"
    },
    {
        "id": "seg10_joke_lands_deadpan",
        "beat": 6,
        "text": "And then... this is where the joke lands.",
        "tts_text": "And then... this is where the joke lands.",
        "pause_after": 1.20, # Comedic freeze hold!
        "tone": "deadpan comedic timing, sudden flat delivery"
    },

    # Beat 7: Godot Animation & The Timeline Scare
    {
        "id": "seg11_open_godot",
        "beat": 7,
        "text": "Then I open Godot to animate. I tell myself, 'Oh, this will be so simple and fast!'",
        "tts_text": "Then I open Godot to animate. I tell myself, 'Oh, this will be so simple and fast!'",
        "pause_after": 0.35,
        "tone": "overconfident cheerful optimism"
    },
    {
        "id": "seg12_forty_tracks_dread",
        "beat": 7,
        "text": "And then I see forty keyframe tracks. And my soul briefly leaves my body.",
        "tts_text": "And then I see forty keyframe tracks. And my soul briefly leaves my body.",
        "pause_after": 0.50,
        "tone": "dry disbelief, slow dramatic exhaustion, wry laugh"
    },

    # Beat 8: Props, Doodles & Handwriting
    {
        "id": "seg13_props_and_doodles",
        "beat": 8,
        "text": "Next come the hand-drawn props, the doodles, and handwritten notes. Every stroke is drawn by hand so the whole world feels alive.",
        "tts_text": "Next come the hand-drawn props, the doodles, and handwritten notes. Every stroke is drawn by hand so the whole world feels alive.",
        "pause_after": 0.45,
        "tone": "proud artist passion, organic flow"
    },

    # Beat 9: The Microscopic Fix
    {
        "id": "seg14_watch_fifty_times",
        "beat": 9,
        "text": "Then I watch it fifty times to polish the timing. Everything looks fine... until I notice one tiny hair pixel jittering.",
        "tts_text": "Then I watch it fifty times to polish the timing. Everything looks fine, until I notice one tiny hair pixel jittering.",
        "pause_after": 0.35,
        "tone": "perfectionist dread building up"
    },
    {
        "id": "seg15_zoom_in_no",
        "beat": 9,
        "text": "Zoom in. No. Unacceptable. Fix it immediately.",
        "tts_text": "Zoom in. No. Unacceptable. Fix it immediately.",
        "pause_after": 0.55,
        "tone": "intense comedic precision, firm deadpan"
    },

    # Beat 10: Final Render & Outro
    {
        "id": "seg16_final_render_renders",
        "beat": 10,
        "text": "And finally... after hours of tweaking lip sync and sound effects, the episode renders. So the next time you watch one of these...",
        "tts_text": "And finally, after hours of tweaking lip sync and sound effects, the episode renders. So the next time you watch one of these,",
        "pause_after": 0.35,
        "tone": "satisfaction and relief, warm storytelling wind-down"
    },
    {
        "id": "seg17_not_magic_journey",
        "beat": 10,
        "text": "Now you know: it didn't just magically appear. It was an entire journey. See you in the next story!",
        "tts_text": "Now you know: it didn't just magically appear. It was an entire journey. See you in the next story!",
        "pause_after": 0.60,
        "tone": "cheerful bright signoff, warm connection, friendly smile"
    }
]

def main():
    print("============================================================")
    print("  NEMI EPISODE 06: VOICEOVER GENERATION")
    print("  Title: \"HOW I ACTUALLY MAKE STORYTIME ANIMATIONS\"")
    print("  Voice Actor: SOHEE (Qwen3-TTS 1.7B CustomVoice, spk_id: 2864)")
    print(f"  Base Prompt: \"{EP00_VOICE_PROMPT}\"")
    print("============================================================")

    audio_dir = os.path.join(EP06_DIR, "audio")
    segments_dir = os.path.join(audio_dir, "segments")
    timing_dir = os.path.join(EP06_DIR, "timing")
    os.makedirs(segments_dir, exist_ok=True)
    os.makedirs(timing_dir, exist_ok=True)

    config = NemiVoiceConfig(
        speaker="sohee",
        voice_identifier="sohee",
        voice_design_prompt=EP00_VOICE_PROMPT
    )

    print("\n[1/3] Initializing Qwen Voice Engine with Sohee...")
    engine = QwenVoiceDesignEngine(config)

    print(f"\n[2/3] Synthesizing {len(SEGMENTS_DEF)} dialogue segments with actor: SOHEE...")
    generated_segments = []

    for idx, seg in enumerate(SEGMENTS_DEF):
        seg_id = seg["id"]
        out_wav = os.path.join(segments_dir, f"{seg_id}.wav")
        instruct = f"{EP00_VOICE_PROMPT} Tone directive: {seg['tone']}"

        t0 = time.time()
        duration = engine.synthesize_to_file(
            text=seg["tts_text"],
            output_path=out_wav,
            speaker="sohee",
            instruct=instruct,
            speed=1.0
        )
        dt = time.time() - t0
        print(f"  [{idx+1:02d}/{len(SEGMENTS_DEF)}] {seg_id}.wav ({duration:.2f}s, took {dt:.1f}s) — \"{seg['text'][:45]}...\"")
        
        seg_info = dict(seg)
        seg_info["file"] = f"{seg_id}.wav"
        seg_info["duration"] = round(duration, 3)
        generated_segments.append(seg_info)

    print("\n[3/3] Assembling Master Track & Alignment Manifest...")
    sample_rate = config.sample_rate # 24000 Hz
    master_chunks = []
    current_time = 0.0

    timeline_data = {
        "episode_id": "ep06_how_i_animate",
        "title": "HOW I ACTUALLY MAKE STORYTIME ANIMATIONS",
        "voice": "sohee",
        "total_segments": len(generated_segments),
        "segments": []
    }

    for seg in generated_segments:
        seg_path = os.path.join(segments_dir, seg["file"])
        audio_data, sr = sf.read(seg_path)
        if sr != sample_rate:
            raise ValueError(f"Sample rate mismatch: {sr} != {sample_rate}")
        
        start_t = current_time
        seg_len = len(audio_data) / float(sample_rate)
        end_t = start_t + seg_len

        seg_entry = {
            "id": seg["id"],
            "beat": seg["beat"],
            "text": seg["text"],
            "start_time": round(start_t, 3),
            "end_time": round(end_t, 3),
            "duration": round(seg_len, 3),
            "pause_after": seg["pause_after"]
        }
        timeline_data["segments"].append(seg_entry)

        master_chunks.append(audio_data)
        current_time = end_t

        # Insert pause
        pause_samples = int(seg["pause_after"] * sample_rate)
        if pause_samples > 0:
            master_chunks.append(np.zeros(pause_samples, dtype=np.float32))
            current_time += seg["pause_after"]

    full_master_audio = np.concatenate(master_chunks)
    total_duration = len(full_master_audio) / float(sample_rate)
    timeline_data["total_duration"] = round(total_duration, 3)

    master_wav_path = os.path.join(audio_dir, "EP06_voice.wav")
    sf.write(master_wav_path, full_master_audio, sample_rate, subtype="PCM_16")

    timing_manifest_path = os.path.join(timing_dir, "ep06_raw_timing.json")
    with open(timing_manifest_path, "w", encoding="utf-8") as f:
        json.dump(timeline_data, f, indent=2)

    print("\n============================================================")
    print(f"  ✓ Voiceover Generation Complete!")
    print(f"  Master Audio: {master_wav_path}")
    print(f"  Total Duration: {total_duration:.2f} seconds ({total_duration/60.0:.2f} mins)")
    print(f"  Timing Manifest: {timing_manifest_path}")
    print("============================================================")

if __name__ == "__main__":
    main()
