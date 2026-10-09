#!/usr/bin/env python3
"""Prepare EP03's preserved 1.00x takes with authored thought gaps.

The shared preparer performs hashing, interval validation, and final assembly.
Cached-ASR word boundaries remain approximate and require auditory review.
"""
import copy
import hashlib
import json
import math
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[4]
FOLDER = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from tools.storytime.prepare_voice import prepare


GAPS = [
    (.38, "Hook lands before clarifying the old channel."),
    (.35, "Actual-face joke settles before the approximate 2015 memory."),
    (.40, "Lip-sync explanation gives way to personal commitment."),
    (.55, "Dry hindsight lands before the subscriber achievement."),
    (.35, "The thousand-subscriber memory leads into trusting one friend."),
    (.80, "One-friend confidence receives a dry hold before the lab."),
    (.40, "Computer-period setup prepares the play-click consequence."),
    (.70, "Opening and playing the videos lands before the class reveal."),
    (.45, "The exposed-face list settles before the emotional reaction."),
    (.75, "The vulnerable embarrassment receives quiet room."),
    (.65, "Public-versus-personal contrast gives way to adult hindsight."),
    (.35, "The warmer interpretation continues into their apparent admiration."),
    (.50, "Missed admiration lands before the cute-memory reframe."),
    (.60, "Warm memory settles before leaving the old channel."),
    (.60, "Dropping the channel has a reflective hold before the comeback."),
    (.45, "YouTube comeback sets up the animated-face callback."),
    (.65, "Character-development joke receives a small dry hold."),
    (1.15, "Closing commitment callback has an intentional final picture hold."),
]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tokens(text):
    return re.findall(r"[\w]+(?:['’][\w]+)*", text.lower().replace("’", "'"))


def main():
    raw = json.loads((FOLDER / "source_words_take1.json").read_text())
    selected = copy.deepcopy(raw)
    alternatives = json.loads((FOLDER / "review/audio/alternative_alignment_r1.json").read_text())
    phrases = json.loads((FOLDER / "review/audio/phrase_alignment_r1.json").read_text())
    repairs = []
    # The initial prompted pass skipped almost all of this audible-length source.
    # A fresh unprompted cached pass measured all 26 expected spoken words.
    selected[11]["words"] = alternatives["11"]["words"]
    selected[11]["transcript"] = alternatives["11"]["transcript"]
    repairs.append({"paragraph": 11, "action": "Use complete unprompted cached-ASR alignment; preserve original prompted result.",
                    "evidence": "review/audio/alternative_alignment_r1.json"})
    # Two zero-duration function words were remeasured from authored phrase crops.
    # Their crop offsets are restored; no evenly divided sentence times are used.
    for i, first in [(4, 14), (13, 14)]:
        selected[i]["words"] = selected[i]["words"][:first] + phrases[str(i)]["words"]
        repairs.append({"paragraph": i, "action": "Replace phrase from measured crop to repair zero-duration function word.",
                        "source_crop_start": phrases[str(i)]["source_crop_start"],
                        "evidence": "review/audio/phrase_alignment_r1.json"})
    for record in selected:
        words = []
        for word in record["words"]:
            word = dict(word, word=word["word"].strip())
            if word["word"].startswith("-") and words:
                previous = words[-1]
                previous["word"] += word["word"]
                previous["end"] = word["end"]
                previous["probability"] = min(previous["probability"], word["probability"])
                previous["alignment_note"] = "Hyphen compound merged using measured outer bounds."
            else:
                words.append(word)
        record["words"] = words
        assert tokens(" ".join(w["word"] for w in words)) == tokens(record["text"]), record["paragraph"]
        record["transcript_matches_script_tokens"] = True
        previous = 0
        for w in words:
            assert previous <= w["start"] < w["end"] <= record["source_duration"], (record["paragraph"], w)
            previous = w["end"]
        assert sha(ROOT / record["file"][6:]) == record["sha256"]
    selected_path = FOLDER / "source_words_r1.json"
    selected_path.write_text(json.dumps(selected, indent=2) + "\n")
    initial_pad = .35
    cursor = initial_pad
    clips, references = [], []
    word_index = 0
    for i, record in enumerate(selected):
        length = record["source_duration"]
        gap, reason = GAPS[i]
        clips.append({
            "author": "adb", "file": record["file"], "sha256": record["sha256"],
            "at": round(cursor, 6), "start": 0.0, "end": length, "tempo": 1.0,
            "words": [{k: w[k] for k in ["word", "start", "end"]} for w in record["words"]],
        })
        references.append({
            "paragraph": i, "clip": i, "take": record["take"], "text": record["text"],
            "source_file": record["file"], "source_sha256": record["sha256"],
            "source_bounds": [0.0, length], "tempo": 1.0,
            "start": round(cursor, 6), "end": round(cursor + length, 6),
            "beat_start": 0.0 if i == 0 else round(cursor, 6),
            "beat_end": round(cursor + length + gap, 6),
            "first_word": word_index, "last_word": word_index + len(record["words"]) - 1,
            "added_gap_after": gap, "gap_intent": reason,
            "bounds_intent": "Preserve the entire thought take including recorded breaths and pauses; no silence trim.",
        })
        word_index += len(record["words"])
        cursor += length + gap
    duration = math.ceil((cursor - 1e-8) * 30) / 30
    assert duration <= 180, f"Measured runtime {duration:.3f}s exceeds 180s; tighten prose with root."
    references[-1]["beat_end"] = duration
    plan = {"version": 1, "duration": duration, "clips": clips}
    plan_path = FOLDER / "voice_plan_r1.json"
    plan_path.write_text(json.dumps(plan, indent=2) + "\n")
    output = ROOT / "renders/adb_school_youtube/audio_r1"
    timeline = prepare(plan, output)
    reference = {
        "version": 1, "fps": 30, "duration": duration, "hard_runtime_cap": 180,
        "audio": "res://renders/adb_school_youtube/audio_r1/narration.wav",
        "audio_metadata": "res://renders/adb_school_youtube/audio_r1/timeline.json",
        "audio_sha256": timeline["audio_sha256"], "source_duration_sum": sum(r["source_duration"] for r in selected),
        "initial_pad": initial_pad, "pacing": "All 18 sources preserved at 1.00x; explicit thought gaps only.",
        "paragraphs": references,
        "alignment": "Measured cached Whisper Tiny boundaries; corrected transcript coverage, zero intervals and compounds; approximate, auditory review pending.",
    }
    (FOLDER / "timing_reference_r1.json").write_text(json.dumps(reference, indent=2) + "\n")
    review = {
        "version": 1, "source_take_count": 18, "selected_take": 1,
        "source_duration_sum": reference["source_duration_sum"], "final_duration": duration,
        "tempo": 1.0, "source_bounds_policy": "Full source takes; no silence trimming.",
        "speaker": selected[0]["speaker"], "model": selected[0]["model"],
        "identity_prompt": selected[0]["identity_prompt"],
        "audio_sha256": timeline["audio_sha256"], "voice_plan_sha256": sha(plan_path),
        "text_tokens_verified": True, "source_hashes_verified": True,
        "ordered_positive_word_intervals_verified": True, "word_count": len(timeline["words"]),
        "alignment_repairs": repairs,
        "low_confidence_words": [{"paragraph": r["paragraph"], **w} for r in selected for w in r["words"] if w["probability"] < .65],
        "listening_performed": False,
        "listening_limitation": "Attempted audio-content inspection returned: audio content omitted because you do not support audio input. Transcript verification does not constitute listening.",
        "pending": ["Subjective Aiden delivery, breaths and thought-gap pacing listening.",
                    "Important spoken-word and mouth-boundary review against final audio.",
                    "Final episode narration/SFX mix audition after sound direction."],
    }
    (FOLDER / "review/audio/voice_qa_r1.json").write_text(json.dumps(review, indent=2) + "\n")
    print(json.dumps({"duration": duration, "source_duration": reference["source_duration_sum"],
                      "words": len(timeline["words"]), "audio": reference["audio"],
                      "timeline": reference["audio_metadata"]}, indent=2))


if __name__ == "__main__":
    main()
