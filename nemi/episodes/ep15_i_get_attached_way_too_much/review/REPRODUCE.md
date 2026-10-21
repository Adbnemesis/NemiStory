# EP15 current production source

The current R5 cut is directed by `scene_r5.json` and `tools/build_episode_r5.py`. Runtime150.2seconds (2:30.2) meets the user's150–180second request. Previous R4 `scene.json` and `scene_r4_1080p.json`, R3/R4 movies, original voice and earlier QA remain preserved.

Stable source branch: `codex/nemi-ep15-review`. Current picture/mix source commit: `8a3f9c5`. Active managed checkout: `/Users/talus/.codex/worktrees/nemi-ep15-review/adb`. This isolated checkout avoids unrelated simultaneous production changes invalidating the exact render input signature. The renderer was not bypassed.

Run the episode builder with the retained narration/SFX present, then the normal validator/renderer:

```sh
python3 nemi/episodes/ep15_i_get_attached_way_too_much/tools/build_episode_r5.py
python3 tools/storytime/validate_scene.py nemi/episodes/ep15_i_get_attached_way_too_much/scene_r5.json
python3 tools/storytime/render_scene.py --spec nemi/episodes/ep15_i_get_attached_way_too_much/scene_r5.json --output nemi/episodes/ep15_i_get_attached_way_too_much/renders/NEW_REVISION_1080p.mp4
```

`tools/build_voice_plan_r5.py` reconstructs the exact R5 narration from the12hash-verified original Sohee recordings, fixed silence bounds and existing approved phrase tempos. It emits transformed exact word times and old/new map. The scene builder derives a copy of that metadata with61 city word actor aliases solely to support two non-simultaneous instances of the unchanged Nemi rig. Audio, author, source hashes and word intervals are identical. Do not synthesize replacement sources and reuse these timings.

Voice originals, final narration and movies remain local; generated media is excluded from Git. Main-checkout files are synced for convenient review, but its unrelated shared source is not the reviewed isolated input signature. Future4K must use this exact isolated spec/input signature and the actual user's satisfaction quote through the normal approval gate. No quote/receipt exists yet.

Logs, audio reports and capture stamps belong in `review/render_records/`; movie indices belong in `review/RENDERS.md`. Keep the stable checkout, all revisions, declared voice/SFX and review evidence until the user-approved final4K passes; only then apply episode-scoped final-only retention.
