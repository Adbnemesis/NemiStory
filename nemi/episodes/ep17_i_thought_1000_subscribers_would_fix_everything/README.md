# Nemi EP17 — I thought 1,000 subscribers would fix everything

Current full 1080p review is `renders/NEMI_EP17_1000_Subscribers_r7_1080p_REVIEW.mp4`, 114.433333 seconds. Current source is `scene_r7_1080p.json`, also saved as `scene.json`. Current narration is `voice/narration_r3.wav`; current word metadata is `timing_reference_r4.json`.

Script and thought beats are in `SCRIPT_AND_BEATS.md` and `story.json`. Camera and sound intentions are in `camera_plan.json` and `sound_plan.json`. Voice sources and their hashes, independent ASR records, editorial pace plans and review evidence are preserved. All prior movies/specs remain available. The render index and current QA are under `review/`.

`tools/build_episode.py` preserves the complete R6 base direction. `tools/build_caption_revision_r7.py` records and reproduces the single R7 text correction from that exact base against independent final-audio ASR: “I'd reached the checkpoint.” Voice, timestamps, mouth intervals, camera, artwork and sound are unchanged. The revision helper refuses existing output paths. Do not regenerate protected voices or overwrite prior revisions.

Use the shared validator and renderer with the current saved source and a new output revision filename. Required preparation is recorded in `preflight.json`. Canonical Nemi character, pen, poses, expression, hand and mouth source libraries were not changed. The original milestone evidence drawings use the existing shared stage and LiveDrawing player; their catalog and valid silent example are `ART_REFERENCE.md` and `art_example.json`.

The complete 1080p cut is for user viewing/listening review. Technical checks and sampled-frame inspection do not establish perceptual audio approval or measured phoneme accuracy. Browser playback was disabled and native player computer use was not approved, so actual continuous playback/listening remains unperformed. No 4K episode has been rendered; wait for explicit user satisfaction with this exact current full cut. Keep generated video/audio local and retain older versions until the approved replacement meets the user's retention gate.
