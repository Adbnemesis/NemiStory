# Current Nemi tooling

Resolve the repository root before commands; this install uses `/Users/talus/Documents/adb`. Inspect current help/schema when reusing or extending a capability.

- `.agents/skills/nemi-storytime/SKILL.md`, `docs/animation/EPISODE_START.md`, `tools/storytime/preflight.py`: current preparation and reading gate.
- `common/storytime/examples/story_review_48s/scene.json` and its review guide: supported integrated acting/production example.
- `nemi/playable_storytime/engine/godot/SCHEMA.md`, `DRAWING_MATERIAL_PROFILE.md`, `documentation/ARCHITECTURE.md`: panorama/object contracts.
- `nemi/playable_storytime/tools/{prepare_episode,validate_episode,continuity,voice,render,spatial_metadata,media_qa,digit_media_qa,result_media_qa}.py`: actual maintained mechanisms; inspect the relevant implementation before authoring an adapter or command.
- `nemi/playable_storytime/episodes/episode_002/`: starter story, locations, gameplay, scene, compiler and honest `review/visibility_pace_r9/` evidence. Inspect actual art/movie frames when treating it as a visual reference. The user accepted it for starters, not as an exceptional creative benchmark.

Current exact voice settings live in `tools/tts/config.py: NemiVoiceConfig` and approved sources; isolated voice tooling verifies copied implementation/source hashes. New processed timing does not require replacing a canonical source take.

## Do not replay a story-specific compiler

Episode002's `author_*`/`build_full_game.py` encode its ten scenes, actor sectors, three decision pairs, paper arrival, eraser movement and ending. Do not use them unchanged for another story. Create an episode-local supported compiler/spec, reusing general validation/projection/canonical acting rather than copying plot assumptions.

Current isolated helpers constrain their root to `nemi/playable_storytime`; they are not generic repo-path APIs. Canonical numbered episodes follow current repository folder rules. If the selected new folder lies outside that helper root, implement a scoped maintained root adapter and prove it, or use the canonical stage with a validated spherical integration. Do not bypass `safe`, `sync_episode`, preflight or protected annotations; preserve accepted frozen games.

For an existing compatible isolated episode, use this dependency order:

1. Preserve previous source/audio, author the story/gameplay clock and supported locations.
2. Emit dialogue with its compiler/initial preparation stage.
3. Process/generate and check exact canonical audio using the existing `.venv/bin/python` route; mismatched narration must be preserved, not overwritten. Review final word alignment and safe display corrections.
4. Compile final-word anchors, calibrate with `tools/mix.py`, then recompile so picture references current calibration.
5. Validate scene, panorama, support/transport, routes and input contract. Use the maintained renderer for proofs/full cut.
6. For specialized picture, `tools/produce.py --episode episode_NNN --revision rN --render-only` keeps compiler adaptations; generic preparation in its normal path can overwrite them. Inspect before using.

Do not bootstrap/sync, build active audio, mutate engine source or run a fixture that changes frozen inputs during capture. The exporter must reject a concurrent snapshot change. Parallel reads, docs and existing-media review are safe.

Compatible export syntax is `python3 nemi/playable_storytime/tools/render.py --scene <actual-scene.json> --mode sphere --output <new-file.mp4>`. Use `--start`/`--duration` only for proofs; `--4k` requires the exact receipt. Never reuse a movie filename. `produce.py` currently packages1080p reviews; do not invent a4K option. Use `spatial_metadata.py inject <raw.mp4> <new-tagged.mp4>` and its inspector, then actual media/digit QA.

Switch `previews/current.json` only after the exact new movie/timeline/revision/runtime pair passes. Verify endpoint and ranges. Source tables, simulated DOM tests and sampled image sheets do not establish real browser/native YouTube compatibility.
