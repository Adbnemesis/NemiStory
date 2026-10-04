# Reproduce the episode

Run from the repository root with the existing Godot, FFmpeg and Python environment. Do not replace canonical voice settings or download another model. Original recordings and prepared narration are retained locally under renders/adb_school_crush/.

1. `python3 adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/tools/build_episode.py` rebuilds the measured scene from retained source recordings, selected alignment and direction.
2. `python3 tools/storytime/validate_scene.py adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/scene.json` validates the version-2 spec.
3. `python3 tools/storytime/render_scene.py --spec adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/scene.json --output adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/renders/ADB_EP01_new_1080p.mp4` renders a fresh full export.
4. Add `--4k` with a new output filename for native 3840×2160. The shared renderer checks captured dimensions and frame count before replacing the output. Run one capture at a time.

For a proof, add `--start 74 --duration 10`; for the integrated review, use `--start 52 --duration 48`. Preserve earlier movies. Inspect moving playback as well as stills and listen at ordinary volume. Current perceptual listening is unverified; see review/STATUS.md for the checks actually completed.

Voice generation and alignment tools preserve source hashes and canonical Aiden identity. Re-generating voice requires remeasurement and a new alignment; do not reuse timing from a changed recording. Large media remain local and are excluded from Git.
