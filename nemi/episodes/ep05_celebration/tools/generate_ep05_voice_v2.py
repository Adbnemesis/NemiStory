#!/usr/bin/env python3
"""
generate_ep05_voice_v2.py
Regenerates Nemi Episode 05 Voiceover using EXACT EP00 Introduction Voice Properties:
- Model: mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16
- Voice Actor: Sohee (spk_id: 2864, predefined speaker)
- Voice Prompt: "Warm, natural young adult woman around 24, relaxed conversational speech, friendly, casual, intelligent, slightly playful."
- Target Runtime: ~1:30 (approx 85-92s)
- Natural relaxed conversational tempo, authentic pauses, no rushed rambling.
"""

import os
import sys
import json
import time
import numpy as np
import soundfile as sf
import shutil

EP05_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKSPACE_ROOT = os.path.abspath(os.path.join(EP05_DIR, "..", "..", ".."))
if WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, WORKSPACE_ROOT)

from tools.tts.config import NemiVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine

# Canonical EP00 Prompt
EP00_VOICE_PROMPT = (
    "Warm, natural young adult woman around 24, relaxed conversational speech, "
    "friendly, casual, intelligent, slightly playful."
)

SEGMENTS_DEF = [
    # Beat 1: The Freeze (Hook)
    {
        "id": "seg01_freeze_hook",
        "beat": 1,
        "text": "Guys... what is going on with YouTube right now?",
        "tts_text": "Guys, what is going on with YouTube right now?",
        "pause_after": 0.40,
        "tone": "relaxed, bewildered conversational question"
    },
    {
        "id": "seg02_sat_at_desk",
        "beat": 1,
        "text": "I sat down at my desk today, opened my analytics... and I just froze.",
        "tts_text": "I sat down at my desk today, opened my analytics, and I just froze.",
        "pause_after": 0.50,
        "tone": "conversational storytime, soft laugh, deadpan pause on froze"
    },

    # Beat 2: The 7 Views Callback (EP04 callback)
    {
        "id": "seg03_last_week_seven_views",
        "beat": 2,
        "text": "Because literally last week, I was refreshing at two in the morning, staring at seven views.",
        "tts_text": "Because literally last week, I was refreshing at two in the morning, staring at seven views.",
        "pause_after": 0.40,
        "tone": "self-deprecating storytelling, gentle laugh"
    },
    {
        "id": "seg04_from_my_own_phone",
        "beat": 2,
        "text": "And honestly? Three of those were from my own phone.",
        "tts_text": "And honestly? Three of those were from my own phone.",
        "pause_after": 0.55,
        "tone": "sheepish smile, playful wry confession"
    },

    # Beat 3: Counter Climb
    {
        "id": "seg05_opened_dashboard",
        "beat": 3,
        "text": "So I opened the dashboard today, expecting nothing...",
        "tts_text": "So I opened the dashboard today, expecting nothing.",
        "pause_after": 0.35,
        "tone": "casual relaxed setup"
    },
    {
        "id": "seg06_counter_climbing",
        "beat": 3,
        "text": "And the subscriber counter was just climbing. One, seventeen, eighty-four, five hundred...",
        "tts_text": "And the subscriber counter was just climbing. One, seventeen, eighty-four, five hundred,",
        "pause_after": 0.40,
        "tone": "wonder building up, conversational counting"
    },
    {
        "id": "seg07_nine_ninety_nine",
        "beat": 3,
        "text": "Nine hundred ninety-nine...",
        "tts_text": "Nine hundred ninety-nine.",
        "pause_after": 0.50,
        "tone": "hushed suspense, gentle awe"
    },

    # Beat 4: Milestone Explosion
    {
        "id": "seg08_one_thousand",
        "beat": 4,
        "text": "And then... one thousand.",
        "tts_text": "And then, one thousand.",
        "pause_after": 0.35,
        "tone": "stunned realization"
    },
    {
        "id": "seg09_wait_what_one_thousand",
        "beat": 4,
        "text": "Wait, what?! One thousand subscribers?!",
        "tts_text": "Wait, what?! One thousand subscribers?!",
        "pause_after": 0.35,
        "tone": "joyful surprise, laughing disbelief"
    },
    {
        "id": "seg10_are_you_serious",
        "beat": 4,
        "text": "Are you guys actually serious right now?!",
        "tts_text": "Are you guys actually serious right now?!",
        "pause_after": 0.55,
        "tone": "happy wonder, smiling amazement"
    },

    # Beat 5: Actual Human Beings
    {
        "id": "seg11_process_that",
        "beat": 5,
        "text": "I don't even know how to process that.",
        "tts_text": "I don't even know how to process that.",
        "pause_after": 0.40,
        "tone": "soft thoughtful breath, grounded honesty"
    },
    {
        "id": "seg12_living_human_beings",
        "beat": 5,
        "text": "That's not just a digital number on a screen. That is one thousand actual, living human beings.",
        "tts_text": "That's not just a digital number on a screen. That is one thousand actual, living human beings who chose to subscribe.",
        "pause_after": 0.55,
        "tone": "heartfelt sincere warmth, gentle emphasis"
    },

    # Beat 6: Comments Avalanche
    {
        "id": "seg13_checked_comments",
        "beat": 6,
        "text": "And then I checked the comments, and there are around one thousand comments across the videos.",
        "tts_text": "And then I checked the comments, and there are around one thousand comments across the videos.",
        "pause_after": 0.40,
        "tone": "amazed storytelling, happy disbelief"
    },
    {
        "id": "seg14_thousand_comments_shout",
        "beat": 6,
        "text": "A thousand comments?! Guys... what?!",
        "tts_text": "A thousand comments?! Guys, what?!",
        "pause_after": 0.50,
        "tone": "playful laugh, fond shake of head"
    },

    # Beat 7: Reading & Instagram
    {
        "id": "seg15_reading_promise",
        "beat": 7,
        "text": "I promise I read them, even if I can't reply to everyone. They make me smile like an idiot.",
        "tts_text": "I promise I read them, even if I can't reply to everyone. They make me smile like an idiot.",
        "pause_after": 0.45,
        "tone": "warm sweet smile, breathy chuckle"
    },
    {
        "id": "seg16_instagram_surprise",
        "beat": 8,
        "text": "And then Instagram hit two hundred and fifty followers too!",
        "tts_text": "And then Instagram hit two hundred and fifty followers too!",
        "pause_after": 0.55,
        "tone": "cheerful bounce, pleasant surprise"
    },

    # Beat 8: Creator Reality & Signoff
    {
        "id": "seg17_drawing_by_hand",
        "beat": 9,
        "text": "When you sit alone drawing every single frame by hand, this kind of support means everything to me.",
        "tts_text": "When you sit alone drawing every single frame by hand, this kind of support means everything to me.",
        "pause_after": 0.45,
        "tone": "quiet sincere gratitude, reflective connection"
    },
    {
        "id": "seg18_warm_signoff",
        "beat": 10,
        "text": "So from the bottom of my heart, thank you so much. New video soon. Bye!",
        "tts_text": "So from the bottom of my heart, thank you so much. New video soon. Bye!",
        "pause_after": 0.80,
        "tone": "cheerful genuine thank you, warm parting wave"
    }
]

def main():
    print("============================================================")
    print("  NEMI EPISODE 05: VOICEOVER GENERATION V2 (EP00 PARITY)")
    print("  Title: \"WHAT IS GOING ON WITH YOUTUBE?\"")
    print("  Voice Actor: SOHEE (Qwen3-TTS 1.7B CustomVoice, spk_id: 2864)")
    print(f"  Base Prompt: \"{EP00_VOICE_PROMPT}\"")
    print(f"  Target Length: ~1:30 (~90s)")
    print("============================================================")

    audio_dir = os.path.join(EP05_DIR, "audio")
    v2_segments_dir = os.path.join(audio_dir, "segments_v2")
    os.makedirs(v2_segments_dir, exist_ok=True)

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
        out_wav = os.path.join(v2_segments_dir, f"{seg_id}.wav")
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
        print(f"  [{idx+1:02d}/{len(SEGMENTS_DEF)}] {seg_id}.wav ({duration:.2f}s, took {dt:.1f}s) — \"{seg['text'][:40]}...\"")
        
        seg_info = dict(seg)
        seg_info["file"] = f"{seg_id}.wav"
        seg_info["duration"] = round(duration, 3)
        generated_segments.append(seg_info)

    print("\n[3/3] Assembling Master Track & Alignment Manifest...")
    sample_rate = config.sample_rate # 24000 Hz
    master_chunks = []
    current_time = 0.0

    alignment_data = {
        "episode_id": "ep05_celebration",
        "title": "WHAT IS GOING ON WITH YOUTUBE?",
        "voice": "sohee",
        "sample_rate": sample_rate,
        "voice_design_prompt": EP00_VOICE_PROMPT,
        "speed": 1.0,
        "segments": []
    }

    for idx, seg in enumerate(generated_segments):
        seg_path = os.path.join(v2_segments_dir, seg["file"])
        audio_data, sr = sf.read(seg_path, dtype="float32")
        if audio_data.ndim > 1:
            audio_data = audio_data.mean(axis=1)

        dur = len(audio_data) / float(sr)
        start_t = round(current_time, 3)
        end_t = round(current_time + dur, 3)

        master_chunks.append(audio_data)
        current_time = end_t

        pause_sec = seg["pause_after"]
        if pause_sec > 0:
            silence = np.zeros(int(sr * pause_sec), dtype=np.float32)
            master_chunks.append(silence)
            current_time = round(current_time + pause_sec, 3)

        alignment_data["segments"].append({
            "id": seg["id"],
            "beat": seg["beat"],
            "text": seg["text"],
            "start": start_t,
            "duration": round(dur, 3),
            "end": end_t,
            "pause_after": pause_sec,
            "tone": seg["tone"]
        })

    full_master = np.concatenate(master_chunks)
    total_duration = round(len(full_master) / float(sample_rate), 3)
    alignment_data["total_duration"] = total_duration

    # Output master V2 WAV
    master_v2_path = os.path.join(audio_dir, "EP05_voice_v2.wav")
    sf.write(master_v2_path, full_master, sample_rate, subtype="PCM_16")

    # Also export MP3 for easy listening
    mp3_v2_path = os.path.join(audio_dir, "EP05_voice_v2.mp3")
    import subprocess
    cmd_mp3 = ["/opt/homebrew/bin/ffmpeg", "-y", "-i", master_v2_path, "-b:a", "192k", mp3_v2_path]
    subprocess.run(cmd_mp3, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    timing_v2_json = os.path.join(EP05_DIR, "timing", "voice_alignment_v2.json")
    with open(timing_v2_json, "w", encoding="utf-8") as f:
        json.dump(alignment_data, f, indent=2)

    print("\n============================================================")
    print(f"  ✓ MASTER VOICE V2 COMPLETE: {master_v2_path}")
    print(f"  ✓ MP3 PREVIEW: {mp3_v2_path}")
    print(f"  ✓ TOTAL DURATION: {total_duration:.2f}s ({int(total_duration//60)}m {total_duration%60:.1f}s)")
    print(f"  ✓ ALIGNMENT JSON: {timing_v2_json}")
    print("============================================================")

if __name__ == "__main__":
    main()
