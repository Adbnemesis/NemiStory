#!/usr/bin/env python3
"""
process_ep06_audio_timing.py
Processes EP06 voice segments:
1. Reads all 17 synthesized segments from audio/segments/
2. Assembles master audio EP06_voice.wav with calibrated storytelling pauses
3. Calculates exact beat boundaries (Beats 1 through 10)
4. Generates Episode06Subtitles.gd ensuring strictly <= 5 words per subtitle card
5. Generates timing/ep06_timing.json and timing/voice_alignment.json
"""

import os
import sys
import json
import numpy as np
import soundfile as sf
import shutil

EP06_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO_DIR = os.path.join(EP06_DIR, "audio")
SEGMENTS_DIR = os.path.join(AUDIO_DIR, "segments")
TIMING_DIR = os.path.join(EP06_DIR, "timing")

SEGMENTS_CONFIG = [
    # Beat 1: The Question (Hook)
    {
        "id": "seg01_people_asking",
        "beat": 1,
        "pause_after": 0.35,
        "text": "People keep asking how I actually make these animations. Like... do they just magically pop out of my laptop?",
        "cards": [
            ("People keep asking", 0.17, "candid"),
            ("how I actually make", 0.18, "candid"),
            ("these animations.", 0.16, "normal"),
            ("Like... do they", 0.14, "confused"),
            ("just magically pop out", 0.18, "confused"),
            ("of my laptop?", 0.17, "confused")
        ]
    },
    {
        "id": "seg02_honestly_i_wish",
        "beat": 1,
        "pause_after": 0.45,
        "text": "Honestly? I wish. But here's what actually happens.",
        "cards": [
            ("Honestly? I wish.", 0.38, "sheepish"),
            ("But here's what", 0.30, "candid"),
            ("actually happens.", 0.32, "normal")
        ]
    },

    # Beat 2: The Real-Life Spark
    {
        "id": "seg03_step_one_stupid",
        "beat": 2,
        "pause_after": 0.35,
        "text": "Step one: something stupid has to happen to me in real life. Usually last week, or yesterday.",
        "cards": [
            ("Step one:", 0.16, "candid"),
            ("something stupid has to", 0.24, "candid"),
            ("happen in real life.", 0.22, "normal"),
            ("Usually last week,", 0.20, "sheepish"),
            ("or yesterday.", 0.18, "sheepish")
        ]
    },
    {
        "id": "seg04_suddenly_brain_goes",
        "beat": 2,
        "pause_after": 0.50,
        "text": "I'll be standing there, and suddenly my brain goes... wait. This could be hilarious.",
        "cards": [
            ("I'll be standing there,", 0.28, "normal"),
            ("and suddenly my brain", 0.26, "wonder"),
            ("goes... wait.", 0.20, "shock"),
            ("This could be hilarious.", 0.26, "excited")
        ]
    },

    # Beat 3: The Script & The Notebook
    {
        "id": "seg05_then_comes_notebook",
        "beat": 3,
        "pause_after": 0.35,
        "text": "Then comes the notebook. I sit down and write what actually happened, what made it funny, and cross out all the boring parts.",
        "cards": [
            ("Then comes the notebook.", 0.20, "normal"),
            ("I sit down and", 0.15, "normal"),
            ("write what actually happened,", 0.22, "candid"),
            ("what made it funny,", 0.18, "excited"),
            ("and cross out", 0.11, "candid"),
            ("all the boring parts.", 0.14, "candid")
        ]
    },
    {
        "id": "seg06_cross_out_boring",
        "beat": 3,
        "pause_after": 0.45,
        "text": "If it doesn't make me laugh out loud at my desk, it gets crossed out.",
        "cards": [
            ("If it doesn't", 0.22, "candid"),
            ("make me laugh out", 0.26, "excited"),
            ("loud at my desk,", 0.26, "excited"),
            ("it gets crossed out.", 0.26, "deadpan")
        ]
    },

    # Beat 4: Recording The Voice
    {
        "id": "seg07_next_is_voice",
        "beat": 4,
        "pause_after": 0.50,
        "text": "Next is the voice. The voice is the absolute backbone of everything. I record it, listen back, and that audio becomes the master clock.",
        "cards": [
            ("Next is the voice.", 0.15, "normal"),
            ("The voice is the", 0.14, "candid"),
            ("absolute backbone of everything.", 0.22, "wonder"),
            ("I record it,", 0.12, "normal"),
            ("listen back,", 0.11, "normal"),
            ("and that audio becomes", 0.13, "candid"),
            ("the master clock.", 0.13, "wonder")
        ]
    },

    # Beat 5: Storytelling Beats (The Timeline)
    {
        "id": "seg08_storytelling_beats",
        "beat": 5,
        "pause_after": 0.45,
        "text": "Then I don't just animate sentences. I break the voice into storytelling beats. Explain, reaction, joke, pause, cutaway.",
        "cards": [
            ("Then I don't just", 0.18, "candid"),
            ("animate sentences.", 0.15, "normal"),
            ("I break the voice", 0.18, "candid"),
            ("into storytelling beats.", 0.17, "wonder"),
            ("Explain, reaction,", 0.16, "excited"),
            ("joke, pause, cutaway.", 0.16, "excited")
        ]
    },

    # Beat 6: Why Beats Matter
    {
        "id": "seg09_secret_explain",
        "beat": 6,
        "pause_after": 0.30,
        "text": "Because here's the secret: animation has to follow the beat. Over here, I'm calmly explaining something.",
        "cards": [
            ("Because here's the secret:", 0.24, "wonder"),
            ("animation has to follow", 0.24, "candid"),
            ("the beat.", 0.14, "candid"),
            ("Over here, I'm", 0.18, "normal"),
            ("calmly explaining something.", 0.20, "normal")
        ]
    },
    {
        "id": "seg10_joke_lands_deadpan",
        "beat": 6,
        "pause_after": 1.20, # Comedic freeze
        "text": "And then... this is where the joke lands.",
        "cards": [
            ("And then...", 0.32, "wonder"),
            ("this is where the", 0.34, "deadpan"),
            ("joke lands.", 0.34, "deadpan")
        ]
    },

    # Beat 7: Godot Animation & The Timeline Scare
    {
        "id": "seg11_open_godot",
        "beat": 7,
        "pause_after": 0.35,
        "text": "Then I open Godot to animate. I tell myself, 'Oh, this will be so simple and fast!'",
        "cards": [
            ("Then I open Godot", 0.22, "normal"),
            ("to animate.", 0.16, "normal"),
            ("I tell myself,", 0.18, "candid"),
            ("'Oh, this will be", 0.22, "excited"),
            ("so simple and fast!'", 0.22, "excited")
        ]
    },
    {
        "id": "seg12_forty_tracks_dread",
        "beat": 7,
        "pause_after": 0.50,
        "text": "And then I see forty keyframe tracks. And my soul briefly leaves my body.",
        "cards": [
            ("And then I see", 0.24, "shock"),
            ("forty keyframe tracks.", 0.26, "shock"),
            ("And my soul briefly", 0.24, "deadpan"),
            ("leaves my body.", 0.26, "deadpan")
        ]
    },

    # Beat 8: Props, Doodles & Handwriting
    {
        "id": "seg13_props_and_doodles",
        "beat": 8,
        "pause_after": 0.45,
        "text": "Next come the hand-drawn props, the doodles, and handwritten notes. Every stroke is drawn by hand so the whole world feels alive.",
        "cards": [
            ("Next come the hand-drawn", 0.17, "candid"),
            ("props, the doodles,", 0.16, "wonder"),
            ("and handwritten notes.", 0.16, "wonder"),
            ("Every stroke is drawn", 0.17, "normal"),
            ("by hand so the", 0.17, "normal"),
            ("whole world feels alive.", 0.17, "excited")
        ]
    },

    # Beat 9: The Microscopic Fix
    {
        "id": "seg14_watch_fifty_times",
        "beat": 9,
        "pause_after": 0.35,
        "text": "Then I watch it fifty times to polish the timing. Everything looks fine... until I notice one tiny hair pixel jittering.",
        "cards": [
            ("Then I watch it", 0.16, "normal"),
            ("fifty times to polish", 0.20, "normal"),
            ("the timing.", 0.12, "normal"),
            ("Everything looks fine...", 0.18, "sheepish"),
            ("until I notice one", 0.16, "shock"),
            ("tiny hair pixel jittering.", 0.18, "shock")
        ]
    },
    {
        "id": "seg15_zoom_in_no",
        "beat": 9,
        "pause_after": 0.55,
        "text": "Zoom in. No. Unacceptable. Fix it immediately.",
        "cards": [
            ("Zoom in.", 0.25, "deadpan"),
            ("No.", 0.20, "shock"),
            ("Unacceptable.", 0.25, "shock"),
            ("Fix it immediately.", 0.30, "deadpan")
        ]
    },

    # Beat 10: Final Render & Outro
    {
        "id": "seg16_final_render_renders",
        "beat": 10,
        "pause_after": 0.35,
        "text": "And finally... after hours of tweaking lip sync and sound effects, the episode renders. So the next time you watch one of these...",
        "cards": [
            ("And finally... after hours", 0.20, "normal"),
            ("of tweaking lip sync", 0.18, "candid"),
            ("and sound effects,", 0.17, "normal"),
            ("the episode renders.", 0.16, "wonder"),
            ("So the next time", 0.14, "candid"),
            ("you watch one of", 0.11, "candid"),
            ("these...", 0.04, "candid")
        ]
    },
    {
        "id": "seg17_not_magic_journey",
        "beat": 10,
        "pause_after": 0.60,
        "text": "Now you know: it didn't just magically appear. It was an entire journey. See you in the next story!",
        "cards": [
            ("Now you know:", 0.18, "wonder"),
            ("it didn't just", 0.16, "candid"),
            ("magically appear.", 0.18, "candid"),
            ("It was an entire", 0.18, "wonder"),
            ("journey.", 0.10, "wonder"),
            ("See you in the", 0.10, "excited"),
            ("next story!", 0.10, "excited")
        ]
    }
]

def main():
    print("============================================================")
    print("  PROCESSING EP06 AUDIO & TIMING METADATA")
    print("============================================================")

    # 1. Verify all segment files exist
    segment_files = []
    sample_rate = 24000
    for seg in SEGMENTS_CONFIG:
        wav_file = os.path.join(SEGMENTS_DIR, f"{seg['id']}.wav")
        if not os.path.exists(wav_file):
            print(f"Error: Segment file not found: {wav_file}")
            sys.exit(1)
        data, sr = sf.read(wav_file)
        sample_rate = sr
        duration = len(data) / float(sr)
        segment_files.append((seg, data, duration))
        print(f"  ✓ {seg['id']}.wav: {duration:.2f}s")

    # 2. Build master audio track and compute accurate timestamps
    master_chunks = []
    current_time = 0.0
    all_subtitle_cards = []
    beat_ranges = {}
    speech_intervals = []

    for seg, data, duration in segment_files:
        beat_idx = seg["beat"]
        if beat_idx not in beat_ranges:
            beat_ranges[beat_idx] = {"start": current_time, "end": current_time}

        seg_start = current_time
        seg_end = current_time + duration
        speech_intervals.append((round(seg_start, 3), round(seg_end, 3)))

        # Subtitle cards calculation
        cards_def = seg["cards"]
        card_start = seg_start
        for text, frac, mood in cards_def:
            card_dur = duration * frac
            card_end = card_start + card_dur
            card_obj = {
                "text": text,
                "start": round(card_start, 3),
                "end": round(card_end, 3),
                "duration": round(card_dur, 3),
                "mood": mood,
                "beat": beat_idx
            }
            all_subtitle_cards.append(card_obj)
            card_start = card_end

        master_chunks.append(data)
        current_time = seg_end
        beat_ranges[beat_idx]["end"] = current_time

        # Pause after segment
        pause = seg["pause_after"]
        if pause > 0:
            pause_samples = int(pause * sample_rate)
            master_chunks.append(np.zeros(pause_samples, dtype=np.float32))
            current_time += pause
            beat_ranges[beat_idx]["end"] = current_time

    # Final padding so audio ends smoothly
    end_padding = int(0.5 * sample_rate)
    master_chunks.append(np.zeros(end_padding, dtype=np.float32))
    current_time += 0.5
    beat_ranges[10]["end"] = current_time

    full_master = np.concatenate(master_chunks)
    total_dur = len(full_master) / float(sample_rate)

    master_wav_path = os.path.join(AUDIO_DIR, "EP06_voice.wav")
    sf.write(master_wav_path, full_master, sample_rate, subtype="PCM_16")
    print(f"\n  ✓ Master Audio assembled: {master_wav_path} ({total_dur:.2f}s)")

    # 3. Subtitle Word Count Audit
    print("\n------------------------------------------------------------")
    print("  AUDITING SUBTITLE CARDS (Strict <= 5 words per card)")
    print("------------------------------------------------------------")
    max_words = 0
    violations = []
    for c in all_subtitle_cards:
        wc = len(c["text"].split())
        if wc > max_words:
            max_words = wc
        if wc > 5:
            violations.append((c["text"], wc))

    print(f"  Total cards: {len(all_subtitle_cards)}")
    print(f"  Max word count: {max_words}")
    if violations:
        print(f"  ❌ FAILED: {len(violations)} subtitle cards exceed 5 words!")
        for v in violations:
            print(f"     - '{v[0]}' ({v[1]} words)")
        sys.exit(1)
    else:
        print(f"  ✓ PASSED: All {len(all_subtitle_cards)} cards have <= 5 words.")

    # 4. Generate Episode06Subtitles.gd
    subtitles_gd_path = os.path.join(EP06_DIR, "Episode06Subtitles.gd")
    with open(subtitles_gd_path, "w", encoding="utf-8") as f:
        f.write('class_name Episode06Subtitles\n')
        f.write('extends RefCounted\n\n')
        f.write('## Episode 06 Subtitle Manifest: "HOW I ACTUALLY MAKE STORYTIME ANIMATIONS"\n')
        f.write('## Generated deterministically from calibrated audio timestamps.\n')
        f.write('## HARD CONSTRAINT: Every card <= 5 words.\n\n')
        f.write('const CARDS: Array[Dictionary] = [\n')
        for i, c in enumerate(all_subtitle_cards):
            comma = "," if i < len(all_subtitle_cards) - 1 else ""
            f.write(f'\t{{"text": "{c["text"]}", "start": {c["start"]:.3f}, "end": {c["end"]:.3f}, "beat": {c["beat"]}, "mood": "{c["mood"]}"}}{comma}\n')
        f.write(']\n\n')
        f.write('static func get_card_at_time(time_sec: float) -> Dictionary:\n')
        f.write('\tfor card in CARDS:\n')
        f.write('\t\tif time_sec >= card["start"] and time_sec < card["end"]:\n')
        f.write('\t\t\treturn card\n')
        f.write('\treturn {}\n\n')
        f.write('static func get_cards_for_beat(beat_idx: int) -> Array[Dictionary]:\n')
        f.write('\tvar result: Array[Dictionary] = []\n')
        f.write('\tfor card in CARDS:\n')
        f.write('\t\tif card["beat"] == beat_idx:\n')
        f.write('\t\t\tresult.append(card)\n')
        f.write('\treturn result\n')

    print(f"  ✓ Written: {subtitles_gd_path}")

    # 5. Generate ep06_timing.json and voice_alignment.json
    timing_manifest = {
        "episode_id": "ep06_how_i_animate",
        "title": "HOW I ACTUALLY MAKE STORYTIME ANIMATIONS",
        "total_duration": round(total_dur, 3),
        "beats": []
    }

    for b_idx in range(1, 11):
        b_data = beat_ranges[b_idx]
        b_dur = b_data["end"] - b_data["start"]
        timing_manifest["beats"].append({
            "beat": b_idx,
            "start": round(b_data["start"], 3),
            "end": round(b_data["end"], 3),
            "duration": round(b_dur, 3)
        })

    timing_json_path = os.path.join(TIMING_DIR, "ep06_timing.json")
    with open(timing_json_path, "w", encoding="utf-8") as f:
        json.dump(timing_manifest, f, indent=2)

    alignment_manifest = {
        "episode_id": "ep06_how_i_animate",
        "voice": "sohee",
        "total_duration": round(total_dur, 3),
        "speech_active_intervals": speech_intervals,
        "cards": all_subtitle_cards
    }
    alignment_json_path = os.path.join(TIMING_DIR, "voice_alignment.json")
    with open(alignment_json_path, "w", encoding="utf-8") as f:
        json.dump(alignment_manifest, f, indent=2)

    print(f"  ✓ Written: {timing_json_path}")
    print(f"  ✓ Written: {alignment_json_path}")

    print("\n------------------------------------------------------------")
    print("  BEAT TIMELINE BREAKDOWN:")
    print("------------------------------------------------------------")
    for b in timing_manifest["beats"]:
        print(f"  Beat {b['beat']:02d}: {b['start']:6.2f}s -> {b['end']:6.2f}s ({b['duration']:5.2f}s)")
    print(f"  TOTAL EPISODE DURATION: {total_dur:.2f}s")
    print("============================================================")

if __name__ == "__main__":
    main()
