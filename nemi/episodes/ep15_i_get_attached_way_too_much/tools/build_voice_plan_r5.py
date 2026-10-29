#!/usr/bin/env python3
"""EP15 R5: reuse approved Sohee sources; shorten 11 authored silent windows.

No resynthesis, voice setting changes, automatic silence cutting or blanket
tempo change. Outputs refuse replacement. Word intervals are transformed from
the measured source recording through the exact retained source ranges.
"""
import hashlib
import json
import math
import shutil
import sys
from pathlib import Path

import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / "tools/storytime"))
from prepare_voice import prepare
from tools.tts.config import NemiVoiceConfig

EP = Path(__file__).resolve().parent.parent
TEMPOS = [1.08, 1.08, 1.08, 1.0, 1.0, 1.0, 1.08, 1.0, 1.0, 1.0, 1.0, 1.0]
HOLDS = [0.55, 0.70, 0.75, 1.30, 1.10, 1.40, 0.80, 1.00, 1.40, 0.95, 1.30, 2.90]
# Bounds are source-file seconds, deliberately inside waveform-checked silence.
# End consonants, lead-in breaths and emotional hesitation remain outside them.
CUTS = {
    0: [(8.12, 8.42, "contract. / They"), (11.06, 11.52, "conversation. / I'm")],
    1: [(5.38, 6.02, "there. / We")],
    4: [(1.36, 1.87, "say. / I"), (5.89, 6.53, "lives. / But")],
    6: [(9.18, 9.63, "energy. / I'd"), (11.66, 12.11, "say. / Then")],
    7: [(9.02, 9.42, "fix. / Maybe")],
    8: [(2.15, 2.57, "too. / Neeko")],
    9: [(8.98, 9.90, "on. / Sometimes")],
    11: [(6.26, 6.70, "hold. / I'll")],
}


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def dump(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + "\n")


def r6(value):
    return round(float(value), 6)


def db(value):
    return r6(20 * math.log10(max(float(value), 1e-12)))


def main():
    out_plan = EP / "voice_plan_r5.json"
    out_timing = EP / "timing_reference_r5.json"
    out_lines = EP / "timing_lines_r5.json"
    out_audio = EP / "voice/narration_r5.wav"
    out_map = EP / "retiming_r5.json"
    out_qa = EP / "review/audio/pacing_r5.json"
    out_notes = EP / "voice/PACING_R5.md"
    work = ROOT / "renders/nemi_ep15_voice_r5"
    for path in [out_plan, out_timing, out_lines, out_audio, out_map, out_qa, out_notes, work]:
        if path.exists():
            raise RuntimeError(f"Protected output already exists: {path}. Use a new revision.")

    records = json.loads((EP / "source_words.json").read_text())
    old_timing = json.loads((EP / "timing_reference_r1.json").read_text())
    old_lines = json.loads((EP / "timing_lines_r1.json").read_text())["lines"]
    identity = NemiVoiceConfig()
    if len(records) != 12 or len(old_lines) != 12:
        raise RuntimeError("Expected the 12 approved EP15 source lines")

    current = 0.6
    clips, line_map, removed, segments = [], [], [], []
    clock_map = [{"kind": "opening_lead", "old_start": 0.0, "old_end": 0.6,
                  "new_start": 0.0, "new_end": 0.6}]
    global_index = 0
    for index, record in enumerate(records):
        if (record["author"] != "nemi" or record["speaker"] != identity.speaker
                or record["model"] != identity.repo_id
                or record["identity_prompt"] != identity.voice_design_prompt
                or record["synthesis_tempo"] != 1.0):
            raise RuntimeError(f"Identity provenance changed on source {index}")
        source = ROOT / record["file"][6:]
        if not source.is_file() or digest(source) != record["sha256"]:
            raise RuntimeError(f"Approved source missing or changed: {source}")
        samples, rate = sf.read(source, dtype="float64", always_2d=True)
        if rate != identity.sample_rate or samples.shape[1] != 1:
            raise RuntimeError("Expected approved 24kHz mono source")
        if abs(len(samples) / rate - record["duration"]) > 1 / rate:
            raise RuntimeError("Source duration changed")
        words = [{"word": w["word"].strip(), "start": r6(w["start"]), "end": r6(w["end"])}
                 for w in record["words"]]
        cuts = CUTS.get(index, [])
        ranges, previous = [], 0.0
        for start, end, label in cuts:
            if not previous < start < end < record["duration"]:
                raise RuntimeError("Invalid authored cut order")
            if any(w["start"] < end and w["end"] > start for w in words):
                raise RuntimeError(f"Authored cut touches a measured word: {index} {start}–{end}")
            ranges.append((previous, start))
            window = samples[round(start * rate):round(end * rate)]
            rms = float(np.sqrt(np.mean(window ** 2)))
            peak = float(np.max(np.abs(window)))
            # This gate validates these specific authored bounds. It never finds cuts.
            if db(rms) > -60 or db(peak) > -40:
                raise RuntimeError(f"Authored silent cut needs new review: source {index} {start}–{end}")
            removed.append({"source_line": index, "source_file": record["file"],
                            "source_sha256": record["sha256"], "start": start, "end": end,
                            "thought_boundary": label, "tempo": TEMPOS[index],
                            "removed_scene_seconds": r6((end - start) / TEMPOS[index]),
                            "rms_dbfs": db(rms), "peak_dbfs": db(peak)})
            previous = end
        ranges.append((previous, record["duration"]))
        line_at = current
        first_clip = len(clips)
        line_words = []
        for source_start, source_end in ranges:
            kept_words = [w for w in words if source_start <= w["start"] and w["end"] <= source_end]
            if not kept_words:
                raise RuntimeError("A retained source segment has no measured words")
            clip = {"author": "nemi", "file": record["file"], "sha256": record["sha256"],
                    "at": current, "start": source_start, "end": source_end,
                    "tempo": TEMPOS[index], "words": kept_words}
            clips.append(clip)
            clip_end = current + (source_end - source_start) / TEMPOS[index]
            segment = {"kind": "kept_audio", "source_line": index, "clip_index": len(clips) - 1,
                       "source_start": source_start, "source_end": source_end,
                       "old_start": r6(old_lines[index]["at"] + source_start / old_lines[index]["tempo"]),
                       "old_end": r6(old_lines[index]["at"] + source_end / old_lines[index]["tempo"]),
                       "new_start": r6(current), "new_end": r6(clip_end),
                       "old_tempo": old_lines[index]["tempo"], "new_tempo": TEMPOS[index]}
            segments.append(segment)
            clock_map.append(segment)
            for word in kept_words:
                line_words.append({"word": word["word"],
                                   "start": r6(current + (word["start"] - source_start) / TEMPOS[index]),
                                   "end": r6(current + (word["end"] - source_start) / TEMPOS[index])})
            current = clip_end
            cut = next((c for c in cuts if c[0] == source_end), None)
            if cut:
                clock_map.append({"kind": "removed_silence", "source_line": index,
                                  "source_start": cut[0], "source_end": cut[1],
                                  "old_start": r6(old_lines[index]["at"] + cut[0] / old_lines[index]["tempo"]),
                                  "old_end": r6(old_lines[index]["at"] + cut[1] / old_lines[index]["tempo"]),
                                  "new_start": r6(current), "new_end": r6(current)})
        if len(line_words) != len(words):
            raise RuntimeError("Retained source ranges lost or duplicated a measured word")
        line_map.append({"source_line": index, "script": record["text"],
                         "measured_transcript": " ".join(w["word"] for w in words),
                         "at": r6(line_at), "end_at": r6(current),
                         "first_word_at": line_words[0]["start"], "last_word_end_at": line_words[-1]["end"],
                         "tempo": TEMPOS[index], "pause_after": HOLDS[index],
                         "word_count": len(words), "word_start_index": global_index,
                         "word_end_index_exclusive": global_index + len(words),
                         "clip_start_index": first_clip, "clip_end_index_exclusive": len(clips),
                         "source_ranges": [[a, b] for a, b in ranges],
                         "removed_source_ranges": [[a, b] for a, b, _ in cuts]})
        old_hold_end = (old_lines[index + 1]["at"] if index + 1 < len(old_lines) else old_timing["duration"])
        clock_map.append({"kind": "interline_hold" if index < 11 else "ending_hold",
                          "source_line": index, "old_start": old_lines[index]["end_at"],
                          "old_end": old_hold_end, "new_start": r6(current),
                          "new_end": r6(current + HOLDS[index])})
        global_index += len(words)
        current += HOLDS[index]

    duration = math.ceil(current * 30) / 30
    if not 150 <= duration <= 154:
        raise RuntimeError(f"Runtime outside revision target 150–154 seconds: {duration}")
    if global_index != 384:
        raise RuntimeError("Expected all 384 approved measured words")
    clock_map[-1]["new_end"] = r6(duration)
    plan = {"version": 1, "duration": duration, "clips": clips}
    timeline = prepare(plan, work)
    if len(timeline["words"]) != global_index:
        raise RuntimeError("Prepared word count differs from source count")
    word_map = []
    for word_index, (old, new) in enumerate(zip(old_timing["words"], timeline["words"])):
        if old["word"] != new["word"]:
            raise RuntimeError("Word identity or order changed")
        source_line = next(line["source_line"] for line in line_map
                           if line["word_start_index"] <= word_index < line["word_end_index_exclusive"])
        word_map.append({"word_index": word_index, "source_line": source_line, "word": new["word"],
                         "old_start": old["start"], "old_end": old["end"],
                         "new_start": new["start"], "new_end": new["end"]})
    for line in line_map:
        measured = timeline["words"][line["word_start_index"]:line["word_end_index_exclusive"]]
        if (measured[0]["start"] != line["first_word_at"]
                or measured[-1]["end"] != line["last_word_end_at"]):
            raise RuntimeError("Line grouping differs from exact prepared word times")
    if any(a["end"] > b["start"] for a, b in zip(timeline["words"], timeline["words"][1:])):
        raise RuntimeError("Prepared word intervals overlap")

    audio, rate = sf.read(work / "narration.wav", dtype="float64", always_2d=True)
    audio_duration = len(audio) / rate
    if rate != 24000 or audio.shape[1] != 1 or abs(audio_duration - duration) > 1 / rate:
        raise RuntimeError("Prepared narration format/duration changed")
    peak = float(np.max(np.abs(audio)))
    clipped = int(np.sum(np.abs(audio) >= 1))
    if clipped:
        raise RuntimeError("Prepared narration clips")

    out_qa.parent.mkdir(parents=True, exist_ok=True)
    dump(out_plan, plan)
    shutil.copyfile(work / "timeline.json", out_timing)
    shutil.copyfile(work / "narration.wav", out_audio)
    audio_hash = digest(out_audio)
    dump(out_lines, {"version": 1, "duration": duration, "audio_sha256": audio_hash,
                     "word_count": global_index, "lines": line_map})
    dump(out_map, {"version": 1, "old_revision": "r1", "new_revision": "r5",
                   "old_duration": old_timing["duration"], "new_duration": duration,
                   "old_audio_sha256": old_timing["audio_sha256"], "new_audio_sha256": audio_hash,
                   "mapping_policy": "piecewise linear per interval; removed silence collapses to its new boundary; exact word pairs supplied",
                   "clock_intervals": clock_map, "line_groups": line_map, "word_pairs": word_map})
    old_internal_holds = sum(line["pause_after"] for line in old_lines)
    qa = {"version": 1, "duration": audio_duration, "old_duration": old_timing["duration"],
          "saved_total_seconds": r6(old_timing["duration"] - audio_duration),
          "sample_rate": rate, "channels": audio.shape[1], "word_count": global_index,
          "retained_clip_count": len(clips), "authored_cut_count": len(removed),
          "peak_dbfs": db(peak), "rms_dbfs": db(np.sqrt(np.mean(audio ** 2))),
          "clipped_samples": clipped, "audio_sha256": audio_hash,
          "identity": {"speaker": identity.speaker, "model": identity.repo_id,
                       "identity_prompt": identity.voice_design_prompt,
                       "synthesis_tempo": 1.0, "processing": "atrim + pitch-preserving atempo only; no synthesis, pitch/formant/EQ change"},
          "source_words_sha256": digest(EP / "source_words.json"),
          "config_sha256": digest(ROOT / "tools/tts/config.py"),
          "old_after_line_holds_seconds": old_internal_holds,
          "new_after_line_holds_seconds": sum(HOLDS),
          "removed_scene_seconds": r6(sum((b - a) / TEMPOS[i] for i, cuts in CUTS.items() for a, b, _ in cuts)),
          "frame_padding_seconds": r6(duration - current), "removed_windows": removed,
          "checks": {"all_source_hashes_verified": True, "all_384_source_words_retained_once": True,
                     "word_intervals_rebuilt_from_retained_source_bounds": True,
                     "word_intervals_positive_ordered_nonoverlapping": True,
                     "source_window_rms_at_most_minus60_dbfs": True,
                     "direct_acoustic_audition_performed": False,
                     "independent_final_asr_performed": False},
          "placement_quantization": "shared preparer offsets processed clips by rounded milliseconds; metadata uses exact planned seconds, maximum 0.5ms offset quantization",
          "review_limit": "Waveform/identity/timing checks do not replace acoustic playback review of final narration and full movie."}
    dump(out_qa, qa)

    table = "\n".join(f"| {line['source_line']:02d} | {line['at']:.6f} | {line['end_at']:.6f} | {line['tempo']:.2f} | {line['pause_after']:.2f} |"
                       for line in line_map)
    cuts_table = "\n".join(f"| {cut['source_line']:02d} | {cut['start']:.2f}–{cut['end']:.2f} | {cut['thought_boundary']} | {cut['rms_dbfs']:.1f} | {cut['peak_dbfs']:.1f} |"
                            for cut in removed)
    out_notes.write_text(f"""# EP15 voice R5 — {duration:.3f} seconds

This pacing revision reuses all 12 exact approved Sohee source WAVs. Their hashes, speaker, model, identity prompt and 1.00× synthesis provenance were checked against source metadata and current canonical Nemi configuration. No voice was generated; no speaker, pitch, formant or EQ setting changed. The same R1 phrase tempos remain: lines 00, 01, 02 and 06 at 1.08×; all other lines at 1.00×.

The user reported large pauses and a slow episode. Eleven explicitly selected, waveform-reviewed silent windows remove {qa['removed_scene_seconds']:.6f}s. These are fixed authored source bounds, not threshold-based automatic trimming. The longest deleted window is 0.92s after “moved on”; quiet tails and lead-ins around it remain. Every removed window measures RMS below −60dBFS and peak below −40dBFS. All 384 measured source word intervals remain once, with no deletion touching a measured word. R1 and the canonical recordings remain preserved.

| Source line | Deleted source seconds | Boundary | RMS dBFS | Peak dBFS |
| --- | --- | --- | --- | --- |
{cuts_table}

Opening lead stays 0.60s. Authored after-line holds total {sum(HOLDS):.2f}s, reduced from {old_internal_holds:.2f}s. Rejection, wanting to feel missed, Neeko and the ending still have deliberate reactions. Emotional source pauses after “hurting”, “all”, “them”, “after”, “much”, “people”, “miss them”, “down” and “lot” remain intact. The 2.90s ending hold requires purposeful closing performance. Picture should develop each remaining hold with one readable audience focus, not add dead padding.

Complete duration is {duration:.3f}s (2:30.2), {qa['saved_total_seconds']:.3f}s shorter than R1, within the user's 150–180s requirement. The unrounded authored clock is {current:.9f}s; 30fps frame rounding adds {duration-current:.9f}s. Last measured speech ends {line_map[-1]['last_word_end_at']:.6f}s; last source tail ends {line_map[-1]['end_at']:.6f}s.

| Source line | Final start | Final end | Tempo | Hold after |
| --- | --- | --- | --- | --- |
{table}

`timing_reference_r5.json` rebuilds every word interval through the retained source ranges. It does not reuse R1 scene-clock word times or redistribute words proportionally. `timing_lines_r5.json` groups global word and clip indices by original source line. `retiming_r5.json` supplies all 384 exact old/new word pairs plus piecewise intervals for kept audio, removed silence, and revised holds. Caption, mouth, acting, camera and sound cues must use the new clock. Shared audio placement rounds offsets to milliseconds (at most 0.5ms); metadata retains the exact planned clock.

Measured final WAV: {rate}Hz mono, {audio_duration:.3f}s, peak {qa['peak_dbfs']:.2f}dBFS, RMS {qa['rms_dbfs']:.2f}dBFS, zero clipped samples. SHA256 `{audio_hash}`. Machine source/timing/waveform checks passed. Direct human acoustic audition and an independent final-ASR pass were not performed by this builder; neither naturalness nor full-movie mix approval is claimed. The root production review must inspect actual playback.
""")
    print(f"EP15 narration R5: {duration:.3f}s; {global_index} words; {len(clips)} retained-source clips; {len(removed)} authored cuts")
    print(f"SHA256 {audio_hash}")
    for line in line_map:
        print(f"line {line['source_line']:02d}: {line['at']:.6f}–{line['end_at']:.6f}, "
              f"{line['tempo']:.2f}×, {line['word_count']} words, hold {line['pause_after']:.2f}s")


if __name__ == "__main__":
    main()
