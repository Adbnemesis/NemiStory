# School scenery and supporting illustrations

New version-2 production extension, 2026-10-04. Demonstrated by `adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/scene.json`. Existing episodes and character rigs are unchanged.

Supported backgrounds: `school_classroom` (window, teaching board, rear desks/chairs, door, floor), `school_corridor` (lockers, door, floor). Both use the same 1920×1080 world and floor y=894. Reframe with existing shot.camera; do not resize the actor against furniture.

Supported held art kinds: `school_friend`, `school_friend_smile`, `school_friend_laugh`, `school_classmate`, `school_classmate_laugh`, `lunch_box`, `homework_notes`, `school_clock`. They use existing author, position, scale, at/end, mode, shots and layer fields, without new schema fields. Author selects the existing ink profile. This episode uses author=adb throughout. Supporting students are static illustrations with expression-specific cuts, not guest voices, replacements for ADB/Nemi, or an automatic character animation system.

Student art origin is at the feet (local y=0); head center is approximately y=-295 and top is -354. Preserve position/scale across expression swaps. ADB's scale and root differ: at scale 1.7, root y=591.4 gives fixed foot anchors y=894. His unchanged sneaker sole extends another 14 local units, placing sole contact near y=918 in the foreground floor plane, slightly nearer than the supporting pupils. Check both in rendered shots. Lunch/notes use object-center origins; do not assume their center is a surface-contact point.

All geometry is authored once, played through SceneArt/LiveDrawing and held still. No randomized ink, root-motion walking, automatic hand action or phoneme generation. Page turns, pickups or garment interaction still require authored controls and separate contact review.

Backdrop delegates to SchoolBackdrop.gd; SceneArt delegates to SchoolArt.gd. Supported kinds are declared in validate_production.py. Example and production checks belong with the new episode. No edits to profile mark paths or character definitions.

Native 4K export uses the shared renderer’s `--4k` option and existing canvas_items stretch configuration. The ten-second episode proof was checked at 3840×2160, 300 encoded frames. The full source remains a 1920×1080 logical composition; vectors are rerasterized at the output resolution rather than upscaling a movie.
