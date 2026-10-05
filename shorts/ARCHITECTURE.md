# Godot ink Shorts architecture

New work uses version3, with the strict schema and skill helpers. The original v1/v2 accepted art and playback remain as inherited source and reproducible history. Original storytime files/settings stay read-only.

| Layer | Responsibility |
| --- | --- |
| Three project skills | Cast scope, character direction, causal brief, music/source discipline and maintained production/check commands |
| short.json + Edit.tscn | One clock, exact source interval, actor cues/motion, framing/travel, theme and named events |
| DynamicPoseArt.gd | Sixteen explicit actions, coherent head group, pupil/lid motion, finite arm paths, continuous phone/book/pencil grips, grounded feet |
| DynamicEdit.gd | Version3 motion interpolation and finite camera follow over the established director |
| DynamicAccentArt.gd | Fixed path tracing, held completed ink, finite event-local particles and established stage/foreground art |
| validate_ink.py | Strict supported fields, contact/view scope, source hashes/ranges, shared clock, planned pacing and finite VFX |
| render_ink.py + render_dynamic.gd | Isolated native Godot capture; stop on script errors; exact frames and original-source audio packaging |
| inspect_export.py | Actual encoded dimensions, clock, cue changes, poster and contact sheet |
| verify_audio.py | Decode and reconstruct original-source music/SFX; measure delay, correlation, clipping/peak and audible contribution |
| check_pacing.py | Actual decoded picture changes and maximum static run1.5s |
| Review gallery | Range-aware native playback, cue seeking, source links and downloads |
| audit_isolation.py | Protected source hashes and unrelated dirty status; explicit routing/skill status changes separately recorded |

Every visual frame originates in Godot. FFmpeg encodes, trims surplus capture frames and mixes recorded sound. Still/contact-sheet processing measures real exports; it creates no animation assets. Visible supplemental art is honestly identified as separate Godot illustration. Original rig definitions and all existing episodes remain untouched.

Motion keys interpolate finite authored head, gaze, eye, torso and gesture states. Equal keys hold still. Shots can follow a hand/face action within small bounded travel. No per-frame random ink, endless bob or opacity handwriting. Completed ink stays fixed; moving VFX have finite event lifetimes. One deliberate reaction can be small, but numerical motion is not sufficient artistic evidence.

A production carries exact original/decoded music identity/hashes, source section, gain and a cue map tied to the source clock. Recorded SFX event attacks and exported contributions are checked independently. Topic/rhythm fit is distinct from an unverified current platform ranking.

Source, direction and checks stay beside each production; movies remain immutable revisions under renders/, review records under review/. Current selection lives in review/current.json and the batch manifest. Generated media is excluded from source Git delivery. Uploading/publishing Shorts requires a separate user request.
