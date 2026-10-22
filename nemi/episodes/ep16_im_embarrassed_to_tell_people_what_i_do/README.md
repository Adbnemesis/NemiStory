# EP16 — I’m Embarrassed to Tell People What I Do

Nemi struggles to answer a normal cafe question, hides behind vague descriptions, then discovers the intended joke in a story video connects with its viewer. The production is a fictionalized low-stakes dramatization of the approved concept.

- Runtime:107.400 seconds;120-second hard cap.
- Current source:scene.json, with immutable scene_r5_1080p.json snapshot.
- Review:review/RENDERS.md and review/QA.md; current full R5 review movie is ready locally.
- Voice:canonical Sohee source recordings and provenance in voice/source/, explicit bounds/tempo in voice_plan_r1.json, final narration/timeline hashes in timing_reference_r1.json.
- Direction:DIRECTION_BRIEF.md, SCRIPT_AND_BEATS.md, camera_plan.json and sound_plan.json.
- Preparation:preflight.json; complete current character/shared reading with episode-specific notes.

Reproduction uses existing cached tools and protected files. tools/generate_voice.py refuses changed/overwritten source recordings; tools/build_voice_plan.py refuses existing prepared output, so a new voice revision needs new explicit output names. tools/build_episode.py directs the final recording through the shared version-2 stage and calibrates the original voice plus exact existing SFX. Validate/export through tools/storytime/validate_scene.py and render_scene.py at the repository root. No private player, rig changes or 4K bypass.

All movies are local and excluded from Git. Preserve earlier versions until the user explicitly approves the current complete1080p cut; only then can the normal gated4Kworkflow proceed. No user satisfaction receipt has been recorded. Actual real-time playback and acoustic listening remain unperformed due unavailable tool access; review records distinguish still/decoded/ASR/numeric checks from perceptual review.
