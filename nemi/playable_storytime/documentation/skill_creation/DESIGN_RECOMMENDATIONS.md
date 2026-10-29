# Reusable playable YouTube skill design

Read-only design audit, 2026-10-27. This file is a recommendation for the skill author, not an engine implementation or a new production approval. No episode, engine, rig, voice or installed skill was changed.

## The useful product boundary

Create two discoverable entry points: `adb-playable-youtube` and `nemi-playable-youtube`. Each should activate for creating or materially improving a playable YouTube story/video for its author, and should exclude ordinary linear storytime, ink Shorts, thumbnails and generic website games. If the requested work is a crossover, load both author identities and make cast ownership explicit.

Default to the user's accepted product: one self-contained upload with 360-degree looking and native number-key choices, plus matching numbered chapters where the phone app/channel supports them. This is a default for this workflow, not permission to reject a user's explicitly different format. Do not silently replace it with a companion website or linked-video tree. Reusable means new stories and physical rules, not another eraser/sketchbook reskin.

The main skill needs the non-negotiable conceptual and production boundaries. Longer design rubrics, clock arithmetic, verified repo commands and platform QA belong in linked references. Do not copy the entire storytime manuals into either entry point or establish a stale second preflight document list.

## Suggested main SKILL structure

1. **Promise and author:** create a fun, legible playable story with the selected author's canonical identity; an unfamiliar viewer should know why they are here, their immediate objective, what to inspect, which control to use, and what changed after a choice.
2. **Start from the brief:** retain stated runtime/platform/interaction/cast and existing approvals; choose a fresh central predicament and a coherent ending before adding puzzles. On resume inspect current files and reading receipts, not an old preview title.
3. **Story and interaction contract:** save an origin/promise/want/choice/consequence/payoff brief plus a small route/beat table. Read the design reference before scripting.
4. **Playable platform constraint:** the movie is a deterministic authored timeline. Drag/swipe rotates the view; a native digit selects a percentage of the whole file. It cannot detect looking, collect inventory, grade an answer, save state, execute JS, pause itself for a choice or make an in-picture prop clickable.
5. **Production route:** use the author's actual canonical skill/current preflight and supported version-2 controls. Read the repo capability reference before touching the existing Nemi-specific adapter. Preserve existing productions and identities; new kinds/mechanics require honest schema/validator/example/testing support.
6. **Quality gates:** first mechanism proof, integrated 30–60s excerpt when broad changes warrant it, complete current1080p review; actually inspect normal projected views and playback/listening when available. Distinguish data checks, decoded image inspection, perceptual playback and actual-platform playthrough. Keep missing evidence explicit.
7. **Deliver and approve:** deliver the complete matching local review first. Bind actual user acceptance to exact full1080p scene/input/movie hashes before4K. A future content/timing/mix change revokes approval. Render natively rather than upscale, preserve exact runtime, tag spherical metadata and verify the final encoded map. Give exact local output links and which movie is the upload master. Publishing/uploading requires its own authorization.

## Reference: story, fun and first-time clarity

### One origin story, not unrelated rounds

Write the initial predicament in one sentence, then the goal in one sentence. Every obstacle must be caused by that same predicament and every successful choice must move toward the same goal. The ending visibly resolves the original problem and pays off an earlier detail; do not swap to an unrelated threat or destination halfway through.

Use one stable material/world rule that the audience can observe, predict and exploit. Build an evidence→choice→physical consequence→new useful information→next problem chain. Establish what the character knows and wants before explaining a button. A surprising solution should feel obvious in hindsight from already visible evidence. Do not hide the only clue below the viewport or invent a new rule after the answer.

Save a route table with: beat, current goal, visible evidence, available actions, exact number, landing, physical consequence, recovery, persistent landmark, next narrative question. Mark the intended first-time path, passive path and every wrong/retry path. Not every digit slot needs to be a choice. Avoid unnecessary Continue keys after successful actions.

Wrong choices should give a short characterful physical failure or discovery, retain the current goal and name an easy recovery number. The audience should learn something useful instead of being punished with a long replay or an opaque failure card. No arbitrary instant death, hidden timing windows or fake reaction score unless the brief genuinely supports and implements them.

### Explain controls by showing an immediate payoff

Before the first decision, show and speak the minimal controls: desktop click/focus and drag to look, then press the displayed number; phone swipe to look, then select the matching numbered chapter when available; resume Play/K if paused. Demonstrate one harmless look/choice relationship, not a long tutorial. WASD is optional view rotation where supported, never implied character walking.

Keep the immediate objective and short numbered verbs readable. Put the label near its object at a readable horizon; a label must not substitute for the prop. Only advertise controls actually available in the final destination player. Captions are accessibility, not a custom button/input API. Do not make manual timestamp hunting the main game interaction; description timestamps are a recovery path.

Use a blind first-time comprehension pass: can a reviewer describe why this predicament exists, the current goal, what the visible clue implies, exactly how to look/select/resume, why the result happened, and what to try next without the creator explaining? If any answer needs extra conversation, revise the game before polish. Do not claim a human blind test when only an agent simulation occurred.

### Pacing is a coordinated edit

Start the story with an incident and a concrete request for help; teach controls while giving the viewer something to discover. Use connected conversational thoughts, not clipped robotic instruction sentences. Keep character humor, reaction and a purposeful visual consequence in each decision; a choice count or effects quota does not create fun.

Author a gap budget. Flag long non-emotional gaps and tails (roughly1.5–2s is a useful review trigger, not a universal maximum), then shorten dead air or use it for a visible action or actual observation. Never pad empty waits merely to fill an equal digit block. Preserve earned surprise, breaths, dry comedy, emotional processing and a short ending/replay hold. Silence detection and WPM guide review but do not prove natural delivery.

If the faster voice leaves unused slot tails, retime the whole movie/map coherently. Do not speed every phrase to fit an already chosen runtime or reuse an old master already processed faster. Reuse hashed original sources, use author-approved pitch-preserving phrase tempos and bounded ordinary-gap cuts, then independently realign the final audio and rebuild captions, mouths, acting, camera, drawing and sound cues.

## Reference: native clock and orientation

For final encoded duration D, digit k lands at D*k/10, k=0..9. Author required choice destinations at these exact fractions. Recompute the entire map and all absolute tracks whenever D changes, then verify against decoded final duration and frames, not a planning constant. Ten percentage positions do not imply ten puzzles or ten isolated rooms. Choose story length and block use to serve pacing; 220seconds/22second blocks are this episode's result, not a reusable requirement.

Use one seconds-based clock for final voice/words/mouths/captions/acting/props/camera/events/SFX and one final frame rate. Lock runtime after the complete cut; append no bumper, intro, logo or padding later without rebuilding the map. Chapters/printed numbers/spoken choices/local preview/metadata must agree.

Native seeking preserves viewpoint and pause. Do not rely on the preview's optional auto-turn or a director camera to make the uploaded movie understandable. Keep result action in the same inspected world sector. For each choice destination, provide a concise authored turn direction that works from each cardinal view and keep the physical consequence findable. Test the action from front/back/left/right and while paused/playing. The optional local follow helper remains explicitly a local convenience and yields to manual looking.

At ordinary successful continuations, preserve actor sector, supported endpoint, direction, object/material state and a recognizable landmark. No surprise camera reset, unexplained teleport or new-round card. A motivated material match cut may change framing while retaining geography; a root slide is not a walk, and rotating the viewer is not character movement. Pickup/release/boarding/contact require supported authored choreography or an honest cut.

## Reference: art, sound and QA

Recognizable physical props must exist before the decision and remain readable at the normal horizon/FOV, not only in a flat panorama or a directed insert. Inspect actual encoded rectilinear views at the intended normal FOV, a narrower/framed view when appropriate and small presentation size. Inspect floor-adjacent props, boundaries and all states. A bridge needs recognizable deck/rails/support/missing span; paper needs a broad face/edge/crease/contact. These are examples of visual evidence, not mandatory props for every story.

More props should clarify scale, location, causal clues or character business. Use purposeful progression, selective contrast and one audience focus; do not accumulate decorative clutter or permanent VFX. Keep cream paper, readable author ink, canonical colors and selective washes according to current storytime direction. Completed ink stays stable. Use authored finite VFX on named events and recorded SFX that audibly reinforce visible changes. Keep faces, hands, feet, labels and important support visible; check both arms/wrists/grips and scale against furniture/vehicles.

Validate source/schema/audio/paths/continuity, render and inspect a short mechanism and integrated excerpt, then the complete1080p cut and full sphere. Decode through the end; check exact frames/runtime, metadata, black gaps, captions, encoded audio/headroom and source/input hashes. Save all ten encoded percentage landings, cardinal entry/return views, selected clue/material views and fixed-yaw samples before/after successful joins. An export on disk is not artistic review. A frame sheet is not continuous playback; ASR is not pronunciation/phoneme proof; a VM is not browser interaction; metadata is not YouTube processing.

When authorized and an owner session exists, test the exact tagged file as unlisted in the native watch player, then check360recognition/rotation, all digits and retries, pause/view preservation, passive/direct/failure paths, compression readability and actual voice/SFX. Test the actual phone app/chapter access separately. No claim of guaranteed YouTube compatibility, watch-time qualification or phone support from the local preview. If unavailable, deliver concrete files/checklist and label the unperformed gate honestly rather than bypassing access controls.

## Author-specific decisions

**Nemi:** load the Nemi storytime skill/current preflight. Preserve canonical Sohee identity, warm observational self-awareness, expressive but thought-specific acting and rounded warm pen. Faster delivery still contains worry, embarrassment, relief and breaths. Current approved pace tools allow phrase-specific1.08–1.12 where needed and exceptional≤1.15 after listening; do not hardcode this as every line's tempo. Use the existing isolated Nemi game engine only after inspecting the current template, not by executing episode002's story-specific authoring/build script for a new story.

**ADB:** load ADB storytime/current preflight. Preserve Aiden identity, dry conversational flow, restrained physical acting and compact/economical author ink. Never change Nemi's label to ADB or use Sohee as a shortcut. The same design/clock/QA principles apply, but current engine support must be extended explicitly before it can render an ADB playable episode.

## Verified current repo limitations

`nemi/playable_storytime/tools/new_episode.py` copies a content-only template and assigns a NEMI basename. `tools/preflight.py` always initializes author list[nemi]. `tools/prepare_episode.py` hardcodes narrator/speaker/actors/script/caption/VFX/illustration ownership to nemi. `tools/voice.py` imports the canonical NemiVoiceConfig, expects Sohee/nemi and checks word actors as nemi. `tools/validate_episode.py` requires illustrated author=nemi and transport actor=nemi. `tools/bootstrap.py` includes ADB dependency assets, but availability of assets does not implement ADB narrator/voice/preflight/rendering contracts. The spherical compositor and generic percentage QA concepts are reusable; the complete wrapper is not author-neutral.

The ADB skill must authorize an implementation route, not pretend a ready CLI exists: create a separate author-aware adapter or carefully extend the isolated adapter with explicit author selection; retain byte-identical canonical rigs/voices, require author-specific reading/voice/acting/art and update schema/example/validator/tests/renderer together. Prove ADB full-body acting, mouth/voice, prop contact, 360world, labels, direct/passive/retry routes and recorded sound in a mechanism/integrated proof before complete production. Preserve the accepted Nemi game. Do not weaken Nemi guards globally, bypass validators, edit old episodes or claim ADB gameplay exports are already supported.

`tools/new_episode.py` is a useful Nemi scaffold, not a creative script generator. `episodes/episode_002/tools/build_full_game.py` includes specific decision indices, actor sectors, eraser travel and folded-paper arrival rules; it is not a generic compiler for arbitrary games. `tools/produce.py --render-only` is needed for that specialized authored builder because generic preparation can overwrite the specialized spatial placements. New games must adapt their own compiler/data rather than inherit those decisions accidentally.

## Behavioral checks worth running on the completed skills

Give an independent agent a new premise (for example an ADB museum exhibit that wakes up, or Nemi trying to stop a moving train sketch) and ask for a playable plan with the skill. Check that it makes one coherent origin/problem/goal, causal evidence, meaningful controls, passive/direct/retry routes and a flexible runtime; does not clone the eraser story, promise clickable MP4 objects, add a companion page by default, pad empty ten-block waits, swap author voices or claim the current Nemi-only CLI supports ADB. A second scenario should revise duration by12seconds and require it to recompute the entire percentage map and dependent tracks. Evaluation can remain a small isolated written plan; no live upload, expensive TTS or full movie is needed to validate these decisions.
