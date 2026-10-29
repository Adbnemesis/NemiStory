# Architecture

The production boundary is `nemi/playable_storytime/`. The uploaded result is a pre-rendered spherical movie; there is no server-side game session, injected JavaScript, collision simulation or per-viewer state. The reusable engine compiles episode data into canonical Nemi acting and a spatially authored environment, then renders a deterministic clock.

## Data flow

```text
Episode story + scene/object data + gameplay contracts
             │
             ├── prepare_episode.py → dialogue and spatial timeline
             │
Canonical voice copies + copied cached models
             └── voice.py → hashed recordings + paced clips + final words
                                      │
                         prepare_episode.py
                                      │
               version-2 scene, mouths, captions, camera/SFX plans
                                      │
             bootstrap.py → independent frozen Godot workspace
                                      │
               existing validator → isolated RenderPlayable.gd
                                      │
              director viewport OR equirectangular room-ray output
                                      │
               FFmpeg mix/encode → render record → metadata injector
                                      │
              MP4 inspection + local view review + YouTube test
```

## Responsibilities and boundaries

| Component | Implementation | Contract |
| --- | --- | --- |
| Narrative source | Episode `scripts/story.json` | Stable chapter/line IDs, narration text, bounded line windows, desired acting recipe, scene clock and five-sentence direction |
| Episode preparation | `tools/prepare_episode.py` | Derive script/dialogue, spatial timeline, interaction manifest, then compile performance against final measured words |
| Voice | `tools/voice.py`, `engine/voice/` | Exact approved Sohee configuration copied with hashes; existing models copied locally; pitch-preserving pacing; source/final durations and hashes retained |
| Canonical animation | Frozen `engine/godot/common/` and character resources | Original rigs, poses, expression/hand/mouth vocabulary remain byte-recorded copies; adapter directs existing controls |
| Panoramic scene composition | `engine/godot/RenderPlayable.gd` and `cube_to_sphere.gdshader` | Four authored room-wall views composed through sphere rays; polar treatment and continuous horizontal wrap; no guessed 16:9-to-360 labeling |
| Timeline | Episode `storyboard/timeline.json`, `scene.json` and audio metadata | One seconds-based clock, stable object/scene/event IDs, exact route landings and final-audio alignment |
| Audio | Existing copied mixer and licensed local recordings | Narration remains primary, event-linked existing SFX and any documented licensed music; exported peaks and audibility reviewed separately |
| Rendering | `tools/render.py` | Freeze inputs, run full validation, capture exact frame count, encode H.264/AAC/BT.709, enforce new output paths and gate 4K on actual complete-review approval |
| Spherical metadata | `tools/spatial_metadata.py` | V2 plus equivalent V1, monoscopic equirectangular; preserve media samples and correct moved chunk offsets |
| Gameplay validation | `tools/validate_episode.py` | Check spatial clues, printed key labels, exact percentage-to-chapter landings, retries and honest no-state contracts; retain legacy timestamp contracts |
| Final digit media QA | `tools/digit_media_qa.py` | Probe the actual encoded clock and save all ten landing views plus three clue views, with hashes; readability and native YouTube behavior require separate review |
| Preview | `previews/index.html`, `previews/serve.py` | Actual video texture, focused continuous WASD and drag/touch; focused top-row0–9 percentage choices and K/Space play/pause, preserving view and pause state; development helpers labeled |
| Isolation | `tools/isolation.py` | Compare outside-project source hashes/metadata against a pre-production baseline, preserving preexisting Git changes |

## Independence and installed runtimes

The host's installed Python environment and FFmpeg are used read-only. The installed Godot executable is copied into the new project's portable cache before production use. Canonical source resources are copied rather than imported from mutable external paths. `dependency_provenance.json` and `episode_snapshot.json` identify dependencies and production inputs. Future changes to the normal storytime pipeline do not silently replace an established snapshot.

TTS and alignment model snapshots are copied from the already cached exact local models into this project's `.cache/models/`, with byte hashes and original snapshot IDs. Voice generation keeps identity settings fixed. New recordings are identified as new performances, not mistaken for saved performances from earlier episodes. ASR timings remain reviewable approximations, not guaranteed phoneme timing.

No new root package files or web framework are required. Python standard-library tools handle orchestration/export/HTTP; the preview uses browser WebGL directly and has no CDN dependency. Generated model weights, audio, caches and movies remain local rather than being committed as source.

## Movie classes and approval

1. A ten-second proof isolates a mechanism.
2. A 30–60 second integrated excerpt checks acting, environment, contact, mouth/caption timing and actual sound together.
3. The complete 1920×1080 director review is the current artistic approval candidate.
4. The 2160×1080 equirectangular review permits viewpoint and puzzle playthrough.
5. The 3840×1920 upload master is rendered only after explicit user satisfaction with the exact complete director review. `review/1080P_APPROVAL.json` binds the user quote, scene hash, production-input signature and preview hash.

Material picture/voice/timing/mix changes invalidate approval. Local validation and a successful metadata parse cannot certify YouTube processing. YouTube-side recognition, controls, compression readability and mobile behavior remain separately reported.

## Extension points

New episodes primarily supply narration, thought beats, locations, objects and navigation contracts. Existing scene-object kinds and canonical acting vocabulary are reusable. A new drawing/object type or genuinely new mechanic requires an explicit renderer/schema/validator/test extension; do not disguise unsupported data as implemented behavior. Keep episode-specific puzzle answers and route times in episode data, not reusable rendering code.

### Drawing result-cue contract

Drawing `entry_card` data uses the existing title/duration/subtitle contract.
The renderer places the short title and relative turn direction at face-canvas
`[960,330]`, size46, inside a normal90-degree horizontal viewport and above
Nemi's hair. A paper-backed1500×110 notice panel spans `[210,260]` to
`[1710,370]`, masking held scenery labels behind the temporary cue. It lasts
only the authored2–4-second window. This is rendered
guidance; native YouTube does not automatically rotate a viewer's viewpoint.

A drawing `paper_exit` object may additionally set `visible_from_event` to
one nonempty canonical story-event name. Exactly one environment action in
its owning scene must use that name, with its absolute `at` inside the scene.
The text is absent before that event and held from its start to the scene end.
Event-gated recovery text uses the same paper-backed notice around its own
position, so an underlying location label cannot cross the retry instruction.
Other `paper_exit` art keeps its original text and underline treatment.
Direct seeking reconstructs visibility from that absolute time. No collected
state, opacity animation or player input is inferred. Other object kinds and
the school renderer reject this field. Objects without it remain visible as
before. Continuity groups include this reveal ownership in their layout
identity. The full drawing game uses the authored rewind event to introduce
recovery text after the failed attempt, keeping the initial chosen-action
receipt separate from the later retry instruction. See
[`examples/drawing_result_cues.json`](examples/drawing_result_cues.json).

### Held material and local continuity context

Drawing `page_tear` objects may set `opened: true` and drawing `paper_tab`
objects may set `folded: true`. These are strict booleans on those kinds only;
school objects and other drawing kinds reject them. Missing or `false` keeps
the existing event-driven animation. `true` renders the completed material
from scene entry without replaying its reveal: the opened tear retains its
depth, receding path and visible desk goal in any drawing location, while the
tab retains the supported folded crossing. This is authored held scenery,
not saved player progress. Continuity layout identity includes both states,
so incompatible finished states cannot share a global/group reconstruction.

A drawing timeline may provide `preview_goal`, one trimmed nonempty line of
at most16 words /140 characters, to keep the same escape goal readable while
the optional local controls change. It does not require automatic turning.

With `world_renderer: "drawing"` and explicit `preview_choice_turns: true`,
`preview_handoffs` may contain ordered `{at,yaw,duration}` objects. Fields are
exact; all numbers must be finite. `at` must strictly increase and equal an
existing noninitial scene start, `yaw` is an authored world yaw in
−180..180degrees (the same convention as `review_yaw`), and `duration` must be
0.2..2seconds and finish within the following scene. The list may be empty or
omitted. No new scene boundary, actor movement, camera pitch or automatic
answer detector is implied. The preview may consume this data only through
its explicit local assistance option; native-view mode keeps viewer control.
Uploaded MP4s and native YouTube seeking cannot execute these handoffs.
Stable movie geography, actor/landmark continuity and visible material
consequences remain necessary independently of this local convenience.
See [`examples/drawing_continuity_context.json`](examples/drawing_continuity_context.json).

### One eraser removes the drawn road

Drawing `ride_eraser` objects may set `erasing: true` to reveal a missing ink-road
strip behind that same moving solid vehicle. The field is a strict boolean;
school objects and other drawing kinds reject it. Missing/`false` preserves
existing vehicle artwork and path behavior. `true` needs an authored `path`
and its existing unique matching `eraser_pass` action, at the same endpoints
and within the existing eight-second maximum. Every path point must have the
same y, and x must increase throughout or decrease throughout; a road-erasing
action cannot climb, stop at an intermediate point or reverse through itself.
Non-erasing paths keep their previous contract.

The renderer places the strip behind the current rear edge, deriving its
length from the existing absolute-time `Motion.point` result. It is absent
before the path starts, advances only during that finite event, then holds
the completed geometry. A straight pale page edge keeps the established
missing-drawn-floor treatment; no torn-paper fibres, continuous dust, opacity
reveal, random motion or synthesized sound is added. The vehicle, its label,
canonical actor support and existing motion accents remain unchanged.
Continuity layout identity includes the `erasing` flag (missing equals
`false`). No viewer state, collision or boarding animation is implied.
See [`examples/erasing_vehicle.json`](examples/erasing_vehicle.json).

### Readable held material landmarks

The drawing renderer additionally supports four fixed context kinds:
`ruler`, `ink_bottle`, `paper_stack` and `paper_clip`. They use the existing
`id`, `author:"nemi"`, `kind`, `x` and `y` object fields; `text` is omitted or
empty. They do not introduce new choices, inventory, automatic viewer state,
environment actions, paths, reveals, material flags, scale/rotation fields
or animated idles. Full and audition validation reject action targets or
choice labels on these context objects. Their stable wall/ID/kind/author/x/y
identity remains part of drawing continuity. These kinds do not extend the
school renderer or canonical character systems.

Bridge and folding-paper art now exposes broad material surfaces in the
ordinary projected view while preserving the established support plane.
The unfinished bridge has a near half deck/rails and a separate far page
bank, with its missing span left empty. A paper tab folds one broad face
around its fixed hinge; its front edge remains at the authored sole plane
when held. The paper's edge-on instant draws a stable contour if area or
triangulation cannot support a fill. Existing finite events and direct-seek
reconstruction own these states; no character walking is inferred.
Exact geometry is documented in
[`DRAWING_MATERIAL_PROFILE.md`](../engine/godot/DRAWING_MATERIAL_PROFILE.md),
with a field-contract fragment in
[`examples/drawing_material_props.json`](examples/drawing_material_props.json).

Limits are explicit: no automatic collection, answer grading, collision response or orientation-aware story change; no end-screen branching for 360 uploads; caption positioning is optional accessibility rather than essential gameplay. TV/VR/device-specific behavior requires actual testing before being claimed.

### Natural successful joins

Drawing timelines may include `natural_continuity`, an array of exact objects
`{at, from_scene, to_scene, actor_wall, position, landmark}`. It describes an
uninterrupted authored result-to-next-thought boundary; it does not execute a
camera callback or infer viewer input. Example:

```json
{"at":144,"from_scene":"the_paper_holds","to_scene":"where_is_the_eraser","actor_wall":2,"position":[320,620],"landmark":"loose_tab"}
```

`tools/continuity.py` validates increasing adjacent boundaries, unchanged actor
sector, preserved landmark kind/wall/x, the required opened/folded completed state, and absence of a new entry card. With
the production spec it checks the actual outgoing shot position (including a
completed vehicle path) against the incoming position and scale. It runs in
the specialized builder, episode validator and export path. A motivated
material match cut may change landmark height/framing while keeping the actor
and destination on the same side; it does not claim an animated walk or
boarding/landing sequence. R7 retains the opened tear and folded tab as held
states, and matches the rider's endpoint into the final studio shot.
