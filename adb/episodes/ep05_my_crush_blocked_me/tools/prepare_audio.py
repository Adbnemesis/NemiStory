#!/usr/bin/env python3
"""Prepare EP05's preserved 1.00x takes with authored thought gaps.

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
    (.35, "Opening section change memory settles before introducing the elective."),
    (.40, "Classroom distance settles before the awkward texting decision."),
    (.45, "Comedic pause after sending the desperate second text."),
    (.40, "Absurd 'deactivated account' rationalization lands with smug pride."),
    (.45, "Sustained comedic hold on one full year of blissful ignorance."),
    (.40, "Overhearing whispers in Year 2 sets up the shocking revelation."),
    (.45, "Rival boyfriend identity lands as the puzzle pieces click."),
    (.70, "Total deadpan shock freeze on the devastating 'SHE BLOCKED ME' realization."),
    (.90, "Final heartbreak confession settles through black."),
]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tokens(text):
    return re.findall(r"[\w]+(?:['’][\w]+)*", text.lower().replace("’", "'"))


def main():
    raw = json.loads((FOLDER / "source_words_take2.json").read_text())
    selected = copy.deepcopy(raw)
    repairs = []

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
        assert tokens(" ".join(w["word"] for w in words)) == tokens(record["text"]), f"Token mismatch in paragraph {record['paragraph']}"
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
    assert duration <= 120, f"Measured runtime {duration:.3f}s exceeds 120s; tighten prose with root."
    references[-1]["beat_end"] = duration
    plan = {"version": 1, "duration": duration, "clips": clips}
    plan_path = FOLDER / "voice_plan_r1.json"
    plan_path.write_text(json.dumps(plan, indent=2) + "\n")

    output = ROOT / "renders/adb_my_crush_blocked_me/audio_take2"
    timeline = prepare(plan, output)
    reference = {
        "version": 1, "fps": 30, "duration": duration, "hard_runtime_cap": 120,
        "audio": "res://renders/adb_my_crush_blocked_me/audio_take2/narration.wav",
        "audio_metadata": "res://renders/adb_my_crush_blocked_me/audio_take2/timeline.json",
        "audio_sha256": timeline["audio_sha256"], "source_duration_sum": sum(r["source_duration"] for r in selected),
        "initial_pad": initial_pad, "pacing": "All 9 sources preserved at 1.00x; explicit thought gaps only.",
        "paragraphs": references,
        "alignment": "Measured cached Whisper Tiny boundaries; corrected transcript coverage; approximate, auditory review pending.",
    }
    (FOLDER / "timing_reference_r1.json").write_text(json.dumps(reference, indent=2) + "\n")

    review_audio = FOLDER / "review/audio"
    review_audio.mkdir(parents=True, exist_ok=True)
    review = {
        "version": 1, "source_take_count": 9, "selected_take": 1,
        "source_duration_sum": reference["source_duration_sum"], "final_duration": duration,
        "tempo": 1.0, "source_bounds_policy": "Full source takes; no silence trimming.",
        "speaker": selected[0]["speaker"], "model": selected[0]["model"],
        "identity_prompt": selected[0]["identity_prompt"],
        "audio_sha256": timeline["audio_sha256"], "voice_plan_sha256": sha(plan_path),
        "text_tokens_verified": True, "source_hashes_verified": True,
        "ordered_positive_word_intervals_verified": True, "word_count": len(timeline["words"]),
        "alignment_repairs": repairs,
        "low_confidence_words": [{"paragraph": r["paragraph"], **w} for r in selected for w in r["words"] if w.get("probability", 1.0) < .65],
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
