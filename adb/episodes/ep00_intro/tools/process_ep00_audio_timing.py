#!/usr/bin/env python3
"""
process_ep00_audio_timing.py
Processes ADB EP00 voice segments:
1. Validates and loads all 40 synthesized segments from audio/segments/
2. Assembles master audio ADB_Intro_voice.wav with exact storytelling pauses
3. Calculates exact beat boundaries (Beats 1 through 10)
4. Generates Episode00Subtitles.gd ensuring strictly <= 5 words per subtitle card
5. Generates timing/ep00_timing.json and timing/voice_alignment.json
"""

import os
import sys
import json
import numpy as np
import soundfile as sf

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO_DIR = os.path.join(BASE_DIR, "audio")
SEGMENTS_DIR = os.path.join(AUDIO_DIR, "segments")
TIMING_DIR = os.path.join(BASE_DIR, "timing")

SEGMENTS_CONFIG = [
    # Beat 1: The Pushed Hook
    {
        "id": "seg01_wait_hold_on",
        "beat": 1,
        "pause_after": 0.25,
        "text": "Wait—hold on—",
        "cards": [
            ("Wait, hold on...", 1.0, "reluctant")
        ]
    },
    {
        "id": "seg02_okay_im_here",
        "beat": 1,
        "pause_after": 0.30,
        "text": "Okay, okay! I'm here.",
        "cards": [
            ("Okay, okay!", 0.50, "amused"),
            ("I'm here.", 0.50, "normal")
        ]
    },
    {
        "id": "seg03_hi_im_adb",
        "beat": 1,
        "pause_after": 0.30,
        "text": "Hi. I'm ADB.",
        "cards": [
            ("Hi. I'm ADB.", 1.0, "normal")
        ]
    },

    # Beat 2: First Intro & The Confession
    {
        "id": "seg04_im_24",
        "beat": 2,
        "pause_after": 0.25,
        "text": "I'm 24...",
        "cards": [
            ("I'm 24...", 1.0, "normal")
        ]
    },
    {
        "id": "seg05_making_animations_now",
        "beat": 2,
        "pause_after": 0.45,
        "text": "...and apparently, I'm making storytime animations now.",
        "cards": [
            ("...and apparently,", 0.35, "wry"),
            ("I'm making storytime", 0.35, "wry"),
            ("animations now.", 0.30, "wry")
        ]
    },
    {
        "id": "seg06_which_is_interesting",
        "beat": 2,
        "pause_after": 0.35,
        "text": "Which is interesting...",
        "cards": [
            ("Which is interesting...", 1.0, "thoughtful")
        ]
    },
    {
        "id": "seg07_no_idea_what_im_doing",
        "beat": 2,
        "pause_after": 0.50,
        "text": "...because I have absolutely no idea what I'm doing.",
        "cards": [
            ("...because I have", 0.35, "deadpan"),
            ("absolutely no idea", 0.35, "deadpan"),
            ("what I'm doing.", 0.30, "deadpan")
        ]
    },

    # Beat 3: National-Level Table Tennis Past
    {
        "id": "seg08_life_was_normal",
        "beat": 3,
        "pause_after": 0.25,
        "text": "Now, before this, my life was pretty normal.",
        "cards": [
            ("Now, before this,", 0.45, "normal"),
            ("my life was", 0.25, "normal"),
            ("pretty normal.", 0.30, "normal")
        ]
    },
    {
        "id": "seg09_used_to_play_sports",
        "beat": 3,
        "pause_after": 0.25,
        "text": "A lot of people don't know this, but I used to play sports.",
        "cards": [
            ("A lot of people", 0.32, "normal"),
            ("don't know this,", 0.28, "normal"),
            ("but I used to", 0.22, "normal"),
            ("play sports.", 0.18, "normal")
        ]
    },
    {
        "id": "seg10_table_tennis_national",
        "beat": 3,
        "pause_after": 0.40,
        "text": "Specifically... table tennis. At the national level.",
        "cards": [
            ("Specifically...", 0.30, "dramatic"),
            ("table tennis.", 0.35, "serious"),
            ("At the national level.", 0.35, "proud")
        ]
    },
    {
        "id": "seg11_yes_it_was_intense",
        "beat": 3,
        "pause_after": 0.30,
        "text": "And yes, it was intense.",
        "cards": [
            ("And yes,", 0.40, "intense"),
            ("it was intense.", 0.60, "intense")
        ]
    },
    {
        "id": "seg12_spinning_balls_rallies",
        "beat": 3,
        "pause_after": 0.35,
        "text": "Spinning balls, lightning rallies, extreme tournament focus.",
        "cards": [
            ("Spinning balls,", 0.33, "intense"),
            ("lightning rallies,", 0.33, "intense"),
            ("extreme tournament focus.", 0.34, "intense")
        ]
    },
    {
        "id": "seg13_retired_paddle",
        "beat": 3,
        "pause_after": 0.45,
        "text": "Then I grew up... and retired my paddle.",
        "cards": [
            ("Then I grew up...", 0.50, "relaxed"),
            ("and retired my paddle.", 0.50, "relaxed")
        ]
    },

    # Beat 4: Sports & Games
    {
        "id": "seg14_still_love_sports_games",
        "beat": 4,
        "pause_after": 0.25,
        "text": "I still love sports, but mostly these days... I play games.",
        "cards": [
            ("I still love sports,", 0.38, "warm"),
            ("but mostly these days...", 0.32, "warm"),
            ("I play games.", 0.30, "warm")
        ]
    },
    {
        "id": "seg15_way_too_many_games",
        "beat": 4,
        "pause_after": 0.30,
        "text": "Like, way too many games.",
        "cards": [
            ("Like, way too", 0.50, "sheepish"),
            ("many games.", 0.50, "sheepish")
        ]
    },
    {
        "id": "seg16_ranked_ladder_sleep",
        "beat": 4,
        "pause_after": 0.45,
        "text": "Competitive shooters, RPGs, strategy... if there's a ranked ladder, I've probably lost sleep over it.",
        "cards": [
            ("Competitive shooters,", 0.25, "excited"),
            ("RPGs, strategy...", 0.22, "excited"),
            ("if there's a ranked ladder,", 0.28, "excited"),
            ("I've probably lost", 0.13, "excited"),
            ("sleep over it.", 0.12, "wry")
        ]
    },

    # Beat 5: The Anime Obsession
    {
        "id": "seg17_then_theres_anime",
        "beat": 5,
        "pause_after": 0.35,
        "text": "And then... there's anime.",
        "cards": [
            ("And then...", 0.50, "dramatic"),
            ("there's anime.", 0.50, "dramatic")
        ]
    },
    {
        "id": "seg18_hundreds_of_anime",
        "beat": 5,
        "pause_after": 0.45,
        "text": "I've watched hundreds of anime.",
        "cards": [
            ("I've watched", 0.40, "deadpan"),
            ("hundreds of anime.", 0.60, "deadpan")
        ]
    },
    {
        "id": "seg19_action_shonen_slice",
        "beat": 5,
        "pause_after": 0.30,
        "text": "Action, shonen, slice of life, psychological thrillers...",
        "cards": [
            ("Action, shonen,", 0.32, "passionate"),
            ("slice of life,", 0.33, "passionate"),
            ("psychological thrillers...", 0.35, "passionate")
        ]
    },
    {
        "id": "seg20_obsession_research",
        "beat": 5,
        "pause_after": 0.50,
        "text": "My friends say it's an obsession. I call it... thorough cultural research.",
        "cards": [
            ("My friends say", 0.24, "wry"),
            ("it's an obsession.", 0.26, "wry"),
            ("I call it...", 0.22, "smug"),
            ("thorough cultural research.", 0.28, "smug")
        ]
    },

    # Beat 6: Regular Gym Routine
    {
        "id": "seg21_gym_regularly",
        "beat": 6,
        "pause_after": 0.25,
        "text": "To balance all that sitting, I go to the gym regularly.",
        "cards": [
            ("To balance all that sitting,", 0.45, "normal"),
            ("I go to the gym", 0.30, "normal"),
            ("regularly.", 0.25, "normal")
        ]
    },
    {
        "id": "seg22_discipline_form",
        "beat": 6,
        "pause_after": 0.30,
        "text": "Discipline. Form. Progressive overload.",
        "cards": [
            ("Discipline.", 0.33, "focused"),
            ("Form.", 0.33, "focused"),
            ("Progressive overload.", 0.34, "focused")
        ]
    },
    {
        "id": "seg23_stairs_after_leg_day",
        "beat": 6,
        "pause_after": 0.30,
        "text": "Right up until I try to walk up stairs after leg day.",
        "cards": [
            ("Right up until", 0.30, "wince"),
            ("I try to walk up", 0.35, "wince"),
            ("stairs after leg day.", 0.35, "wince")
        ]
    },
    {
        "id": "seg24_question_life_choices",
        "beat": 6,
        "pause_after": 0.45,
        "text": "Then I question every life choice I've ever made.",
        "cards": [
            ("Then I question", 0.30, "exhausted"),
            ("every life choice", 0.35, "exhausted"),
            ("I've ever made.", 0.35, "exhausted")
        ]
    },

    # Beat 7: Engineering Job
    {
        "id": "seg25_by_the_way",
        "beat": 7,
        "pause_after": 0.25,
        "text": "Oh, and by the way...",
        "cards": [
            ("Oh, and by the way...", 1.0, "normal")
        ]
    },
    {
        "id": "seg26_engineering_job",
        "beat": 7,
        "pause_after": 0.45,
        "text": "I also have an engineering job.",
        "cards": [
            ("I also have", 0.40, "serious"),
            ("an engineering job.", 0.60, "serious")
        ]
    },
    {
        "id": "seg27_wasnt_enough_work",
        "beat": 7,
        "pause_after": 0.50,
        "text": "And apparently... that wasn't enough work for one human being.",
        "cards": [
            ("And apparently...", 0.28, "deadpan"),
            ("that wasn't enough work", 0.42, "deadpan"),
            ("for one human being.", 0.30, "deadpan")
        ]
    },

    # Beat 8: Adding Storytime Animation
    {
        "id": "seg28_looked_at_schedule",
        "beat": 8,
        "pause_after": 0.30,
        "text": "Because recently, I looked at my schedule: engineering, gym, sports, games, anime...",
        "cards": [
            ("Because recently,", 0.24, "rapid"),
            ("I looked at my schedule:", 0.32, "rapid"),
            ("engineering, gym,", 0.22, "rapid"),
            ("sports, games, anime...", 0.22, "rapid")
        ]
    },
    {
        "id": "seg29_what_would_fit",
        "beat": 8,
        "pause_after": 0.35,
        "text": "And I thought... 'You know what would fit perfectly into this?'",
        "cards": [
            ("And I thought...", 0.35, "sarcastic"),
            ("'You know what would fit", 0.35, "sarcastic"),
            ("perfectly into this?'", 0.30, "sarcastic")
        ]
    },
    {
        "id": "seg30_thousands_of_frames",
        "beat": 8,
        "pause_after": 0.40,
        "text": "'Thousands of hand-drawn animation frames.'",
        "cards": [
            ("'Thousands of hand-drawn", 0.50, "unhinged"),
            ("animation frames.'", 0.50, "unhinged")
        ]
    },
    {
        "id": "seg31_great_deadpan",
        "beat": 8,
        "pause_after": 0.50,
        "text": "Great.",
        "cards": [
            ("Great.", 1.0, "deadpan")
        ]
    },

    # Beat 9: Mysterious Girlfriend Help
    {
        "id": "seg32_not_completely_alone",
        "beat": 9,
        "pause_after": 0.30,
        "text": "Now, to be fair... I'm not doing this completely alone.",
        "cards": [
            ("Now, to be fair...", 0.42, "honest"),
            ("I'm not doing this", 0.30, "honest"),
            ("completely alone.", 0.28, "honest")
        ]
    },
    {
        "id": "seg33_girlfriend_help",
        "beat": 9,
        "pause_after": 0.35,
        "text": "I'm getting some help from my girlfriend.",
        "cards": [
            ("I'm getting some help", 0.50, "affectionate"),
            ("from my girlfriend.", 0.50, "affectionate")
        ]
    },
    {
        "id": "seg34_a_lot_of_help",
        "beat": 9,
        "pause_after": 0.45,
        "text": "...A LOT of help.",
        "cards": [
            ("...A LOT of help.", 1.0, "flustered")
        ]
    },
    {
        "id": "seg35_not_look_like_potato",
        "beat": 9,
        "pause_after": 0.45,
        "text": "She basically made sure my character didn't look like a potato.",
        "cards": [
            ("She basically made sure", 0.35, "fond"),
            ("my character didn't", 0.30, "fond"),
            ("look like a potato.", 0.35, "fond")
        ]
    },

    # Beat 10: Outro & The Final Shove
    {
        "id": "seg36_thats_me_im_adb",
        "beat": 10,
        "pause_after": 0.30,
        "text": "So... that's me. I'm ADB.",
        "cards": [
            ("So... that's me.", 0.50, "warm"),
            ("I'm ADB.", 0.50, "warm")
        ]
    },
    {
        "id": "seg37_animator_now",
        "beat": 10,
        "pause_after": 0.40,
        "text": "And apparently... I'm a storytime animator now.",
        "cards": [
            ("And apparently...", 0.40, "relaxed"),
            ("I'm a storytime", 0.30, "relaxed"),
            ("animator now.", 0.30, "relaxed")
        ]
    },
    {
        "id": "seg38_tell_some_stories",
        "beat": 10,
        "pause_after": 0.35,
        "text": "We're going to tell some stories, laugh at bad decisions, and see what happens.",
        "cards": [
            ("We're going to tell", 0.30, "welcoming"),
            ("some stories,", 0.22, "welcoming"),
            ("laugh at bad decisions,", 0.26, "welcoming"),
            ("and see what happens.", 0.22, "welcoming")
        ]
    },
    {
        "id": "seg39_thanks_for_watching",
        "beat": 10,
        "pause_after": 0.20,
        "text": "Thanks for watching, and I'll—",
        "cards": [
            ("Thanks for watching,", 0.55, "outro"),
            ("and I'll—", 0.45, "interrupted")
        ]
    },
    {
        "id": "seg40_let_me_do_the_intro",
        "beat": 10,
        "pause_after": 0.40,
        "text": "Okay! LET ME DO THE INTRO!",
        "cards": [
            ("Okay!", 0.25, "indignant"),
            ("LET ME DO", 0.38, "indignant"),
            ("THE INTRO!", 0.37, "indignant")
        ]
    }
]

def main():
    print("============================================================")
    print("ADB EP00 AUDIO & TIMING PROCESSOR: \"HI, I'M ADB.\"")
    print("============================================================")

    # 1. Strict validation: Every card must be <= 5 words
    violations = []
    max_words = 0
    total_cards = 0
    for seg in SEGMENTS_CONFIG:
        for card_text, weight, mood in seg["cards"]:
            words = len(card_text.split())
            total_cards += 1
            if words > max_words:
                max_words = words
            if words > 5:
                violations.append((card_text, words, seg["id"]))

    if violations:
        print(f"❌ FATAL: Found {len(violations)} subtitle cards exceeding 5 words!")
        for v in violations:
            print(f"   - '{v[0]}' ({v[1]} words) in {v[2]}")
        sys.exit(1)

    print(f"✓ All {total_cards} subtitle cards strictly <= 5 words! (Peak words per card: {max_words})")

    # 2. Check that all segment WAV files exist
    sample_rate = 24000
    seg_audio_map = {}
    for seg in SEGMENTS_CONFIG:
        seg_file = os.path.join(SEGMENTS_DIR, f"{seg['id']}.wav")
        if not os.path.exists(seg_file):
            print(f"❌ Segment WAV not found: {seg_file}")
            sys.exit(1)
        data, sr = sf.read(seg_file)
        if sr != sample_rate:
            raise ValueError(f"Sample rate mismatch: {sr} != {sample_rate}")
        if data.ndim > 1:
            data = data.mean(axis=-1)
        seg_audio_map[seg["id"]] = data.astype(np.float32)

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

        # Generate subtitle cards
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

        # Pause silence
        pause_samples = int(seg["pause_after"] * sample_rate)
        if pause_samples > 0:
            master_chunks.append(np.zeros(pause_samples, dtype=np.float32))
            current_time += seg["pause_after"]

    full_master_audio = np.concatenate(master_chunks)
    total_duration = len(full_master_audio) / float(sample_rate)

    # Normalize audio to -2.5 dB True Peak
    peak = np.max(np.abs(full_master_audio))
    target_peak = 10.0 ** (-2.5 / 20.0) # ~0.7499
    if peak > 0.001:
        full_master_audio = full_master_audio * (target_peak / peak)

    master_wav_path = os.path.join(AUDIO_DIR, "ADB_Intro_voice.wav")
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
        "episode_id": "adb_ep00_intro",
        "title": "HI, I'M ADB.",
        "voice": "aiden",
        "total_duration": round(total_duration, 3),
        "total_segments": len(timeline_segments),
        "beats": formatted_beats,
        "segments": timeline_segments
    }

    timing_json_path = os.path.join(TIMING_DIR, "ep00_timing.json")
    with open(timing_json_path, "w", encoding="utf-8") as f:
        json.dump(timing_manifest, f, indent=2)

    alignment_json_path = os.path.join(TIMING_DIR, "voice_alignment.json")
    with open(alignment_json_path, "w", encoding="utf-8") as f:
        json.dump({"subtitles": all_subtitles}, f, indent=2)

    # 5. Generate Episode00Subtitles.gd
    subtitles_gd_path = os.path.join(BASE_DIR, "Episode00Subtitles.gd")
    gd_lines = [
        "class_name Episode00Subtitles",
        "extends RefCounted",
        "",
        '## Autogenerated Subtitles for ADB Episode 00: "HI, I\'M ADB."',
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

    print(f"✓ Master Audio: {master_wav_path} ({total_duration:.2f}s, {int(total_duration//60)}m {int(total_duration%60):02d}s)")
    print(f"✓ Timing Manifest: {timing_json_path}")
    print(f"✓ Voice Alignment: {alignment_json_path}")
    print(f"✓ Subtitles Script: {subtitles_gd_path} ({len(all_subtitles)} cards)")
    print("\nBeat Breakdown:")
    for b in range(1, 11):
        info = formatted_beats[b]
        print(f"  Beat {b:02d}: {info['start']:6.2f}s -> {info['end']:6.2f}s (dur: {info['duration']:5.2f}s) [{len(info['segments'])} segments]")

if __name__ == "__main__":
    main()
