# Audition voice review — episode 002

Scope: fresh 45-second voice audition for “Please Get Me Out of My Own Drawing.” This is a rough-storyboard voice pass, not final YouTube interaction verification.

## Identity and recording

- Exact canonical Sohee model, speaker, language and instruction retained. Canonical implementation hashes passed the existing checker.
- Three newly generated source takes preserved with source metadata and independent source/final word alignments.
- All tempos are 1.00. No source cuts, no pitch/formant/EQ changes, no altered identity instructions.
- Final narration is mono 24,000 Hz floating-point PCM, exactly 45.000 seconds.

## Measured placement

| Clip | Scene start | Actual take | Scene end | Authored window end |
| --- | ---: | ---: | ---: | ---: |
| drawing_hook | 0.350 | 17.2000 | 17.5500 | 23.700 |
| door_admission | 24.400 | 7.5275 | 31.9275 | 32.700 |
| tear_discovery | 34.300 | 8.3200 | 42.6200 | 44.500 |

All clips fit the supplied windows. The hook ends at 17.550 seconds, leaving 6.850 seconds before the next spoken clip for the choice prompt and door action. The door take contains a post-speech tail; no automatic silence edits were applied.

## Text and approximate timing

The unchanged local Whisper aligner measured 86 word entries. Its normalized transcript matches the script except “you’d” is recognized as “you” in the hook and the single word “doorknob” is recognized as “door knob.” These are ASR observations, not established spoken errors; aligner output remains unmodified.

Raw source and processed alignments, final scene-clock words and audio hashes are retained in `audio/timeline.json`, `audio/source/`, and `audio/processed/`.

## Technical audio checks

- Decoded sample peak: 0.611786; no nonfinite or full-scale samples.
- FFmpeg EBU R128 measurement: −21.7 LUFS integrated, 9.3 LU loudness range, −4.2 dBFS true peak. No normalization or effects applied.
- Existing voice checker passed canonical hashes, dialogue/placement equality, source/final/alignment hashes, window fit, ordered measured words and PCM format.

## Review status

**Listening, pronunciation, naturalness and emotional performance remain pending human playback.** Automated timing and transcript checks do not establish perceptual quality or final character approval. Preserve these takes if further audition revisions are requested.

Narration SHA-256: `447fbd638e228871642193f9f90cef89a50adef6034a4acbe536c21d74aee4d1`
Dialogue SHA-256: `f97337d894d08459d8646384d9f18392a0e96ae2bba6fb261c0788e40507a5ac`
