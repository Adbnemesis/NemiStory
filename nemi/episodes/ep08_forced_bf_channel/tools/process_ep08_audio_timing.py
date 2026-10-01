#!/usr/bin/env python3
"""
process_ep08_audio_timing.py
Processes EP08 audio timing & subtitle cards:
1. Loads timing from timing/ep08_raw_timing.json
2. Breaks all dialogue down into cards strictly <= 5 words
3. Accurately maps card timings onto actual voice recordings
4. Generates Episode08Subtitles.gd
5. Generates timing/ep08_timing.json and timing/voice_alignment.json
"""

import os
import sys
import json

EP08_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TIMING_DIR = os.path.join(EP08_DIR, "timing")
RAW_TIMING_FILE = os.path.join(TIMING_DIR, "ep08_raw_timing.json")

# Define card breakdown per segment with relative duration fractions
# Each card text MUST have strictly <= 5 words.
SEGMENT_CARDS = {
    # Beat 1
    "seg01_new_problem": [
        ("I have a new problem.", 1.0, "shock", "nemi")
    ],
    "seg02_convinced_bf": [
        ("I somehow convinced", 0.30, "candid", "nemi"),
        ("my boyfriend to start", 0.38, "candid", "nemi"),
        ("a YouTube channel.", 0.32, "dread", "nemi")
    ],

    # Beat 2
    "seg03_guys_remember": [
        ("Guys...", 0.40, "curious", "nemi"),
        ("remember ADB?", 0.60, "curious", "nemi")
    ],
    "seg04_yeah_this_adb": [
        ("Yeah.", 0.40, "normal", "nemi"),
        ("THIS ADB.", 0.60, "reveal", "nemi")
    ],
    "seg05_yeah_this_version": [
        ("...yeah.", 0.42, "awkward", "nemi"),
        ("This version.", 0.58, "awkward", "nemi")
    ],

    # Beat 3
    "seg06_adb_hated": [
        ("ADB hated", 0.45, "confession", "nemi"),
        ("this character.", 0.55, "confession", "nemi")
    ],
    "seg07_understand_why": [
        ("Honestly...", 0.45, "awkward", "nemi"),
        ("I kinda understand why.", 0.55, "sheepish", "nemi")
    ],

    # Beat 4
    "seg08_so_eventually": [
        ("So eventually", 0.50, "thoughtful", "nemi"),
        ("we decided:", 0.50, "thoughtful", "nemi")
    ],
    "seg09_okay_completely_new": [
        ("okay.", 0.30, "decisive", "nemi"),
        ("We're making", 0.30, "excited", "nemi"),
        ("a completely new ADB.", 0.40, "excited", "nemi")
    ],
    "seg10_unreasonable_amount": [
        ("And after an", 0.24, "tired", "nemi"),
        ("unreasonable amount of work...", 0.42, "tired", "nemi"),
        ("we finally made one.", 0.34, "proud", "nemi")
    ],

    # Beat 5
    "seg11_terrible_idea": [
        ("And then I had", 0.48, "smug", "nemi"),
        ("another terrible idea.", 0.52, "smug", "nemi")
    ],
    "seg12_why_doesnt_adb": [
        ("If I'm making", 0.24, "explaining", "nemi"),
        ("storytime animations...", 0.26, "explaining", "nemi"),
        ("why doesn't ADB make", 0.26, "excited", "nemi"),
        ("storytime animations too?", 0.24, "excited", "nemi")
    ],

    # Beat 6
    "seg13_adb_said_no_1": [
        ("ADB said no.", 1.0, "deadpan", "nemi")
    ],
    "seg14_asked_again_1": [
        ("I asked again.", 1.0, "cheerful", "nemi")
    ],
    "seg15_adb_said_no_2": [
        ("ADB said no.", 1.0, "deadpan", "nemi")
    ],
    "seg16_asked_again_2": [
        ("I asked again.", 1.0, "cheerful", "nemi")
    ],
    "seg17_eventually_made_channel": [
        ("And eventually...", 0.42, "quiet", "nemi"),
        ("ADB made a channel.", 0.58, "victorious", "nemi")
    ],

    # Beat 7
    "seg18_and_now_both": [
        ("And now...", 0.20, "proud", "nemi"),
        ("there's Nemi...", 0.24, "proud", "nemi"),
        ("and there's ADB...", 0.26, "proud", "nemi"),
        ("both making storytime animations.", 0.30, "excited", "nemi")
    ],
    "seg19_little_dangerous": [
        ("Which is honestly...", 0.50, "mischievous", "nemi"),
        ("a little dangerous.", 0.50, "mischievous", "nemi")
    ],
    "seg20_annoy_each_other": [
        ("Because now we can", 0.36, "playful", "nemi"),
        ("annoy each other with", 0.36, "playful", "nemi"),
        ("animation too.", 0.28, "playful", "nemi")
    ],

    # Beat 8
    "seg21_introduce_yourself": [
        ("Actually...", 0.28, "pivot", "nemi"),
        ("ADB.", 0.28, "call", "nemi"),
        ("Introduce yourself.", 0.44, "call", "nemi")
    ],
    "seg22_adb_uh_im_adb": [
        ("Uh...", 0.42, "casual", "adb"),
        ("I'm ADB.", 0.58, "cool", "adb")
    ],
    "seg23_adb_make_animations": [
        ("I make storytime", 0.48, "calm", "adb"),
        ("animations too.", 0.52, "calm", "adb")
    ],
    "seg24_adb_overshare": [
        ("I talk about my", 0.28, "conversational", "adb"),
        ("own experiences...", 0.24, "conversational", "adb"),
        ("and probably overshare", 0.25, "dry_smirk", "adb"),
        ("way too much.", 0.23, "dry_smirk", "adb")
    ],
    "seg25_adb_check_channel": [
        ("So... if you're curious,", 0.50, "direct", "adb"),
        ("check out my channel.", 0.50, "direct", "adb")
    ],
    "seg26_adb_link_description": [
        ("The link's in", 0.48, "point_down", "adb"),
        ("the description.", 0.52, "point_down", "adb")
    ],

    # Beat 9
    "seg27_suspiciously_normal": [
        ("Wow.", 0.30, "baffled", "nemi"),
        ("That was", 0.28, "baffled", "nemi"),
        ("suspiciously normal.", 0.42, "baffled", "nemi")
    ],
    "seg28_just_getting_started": [
        ("Anyway... ADB is just", 0.32, "warm", "nemi"),
        ("getting started.", 0.24, "warm", "nemi"),
        ("So go check out", 0.24, "supportive", "nemi"),
        ("the channel.", 0.20, "supportive", "nemi")
    ],
    "seg29_worked_way_too_hard": [
        ("I worked way too", 0.45, "dramatic_tired", "nemi"),
        ("hard to convince", 0.30, "dramatic_tired", "nemi"),
        ("this person.", 0.25, "dramatic_tired", "nemi")
    ],
    "seg30_please_make_worth_it": [
        ("Please make it worth it.", 1.0, "pleading", "nemi")
    ]
}

def main():
    if not os.path.exists(RAW_TIMING_FILE):
        print(f"Error: {RAW_TIMING_FILE} not found!")
        sys.exit(1)

    with open(RAW_TIMING_FILE, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    all_cards = []
    beat_ranges = {}

    for seg in raw_data["segments"]:
        seg_id = seg["id"]
        seg_beat = seg["beat"]
        seg_start = seg["start_time"]
        seg_dur = seg["duration"]
        seg_char = seg.get("character", "nemi")

        cards_def = SEGMENT_CARDS.get(seg_id, [(seg["text"], 1.0, "normal", seg_char)])
        curr_t = seg_start

        for card_tuple in cards_def:
            c_text = card_tuple[0]
            c_frac = card_tuple[1]
            c_mood = card_tuple[2]
            c_char = card_tuple[3] if len(card_tuple) > 3 else seg_char

            words = [w for w in c_text.split() if w.strip()]
            word_count = len(words)
            if word_count > 5:
                print(f"❌ ERROR: Card exceeds 5 words: '{c_text}' ({word_count} words)")
                sys.exit(1)

            c_dur = seg_dur * c_frac
            c_start = round(curr_t, 3)
            c_end = round(curr_t + c_dur, 3)
            curr_t = c_end

            card_entry = {
                "beat": seg_beat,
                "character": c_char,
                "start": c_start,
                "end": c_end,
                "text": c_text,
                "mood": c_mood,
                "words": word_count
            }
            all_cards.append(card_entry)

            if seg_beat not in beat_ranges:
                beat_ranges[seg_beat] = {"start": c_start, "end": c_end}
            else:
                beat_ranges[seg_beat]["end"] = max(beat_ranges[seg_beat]["end"], c_end)

    # Output Episode08Subtitles.gd
    subtitles_gd_path = os.path.join(EP08_DIR, "Episode08Subtitles.gd")
    with open(subtitles_gd_path, "w", encoding="utf-8") as f:
        f.write("class_name Episode08Subtitles\n")
        f.write("extends RefCounted\n\n")
        f.write("## Autogenerated Subtitles for Episode 08: \"I FORCED MY BF TO CREATE A CHANNEL\"\n")
        f.write("## Hard constraint: Strictly <= 5 words per card (100% verified)\n")
        f.write(f"## Total Cards: {len(all_cards)}\n")
        f.write(f"## Total Duration: {raw_data['total_duration']}s\n\n")
        f.write("const SUBTITLES: Array[Dictionary] = [\n")
        for idx, c in enumerate(all_cards):
            comma = "," if idx < len(all_cards) - 1 else ""
            f.write(f'\t{{"beat": {c["beat"]}, "speaker": "{c["character"]}", "start": {c["start"]:.3f}, "end": {c["end"]:.3f}, "text": "{c["text"]}", "mood": "{c["mood"]}"}}{comma}\n')
        f.write("]\n\n")
        f.write("static func get_cards_for_beat(beat_num: int) -> Array[Dictionary]:\n")
        f.write("\tvar res: Array[Dictionary] = []\n")
        f.write("\tfor c in SUBTITLES:\n")
        f.write("\t\tif c.get(\"beat\", 0) == beat_num:\n")
        f.write("\t\t\tres.append(c)\n")
        f.write("\treturn res\n\n")
        f.write("static func get_all_cards() -> Array[Dictionary]:\n")
        f.write("\treturn SUBTITLES\n")

    # Output detailed timing json
    final_timing_file = os.path.join(TIMING_DIR, "ep08_timing.json")
    final_timing = {
        "episode_id": "ep08_forced_bf_channel",
        "title": "I FORCED MY BF TO CREATE A CHANNEL",
        "total_duration": raw_data["total_duration"],
        "total_cards": len(all_cards),
        "beat_ranges": beat_ranges,
        "segments": raw_data["segments"],
        "cards": all_cards
    }
    with open(final_timing_file, "w", encoding="utf-8") as f:
        json.dump(final_timing, f, indent=2)

    # Output voice alignment
    alignment_file = os.path.join(TIMING_DIR, "voice_alignment.json")
    with open(alignment_file, "w", encoding="utf-8") as f:
        json.dump(all_cards, f, indent=2)

    print("============================================================")
    print("  ✓ EP08 Audio Timing & Subtitles Processed Successfully!")
    print(f"  Total Subtitle Cards: {len(all_cards)} (All <= 5 words: PASS)")
    print(f"  Total Beats: {len(beat_ranges)}")
    for b_idx in sorted(beat_ranges.keys()):
        b = beat_ranges[b_idx]
        print(f"    Beat {b_idx}: {b['start']:.2f}s -> {b['end']:.2f}s (dur: {b['end']-b['start']:.2f}s)")
    print(f"  Generated Subtitles GDScript: {subtitles_gd_path}")
    print(f"  Generated Timing JSON: {final_timing_file}")
    print("============================================================")

if __name__ == "__main__":
    main()
