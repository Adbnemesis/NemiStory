#!/usr/bin/env python3
"""
process_ep07_audio_timing.py
Processes EP07 voice segments:
1. Reads all 35 synthesized segments from audio/segments/
2. Assembles master audio EP07_voice.wav with calibrated storytelling pauses
3. Calculates exact beat boundaries (Beats 1 through 10)
4. Generates Episode07Subtitles.gd ensuring strictly <= 5 words per subtitle card
5. Generates timing/ep07_timing.json and timing/voice_alignment.json
"""

import os
import sys
import json
import numpy as np
import soundfile as sf
import shutil

EP07_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO_DIR = os.path.join(EP07_DIR, "audio")
SEGMENTS_DIR = os.path.join(AUDIO_DIR, "segments")
TIMING_DIR = os.path.join(EP07_DIR, "timing")

SEGMENTS_CONFIG = [
    # Beat 1: The Hook (Opening)
    {
        "id": "seg01_wait",
        "beat": 1,
        "pause_after": 0.45,
        "text": "WAIT.",
        "cards": [
            ("WAIT.", 1.0, "shock")
        ]
    },
    {
        "id": "seg02_fastest_way",
        "beat": 1,
        "pause_after": 0.55,
        "text": "I think I discovered the fastest way to get zero marks in an exam.",
        "cards": [
            ("I think I discovered", 0.30, "candid"),
            ("the fastest way", 0.22, "candid"),
            ("to get zero marks", 0.28, "shock"),
            ("in an exam.", 0.20, "normal")
        ]
    },

    # Beat 2: College During COVID / Everything Online
    {
        "id": "seg03_started_in_college",
        "beat": 2,
        "pause_after": 0.40,
        "text": "It started back in college, during COVID.",
        "cards": [
            ("It started back", 0.32, "reflective"),
            ("in college,", 0.28, "reflective"),
            ("during COVID.", 0.40, "reflective")
        ]
    },
    {
        "id": "seg04_first_couple_online",
        "beat": 2,
        "pause_after": 0.35,
        "text": "For the first couple of semesters, everything was online.",
        "cards": [
            ("For the first couple", 0.34, "normal"),
            ("of semesters,", 0.26, "normal"),
            ("everything was online.", 0.40, "normal")
        ]
    },
    {
        "id": "seg05_classes_tests_assignments",
        "beat": 2,
        "pause_after": 0.55,
        "text": "Classes. Tests. Assignments. Everything.",
        "cards": [
            ("Classes.", 0.22, "normal"),
            ("Tests.", 0.22, "normal"),
            ("Assignments.", 0.28, "normal"),
            ("Everything.", 0.28, "deadpan")
        ]
    },

    # Beat 3: Third Semester & The Contradiction
    {
        "id": "seg06_third_semester",
        "beat": 3,
        "pause_after": 0.30,
        "text": "Then in third semester, we finally went to college.",
        "cards": [
            ("Then in third semester,", 0.40, "excited"),
            ("we finally went", 0.30, "excited"),
            ("to college.", 0.30, "excited")
        ]
    },
    {
        "id": "seg07_which_was_great",
        "beat": 3,
        "pause_after": 0.40,
        "text": "Which was great.",
        "cards": [
            ("Which was great.", 1.0, "happy")
        ]
    },
    {
        "id": "seg08_except_somehow",
        "beat": 3,
        "pause_after": 0.60,
        "text": "Except somehow... the exams were STILL online.",
        "cards": [
            ("Except somehow...", 0.35, "confused"),
            ("the exams were", 0.28, "confused"),
            ("STILL online.", 0.37, "baffled")
        ]
    },

    # Beat 4: One Subject I Didn't Care About / Terrible Plan
    {
        "id": "seg09_one_subject",
        "beat": 4,
        "pause_after": 0.35,
        "text": "So when final exams came around, there was one subject I really didn't care about.",
        "cards": [
            ("So when final exams", 0.24, "normal"),
            ("came around,", 0.16, "normal"),
            ("there was one subject", 0.25, "bored"),
            ("I really didn't", 0.18, "bored"),
            ("care about.", 0.17, "shrug")
        ]
    },
    {
        "id": "seg10_study_later",
        "beat": 4,
        "pause_after": 0.45,
        "text": "And I thought... 'eh, I'll study later.'",
        "cards": [
            ("And I thought...", 0.40, "smug"),
            ("'eh, I'll study later.'", 0.60, "smug")
        ]
    },
    {
        "id": "seg11_obviously_online",
        "beat": 4,
        "pause_after": 0.40,
        "text": "Because obviously... the exam was going to be online.",
        "cards": [
            ("Because obviously...", 0.35, "confident"),
            ("the exam was going", 0.35, "confident"),
            ("to be online.", 0.30, "confident")
        ]
    },
    {
        "id": "seg12_had_a_plan",
        "beat": 4,
        "pause_after": 0.65,
        "text": "I had a plan. It was a terrible plan.",
        "cards": [
            ("I had a plan.", 0.42, "proud"),
            ("It was a terrible plan.", 0.58, "deadpan")
        ]
    },

    # Beat 5: The Email Reveal & Panic
    {
        "id": "seg13_one_week_before",
        "beat": 5,
        "pause_after": 0.50,
        "text": "Then, one week before the finals... we got the email.",
        "cards": [
            ("Then, one week", 0.30, "suspense"),
            ("before the finals...", 0.35, "suspense"),
            ("we got the email.", 0.35, "ominous")
        ]
    },
    {
        "id": "seg14_not_online_anymore",
        "beat": 5,
        "pause_after": 0.45,
        "text": "The exams would NOT be online anymore. They'd be offline.",
        "cards": [
            ("The exams would NOT", 0.35, "shock"),
            ("be online anymore.", 0.33, "shock"),
            ("They'd be offline.", 0.32, "horror")
        ]
    },
    {
        "id": "seg15_everyone_panicked",
        "beat": 5,
        "pause_after": 0.60,
        "text": "Everyone panicked.",
        "cards": [
            ("Everyone panicked.", 1.0, "panic")
        ]
    },

    # Beat 6: The 2 AM Study Grind Montage
    {
        "id": "seg16_hardworking_class",
        "beat": 6,
        "pause_after": 0.35,
        "text": "Suddenly the entire class became extremely hardworking.",
        "cards": [
            ("Suddenly the entire class", 0.48, "candid"),
            ("became extremely hardworking.", 0.52, "ironic")
        ]
    },
    {
        "id": "seg17_studied_every_day",
        "beat": 6,
        "pause_after": 0.50,
        "text": "We studied every day. Until 2 AM.",
        "cards": [
            ("We studied every day.", 0.52, "tired"),
            ("Until 2 AM.", 0.48, "exhausted")
        ]
    },
    {
        "id": "seg18_books_notes_everywhere",
        "beat": 6,
        "pause_after": 0.35,
        "text": "Books everywhere. Notes everywhere. People asking each other questions.",
        "cards": [
            ("Books everywhere.", 0.24, "frantic"),
            ("Notes everywhere.", 0.24, "frantic"),
            ("People asking each other", 0.34, "chaos"),
            ("questions.", 0.18, "chaos")
        ]
    },
    {
        "id": "seg19_fighting_for_lives",
        "beat": 6,
        "pause_after": 0.65,
        "text": "We were fighting for our lives.",
        "cards": [
            ("We were fighting", 0.48, "desperate"),
            ("for our lives.", 0.52, "desperate")
        ]
    },

    # Beat 7: Exam Day & The Blank Mind
    {
        "id": "seg20_exam_day",
        "beat": 7,
        "pause_after": 0.45,
        "text": "And then... exam day.",
        "cards": [
            ("And then...", 0.45, "dread"),
            ("exam day.", 0.55, "dread")
        ]
    },
    {
        "id": "seg21_got_question_paper",
        "beat": 7,
        "pause_after": 0.80, # Long silence before blank realization
        "text": "I got the question paper. I looked at it.",
        "cards": [
            ("I got the", 0.28, "quiet"),
            ("question paper.", 0.34, "quiet"),
            ("I looked at it.", 0.38, "quiet")
        ]
    },
    {
        "id": "seg22_nothing_absolutely",
        "beat": 7,
        "pause_after": 0.70, # Silence breathes
        "text": "Nothing. Absolutely nothing.",
        "cards": [
            ("Nothing.", 0.45, "deadpan"),
            ("Absolutely nothing.", 0.55, "blank")
        ]
    },
    {
        "id": "seg23_brain_left_building",
        "beat": 7,
        "pause_after": 0.55,
        "text": "My brain had completely left the building.",
        "cards": [
            ("My brain had", 0.32, "baffled"),
            ("completely left", 0.34, "baffled"),
            ("the building.", 0.34, "baffled")
        ]
    },

    # Beat 8: Refused to Leave Anything Unanswered
    {
        "id": "seg24_pretty_good_student",
        "beat": 8,
        "pause_after": 0.35,
        "text": "But I've always been a pretty good student, so there was ONE thing I refused to do.",
        "cards": [
            ("But I've always been", 0.26, "proud"),
            ("a pretty good student,", 0.28, "proud"),
            ("so there was ONE thing", 0.26, "determined"),
            ("I refused to do.", 0.20, "determined")
        ]
    },
    {
        "id": "seg25_leave_unanswered",
        "beat": 8,
        "pause_after": 0.45,
        "text": "Leave anything unanswered.",
        "cards": [
            ("Leave anything unanswered.", 1.0, "fierce")
        ]
    },
    {
        "id": "seg26_wrote_for_every",
        "beat": 8,
        "pause_after": 0.35,
        "text": "So I wrote something for every question.",
        "cards": [
            ("So I wrote something", 0.52, "determined"),
            ("for every question.", 0.48, "determined")
        ]
    },
    {
        "id": "seg27_every_single_question",
        "beat": 8,
        "pause_after": 0.60,
        "text": "Every. Single. Question.",
        "cards": [
            ("Every.", 0.33, "punchy"),
            ("Single.", 0.33, "punchy"),
            ("Question.", 0.34, "punchy")
        ]
    },

    # Beat 9: Answer Sheet Reveal & ZERO
    {
        "id": "seg28_thought_id_get_something",
        "beat": 9,
        "pause_after": 0.40,
        "text": "And honestly? I thought I'd get SOMETHING.",
        "cards": [
            ("And honestly?", 0.38, "hopeful"),
            ("I thought I'd get", 0.34, "hopeful"),
            ("SOMETHING.", 0.28, "hopeful")
        ]
    },
    {
        "id": "seg29_maybe_ten_five_pity",
        "beat": 9,
        "pause_after": 0.55,
        "text": "Maybe ten marks. Maybe five. Maybe pity marks.",
        "cards": [
            ("Maybe ten marks.", 0.35, "bargaining"),
            ("Maybe five.", 0.27, "bargaining"),
            ("Maybe pity marks.", 0.38, "pleading")
        ]
    },
    {
        "id": "seg30_sheets_back",
        "beat": 9,
        "pause_after": 0.40,
        "text": "Then we got our answer sheets back.",
        "cards": [
            ("Then we got", 0.45, "suspense"),
            ("our answer sheets back.", 0.55, "suspense")
        ]
    },
    {
        "id": "seg31_there_it_was_zero",
        "beat": 9,
        "pause_after": 0.45,
        "text": "And there it was. Zero. Zero out of thirty.",
        "cards": [
            ("And there it was.", 0.38, "stunned"),
            ("Zero.", 0.24, "shock"),
            ("Zero out of thirty.", 0.38, "disbelief")
        ]
    },
    {
        "id": "seg32_thirty_available_got_zero",
        "beat": 9,
        "pause_after": 0.85, # Comedic peak silence
        "text": "Thirty marks were available. I got... ZERO.",
        "cards": [
            ("Thirty marks were available.", 0.55, "disbelief"),
            ("I got...", 0.22, "pause"),
            ("ZERO.", 0.23, "deadpan")
        ]
    },

    # Beat 10: Final Stare, Callback & Outro
    {
        "id": "seg33_stared_at_paper",
        "beat": 10,
        "pause_after": 0.60,
        "text": "I just stared at the paper.",
        "cards": [
            ("I just stared", 0.50, "deadpan"),
            ("at the paper.", 0.50, "deadpan")
        ]
    },
    {
        "id": "seg34_after_studying_for_this",
        "beat": 10,
        "pause_after": 0.70,
        "text": "After studying until 2 AM. For this.",
        "cards": [
            ("After studying until 2 AM.", 0.65, "exhausted"),
            ("For this.", 0.35, "defeated")
        ]
    },
    {
        "id": "seg35_future_me_strategy",
        "beat": 10,
        "pause_after": 0.80,
        "text": "Turns out... 'future me will figure it out' was not, in fact, a very good strategy.",
        "cards": [
            ("Turns out...", 0.20, "wry"),
            ("'future me", 0.18, "wry"),
            ("will figure it out'", 0.24, "wry"),
            ("was not, in fact,", 0.20, "wry"),
            ("a very good strategy.", 0.18, "peaceful")
        ]
    }
]

def main():
    print("============================================================")
    print("EPISODE 07 AUDIO & TIMING PROCESSOR: \"I GOT 0 MARKS IN MY EXAM\"")
    print("============================================================")

    # 1. Verify all cards <= 5 words
    for seg in SEGMENTS_CONFIG:
        for card_text, weight, mood in seg["cards"]:
            words = len(card_text.split())
            if words > 5:
                raise ValueError(f"FATAL: Card '{card_text}' exceeds 5 words ({words} words) in segment {seg['id']}")

    print("✓ All subtitle cards strictly <= 5 words verified.")

    # 2. Check that all segment WAVs exist
    sample_rate = 24000
    seg_audio_map = {}
    for seg in SEGMENTS_CONFIG:
        seg_file = os.path.join(SEGMENTS_DIR, f"{seg['id']}.wav")
        if not os.path.exists(seg_file):
            raise FileNotFoundError(f"Segment WAV not found: {seg_file}")
        data, sr = sf.read(seg_file)
        if sr != sample_rate:
            raise ValueError(f"Sample rate mismatch: {sr} != {sample_rate}")
        seg_audio_map[seg["id"]] = data

    print(f"✓ All {len(SEGMENTS_CONFIG)} segment WAVs successfully loaded.")

    # 3. Assemble master audio and compute timing
    master_chunks = []
    current_time = 0.0

    beat_timings = {b: {"start": 999999.0, "end": 0.0, "segments": []} for b in range(1, 11)}
    timeline_segments = []
    all_subtitles = []

    for seg in SEGMENTS_CONFIG:
        seg_id = seg["id"]
        data = seg_audio_map[seg_id]
        dur = len(data) / float(sample_rate)
        seg_start = current_time
        seg_end = seg_start + dur

        beat_idx = seg["beat"]
        beat_timings[beat_idx]["start"] = min(beat_timings[beat_idx]["start"], seg_start)
        beat_timings[beat_idx]["end"] = max(beat_timings[beat_idx]["end"], seg_end + seg["pause_after"])
        beat_timings[beat_idx]["segments"].append(seg_id)

        # Generate subtitle cards for this segment
        card_start = seg_start
        for card_text, weight, mood in seg["cards"]:
            card_dur = dur * weight
            card_end = card_start + card_dur
            all_subtitles.append({
                "segment": seg_id,
                "beat": beat_idx,
                "text": card_text,
                "start": round(card_start, 3),
                "end": round(card_end, 3),
                "mood": mood
            })
            card_start = card_end

        timeline_segments.append({
            "id": seg_id,
            "beat": beat_idx,
            "text": seg["text"],
            "start": round(seg_start, 3),
            "end": round(seg_end, 3),
            "duration": round(dur, 3),
            "pause_after": seg["pause_after"]
        })

        master_chunks.append(data)
        current_time = seg_end

        # Pause
        pause_samples = int(seg["pause_after"] * sample_rate)
        if pause_samples > 0:
            master_chunks.append(np.zeros(pause_samples, dtype=np.float32))
            current_time += seg["pause_after"]

    full_master_audio = np.concatenate(master_chunks)
    total_duration = len(full_master_audio) / float(sample_rate)

    master_wav_path = os.path.join(AUDIO_DIR, "EP07_voice.wav")
    sf.write(master_wav_path, full_master_audio, sample_rate, subtype="PCM_16")

    # Round beat timings
    formatted_beats = {}
    for b in range(1, 11):
        formatted_beats[b] = {
            "beat": b,
            "start": round(beat_timings[b]["start"], 3),
            "end": round(beat_timings[b]["end"], 3),
            "duration": round(beat_timings[b]["end"] - beat_timings[b]["start"], 3),
            "segments": beat_timings[b]["segments"]
        }

    # 4. Save timing manifests
    timing_manifest = {
        "episode_id": "ep07_zero_marks",
        "title": "I GOT 0 MARKS IN MY EXAM",
        "voice": "sohee",
        "total_duration": round(total_duration, 3),
        "total_segments": len(timeline_segments),
        "beats": formatted_beats,
        "segments": timeline_segments
    }

    timing_json_path = os.path.join(TIMING_DIR, "ep07_timing.json")
    with open(timing_json_path, "w", encoding="utf-8") as f:
        json.dump(timing_manifest, f, indent=2)

    alignment_json_path = os.path.join(TIMING_DIR, "voice_alignment.json")
    with open(alignment_json_path, "w", encoding="utf-8") as f:
        json.dump({"subtitles": all_subtitles}, f, indent=2)

    # 5. Generate Episode07Subtitles.gd
    subtitles_gd_path = os.path.join(EP07_DIR, "Episode07Subtitles.gd")
    gd_lines = [
        "class_name Episode07Subtitles",
        "extends RefCounted",
        "",
        '## Autogenerated Subtitles for Episode 07: "I GOT 0 MARKS IN MY EXAM"',
        "## Hard constraint: Strictly <= 5 words per card (100% verified)",
        f"## Total Cards: {len(all_subtitles)}",
        f"## Total Duration: {total_duration:.2f}s",
        "",
        "const SUBTITLES: Array[Dictionary] = ["
    ]

    for c in all_subtitles:
        esc_text = c['text'].replace('"', '\\"')
        gd_lines.append(f'\t{{"beat": {c["beat"]}, "start": {c["start"]:.3f}, "end": {c["end"]:.3f}, "text": "{esc_text}", "mood": "{c["mood"]}"}},')

    gd_lines.append("]")
    gd_lines.append("")
    gd_lines.append("static func get_cards_for_beat(beat_num: int) -> Array[Dictionary]:")
    gd_lines.append("\tvar result: Array[Dictionary] = []")
    gd_lines.append("\tfor c in SUBTITLES:")
    gd_lines.append("\t\tif c.get(\"beat\", 0) == beat_num:")
    gd_lines.append("\t\t\tresult.append(c)")
    gd_lines.append("\treturn result")
    gd_lines.append("")
    gd_lines.append("static func get_total_duration() -> float:")
    gd_lines.append(f"\treturn {total_duration:.3f}")
    gd_lines.append("")

    with open(subtitles_gd_path, "w", encoding="utf-8") as f:
        f.write("\n".join(gd_lines))

    print(f"✓ Master Audio: {master_wav_path} ({total_duration:.2f}s)")
    print(f"✓ Timing Manifest: {timing_json_path}")
    print(f"✓ Voice Alignment: {alignment_json_path}")
    print(f"✓ Subtitles Script: {subtitles_gd_path} ({len(all_subtitles)} cards)")
    print("\nBeat Breakdown:")
    for b in range(1, 11):
        info = formatted_beats[b]
        print(f"  Beat {b:02d}: {info['start']:6.2f}s -> {info['end']:6.2f}s (dur: {info['duration']:5.2f}s) [{len(info['segments'])} segments]")

if __name__ == "__main__":
    main()
