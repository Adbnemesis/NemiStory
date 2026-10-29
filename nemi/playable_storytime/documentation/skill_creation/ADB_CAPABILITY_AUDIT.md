# ADB playable-video capability audit

Read-only audit of the current source on 2026-10-27. No active episode, engine,
voice, rig or skill source was changed. The audit read the current skill-creator
instructions, ADB storytime skill, relevant playable compiler/export source,
shared stage/validator, canonical voice configuration and existing voice tools.

## Decision

The ADB skill can define and execute the complete creative/production workflow,
including a scoped author adapter when the first ADB game is requested. It must
not claim that today's Nemi command is a tested turnkey ADB command. The shared
animation stage already supports ADB, but the isolated playable compiler,
validator and voice wrapper are presently Nemi-specific. A skill is guidance,
not an implemented runtime feature or evidence of a rendered ADB game.

Do not silently call the Nemi pipeline, substitute Sohee, relabel a Nemi rig,
replace ADB's mouth shapes, or render ADB with Nemi handwriting. Creating a new
ADB game normally authorizes the reversible implementation work needed for a
scoped adapter; routine implementation does not require another permission
question. If a necessary capability cannot be implemented safely, report the
concrete limitation instead of inventing an existing API or a successful test.

## Existing ADB foundations

| Capability | Verified source |
|---|---|
| Canonical rig | `adb/characters/adb/ADB.tscn`, selected by `common/storytime/StorytimeStage.gd`'s `Scenes['adb']` |
| Version-2 production stage | `common/storytime/production/ProductionStage.gd` instantiates each `item.author`; it is not Nemi-only |
| Acting and face controls | `common/storytime/production/ActingTimeline.gd` selects ADB expressions/face fields and `adb/poses/ADBPoseLibrary.gd` |
| Acting recipes | `common/storytime/performances/recipes.json` contains separate author catalogs |
| ADB ink/lettering | `common/storytime/profiles/adb.json` and `adb_lettering.json`; compact technical print, ink `#303944`, accent `#8a6245`, author-specific mark geometry |
| Scene validation | `tools/storytime/validate_scene.py` / `validate_production.py` accept `author: adb` and ADB's own mouth vocabulary |
| ADB canonical voice | `tools/tts/config.py: ADBVoiceConfig`, used by `tools/generate_adb_voice.py` |
| Approved-recording pacing | `tools/storytime/prepare_voice.py` accepts both authors; no speech synthesis and no overwrite |
| Final-word alignment | `tools/storytime/align_voice.py --actor adb` uses the cached recognizer; approximate words remain review-required |

`nemi/playable_storytime/tools/bootstrap.py` initially includes the ADB rig,
poses and shared production stage in its dependency snapshot. That asset
presence alone does not make the Nemi production wrapper ADB-compatible.

## Concrete adapter requirements

| Current Nemi-only assumption | Required ADB treatment |
|---|---|
| `tools/prepare_episode.py` sets dialogue speaker, script/caption actors, drawings, props, VFX and scene actor to `nemi` | Use an explicit supported author profile throughout all tracks and IDs; inspect callers rather than replacing every text occurrence |
| Compiler emits Nemi mouth names `o_u`, `ae`, `small_open` | Select actual supported ADB mouth shapes such as `talk_round`, `talk_wide`, `talk_open`; author/check them against the final recording |
| `tools/voice.py` imports `NemiVoiceConfig`, selects Sohee, writes Nemi actors/provenance, checks `word.actor == 'nemi'` | Reuse the exact canonical Aiden configuration in an author-specific or parameterized wrapper, with separate source/alignment/provenance validation |
| `tools/validate_episode.py` requires every illustration author to be Nemi and restricts transport to the canonical Nemi actor | Add an explicit supported author contract and validate the chosen canonical actor without weakening unrelated route/material/contact rules |
| `tools/continuity.py` indexes `shot['actors']['nemi']` | Derive the declared canonical actor and verify its actual endpoint/scale; retain transport delta and landmark checks |
| `DrawingWorld.gd` has fixed Nemi warm ink and object drawings | Apply the selected author's maintained ink/mark style; sharing world geometry must not imply shared handwriting or automatic Nemi-coloured ADB art |
| Episode-002 specialized builder uses Nemi-specific actor IDs, placements, eraser story assumptions and three hard-coded choice groups | Use it as a mechanism example only; create a new game compiler/spec appropriate to the new story, supported assets and chosen actor |
| `PROJECT`, `source_ref`, `safe`, `sync_episode` and resource roots point to `nemi/playable_storytime` | Make an explicit production-root adapter or maintained parameterized path route; preserve current Nemi projects and reject writes outside the selected new production boundary |

`RenderPlayable.gd` is mostly reusable: it projects four environment viewports
and a canonical `ProductionStage` texture, places that texture on the declared
actor wall, and applies a seekable vehicle delta to the stage. Its default
scene path is Nemi-specific; there is no verified existing ADB end-to-end
export command in this audit. Preserve the shared implementation and add a
small author/path adapter rather than inventing a separate private player.

Before a first ADB production, resolve the production folder using current
repository instructions and the ADB storytime preparation route. New numbered
episodes belong under `adb/episodes/epNN_<slug>/` when that route applies.
Keep any new playable tooling, game-specific assets and generated evidence
scoped to the selected new production/framework. Do not migrate old episodes,
edit rigs, mutate the frozen approved Nemi game, or place a new ADB production
inside Nemi simply because today's wrapper only accepts that root.

## Canonical voice facts and tool limits

`ADBVoiceConfig` currently specifies:

- Model `Qwen3-TTS-12Hz-1.7B-CustomVoice`, repository
  `mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`.
- Speaker and voice identifier `aiden`; English, 24,000 Hz; base speed 1.00.
- Exact identity prompt: “Cool, relaxed young adult male around 24, calm
  conversational speech, confident, subtle dry wit, understated and natural.”

The ADB storytime skill is the current authority for retaining this identity
and his restrained physical acting/dry conversational flow. Historical voice
profile tables include slower synthesis-speed examples; current refinement
and recording-preparer policies take precedence. Do not import Nemi's
particular R9 tempo choices or assume every ADB passage needs acceleration.
Choose phrase pace by listening and the game's immediate thought. Preserve
intentional dry holds and emotional breaths; remove repetitive explanatory
slack, not character identity.

`tools/generate_adb_voice.py` is a real existing CLI with `--script`, `--output`,
`--project-id`, `--title`, `--speaker`, `--prompt`, and
`--anim-voiceover-dir`. For a new game, use a fresh explicit output folder and
the locked default Aiden identity. Do not use a different `--speaker` or a
custom `--prompt` to approximate Nemi's energy. The optional animation sync
path can delete/recreate its segment directory; do not use it to overwrite
an existing production. Its defaults name an old intro project, so a skill
must not present a bare invocation as safe new-game setup.

`tools/storytime/prepare_voice.py` accepts hash-bound source recordings,
authored source bounds, per-clip tempos in 1.00–1.15, measured source words
and explicit scene placement. It requires a new nonexistent folder under
`renders/`. Its `alignment_kind` is transformed source times, which are
planning data; after timing edits, obtain/check final processed-word
alignment instead of claiming fresh measurements from that transform.
`align_voice.py` accepts `--audio`, `--actor adb`, and `--output`; it refuses
existing outputs and protected episode-output annotation locations. Respect
those real boundaries; do not bypass them or invent other flags.

## Minimum evidence before claiming ADB runtime support

1. An author-specific schema/voice/actor test that rejects Sohee/Nemi data in
   the ADB route and keeps current Nemi validation intact.
2. A fresh ten-second ADB mechanism proof through the maintained renderer,
   showing his canonical face/mouths, full-body support and one actual game
   interaction, plus a 30–60-second integrated sequence when broader changes
   require it.
3. Actual stills and playback/listening checks, recorded separately from
   parsing or export success. Include hands, wrists, feet, object contact,
   visible clues and a native-preserved viewing direction.
4. A complete current 1080p cut, real encoded duration/digit destinations,
   authored chapters, full decode and metadata checks. A Nemi movie or
   generic two-author technical sample is not an ADB game proof.
5. Exact current-full-1080p user satisfaction before 4K; unchanged upload
   clock and exact-file platform verification after any final edit. Never
   inherit the current Nemi game's approval or claimed YouTube testing.

The skill should keep these as an explicit initial capability check and
production responsibility, not as a permanent warning that stops otherwise
authorized work. Story design can proceed while scoped adapter work happens.
