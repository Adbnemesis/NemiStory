# Active ink-edit schema: version 3

Use `shorts/godot/validate_ink.py` as the executable authority. Unknown keys fail. Version 1/2 examples are retained history; new work uses version 3, `DynamicEdit.gd`, and `DynamicPoseArt.gd`. Never change existing storytime definitions to make a spec pass.

## Top level

`version:3`, lowercase hyphenated `id`, `title`, `premise` (one bottom headline, at most 100 characters), `fps:30`, `width:1080`, `height:1920`, `frames:360..750` (12–25s), `music`, `sfx`, `theme`, `actors`, `shots`, `events`.

Music object: `file` workspace-relative existing audio, `sourceHash` exact SHA256, `sourceStart` seconds, `duration` exactly frames/30, `gainDb` −40..12. The selected range must fit the real file. Original previews are recorded in `shorts/assets/music/batch01/MUSIC_SOURCES.md`; current music selection is reference-fit/famous, not a claim of live platform trend ranking.

Theme: `signature` sound/runway/doodle/duo/camera; `paper`, `ink`, `shade`, `accent` six-digit hex colors; `shading`0..0.6. Stable paper grain and crosshatching are art, not motion.

## Actors and visible motion

Actor: `id`, `author` adb/nemi, `cues`, `motion`. Author scopes are enforced by each skill wrapper. Preserve the approved long-haired hoodie/skirt/bag Nemi and collared-shirt/trousers ADB art. They are separate personalities and strokes; read CHARACTER_DIRECTION.md.

Cue keys: `frame`, `pose` (actual original author pose-library label), `expression`, `gaze:[x,y]` each −1..1, `eyes`0..1.3, `head`−30..30, `motion` snap/smooth/stepped, `duration`0.001..2 seconds, `blinks`, `view` front/threequarter/profile/back, `emotion` shy/smile/shock/cover/deadpan, `action`.

Supported visible actions: `rest`, `listen`, `glasses`, `peace`, `wave`, `phone`, `sketch`, `point`, `thumbsup`, `heart_hand`, `shrug`, `hip`, `arms_open`, `chin`, `phone_up`, `book_show`. `phone_up` holds a raised phone continuously; `book_show` has two grips and a finished cat page. The back drawing has held rear arms: ADB back only rest, Nemi back rest/listen. Do not invent walking, pickups, exchanges or back contact art. Changes are pose edits, not automatic physical prop transfer.

`motion` is a strictly increasing key array starting at frame 0. Every key has `frame`, `head`−10..10 degrees, `look`−1..1, `eyes`0..1, `lean`−5..5 degrees, `gesture`0..1. Smooth interpolation occurs between adjacent keys, equal states create stillness, final state holds. `head` rotates a coherent head/hair/face group; `eyes` visibly closes lids; `lean` pivots above grounded feet; `gesture` controls finite arm entry. Author eyes leading, head following, hand entry and settling. Add actual matching keys before a later change when a hold is intended. No periodic bob or random jitter.

## Shots

Strictly increasing from frame 0: `frame`, `zoom`0.5..3, `center:[x,y]`, `actors:{id:{position:[x,y],scale:0.1..5,flip:1|-1}}`, `move` cut/punch/pull/whip, optional `angle`−20..20, `settle`1..15 frames, `direction`1|-1, `palette` paper/ink, `stage` plain/door/columns/page/viewfinder/runway.

World-to-screen mapping after settle is `screen=(world-center)*zoom+[540,960]`. Feet local y≈385; head≈−305. Use this to keep full-body poses readable. Only named actors are visible. A cut is not proof of a changed pose.

Optional finite `travel:{pan:[dx,dy],zoom:factor,end:frame}`: pan each±60 screen units, factor0.97..1.03; end after shot start and before the next cut or movie end. Travel smoothly follows the action then stops. It cannot substitute for meaningful acting.

## Events and sound

Each unique event: `id`, `at`, `end` frame integers, `kind`, `position:[x,y]` screen units, optional `scale`0.1..3, `rotation`−360..360 degrees, `accent:true|false`, `animation` pop/draw/orbit/burst/wipe. Event end is exclusive.

Kinds: stars/arcs/notes/heart/zigzag/brackets/moon/cloud/leaf/rays/dash/pencil/flash plus flower/spiral/ring/confetti/speedlines/cat/spark_trail. `draw` traces fixed line paths over 9 frames then holds completed ink. `pop` settles in 6 frames. `orbit`, `burst`, `wipe` are finite moving effects, at most 45 frames. Confetti and spark trails use deterministic paths. Pencil and flash occupy the foreground. Flash at most2 frames; no strobe patterns. Moving particles can disappear; completed drawn ink must remain fixed until a meaningful cut/event end.

SFX: `event` existing event id, `file` inside common/audio/sfx, exact `sourceHash`, `sourceStart`, `duration`, `gainDb`, optional integer `offsetFrames`. Use actual recorded root MP3/category recordings indexed in common/audio/sfx/root_sfx_inventory.json. Never procedural placeholders or synthesized audio. Clip attack is sourceStart+offset on the shared30fps clock. Preserve audible music and intentional accents; verify final AAC mix.

## Pacing and export authority

Planned semantic/motion/cut/event changes cannot leave a gap over 45 frames. A separate decoded-video check rejects actual still runs over 1.5s. That check is an engineering backstop, not a creativity score: watch playback to reject jitter, meaningless zooms, excessive flashing, hand clipping and unreadable doodle clutter.

Run `render_ink.py` to validate and capture Godot; ffmpeg only encodes/muxes audio. `inspect_export.py` verifies dimensions, actual cuts and exact frame count. `verify_audio.py` verifies decoded mix against original sources. `check_pacing.py SPEC MOVIE REVIEW_JSON` checks actual frames. Every review record must distinguish source-authored intentions from verified exported evidence.
