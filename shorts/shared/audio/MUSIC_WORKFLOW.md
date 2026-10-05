# Music direction for Godot ink edits

The user wants famous/topic-fit music and tight visual sync, with no copyright-selection gate. Preserve exact recording identity and provenance. The current approved choices are cataloged under shorts/assets/music/batch01/, including official preview URLs, original/decoded hashes, analyses and selected music sections.

Read the selected metadata, analysis and production CUE_MAP. Choose12–25s around a phrase; check the real source length. Music sourceStart is preview-relative unless full-song offset is known. Important pose, camera, doodle and sound accents share the30fps scene clock. Source onset candidates are timing evidence, not magically confirmed downbeats.

Use `shorts/tools/audio_analyze.py` for a new source/section and the version3 schema for the final exact range/gain/hash. A music replacement requires a new cue map and export; do not reuse stale timing. The source extractor `shorts/assets/music/batch01/fetch_music.py` fetches the documented public previews without altering their identity. Current platform trend rank requires a fresh authoritative observation; the user's approved famous music can be retained without such a claim.

Recorded SFX use the real root/category inventory and exact hashes. `shorts/godot/verify_audio.py` reconstructs and measures the delivered AAC music+SFX against those sources. It checks source coverage, clipping/true peak, timing and actual SFX contribution. Godot supplies all visuals; ffmpeg only packages the sound and capture. See V3_WORKFLOW.md and the author skill helper for commands.
