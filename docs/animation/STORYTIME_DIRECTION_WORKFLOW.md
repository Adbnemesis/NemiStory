# Storytime direction: from a thought to a complete scene

This is the starting workflow for **new full storytime scenes**, using version 2 of the production kit. Live ink is one tool. A story also needs established artwork, prop contact, changing environments, acting, pauses, and selective sound. Version 1's two-hand comparison remains an isolated lettering test.

Read the [character pen guide](CHARACTER_DRAWING_PRODUCTION_KIT.md) and the relevant [Nemi](../Nemi_Animation_Personality_Guide.md) / [ADB](../../adb/docs/ADB_ACTING_GUIDE.md) personality guide. Preserve both rigs and all old episodes. New stage code sits under `common/storytime/production/` and never modifies those files.

## The repeatable workflow

1. Write a spoken thought and save it alongside a beat sheet. Keep sentences conversational. Give the drawing a second job: evidence, contradiction, an aside, a revision, or context. Do not decorate every noun.
2. Record/generate the approved voice. Measure actual word/pause times; do not estimate a ten-second voice from word count. Save source text, speaker identity, audio path and timing annotations. If voice is not ready, use a silent study with `audio: null`, `script: []`, and no mouth cues.
3. Choose a shot for each change of thought. Establish a place, show a relevant object, enter a mental image, return to a reaction, or hold on the aftermath. A scene cut should have a reason. Do not rotate through backgrounds simply to fill time.
4. For each beat choose **one primary visual action** from the decision table. A fully drawn illustration is often the right answer. Use live drawing when watching the idea emerge or change is the point.
5. Choose a character performance recipe. Add gaze/hand refinements only when their intent is clear. Let eyes register the idea before the body and hand commit. Plant the feet during standing speech; use a separately blocked action for stepping/walking.
6. Write all cues as seconds from the same scene start. Link simultaneous drawing/VFX/SFX to a named event so the validator checks that they land together. Captions and mouths use the same voice times.
7. Validate before rendering. Render a separate ten-second proof, inspect intermediate frames and playback, and check speech/sound audibly. A successful export is not artistic approval. Revise only the new scene.
8. Save the spec, beat sheet, timing annotations, assets, QA result and reproduction commands. Update this guide when adding a field/kind/API. Push source and small review artifacts; retain raw movies and generated audio locally.

## Which visual action serves this thought?

| Story need | Primary choice | Movement / sound |
|---|---|---|
| Establish who/where | Room/paper/evening shot + existing pose | One motivated glance; often silence |
| State an already-known fact | `mode: hold` illustration | Fully inked from entry; no forced pen reveal |
| Interact with an object | Held prop + grip attachment | Hand/forearm travels, prop follows palm |
| Build an idea or revise a claim | `mode: live` drawing | One pen action; optional quiet scratch cue |
| Show what the speaker imagines | Cut to `thought` shot | Change framing/content; no mandatory whoosh |
| Deliver a dry line | `deadpan` | Still silhouette; remove unrelated accents |
| Reaction or recognition | Soft face/weight change | At most one short VFX accent |
| Aftermath | Hold or return to room | Leave space; do not immediately add another event |

Do not impose a fixed percentage of live drawing. In the saved ten-second proof most art is held; only a scratch-out and its replacement lettering reveal live. This is an example of purposeful variety, not a sequence to repeat in every story.

## Existing rigs, better directed acting

`ActingTimeline.gd` adds refinements externally to the existing sixteen conversational recipes and twelve new combinations (six per character). No character definition, pose library, hand renderer or expression renderer is rewritten.

| Added recipe | Purpose |
|---|---|
| `prop_present` | Show an object with a small arm/wrist arc |
| `weight_shift` | Hip leads a change of mind; feet keep contact |
| `soft_shrug` | Asymmetric doubt, then wait |
| `lean_in` | Small forward commitment without foot travel |
| `quiet_recoil` | Restrained backward response to recognition |
| `recover` | Return to composure and hold |

The original recipes are `listening`, `explaining`, `uncertain`, `skeptical`, `embarrassed`, `pleased`, `deadpan`, `realization`. Recipe data lives in `common/storytime/performances/recipes.json`; use these exact names.

Version 2 softens numerical facial controls across up to 120 ms, with gaze orienting within 90 ms. Body/head follow; upper arm/elbow starts before forearm/wrist. A single bounded gesture arc provides travel and settle, not an endless sine loop. Hand shape changes during the gesture. Nemi's mouth uses the existing exaggeration scale at 0.85 for restrained conversational opening. Discrete mouth/face accents remain authored choices; this is not a new continuous face rig.

Nemi's standing leg chains use an external two-bone solve against fixed foot targets. Pelvis height is corrected when a target would exceed leg reach; knees share a consistent bend direction rather than crossing or forming a wide bow-legged stance. ADB's existing foot offsets compensate for pelvis/leg lean, while knee controls carry weight changes. Targets are local to the actor's shot placement: a cut can change blocking, but a standing gesture cannot drag a shoe around within the shot.

The stage owns the clock and disables autonomous processing on **its own instances** so procedural timers cannot fight these controls. Do not run another acting director on the same instance. `grounded: false` is an explicit escape for a separately authored action; it does not generate a walk. Turns, seated contacts, steps, running, and object pickup paths still need authored choreography and individual visual review.

## Version 2 spec: use the saved example

Copy `common/storytime/examples/storytime_direction_10s.json`, or create a silent starter:

```sh
python3 tools/storytime/new_scene.py --author nemi --name my_new_story
```

The generator refuses overwrites and writes `scene.json` plus `SCRIPT_AND_BEATS.md` into a new folder. Use `--author adb` for ADB. Add another actor with a unique ID for dialogue. Do not create a new private scene clock or doodle engine.

| Field | Content / rule |
|---|---|
| version/title/duration/fps | `2`, title, seconds, `24`, `30` or `60` |
| audio | Narration-only mix at scene time zero, `res://` path or `null` |
| actors | `{id, author, performances, mouths?}`; unique IDs |
| performances | First at `0`; increasing `{at, recipe, duration?, blinks?, gaze?, hands?, grounded?}` |
| shots | Ordered `{id,start,end,background,actors,camera?}` covering the whole duration without gaps |
| shot actors | ID → `{position:[x,y],scale:number}`; absent actor is offscreen |
| camera | Optional `{center:[x,y],zoom:number}`; affects world/art/props together, not captions |
| drawings | Profile author, kind, `at`, `end`, position or attachment; optional mode/scale/tilt/layer/shots |
| props | Same spatial fields, `mode: hold`; ordinary objects are already drawn |
| mode | `hold` (default) or `live`; `live` requires positive `duration` |
| attach | `{actor,hand,grip:[x,y],angle?,socket?}`; palm socket follows existing hand controls |
| vfx | `{kind,author,at,end,actor?,offset?,position?,shots?,event?}`; maximum two seconds |
| sfx | `{file,at,duration,gain_db,event?}`; maximum 2.5 seconds, −60 to −6 dB |
| events | Optional `{id,at,intent}`; event-linked cues must use that exact `at` |
| script | Ordered nonoverlapping `{actor,start,end,text}` spoken turns |
| captions | Ordered `{start,end,text}` cards, maximum five words each |
| mouths | Actor's `{start,end,shape}` intervals; inside a visible speaker's turn |

All coordinates use a 1920×1080 world. Actor scale is a number; art scale is `[x,y]`. Ink widths scale with art. `tilt` and attachment `angle` are degrees. Layers: scenery below 0, attached props often 0 behind hands, actors 1, illustrations 2, VFX 5. A shot filter is an explicit array of shot IDs; it prevents old artwork leaking into a new environment. Otherwise a cue persists until its `end`.

Background kinds: `paper`, `room`, `thought`, `evening`. These are small authored environments, not automatic scene generation. Extend `Backdrop.gd` or add new authored assets when a story needs a different place; document the kind in the validator at the same time.

Art kinds: the character marks `arrow`, `circle`, `underline`, `scratch`, `question`, `spark`, `notebook`, plus production props `laptop`, `phone`, `mug`, `tabs`, `cloud`, and profile `text`. Production object construction is shared but takes each author's ink color; these new prop silhouettes are not all independently redesigned per character yet. Handwriting/mark identities remain separate. `SceneArt.gd` contains fill/ink geometry and avoids drawing hidden card borders through foreground paper.

VFX kinds: `realization`, `impact`, `sweat`, `focus`. They have finite reveal/settle lifetimes, are attached to the face or a world position, and disappear without lingering timers. Do not use all four in one reaction.

Hand overrides use existing supported shapes. Nemi: `relaxed`, `pointing`, `fist`, `open`, `open_palm_up`, `finger_count_one/two/three`, `splayed_fingers`, `pinch`, `hold_prop`, `hand_to_chest`, `hand_to_cheek`, `hand_to_mouth`, `facepalm`, `hands_together`, `grip_strap`. ADB: `relaxed`, `open_palm`, `pointing`, `fist`, `holding_cup`, `shrug_open`, `hand_to_chin`. ADB's cup grip supplies the supported wrapping fingers for the phone proof; `holding_phone` has an anchor name in the old hand controller but no distinct drawn hand shape, so this kit does not accept it as a new grip.

`grip` is the prop's local contact point. ADB defaults to its existing `get_prop_anchor()` palm socket; Nemi defaults to `[0,8]` on the hand bone. A custom `socket` overrides that local hand point. The stage solves `prop(contact) == hand(socket)` after acting, with parent rotation/scale respected. To hold another object, choose a compatible existing hand shape and author its grip rather than drawing a second replacement hand.

## Sound and mouth synchronization

Voice is primary. The renderer combines narration with each trimmed/delayed SFX at its cue time. Narration reserves 2 dB of headroom; SFX use their explicit gain. The live stage uses the same gains/times. Do not place an already SFX-mixed master in `audio` while also declaring those SFX, or they will double. Finish a final mix and listen for clipping/clarity. This kit does not impose automatic ducking, music, or sound on every reveal.

Use the existing [SFX catalog](../../common/audio/sfx/sfx_catalog.json) and its provenance records. No new external sound downloads were needed for this proof. Generate local voice files before live preview. The version-2 stage loads WAV/MP3/OGG directly, so fresh recordings do not depend on an editor import. Video export muxes audio directly and does not require the live players to run.

The proof uses fresh Sohee/Nemi and Aiden/ADB voice clips, actual word timestamps from the complete cached Whisper Tiny model, and selected existing conversational mouth shapes. Saved word timings are in `storytime_direction_words.json`. These are word-aligned vowel choices, **not measured phoneme boundaries**. For closeups or final episodes, author phoneme intervals or review/refine the word intervals by listening; do not claim automatic lip-sync accuracy from this demonstration.

The narration starts Nemi at 0.30 s and ADB at 5.30 s. The synchronized revision event is 6.12 s. After the dry line, the voices stop and the room holds quietly. See [the beat sheet](../../common/storytime/examples/storytime_direction_10s.beats.md) for why each shot exists.

## Run and reproduce

```sh
python3 tools/storytime/validate_scene.py common/storytime/examples/storytime_direction_10s.json
python3 tools/storytime/test_validator.py
python3 tools/storytime/test_production_validator.py
python3 tools/storytime/test_audio_mix.py
python3 tools/storytime/check_engine.py
"$GODOT_BIN" --headless --path . --log-file /tmp/storytime-production-tests.log --script tools/storytime/test_production.gd
python3 tools/storytime/render_scene.py --spec common/storytime/examples/storytime_direction_10s.json --output renders/storytime_direction/A_Tiny_Plan_10s.mp4
```

On a checkout without the locally generated proof voice:

```sh
HF_HUB_OFFLINE=1 .venv/bin/python tools/storytime/generate_proof_voice.py
python3 tools/storytime/prepare_direction_proof.py
```

The generator uses the project's existing cached Qwen CustomVoice setup; it does not bundle/download model weights. If the cache/runtime is absent, follow the project's voice setup or supply approved clips in the declared paths. Do not download gigabytes merely to run a structural check. For source-only validation use `--structure-only`; rendering still requires real audio assets. Resynthesized voices can have different timings: listen, reannotate `storytime_direction_words.json`, and update the beat times rather than assuming the old annotations still fit.

The exporter chooses stage version from the spec, rejects old episode spec/output paths, captures a fresh temporary movie, checks for script/render errors, checks duration, removes the startup frame, and muxes exact-duration audio/video. It does not publish or update existing episodes.

## Model handoff and quality boundary

A smaller model gets a starter, exact accepted fields/kinds, finite acting recipes, a shot grammar, explicit timing links, guardrails, and error messages. It should spend its effort choosing the thought and visual action, not inventing engine calls. Unknown fields, unsupported glyphs/hands, shot gaps, invalid attachments, mouth cues outside spoken/visible turns, and event timing drift are rejected.

Use this completion checklist: source/spec saved; no old episode edits; rig hashes unchanged; validation/engine checks passed; new render duration verified; ink and contact checked in stills; playback and speech/sound listened to; remaining limits recorded; source pushed with excluded local media recorded. Mark unperformed checks honestly. Good templates improve repeatability; they cannot make every model's artistic decisions identical.
