# Godot ink Shorts production workflow

Use the appropriate ADB, Nemi or duo ink-short skill for this separate12–25s music-edit format. [Motion04](../review/motion04/index.html) is the current music/motion review target. The preceding revision03 pose pass is preserved interim work, not an approved completed batch playback. Read the matching example’s current source, direction and cue map; its `review/current.json` and QA identify the actual checked export. An unfinished source/native proof does not count as full movie approval.

## Plan the thought and pose cards

1. Read [current Shorts rules](../AGENTS.md), [schema](V3_SCHEMA.md), [character direction](CHARACTER_DIRECTION.md), the cast skill and the closest canonical example. Read the relevant measured-reference notes—[ref01](../review/motion04/ref01/MOTION.md) for body/recoil/camera contrast or [ref03](../review/motion04/ref03/MOTION.md) for large/small reaction frames and continuous joins—then inspect their linked actual source frames/video and the matched example’s art/playback. Save which observed motion device applies. These notes separate evidence from our adaptation; do not pretend a held reference drawing has unobserved acting. Preserve original storytime source and voices.
2. Save `DIRECTION.md` before authoring: promise, want, visible choice, consequence and payoff. Give the first second a recognisable situation/posture. Choose12–25s around the music phrase and ending; do not pad to15s. A first-time viewer must understand why the next pose happens.
3. Make one pose card per thought beat. Record its frame, audience focus, supported `bodyPose`, view, action/prop contact, eyeline, framing and music-arrival reason. A different wrist position or crop of the same drawing is not a new whole-body pose. ADB’s economical composure and Nemi’s warmer curiosity can contrast, but neither becomes a generic reaction mascot.

A useful card sequence is: **recognisable want → committed body shape → consequence/recoil → deliberate recovery/payoff**. For a duo, let an individual reaction change the partner’s next shared beat. A montage may still use a tiny stable premise; it must not become narration captions over idle art. There is no fixed pose/effects quota or guaranteed retention score.

## Author supported art and timing

Create the cast folder with the helper below, then adapt the template into a distinct idea. Keep the original template’s supported rig labels where appropriate and use the schema’s actual fields. The thought cards plan the major body changes; each card also needs a small coherent internal-action path and a camera purpose, so it continues to develop between cuts. `bodyPose` selects separate held whole-body drawings; it does not replace the required original-library `pose` label or add automatic walking/joint physics. `folded` uses `rest`; `celebrate` uses `arms_open`, `wave` or `peace`; nonneutral back art is unsupported. Other supported contact drawings retain their exact phone/book/pencil grips. For a sketch-page before/after, use the schema’s optional `pageArt` selector on every relevant sketch cue; defaultcat must not accidentally reveal a finished cat before a promised crescent. Review the actual first and final art against the caption.

Show important silhouette changes in full-body frames with grounded feet. Add deliberate large/small contrasts: a reaction face, a readable prop insert or one character’s single before the two-shot returns. Check both hands and raised palms against the actual image edges; changing zoom alone cannot manufacture an action. Use genuine authored profile views, not a front drawing rotated into one.

Visible motion keys provide finite eye leads/head settling and supported contact movement. For a held pose edit, `gesture:1` can stay fixed while the whole drawing changes. Use finite eye/head/grounded torso paths across the thought; a matching key can create a deliberate brief read, while another authored choice can continue afterward. Avoid a generic periodic hand/sleeve or body loop. Completed ink stays coherent in world space until a meaningful event/cut ends; directed camera movement can move that stable drawing across the screen. This is different from random line redraws or idle jitter.

Audition a documented recording section and use its saved source accents to choose picture landings. Picture time is integer frames at30fps; source time is `music.sourceStart + frame/30`. Keep exact artist/version/source/hash/range/gain and preview-relative timing. Onset candidates are not automatic downbeats or confirmed choruses; fresh evidence is needed for current trend claims. Retain only recorded original root/category SFX, with exact hashes and event purposes.

## Link anticipation, transition and arrival

Keep clear hard cuts where they work. Use `smear`, `whip`, `match` or `focus_wipe` when the thought changes direction. Read the schema’s exact window/contact restrictions. A transition is4–12frames, ends completely, and gives the new pose time to read. `match` needs a real frame/scale/focus contrast; repeating the same zoom/placement produces little visible transition.

For a selected pose accent at frame120 and an8frame anticipatory smear:

- Start the incoming shot at112 with `move:"cut"` and `transition:{kind:"smear",duration:8,event:"pose-arrival",direction:1,poseFrame:120}`.
- Put the intended target actor cue at120. The transition previews that target drawing and settles on the accent; the held clock continues from its cue.
- Link an event with `id:"pose-arrival"`, `at:112`, `end:120`, `kind:"ink_swoosh"`, `animation:"burst"` and a deliberate screen position. A `match` instead links `landing_ticks` and requires `focus`.
- Record transition start and pose-arrival timing separately in `CUE_MAP.json`; do not call the early transition start beat-aligned when the arrival is the selected accent.

Use finite emphasis marks around the focus, rather than across a face/prop contour. Recorded SFX can accent a meaningful arrival, recognition or shutter; do not add a loud whoosh to every cut. Inspect the outgoing pose, start/middle/final transition frame and settled target. An apparently clever move that hides the thought, clips the hands or doubles the character is a failure even when validation passes.


## Direct ongoing camera and internal motion

Read the schema’s current `shot.camera` controls. Camera is a source-authored relative transform around an explicit screen `focus`, with absolute-frame keys for `factor`, `pan:[dx,dy]`, `roll` and destination `ease`. Keys begin on the shot frame, stay inside that shot and hold their final value. Choose `camera` or legacy `travel`, not both. Godot applies the camera to the character canvas and supported physical stage context; check the actual door/floor contact and graphic overlays after any move.

Give each thought a purposeful base push, pull or pan—toward recognition, into concentration, away for recoil/relief, along a directed eyeline—then optionally add a tiny short impulse at a selected source attack. Avoid copying one push/pull pattern into every shot. Linear development can carry momentum through held art; eased segments can finish a specific choice. Check speed before a join and the departing/incoming camera image, rather than resetting to a perceptually dead stop by habit. Stronger close/miniature moves are allowed when framing serves the thought; actual safe hands/feet/props are the constraint.

A relative-camera example, with a base push and one smaller accent around frame45, assumes this shot spans30–59:

```json
"camera": {
  "focus": [540,780],
  "keys": [
    {"frame":30,"factor":0.98,"pan":[0,0],"roll":0,"ease":"linear"},
    {"frame":43,"factor":1.01,"pan":[0,-4],"roll":0,"ease":"linear"},
    {"frame":45,"factor":1.025,"pan":[0,-8],"roll":0,"ease":"out"},
    {"frame":53,"factor":1.03,"pan":[0,-7],"roll":0,"ease":"out"},
    {"frame":59,"factor":1.04,"pan":[0,-10],"roll":0,"ease":"linear"}
  ]
}
```

Use the actual music to choose45; the example timing is not a universal beat recipe. The smaller impulse rides the continuing base push and resolves toward it, rather than pulsing the whole picture endlessly. Record camera purpose, selected source attack time and frame quantization in `CUE_MAP.json`. [Motion04 beat direction](../review/motion04/BEAT_DIRECTION.md) distinguishes rhythmic-body, bright attack and texture evidence; its candidate recipes are examples, not a requirement to reuse eight sequences.

Within a pose, eyes can lead a small head turn by a few frames and grounded torso lean can settle shoulder emphasis; keep the supported hand/prop fully arrived when no new hand action is needed. Nemi and ADB differ in amplitude/response timing where the thought warrants it. Check actual internal motion at real speed—stills cannot establish it. New joint, prop or physics behavior must be implemented in the separate maintained Shorts art/schema/example before a spec uses it; a director’s imagined chest/knee action is not an API.

Choose the endpoint after the useful payoff and audition the actual final/first audio. Tail trimming can remove repeated solved poses while preserving sourceStart, gain, speed and recording identity. Do not stretch all clips to15s or a guessed bar count. Current examples vary13.5–17.567s; the format remains12–25s. A visual restart is not proof of a seamless music loop.

## Render and verify

From the project root, use the matching cast helper and an unused revision:

```sh
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py validate shorts/nemi/new-music-moment/short.json
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py stills shorts/nemi/new-music-moment/short.json --revision r1
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py build shorts/nemi/new-music-moment/short.json --revision r1
```

Inspect native proof stills and real-speed motion proof before the full build: camera extrema/impulse peaks, internal eye/head/grounded torso samples, silhouette differences, full-body grounding, true view, author identity, contact, safe raised hands, readable props, premise clearance, VFX overlap and ending. The current renderer samples settled pose cards, camera extrema/keys and transition boundaries; inspect continuous actual playback as well, not just each endpoint. Repair source and use a fresh revision when art fails. Native Godot capture requires a desktop session and stops on errors; never bypass unknown fields, missing assets, stale hashes, script errors or incomplete capture.

`build` captures the complete clip in Godot, then checks encoded frame count/dimensions, reconstructed original-source audio and actual decoded pacing. Encoding tools only package Godot images and recorded audio. Maximum decoded still hold is1.5s; numerical motion is not a performance review. For an existing export:

```sh
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py check shorts/nemi/new-music-moment/short.json --movie shorts/nemi/new-music-moment/render/new-music-moment_r1_1080x1920.mp4
```

Watch the entire exported movie at real speed with music. Check that internal movement feels motivated, camera development continues between cards, the selected camera impulses match the audible accents and there is no redundant prolonged ending. Inspect the first-second hook, body/view/framing contrasts, transition arrivals, prop contact, reversal/payoff and final-to-first restart at phone size beside the reference. Verify recorded SFX are actually audible and music remains the lead. Save only performed observations in `review/QA.md`; source intent, still inspection, numerical checks and whole-movie playback remain distinct records. The helper deliberately leaves creative/playback review pending until it is performed.

Select the passed revision in `review/current.json`, update `review/RENDERS.md` and retain the actual export/audio/pacing reports. Refresh the latest gallery with `.venv/bin/python shorts/godot/build_upgrade_review.py --output motion04` after selections pass. A temporary mixed-revision gallery can be built with `--revisions-json shorts/review/revision03/PREVIEW_REVISIONS.json` for playback review without changing the selected records. Refresh again without overrides only after real selections pass. Full movie/playback checks are pending anywhere their real evidence has not been written. Audience retention is measured after posting, not inferred from a pose count or validator.

## Skill demonstrations

The ADB, Nemi and duo skills were forward-tested on `adb-big-idea`, `nemi-tiny-cat` and `duo-matching-moment`. Their `SKILL_USE.md` separates historical r1 use, interim revision03 pose work and the current motion04 recut. A recut is not a new blind evaluation of the skill. For a new skill or materially changed helper, save the actual invoked skill/readings, new request, source choices, failures, validation/build/check results and performed art/playback observations. Another model must be able to reproduce the route without relying on this chat.

## Folder layout and starting command

Run the cast helper’s `new <short-slug>` first. It copies the matched editable spec/scene, updates identity and scene path, and creates unreviewed direction/cue records without copying old QA:

```sh
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py new new-music-moment
```

Adapt the template’s thought, pose cards, framing, transitions, effects and verified music clock before validate/stills/build. The starter is a draft.

```text
shorts/
  nemi/<short-slug>/     # likewise adb/ and duo/
    short.json          # current timing/poses/shots/sound/events
    Edit.tscn           # active editable Godot scene
    DIRECTION.md
    CUE_MAP.json
    render/             # immutable revision movies only
    review/             # QA, native stills, logs and render index
      source-r1/        # original source snapshots for current recuts
      r1/               # preserved original review evidence
      source-motion03/  # preserved interim pose source
    assets/             # optional unique assets
  godot/                # shared art, engine and tools
  assets/music/         # shared recordings and provenance
  review/motion04/      # current batch gallery and motion evidence
```

Original storytime rigs remain outside Shorts in `adb/`, `nemi/` and `common/`. Visible ink art lives in `DynamicPoseArt.gd` and `DynamicAccentArt.gd`. New production output uses singular `render/`; accepted version1/2 history keeps its historical `renders/` folders.

Before recutting an existing edit, preserve its source/evidence and keep the old movie. For the current recuts, source snapshots are in `review/source-r1/`, original records in `review/r1/`, and the old movie stays in `render/`. Work from the current Short-root source; an archived scene is provenance, not the active editing entry. Interim pose-pass source is in `review/source-motion03/`; existing intermediate movies do not imply their whole-batch playback was approved. Do not attach a new spec hash to an older movie. Retain previous media until the replacement passes QA; cleanup of unrelated episodes is not authorized by a recut.

For shared-engine/batch work, take the isolation snapshot before editing and compare afterward. Protect original `adb/`, `nemi/`, `common/`, animation docs/storytime tools and project settings; record authorized routing/skill updates separately. Standing source-push authorization excludes generated media, large binaries, caches and secrets. Publishing/uploading or unrelated episode changes require their own request.
