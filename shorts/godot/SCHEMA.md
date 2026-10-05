> Accepted version2 history. New ink Shorts use [V3_WORKFLOW.md](V3_WORKFLOW.md), [V3_SCHEMA.md](V3_SCHEMA.md) and the corresponding author skill.

# Version-2 Godot music-edit spec

`validate_ink.py` validates this separate Shorts format before `render_ink.py` dispatches `render_batch.gd`. Version 1 remains the original monochrome comparison proof. Use version 2 for new edits. Unknown fields are rejected at every documented object level; extending the source requires updating this schema and an example together.

All picture times are **integer frames at 30 fps**. Audio source positions/durations are seconds. Canvas and screen coordinates use the native **1080 × 1920** portrait units. Color strings use `#RRGGBB`.

## Root

| Field | Meaning / accepted value |
| --- | --- |
| `version` | `2` |
| `id` | Lowercase letters/digits/hyphens; used in the output filename |
| `title` | Descriptive production title |
| `fps`, `width`, `height` | Exactly `30`, `1080`, `1920` |
| `frames` | Integer 240–660, or 8–22 seconds |
| `premise` | One stable string, at most 100 characters; `\n` creates a line break |
| `music` | One saved audio section, described below |
| `sfx` | Array of event-linked recorded cues; use `[]` for none |
| `actors` | Actor definitions with their cue arrays |
| `shots` | Ordered nonempty compositions, starting at frame 0 |
| `theme` | Paper/ink/shading/accent choices |
| `events` | Authored finite drawings; use `[]` for none |

## Audio section

`music` requires `file`, `sourceHash`, `sourceStart`, `duration`, `gainDb`. `file` is a workspace-relative existing file resolved inside the workspace. `sourceHash` must equal the current file's SHA-256 exactly. `sourceStart ≥ 0`; duration must be positive and the entire interval must fit the source. Music duration must equal `frames / fps`. `gainDb` is −40 to +12 dB; this is gain, without tempo or pitch changes.

Each `sfx` cue has the same five audio fields, plus `event` and optional integer `offsetFrames` (default 0). `event` must match an event ID. The audio file must resolve under `common/audio/sfx/`; its saved original inventory identity/provenance should also be recorded in the production review. Cue onset is `events[event].at + offsetFrames` and must fall within the short. A negative offset is useful for an audible clip attack that should arrive with the picture. `sourceStart` removes silence only when the actual recording supports that choice. The mix is trimmed at the end of the short.

## Theme

Required fields are `signature`, `paper`, `ink`, `shade`, `accent`. Optional `shading` is 0–0.6, default 0.28, controlling wash opacity.

`signature` accepts `sound`, `runway`, `doodle`, `duo`, `camera`. Currently `sound` automatically draws headphones on visible poses. Other signatures identify the edit's visual family; they do not automatically choose a stage or generate events. Author those choices explicitly. An `ink` shot palette swaps paper and ink colors; shade and accent retain their saved colors.

## Actors and cues

An actor has unique `id`, `author` (`adb` or `nemi`) and nonempty `cues`. Each cue requires `frame`, `pose`, `expression`, `gaze`; cues must increase strictly, start at frame 0 and remain below `frames`.

| Cue field | Values / default |
| --- | --- |
| `pose` | A pose name actually declared in the selected original pose library; unknown names fail |
| `expression` | Existing author-specific expression control for the hidden original rig |
| `gaze` | `[x,y]`, each −1 to +1; visible supplemental face uses `x` |
| `eyes` | 0–1.3; default 0.95, applied to hidden rig |
| `head` | −30 to +30 degrees; default 0; visible drawing settles to 0.24 × this value |
| `motion` | `snap`, `smooth`, `stepped`; default `snap`, applied to hidden rig |
| `duration` | 0.001–2 seconds; default 0.2, applied to hidden rig |
| `blinks` | Optional existing acting blink cues, passed to hidden rig |
| `view` | `front`, `threequarter`, `profile`, `back`; default `front` |
| `emotion` | `shy`, `smile`, `shock`, `cover`, `deadpan`; default `shy`, visible illustrated expression |
| `action` | `rest`, `listen`, `glasses`, `peace`, `wave`, `phone`, `sketch`, `point`; default `rest` |

The validator checks original pose names and the listed numerical/enumerated fields. It does not yet enumerate every original expression or validate the contents of `blinks`; use actual supported controls. The visible body is supplemental authored art, selected independently of the hidden rig pose.

Actions draw fixed hand/prop or gesture shapes. `listen` adds headphones, `glasses` adds sunglasses, `phone` holds a phone and `sketch` locks a pencil/sketchbook to the authored grip. Nemi back cues accept `rest` or `listen`; ADB back cues accept `rest` only. Other back contact actions fail validation. Current ADB back art omits gesture/accessory additions entirely. There is no walking or pickup/release field.

## Shots

Each shot requires `frame`, `zoom`, `center`, `actors`, `move`. Frames increase strictly, start at 0 and remain below `frames`. The latest shot holds until the next shot/end.

| Shot field | Values / default |
| --- | --- |
| `zoom` | 0.5–3 |
| `center` | Finite `[x,y]` in scene units; this point is placed at screen center |
| `actors` | Nonempty object keyed by known actor IDs; omitted actors are hidden |
| `move` | `cut`, `punch`, `pull`, `whip` |
| `angle` | Initial camera tilt −20 to +20 degrees, settling to 0; default 0 |
| `settle` | 1–15 frames; default 5 |
| `direction` | `−1` or `1`; default 1, sets whip side |
| `palette` | `paper` or `ink`; default `paper` |
| `stage` | `plain`, `door`, `columns`, `page`, `viewfinder`, `runway`; default `plain` |

Each shot actor block requires `position: [x,y]`, `scale: 0.1–5`; optional `flip` is −1 or +1, default +1. Actor positions are in the transformed scene; stages/doodles stay at fixed screen coordinates behind characters. The pencil wipe and flash use a separate foreground layer. `door` includes the authored `LAB 3` sign/floor cues. `page`, `columns`, `viewfinder` and `runway` draw their respective sparse framing.

Punch begins 13% larger than saved zoom; pull begins 23% larger. Both ease to saved framing. A whip starts 420 screen units to its chosen side and settles; its smear lasts the first two frames. The completed drawing is held rather than continually jittering.

## Events

An event requires unique `id`, `at`, `end`, `kind`, `position`. `at/end` are integers with `0 ≤ at < end ≤ frames`. The visible span is `[at,end)`.

Optional `scale` is 0.1–3 (default 1), `rotation` is −360 to +360 degrees (default 0), and `accent` selects accent color when true or ink when false (default true). Position is fixed screen `[x,y]`; rotation/scale apply to the authored mark.

`kind` accepts `stars`, `arcs`, `notes`, `heart`, `zigzag`, `brackets`, `moon`, `cloud`, `leaf`, `rays`, `dash`, `pencil`, `flash`. A flash may last **at most two frames**. The pencil is a large authored foreground graphic moving across the screen over its event span; it does not create a physical tool interaction. Other doodles use a deterministic four-frame scale entry, then hold still. The flash is a two-frame transparent wash. Ended marks disappear; no opacity-only pretend handwriting or random redrawing is supplied.

Example shot and event, to insert in a complete spec:

```json
{
  "shot": {
    "frame": 120,
    "zoom": 1.4,
    "center": [540, 750],
    "actors": {"nemi": {"position": [540, 1030], "scale": 1.5}},
    "move": "whip",
    "direction": 1,
    "settle": 6,
    "stage": "viewfinder"
  },
  "event": {
    "id": "pose-arrival",
    "at": 120,
    "end": 180,
    "kind": "stars",
    "position": [230, 620],
    "scale": 0.8,
    "accent": true
  }
}
```

`shot`/`event` above are explanatory labels, not root schema keys. Put their contents in `shots`/`events`. For a full valid production file, use `batch01/01-my-song/short.json`. Validation establishes source/timing/schema consistency; actual picture, contact, music sync and audibility still require exported review.
