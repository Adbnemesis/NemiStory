# Godot ink Shorts architecture

New work follows the pose-first version3 workflow and cast skill helpers. [Revision03](review/revision03/index.html) is the current review target; original v1/v2 and r1 sources remain history. Original storytime files/settings are protected.

| Layer | Responsibility |
| --- | --- |
| Three project skills | Cast direction, thought/pose cards, source music discipline and scoped starter/render/check commands |
| `short.json` + `Edit.tscn` | One scene clock, original audio interval, supported body/view/action cues, framing, finite transitions and named events |
| `DynamicPoseArt.gd` | Ten held whole-body profiles, supported actions, coherent head group and exact phone/book/pencil grips; separate editable Shorts art |
| `DynamicEdit.gd` | Finite eye/head/gesture keys and outgoing/incoming pose transitions with explicit anticipation/target arrival |
| `DynamicAccentArt.gd` | Fixed traced/held drawings, selective deterministic finite accents and sparse stage art |
| `validate_ink.py` | Strict supported fields, body/action/view restrictions, source hashes/ranges, event links and planned pacing |
| `render_ink.py` + `render_dynamic.gd` | Native Godot pose/boundary proofs and full capture; stop on errors; exact source-audio packaging |
| `inspect_export.py` | Actual encoded dimensions, clock/frame count, changed cue frames and contact images |
| `verify_audio.py` | Decode and reconstruct exact-source music/SFX; measure delay, correlation, peaks and sound contributions |
| `check_pacing.py` | Actual decoded picture changes and maximum still run of1.5s |
| Review gallery | Range-aware native playback, cue seeking, source links and downloads from selected checked revisions |
| `audit_isolation.py` | Protected source hashes and unrelated dirty status; authorized routing/skill changes recorded separately |

Godot supplies every visual frame. FFmpeg packages capture and recorded sound; contact-sheet tools inspect output rather than generating animation assets. Separate supplemental ink art is not falsely attributed to original rigs. Existing episodes, definitions, voices and settings remain untouched.

Whole-body pose decisions carry the thought. Finite eye/head settling or supported arm contact can reinforce it; equal keys hold still. Meaningful face/prop/single crops alternate with grounded/shared views. Transition `poseFrame` can preview the accent’s target drawing during an earlier entry, then land at the intended scene frame. No random ink, idle hand loops, drifting camera or continuous unimplemented prop exchange.

Each production is `shorts/<adb|nemi|duo>/<short-name>/`. Active source/direction/cue map sit at its root; revision videos are in `render/`; QA, native stills, logs and selection/index are in `review/`; unique assets may use `assets/`. Shared art/engine is in `shorts/godot/`, music/provenance in `shorts/assets/music/`, galleries/batch records in `shorts/review/revision03/`. The cast `new` helper enforces this layout.

Current recuts preserve original source in `review/source-r1/`, old review evidence in `review/r1/` and r1 movies in `render/`. Source hashes and QA belong to their actual movie revision. A checked selection is written only after decoded export/audio/pacing checks and complete playback. Source/proof completion alone cannot approve creativity or establish retention. Generated media stays outside source Git delivery; publishing requires a user request.
