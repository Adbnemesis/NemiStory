# ADB + Nemi · Godot ink Shorts

The active format is a 12–25 second music edit: author-specific ink, gray washes/hatching, visible head/eye/hand motion, meaningful pose edits, finite doodle/VFX events and a cute causal payoff. Maximum static hold 1.5 seconds. Godot draws every visual frame.

[Watch the eight edits](review/upgrade02/index.html) · [Production and checks](godot/upgrade02/README.md) · [Three skills](godot/upgrade02/SKILLS.md) · [Workflow](godot/V3_WORKFLOW.md) · [Schema](godot/V3_SCHEMA.md)

Five revised edits retain the approved music and ideas while adding authored gestures and faster development. Three new edits demonstrate the ADB, Nemi and duo skills. Every production has an editable Edit.tscn, short.json, direction, source-clock cue map, music provenance, native portrait movie and review evidence. Earlier accepted [batch01](review/batch01/index.html) and the [original ink proof](review/rebuild/index.html) remain as style history.

Use `$adb-ink-shorts`, `$nemi-ink-shorts`, or `$duo-ink-shorts`. Canonical source lives in this project’s `.agents/skills/`; discoverable local skill links are installed in the user's Codex skills folder. Each helper enforces cast scope, version 3, actual export/audio/pacing checks, and leaves visual review explicit. The active rules automatically route ink Shorts requests to these skills; narrated storytime keeps its existing separate preparation workflow.

The famous music recordings are the exact official public previews cataloged under [assets/music/batch01](assets/music/batch01/MUSIC_SOURCES.md). Original/decoded hashes, source URL/version, selected ranges and musical accent evidence are saved. SFX uses exact existing recorded clips. Source mix reconstruction and encoded timing checks accompany every delivery.

New visible art is separate editable Godot curves/polygons in DynamicPoseArt.gd and DynamicAccentArt.gd. Original storytime rigs are sampled only as hidden instances; they do not supply the visible supplemental illustration. The engine provides authored supported contact drawings and finite motion, not automatic walking/physics/prop exchanges. Original episodes, character definitions, poses, expressions, hands, voice source and project settings are protected by the isolation audit.

## Reproduce

```sh
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py validate shorts/godot/upgrade02/productions/my-song/short.json
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py stills shorts/godot/upgrade02/productions/my-song/short.json --revision r2
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py build shorts/godot/upgrade02/productions/my-song/short.json --revision r2
```

Choose a fresh revision. The native portrait Godot renderer stops on errors. FFmpeg only packages capture/source audio; it does not provide visual animation. Source and small QA records can be committed; music, movies and generated stills stay local. Existing public previews can be fetched again with assets/music/batch01/fetch_music.py; revalidate hashes and timings if a catalog recording changes.

Serve the range-aware gallery with `.venv/bin/python shorts/tools/review_server.py`, then open `http://127.0.0.1:8768/shorts/review/upgrade02/index.html`.

The rejected Leg Day, Ship the Machine, Tiny Change and Quick Sketch prototypes, their31 generated movies and obsolete Remotion pipeline were deleted on the user's explicit request. [The cleanup manifest](godot/upgrade02/review/legacy-cleanup.json) lists the exact targets. Original storytime episodes and accepted ink edits were excluded. Supplied references and [reference analysis](REFERENCE_ANALYSIS.md) remain available.
