# Storytime thumbnails from production art

## Current user direction

The user requests episode-specific art direction for every ADB and Nemi thumbnail. **No fixed channel background, palette, font, layout or mandatory aura.** The former gold-ADB/blue-Nemi collection is superseded as a design rule. Choose the background, location, doodles, typography, props, expression, crop and headline together for the actual story. Keep the recognizable storytime animation art.

Use **one eye-catching headline only**, optionally split across lines. Omit small captions, labels, branding and secondary copy. Punctuation can support that headline. White silhouette outlines/soft aura and completed author-profile doodles remain available when they improve separation or clarify the event; omit them when unnecessary. An episode-specific palette can reuse a successful colour, but it is a deliberate story choice, never an inherited channel default.

No AI image generation or restyling. Build in Godot from the canonical rigs, supported acting controls, existing episode props and scenery. New supporting scenery may be explicitly authored in vector/Godot code through the shared illustration route, in the same fill/ink language. Ordinary crop, typography, resizing and packaging tools can finish native captures. Do not replace a character with an independently drawn lookalike or copy an old generated character/face. Record honest provenance for reused assets/background pixels.

## Performance review and next plan

On 6 October 2026 the user reported about 1–2% CTR for the delivered collection and supplied three reference sets. The next proposed direction is a staged story moment, with a complementary title and one short thumbnail phrase, instead of a large headline/portrait with smaller illustrative props. See the [thumbnail and title plan](THUMBNAIL_TITLE_PLAN_2026-10-06.md) for the reference audit, twelve candidate pairs and a three-episode pilot. This is a plan; current images remain the delivered baseline until replacements are separately produced. Readability QA is not audience-performance validation. The user's 20% target is not a verified result or guaranteed minimum.

The user explicitly authorized redesigning all existing numbered episodes: ADB EP00–EP01 and Nemi EP00–EP09. This is thumbnail-only authorization. Preserve films, scripts, rigs, hand/pose/expression libraries, audio and timing. Current recommended delivery paths are indexed in [the collection](THUMBNAIL_COLLECTION.md); historical root thumbnails and previous delivered versions remain preserved.

## Read and direct the actual story

For thumbnail work, load the narrator’s storytime skill and this guide. Read the episode script/direction, inspect actual movie stills and read the existing rig/prop APIs required by the composition. Save episode-specific evidence and application notes in `thumbnail/BRIEF_AND_REVIEW.md` before composing. Do not create a new episode or fabricate animation-preflight receipts for a static image. Full episode preparation, validation and movie proofs still apply when animation work is separately requested.

Choose one real curiosity gap or tension. The image should make the story object/action identifiable before someone reads the title; the headline should sharpen that promise rather than list everything in the video. Prefer a concrete moment or meaningful number over a vague reaction when the episode supplies one. Preserve a reveal when it is the video’s payoff. Introduction and process videos may need a welcoming identity or clear craft promise instead of drama.

Balance one focal reaction, the meaningful object/event and the single headline. Decide what leads for that episode: the kitten, the impossible grade, a relationship or the collision. Direction may vary between a portrait, a two-character conversation, an enlarged evidence object, a location vignette or a comic prop gag. Do not mechanically reuse a portrait on the same side with generic sparks.

Keep the silhouette, face construction, canonical colour/monochrome mode and prop line language shown in that episode. For a historical episode, use the character variant actually in its film unless the user requests a character update. Nemi’s rounded warm pen and ADB’s compact slate pen come from separate `common/storytime/profiles/`. Use `ProfileAssets.mark(author, ...)` for marks and `LiveDrawing` for authored supporting scenery; completed ink has `progress = 1.0`. Editorial headline type is typesetting, not rig handwriting: select a readable project font, then choose weight, size, colour, spacing and outline for this image. Thin details that disappear at feed size are not essential story information.

Editorial portrait/event collages can use different object scales; make that distinction visible. Literal single-location scenes need believable character-to-object scale/contact. Background scenery supports the foreground promise and should not run through the headline or face. Avoid excessive glow, clutter, sticker arrows and fake lighting on the canonical character.

Headline and image must match the script. Do not invent injury, fire, villains, disasters or success metrics. Nemi’s human-driven airport taxi was rear-ended; her Waymo ride was safe. A bridge in a San Francisco thumbnail may establish her trip, but must not imply the crash happened on it. Neeko was rescued and adopted; do not imply death. ADB’s crush story ends in a prank; avoid promising a successful romance or spoiling that reveal unnecessarily.

Click appeal is an artistic objective. Do not report a CTR increase or call a version a proven winner without audience data. When the user requests a real test, use their actual analytics and an authorized platform workflow. YouTube’s native tests evaluate watch time and can produce inconclusive results; optimise a truthful promise that earns viewing, not clicks alone. [YouTube A/B testing guidance](https://support.google.com/youtube/answer/16391400?hl=en-GB).

## Compose, inspect and deliver

Save editable source, native master, upload copy and QA under `<author>/episodes/epNN_slug/thumbnail/`; keep the episode’s `renders/` for its final movie. Before replacing a delivery, preserve its exact image, layout, renderer and review under `thumbnail/revisions/`. Do not retroactively clean unrelated media.

Instantiate the existing rig in a separate static Godot composition, let `_ready` run, disable autonomous processing and apply supported controls once. Choose an existing thought-specific pose/expression; direct arms/hands only as needed for the image. Read the controls before using them. Render with a real graphics renderer. Headless dummy output is not visual evidence.

A native 3840×2160 vector capture supplies the master; deliver 1920×1080 JPG/PNG plus 320×180 and 160×90 feed checks. Downsample rather than upscale. Inspect each full delivery and the complete reduced set: story clarity, eye/mouth readability, supporting portrait crops, fingers/arm overlap, action/prop direction, contact, type boundaries, value contrast, clutter and the lower-right duration overlay area. Revise any ambiguity, collision or cropped key face. An image existing on disk does not establish quality. Record what was actually viewed; dimension checks alone do not establish a visually reviewed 4K master.

Save dimensions, file sizes, hashes, exact sources, render command/log, the chosen story rationale and performed/unperformed checks. Use honest provenance: **Godot render using existing production rig/art; AI-assisted direction/code** where appropriate. Do not label AI-assisted vector direction as entirely human handmade. No generative image service belongs to this workflow.

## Editable current examples

`tools/storytime/thumbnail_collection.json` lists the twelve layouts. `ThumbnailEpisodeSet.gd` composes independently directed story layouts; `ThumbnailStoryArt.gd` supplies held supporting scenery and headline type through existing Godot/illustration tools. It extends the older static prop/character helper, not an animation stage or private drawing player. Background kinds are examples for these episodes, not mandatory templates for future episodes.

Each episode’s `thumbnail/render_thumbnail.gd` delegates its own layout. From the repository root with the installed Godot executable:

```sh
"$GODOT_BIN" --path . --log-file /tmp/story_thumbnails.log --script tools/storytime/ThumbnailEpisodeSet.gd
```

Render a single current image with its per-episode entry point, or supply `-- --layout=res://<author>/episodes/<episode>/thumbnail/layout.json` to the collection renderer. Layouts record exact headline/font, independent background and placements, existing rig/prop sources, optional aura/marks and story evidence. The previous uniform collection and first standalone taxi/crush sources are preserved under each episode’s revisions; they are historical examples, not current design constraints.

Package the current deliveries without changing their artwork:

```sh
.venv/bin/python tools/storytime/package_thumbnails.py --output renders/thumbnail_story_collection_2026-10-05
```

This checks image dimensions and ZIP hashes/contents and creates named JPGs, a gallery and review sheets. It does not perform or claim visual approval; inspect the exported sheets separately.
