# Two characters, two drawing hands

For full new productions, first use [the current refinement workflow](STORYTIME_REFINEMENT_WORKFLOW.md) and [version-2 direction reference](STORYTIME_DIRECTION_WORKFLOW.md). This page documents pen identities and the original version-1 comparison, which remains a focused lettering study. Both use the same stable live-ink player, but they have separate letter centerlines, pen settings, mark paths, and acting recipes. The character rigs and pose/expression libraries are unchanged. Existing episodes are outside this pass.

## Start here: repeatable model workflow

1. Read this page and the character's [Nemi acting guide](../Nemi_Animation_Personality_Guide.md) or [ADB acting guide](../../adb/docs/ADB_ACTING_GUIDE.md). Preserve their personality and silhouette.
2. Use `two_authors_10s.json` only for an explicit pen study. For a real episode use the version-2 starter in `<author>/episodes/epNN_slug/`. For a single character remove the other actor and that actor's drawings. The current stage is deliberately a fixed comparison layout; revise staging in a separate new scene for a full episode.
3. Write a short spoken thought and its visual counterpoint. Save the script and a beat sheet alongside the new spec. Use the example [beat sheet](../../common/storytime/examples/two_authors_10s.beats.md) as the pattern. A doodle should add evidence, contradict, revise, or reveal an unspoken thought; it should not just repeat every noun.
4. Choose/record the voice before final timing. Listen and mark actual word/pause times. Put those times into acting, drawing, caption, and mouth intervals. For a silent visual study set `audio` to `null` and omit mouths. Do not invent a narration track or simulate talking in silence.
5. Select `nemi` or `adb` for every actor and drawing. Choose recipes from the table below. Use the existing recipes first; extend external recipes only when a specific thought needs another combination.
6. Run the validator and engine check shown below. Errors must be fixed; never silently replace missing glyphs with a font or emoji.
7. Render a **new ten-second proof**. Review at full speed, pause during unfinished lettering, and inspect the last frame. Check readable text, distinct author identity, motivated acting, stable holds, and cue/audio alignment.
8. Save the spec, script/beat sheet, new assets/recipes, preview, and verification note. Link the new asset in these docs if the workflow changes. Do not edit or regenerate previous episodes.

These instructions reduce how much a model needs to invent. They do not guarantee equal artistic judgment from every model; visual review still matters.

## Distinct pen identities

| Habit | Nemi | ADB |
|---|---|---|
| Letter form | Looped, rounded, tall ascenders | Compact print, squared turns |
| Placement | Looser baseline, slight forward lean | Flatter baseline, restrained slant |
| Pressure | More taper and contrast | More consistent fine pen |
| Pen lifts | Longer, irregular-looking cadence | Shorter, measured cadence |
| Arrow | Curved sweep | Deliberate elbow/straight segments |
| Corrections | Loose scribbled revision | Two economical slash strokes |
| Underline | Curved double pass | Single short stroke |
| Notebook | Leaning, loose border and rings | Squared border and ticks |
| Color | Warm plum / rose | Slate / muted brown |

Shape differences remain visible in monochrome; color is supplementary. This is an initial authored direction, not a claim that Nemi must always use cursive or ADB must always use a ruler. ADB's pen should stay human: vary spacing and pressure subtly, use authored lifted strokes, and avoid turning every future prop into a perfect rectangle. Nemi should stay legible rather than arbitrarily messy.

Files: `common/storytime/profiles/nemi.json`, `adb.json`, and their `*_lettering.json` alphabets. Frequent letters and alternatives have distinct authored centerlines; remaining glyphs derive from the shared alphabet with profile-specific proportions. Not every glyph is independently redrawn yet. Repeated letters select stable variants; no geometry changes after ink is written.

Available authored marks for **both** profiles: `arrow`, `circle`, `underline`, `scratch`, `question`, `spark`, `notebook`. They have separate paths, not just different color settings. Add a new kind to both profiles when both authors need it; do not silently fall back to a generic mark. A gap is two strokes or a deliberate open contour. Random holes are not a hand-drawn style.

## Acting through the existing rigs

`common/storytime/performances/recipes.json` now contains fourteen recipes per character: the eight original combinations below plus six listed in the version-2 direction guide. Nemi additionally has the externally directed `passenger_listening`, `passenger_worried`, `passenger_deadpan` and `overwhelmed` combinations documented in the direction guide; the first three use her existing seated pose with standing grounding disabled and explicit cabin framing. These combine existing poses, expressions, gaze, eye openness, brow accents, and head angles. They are new **performance combinations**, not replacement rigs or new underlying rig poses.

| Recipe | Nemi's intention | ADB's intention |
|---|---|---|
| listening | Open face, slight tilt | Restrained attention |
| explaining | One active hand, small lean | Economical explaining gesture |
| uncertain | Small shrug, questioning gaze | Chin rub, quietly thinking |
| skeptical | Side-eye, asymmetric brow | Weight shift, eyebrow doubt |
| embarrassed | Withdraw, glance down | Smaller embarrassed stance |
| pleased | Small private satisfaction | Restrained amusement |
| deadpan | Freeze, steady eye contact | Still dry delivery |
| realization | Eyes lead the thought | Brief recognition, open palms |

`PerformancePlayer.gd` samples the transition from absolute time. Eyes/expression change at the cue; torso starts after 15% of the transition, head after 25%, hands after 38%. Nemi's default transition is 0.34 seconds; ADB's is 0.42. A delayed head response supplies small deterministic hair follow-through. After settling there is no idle bobbing. Use explicit blinks at pauses, never a random timer. `deadpan` intentionally snaps and holds.

The stage disables autonomous character processing for its own instances so springs/timers cannot fight the scene clock; the player maintains ADB's existing face/hand transforms externally. It never changes the rig files. In another scene, use the same ownership arrangement rather than running two acting systems on the same character. These recipes cover standing conversational acting; walking, contact poses, held props, turns, and new camera blocking still need authored sequences and visual checks.

## Scene spec, version 1

All times are seconds from scene start. Positions are 1920×1080 canvas coordinates. `scale` on a drawing is `[x,y]`; on an actor it is a positive number. The complete example is the copyable template.

| Field | Required content |
|---|---|
| version/title/duration/fps | `1`, readable title, seconds, `24`, `30` or `60` |
| audio | `null` or workspace `res://` path to imported WAV/MP3/OGG; starts at scene time zero |
| actors | author, position `[x,y]`, scale, performances |
| performances | increasing `at` times; first at `0`; valid `recipe`; optional `duration` and absolute `blinks` list |
| mouths (optional actor field) | ordered nonoverlapping `{start,end,shape}` intervals |
| drawings | author, kind, position, `at`, `duration`, `end`; optional scale, tilt in degrees, accent boolean |
| text drawing | additionally text, size in pixels; optional integer variant |
| captions (optional) | ordered `{start,end,text}`, at most five words per card |

Example mouth cue: `{"start": 1.12, "end": 1.25, "shape": "ae"}` for Nemi, or `"talk_open"` for ADB. These are manual phoneme/phrase annotations, not automatic recognition. Between intervals the current expression's mouth is restored. Nemi shapes include `closed`, `neutral`, `smile`, `ae`, `small_open`, `o_u`; ADB uses `neutral`, `smile`, `talk_open`, `talk_wide`, `talk_round`. The validator contains the full accepted sets. Do not exchange character mouth names.

The live preview uses audio playback position as its clock when audio is present. The exporter evaluates all tracks at fixed frame times and muxes the same audio at zero. Caption changes and doodle pen lifts do not trigger sound automatically. Use selected event sounds only when they serve the beat; prepare the final audio mix separately using the existing [voice timing](COMMON_VOICE_BEAT_TIMING.md) and [SFX](COMMON_SFX_SYSTEM.md) guidance. This new kit does not generate speech, align phonemes, edit scripts, mix SFX, or migrate old episode clocks automatically.

## Concrete directing example

“A little plan” appears while the notebook is drawn. “Easy” becomes an overconfident aside; doubt changes the face and crosses that word out; “start anyway” resolves the thought. The demo repeats the task on both sides to isolate differences in drawing and acting. Full productions should not mechanically reuse this sequence for every line.

Cue policy: start a supporting doodle slightly before or on its key word, finish it while the idea is relevant, then hold it. A revision must arrive when the thought changes. Do not make a ten-word sentence complete in 0.2 seconds. The stroke renderer proportions travel time and pen lifts inside the drawing's duration; author separate drawing entries when a pause needs explicit editorial control.

## Commands and outputs

From the repository root:

```sh
python3 tools/storytime/validate_scene.py common/storytime/examples/two_authors_10s.json
python3 tools/storytime/test_validator.py
"$GODOT_BIN" --headless --path . --log-file /tmp/storytime-tests.log --script tools/storytime/test_identity.gd
python3 tools/storytime/render_scene.py --spec common/storytime/examples/two_authors_10s.json --output renders/storytime_identity/Two_Drawing_Hands_10s.mp4
```

Set `GODOT_BIN` to the installed executable if automatic discovery fails; do not install another engine unnecessarily. Godot must run with a desktop graphics renderer for video export. FFmpeg and FFprobe must be available. The renderer uses a fresh temporary movie path every time, checks raw duration, retains the first authored frames and trims the extra trailing frame, then produces an exact-duration H.264 MP4. It accepts the matching numbered episode `renders/` folder or workspace study `renders/`, and refuses existing output filenames. Real episodes use numbered character episode folders with their own preparation record; examples require an explicit study.

For the comparison's diagnostic stills:

```sh
"$GODOT_BIN" --path . --log-file /tmp/storytime-stills.log --script tools/storytime/render_stage.gd -- --stills
```

This still sampler is specifically for the ten-second example, at 1.2/3.7/5.8/7.8/9.8 seconds. Change that sampler in a separate test when testing another duration. Movie rendering always uses the selected spec's duration/FPS.

## Verified scope and remaining limits

The saved new proof is `renders/storytime_identity/Two_Drawing_Hands_10s.mp4`: ten seconds, 1920×1080, 30 FPS, intentionally silent. Tests exercise distinct/repeatable lettering, all authored marks, all sixteen recipes, backward seeking, and still holds. Validation rejects unsupported letters, bad cue times, overlapping acting transitions, unknown recipes/marks/mouths, and long captions. The QA record is beside the movie.

The earlier shared-ink pass had already changed EP00/EP08 doodle adapters before the request to preserve episodes. Those untracked files had no saved originals, so an exact rollback could not be established. The two precisely reversible earlier integration changes (EP08 speaking-rate adjustment and table-tennis grip attachment) were reversed. No new character-profile/acting-kit work is wired into existing episodes. Do not mistake this for a full restoration of pre-project episode files.

Use [Live Doodling Workflow](LIVE_DOODLING_WORKFLOW.md) for low-level stroke/prop APIs and [the audit](HAND_DRAWN_SYSTEM_AUDIT.md) for the original findings. For new scenes, this page supersedes that first pass's generic shared handwriting guidance.

## Full productions (version 2)

For the next step beyond this pen comparison, use [Storytime Direction Workflow](STORYTIME_DIRECTION_WORKFLOW.md). It adds six external performance combinations per character, planted feet, softer face/gaze changes, staggered arm joints, shot/background selection, held props/art, finite VFX, and synchronized sound. Version 1 remains unchanged as a lettering study.

## Episode masters and camera direction

Read [Thought-driven storytime camera](COMMON_CAMERA_STAGING.md), now part of both characters’ mandatory preparation. Save an exact-word camera plan with portrait/wide/object/reaction choices and explicit holds/returns. Use existing `shot.camera` fields; reframe the whole world rather than enlarging an actor against the set. The [current Pegi study](PEGI_CAMERA_STUDY_2026_10_02.md) records local reference observations and their limits. Existing finite `sweat` and `tears` accents now use stable asymmetric open contours; tears remain eye-relative. No rig changes.

Final approved masters belong in `<author>/episodes/epNN_slug/renders/`, with resolution/revision in their filenames and a small `RENDERS.md` pointing to the current cut. Workspace `renders/` remains valid for studies and intermediate exports. Preserve older movies and exclude large media from Git. The shared renderer accepts only its matching episode render folder or workspace study folder and refuses an existing output. New starters create `renders/` and `review/`. Native 4K capture rerasterizes the vector scene at 3840×2160 with the same 1920×1080 logical composition; an upscaled movie must be labelled as an upscale.
