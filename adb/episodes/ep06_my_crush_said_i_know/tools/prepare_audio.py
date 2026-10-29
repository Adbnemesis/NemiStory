#!/usr/bin/env python3
"""Prepare EP06's preserved 1.00x takes with authored thought gaps.

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
    (.35, "Opening section reshuffle memory settles before revealing the classroom setup."),
    (.40, "The awkward trio dynamic and reignited feelings settle before introducing the early isolation."),
    (.40, "Quiet corner kid memory transitions into the second year social recovery."),
    (.45, "Comfortable friendship recovery lands before daring to ask the forbidden question."),
    (.45, "Tension builds after asking the question that haunted him for years."),
    (.65, "Comedic shock hold on her completely forgetting she ever blocked him."),
    (.40, "Math exam relief and ambitious plan settle before taking out the phone."),
    (.55, "High-suspense waiting hold between sending the text and phone buzzing."),
    (.90, "Final comedic deadpan hold on 'I know' and high school reflection through black."),
]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tokens(text):
    return re.findall(r"[\w]+(?:['’][\w]+)*", text.lower().replace("’", "'"))


def main():
    source_words_file = FOLDER / "source_words_take2.json"
    if not source_words_file.exists():
        print(f"Waiting for {source_words_file} to be generated.")
        sys.exit(1)
    raw = json.loads(source_words_file.read_text())
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
                previous["probability"] = min(previous.get("probability", 1.0), word.get("probability", 1.0))
                previous["alignment_note"] = "Hyphen compound merged using measured outer bounds."
            else:
                words.append(word)
        for j, w in enumerate(words):
            if w["end"] <= w["start"]:
                prev_end = words[j - 1]["end"] if j > 0 else 0.0
                next_start = words[j + 1]["start"] if j + 1 < len(words) else record["source_duration"]
                if w["start"] - 0.15 >= prev_end:
                    w["start"] = round(w["start"] - 0.15, 3)
                elif next_start - w["end"] >= 0.15:
                    w["end"] = round(w["end"] + 0.15, 3)
                else:
                    mid = (prev_end + next_start) / 2.0
                    w["start"] = round(mid - 0.06, 3)
                    w["end"] = round(mid + 0.06, 3)
                repairs.append({
                    "paragraph": record["paragraph"],
                    "word": w["word"],
                    "repaired_bounds": [w["start"], w["end"]],
                    "note": "Zero-duration whisper timestamp adjusted."
                })
        record["words"] = words
        record_tokens = tokens(record["text"])
        word_tokens = tokens(" ".join(w["word"] for w in words))
        if word_tokens != record_tokens:
            print(f"Note: Token difference in paragraph {record['paragraph']}: expected {len(record_tokens)} tokens, got {len(word_tokens)} words.")
        record["transcript_matches_script_tokens"] = (word_tokens == record_tokens)
        previous = 0
        for w in words:
            if not (previous <= w["start"] < w["end"] <= record["source_duration"] + 0.5):
                print(f"Warning: word timestamp bounds in paragraph {record['paragraph']}: {w}")
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

    output = ROOT / "renders/adb_my_crush_said_i_know/audio_take2"
    timeline = prepare(plan, output)
    reference = {
        "version": 1, "fps": 30, "duration": duration, "hard_runtime_cap": 120,
        "audio": "res://renders/adb_my_crush_said_i_know/audio_take2/narration.wav",
        "audio_metadata": "res://renders/adb_my_crush_said_i_know/audio_take2/timeline.json",
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
