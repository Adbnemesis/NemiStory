# Storytime animation work

For both ADB and Nemi episode animation, use `docs/animation/STORYTIME_EPISODE_COLOUR_THEME.md`: the actual Nemi EP06 "How I Animate" movie is the current colour-treatment reference. Keep cream paper, dark readable ink, soft washes, canonical character colours and selective prop/doodle emphasis. Rich scene-specific art, live drawings, acting, camera and sound do not require broadly coloured walls/roads. Thumbnail promotional palettes remain independent.

The user approved Nemi EP11 R10 as the **upper-middle balance** for episode direction. Keep simple, recognizable backgrounds and sustained thought-specific poses, expressions, props, held/live doodles, camera and audible event-linked SFX. Develop these sequentially around one audience focus; clear or rest secondary accents when their job ends. A request to reduce excess calls for less simultaneous density or shorter accents while retaining visual storytelling. A request for more calls for purposeful progression, not permanent accumulation. Quiet emotional moments remain deliberate parts of the performance. Apply this balance through each author's own acting/ink identity; EP11 cue counts are descriptive, not quotas or a reusable layout.

Deliver the complete current 1080p cut and wait for the user's explicit satisfaction before any 4K episode/movie proof. Technical checks, short proofs and agent approval do not qualify; material changes revoke approval. Preserve rejected versions while revising and enforce the user's runtime cap. The shared renderer checks the exact full-preview approval receipt and source/input hashes.

## Thumbnails with image generation

For both Nemi and ADB thumbnails, load the relevant storytime skill and `docs/animation/STORYTIME_THUMBNAILS.md`. Use the built-in image-generation tool by default. The user approved Nemi EP10’s generated **Don't Tell Anyone...** thumbnail and explicitly retired Godot thumbnail creation for future work. The old Godot static-layout/compositor and no-image-generation thumbnail instructions are historical. Episode animation and ink Shorts still use their own Godot workflows.

Inspect `references/thumbnail_ref/thumbnail_set_raora.png`, the approved generated example at `nemi/episodes/ep10_my_teacher_used_to_stalk_me/thumbnail/thumbnail.png`, and actual target-author episode art. Match broad heavy white sans lettering with thick BLACK/RED/BLACK outlines, bright white or pale checker backgrounds, expressive close faces, clear cutout edges and story-specific props/doodles. Preserve each author’s recognizable character design and ink/fill language; ADB identity comes from ADB references, Nemi identity from Nemi references. Use one headline without smaller captions/labels and a truthful complementary title. Invent an original promotional idea; no fixed gold-ADB/blue-Nemi palette or copied anime character.

For a new episode’s thumbnail pair, create two distinct generated concepts unless the user requests one image; a user-selected image is the sole current delivery. Save the chosen native PNG as `thumbnail/thumbnail.png` and upload JPG as `thumbnail/thumbnail.jpg`, with prompt, reference/provenance, dimensions/hashes and full/mobile review under that episode’s `thumbnail/`. Generated raster art is not an exact rig export or native 4K after upscaling. Preserve episode movies, voice and animation sources. Thumbnail-only work follows this image route; full episode preflight/proofs apply to separately requested animation. Preserve alternatives unless the user explicitly requests their deletion; verify the selected image before episode-scoped cleanup. EP10’s rejected thumbnails were explicitly authorized for removal.

## Automatic episode-start routing (Codex and Antigravity)

Before creating, scripting, continuing or animating a **new storytime episode**, load `.agents/skills/nemi-storytime/SKILL.md` for Nemi or `.agents/skills/adb-storytime/SKILL.md` for ADB; load both for a crossover. Apply this to natural-language requests even when no skill is named. Complete the relevant current reading using `tools/storytime/preflight.py` and record episode-specific application notes **before authoring**. On resume, check the record and reread stale documents or notes missing from current context. See `docs/animation/EPISODE_START.md`.

Do not dump all manuals into one truncated output, fabricate read notes, bypass the validator/renderer, or add new specs to the historical exemption list. This route is for episode production, not unrelated repository questions, tool maintenance or documentation-only changes. Existing-episode edits still require a separate explicit request.

For new ADB/Nemi animation work, first read `docs/animation/STORYTIME_REFINEMENT_WORKFLOW.md`, then `docs/animation/STORYTIME_DIRECTION_WORKFLOW.md`, then `docs/animation/CHARACTER_DRAWING_PRODUCTION_KIT.md`, then the relevant character acting guide linked there. Start from the saved JSON example and use the validator and renderer. Do not invent API names or build another private doodle player.

- Preserve existing character rigs, character definitions, pose libraries, expression libraries, and hand/lipsync systems. Direct their existing controls from external production code.
- Do not edit existing episodes or overwrite episode renders for this improvement project. Create a separate new scene/spec and render under `renders/`.
- Do not live-draw every scene. Choose held art, prop contact, a scene/environment cut, live revision, or stillness based on the thought. Use version-2 specs for full scenes and version-1 only for the original comparison.
- Every illustration must select `author: nemi` or `author: adb`. Shared playback does not mean shared handwriting or mark geometry.
- Completed ink stays still. Never use per-frame randomness, sliding masks, opacity-only word reveals, or constant bobbing as a substitute for authored drawing/acting.
- Choose a performance recipe by the thought being expressed. Eyes lead, body/head follow, gesture settles, then hold. Do not repeatedly trigger speaking/blink tweens every frame.
- Use existing supported hand shapes, finite VFX lifetimes, and grounded standing cues. Walking/contact choreography needs an authored sequence; never fake it with floating root motion.
- Link simultaneous drawing/VFX/SFX cues to named events. The validator must pass before export; do not bypass missing assets or unknown fields.
- Preserve the exact approved voice identity/settings. Pacing only: use approved source recordings with hashes and pitch-preserving tempo, normally 1.00–1.12 and at most 1.15 for the new recording preparer. Explicitly review Nemi's slow explanatory phrases and prolonged sentence gaps: try 1.08–1.12 for passages that drag and shorten selected non-emotional gaps through authored source bounds. Preserve emotional pauses, breaths and dry holds; never blanket-trim silence. Never change speaker/model/identity prompt/pitch/formants/EQ or reuse stale word times after audio changes. Rebuild dependent mouth, caption, acting, camera and sound timing against the final audio. ADB's conversational pacing is a flow reference, not a substitute voice for Nemi.
- Save a direction brief (promise/want/choice/consequence/payoff) and thought beats with one audience focus each. Use readable framing and a meaningful ending, not a fixed cut rate or effects quota.
- Pickup/release needs authored hand paths and a continuous grip/resting contact. Stepped acting is optional; completed ink remains still.
- Voice timing, mouth intervals, captions, acting, and drawings use seconds on one scene clock. Audio does not automatically produce phonemes. Author and check mouth intervals against the actual recording.
- Validate the spec, run relevant engine checks, render a fresh ten-second proof, inspect stills AND playback, and record what was verified. A render existing on disk is not evidence that it looks good.
- Existing episode adapters from the earlier shared-ink pass remain historical work; do not migrate more episodes or attempt to reconstruct missing originals without a separate user request.

The refinement and version-2 direction workflows are the authoritative executable workflow for new storytime scenes. Older style documents remain artistic context. If extending a mark, letter, recipe, or field, update the profile/schema documentation and example in the same change.

The user authorized pushing current and previously unpushed project source to GitHub, excluding large files. Preserve local generated media; use normal pushes, never force-push. Review staged file sizes and secrets before pushing.


## Integrated review after the short proof

A ten-second proof isolates a mechanism; it does not verify the whole animation system. For a broader change, also render a 30–60 second story with enough time to inspect full-body acting, prop contact, expressions, environments, held art, both authors’ live ink, narration, captions, selective VFX/SFX and an ending. Use `common/storytime/examples/story_review_48s/scene.json` and its review guide. Keep feet and hands visible in review shots; do not default to close framing throughout.

ADB authored hand paths now preserve 58/55 local-unit arm lengths. Unspecified wrist angles follow the forearm. Existing rig and hand drawings are unchanged. Optional actor `hand_path_window: [start,end]` limits path ownership to that interval; elsewhere the performance recipe controls the arms. Validate and inspect both boundaries. This is not an automatic anatomy or walking system.

Real episodes belong in `<author>/episodes/epNN_<story_slug>/`; examples are explicit technical/art studies only. Save script/spec/preflight/timing/tools/review together and generated media under `renders/`. Check character size against furniture, doors and vehicles; labels/live marks cannot stand in for a story location.

Current approved masters live in each episode’s `renders/` folder with revision/resolution names; the render index belongs at `review/RENDERS.md`. Preserve intermediate/older movies until the approved final 4K export passes checks; then, per the user’s retention preference, keep only the final 4K movie and remove superseded movies and unnecessary generated stills. After completion, the episode `renders/` folder must contain ONLY the final 4K video—no logs, JSON, index, stills or other files. Move capture logs and audio reports to `review/render_records/`; keep the index and QA documentation under `review/`. Retain voice, script, assets and source elsewhere in the episode; record cleanup under `review/`. This preference does not authorize retroactive cleanup of unrelated episodes. Read mandatory `COMMON_CAMERA_STAGING.md`, save exact-word camera intentions, and inspect portrait as well as wide/contact framing.

Sound direction is mandatory for both characters: read `docs/animation/COMMON_SFX_SYSTEM.md`, save event-linked cue choices and verify actual exported audibility. Narration plus a few inaudible effects is not a finished sound pass. User-requested superseded-render cleanup happens only after replacement media passes checks; retain voice, script, assets and QA records.

SFX sourcing: use the exact existing root MP3 clips indexed by `common/audio/sfx/root_sfx_inventory.json` plus existing library recordings in the category folders. Do not generate/synthesize SFX or use the older procedural vault placeholders as substitutes. Root vocal meme clips are commentary accents, not new character dialogue. Keep original clip hashes and record honest provenance.


## Godot ink-edit Shorts routing

For music-led ink edit Shorts/reels, read `.agents/skills/adb-ink-shorts/SKILL.md`, `.agents/skills/nemi-ink-shorts/SKILL.md` or `.agents/skills/duo-ink-shorts/SKILL.md` according to the cast, plus `shorts/AGENTS.md`. Use the strict version3 Godot workflow in `shorts/godot/V3_WORKFLOW.md` and schema. This is a separate12–25s music-edit format, with no static hold longer than1.5s and authored visible gestures, doodles and finite VFX. It does not modify storytime episodes or replace the storytime preparation route above. Preserve original episodes/rigs/settings. No image generation or alternate visual renderer. Validate, inspect real Godot art, export, verify decoded music/SFX and pacing, then watch the whole clip before marking review complete.

Current ink Shorts folder layout is `shorts/<adb|nemi|duo>/<short-slug>/`: source and direction at the Short root, exported videos in `render/`, evidence/stills/logs in `review/`, optional unique assets in `assets/`. Start with the cast skill helper `new <short-slug>`; do not place new productions in shared `shorts/godot/` or gallery `shorts/review/`.
