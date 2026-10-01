# New storytime direction proof — 2026-10-01

`A_Tiny_Plan_10s.mp4`: independent new production, 10.000 seconds, 1920×1080, 30 FPS, 300 video frames, fresh Nemi/ADB dialogue and three punctual existing SFX.

Verified:
- All 28 recipe combinations evaluated at multiple transition/hold times.
- Both characters' planted feet stay within 0.65 local pixels of their bound targets through tested standing transitions.
- Visible acting/art/VFX states reproduce after backward seeks across all four shots.
- Attached phone grip coincides with the palm socket after acting and parent scaling.
- Held artwork is fully drawn; only the revision uses live strokes. The quiet aftermath stays stable.
- Existing ink/identity regression checks pass; valid scene and 24 invalid authoring cases rejected across version 1 and version 2.
- Separate known-signal audio test confirms cue offsets, clip trimming, narration headroom, SFX gain and exact duration.
- Final exported audio peak is 0.4474 (below clipping), and the 8.75–9.90 second aftermath has zero RMS.
- Fresh WAV/OGG sources load directly for live playback.
- Raw movie script errors abort export instead of silently producing a superficially valid movie.
- Word timestamps came from the complete cached Whisper Tiny model. Spoken script matches the two fresh source recordings' transcription. Mouth shapes are manually selected vowels aligned to words, not measured phonemes.
- Visual review used a sampled rendered sequence and full-resolution weight/reply frames; corrected overlapping labels, transparent-looking paper borders, crossed/bowed knee stance, oversized speech shapes, and wrist-only attachment.
- 2,168 protected character/episode files match the start-of-pass hashes. Existing pending changes in those folders are preserved, not rewritten by this pass.

Playback listening remains a subjective review step for the user; the agent used transcription/timing checks and known-signal audio tests, not a claim of listening through native speakers. Final phoneme alignment, walking, seated contact, object pickup, and scene-specific camera movement still require authored choreography/review.

Reproduction: `docs/animation/STORYTIME_DIRECTION_WORKFLOW.md`. Generated voice WAVs/movie stay local; spec, text, timing annotations, code, documentation and small review images are publishable source artifacts. Voice model weights are not bundled. Re-generated recordings need timing review before old annotations are reused.
