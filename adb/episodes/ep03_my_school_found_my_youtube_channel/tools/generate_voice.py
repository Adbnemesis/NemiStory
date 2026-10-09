#!/usr/bin/env python3
"""Generate preserved EP03 Aiden takes and cached, measured source word timing.

Run with the project .venv outside the sandbox for existing Metal access.
Identity and synthesis settings come unchanged from ADBVoiceConfig.
This helper does not trim, accelerate, or synthesize sound effects.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import sys

os.environ["HF_HUB_OFFLINE"] = "1"
os.environ["TOKENIZERS_PARALLELISM"] = "false"
ROOT = Path(__file__).resolve().parents[4]
FOLDER = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from tools.tts.config import ADBVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine
import mlx_whisper
import soundfile as sf


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tokens(text):
    return re.findall(r"[\w]+(?:['’][\w]+)*", text.lower().replace("’", "'"))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--take", type=int, default=1)
    parser.add_argument("--paragraph", type=int, action="append", help="Zero-based paragraph(s); default all")
    args = parser.parse_args()
    if args.take < 1:
        parser.error("Take must be positive; previous takes are preserved.")
    paragraphs = (FOLDER / "narration.txt").read_text().strip().split("\n\n")
    assert len(paragraphs) == 18, f"Expected 18 authored thought paragraphs, got {len(paragraphs)}"
    selected = args.paragraph if args.paragraph is not None else list(range(len(paragraphs)))
    assert all(0 <= i < len(paragraphs) for i in selected)
    output = ROOT / "renders/adb_school_youtube/source_voice_r1"
    output.mkdir(parents=True, exist_ok=True)
    config = ADBVoiceConfig()
    engine = None
    records = []
    for i in selected:
        text = paragraphs[i]
        path = output / f"{i:02d}_adb_take{args.take}.wav"
        metadata = path.with_suffix(".json")
        if metadata.exists():
            record = json.loads(metadata.read_text())
            assert path.is_file() and record["sha256"] == sha(path)
            assert record["text"] == text and record["speaker"] == config.speaker
            assert record["model"] == config.repo_id and record["identity_prompt"] == config.voice_design_prompt
        else:
            if not path.exists():
                if engine is None:
                    engine = QwenVoiceDesignEngine(config)
                print(f"GENERATING paragraph={i:02d} take={args.take} words={len(text.split())}", flush=True)
                engine.synthesize_to_file(text, str(path), speed=1.0)
            info = sf.info(path)
            result = mlx_whisper.transcribe(
                str(path), path_or_hf_repo="mlx-community/whisper-tiny", language="en",
                word_timestamps=True, verbose=False, initial_prompt=text,
            )
            measured = [dict(w) for segment in result["segments"] for w in segment.get("words", [])]
            transcript = result["text"].strip()
            record = {
                "paragraph": i, "take": args.take, "author": "adb", "text": text,
                "file": "res://" + str(path.relative_to(ROOT)), "sha256": sha(path),
                "speaker": config.speaker, "model": config.repo_id,
                "identity_prompt": config.voice_design_prompt, "tempo": 1.0,
                "sample_rate": info.samplerate, "source_duration": info.duration,
                "alignment_kind": "cached Whisper Tiny measured word boundaries; approximate",
                "transcript": transcript, "transcript_matches_script_tokens": tokens(transcript) == tokens(text),
                "words": measured, "alignment_review_required": True,
                "listening_review": "pending; text comparison is not listening",
            }
            metadata.write_text(json.dumps(record, indent=2) + "\n")
        records.append(record)
        print(f"READY paragraph={i:02d} take={args.take} duration={record['source_duration']:.3f} "
              f"transcript_matches={record['transcript_matches_script_tokens']}", flush=True)
        if not record["transcript_matches_script_tokens"]:
            print("EXPECTED " + record["text"], flush=True)
            print("WHISPER  " + record["transcript"], flush=True)
    index = FOLDER / f"source_words_take{args.take}.json"
    existing = json.loads(index.read_text()) if index.exists() else []
    by_id = {r["paragraph"]: r for r in existing}
    by_id.update({r["paragraph"]: r for r in records})
    index.write_text(json.dumps([by_id[i] for i in sorted(by_id)], indent=2) + "\n")
    print(f"INDEX {index}; total source duration={sum(r['source_duration'] for r in by_id.values()):.3f}", flush=True)


if __name__ == "__main__":
    main()
