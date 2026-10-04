# Storytime thumbnails from production art

User direction, 2026-10-04: future Nemi and ADB thumbnails must match their storytime animation art. Do not use an AI image generator to make or restyle a thumbnail. Build the composition in Godot from the existing character rig, supported expressions/poses/hands, episode scenery and prop art. Ordinary crop, type, layout and export tools can finish the rendered art. New supporting shapes can be explicitly authored in Godot/vector code in the same illustration language; do not replace the character with an independently drawn lookalike.

This applies to thumbnail requests and the thumbnail deliverable of future episodes. It does not authorize changing old movies or replacing unrelated old thumbnails. The first requested example is `nemi/episodes/ep09_sf_accident/thumbnail/`.

## Route and scope

For a thumbnail-only request, load the narrator's storytime skill and this document. Read the episode script/direction, inspect actual movie stills, and read the relevant existing rig/prop APIs before composing. Save thumbnail-specific application notes and provenance in the episode's `thumbnail/BRIEF_AND_REVIEW.md`. Do not create a new episode or rewrite its animation `scene.json`, audio, timing or preparation record merely to make a static thumbnail. The full episode preflight and ten-second/integrated movie proof apply when animation work is also requested; a static thumbnail is reviewed as an image, not passed off as a validated animation export.

Use `<author>/episodes/epNN_slug/thumbnail/` for editable composition source, native master, upload copy and reduced previews. Keep thumbnail QA/provenance here or under the episode's `review/`. The episode's `renders/` remains reserved for its final 4K movie. Preserve an existing thumbnail under a revision name before replacing it. Do not edit rigs, expression/pose/hand libraries, episode scripts or original renders to satisfy an editorial thumbnail pose.

## Design the click around the story

Choose a real tension or consequence from the script. Start with one readable face, one story object/action and a short hook. Reaction size, purposeful asymmetry, a quiet background and clear value separation can make existing art compelling. Use location scenery when place matters. An editorial portrait plus a separate event vignette can have different scales; make that separation clear. In a single literal scene, preserve believable character-to-object scale.

Keep the actual silhouette, face construction, line language and canonical colour/monochrome mode used in the episode. Nemi's rounded warm plum/rose pen and ADB's compact slate pen come from their separate `common/storytime/profiles/` files. Use `ProfileAssets.mark(author, ...)` for handwritten marks and set completed ink `progress = 1.0`. Do not invent a second private doodle renderer. Bold typeset headline text is editorial typography, not character handwriting; use existing project fonts. Avoid glossy lighting, painterly skin, fake depth, arbitrary grain or a different illustration genre.

Headline and picture must describe the story honestly. Do not add injury, fire, blood, a villain or an outcome absent from the episode. Avoid implying the Waymo caused Nemi's accident: her human-driven airport taxi was rear-ended. Catchiness is an artistic aim; do not claim higher click-through or audience approval without data.

## Build and inspect

1. Save a brief: episode/title, exact story evidence, visual hook, art sources, type/colour choice and what the thumbnail edit may change.
2. Instantiate the existing rig in a separate Godot static composition. Let `_ready` run, disable autonomous processing, then apply supported controls once. Keep eyes, mouth and identifying hair readable. Use the episode's existing prop/scenery helpers. Render a fresh framebuffer with a real graphics renderer; headless dummy rendering is not image evidence.
3. Rerasterize vector artwork at the master resolution. A useful starting point is a native 3840×2160 master and a 1920×1080 JPG/PNG delivery image, with 320×180 and optionally 160×90 feed previews. Downsampling a native vector capture is acceptable; label an upscale honestly.
4. Inspect the full composition and reduced image. Check expression, fingers, arm overlap, crop, story-object contact/orientation, text clipping, contrast, clutter and the bottom-right duration-overlay area. Revise when the face or action becomes ambiguous. A file's existence does not prove visual quality.
5. Save exact output dimensions, file sizes, hashes, source provenance and which images were actually inspected. Record the rendering command and any unperformed checks. Keep a recommended option and an alternate only when the alternate offers a meaningful hook. Final approval/real audience performance remains with the user.

Provenance should say “Godot render using existing production rig/art; AI-assisted direction/code” where appropriate. Do not describe AI-assisted vector composition as entirely human handmade, or assert an unverified history for existing assets. No generative image service is part of this thumbnail workflow.

## Reproducible first example

`nemi/episodes/ep09_sf_accident/thumbnail/render_thumbnail.gd` is an episode-specific static composition, not a movie-stage replacement or universal thumbnail schema. `layout.json` records Nemi, palette, placements and two headline options. It uses:

- `nemi/characters/nemi/nemi.tscn` and its existing colour, expression, pupil/gaze and arm controls;
- `common/storytime/production/TravelArt.gd` for both cars;
- `common/storytime/production/Backdrop.gd` for the Golden Gate context;
- `common/storytime/ProfileAssets.gd` for Nemi's underlines and impact marks;
- the project's `Impact.ttf` and `PatrickHand-Regular.ttf` for editorial type.

From the repository root, using the installed Godot executable:

```sh
"$GODOT_BIN" --path . --log-file /tmp/nemi_ep09_thumbnail.log --script nemi/episodes/ep09_sf_accident/thumbnail/render_thumbnail.gd
```

The example rerenders its own named thumbnail outputs only. Adapt a separate source composition for the next episode; do not mechanically reuse the taxi crash, Nemi reaction or headline. For ADB, instantiate `adb/characters/adb/ADB.tscn`, read his supported controls and choose his restrained acting and pen rather than copying Nemi's mannerisms. The shared `PerformancePlayer.gd` supplies existing per-author performance combinations if useful.
