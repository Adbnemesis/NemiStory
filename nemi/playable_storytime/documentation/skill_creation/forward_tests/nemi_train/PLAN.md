# Nemi — The Last Train in the Globe

Planning-only skill trial, 2026-10-27. No episode, script, scene, audio, renderer, upload or global files were created/changed. This is a proposed design, not an implemented or tested game.

**Delivery promise:** one spherical YouTube upload, exactly 180.000 seconds at 30 fps (5,400 picture frames). Three two-way choices. The file lasts three minutes; viewers who pause or seek can spend more or less time with it. No inventory, answer detection, saved route, clickable drawn props or automatic unpause.

## Causal spine and direction

Nemi winds a souvenir station globe beyond its stop to make the last train run. Its enchanted winding mechanism shrinks her into the station and seals the glass. The engine has stopped one circuit short of HOME. Before the first choice, show the gear diagram connecting one completed train circuit to the dome latch and the restoration of normal scale. The outside home tabletop remains visible through the glass; the HOME arch and the unfinished circuit stay recognizable throughout.

She wants to restart that train, finish its circuit and undo her own mistake. Viewers look for physical evidence and select preauthored actions. Winding the motor provides power, which reveals that the points face a dead-end loop; aligning them provides a route, which makes the still-applied wheel brake the last obstruction. Releasing it lets the same train complete the circuit, turn the visible base gears, lift the dome and restore Nemi at her home tabletop. The last image echoes her initial hand over the winding key; she puts it down with earned relief. Nothing new rescues her after the final decision.

Nemi is observant, worried, then dryly self-aware. Eyes find a clue before head/body follow; gestures settle into thought-specific holds. Use her canonical rounded warm ink, cream paper, soft washes and restrained brass/red/teal prop accents. The station is scenery: canopy, bench, rails, ties, platform edge and tunnel depth. It cannot be represented by a STATION label. One audience focus at a time; stable completed ink; quiet relief is allowed.

## Choices, evidence, results and recovery

| Decision / inspection | Offered actions | Result / inexpensive recovery |
|---|---|---|
| Power: square winding socket beside the stopped motor; matching square key. The globe visibly shakes snow without turning the motor. | **2 SHAKE THE GLOBE** / **3 WIND THE ENGINE** | 2: brief snow whiteout, Nemi brushes snow off; motor remains still. The snow settles and she fits the key ready for the useful attempt. Show/say **3 WIND THE ENGINE**, or **1 FIND THE SOCKET** to inspect again. 3: key turns, spring takes tension, headlamp lights and wheel tries against its stop. Power remains on. |
| Route: follow the actual rails. One branch curls back to the same bench; the other continues to the HOME arch and base gear. A large points lever has two distinct end positions. | **5 TAKE THE LOOP** / **6 SET HOME POINTS** | 5: a short empty-train shunt returns visibly to the same bench; reverse to the switch before the boundary. Nemi's dry reaction identifies the mistake without a lecture. Show/say **6 SET HOME POINTS**, or **4 TRACE THE RAILS**. 6: lever and rails align continuously toward HOME; completed setting stays. |
| Departure: lamp on and route aligned, but a broad red brake shoe still presses the visible wheel. Whistle tube points upward; brake linkage runs to the shoe. | **8 BLOW THE WHISTLE** / **9 RELEASE THE BRAKE** | 8: whistle sounds, snow slips from canopy, wheels stay fixed. Nemi notices the shoe; show/say **9 RELEASE THE BRAKE**, or **7 CHECK THE WHEEL**. 9: shoe lifts visibly, wheels turn, the train completes its circuit and opens the dome. |

The alternatives have different physical effects, not arbitrary answer grades. No timed reflex is required. Choices remain available while the movie continues; viewers may pause voluntarily. Direct success route is 0→3→6→9, with clue scenes encountered between successes. All wrong routes, including 2→3, 5→6 and 8→9, are coherent. Retry keys 1/4/7 return to inspection within the same story. An uninterrupted watch sees Nemi make each harmless mistake, recover and succeed. Replaying a previous step deliberately revisits its authored state; the movie does not remember progress. Each landing starts with its needed physical state and a short contextual line, without reintroducing the entire game.

## Instruction example (planning illustration only)

Spread this through the first 36 seconds while Nemi handles the actual socket/key; do not isolate a tutorial card:

“Drag to look around—or swipe in the YouTube app. See that square socket? Click the video, then press 2 to shake the globe or 3 to wind the engine. If you paused, press K or Play after choosing. On a phone, open the matching numbered chapter; if it isn’t available, use that number’s time in the description. You can press 1 to look again.”

Show desktop/phone instruction lines sequentially. Labels live beside large real props, clear of captions, faces, seams and poles. Drag/swipe changes the view; choosing a number selects a filmed action. Drawn objects and labels are not tap targets. The matching chapter and timestamp labels must use exactly the wording in the map. Restart is **0 START AGAIN** / 00:00. This is provisional copy to shorten after a read-aloud, not a claim that this much instruction fits over still imagery.

## Complete file clock / native map

Every key k lands at 180×k/10; every chapter is 18 seconds, above YouTube's 10-second minimum. The full ten-entry planning map is in `key_map.json`.

| Key / chapter time | 18-second window and visible progression | Main sector / carried state |
|---|---|---|
| 0 / 00:00 START AGAIN | Overwind, shrinking/seal, visible circuit/latch rule; looking demonstrated inside the predicament. | Front station; HOME arch and outside tabletop established. |
| 1 / 00:18 FIND THE SOCKET | Discover square socket/key; choosing/resume/phone instructions; offer 2/3. | Engine front; train stopped, brake applied, loop selected. |
| 2 / 00:36 SHAKE THE GLOBE | Shake and settling snow, reaction, useful socket reveal, key fitted; offer 1/3. | Same engine/actor support; no lasting power change. |
| 3 / 00:54 WIND THE ENGINE | Wind, motor/headlamp response, rail route revealed; gaze leads toward points. | Engine front; power remains on into key 4. |
| 4 / 01:12 TRACE THE RAILS | Follow rails from engine to branch and HOME arch; offer 5/6. | Right/front-right points; lit engine remains a landmark. |
| 5 / 01:30 TAKE THE LOOP | Empty train shunts around short loop, returns and reverses to points; reaction/recovery; offer 4/6. | Same station; Nemi stays grounded at switch. |
| 6 / 01:48 SET HOME POINTS | Lever/rails align; visible short boarding with authored hand/foot contacts; train still stopped. | Match actor endpoint/support continuously; aligned rail stays into key 7. |
| 7 / 02:06 CHECK THE WHEEL | Show Nemi aboard and wheel/brake contact at readable height; offer 8/9. | Train front near brake; power/points already restored. |
| 8 / 02:24 BLOW THE WHISTLE | Audible whistle, finite snow slip, wheels still stopped, brake observation and grip preparation; offer 7/9. | Same train support and brake; no position reset. |
| 9 / 02:42 RELEASE THE BRAKE | Release ~2s, train circuit ~8s, base gears/dome open ~3s, home restoration and relief ~5s. | Visible motivated scale/unwinding transition; original home payoff by 03:00. |

These are action budgets, not permission for waiting tails. Plan roughly 250–285 final spoken words with room for looking, motor/rail/boarding action and reaction. Measure the canonical recording before locking internal beats. Rewrite or redistribute action within the fixed 180-second clock when speech is short/long; never fill a silent tail or rush instructions. Inspect every ordinary gap over about two seconds for a specific physical/reading/emotional reason. Film remains useful during each 18-second wrong-result window: effect → reaction → evidence → preparation, without a long repeated explanation.

## Geography, props and continuity

Use a single station enclosure with engine at yaw 0°, points near +60°, HOME arch near +110° and a readable home tabletop beyond the glass. Keep engine socket/key, lever/rail junction, brake/wheel broad and near normal eye level; include material thickness, support, rail continuity and depth. Inspect ordinary 85–90° rectilinear views, not only the spherical strip. Numbers must remain legible on a small viewport without tiny embedded diagrams. Put option and result in the same sector. Spoken stable landmark guidance and brief authored directional notices lead a viewer who is facing elsewhere; the upload never forces a turn. Preserve yaw/pitch/pause when seeking in native tests.

Keep an authoring ledger per landing: actor sector/endpoint/scale/support and grip; train position; motor power; selected route; brake state; dome state; viewer evidence. Successful joins 3→4 and 6→7 preserve endpoints and completed material. The loop returns before 108s; boarding is an actual authored sequence, not floating root translation or an unexplained cut. Named events tie motor engagement, points movement, whistle, brake release, wheel start and dome latch to finite VFX and existing recorded SFX. No continuous snow/noise filler. Listen to the encoded mix for actual prominence beneath narration.

## Production and verification strategy

1. On authorization to produce, allocate a fresh canonical `nemi/episodes/epNN_last_train_in_the_globe/` through the current helper; run the canonical preflight, read all required parts in order and save episode-specific notes before script/spec authoring. No readiness receipt is claimed for this planning trial. Inspect actual EP06 colour and Nemi art then.
2. Resolve the isolated-helper-root boundary with a scoped maintained adapter, or a validated spherical integration at the canonical stage. Inspect help/code before choosing. Do not replay episode002's story compiler, bootstrap over frozen games, change rigs/Sohee settings or place a real episode in examples.
3. Existing panorama kinds do **not** include train, globe, points or brake. Implement/document/test a maintained station asset/event extension before using those names in a scene: schema, profile geometry/contact, example, renderer, gameplay/direct-seek validation and meaningful tests together. Preserve canonical acting. No station capability is claimed today. Prove the gear/latch, contact and deterministic direct-seek states with a fresh 10-second proof; inspect stills **and playback**.
4. Use exact canonical Sohee route or approved source recordings with hashes; preserve source takes. Pace only selected dragging phrases once from source, normally 1.08–1.12 and never above 1.15; preserve breaths and relief. Independently align final processed audio, then build mouths, captions, acting, drawings, camera and SFX from that final clock. Select recorded SFX from current root inventory/library with provenance; no synthesis for effects.
5. Render a 30–60s integrated story excerpt with real voice, contact-wide/full-body acting, close mouth detail, setting, held/live ink, props, captions, event-linked sound and a small payoff. It is a nonplayable audition or clearly labeled excerpt; its digit percentage clock does not validate the three-minute game.
6. Validate full v2 production and exact ten-target/choice/retry map. Render the complete current 1920×1080 director review plus 2160×1080 equirectangular view review. Fully decode/probe: 180.000s, 5,400 frames at 30fps, codec/pixel format, 48k audio, headroom, black/gaps and spherical metadata. Check actual encoded percentage landings within one frame, including all unadvertised keys; any retime/remux duration change requires fresh checks. Inspect all choices/results from front/right/back/left preserved views, hands/wrists/feet, intermediate contacts, seams/poles, small layout and successful joins. Watch and listen continuously.
7. Cold-viewer test with only the film/instructions: origin/goal, why each action worked, where props are, how to choose/resume/recover. Exercise direct successes, each wrong/retry route, mixed route, passive watch, paused seek + resume, manual looking and rapid seeks in the actual local browser. Separate source/numerical results, viewed images, playback and listening evidence.
8. Deliver the full current 1080p cut and wait for explicit user satisfaction before any 4K movie/proof. Bind actual words and exact source/input/movie/report hashes. Only then render native 3840×1920 spherical master, inject/verify metadata, recheck clock/media and deliver exact matching file/controls/chapters. A 4K upload master is optional future production, not authorized by this planning trial.
9. Native compatibility stays pending until separately authorized upload to the confirmed owner channel/visibility. If authorized, test that exact file after 360 processing on the ordinary desktop watch page and a real current YouTube phone app: rotation, digits, preserved view/pause, chapter eligibility/selection, timestamp fallback, captions, all paths and compression readability. Record URL/hash/date/device/app. If the phone chapter path fails, repair the instruction/fallback and retest; do not substitute local buttons or claim success from samples. No upload is authorized or performed here.
