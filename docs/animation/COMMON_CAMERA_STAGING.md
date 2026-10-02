# Thought-driven storytime camera

Current shared camera direction for Nemi and ADB. Read after the refinement/direction/pen kit and character acting guide. This supersedes old fixed zoom tables. A camera changes what the audience attends to; it must not turn a person into a giant beside a chair or car. Keep actor scale consistent with the set and reframe the whole world.

## Choose the image before the movement

Save a camera plan beside the episode spec: scene seconds, exact spoken word or pause, audience focus, framing, reason, and return/hold. Repeated wide narration can hide face acting; continuous zooming can distract. Use a face/shoulders portrait for a personal thought, an establishing wide for geography, an object insert for evidence, and a quiet reaction for the consequence. A closeup need not show feet; a contact/scale review does.

| Thought | Camera choice | Finish |
|---|---|---|
| Talk directly to the viewer | Medium portrait, gaze to viewer | Hold while the thought lands |
| Reveal a specific place | Wide location or pull back toward landmark | Keep its shape readable |
| Explain a mechanism | Reframe toward the actual object | Include the necessary interacting parts |
| Realize/confess something | Brief cut or 0.1–0.2 s punch toward face | Hold; no continuous creep |
| Experience an accident | Wide enough to establish both vehicles/contact | Reaction closeup only after contact |
| Feel vulnerable | Restrained face/shoulder reframe | Quiet eyes/brow; no compulsory joke effect |
| Deliver a dry payoff | Deliberate portrait/cut after the visual callback | Hold through the last meaningful pause |

Nemi can use a sharper personal reaction and asymmetric framing. ADB favors restrained reframes and a longer dry hold. Shared controls do not require identical timing or compositions. There is no required number of moves per minute.

## Exact supported fields and geometry

Use existing version-2 `shot.camera = {center:[x,y], zoom:number, path?:[...]}`. Each path point is `{at,center:[x,y],zoom}` in **absolute scene seconds**, inside its shot. Zoom is 0.5–3. The shared path uses smoothstep interpolation and holds its endpoint. To wait and then move, repeat the initial framing at the movement start; without that repeated key, movement begins at the preceding key. For an actual snap, split the shot at the measured spoken cue, with fixed camera values on each side. Do not invent a tween/event field inside `camera`.

All artwork, actors, scenery, props and actor-attached VFX reframe together. Captions stay in screen space. World canvas is 1920×1080 regardless of export resolution. Screen position is `[960,540] + (world_position-center)*zoom`. A zoom number does not define a universal shot size: actor scale, head location, placement and the selected center all matter. Center on the actual head/gesture, not automatically on the character root or canvas midpoint.

Check frame edges at entry, middle and endpoint. Keep essential eyes/chin/hand or contacted object visible, leave readable headroom, and keep captions away from the face. Cropping the lower body is deliberate in a portrait. Verify a wide or full body when reviewing standing contacts and physical scale. A larger image because the camera moved closer is different from a larger actor within the same set.

Camera timing follows final recorded words and intentional pauses. Put important camera cues in a saved sidecar plan and reference the named scene event; copy its exact timestamp into the supported path or split shot. The current schema does not accept `event` on camera points. The validator checks path bounds but cannot prove a meaningful composition or audience attention.

## Hand-drawn reaction marks

Study the actual local Pegi references using [the current reference review](PEGI_CAMERA_STUDY_2026_10_02.md). Sweat marks are often a few open asymmetric curves near a worried head; tears relate to the lower lid and expression. Their shape and placement serve the feeling. Do not add a stock droplet to every uncertainty, a twin waterfall to an ordinary sad line, or continuous moving ink to make a hold look handmade. Prefer authored stable contours, distinct Nemi/ADB pen habits, finite lifetimes and face-relative placement. Preserve the approved rigs; stage external marks only when they add to the existing expression.

## Delivery and verification

Real episodes use `<author>/episodes/epNN_slug/`. Save script/spec/preflight/timing/tools/review there, and current masters in that episode's **`renders/`** folder. Keep revision/resolution in filenames and preserve originals. Workspace `renders/` is for studies, scratch exports and source media when already declared; an approved review must also be available in the episode render folder. Write a small `renders/RENDERS.md` naming the current master so an old filename cannot be mistaken for the current cut. Keep large generated video/audio out of Git.

Render a fresh ten-second camera proof with the shared validator/renderer, inspect stills and actual playback, then inspect the full episode. A moved camera can expose mouth/hand problems hidden in a wide shot; review those rather than claiming automatic phoneme accuracy. Record what was checked and what remains pending. Native 4K renders rerasterize vector art at 3840×2160; resizing a 1080p MP4 is an upscale and must be labelled accordingly.
