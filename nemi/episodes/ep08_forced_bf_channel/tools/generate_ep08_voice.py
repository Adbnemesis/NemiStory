#!/usr/bin/env python3
"""
generate_ep08_voice.py
Generates Voiceover for NEMI EPISODE 08:
"I FORCED MY BF TO CREATE A CHANNEL"

Cast:
- Nemi: Sohee (Qwen3-TTS 1.7B CustomVoice predefined speaker, 24kHz Mono WAV)
  Prompt: "Warm, natural young adult woman around 24, relaxed conversational speech, friendly, casual, intelligent, slightly playful."
- ADB: Aiden (Qwen3-TTS 1.7B CustomVoice predefined speaker, 24kHz Mono WAV)
  Prompt: "Cool, relaxed young adult male around 24, calm conversational speech, confident, subtle dry wit, understated and natural."

Audio is the MASTER CLOCK: Native speed 1.0, no pitch shift, no time stretch.
Output:
- 24kHz WAV segments in audio/segments/
- Master audio in audio/EP08_voice.wav
- Raw timing manifest in timing/ep08_raw_timing.json
"""

import os
import sys
import json
import time
import numpy as np
import soundfile as sf

EP08_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORKSPACE_ROOT = os.path.abspath(os.path.join(EP08_DIR, "..", "..", ".."))
if WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, WORKSPACE_ROOT)

from tools.tts.config import NemiVoiceConfig, ADBVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine

NEMI_VOICE_PROMPT = (
    "Warm, natural young adult woman around 24, relaxed conversational speech, "
    "friendly, casual, intelligent, slightly playful."
)

ADB_VOICE_PROMPT = (
    "Cool, relaxed young adult male around 24, calm conversational speech, "
    "confident, subtle dry wit, understated and natural."
)

SEGMENTS_DEF = [
    # -------------------------------------------------------------------------
    # Beat 1: The Hook (Opening)
    # -------------------------------------------------------------------------
    {
        "id": "seg01_new_problem",
        "beat": 1,
        "speaker": "sohee",
        "character": "nemi",
        "text": "I HAVE A NEW PROBLEM.",
        "tts_text": "I have a new problem.",
        "pause_after": 0.45,
        "tone": "sharp energetic storytime hook, sudden dramatic confession to viewer"
    },
    {
        "id": "seg02_convinced_bf",
        "beat": 1,
        "speaker": "sohee",
        "character": "nemi",
        "text": "I somehow convinced my boyfriend to start a YouTube channel.",
        "tts_text": "I somehow convinced my boyfriend to start a YouTube channel.",
        "pause_after": 0.65,
        "tone": "casual conversational storytelling, slight disbelief at what she just caused"
    },

    # -------------------------------------------------------------------------
    # Beat 2: Old ADB Callback
    # -------------------------------------------------------------------------
    {
        "id": "seg03_guys_remember",
        "beat": 2,
        "speaker": "sohee",
        "character": "nemi",
        "text": "Guys... remember ADB?",
        "tts_text": "Guys... remember ADB?",
        "pause_after": 0.40,
        "tone": "engaging conversational question, glancing toward stage right"
    },
    {
        "id": "seg04_yeah_this_adb",
        "beat": 2,
        "speaker": "sohee",
        "character": "nemi",
        "text": "Yeah. THIS ADB.",
        "tts_text": "Yeah. This ADB.",
        "pause_after": 0.50,
        "tone": "comedic reveal pose, dry emphasis on the legacy character"
    },
    {
        "id": "seg05_yeah_this_version",
        "beat": 2,
        "speaker": "sohee",
        "character": "nemi",
        "text": "...yeah. This version.",
        "tts_text": "...yeah. This version.",
        "pause_after": 0.55,
        "tone": "understated awkward acknowledgment of the old techwear goggles design"
    },

    # -------------------------------------------------------------------------
    # Beat 3: ADB Hated The Old Design
    # -------------------------------------------------------------------------
    {
        "id": "seg06_adb_hated",
        "beat": 3,
        "speaker": "sohee",
        "character": "nemi",
        "text": "ADB hated this character.",
        "tts_text": "ADB hated this character.",
        "pause_after": 0.45,
        "tone": "matter-of-fact confession, looking sideways at the old character"
    },
    {
        "id": "seg07_understand_why",
        "beat": 3,
        "speaker": "sohee",
        "character": "nemi",
        "text": "Honestly... I kinda understand why.",
        "tts_text": "Honestly... I kinda understand why.",
        "pause_after": 0.80,
        "tone": "sheepish, slightly guilty, humorous deadpan admission"
    },

    # -------------------------------------------------------------------------
    # Beat 4: Redesign & New ADB Reveal
    # -------------------------------------------------------------------------
    {
        "id": "seg08_so_eventually",
        "beat": 4,
        "speaker": "sohee",
        "character": "nemi",
        "text": "So eventually we decided:",
        "tts_text": "So eventually we decided:",
        "pause_after": 0.25,
        "tone": "bright narrative shift, proactive problem solving"
    },
    {
        "id": "seg09_okay_completely_new",
        "beat": 4,
        "speaker": "sohee",
        "character": "nemi",
        "text": "okay. We're making a completely new ADB.",
        "tts_text": "okay. We're making a completely new ADB.",
        "pause_after": 0.50,
        "tone": "decisive, enthusiastic, authoring sketch gestures"
    },
    {
        "id": "seg10_unreasonable_amount",
        "beat": 4,
        "speaker": "sohee",
        "character": "nemi",
        "text": "And after an unreasonable amount of work... we finally made one.",
        "tts_text": "And after an unreasonable amount of work... we finally made one.",
        "pause_after": 0.65,
        "tone": "relieved proud sigh, presenting the brand new ADB"
    },

    # -------------------------------------------------------------------------
    # Beat 5: The Terrible Idea
    # -------------------------------------------------------------------------
    {
        "id": "seg11_terrible_idea",
        "beat": 5,
        "speaker": "sohee",
        "character": "nemi",
        "text": "And then I had another terrible idea.",
        "tts_text": "And then I had another terrible idea.",
        "pause_after": 0.50,
        "tone": "mischievous, self-aware smirk, visual lightbulb beat"
    },
    {
        "id": "seg12_why_doesnt_adb",
        "beat": 5,
        "speaker": "sohee",
        "character": "nemi",
        "text": "If I'm making storytime animations... why doesn't ADB make storytime animations too?",
        "tts_text": "If I'm making storytime animations... why doesn't ADB make storytime animations too?",
        "pause_after": 0.55,
        "tone": "animated persuasion, logical pitch to boyfriend"
    },

    # -------------------------------------------------------------------------
    # Beat 6: Asking ADB
    # -------------------------------------------------------------------------
    {
        "id": "seg13_adb_said_no_1",
        "beat": 6,
        "speaker": "sohee",
        "character": "nemi",
        "text": "ADB said no.",
        "tts_text": "ADB said no.",
        "pause_after": 0.40,
        "tone": "blunt, immediate flat refusal report"
    },
    {
        "id": "seg14_asked_again_1",
        "beat": 6,
        "speaker": "sohee",
        "character": "nemi",
        "text": "I asked again.",
        "tts_text": "I asked again.",
        "pause_after": 0.40,
        "tone": "persistent, cheerful asking"
    },
    {
        "id": "seg15_adb_said_no_2",
        "beat": 6,
        "speaker": "sohee",
        "character": "nemi",
        "text": "ADB said no.",
        "tts_text": "ADB said no.",
        "pause_after": 0.40,
        "tone": "firmer deadpan report of his stubbornness"
    },
    {
        "id": "seg16_asked_again_2",
        "beat": 6,
        "speaker": "sohee",
        "character": "nemi",
        "text": "I asked again.",
        "tts_text": "I asked again.",
        "pause_after": 0.75,
        "tone": "relentless smiling persistence, building comedy"
    },
    {
        "id": "seg17_eventually_made_channel",
        "beat": 6,
        "speaker": "sohee",
        "character": "nemi",
        "text": "And eventually... ADB made a channel.",
        "tts_text": "And eventually... ADB made a channel.",
        "pause_after": 0.65,
        "tone": "victorious, triumphant storytelling payoff"
    },

    # -------------------------------------------------------------------------
    # Beat 7: Two Channels
    # -------------------------------------------------------------------------
    {
        "id": "seg18_and_now_both",
        "beat": 7,
        "speaker": "sohee",
        "character": "nemi",
        "text": "And now... there's Nemi... and there's ADB... both making storytime animations.",
        "tts_text": "And now... there's Nemi... and there's ADB... both making storytime animations.",
        "pause_after": 0.50,
        "tone": "warm two-character stage presentation"
    },
    {
        "id": "seg19_little_dangerous",
        "beat": 7,
        "speaker": "sohee",
        "character": "nemi",
        "text": "Which is honestly... a little dangerous.",
        "tts_text": "Which is honestly... a little dangerous.",
        "pause_after": 0.45,
        "tone": "conspiratorial aside to camera, mischievous warning"
    },
    {
        "id": "seg20_annoy_each_other",
        "beat": 7,
        "speaker": "sohee",
        "character": "nemi",
        "text": "Because now we can annoy each other with animation too.",
        "tts_text": "Because now we can annoy each other with animation too.",
        "pause_after": 0.60,
        "tone": "delighted teasing, playful rivalry"
    },

    # -------------------------------------------------------------------------
    # Beat 8: Hand The Mic To ADB
    # -------------------------------------------------------------------------
    {
        "id": "seg21_introduce_yourself",
        "beat": 8,
        "speaker": "sohee",
        "character": "nemi",
        "text": "Actually... ADB. Introduce yourself.",
        "tts_text": "Actually... ADB. Introduce yourself.",
        "pause_after": 0.60,
        "tone": "casual natural pivot, turning physically to ADB"
    },
    {
        "id": "seg22_adb_uh_im_adb",
        "beat": 8,
        "speaker": "aiden",
        "character": "adb",
        "text": "Uh... I'm ADB.",
        "tts_text": "Uh... I'm ADB.",
        "pause_after": 0.40,
        "tone": "cool relaxed greeting, slight casual surprise, direct to viewer"
    },
    {
        "id": "seg23_adb_make_animations",
        "beat": 8,
        "speaker": "aiden",
        "character": "adb",
        "text": "I make storytime animations too.",
        "tts_text": "I make storytime animations too.",
        "pause_after": 0.40,
        "tone": "calm, natural conversational statement"
    },
    {
        "id": "seg24_adb_overshare",
        "beat": 8,
        "speaker": "aiden",
        "character": "adb",
        "text": "I talk about my own experiences... and probably overshare way too much.",
        "tts_text": "I talk about my own experiences... and probably overshare way too much.",
        "pause_after": 0.55,
        "tone": "dry self-aware wit, subtle smirk"
    },
    {
        "id": "seg25_adb_check_channel",
        "beat": 8,
        "speaker": "aiden",
        "character": "adb",
        "text": "So... if you're curious, check out my channel.",
        "tts_text": "So... if you're curious, check out my channel.",
        "pause_after": 0.40,
        "tone": "genuine understated invitation, looking at audience"
    },
    {
        "id": "seg26_adb_link_description",
        "beat": 8,
        "speaker": "aiden",
        "character": "adb",
        "text": "The link's in the description.",
        "tts_text": "The link's in the description.",
        "pause_after": 0.65,
        "tone": "casual clear sign-off, subtle natural downward point"
    },

    # -------------------------------------------------------------------------
    # Beat 9: Nemi Takes Back Control & Outro
    # -------------------------------------------------------------------------
    {
        "id": "seg27_suspiciously_normal",
        "beat": 9,
        "speaker": "sohee",
        "character": "nemi",
        "text": "Wow. That was suspiciously normal.",
        "tts_text": "Wow. That was suspiciously normal.",
        "pause_after": 0.55,
        "tone": "comedic interruption, genuine mild disbelief"
    },
    {
        "id": "seg28_just_getting_started",
        "beat": 9,
        "speaker": "sohee",
        "character": "nemi",
        "text": "Anyway... ADB is just getting started. So go check out the channel.",
        "tts_text": "Anyway... ADB is just getting started. So go check out the channel.",
        "pause_after": 0.50,
        "tone": "bright supportive host, turning back to camera"
    },
    {
        "id": "seg29_worked_way_too_hard",
        "beat": 9,
        "speaker": "sohee",
        "character": "nemi",
        "text": "I worked way too hard to convince this person.",
        "tts_text": "I worked way too hard to convince this person.",
        "pause_after": 0.45,
        "tone": "playful exaggeration, comedic fatigue"
    },
    {
        "id": "seg30_please_make_worth_it",
        "beat": 9,
        "speaker": "sohee",
        "character": "nemi",
        "text": "Please make it worth it.",
        "tts_text": "Please make it worth it.",
        "pause_after": 0.80,
        "tone": "pleading deadpan humor directly to camera"
    }
]

def main():
    audio_dir = os.path.join(EP08_DIR, "audio")
    segments_dir = os.path.join(audio_dir, "segments")
    timing_dir = os.path.join(EP08_DIR, "timing")

    os.makedirs(segments_dir, exist_ok=True)
    os.makedirs(timing_dir, exist_ok=True)

    print("============================================================")
    print("  NEMI EPISODE 08: VOICE GENERATION")
    print("  'I FORCED MY BF TO CREATE A CHANNEL'")
    print(f"  Total Segments: {len(SEGMENTS_DEF)}")
    print("  Nemi Speaker: Sohee | ADB Speaker: Aiden")
    print("============================================================")

    config = NemiVoiceConfig()
    engine = QwenVoiceDesignEngine(config)

    generated_segments = []

    for idx, seg in enumerate(SEGMENTS_DEF):
        seg_id = seg["id"]
        out_wav = os.path.join(segments_dir, f"{seg_id}.wav")
        speaker = seg["speaker"]
        
        base_prompt = NEMI_VOICE_PROMPT if seg["character"] == "nemi" else ADB_VOICE_PROMPT
        instruct = f"{base_prompt} Tone: {seg['tone']}"

        t0 = time.time()
        duration = engine.synthesize_to_file(
            text=seg["tts_text"],
            output_path=out_wav,
            speaker=speaker,
            instruct=instruct,
            speed=1.0
        )
        dt = time.time() - t0
        print(f"  [{idx+1:02d}/{len(SEGMENTS_DEF)}] [{seg['character'].upper()}:{speaker}] {seg_id}.wav ({duration:.2f}s, took {dt:.1f}s) — \"{seg['text'][:40]}...\"")

        seg_info = dict(seg)
        seg_info["file"] = f"{seg_id}.wav"
        seg_info["duration"] = round(duration, 3)
        generated_segments.append(seg_info)

    print("\n[Assembling Master Track & Raw Alignment Manifest...]")
    sample_rate = config.sample_rate # 24000 Hz
    master_chunks = []
    current_time = 0.0

    timeline_data = {
        "episode_id": "ep08_forced_bf_channel",
        "title": "I FORCED MY BF TO CREATE A CHANNEL",
        "voices": {"nemi": "sohee", "adb": "aiden"},
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
            "character": seg["character"],
            "speaker": seg["speaker"],
            "text": seg["text"],
            "start_time": round(start_t, 3),
            "end_time": round(end_t, 3),
            "duration": round(seg_len, 3),
            "pause_after": seg["pause_after"]
        }
        timeline_data["segments"].append(seg_entry)

        master_chunks.append(audio_data)
        current_time = end_t

        pause_samples = int(seg["pause_after"] * sample_rate)
        if pause_samples > 0:
            master_chunks.append(np.zeros(pause_samples, dtype=np.float32))
            current_time += seg["pause_after"]

    full_master_audio = np.concatenate(master_chunks)
    total_duration = len(full_master_audio) / float(sample_rate)
    timeline_data["total_duration"] = round(total_duration, 3)

    master_wav_path = os.path.join(audio_dir, "EP08_voice.wav")
    sf.write(master_wav_path, full_master_audio, sample_rate, subtype="PCM_16")

    raw_manifest_path = os.path.join(timing_dir, "ep08_raw_timing.json")
    with open(raw_manifest_path, "w", encoding="utf-8") as f:
        json.dump(timeline_data, f, indent=2)

    print("\n============================================================")
    print("  ✓ EP08 Voiceover Generation Complete!")
    print(f"  Master Audio: {master_wav_path}")
    print(f"  Total Duration: {total_duration:.2f}s ({total_duration/60.0:.2f} mins)")
    print(f"  Raw Timing Manifest: {raw_manifest_path}")
    print("============================================================")

if __name__ == "__main__":
    main()
