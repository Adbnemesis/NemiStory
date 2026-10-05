# Separate Godot Shorts architecture

The active pipeline is the v2 Godot music edit. All new source, audio, outputs and review remain inside `shorts/`; original storytime episodes and production libraries are read-only. The accepted v1 r3 proof is preserved. Earlier Remotion architecture is retained in [ARCHITECTURE_REMOTION_HISTORY.md](ARCHITECTURE_REMOTION_HISTORY.md).

| Layer | Responsibility |
| --- | --- |
| Production `short.json` + `Edit.tscn` | One premise, exact music interval, actor illustration cues, camera shots, theme and named visual/SFX events |
| `InkPoseArt.gd` / `BatchPoseArt.gd` | Separately authored editable Godot curves/polygons for viewpoints, expression, hands, gray washes and attached props |
| `InkEdit.gd` / `BatchEdit.gd` | One 30 fps scene clock, held art, finite reframes, actual profile/back selections and runtime-only sampling of hidden original rig controls |
| `BatchAccentArt.gd` | Static stage/doodle marks, finite foreground pencil wipe and brief shutter wash |
| `validate_ink.py` | Reject unknown fields/poses/contact fallbacks, bad clocks, changed audio hashes, invalid source ranges and unknown SFX events |
| `render_ink.py` + `render_batch.gd` | Temporary native portrait Godot capture, error rejection, decoded frame/dimension validation, exact recorded-audio mux |
| `inspect_export.py` / `verify_audio.py` | Inspect actual encoded cue changes, contact sheets, source reconstruction, measured latency, SFX contribution, clipping/loudness/true peak |
| `build_review.py` / review server | Native range-aware browser playback, source/direction links and MP4 downloads |
| `audit_isolation.py` | Compare protected original source hashes/settings and existing outside-Shorts Git status |

Every new movie frame is drawn in Godot. FFmpeg only encodes/trims the surplus capture frame and selects/gains/mixes source recordings. It never supplies visual edits. Review thumbnails/contact sheets are measurements of the actual capture, not animation assets.

Visible body art is supplemental illustration, independently selected by view/emotion/action. Original rig poses remain sampled in hidden instances without changes to character definitions, geometry, pose/face/hand systems or voice identity. There is no automatic universal walking, pickup/release or full dance system. Prop contact is authored into a held drawing, with cuts between poses.

Picture cues use integer 30 fps frames; audio section timing uses seconds. Named events link doodles/physical editorial moments with recorded SFX. Completed ink stays fixed after a brief deterministic settle. No frame-random lines, constant bobbing or opacity-only handwriting is used. A source clock changes when the recording/section changes; old beat maps are never silently reused.

Batch01 supplies five distinct visual devices and five exact public official music preview sources. Music identity/hashes/analysis are separate from current trend confidence. Sources are selected for topic/rhythm fit; no current ranking or licensing permission is invented. SFX uses exact existing root recordings with honest provenance, not synthesized substitutes.

Movie revisions are immutable local files. Current selections and source identities live in per-short `review/current.json` and batch `MANIFEST.json`; logs, QA, timing evidence and indices remain under `review/`. Local generated media is ignored by Git. Every completed batch receives encoded still/playback/source/audio checks and an isolation comparison. Publishing/uploading the Shorts is a separate action.
