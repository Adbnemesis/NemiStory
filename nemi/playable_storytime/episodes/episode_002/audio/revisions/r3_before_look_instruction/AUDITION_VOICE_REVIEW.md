# Audition voice review — episode 002

Scope: 40-second voice audition for “Please Get Me Out of My Own Drawing.” This is a rough-storyboard voice pass, not final YouTube interaction verification.

## Identity and preserved takes

- Exact canonical Sohee model, speaker, language and instruction retained. Canonical implementation hashes passed the existing checker.
- Same three newly generated source/processed takes as the initial 45-second assembly; source and processed SHA-256 hashes, alignment files and durations verified identical. No model was loaded for this reassembly.
- All tempos are 1.00. No source cuts, no pitch/formant/EQ changes, no altered identity instructions.
- Initial 45-second narration, timeline, exact dialogue, provenance, checker and reports preserved under `audio/revisions/45s_initial/`. All source and processed takes remain in their original folders.
- Current narration is mono 24,000 Hz floating-point PCM, exactly 40.000 seconds.

## Measured placement

| Clip | Scene start | Actual take | Scene end | Authored window end |
| --- | ---: | ---: | ---: | ---: |
| drawing_hook | 0.350 | 17.2000 | 17.5500 | 19.700 |
| door_admission | 20.400 | 7.5275 | 27.9275 | 28.700 |
| tear_discovery | 30.300 | 8.3200 | 38.6200 | 39.500 |

All clips fit the supplied windows. The hook ends at 17.550 seconds, leaving 2.850 seconds before the next spoken clip for the choice prompt and door action. The door take contains a post-speech tail; no automatic silence edits were applied.

## Text and approximate timing

The unchanged local Whisper aligner measured 86 word entries. Its normalized transcript matches the script except “you’d” is recognized as “you” in the hook and the single word “doorknob” is recognized as “door knob.” These are ASR observations, not established spoken errors; aligner output remains unmodified.

Raw source and processed alignments, final scene-clock words and audio hashes are retained in `audio/timeline.json`, `audio/source/`, and `audio/processed/`. The scene-clock word placements were rebuilt for the new clip starts.

## Technical audio checks

- Decoded sample peak: 0.611786; no nonfinite or full-scale samples.
- FFmpeg EBU R128 measurement: −21.7 LUFS integrated, 8.8 LU loudness range, −4.2 dBFS true peak. No normalization or effects applied.
- Existing voice checker passed canonical hashes, dialogue/placement equality, source/final/alignment hashes, window fit, ordered measured words and PCM format.

## Review status

**Listening, pronunciation, naturalness and emotional performance remain pending human playback.** Automated timing and transcript checks do not establish perceptual quality or final character approval. Preserve these takes if further audition revisions are requested.

Narration SHA-256: `4b089cd45f4686a00a0b71240dd33ee5ed93cede13ad9eb2a85b35cbc530a568`
Dialogue SHA-256: `e1790720e96a3d24071c54ed533b8c82e5a5cefd3c923dcd1923fc772fb11846`
