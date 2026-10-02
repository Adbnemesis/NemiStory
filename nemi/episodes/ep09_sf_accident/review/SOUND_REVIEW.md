# Existing root/library sound pass — 2026-10-02

34 cues, including 7 placements of the exact existing root clips: anime-wow.mp3, bruh.mp3, fahhh.mp3, ping.mp3, pop.mp3, whoosh.mp3. Category-folder recordings provide the remaining Foley/reaction/detail sounds. No procedural substitutes and no new audio synthesis. Root files remain in place; every used source has its path/hash in `existing_sfx_audit.json`. Narration identity, script, pitch, tempo and timings remain unchanged. Vocal memes are external comic commentary, not replacement character dialogue.

Root MP3s now have `viral_*` catalog IDs and are indexed in `common/audio/sfx/root_sfx_inventory.json`. Original root license records were absent; they are recorded honestly as unknown rather than relabelled CC0. Existing library provenance is retained. No new raw sounds were downloaded or committed.

Measured cue RMS stays above the -18 dB review threshold relative to nearby narration. The root pop uses its full audible attack after review found the earlier 0.09-second trim nearly silent. `anime-wow.mp3` uses the first 2.5 seconds, containing its attack and fading tail; the clip remains unchanged on disk. EP08's final `fahhh` excerpt fits the existing episode endpoint. Other source clips use documented durations in the saved plans. No voice generation, pitch or tempo changes.

All current exports passed encoded true-peak <= -1 dBFS, frame/duration/resolution and byte-identical approved picture-stream checks. EP08 retains native 3840×2160 for its 4K master. Numeric audibility checks are not a complete human listening review; no uninterrupted listening pass is claimed. Prior visual playback review remains applicable because picture streams are unchanged.

Both skills and mandatory sound docs now explicitly require the existing root clips plus category-folder recordings and reject procedural substitutes. Superseded episode exports were removed only after replacement checks; source/audio assets and review history are retained. See `render_cleanup.json` and `../renders/RENDERS.md`.
