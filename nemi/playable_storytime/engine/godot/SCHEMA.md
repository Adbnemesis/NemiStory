# Panoramic school and drawing compositor

`storyboard/timeline.json` supplies `duration`, `fps`, and contiguous `scenes`.
Every scene has `id`, `start`, `end`, `location`, and `walls`; wall indices are
0 front, 1 right, 2 back and 3 left. Each wall contains `objects` with unique
stable `id`, `kind`, `x`, `y`, mandatory `author: "nemi"`, optional `text` and optional wash `accent`.
Coordinates are a 1920 by 1080 logical wall, rerasterized for native 4K.

Optional scene `actor_wall` selects which cube face receives the unchanged
canonical production-stage texture: integer `0` front (the default), `1`
right, `2` back or `3` left. Booleans, floats, strings and out-of-range values
are rejected. It is an authored staging cut, not a viewer-camera reset or
walking/contact animation. The stage's ordinary shot-local actor position,
scale, acting, ink and mouth timing remain owned by the canonical v2 scene.
Only one wall receives the stage, so a cut does not duplicate Nemi around
the sphere. The existing default/front composition is unchanged.

For a side-sector outcome, set its spatial scene's `actor_wall` and author
the actor's ordinary shot-local position beside the object. For example,
left wall `3` at local `x:1420` is about world yaw −64.4 degrees; right wall
`1` at local `x:500` is +64.4 degrees. A centered actor at `x:960` is at
−90/+90 degrees on those faces, so a directed review near −75/+75 degrees
can include the actor and the chosen prop. Director yaw uses world signs;
the local WebGL audition viewer currently uses the opposite yaw-uniform
sign. Check actual decoded projections rather than assuming these examples
establish readable framing. Spherical output still does not command the
viewer's orientation. Baked spherical captions follow the stage's selected
wall; the director's caption overlay remains unchanged.

```json
{"id":"door_outcome","actor_wall":3,"review_yaw":-75}
```

The fragment still needs its normal scene clock, location and four walls.
This adapter adds no controls to YouTube; local choice-driven view turns
remain a separately tested preview behavior.

Supported kinds: `locker`, `door`, `board`, `bench`, `poster`, `clock`, `clue`,
`trophy`, `speaker`, `badge`, `sandwich`, `duck`, `bear`, `rabbit`, `microphone`,
`form`, `pencil_cup`.
`crossed: true` draws visible crossed pen strokes on an obsolete `board`.
Toy kinds draw recognizable stuffed animals; they do not use trophy stand-ins.
`badge` draws a lanyard and pass; `microphone` draws a microphone on a grounded
stand. These are isolated environment assets; canonical character rigs and
shared author ink implementations remain unchanged.

`form` draws held, slightly uneven cream paper with an authored checkbox and
signature line. Its data-owned `text` supports up to three short lines; each
line fits a 458-unit text area. `pencil_cup` draws five stationary pencils with
visible wood/graphite points inside a soft-wash cup; its bottom is `y + 115`.
Place it at `y: 640` on a bench at `y: 820` to meet the seat top at 755.
Its optional short `text` fits 132 units on the cup. Neither kind adds an
animation clock, random marks, synthetic sound or character-held contact.

```json
[{"id":"volunteer_form","author":"nemi","kind":"form","x":1330,"y":595,
 "text":"VOLUNTEER FORM\nFREE PUDDING\nI CAN HELP"},
{"id":"dessert_pencils","author":"nemi","kind":"pencil_cup","x":1320,"y":640,
 "text":"PENCILS"}]
```

`review_yaw` supplies a static director-view yaw. `review_yaw_path` optionally
supplies increasing absolute scene-clock `{at,yaw}` points, with smoothstep
interpolation and yaw bounded to -180 through 180 degrees. `review_fov` is
50 through 110 degrees, default 85. These affect the directed review only;
sphere output remains a full equirectangular recording without forced viewing.

Optional `environment_events` contain `id`, existing `object` ID, `kind`, `at`
and `end`. Kinds are `clock_tick`, `paper_flap`, `speaker_pulse`. Cues last at
most2.5seconds inside their scene and are deterministic. A clock tick
settles and holds; paper/speaker accents stop when the named event ends.
Sound is linked separately in the production scene specification.

Example scene fragment (also expresses supported object geometry):

```json
{"id":"assembly","start":180,"end":210,"location":"assembly",
 "review_fov":85,"review_yaw_path":[{"at":180,"yaw":0},{"at":198,"yaw":180}],
 "walls":[{"index":2,"objects":[
   {"id":"toy_duck","author":"nemi","kind":"duck","x":520,"y":650},
   {"id":"toy_bear","author":"nemi","kind":"bear","x":960,"y":610},
   {"id":"toy_rabbit","author":"nemi","kind":"rabbit","x":1430,"y":610},
   {"id":"today","author":"nemi","kind":"board","x":960,"y":330,"text":"OLD PLAN","crossed":true}
 ]}]}
```

Run all movie captures through `tools/render.py`. It calls the unchanged copied
production validator and reading gate before graphics, refuses existing output
filenames, and restricts the Godot child's writes to the new production folder.
The 4K switch requires the actual user's approval of the exact complete 1080p
review and hashes of the current source, inputs, and review file. No agent
approval or short proof satisfies that gate.

## Explicit voice and storyboard auditions

A short audition uses `tools/render.py --audition --scene ... --output ...`
with either `--mode review` for the directed 1920×1080 watch cut or
`--mode sphere` for a view-only 2160×1080 panorama. The full audition timeline
must be 30–60 seconds at 24, 30 or 60 fps and explicitly declare
`"kind":"audition"` and `"playable":false`. Scenes cover the exact duration
contiguously with unique IDs, frame-aligned boundaries and exactly four walls
indexed 0, 1, 2 and 3. Every object retains `author:"nemi"` and finite logical
wall coordinates. The ordinary canonical v2 scene, preflight reading record,
approved voice identity and source hash validation still run before capture.

An audition is sequential story review. It has no `navigation`,
`interaction_scenes`, challenges, routes or automatic-state metadata. Visible
number labels can illustrate the planned final movie's controls; they are not
working choices in the shortened cut. A spherical audition lets the viewer
look around without claiming native number-key routes. Reports and validation
records identify `kind:"audition"`, `playable:false`, and no verified YouTube
behavior. `--start`/`--duration` still allow short mechanism proofs. The
`--audition --4k` combination is rejected, and an audition report cannot be
used as the complete episode's 1080p approval receipt.

`world_renderer` selects `"school"` (the existing default) or `"drawing"`.
The latter instantiates `DrawingWorld.gd` using the same four-wall interface.
Drawing objects use one of `sketch_door`, `page_tear`, `eraser`, `paper_shelf`,
`pencil`, `sketch_tree`, `paper_exit`, `binder_ring`, `sketch_bridge`, `paper_tab`,
`page_edge`, `studio_desk`, `ride_eraser`, `ruler`, `ink_bottle`, `paper_stack`
and `paper_clip`, with fields `id`,
`author`, `kind`, `x`, `y`, optional `text` and optional `accent`. Drawing-world
events support `erase_sweep`, `door_flatten`, `tear_open`, `rewind`,
`bridge_break`, `tab_fold`, `eraser_pass` and `escape_reveal`.
Every event has a unique `id`, an existing `object`, `kind`, `at`, `end` and
`event` naming the canonical scene event at the same absolute scene-clock
time. Actions last at most 2.5 seconds and stay within their scene, except
the finite `eraser_pass` vehicle travel, which may last at most 8 seconds. Camera
beats retain their existing measured clock and bounds; a static base FOV of
64 degrees remains valid. `SchoolWall.gd` and canonical character rigs are
unchanged.

The four context kinds `ruler`, `ink_bottle`, `paper_stack` and `paper_clip`
are held drawing-world scenery. They use only the existing object fields;
`text` must be omitted or empty. They cannot own environment actions, vehicle
paths, event-linked reveals, or material-state flags. They do not introduce
click targets, inventory, automatic state, new numbered choices, animated
idles, or per-object scale/rotation fields. They participate in the same
wall/ID/kind/author/x/y continuity identity as other objects. See
[`DRAWING_MATERIAL_PROFILE.md`](DRAWING_MATERIAL_PROFILE.md) for the fixed
art/contact geometry and
[`drawing_material_props.json`](../../documentation/examples/drawing_material_props.json)
for an isolated example fragment. These kinds do not extend `SchoolWall.gd`.

`sketch_bridge` keeps its near front support at `p+[0,85]`, while a broad
near-half deck, two raised rails, planks, a separated far page bank and an
unfilled gap expose its unfinished construction. `paper_tab` keeps a fixed
front hinge at `p+[-260,68]`; a560px sheet folds from a220px-wide upright
face into a560×160px top face. Its existing `tab_fold` event is finite, and
the completed `folded:true` state uses exactly the same supported geometry.
Both retain the existing author and absolute-time event interfaces; no
canonical actor motion is inferred from these material actions.

Drawing timelines may opt into `world_continuity:true`. This is a boolean
field supported only with `world_renderer:"drawing"`; omitting it keeps the
existing scene-local behavior. When true, every scene must retain the same
four-wall layout: each object keeps its wall, ID, kind, author and x/y. Wall
and object list order may differ, and held text/accent can change. Objects
cannot appear, vanish or move between these continuous scenes. Environment
event IDs are unique across the complete timeline.

The director collects those scenes' environment events and gives each wall
only events whose absolute `at` time has arrived. Completed actions remain
available after scene boundaries, so the erased floor and restored door do
not reset at a cut. Reconstructing directly at a later time gives the same
past events; future actions remain absent. The drawing renderer still owns
the finite motion and held result of each event. This opt-in does not alter
`SchoolWall.gd`, regular school timelines or the canonical event/SFX clock.

```json
{"kind":"audition","playable":false,"duration":45,"fps":30,
 "world_renderer":"drawing","scenes":[
  {"id":"paper_room","start":0,"end":45,"location":"paper room",
   "review_fov":64,"walls":[
    {"index":0,"objects":[{"id":"drawn_door","author":"nemi",
     "kind":"sketch_door","x":1400,"y":540,"text":"1 DOOR"}]},
    {"index":1,"objects":[]},{"index":2,"objects":[]},
    {"index":3,"objects":[]}]}]}
```

The fragment demonstrates only the spatial timeline; the canonical production
scene still supplies actual narration, acting, captions, sound and preflight.
Run the independent timeline check with
`tools/validate_episode.py --audition --episode ...`; its record
is `review/audition_checks.json`, separate from full gameplay checks.

Every production wall object declares `author: "nemi"`; this engine uses the canonical Nemi paper/ink identity. A finite environment event must target an existing object, fit inside its scene, respect its per-kind lifetime and name the same story event as its SFX cue. Clock ticks settle and hold; paper flaps end; no unbounded ambient bobbing.

## Full drawing-world games and separate continuous sets

The full episode validator accepts `world_renderer:"drawing"` with the same
real ten-key percentage map, complete scene clock, no automatic state and
bounded one/two-choice contracts as school episodes. It does not convert an
audition into a full game or infer native YouTube controls from labels.
For the 240-second drawing escape, all ten percentage landings remain
0, 24, 48, 72, 96, 120, 144, 168, 192 and 216 seconds. Only 1/2, 4/5 and 7/8
need be advertised as decisions. A path through 2, 5 and 8 still uses ordinary
native percentage seeking; unadvertised keys retain their native landings.

Instead of one global `world_continuity:true` layout, drawing scenes can each
declare `continuity_group:"paper_room"`. Grouped mode requires a trimmed,
nonempty string of at most 64 characters on every scene, and cannot be mixed
with global continuity. Each group's scenes keep the same wall/object IDs,
kinds, author, x/y and any authored vehicle path; different groups can have
different physical sets. Text/accent may change. Event IDs remain globally
unique to preserve canonical event/SFX identity.

The compositor gathers a group's environment events across its scenes and
reconstructs only events whose absolute time has arrived. On a direct seek,
the current group receives its own past events and never receives events
from another room, gap, page edge or studio. Future events remain inactive.
`world_continuity:true` retains the approved R4 behavior, and ungrouped scenes
without that flag retain ordinary scene-local events.

```json
{"world_renderer":"drawing","scenes":[
 {"id":"room_intro","start":0,"end":24,"continuity_group":"room"},
 {"id":"door_failure","start":24,"end":48,"continuity_group":"room"},
 {"id":"tear_success","start":48,"end":72,"continuity_group":"room"},
 {"id":"gap_choice","start":72,"end":96,"continuity_group":"gap"}
]}
```

These fragments still need their full ordinary scene/wall contract. Group
validation is not a visual contact proof or permission to move canonical rigs.

## Already-aboard eraser transport

`ride_eraser` may have a finite scene-clock `path`. It contains at least two
points, each exactly `{at,position}`; times are finite and strictly increase
inside the owning scene. Positions contain exactly two finite wall coordinates
strictly inside 1920×1080. The first position equals the object's x/y; the last
time is no more than eight seconds after the first. No bends, looping,
automatic walking, speed fields or alternate path player are accepted.
The object requires exactly one `eraser_pass` event on that same object whose
start/end equal the path endpoints. Endpoint positions hold outside travel.
Only `ride_eraser` supports this world path.

An optional scene `actor_transport` is exactly
`{actor:"nemi",object:"ride_eraser_id",event:"ride_travel"}`. The target must be
a unique `ride_eraser` with that path on `actor_wall`, and its `eraser_pass`
event must name the same canonical story event at the path's first time.
The frozen production scene must contain the canonical Nemi actor alone and
one complete matching shot with camera `{center:[960,540],zoom:1}`. Panoramic
review yaw/FOV supplies directed framing without rescaling the actor layer
against the vehicle. Invalid target, name, ownership, duration or path fields
fail validation before capture.

```json
{"id":"eraser_ride","start":192,"end":216,"actor_wall":1,
 "continuity_group":"ride",
 "actor_transport":{"actor":"nemi","object":"ride_eraser","event":"ride_travel"},
 "walls":[{"index":1,"objects":[
  {"id":"ride_eraser","author":"nemi","kind":"ride_eraser","x":650,"y":780,
   "path":[{"at":198,"position":[650,780]},
           {"at":206,"position":[1150,780]}]}
 ]}],
 "environment_events":[{"id":"ride_motion","object":"ride_eraser",
  "kind":"eraser_pass","at":198,"end":206,"event":"ride_travel"}]}
```

The example still needs all four walls and the corresponding canonical
production shot/event. `DrawingWorld.gd` samples the existing canonical
`Motion.point` for the vehicle; after `ProductionStage.sample`, the compositor
adds that same path displacement minus the object's base position to the
stage's world. The canonical stage resets its world transform each sample,
so offsets do not accumulate and arbitrary-time reconstruction stays
deterministic. The stage node already owns native resolution scaling; the
adapter does not scale the displacement a second time. Captions remain outside
the translated world, and rigs, recipes, hands and mouths remain unchanged.

This adapter describes a cut with Nemi already aboard, followed by authored
vehicle/rider transport. It does not animate boarding, landing or walking.
The author must place the soles on the vehicle's supported top and inspect
contact, anatomy, both endpoints and full playback in a fresh proof before
using the scene in the film. Passing the structural checks does not prove
that contact looks convincing.

Episode001 contact example: the three assembly toys rest at x520/y650 (duck), x960/y610 (bear), x1430/y610 (rabbit). Matching bench centers are x520,960,1430 at y820; their seat top is755, matching each toy’s authored silhouette bottom.

## Native YouTube number choices

The gameplay manifest can declare `navigation.mode: "youtube_digits"` with
`key_targets`, exactly ten `{key,chapter}` entries. `key` is an integer 0–9;
`chapter` names a scene ID. The actual YouTube destination is
`duration * key / 10`, so every named scene must begin exactly there and the
destination must fall on an encoded frame. For a 240-second movie, keys 0–9
land at 0,24,48,72,96,120,144,168,192,216 seconds. This is percentage seeking,
not a creator-programmed key callback. Changing the final movie duration
requires revalidating every landing.

In this navigation mode, each challenge includes `solution_key`, `retry_key`
and `alternative_keys` (an empty array is valid). Its printed `solution` is
`"PRESS N"` or an anchored digit plus outcome, such as `"3 USE BADGE"`.
A lone digit or a digit buried in unrelated text is rejected. The complete
label must be present on the actual clue. `valid_destinations` is the answer key's exact landing, and
`alternative_outcomes` matches the alternative key landings. `retry_method`
must explicitly say `Press N` for its actual retry key. The same optional
`navigation` object may be copied into the spatial timeline for the local
viewer; if present it must agree with the manifest. Legacy timestamp
contracts remain supported when `navigation` is absent.

```json
{"navigation":{"mode":"youtube_digits","key_targets":[
  {"key":0,"chapter":"cold_open"},{"key":1,"chapter":"badge_hunt"},
  {"key":2,"chapter":"badge_hint"},{"key":3,"chapter":"badge_recovery"},
  {"key":4,"chapter":"notice_puzzle"},{"key":5,"chapter":"pudding_detour"},
  {"key":6,"chapter":"assembly_arrival"},{"key":7,"chapter":"final_hunt"},
  {"key":8,"chapter":"final_hint"},{"key":9,"chapter":"payoff"}]}}
```

The local viewer emulates focused top-row digit keys and K/Space play/pause;
it preserves viewing direction and paused state after a choice. Its legend
only labels scenes when all ten actual percentage positions match. A video
and timeline duration mismatch hides those labels. These are local controls;
the upload must be tested in YouTube itself. Desktop viewers need player
focus. Mobile viewers use available named YouTube chapters and app swipe;
the native mobile player does not acquire our local keyboard handler or
custom clickable buttons. Captions remain timed text, with no answer
detection or programmable click action.

Source: [YouTube keyboard shortcuts](https://support.google.com/youtube/answer/7631406?hl=en).

### Optional local choice turns

A full drawing timeline may declare `preview_choice_turns:true`. The field is
strictly boolean; the enhanced option is accepted only for the drawing
renderer, with a finite `review_yaw` between −180 and +180 on every destination
scene. This metadata configures the local review UI only. The original R9
preview, and every timeline without the flag, keep their existing view/pause
behavior and do not display the extra control.

The flagged preview shows a checked **Turn toward choices** checkbox. A
selection retains its exact native percentage seek and pause/play state while
the local viewport turns toward the destination's authored `review_yaw` over
340 milliseconds. World yaw is negated for this WebGL viewer's yaw uniform.
The latest rapid choice replaces the earlier turn; stale seek completions
cannot reveal an old scene. The ordinary loading cover remains until a decoded
selected frame has been painted. Dragging or W/A/S/D cancels an in-progress
turn, and the viewer can always keep looking independently.

Unchecking the checkbox enables the labeled **Native behavior** mode: number
seeks preserve the viewing direction, including key 0. With the convenience
enabled, key 0 returns toward the forward opening. **Face Nemi** is an explicit
local recovery action; for a flagged drawing set it uses the current scene's
authored view instead of assuming Nemi always occupies the front wall. No
selection starts or resumes playback automatically. The checkbox, note and
optional timeline `title` are local UI; the movie still does not run JavaScript,
detect answers or command the native YouTube viewport.

## Entry result cards and bounded choice prompts

A scene may include `entry_card: {duration,title,subtitle}`. The duration is
2–4 seconds and shorter than the scene. The title is one line, at most eight
words/72 characters; the subtitle is one line, at most twelve words/104
characters. Use concrete route feedback such as `3 BADGE FOUND` and the next
objective. These are baked result slates shown at every visit to that scene,
including linear playback; they never claim the movie detected a choice.

`SchoolWall.gd` repeats the same outcome during
`[scene.start, scene.start + duration)`. R8 keeps the front receipt compact
beside Nemi at rectangle `[980,240,690,230]` on the 1920×1080 logical wall.
Its title starts at 48px, subtitle at 34px with fixed fit-to-width typography;
the front landmark says `NEMI IS HERE`. Nemi's canonical production stage
stays visible so her opening thought, face and body reaction can play while
the result is readable. The three peripheral walls retain the larger opaque
cream/plum card: title 72px, subtitle 44px and direction 50px. Their orientation
lines are right `TURN LEFT TO NEMI`, back `TURN AROUND TO NEMI`, and left
`TURN RIGHT TO NEMI`. Finished lettering stays still throughout the hold.

The camera/viewpoint is never reset in the spherical movie. Inspect actual
entry, just-before-expiry and just-after-expiry captures. Check that the front
receipt and current acting remain readable together, and that the three
away-facing views retain matching feedback and directions back to Nemi.

The spatial timeline may additionally contain `interaction_scenes`, one
prompt per scene in the same full scene intervals. Each prompt contains
`id` (the scene ID), `start`, `end`, `objective`, `choices` and optional
`feedback`. The objective is a one-line maximum of sixteen words/140
characters. Feedback is optional one-line text up to twenty words/160
characters. A prompt can have zero, one or two choices; a choice is exactly
`{key,label,chapter}`, with a unique integer key 0–9, a concise one-line
label up to ten words/80 characters and the chapter ID from that key's real
percentage destination. Choice intervals extend through the scene end;
the final scene can offer key 0 to replay. If the gameplay manifest also
contains `interaction_scenes`, it must match the timeline exactly. This
describes readable prompts for the review interface and native key choices;
it does not embed clickable controls in uploaded video pixels.

```json
{"entry_card":{"duration":3.5,"title":"3 BADGE FOUND",
 "subtitle":"READ YOUR NEW JOB TITLE"}}
```

```json
{"interaction_scenes":[{"id":"badge_recovery","start":72,"end":96,
 "objective":"Read the badge and choose the next route",
 "choices":[{"key":4,"label":"Inspect the notice","chapter":"notice_puzzle"}],
 "feedback":"The badge reveals an unfortunate promotion"}]}
```

The second fragment shows a single prompt only; a complete production
supplies one for every scene. Unknown prompt fields such as answer
detectors are rejected, as are missing scenes, scene interval drift,
duplicate keys and choices whose chapter does not match the native key.
When interaction prompts are present, each challenge's answer key must also
be offered by a choice during that challenge. Badge labels fit within
260 logical pixels and sandwich labels within 300, with a 28px minimum.

R6 keeps headings within the director frame with chapter `heading_size`
(default40) and uses compact held Nemi-lettering key prompts. `review_look`
and `review_return` in story chapters are `{clip_id,word}` anchors in final
measured voice; preparation builds bounded0.8second director turns and saves
the exact word intentions. The sphere never inherits those turns.
A badge label beginning `STAR\n` uses the held uneven star artwork above
the remaining key label. No new canonical rig or drawing player is involved.

A clue beginning `TODAY\n` also carries the held star stamp, so the spoken
star-correction instruction matches an actual visible shape.

## Measured conversational performance (R8 compiler)

Chapter `drawing` and `prop` are optional. Missing, null, empty or non-string
values produce no persistent heading/prop plate. A nonempty string retains
the earlier full-chapter plate behavior. The chapter focus supplies the
direction beat's visual intention when a heading is omitted; a label is not
required to make a performance beat valid.

Use `story.additional_props` for deliberately timed evidence, with the actual
version-2 prop fields (`author`, `kind`, `at`, `end`, position/scale and optional
shot filters/path/attachment). The compiler passes these through to `props`
and the copied production validator checks their complete field contract.
Like `additional_drawings`, an optional named `event` plus `event_offset`
resolves `at` from the final measured event. A missing named event fails.
The compiler does not invent contacts, animations or a different lifetime.

```json
{"chapters":[{"id":"badge_result","drawing":null,"prop":null}],
 "additional_props":[
 {"author":"nemi","kind":"clipboard","at":0,"end":92,
  "position":[1200,480],"scale":[0.9,0.9],"mode":"hold",
  "shots":["badge_result"],"event":"acting_read_job","event_offset":0.1}
]}
```

The chapter fragment still needs its ordinary clock, location and dialogue
fields in a complete story. The named event must actually exist.

Story dialogue lines still select an existing `recipe`. They may additionally
set `duration` (default 0.34 seconds), `motion` (`smooth`, `snap` or `stepped`),
`step_fps` (8/10/12/15, only with stepped motion), normalized `gaze`, supported
`face` refinements, `hands`, and absolute scene-clock `blinks`. These are the
existing version-2 actor controls. Only provided optional controls are copied;
line order does not invent a gaze, relaxed hands, a blink or a fixed cadence.
The copied production validator remains authoritative for ranges, supported
recipes/shapes and non-overlapping transitions. Snap motion resolves to a zero
duration transition in the existing player. Do not use a grip pose without
actual contact; explicitly author open/relaxed hands for empty-handed speech.

`story.acting_beats` adds thought changes inside a spoken line. Each has a
unique lowercase `id`, `clip_id`, exact spoken `word`, existing `recipe`, and
optional zero-based `occurrence`, `offset` (−2 to +2 seconds), `intent`, and
the same performance fields. The compiler resolves the final measured word,
creates event `acting_<id>` and gives the actor cue that same event and time.
No timing is guessed from character count or an earlier voice take. A beat
must stay inside the chapter owning its clip; duplicate beat times, unknown
fields and missing word occurrences fail. An explicit word beat at precisely
a line's baseline time replaces that baseline pose. Otherwise the production
validator checks every transition and blink against the next authored cue.

```json
{"acting_beats":[{"id":"inspect_lunch","clip_id":"r8_2_0",
 "word":"qualifications","offset":-0.06,"recipe":"skeptical",
 "duration":0.42,"gaze":[-0.55,0],"hands":{"right":"open_palm_up"},
 "intent":"Interview lunch like an applicant"}]}
```

A chapter may supply `camera_beats` with `clip_id`, exact `word`, `yaw`, `fov`,
`intent`, optional `pitch` (default zero), `occurrence`, `offset` and transition `duration` (default
0.32). The clip must belong to that chapter; anchors and complete transitions
must fit inside it and increase without overlap. Yaw is −180..180, pitch is
−25..25 and FOV is 34..110 degrees. Preparation writes measured
`review_camera_beats` as `{at,yaw,pitch,fov,duration,intent}` on that spatial
scene and in `camera_plan.json`.
These control the director's whole-world projection; they do not zoom Nemi's
transparent stage against unchanged school walls. They do not force the
spherical viewer's orientation. `camera_beats`, when provided, supersede the
older `review_look`/`review_return` compiler path for that chapter.

The director adapter reparents the canonical stage's caption label above the
projected picture, retaining the stage's measured text/timing while keeping
it readable during portraits and turns. Spherical captions remain in the
front-wall artwork; the packaged SRT provides ordinary player captions.
Before any capture, `tools/render.py` independently checks the frozen
`review_camera_beats` data for finite numeric values, yaw/pitch/FOV bounds,
strictly increasing times, nonnegative transition durations, no overlapping
transitions, and complete scene ownership. This catches modified or stale
compiled camera data even if it did not come through the story compiler.
Static `review_fov` retains the wider 50..110 range; tighter 34-degree
portraits require an explicit measured camera beat and readable face framing.

```json
{"camera_beats":[{"clip_id":"r8_2_0","word":"qualifications",
 "yaw":-8,"pitch":16,"fov":34,"duration":0.18,
 "intent":"Read the suspicious reaction without moving the furniture"}]}
```
