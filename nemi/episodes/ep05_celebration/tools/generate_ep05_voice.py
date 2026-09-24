#!/usr/bin/env python3
"""
tools/generate_ep05_voice.py
Voiceover Generation Pipeline for Nemi Episode 05: "WHAT IS GOING ON WITH YOUTUBE?"
Synthesizes 10 dialogue segments using Qwen3-TTS 1.7B CustomVoice (Voice Actor: Sohee).
Assembles master audio track and generates authoritative timing manifests.
"""

import os
import sys
import json
import time
import numpy as np
import soundfile as sf
import shutil

# Ensure workspace root is on sys.path
EP05_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKSPACE_ROOT = os.path.abspath(os.path.join(EP05_DIR, "..", "..", ".."))
if WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, WORKSPACE_ROOT)

from tools.tts.config import NemiVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine

SEGMENTS_DEF = [
    {
        "id": "seg01_analytics_freeze",
        "beat": 1,
        "text": "Guys... what is going on with YouTube right now? Like, I genuinely sat down at my desk today, opened my analytics, and just... froze.",
        "tts_text": "Guys, what is going on with YouTube right now? Like, I genuinely sat down at my desk today, opened my analytics, and just... froze.",
        "pause_after": 0.40,
        "speed": 1.15,
        "acting_note": "Casual confessional opening, confused upward inflection on 'right now', nervous laugh, then deadpan drop on 'froze'."
    },
    {
        "id": "seg02_seven_views_flashback",
        "beat": 2,
        "text": "Because literally last week, I was convinced nobody would ever watch these. I was refreshing at two in the morning, staring at seven views... and half of them were from my own phone!",
        "tts_text": "Because literally last week, I was convinced nobody would ever watch these. I was refreshing at two in the morning, staring at seven views, and half of them were from my own phone!",
        "pause_after": 0.40,
        "speed": 1.16,
        "acting_note": "Fast self-deprecating storytelling, building frustration, dramatic pause before 'seven views', sheepish whisper on 'own phone'."
    },
    {
        "id": "seg03_counter_climb",
        "beat": 3,
        "text": "And then today... I looked at the subscriber counter. And it was just... climbing. One... seventeen... eighty-four... five hundred... nine hundred ninety-nine...",
        "tts_text": "And then today, I looked at the subscriber counter. And it was just climbing. One, seventeen, eighty-four, five hundred, nine hundred ninety-nine...",
        "pause_after": 0.40,
        "speed": 1.14,
        "acting_note": "Pacing slows with mounting tension, breathless counting, voice rising with each number, hushed suspense at 999."
    },
    {
        "id": "seg04_milestone_explosion",
        "beat": 4,
        "text": "And then... ONE THOUSAND. Wait... WHAT?! One thousand subscribers?! Are you actually serious right now?!",
        "tts_text": "And then, one thousand. Wait, what? One thousand subscribers?! Are you actually serious right now?!",
        "pause_after": 0.50,
        "speed": 1.16,
        "acting_note": "Huge explosive energy, sudden high-pitched scream of disbelief on 'WHAT?!', rapid breathless laughing disbelief."
    },
    {
        "id": "seg05_human_beings",
        "beat": 5,
        "text": "I don't even know how to process that. That's not just some random digital number on a screen. That is one thousand actual, living human beings who chose to click subscribe!",
        "tts_text": "I don't even know how to process that. That's not just some random digital number on a screen. That is one thousand actual, living human beings who chose to click subscribe!",
        "pause_after": 0.50,
        "speed": 1.15,
        "acting_note": "Wonder and emotional honesty, emphasis on 'actual, living human beings', voice softening with gratitude."
    },
    {
        "id": "seg06_comments_avalanche",
        "beat": 6,
        "text": "And then I scrolled down to the comments... and there are literally around one thousand comments across the videos. A thousand comments?! Guys... WHAT?!",
        "tts_text": "And then I scrolled down to the comments, and there are literally around one thousand comments across the videos. A thousand comments?! Guys, what?!",
        "pause_after": 0.50,
        "speed": 1.16,
        "acting_note": "Fast escalation, comedic disbelief climbing, hands waving, sharp cutoff into stunned deadpan 'WHAT?!'."
    },
    {
        "id": "seg07_comment_gratitude",
        "beat": 7,
        "text": "I have been trying so hard to read every single one, but I physically cannot reply to everyone. So if I haven't replied to you yet, I'm so sorry, but I promise I read them and I smile like an idiot.",
        "tts_text": "I've been trying so hard to read every single one, but I physically cannot reply to everyone. So if I haven't replied to you yet, I'm so sorry, but I promise I read them and I smile like an idiot.",
        "pause_after": 0.50,
        "speed": 1.18,
        "acting_note": "Soft apologetic warmth, small breathy chuckle on 'smile like an idiot', tender eye contact."
    },
    {
        "id": "seg08_instagram_surprise",
        "beat": 8,
        "text": "And then, as if that wasn't already overwhelming, I checked Instagram... and we hit two hundred and fifty followers there too! Two hundred and fifty?! You guys are unreal.",
        "tts_text": "And then, as if that wasn't already overwhelming, I checked Instagram, and we hit two hundred and fifty followers there too! Two hundred and fifty?! You guys are unreal.",
        "pause_after": 0.50,
        "speed": 1.15,
        "acting_note": "Playful excitement, phone vibration reaction, joyful gasp on 'Two hundred and fifty?!', fond shaking head."
    },
    {
        "id": "seg09_creator_reality",
        "beat": 9,
        "text": "When you spend days sitting alone in your room drawing every single frame by hand, you never really think anyone will notice. So having this much support... it means more than I can even explain.",
        "tts_text": "When you spend days sitting alone in your room drawing every single frame by hand, you never really think anyone will notice. So having this much support, it means more than I can even explain.",
        "pause_after": 0.50,
        "speed": 1.14,
        "acting_note": "Honest vulnerability, gentle quiet delivery, reflective pause before 'it means more', direct heartfelt connection."
    },
    {
        "id": "seg10_warm_signoff",
        "beat": 10,
        "text": "So from the bottom of my heart... thank you. The next video is already in the works, and I cannot wait to show you. Thank you guys so much. Okay... bye!",
        "tts_text": "So from the bottom of my heart, thank you. The next video is already in the works, and I cannot wait to show you. Thank you guys so much. Okay, bye!",
        "pause_after": 0.80,
        "speed": 1.15,
        "acting_note": "Warm genuine thank you, enthusiastic nod on 'next video', intimate goodbye wave on 'Okay... bye!'."
    }
]

def main():
    print("============================================================")
    print("  NEMI EPISODE 05: VOICEOVER GENERATION PIPELINE")
    print("  Title: \"WHAT IS GOING ON WITH YOUTUBE?\"")
    print("  Voice Actor: SOHEE (Qwen3-TTS 1.7B CustomVoice)")
    print("============================================================")

    audio_dir = os.path.join(EP05_DIR, "audio")
    segments_dir = os.path.join(audio_dir, "segments")
    timing_dir = os.path.join(EP05_DIR, "timing")
    metadata_dir = os.path.join(audio_dir, "metadata")
    source_dir = os.path.join(audio_dir, "source")

    for d in [segments_dir, timing_dir, metadata_dir, source_dir]:
        os.makedirs(d, exist_ok=True)

    # Copy script to source
    script_src = os.path.join(EP05_DIR, "EP05_Script.md")
    if os.path.exists(script_src):
        shutil.copyfile(script_src, os.path.join(source_dir, "EP05_Script.md"))

    base_prompt = (
        "A 24-year-old storytime YouTuber recording casually into a nearby microphone at her creative desk, "
        "talking to the audience like close friends. The delivery is extremely animated and expressive: "
        "energetic fast-paced rambling with sudden emphasis spikes on punchlines, playful upward inflections, "
        "dramatic gasps, whispered confessions, breathy nervous laughs, quick self-interruptions, exaggerated "
        "reactions that instantly drop into dry flat deadpan, and genuine emotional warmth. Naturally imperfect "
        "human rhythm with false starts and audible breaths. Zero corporate narrator tone, zero monotone."
    )

    config = NemiVoiceConfig(
        speaker="sohee",
        voice_identifier="sohee",
        voice_design_prompt=base_prompt
    )

    print("\n[1/3] Initializing Qwen Voice Engine...")
    engine = QwenVoiceDesignEngine(config)

    print(f"\n[2/3] Synthesizing {len(SEGMENTS_DEF)} dialogue segments with actor: SOHEE...")
    generated_segments = []

    for idx, seg in enumerate(SEGMENTS_DEF):
        seg_id = seg["id"]
        out_wav = os.path.join(segments_dir, f"{seg_id}.wav")
        instruct = f"{base_prompt} Specific beat emotion directive: {seg['acting_note']}"

        t0 = time.time()
        duration = engine.synthesize_to_file(
            text=seg["tts_text"],
            output_path=out_wav,
            speaker="sohee",
            instruct=instruct,
            speed=seg["speed"]
        )
        dt = time.time() - t0
        print(f"  [{idx+1:02d}/10] {seg_id}.wav ({duration:.2f}s, generated in {dt:.1f}s) — \"{seg['text'][:40]}...\"")
        
        seg_info = dict(seg)
        seg_info["file"] = f"{seg_id}.wav"
        seg_info["duration"] = round(duration, 3)
        generated_segments.append(seg_info)

    print("\n[3/3] Assembling Master Track & Timing Manifests...")
    sample_rate = config.sample_rate # 24000 Hz
    master_chunks = []
    current_time = 0.0

    alignment_data = {
        "episode_id": "ep05_celebration",
        "title": "WHAT IS GOING ON WITH YOUTUBE?",
        "voice": "sohee",
        "sample_rate": sample_rate,
        "master_audio": "nemi/episodes/ep05_celebration/audio/EP05_voice.wav",
        "segments": []
    }

    for idx, seg in enumerate(generated_segments):
        seg_path = os.path.join(segments_dir, seg["file"])
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
            "speed": seg["speed"],
            "acting_note": seg["acting_note"]
        })

    full_master = np.concatenate(master_chunks)
    total_duration = round(len(full_master) / float(sample_rate), 3)
    alignment_data["total_duration"] = total_duration

    # Write Master Audio WAV
    master_wav_path = os.path.join(audio_dir, "EP05_voice.wav")
    sf.write(master_wav_path, full_master, sample_rate, subtype="PCM_16")
    print(f"  ✓ Master Voice WAV: {master_wav_path} ({total_duration:.2f}s)")

    # Write JSON Timing Manifests
    timing_json_path = os.path.join(timing_dir, "voice_alignment.json")
    with open(timing_json_path, "w", encoding="utf-8") as f:
        json.dump(alignment_data, f, indent=2)
    print(f"  ✓ Timing Alignment JSON: {timing_json_path}")

    shutil.copyfile(timing_json_path, os.path.join(audio_dir, "timing", "voice_alignment.json"))
    shutil.copyfile(timing_json_path, os.path.join(timing_dir, "ep05_celebration_timing.json"))

    # Write Metadata
    metadata = {
        "episode_id": "ep05_celebration",
        "title": "WHAT IS GOING ON WITH YOUTUBE?",
        "voice": "sohee",
        "model": "Qwen3-TTS-12Hz-1.7B-CustomVoice",
        "total_segments": len(generated_segments),
        "total_duration_seconds": total_duration,
        "sample_rate": sample_rate,
        "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    }
    with open(os.path.join(metadata_dir, "voice_metadata.json"), "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    # Convert to MP3 preview if ffmpeg is available
    ffmpeg_bin = "/opt/homebrew/bin/ffmpeg"
    if os.path.exists(ffmpeg_bin):
        master_mp3_path = os.path.join(audio_dir, "EP05_voice.mp3")
        os.system(f"{ffmpeg_bin} -y -i {master_wav_path} -q:a 2 {master_mp3_path} >/dev/null 2>&1")
        print(f"  ✓ Master Preview MP3: {master_mp3_path}")

    print("\n============================================================")
    print(f"  VOICEOVER GENERATION COMPLETE: {total_duration:.2f}s")
    print(f"  Duration: {int(total_duration // 60)}m {int(total_duration % 60):02d}s")
    print("============================================================")

if __name__ == "__main__":
    main()
