#!/usr/bin/env python3
"""
generate_ep00_voice.py
Voiceover Generation for ADB EPISODE 00: "HI, I'M ADB."
- Voice Actor: Aiden (Qwen3-TTS 1.7B CustomVoice predefined speaker, 24kHz Mono WAV)
- Voice Directive: "Cool, relaxed young adult male around 24, calm conversational speech, confident, subtle dry wit, understated and natural."
- Output: 24kHz WAV segments in audio/segments/ and master audio in audio/
- Audio is the MASTER CLOCK: Native speed, no speedup, no time stretch.
"""

import os
import sys
import json
import time
import numpy as np
import soundfile as sf

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKSPACE_ROOT = os.path.abspath(os.path.join(BASE_DIR, "..", "..", ".."))
if WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, WORKSPACE_ROOT)

from tools.tts.config import ADBVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine

VOICE_PROMPT = (
    "Cool, relaxed young adult male around 24, calm conversational speech, "
    "confident, subtle dry wit, understated and natural."
)

SEGMENTS_DEF = [
    # Beat 1: The Pushed Hook
    {
        "id": "seg01_wait_hold_on",
        "beat": 1,
        "text": "Wait—hold on—",
        "tts_text": "Wait, hold on...",
        "pause_after": 0.35,
        "tone": "reluctant, caught off guard, slight mild protest"
    },
    {
        "id": "seg02_okay_im_here",
        "beat": 1,
        "text": "Okay, okay! I'm here.",
        "tts_text": "Okay, okay. I'm here.",
        "pause_after": 0.50,
        "tone": "conceding, amused, dusting off sweater"
    },
    {
        "id": "seg03_hi_im_adb",
        "beat": 1,
        "text": "Hi. I'm ADB.",
        "tts_text": "Hi, I'm ADB.",
        "pause_after": 0.45,
        "tone": "cool relaxed conversational greeting directly to camera"
    },

    # Beat 2: First Intro & The Confession
    {
        "id": "seg04_im_24",
        "beat": 2,
        "text": "I'm 24...",
        "tts_text": "I'm 24...",
        "pause_after": 0.35,
        "tone": "calm, natural personal fact"
    },
    {
        "id": "seg05_making_animations_now",
        "beat": 2,
        "text": "...and apparently, I'm making storytime animations now.",
        "tts_text": "...and apparently, I'm making storytime animations now.",
        "pause_after": 0.80,
        "tone": "slight bemusement, self-aware smirk"
    },
    {
        "id": "seg06_which_is_interesting",
        "beat": 2,
        "text": "Which is interesting...",
        "tts_text": "Which is interesting...",
        "pause_after": 0.50,
        "tone": "thoughtful, dry comedic setup"
    },
    {
        "id": "seg07_no_idea_what_im_doing",
        "beat": 2,
        "text": "...because I have absolutely no idea what I'm doing.",
        "tts_text": "...because I have absolutely no idea what I'm doing.",
        "pause_after": 0.90,
        "tone": "completely deadpan, candid honest confession"
    },

    # Beat 3: National-Level Table Tennis Past
    {
        "id": "seg08_life_was_normal",
        "beat": 3,
        "text": "Now, before this, my life was pretty normal.",
        "tts_text": "Now, before this, my life was pretty normal.",
        "pause_after": 0.35,
        "tone": "casual conversational setup"
    },
    {
        "id": "seg09_used_to_play_sports",
        "beat": 3,
        "text": "A lot of people don't know this, but I used to play sports.",
        "tts_text": "A lot of people don't know this, but I used to play sports.",
        "pause_after": 0.35,
        "tone": "understated, modest disclosure"
    },
    {
        "id": "seg10_table_tennis_national",
        "beat": 3,
        "text": "Specifically... table tennis. At the national level.",
        "tts_text": "Specifically... table tennis. At the national level.",
        "pause_after": 0.60,
        "tone": "calm statement of fact, slight pause for weight"
    },
    {
        "id": "seg11:yes_it_was_intense",
        "beat": 3,
        "text": "And yes, it was intense.",
        "tts_text": "And yes, it was intense.",
        "pause_after": 0.40,
        "tone": "serious athletic focus, dramatic protagonist energy"
    },
    {
        "id": "seg12_spinning_balls_rallies",
        "beat": 3,
        "text": "Spinning balls, lightning rallies, extreme tournament focus.",
        "tts_text": "Spinning balls, lightning rallies, extreme tournament focus.",
        "pause_after": 0.50,
        "tone": "rapid-fire athletic intensity"
    },
    {
        "id": "seg13_retired_paddle",
        "beat": 3,
        "text": "Then I grew up... and retired my paddle.",
        "tts_text": "Then I grew up... and retired my paddle.",
        "pause_after": 0.70,
        "tone": "chuckle, relaxed recovery, normal guy again"
    },

    # Beat 4: Sports & Games
    {
        "id": "seg14_still_love_sports_games",
        "beat": 4,
        "text": "I still love sports, but mostly these days... I play games.",
        "tts_text": "I still love sports, but mostly these days... I play games.",
        "pause_after": 0.40,
        "tone": "warm conversational transition"
    },
    {
        "id": "seg15_way_too_many_games",
        "beat": 4,
        "text": "Like, way too many games.",
        "tts_text": "Like, way too many games.",
        "pause_after": 0.45,
        "tone": "self-aware admission, sheepish grin"
    },
    {
        "id": "seg16_ranked_ladder_sleep",
        "beat": 4,
        "text": "Competitive shooters, RPGs, strategy... if there's a ranked ladder, I've probably lost sleep over it.",
        "tts_text": "Competitive shooters, RPGs, strategy... if there's a ranked ladder, I've probably lost sleep over it.",
        "pause_after": 0.65,
        "tone": "enthusiastic gamer commentary, slight chuckle"
    },

    # Beat 5: The Anime Obsession
    {
        "id": "seg17_then_theres_anime",
        "beat": 5,
        "text": "And then... there's anime.",
        "tts_text": "And then... there's anime.",
        "pause_after": 0.50,
        "tone": "reverent, dramatic anime whisper"
    },
    {
        "id": "seg18_hundreds_of_anime",
        "beat": 5,
        "text": "I've watched hundreds of anime.",
        "tts_text": "I've watched hundreds of anime.",
        "pause_after": 0.75,
        "tone": "calm, matter-of-fact statement, completely unfazed"
    },
    {
        "id": "seg19_action_shonen_slice",
        "beat": 5,
        "text": "Action, shonen, slice of life, psychological thrillers...",
        "tts_text": "Action, shonen, slice of life, psychological thrillers...",
        "pause_after": 0.45,
        "tone": "rhythmic list with growing passion"
    },
    {
        "id": "seg20_obsession_research",
        "beat": 5,
        "text": "My friends say it's an obsession. I call it... thorough cultural research.",
        "tts_text": "My friends say it's an obsession. I call it... thorough cultural research.",
        "pause_after": 0.85,
        "tone": "deadpan defense, confident smirk"
    },

    # Beat 6: Regular Gym Routine
    {
        "id": "seg21_gym_regularly",
        "beat": 6,
        "text": "To balance all that sitting, I go to the gym regularly.",
        "tts_text": "To balance all that sitting, I go to the gym regularly.",
        "pause_after": 0.40,
        "tone": "healthy, practical young adult lifestyle"
    },
    {
        "id": "seg22_discipline_form",
        "beat": 6,
        "text": "Discipline. Form. Progressive overload.",
        "tts_text": "Discipline. Form. Progressive overload.",
        "pause_after": 0.50,
        "tone": "focused workout cadence"
    },
    {
        "id": "seg23_stairs_after_leg_day",
        "beat": 6,
        "text": "Right up until I try to walk up stairs after leg day.",
        "tts_text": "Right up until I try to walk up stairs after leg day.",
        "pause_after": 0.40,
        "tone": "sudden comedic vulnerability, wince"
    },
    {
        "id": "seg24_question_life_choices",
        "beat": 6,
        "text": "Then I question every life choice I've ever made.",
        "tts_text": "Then I question every life choice I've ever made.",
        "pause_after": 0.75,
        "tone": "exhausted comedic hold, wry sigh"
    },

    # Beat 7: Engineering Job
    {
        "id": "seg25_by_the_way",
        "beat": 7,
        "text": "Oh, and by the way...",
        "tts_text": "Oh, and by the way...",
        "pause_after": 0.35,
        "tone": "casual narrative turn"
    },
    {
        "id": "seg26_engineering_job",
        "beat": 7,
        "text": "I also have an engineering job.",
        "tts_text": "I also have an engineering job.",
        "pause_after": 0.85,
        "tone": "direct to camera, calm, let it sink in"
    },
    {
        "id": "seg27_wasnt_enough_work",
        "beat": 7,
        "text": "And apparently... that wasn't enough work for one human being.",
        "tts_text": "And apparently... that wasn't enough work for one human being.",
        "pause_after": 0.90,
        "tone": "deadpan disbelief, wry comedic delivery"
    },

    # Beat 8: Adding Storytime Animation
    {
        "id": "seg28_looked_at_schedule",
        "beat": 8,
        "text": "Because recently, I looked at my schedule—engineering, gym, sports, games, anime—",
        "tts_text": "Because recently, I looked at my schedule: engineering, gym, sports, games, anime...",
        "pause_after": 0.45,
        "tone": "rapid inventory of busy life"
    },
    {
        "id": "seg29_what_would_fit",
        "beat": 8,
        "text": "And I thought... 'You know what would fit perfectly into this?'",
        "tts_text": "And I thought... 'You know what would fit perfectly into this?'",
        "pause_after": 0.60,
        "tone": "bright sarcastic enthusiasm"
    },
    {
        "id": "seg30_thousands_of_frames",
        "beat": 8,
        "text": "'Thousands of hand-drawn animation frames.'",
        "tts_text": "'Thousands of hand-drawn animation frames.'",
        "pause_after": 0.65,
        "tone": "unhinged realization, dramatic emphasis"
    },
    {
        "id": "seg31_great_deadpan",
        "beat": 8,
        "text": "Great.",
        "tts_text": "Great.",
        "pause_after": 0.85,
        "tone": "absolute stone-faced deadpan freeze"
    },

    # Beat 9: Mysterious Girlfriend Help
    {
        "id": "seg32_not_completely_alone",
        "beat": 9,
        "text": "Now, to be fair... I'm not doing this completely alone.",
        "tts_text": "Now, to be fair... I'm not doing this completely alone.",
        "pause_after": 0.45,
        "tone": "honest, humble confession"
    },
    {
        "id": "seg33_girlfriend_help",
        "beat": 9,
        "text": "I'm getting some help from my girlfriend.",
        "tts_text": "I'm getting some help from my girlfriend.",
        "pause_after": 0.60,
        "tone": "affectionate, nodding toward off-screen"
    },
    {
        "id": "seg34_a_lot_of_help",
        "beat": 9,
        "text": "...A LOT of help.",
        "tts_text": "...A lot of help.",
        "pause_after": 0.70,
        "tone": "sheepish, cute flustered grin, lowering voice"
    },
    {
        "id": "seg35_not_look_like_potato",
        "beat": 9,
        "text": "She basically made sure my character didn't look like a potato.",
        "tts_text": "She basically made sure my character didn't look like a potato.",
        "pause_after": 0.80,
        "tone": "fond, playful teasing whisper"
    },

    # Beat 10: Outro & The Final Shove
    {
        "id": "seg36_thats_me_im_adb",
        "beat": 10,
        "text": "So... that's me. I'm ADB.",
        "tts_text": "So... that's me. I'm ADB.",
        "pause_after": 0.40,
        "tone": "warm, welcoming channel host"
    },
    {
        "id": "seg37_animator_now",
        "beat": 10,
        "text": "And apparently... I'm a storytime animator now.",
        "tts_text": "And apparently... I'm a storytime animator now.",
        "pause_after": 0.65,
        "tone": "relaxed grin, embracing the adventure"
    },
    {
        "id": "seg38_tell_some_stories",
        "beat": 10,
        "text": "We're going to tell some stories, laugh at bad decisions, and see what happens.",
        "tts_text": "We're going to tell some stories, laugh at bad decisions, and see what happens.",
        "pause_after": 0.50,
        "tone": "engaging, inviting audience in"
    },
    {
        "id": "seg39_thanks_for_watching",
        "beat": 10,
        "text": "Thanks for watching, and I'll—",
        "tts_text": "Thanks for watching, and I'll—",
        "pause_after": 0.25,
        "tone": "mid-sentence outro abruptly interrupted"
    },
    {
        "id": "seg40_let_me_do_the_intro",
        "beat": 10,
        "text": "Okay! LET ME DO THE INTRO!",
        "tts_text": "Okay! Let me do the intro!",
        "pause_after": 0.60,
        "tone": "playful indignant shout over shoulder, laughing"
    }
]

def main():
    print("============================================================")
    print("ADB EP00 VOICE GENERATOR: \"HI, I'M ADB.\"")
    print(f"Actor: AIDEN (Fixed Qwen3-TTS speaker)")
    print(f"Total Segments: {len(SEGMENTS_DEF)}")
    print("============================================================")

    output_dir = os.path.join(BASE_DIR, "audio", "segments")
    os.makedirs(output_dir, exist_ok=True)

    config = ADBVoiceConfig(
        speaker="aiden",
        voice_identifier="aiden",
        voice_design_prompt=VOICE_PROMPT
    )
    engine = QwenVoiceDesignEngine(config)

    for i, seg in enumerate(SEGMENTS_DEF):
        seg_id = seg["id"].replace(":", "_")
        out_file = os.path.join(output_dir, f"{seg_id}.wav")

        if os.path.exists(out_file) and os.path.getsize(out_file) > 1000:
            print(f"[{i+1}/{len(SEGMENTS_DEF)}] (Cached) {seg_id}.wav")
            continue

        prompt = f"{VOICE_PROMPT} Tone: {seg['tone']}"
        print(f"[{i+1}/{len(SEGMENTS_DEF)}] Synthesizing {seg_id}...")
        print(f"   Text: \"{seg['text']}\"")
        dur = engine.synthesize_to_file(
            text=seg["tts_text"],
            output_path=out_file,
            speaker="aiden",
            instruct=prompt,
            speed=1.0
        )
        print(f"   ✓ Duration: {dur:.2f}s")

    print("\n✓ All voice segments generated successfully!")

if __name__ == "__main__":
    main()
