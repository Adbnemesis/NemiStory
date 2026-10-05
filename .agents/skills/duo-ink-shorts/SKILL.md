---
name: duo-ink-shorts
description: Create or improve Godot ink Shorts featuring both ADB and Nemi, with contrasting performances, a shared visual payoff, music sync and verified exports. Use for combined ink edits, reels or Shorts; excludes storytime episodes and thumbnails.
---

# ADB + Nemi ink Shorts

Direct **both ADB and Nemi**. Give each a distinct response to the same song, object or challenge: ADB's relaxed composure and small dry gestures meet Nemi's observant, warmer creative energy. Alternate the lead, then let a clear shared choice or reaction resolve the idea. Do not paste two identical solo performances into one frame. Show both meaningfully across the sequence; singles are useful when their reaction affects the partner's next beat.

Keep paired eyelines, relative scale and screen direction consistent. A held prop does not transfer between hands unless continuous contact is explicitly supported and authored; cuts to separately held poses are safer when the story does not need an exchange. Visible creative peers do not automatically establish relationship canon.

The matched starting examples are [Different energy](../../../shorts/godot/upgrade02/productions/different-energy/short.json) and [Act natural](../../../shorts/godot/upgrade02/productions/act-natural/short.json), with sibling `Edit.tscn` scenes. Read the closest example and its direction; create a new shared premise and payoff. For a single character, use `$adb-ink-shorts` or `$nemi-ink-shorts`.

## Start from the maintained engine

Work from the repository containing `shorts/godot/validate_ink.py`. An installed skill can resolve back to its repo through the script's real path; pass `--repo /path/to/adb` if needed.

Read [current Shorts rules](../../../shorts/AGENTS.md), [version-3 workflow](../../../shorts/godot/V3_WORKFLOW.md), [version-3 schema](../../../shorts/godot/V3_SCHEMA.md), and [character direction](../../../shorts/godot/CHARACTER_DIRECTION.md) before authoring. Read the relevant supported action/event/motion fields, rather than inventing APIs. Inspect the author-matched upgraded example below and its exported movie at phone size. Batch01 is approved style context, but its old version-2 timing does not meet the current pacing request.

All production source, downloaded music, intermediate media, reviews and exports stay under `shorts/`. These are separate music edits, not numbered storytime episodes. Godot draws every visual frame from editable vector art. No imagegen, generated bitmap characters, reference-video sprites, Remotion visuals or new private playback engine. Preserve original storytime episodes, rigs, pose/face/hand libraries and voice settings. Narration is absent by default.

## Direct a new edit

Save a brief beside `short.json`: premise, want, visible choice, consequence, payoff; then list thought beats with one audience focus each. Build a cute causal sequence, not a shuffle of poses. Choose a distinct visual device and palette/shading treatment for this idea. One small stable premise can help; do not turn it into caption-led storytime.

Use a total duration of **12–25 seconds**, chosen for the music phrase and payoff. No fully static image interval may exceed **1.5 seconds**. Use new visible poses, expressions, finite hand/head motion, purposeful reframes/travel and event-linked doodles to keep the thought developing. Tiny camera jitter, endless bobbing, constant random redraws and blinks alone do not satisfy the requested dynamism. Completed ink stays stable. The pacing tools catch temporal failures; they do not judge story clarity or guarantee an engaging edit.

Choose recognizable music whose energy fits the visual topic. Reuse a documented recording when it fits; download a new public recording/preview when authorized by the task. Read [saved music provenance](../../../shorts/assets/music/batch01/MUSIC_SOURCES.md) and the selected track's metadata/analysis. Preserve exact artist/version, source page/download URL, acquisition date, original and decoded hashes, selected source interval and gain. A preview's time is relative to that preview unless its full-song offset is known. Do not claim a current trend rank without fresh evidence. The user removed the copyright-selection gate.

Audition the section, then save a cue map linking important picture/gesture/doodle changes to source accents on the scene clock. Use the maintained audio-analysis tools; onset candidates are not automatically confirmed downbeats. Picture times are integer frames at 30 fps, audio positions seconds. Use original recorded root/category SFX only when they strengthen a named event; preserve their inventory provenance and hash. Do not synthesize substitute SFX or use a meme vocal as new character dialogue.

Copy the matched version-3 `short.json` and `Edit.tscn` into a new production folder under `shorts/godot/`; change the scene's `config_path` to the new spec. Author supported cues, per-actor visible `motion`, shots/travel and finite events. Keep attached props locked to their fingers. Use genuine separately drawn views. Cut between contact drawings if a continuous pickup/handoff has not been authored. Extend only separate Shorts art/director files when necessary, updating the schema and an executable example together.

## Render and verify

Run the bundled wrapper from the repository root; replace the production and revision:

```sh
.venv/bin/python .agents/skills/duo-ink-shorts/scripts/build_short.py validate shorts/godot/PRODUCTION/short.json
.venv/bin/python .agents/skills/duo-ink-shorts/scripts/build_short.py stills shorts/godot/PRODUCTION/short.json --revision r1
.venv/bin/python .agents/skills/duo-ink-shorts/scripts/build_short.py build shorts/godot/PRODUCTION/short.json --revision r1
```

Inspect the stills before the full build. For an already-rendered movie:

```sh
.venv/bin/python .agents/skills/duo-ink-shorts/scripts/build_short.py check shorts/godot/PRODUCTION/short.json --movie shorts/godot/PRODUCTION/renders/ID_r1_1080x1920.mp4
```

The wrapper enforces this skill's author scope and version 3, then uses the maintained validator/renderer. A build/check independently inspects the decoded export, verifies exact-source audio and checks decoded static runs. It fails if audio or pacing fails, or if the pacing evidence is missing. Use a fresh revision; the renderer preserves earlier movies.

Watch the actual exported movie with sound at phone size. Check the first/final image, causal payoff, face/hand readability, contact at motion boundaries, useful pose variety, actual music synchronization, finite VFX and SFX balance. Repair failures and rerender; do not declare success from logs or contact sheets alone. Save only performed observations in `review/QA.md`, plus the technical reports, cue map, source/music provenance and selected revision. The wrapper's technical-pass record deliberately leaves visual/playback review pending.

For a batch or shared-engine change, take the maintained isolation snapshot before work and run its comparison afterward; record authorized skills/routing changes separately from protected episode/rig source. Keep older ink revisions until the replacement passes. Delete rejected legacy prototypes only within an explicit cleanup request. Deliver the playable checked movie and editable source; publishing, messaging others and unrelated episode edits require their own authorization.
