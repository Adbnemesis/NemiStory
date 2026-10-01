#!/usr/bin/env python3
"""
generate_ep07_voice.py
Generates Voiceover for NEMI EPISODE 07: "I GOT 0 MARKS IN MY EXAM"
- Model: mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16
- Voice Actor: Sohee (Qwen predefined speaker, spk_id: 2864, EP00/EP05/EP06 Parity)
- Voice Prompt: "Warm, natural young adult woman around 24, relaxed conversational speech, friendly, casual, intelligent, slightly playful."
- Output: 24kHz WAV segments in audio/segments/ and master EP07_voice.wav in audio/
- Also outputs initial timing manifest in timing/ep07_raw_timing.json
"""

import os
import sys
import json
import time
import numpy as np
import soundfile as sf

EP07_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKSPACE_ROOT = os.path.abspath(os.path.join(EP07_DIR, "..", "..", ".."))
if WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, WORKSPACE_ROOT)

from tools.tts.config import NemiVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine

EP00_VOICE_PROMPT = (
    "Warm, natural young adult woman around 24, relaxed conversational speech, "
    "friendly, casual, intelligent, slightly playful."
)

SEGMENTS_DEF = [
    # Beat 1: The Hook (Opening)
    {
        "id": "seg01_wait",
        "beat": 1,
        "text": "WAIT.",
        "tts_text": "Wait.",
        "pause_after": 0.45,
        "tone": "sharp energetic storytime hook, sudden urgent opening"
    },
    {
        "id": "seg02_fastest_way",
        "beat": 1,
        "text": "I think I discovered the fastest way to get zero marks in an exam.",
        "tts_text": "I think I discovered the fastest way to get zero marks in an exam.",
        "pause_after": 0.55,
        "tone": "casual, wry, engaging storyteller address"
    },

    # Beat 2: College During COVID / Everything Online
    {
        "id": "seg03_started_in_college",
        "beat": 2,
        "text": "It started back in college, during COVID.",
        "tts_text": "It started back in college, during COVID.",
        "pause_after": 0.40,
        "tone": "reflective memory, warm conversational setup"
    },
    {
        "id": "seg04_first_couple_online",
        "beat": 2,
        "text": "For the first couple of semesters, everything was online.",
        "tts_text": "For the first couple of semesters, everything was online.",
        "pause_after": 0.35,
        "tone": "matter-of-fact reminiscing"
    },
    {
        "id": "seg05_classes_tests_assignments",
        "beat": 2,
        "text": "Classes. Tests. Assignments. Everything.",
        "tts_text": "Classes. Tests. Assignments. Everything.",
        "pause_after": 0.55,
        "tone": "rhythmic list, emphatic punctuation on each item"
    },

    # Beat 3: Third Semester & The Contradiction
    {
        "id": "seg06_third_semester",
        "beat": 3,
        "text": "Then in third semester, we finally went to college.",
        "tts_text": "Then in third semester, we finally went to college.",
        "pause_after": 0.30,
        "tone": "bright narrative shift, feeling of progress"
    },
    {
        "id": "seg07_which_was_great",
        "beat": 3,
        "text": "Which was great.",
        "tts_text": "Which was great.",
        "pause_after": 0.40,
        "tone": "upbeat, happy acknowledgment"
    },
    {
        "id": "seg08_except_somehow",
        "beat": 3,
        "text": "Except somehow... the exams were STILL online.",
        "tts_text": "Except somehow, the exams were still online.",
        "pause_after": 0.60,
        "tone": "baffled, amused disbelief at the absurdity"
    },

    # Beat 4: One Subject I Didn't Care About / Terrible Plan
    {
        "id": "seg09_one_subject",
        "beat": 4,
        "text": "So when final exams came around, there was one subject I really didn't care about.",
        "tts_text": "So when final exams came around, there was one subject I really didn't care about.",
        "pause_after": 0.35,
        "tone": "honest casual confession, slight shrug"
    },
    {
        "id": "seg10_study_later",
        "beat": 4,
        "text": "And I thought... 'eh, I'll study later.'",
        "tts_text": "And I thought, eh, I'll study later.",
        "pause_after": 0.45,
        "tone": "smug casual procrastination, nonchalant brush-off"
    },
    {
        "id": "seg11_obviously_online",
        "beat": 4,
        "text": "Because obviously... the exam was going to be online.",
        "tts_text": "Because obviously, the exam was going to be online.",
        "pause_after": 0.40,
        "tone": "overconfident rationalization"
    },
    {
        "id": "seg12_had_a_plan",
        "beat": 4,
        "text": "I had a plan. It was a terrible plan.",
        "tts_text": "I had a plan. It was a terrible plan.",
        "pause_after": 0.65,
        "tone": "deadpan delivery, immediate self-awareness"
    },

    # Beat 5: The Email Reveal & Panic
    {
        "id": "seg13_one_week_before",
        "beat": 5,
        "text": "Then, one week before the finals... we got the email.",
        "tts_text": "Then, one week before the finals, we got the email.",
        "pause_after": 0.50,
        "tone": "dramatic turning point, ominous shift"
    },
    {
        "id": "seg14_not_online_anymore",
        "beat": 5,
        "text": "The exams would NOT be online anymore. They'd be offline.",
        "tts_text": "The exams would NOT be online anymore. They'd be offline.",
        "pause_after": 0.45,
        "tone": "shocked realization, stressed announcement"
    },
    {
        "id": "seg15_everyone_panicked",
        "beat": 5,
        "text": "Everyone panicked.",
        "tts_text": "Everyone panicked.",
        "pause_after": 0.60,
        "tone": "blunt chaotic punchline"
    },

    # Beat 6: The 2 AM Study Grind Montage
    {
        "id": "seg16_hardworking_class",
        "beat": 6,
        "text": "Suddenly the entire class became extremely hardworking.",
        "tts_text": "Suddenly the entire class became extremely hardworking.",
        "pause_after": 0.35,
        "tone": "ironic observation, chaotic group energy"
    },
    {
        "id": "seg17_studied_every_day",
        "beat": 6,
        "text": "We studied every day. Until 2 AM.",
        "tts_text": "We studied every day. Until 2 AM.",
        "pause_after": 0.50,
        "tone": "exhausted emphasis on late night"
    },
    {
        "id": "seg18_books_notes_everywhere",
        "beat": 6,
        "text": "Books everywhere. Notes everywhere. People asking each other questions.",
        "tts_text": "Books everywhere. Notes everywhere. People asking each other questions.",
        "pause_after": 0.35,
        "tone": "fast frantic listing of chaos"
    },
    {
        "id": "seg19_fighting_for_lives",
        "beat": 6,
        "text": "We were fighting for our lives.",
        "tts_text": "We were fighting for our lives.",
        "pause_after": 0.65,
        "tone": "comedic hyperbole, desperate survival energy"
    },

    # Beat 7: Exam Day & The Blank Mind
    {
        "id": "seg20_exam_day",
        "beat": 7,
        "text": "And then... exam day.",
        "tts_text": "And then, exam day.",
        "pause_after": 0.45,
        "tone": "ominous arrival, quiet dread"
    },
    {
        "id": "seg21_got_question_paper",
        "beat": 7,
        "text": "I got the question paper. I looked at it.",
        "tts_text": "I got the question paper. I looked at it.",
        "pause_after": 0.80, # Silence before the blank realization
        "tone": "hushed tension, looking down at paper"
    },
    {
        "id": "seg22_nothing_absolutely",
        "beat": 7,
        "text": "Nothing. Absolutely nothing.",
        "tts_text": "Nothing. Absolutely nothing.",
        "pause_after": 0.70, # Silence breathes
        "tone": "stark deadpan whisper, brain completely empty"
    },
    {
        "id": "seg23_brain_left_building",
        "beat": 7,
        "text": "My brain had completely left the building.",
        "tts_text": "My brain had completely left the building.",
        "pause_after": 0.55,
        "tone": "baffled resignation, comic imagery"
    },

    # Beat 8: Refused to Leave Anything Unanswered
    {
        "id": "seg24_pretty_good_student",
        "beat": 8,
        "text": "But I've always been a pretty good student, so there was ONE thing I refused to do.",
        "tts_text": "But I've always been a pretty good student, so there was one thing I refused to do.",
        "pause_after": 0.35,
        "tone": "sudden stubborn pride, rallying determination"
    },
    {
        "id": "seg25_leave_unanswered",
        "beat": 8,
        "text": "Leave anything unanswered.",
        "tts_text": "Leave anything unanswered.",
        "pause_after": 0.45,
        "tone": "resolute conviction, dramatic focus"
    },
    {
        "id": "seg26_wrote_for_every",
        "beat": 8,
        "text": "So I wrote something for every question.",
        "tts_text": "So I wrote something for every question.",
        "pause_after": 0.35,
        "tone": "fierce determined momentum"
    },
    {
        "id": "seg27_every_single_question",
        "beat": 8,
        "text": "Every. Single. Question.",
        "tts_text": "Every. Single. Question.",
        "pause_after": 0.60,
        "tone": "punchy staccato emphasis"
    },

    # Beat 9: Answer Sheet Reveal & ZERO
    {
        "id": "seg28_thought_id_get_something",
        "beat": 9,
        "text": "And honestly? I thought I'd get SOMETHING.",
        "tts_text": "And honestly? I thought I'd get something.",
        "pause_after": 0.40,
        "tone": "tentative optimism, sheepish hope"
    },
    {
        "id": "seg29_maybe_ten_five_pity",
        "beat": 9,
        "text": "Maybe ten marks. Maybe five. Maybe pity marks.",
        "tts_text": "Maybe ten marks. Maybe five. Maybe pity marks.",
        "pause_after": 0.55,
        "tone": "bargaining descending hope, quiet humor"
    },
    {
        "id": "seg30_sheets_back",
        "beat": 9,
        "text": "Then we got our answer sheets back.",
        "tts_text": "Then we got our answer sheets back.",
        "pause_after": 0.40,
        "tone": "suspenseful reveal setup"
    },
    {
        "id": "seg31_there_it_was_zero",
        "beat": 9,
        "text": "And there it was. Zero. Zero out of thirty.",
        "tts_text": "And there it was. Zero. Zero out of thirty.",
        "pause_after": 0.45,
        "tone": "stunned disbelief, quiet shock"
    },
    {
        "id": "seg32_thirty_available_got_zero",
        "beat": 9,
        "text": "Thirty marks were available. I got... ZERO.",
        "tts_text": "Thirty marks were available. I got, zero.",
        "pause_after": 0.85, # Comedic peak silence
        "tone": "unbelieving whisper to emphatic comedic impact"
    },

    # Beat 10: Final Stare, Callback & Outro
    {
        "id": "seg33_stared_at_paper",
        "beat": 10,
        "text": "I just stared at the paper.",
        "tts_text": "I just stared at the paper.",
        "pause_after": 0.60,
        "tone": "empty deadpan stare, numbness"
    },
    {
        "id": "seg34_after_studying_for_this",
        "beat": 10,
        "text": "After studying until 2 AM. For this.",
        "tts_text": "After studying until 2 AM. For this.",
        "pause_after": 0.70,
        "tone": "hollow comedic realization, exasperated chuckle"
    },
    {
        "id": "seg35_future_me_strategy",
        "beat": 10,
        "text": "Turns out... 'future me will figure it out' was not, in fact, a very good strategy.",
        "tts_text": "Turns out, 'future me will figure it out' was not, in fact, a very good strategy.",
        "pause_after": 0.80,
        "tone": "warm wry self-deprecating conclusion, peaceful acceptance"
    }
]

def main():
    print("============================================================")
    print("NEMI EPISODE 07 VOICEOVER GENERATION: \"I GOT 0 MARKS IN MY EXAM\"")
    print("Speaker: SOHEE (mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16)")
    print("============================================================")

    audio_dir = os.path.join(EP07_DIR, "audio")
    segments_dir = os.path.join(audio_dir, "segments")
    timing_dir = os.path.join(EP07_DIR, "timing")
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
        "episode_id": "ep07_zero_marks",
        "title": "I GOT 0 MARKS IN MY EXAM",
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

        # Insert calibrated comedic pause
        pause_samples = int(seg["pause_after"] * sample_rate)
        if pause_samples > 0:
            master_chunks.append(np.zeros(pause_samples, dtype=np.float32))
            current_time += seg["pause_after"]

    full_master_audio = np.concatenate(master_chunks)
    total_duration = len(full_master_audio) / float(sample_rate)
    timeline_data["total_duration"] = round(total_duration, 3)

    master_wav_path = os.path.join(audio_dir, "EP07_voice.wav")
    sf.write(master_wav_path, full_master_audio, sample_rate, subtype="PCM_16")

    timing_manifest_path = os.path.join(timing_dir, "ep07_raw_timing.json")
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
