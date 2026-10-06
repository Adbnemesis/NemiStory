# Storytime promotional thumbnails in the animation style

## Current user direction

The user requests original promotional illustrations for every ADB and Nemi episode, with the recognizable storytime character design and drawing language. They explicitly rejected merely arranging existing episode assets or recreating a literal scene from the movie. Develop an arresting visual idea of your own: exaggerated interaction, comic scale, emotional metaphor, visual contradiction or a striking newly staged situation. The thumbnail need not depict a shot or event that appears in the animation. Its title and illustration should still represent the episode's underlying subject and emotional promise.

**No fixed channel background, palette, font, layout or mandatory aura.** The former gold-ADB/blue-Nemi collection is superseded as a design rule. Choose the background, doodles, typography, props, expression, crop and headline together for the promotional idea. Reference thumbnails can inform composition, character interaction and visual wit; do not copy their finished illustrations or import their anime rendering into our art.

Create **two distinct promotional concepts per episode**, each paired with a complementary proposed video title. They should differ in visual idea or composition, not just colour or wording. Use **one eye-catching headline per image**, optionally split across lines. Omit small captions, labels, branding and secondary copy. Punctuation can support that headline. White silhouette outlines/soft aura and completed author-profile doodles remain available when they improve separation or clarify the event; omit them when unnecessary. An episode-specific palette can reuse a successful colour, but it is a deliberate story choice, never an inherited channel default.

No AI image generation or restyling. Keep the canonical main-character rigs, face construction and supported acting controls. Existing episode props/scenery are available references and resources, not the only allowed artwork. Author new supporting characters, props, backgrounds and visual metaphors in editable Godot/vector art through the shared illustration route, matching the episode's fill, ink and shape language. Use the narrator's pen profile for authored marks. Ordinary crop, typography, resizing and packaging tools can finish native captures. Do not replace a main character with an independently drawn lookalike or copy an old generated character/face. Record reused and newly authored artwork separately in the provenance.

## Performance review and next plan

On 6 October 2026 the user reported about 1–2% CTR for the delivered collection and supplied three reference sets. The first proposed six pilots leaned on literal episode scenes and existing asset rearrangement; the user rejected that creative direction. Treat those pilots and the literal-scene portions of the [earlier thumbnail and title plan](THUMBNAIL_TITLE_PLAN_2026-10-06.md) as exploratory drafts, not approved replacements or the current production brief. The active request is original promotional illustration in the same animation style, with complementary titles. Preserve earlier deliveries and draft evidence while developing that direction. Do not mark new renders complete until they exist and have been inspected. Readability QA is not audience-performance validation; the user's 20% target is not a verified result or guaranteed minimum.

The user explicitly authorized redesigning all existing numbered episodes: ADB EP00–EP01 and Nemi EP00–EP09. This is thumbnail-only authorization. Preserve films, scripts, rigs, hand/pose/expression libraries, audio and timing. Current recommended delivery paths are indexed in [the collection](THUMBNAIL_COLLECTION.md); historical root thumbnails and previous delivered versions remain preserved.

## Read the story, then invent the promotional idea

For thumbnail work, load the narrator’s storytime skill and this guide. Read the episode script/direction, inspect actual movie stills and read the existing rig/prop APIs required by the composition. Save episode-specific evidence and application notes before composing in the current promotional revision’s `BRIEF.md` under `thumbnail/promotional/`; legacy single-image work uses `thumbnail/BRIEF_AND_REVIEW.md`. Do not create a new episode or fabricate animation-preflight receipts for a static image. Full episode preparation, validation and movie proofs still apply when animation work is separately requested.

Use the script to understand the subject, emotional stakes and payoff; use actual movie frames to match the character and drawing style. This reading is context for invention, not a requirement to extract the movie's props and arrange them into a poster. Start from a compelling audience question, then explore original visual concepts that express it. A crush might become overwhelming oversized hearts or comic personal-space tension; animation work might become a mountain of unruly drawings. These are promotional metaphors, not claims that those exact scenes were filmed. Save that distinction in the brief. Preserve a reveal when it is the video's payoff.

Make the illustration itself compelling before adding text. Direct an expressive relationship among characters, gestures and the unusual visual idea rather than defaulting to a portrait plus detached props. Explore cropping, asymmetry, foreground scale, exaggerated poses through supported controls and value contrast. Newly authored supporting art is welcome when it makes that idea work. The single headline adds tension or a reaction; the title supplies useful context. Do not mechanically reuse a portrait on the same side with generic sparks.

Keep the silhouette, face construction, canonical colour/monochrome mode and prop line language shown in that episode. For a historical episode, use the character variant actually in its film unless the user requests a character update. Nemi’s rounded warm pen and ADB’s compact slate pen come from separate `common/storytime/profiles/`. Use `ProfileAssets.mark(author, ...)` for marks and `LiveDrawing` for authored supporting scenery; completed ink has `progress = 1.0`. Editorial headline type is typesetting, not rig handwriting: select a readable project font, then choose weight, size, colour, spacing and outline for this image. Thin details that disappear at feed size are not essential story information.

Editorial illustrations and metaphors can deliberately exaggerate scale, perspective and situations. Give that exaggeration a clear visual purpose; a giant prop or impossible swirl should read as a coherent comic idea. When a character visibly grips or touches something, keep that contact legible. Background scenery supports the idea and should not run through the headline or face. Lighting, outline/aura and doodles can support emphasis while retaining recognizable face construction, fills and ink.

Distinguish a promotional exaggeration from a new factual claim. Humorous metaphor, symbolic effects and an invented illustrative setting are allowed; do not invent real injuries, fatalities, crimes or measured success. Nemi's human-driven airport taxi was rear-ended; her Waymo ride was safe. A metaphorical trip composition can include San Francisco imagery, but a literal crash illustration must not relocate the collision onto the Golden Gate Bridge. Neeko was rescued and adopted; do not imply death. ADB's crush story ends in a prank; avoid promising a successful romance or spoiling that reveal unnecessarily. Titles and factual words such as grades, counts or times should be supported by the story.

Click appeal is an artistic objective. Do not report a CTR increase or call a version a proven winner without audience data. When the user requests a real test, use their actual analytics and an authorized platform workflow. YouTube’s native tests evaluate watch time and can produce inconclusive results; optimise a truthful promise that earns viewing, not clicks alone. [YouTube A/B testing guidance](https://support.google.com/youtube/answer/16391400?hl=en-GB).

## Compose, inspect and deliver

Save editable source, native master, upload copy and QA under `<author>/episodes/epNN_slug/thumbnail/`; keep the episode’s `renders/` for its final movie. Before replacing a delivery, preserve its exact image, layout, renderer and review under `thumbnail/revisions/`. Do not retroactively clean unrelated media.

Instantiate the existing rig in a separate static Godot composition, let `_ready` run, disable autonomous processing and apply supported controls once. Choose an existing thought-specific pose/expression; direct arms/hands only as needed for the image. Read the controls before using them. Render with a real graphics renderer. Headless dummy output is not visual evidence.

A native 3840×2160 vector capture supplies the master; deliver 1920×1080 JPG/PNG plus 320×180 and 160×90 feed checks. Downsample rather than upscale. Inspect each full delivery and the complete reduced set: immediate appeal of the visual idea, title/image relationship, recognizability beside actual animation art, eye/mouth readability, supporting portrait crops, fingers/arm overlap, action/prop direction, contact, type boundaries, value contrast, clutter and the lower-right duration overlay area. The image need not resemble a movie screenshot. Revise any ambiguity, collision or cropped key face. An image existing on disk does not establish quality. Record what was actually viewed; dimension checks alone do not establish a visually reviewed 4K master.

Save dimensions, file sizes, hashes, exact sources, render command/log, the promotional idea, its relationship to the episode and performed/unperformed checks. Use honest provenance: **Godot render with canonical production rigs and reused/newly authored supporting art; AI-assisted direction/code** where appropriate. Do not label AI-assisted vector direction as entirely human handmade. No generative image service belongs to this workflow.

## Current two-concept collection and tools

The current [all-episode collection](PROMOTIONAL_THUMBNAIL_COLLECTION.md) indexes two independently directed promotional images and title pairs for every numbered ADB/Nemi episode. `tools/storytime/thumbnail_promotional_collection.json` is the active manifest. The first six promotional directions and earlier literal/uniform deliveries remain preserved as historical work.

Editable examples live in each episode’s `thumbnail/promotional/2026-10-06/`: `BRIEF.md`, source/style evidence, newly authored artwork, and A/B variant layouts/exports/QA. `tools/storytime/THUMBNAIL_PROMOTIONAL_LAYOUT.md` documents the static format and a saved complete example. Reuse the mechanisms, not an episode’s visual concept. The [ordered illustration helper](../../tools/storytime/ThumbnailIllustration.gd) prepares held components through the existing LiveDrawing route so foreground fills correctly cover earlier ink.

From the repository root:

```sh
.venv/bin/python tools/storytime/validate_thumbnail_pilots.py
"$GODOT_BIN" --path . --log-file /tmp/promotional.log --script tools/storytime/ThumbnailPromotional.gd
.venv/bin/python tools/storytime/package_promotional_thumbnails.py
```

For one image, validator `--layout <project-relative-layout>` and renderer `-- --layout=res://<layout>` are supported. Alternate collections use validator/package `--manifest <path>` and renderer `-- --manifest=res://<manifest>`; packaging also accepts `--output <project-relative-folder>`. Preserve prior revisions before replacement. Check render errors in addition to completion markers; source/geometry checks and package hashes do not substitute for visual review.

The package includes named upload JPGs, text-free artwork, paired titles, a filterable gallery, author overviews and paged light/dark feed reviews. Local 4K masters remain beside source. Inspect each full delivery and every reduced page; record honestly if a native master or gallery interaction was not inspected. Do not upload or report a test result unless that action actually occurred within the user’s authorization.
