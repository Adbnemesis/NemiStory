# Refinement proof QA — 2026-10-01

New standalone proof: `One_Tiny_Plan_10s.mp4`, 1920×1080, 30 fps, exactly 300 frames / 10 seconds. Source: `common/storytime/examples/refinement_10s/scene.json`. Reproduction: `docs/animation/STORYTIME_REFINEMENT_WORKFLOW.md`.

## Changes demonstrated

Closer character framing; a thought insert; original Nemi and ADB pen identities; held props/art plus one live revision; a bounded camera push; authored ADB phone pickup/lift/putdown; smooth, stepped and snap performance choices; asymmetric existing face controls; word-linked captions above scene art; deliberate anticipation offsets; quiet selective SFX; an unspoken visual payoff. No rig replacement or old-episode migration.

Nemi reuses the exact saved original recording with 1.12× pitch-preserving tempo and explicit phrase placement. ADB reuses his original recording at 1.00×. No synthesis occurred. No speaker, identity prompt, model, pitch, formant or EQ changes were made. Source hashes/bounds/tempi are in the voice plan and verification record. Mix calibration is one constant gain only. Encoded audio: −18.0 LUFS integrated, −3.3 dBFS true peak.

## Verified

- Original and new validator cases pass, including unsupported controls, timing/event drift, captions inconsistent with final word metadata, source audio hash checks and source-only schema validation.
- Engine checks pass for stable authored ink/lettering, all 28 performance recipes, grounded standing feet, deterministic forward/backward seeks, grip contact, smooth/stepped/snap behavior, Nemi external hand reach, camera motion and caption layer order.
- Pickup/putdown boundaries do not teleport or resize the prop; held grip stays on the palm. Tested within 0.01 world pixel for position and 0.001 scale.
- Known-signal audio tests verify exact offsets/trims, intentional gaps, unchanged sample rate, pitch-preserving tempo, unchanged CustomVoice generation arguments for both identities, constant-gain headroom, stale unsafe gain rejection and refusal to overwrite/substitute source recordings. Pitch test uses a deterministic 180 Hz fixture; it is not a subjective timbre judgment.
- Encoded frame boundaries are checked against shot times; the prior export's one-frame advance was corrected by preserving initial authored frames and trimming the extra trailing frame.
- Frame review: twelve full-scene samples, a 31-frame contact sequence spaced 0.13 seconds, and a full-resolution caption/contact frame. This caught and corrected subtitle occlusion and final-aside/head overlap. Completed ink remains stable in the sampled holds.
- A fresh silent ADB starter was generated and validated, then the temporary starter was removed.
- All 2,168 protected rig/episode files match the saved baseline. Canonical voice configuration and the pre-existing local editor project file also match the start-of-work hashes.

## Review boundary

Full-speed native playback / listening was attempted, but the media-player tool stalled and was interrupted. **Subjective playback and listening are not marked passed.** The video is supplied for review; numerical sound checks do not establish whether a phrase feels natural by ear.

Mouths are authored broad word-based vowel/closure cues, not measured phonemes. Whisper Tiny's original “twenty” boundary has low confidence (~0.127) and needs listening/refinement for final production. Tempo-transformed word times remain approximate. Walking, seated contact, turns and larger physical actions still need separately authored sequences. Phone/mug silhouettes now differ by author, but the entire prop library is not independently redrawn. The story template and validation improve repeatability; they cannot guarantee artistic quality or audience retention.

## Saved and excluded

Source/spec, voice plan, reference timing metadata, guides, tests, contact sheets and small QA records belong in Git. Movies, generated narration/processed WAVs, cached models and old Pegi diagnostic images stay local. Existing local editor settings and generated import files are not part of this implementation commit.
