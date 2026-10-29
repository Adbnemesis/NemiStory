# Canonical Nemi voice production

`canonical/config.py`, `engine.py` and `pacing.py` are byte-identical copies of the approved project modules. Their hashes are pinned in `tools/voice.py`. The speaker is **sohee**, English, 24 kHz, using the exact Qwen3-TTS 1.7B CustomVoice bf16 weights and unchanged identity instruction. The local model path changes; the model contents and voice settings do not.

From the original repository directory:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 nemi/playable_storytime/tools/voice.py setup-models
PYTHONDONTWRITEBYTECODE=1 .venv/bin/python nemi/playable_storytime/tools/voice.py generate --episode episodes/episode_001
PYTHONDONTWRITEBYTECODE=1 python3 nemi/playable_storytime/tools/voice.py check --episode episodes/episode_001
```

Model preparation copies the existing local cached snapshots into `.cache/models/`, dereferences all links and checks every file hash. It does not download a model. Generation requires access to the Mac's Metal GPU; a restricted headless execution may need expanded local execution permission. The check command uses no ML runtime. Existing installed Python packages are read-only; caches, temporary files and new outputs stay inside this project.

Each episode supplies `scripts/dialogue.json`:

```json
{
  "duration": 300,
  "speaker": "sohee",
  "clips": [
    {"id": "opening", "text": "Wait. Where did my badge go?", "at": 0.4, "window_end": 8.9, "tempo": 1.0}
  ]
}
```

Windows are authored, ordered and nonoverlapping. Tempo changes use the unchanged pitch-preserving pacing module, with allowed episode tempos 1.00–1.15. Do not use faster pacing to compensate for a repetitive script. Listen before accepting tempo edits.

Generation retains text-keyed source WAVs, source identity records, raw source Whisper words, final paced WAVs and independently measured final word alignments. It never estimates word fractions. Words shift onto the episode clock only after alignment. A clip exceeding its window is reported with its actual duration; the tool does not truncate it. Fix the text or authored placement, then rerun. Matching source and processed clips are reused.

Successful assembly writes `audio/narration.wav`, `timeline.json` and `voice_provenance.json`. The timeline follows the shared storytime metadata convention: `audio_sha256`, `clips`, and ordered `{actor,word,start,end}` word records. Extra confidence/clip IDs preserve traceability. The full narration includes deliberately authored gaps and exactly matches the episode duration.

The checker verifies the current dialogue hash, source/final hashes, canonical implementation hashes, alignment hashes, timing windows, ordered word intervals and PCM format. It records `audio/voice_check.json`.

Whisper Tiny provides approximate **word** boundaries, not phonemes. Its spelling and segmentation can be wrong. Keep raw measurements, record same-unit spelling corrections separately, and omit uncertain caption groups until reviewed. Never invent split timings. Numeric/ASR checks do not establish that a recording has been heard or that delivery, pauses and mouth shapes are satisfactory. Actual listening, pacing and mouth review remain separate gates.

Existing narration is protected. After a successful master, preserve the complete audio folder as a revision before changing dialogue. A new `audio/` folder may reuse copies of the retained `source/` and `processed/` caches; their content hashes and text keys are checked. Do not overwrite a reviewed master or reuse old word times after changing its audio.
