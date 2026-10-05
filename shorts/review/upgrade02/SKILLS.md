# Three ink-edit skills

Canonical editable skill source is saved in this repository. Discoverable local links are installed at `/Users/talus/.codex/skills/`. Repository routing selects the skill by cast; storytime episodes retain their own separate skills.

| Skill | Use | New demonstrated Short |
| --- | --- | --- |
| [adb-ink-shorts](../../../.agents/skills/adb-ink-shorts/SKILL.md) | ADB solo: composed gestures, precise thought, dry reaction | [One big idea](../../adb/adb-big-idea/SKILL_USE.md) |
| [nemi-ink-shorts](../../../.agents/skills/nemi-ink-shorts/SKILL.md) | Nemi solo: curiosity, creative exploration, expressive recovery | [Just one tiny moon cat](../../nemi/nemi-tiny-cat/SKILL_USE.md) |
| [duo-ink-shorts](../../../.agents/skills/duo-ink-shorts/SKILL.md) | Both: different responses, alternating lead, shared earned payoff | [Our matching pose](../../duo/duo-matching-moment/SKILL_USE.md) |

Example requests:

- `$adb-ink-shorts make a 12–25 second ADB ink edit where a confident idea stalls, then one tiny inspiration saves it`
- `$nemi-ink-shorts make a playful music-led Nemi ink edit with a doodle transformation and a cute reaction`
- `$duo-ink-shorts make an ADB and Nemi edit where their contrasting poses resolve in one matching gesture`

Each skill supplies author direction, links the strict current schema/workflow/examples, and provides a scoped `scripts/build_short.py` helper. The helper rejects wrong casts, old-version specs, unknown controls, changed/missing audio, invalid source sections, failed decoded sound and static holds over 1.5s. It leaves creative playback review explicit; it cannot certify taste or platform performance.

Forward testing used a new production per skill and the actual helper, rather than merely renaming previous exports. The tests found and corrected obsolete v2 routing and a `check --movie` command ambiguity. The shared validator also passes 18 tests including unsupported back prop contact, invalid motion/travel, overlong particles and an actual decoded static-movie fixture. Character art sheets and intermediate contact/motion phases were inspected in Godot.

Future models need no chat history: read the skill and its referenced source, write the brief/cue map, author supported version 3 controls, inspect a fresh still proof, run build/check, review actual playback and save evidence. The installed skill source remains editable and versioned with the project.

The helper `new <short-name>` now creates the cast-matched canonical folder and editable starter. Use shorts/adb/<short-name>/, shorts/nemi/<short-name>/ or shorts/duo/<short-name>/; movies belong in render/, evidence in review/. The helper refuses overwrites and rejects mismatched casts. Starter source deliberately has no inherited QA approval. See [folder guide](../../godot/V3_WORKFLOW.md#folder-layout-and-starting-command).
