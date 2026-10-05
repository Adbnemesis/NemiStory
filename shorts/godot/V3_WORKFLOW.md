# Godot ink Shorts production workflow

This is the active 12–25 second music-edit format for ADB, Nemi and their duo. It is separate from narrated storytime episodes. Use the corresponding adb-ink-shorts, nemi-ink-shorts or duo-ink-shorts skill. No AI image generation, Remotion visual render, narration by default or existing episode modification.

1. Read V3_SCHEMA.md, CHARACTER_DIRECTION.md and the corresponding current example. Write DIRECTION.md before the spec: relatable promise, character want, tiny choice, consequence, cute payoff, one focus for each beat, and why this track section supports it. Preserve source music/hash and report evidence honestly. Do not call a track trending without a current source.
2. Choose 12–25s around the music phrase. Read source onset analysis; convert scene seconds to frame=round(seconds*30), not arbitrary equal intervals. Use a mix of full-body, hand/detail and face framing. Each change must show a new action, reaction, idea or musical accent. Repeated close crops do not add poses.
3. Author a version 3 short.json and editable Edit.tscn using DynamicEdit.gd. Keep scripts, source and QA together under shorts/godot/upgrade02/productions/<unique-id>/ or a new explicitly named production root. Use visible motion keys, coherent head turns, eyes/blinks, settling hand gestures and restrained finite camera follow. Keep feet grounded. Completed doodles stay still; live path reveal lasts only where drawing matters. Named VFX/SFX events support the thought, not an effects quota.
4. Create CUE_MAP.json with sourceStart, frame/scene/source times, musical accent evidence/offsets and event purpose. Use the actual recorded SFX inventory and exact hashes. Store only honest source metadata; no music licensing approval gate is part of this requested workflow.
5. Run the skill wrapper `validate`, then `stills` with a fresh revision. Inspect rendered hands, sleeve count, phone/book contact, profile/back honesty, author identity, palette legibility, frame safety and final payoff. Compile success is not visual success. Revise source and render a fresh revision when art fails.
6. Use wrapper `build SPEC --revision rN`. It renders the entire clip in Godot and runs export, mix and decoded pacing checks. Superseded movies are retained until replacement QA passes. Keep generated media local and source/QA small for Git. Wrapper `check SPEC MOVIE` verifies an existing export. Maximum still hold1.5s; numerical movement alone is not a finished performance.
7. Watch the complete movie at real speed with music, seeking every story change. Inspect the loop/ending, full body and prop closeups. Record exactly what was checked under review/QA.md; automated checks, inspected stills and real playback are distinct evidence. Do not mark creative review passed based on files existing.
8. Write review/current.json, review/RENDERS.md and actual music/SFX/pacing reports. Link final movies and skill source in the review gallery. Source delivery may be pushed with standing repository authorization; exclude generated music/video, caches, large binary files and secrets. Audit original adb/, nemi/, common/, docs/animation/, tools/storytime and project settings against a pre-change snapshot.

## Reusable checks

From the project root, choose the correct skill helper:

```sh
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py validate shorts/godot/upgrade02/productions/my-song/short.json
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py build shorts/godot/upgrade02/productions/my-song/short.json --revision r1
```

Read `--help` before invoking the helper; its scope check prevents producing the wrong author. Native Godot movie capture needs a desktop session. An error must stop export: unknown fields, missing audio, stale hashes, script errors or absent completion marker are never bypassed.

## Skill demonstrations

Each newly created skill must be forward-tested on a new production, not merely described or applied retroactively to the same five. Save the invoked skill, request, source decisions, validation/export/audio/pacing results and human-visible art/playback observations in SKILL_USE.md. Another model should be able to reproduce the result from that source and the skill without relying on chat history.
