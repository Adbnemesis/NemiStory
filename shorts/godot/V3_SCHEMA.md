# Active ink-edit schema: version 3

Use `shorts/godot/validate_ink.py` as the executable authority. Unknown keys fail. Version 1/2 examples are retained history; new work uses version 3, `DynamicEdit.gd`, and `DynamicPoseArt.gd`. Never change existing storytime definitions to make a spec pass.

## Top level

`version:3`, lowercase hyphenated `id`, `title`, `premise` (one bottom headline, at most 100 characters), `fps:30`, `width:1080`, `height:1920`, `frames:360..750` (12–25s), `music`, `sfx`, `theme`, `actors`, `shots`, `events`.

Music object: `file` workspace-relative existing audio, `sourceHash` exact SHA256, `sourceStart` seconds, `duration` exactly frames/30, `gainDb` −40..12. The selected range must fit the real file. Original previews are recorded in `shorts/assets/music/batch01/MUSIC_SOURCES.md`; current music selection is reference-fit/famous, not a claim of live platform trend ranking.

Theme: `signature` sound/runway/doodle/duo/camera; `paper`, `ink`, `shade`, `accent` six-digit hex colors; `shading`0..0.6. Stable paper grain and crosshatching are art, not motion.

## Actors and visible motion

Actor: `id`, `author` adb/nemi, `cues`, `motion`. Author scopes are enforced by each skill wrapper. Preserve the approved long-haired hoodie/skirt/bag Nemi and collared-shirt/trousers ADB art. They are separate personalities and strokes; read CHARACTER_DIRECTION.md.

Cue keys: `frame`, `pose` (actual original author pose-library label), `expression`, `gaze:[x,y]` each −1..1, `eyes`0..1.3, `head`−30..30, `motion` snap/smooth/stepped, `duration`0.001..2 seconds, `blinks`, `view` front/threequarter/profile/back, `emotion` shy/smile/shock/cover/deadpan, `action`, optional `bodyPose` and `pageArt`.

`bodyPose` selects a separate whole-body Shorts drawing: `neutral` (default, previous art unchanged), `contrapposto`, `recoil`, `crouch`, `lean_in`, `folded`, `wide`, `groove_left`, `groove_right`, `celebrate`. These change the torso/leg silhouette rather than only a hand. They support front/threequarter/profile; back requires neutral. `folded` supports only rest actions, and `celebrate` only arms_open/wave/peace. Other body drawings retain the existing supported props and grips. This does not add automatic walking, pickup, joint interpolation or new original-rig poses. Keep a held drawing readable after a finite arrival; a sequence should make its want, consequence and payoff legible through silhouettes.

Optional `pageArt` chooses the stable drawing on the held `sketch` page: `moon`, `cat` (default, original picture unchanged), or `blank`. It changes only page marks; page/pencil/finger geometry and all grips stay fixed. Other actions do not display this selector; `book_show` remains the supported finished cat page. Both incoming and departing transition illustrations sample their own cue’s pageArt. Each cue defaults to cat when omitted, so explicitly keep moon on every sketch cue that precedes the cat reveal. This is a drawing swap on the same scene clock, not a continuous live transformation. Inspect the actual before/after against the premise.

Supported visible actions: `rest`, `listen`, `glasses`, `peace`, `wave`, `phone`, `sketch`, `point`, `thumbsup`, `heart_hand`, `shrug`, `hip`, `arms_open`, `chin`, `phone_up`, `book_show`. `phone_up` holds a raised phone continuously; `book_show` has two grips and a finished cat page. The back drawing has held rear arms: ADB back only rest, Nemi back rest/listen. Do not invent walking, pickups, exchanges or back contact art. Changes are pose edits, not automatic physical prop transfer.

`motion` is a strictly increasing key array starting at frame 0. Every key has `frame`, `head`−10..10 degrees, `look`−1..1, `eyes`0..1, `lean`−5..5 degrees, `gesture`0..1. Smooth interpolation occurs between adjacent keys, equal states create stillness, final state holds. `head` rotates a coherent head/hair/face group; `eyes` visibly closes lids; `lean` pivots above grounded feet; `gesture` controls finite arm entry. Author eyes leading, head following, hand entry and settling. Add actual matching keys before a later change when a hold is intended. No periodic bob or random jitter.

## Shots

Strictly increasing from frame 0: `frame`, `zoom`0.5..3, `center:[x,y]`, `actors:{id:{position:[x,y],scale:0.1..5,flip:1|-1}}`, `move` cut/punch/pull/whip, optional `angle`−20..20, `settle`1..15 frames, `direction`1|-1, `palette` paper/ink, `stage` plain/door/columns/page/viewfinder/runway, optional `transition`, optional `camera`.

World-to-screen mapping after settle is `screen=(world-center)*zoom+[540,960]`. Feet local y≈385; head≈−305. Use this to keep full-body poses readable. Only named actors are visible. A cut is not proof of a changed pose.

Optional finite `travel:{pan:[dx,dy],zoom:factor,end:frame}`: pan each±60 screen units, factor0.97..1.03; end after shot start and before the next cut or movie end. Travel smoothly follows the action then stops. It cannot substitute for meaningful acting.

For an authored camera phrase spanning the thought, use `camera:{focus:[screenX,screenY],keys:[...]}`. It is optional and cannot coexist with `travel`. Focus is a screen point inside1080×1920; choose the face, hands/prop or shared duo focus for this thought. Each key requires `frame` (absolute integer), `factor`0.8..1.25, `pan:[dx,dy]` each±120 screen pixels, `roll`−3..3 degrees, and `ease` linear/smooth/out/in. At least two keys must author a transform change; keys strictly increase, start exactly on shot.frame, and finish before the next shot. The final state holds. **The destination key's ease owns the segment from the previous key.** `linear` is constant progress; `smooth` is cubic smoothstep; `out` is cubic ease-out; `in` is cubic ease-in. All use the same scene frame clock as poses/events/music.

The camera delta scales/rolls around its focus, then adds screen-space pan. The engine composes that delta after the existing shot/pose-transition transform: `picture = cameraDelta × shotOrTransition`. This keeps a held drawing moving through a finite phrase after its entrance, rather than only adding a few settling frames before a dead hold. Outgoing transition art samples the previous actual base/travel/transition/camera transform at cut−1, so a sweep cannot jump back to the previous saved neutral framing. With no camera field, existing playback is unchanged.

Only physical stage contours (`door`, `columns`, `runway`) receive the small camera delta. They retain their established screen composition through large base reframes. Graphic page/viewfinder frames, captions and event marks stay in screen coordinates. An event positioned beside a moving hand must therefore be authored at that hand's intended screen landing; it does not automatically follow an actor.

```json
"camera": {"focus":[540,650],"keys":[
  {"frame":120,"factor":1.0,"pan":[0,0],"roll":0,"ease":"linear"},
  {"frame":138,"factor":1.02,"pan":[-8,4],"roll":0.2,"ease":"linear"},
  {"frame":150,"factor":1.07,"pan":[-25,8],"roll":0.4,"ease":"out"}
]}
```

These are permitted amplitudes, not a camera-motion quota. Plan the ongoing push/pull/pan for the thought and music phrase. A selected accent may have an authored brief attack/return via additional keys; do not shake or zoom on every hit. Tiny head/look/lean keys can answer the thought while body/prop contours remain coherent; do not use perpetual bobbing. Inspect phone-size framing, caption competition, contact, transitions and actual beat landing. See [the frame-by-frame ref03 motion study](../review/motion04/ref03/MOTION.md) for observed transforms, joins and uncertainty.

Optional `transition:{kind,duration,event,direction,focus,poseFrame}` is a pose edit device after frame0. The opening shows its pose immediately; a transition needs a departing shot. `duration` is an integer 4–12 frames, `event` is a unique named event id, `direction` optionally 1 or −1 (default1), and `focus` is a screen point within1080×1920. Focus is required for match/focus_wipe. The event starts exactly at this shot's frame and ends at shot frame+duration; it must finish before or at the next cut. `match` links a `landing_ticks` event; other kinds link an `ink_swoosh` event. The transition replaces generic punch/pull/whip arrival during its window, then settles completely at its exclusive end. Optional `poseFrame` is an integer within shot frame..shot frame+duration (and before movie end). It selects the target actor drawing sampled during arrival; default is shot frame. For a pre-beat transition, start the shot/event before the accent, set poseFrame to the accent frame, and place the new actor cue there. The target drawing is visible in the incoming transition art and lands fully on the accent; the outgoing pose is sampled at cut−1. It does not replace the music clock or authorize random animation.

| kind | Authored picture behavior | Use |
|---|---|---|
| `whip` | Previous vector pose departs in one direction while the new whole drawing arrives from the other side. Both are sampled deterministically; they are editable art, not bitmap ghosts. | A strong change of view, attention or stance. |
| `smear` | Previous silhouette leaves; the arriving drawing briefly has a modest horizontal stretch plus authored contour streaks, then resolves. | Sudden recoil or confident pose landing. |
| `match` | New drawing reframes around the specified screen focus using the previous zoom, then stops. | Full-body → matching face/detail without losing eyeline. |
| `focus_wipe` | Complementary screen-space masks reveal the incoming drawing while hiding the outgoing drawing under a finite illustrated brush strip. | A deliberate doodle/page/view change. |

Keep most changes readable clean cuts or match reframes; use a transition where the thought changes direction. Inspect the start, middle, final transition frame and held pose in actual playback. Cross-clipped grips, face obstruction and unreadable overlapping silhouettes are failures even when validation passes. The outgoing art is sampled at cut−1; continuous prop exchange across this device is not implemented.

```json
"transition": {"kind":"smear","duration":7,"event":"wrong-room-recoil","direction":-1}
```

The corresponding event has `id:"wrong-room-recoil"`, `at` equal to this shot frame, `end` seven frames later, `kind:"ink_swoosh"`, `animation:"burst"`, and a deliberate edge position. Audio can reference the same id.

## Events and sound

Each unique event: `id`, `at`, `end` frame integers, `kind`, `position:[x,y]` screen units, optional `scale`0.1..3, `rotation`−360..360 degrees, `accent:true|false`, `animation` pop/draw/orbit/burst/wipe. Event end is exclusive.

Kinds: stars/arcs/notes/heart/zigzag/brackets/moon/cloud/leaf/rays/dash/pencil/flash plus flower/spiral/ring/confetti/speedlines/cat/spark_trail. `draw` traces fixed line paths over 9 frames then holds completed ink. `pop` settles in 6 frames. `orbit`, `burst`, `wipe` are finite moving effects, at most 45 frames. Confetti and spark trails use deterministic paths. Pencil and flash occupy the foreground. Flash at most2 frames; no strobe patterns. Moving particles can disappear; completed drawn ink must remain fixed until a meaningful cut/event end.

Additional selective accents: `landing_ticks` puts six small emphasis strokes outside an open focal center; `ink_swoosh` is a directional three-stroke sweep; `impact_ring` expands a broken ring with small radial ticks; `scribble_burst` sends six authored zigzags outward. Each lasts6–20 frames and uses `animation:"burst"`; ink_swoosh may also use `wipe`. A transition-linked accent may last4–12 frames matching its transition. Position/rotation/scale are authored in screen units; place accents around a face or prop rather than over its contours. These strokes have fixed geometry and deterministic event-local trajectories. They stop and disappear; they are not endless wobbling doodles or a blanket effects layer.

SFX: `event` existing event id, `file` inside common/audio/sfx, exact `sourceHash`, `sourceStart`, `duration`, `gainDb`, optional integer `offsetFrames`. Use actual recorded root MP3/category recordings indexed in common/audio/sfx/root_sfx_inventory.json. Never procedural placeholders or synthesized audio. Clip attack is sourceStart+offset on the shared30fps clock. Preserve audible music and intentional accents; verify final AAC mix.

## Pacing and export authority

Planned semantic/motion/cut/event changes cannot leave a gap over 45 frames. A separate decoded-video check rejects actual still runs over 1.5s. That check is an engineering backstop, not a creativity score: watch playback to reject jitter, meaningless zooms, excessive flashing, hand clipping and unreadable doodle clutter.

Run `render_ink.py` to validate and capture Godot; ffmpeg only encodes/muxes audio. `inspect_export.py` verifies dimensions, actual cuts and exact frame count. `verify_audio.py` verifies decoded mix against original sources. `check_pacing.py SPEC MOVIE REVIEW_JSON` checks actual frames. Every review record must distinguish source-authored intentions from verified exported evidence.
