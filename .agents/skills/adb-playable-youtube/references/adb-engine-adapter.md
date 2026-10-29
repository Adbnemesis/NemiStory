# ADB capability and adapter

The canonical shared stage supports ADB; existing Nemi playable wrappers are not author-neutral even though bootstrap includes ADB assets. Treat this as an implementation checkpoint, not a reason to stop authorized new-game work. Reinspect current code because a maintained author adapter may later resolve these gaps.

## Existing foundations

- `adb/characters/adb/ADB.tscn`, selected through `common/storytime/StorytimeStage.gd` and `production/ProductionStage.gd`.
- `adb/poses/ADBPoseLibrary.gd`, author-specific faces/hands and `common/storytime/performances/recipes.json`, used by `production/ActingTimeline.gd`.
- `common/storytime/profiles/adb.json` and `adb_lettering.json`: compact measured pen, ADB mark geometry. Current ink`#303944`, accent`#8a6245`; read current profiles rather than copying Nemi colours/handwriting.
- `tools/tts/config.py: ADBVoiceConfig`: exact canonical Qwen CustomVoice1.7B/Aiden, English24kHz and locked cool/relaxed male identity. Use current settings, not a stale prompt copied into a skill.
- `.agents/skills/adb-storytime/SKILL.md`, canonical preflight, version-2 validators/renderer: author preparation authority.

## Audit and adapt these real assumptions

| Current Nemi wrapper | ADB requirement |
|---|---|
| `prepare_episode.py` speaker/actor/script/caption/drawing/prop/VFX author | Explicitly select ADB throughout all tracks and ownership. |
| Nemi mouth mapping `o_u`, `ae`, `small_open` | Select actual ADB vocabulary such as `talk_round`, `talk_wide`, `talk_open`; verify rig/recording, not blind renaming. |
| `voice.py` NemiVoiceConfig/Sohee, cache/provenance/word-actor checks | Exact Aiden config and author-specific identity/cache/alignment validation. |
| `validate_episode.py`, `continuity.py` Nemi author/transport/shot lookup | Validate declared ADB actor, actual endpoint/scale, support and landmarks without weakening other checks. |
| `DrawingWorld.gd` fixed Nemi warm pen | Reuse geometry with ADB's maintained ink/mark identity. |
| Episode002 builder | Replace Nemi/eraser/paper/three-choice assumptions with the new story's supported author/compiler. |
| `PROJECT`, `safe`, `source_ref`, `sync_episode`, resource roots | Support selected ADB production explicitly; reject unrelated writes. An ADB CLI folder alone does not override a Nemi-only boundary. |

`RenderPlayable.gd` projects environment viewports plus canonical stage texture on the declared actor sector. Reuse/adapt that maintained mechanism; its default path is Nemi-specific. Do not claim an existing turnkey ADB export command or build a separate private player.

Choose the new production folder from current repo rules; canonical numbered episodes normally belong in `adb/episodes/epNN_<slug>/`. Scope new tooling/assets to that production/framework. Do not place ADB in an old Nemi episode, mutate accepted frozen inputs, edit canonical rigs or weaken Nemi validation. When a new ADB game is authorized, perform the reversible author/path adapter work autonomously and continue useful design in parallel.

## Existing voice CLI limits

`tools/generate_adb_voice.py` exists, but defaults identify an old intro project. Inspect help; use fresh explicit script/output/project-id/title. Keep canonical Aiden/identity, no alternate speaker or custom prompt to imitate Nemi. Optional `--anim-voiceover-dir` synchronization may delete/recreate its segment target; omit it unless that exact fresh target is intentionally owned by the new production.

`tools/storytime/prepare_voice.py` processes approved hash-bound recordings, authored source bounds/placements and pitch-preserving tempo into a new nonexistent folder under `renders/`; it does not synthesize. Its transformed source-word times are planning data. Obtain/check final processed alignment through actual `tools/storytime/align_voice.py --audio <new-audio> --actor adb --output <new-words.json>` with its path restrictions. Never overwrite protected annotations or invent flags. Preserve sources and failed takes.

## Prove support before a full promise

Test author selection and rejection of Sohee/Nemi metadata or mouths in the ADB route; preserve existing Nemi behaviour and all timing/material/contact invariants. Render a fresh ADB mechanism proof through the maintained stage: canonical face/mouths, full-body support and an actual game action/direct seek. For broader changes inspect a30–60s integrated story too. A Nemi movie or generic two-author example is not an ADB game proof.

Then produce the complete current1080p ADB cut with actual encoded time/digit map, props/directions/contact review, metadata and separated listening/playback checks. Obtain its own user satisfaction before4K; never inherit Nemi approval. Exact native upload/phone tests remain separately recorded.
