# Storytime thumbnails from production art

User direction, 2026-10-04: future Nemi and ADB thumbnails must match their storytime animation art. Do not use an AI image generator to make or restyle a thumbnail. Build the composition in Godot from the existing character rig, supported expressions/poses/hands, episode scenery and prop art. Ordinary crop, type, layout and export tools can finish the rendered art. New supporting shapes can be explicitly authored in Godot/vector code in the same illustration language; do not replace the character with an independently drawn lookalike.

This applies to thumbnail requests and the thumbnail deliverable of future episodes. It does not authorize changing old movies or replacing unrelated old thumbnails. The first requested example is `nemi/episodes/ep09_sf_accident/thumbnail/`.

Refinement, 2026-10-04: use **one eye-catching headline only**. Omit small location labels, asides, object labels, branding and secondary copy. Supporting punctuation can be a compact doodle, not another caption. Nemi's default background references her EP00 burgundy/pink field; ADB's references his EP00 golden-yellow field. Keep a common white cutout outline with a soft aura and a few author-specific doodles. These background/compositing treatments are explicitly allowed; character/prop drawing style still comes from the storytime art. Recreate the background treatment in Godot or reuse a user-authorized clean background layer; never copy the generated face/character or old headline. Preserve honest background provenance if any pixels from an older generated image are reused.

## Route and scope

For a thumbnail-only request, load the narrator's storytime skill and this document. Read the episode script/direction, inspect actual movie stills, and read the relevant existing rig/prop APIs before composing. Save thumbnail-specific application notes and provenance in the episode's `thumbnail/BRIEF_AND_REVIEW.md`. Do not create a new episode or rewrite its animation `scene.json`, audio, timing or preparation record merely to make a static thumbnail. The full episode preflight and ten-second/integrated movie proof apply when animation work is also requested; a static thumbnail is reviewed as an image, not passed off as a validated animation export.

Use `<author>/episodes/epNN_slug/thumbnail/` for editable composition source, native master, upload copy and reduced previews. Keep thumbnail QA/provenance here or under the episode's `review/`. The episode's `renders/` remains reserved for its final 4K movie. Preserve an existing thumbnail under a revision name before replacing it. Do not edit rigs, expression/pose/hand libraries, episode scripts or original renders to satisfy an editorial thumbnail pose.

## Design the click around the story

Choose a real tension or consequence from the script. Start with one readable face, one story object/action and a short hook. Reaction size, purposeful asymmetry, a quiet background and clear value separation can make existing art compelling. Use location scenery when place matters. An editorial portrait plus a separate event vignette can have different scales; make that separation clear. In a single literal scene, preserve believable character-to-object scale.

Keep the actual silhouette, face construction, line language and canonical colour/monochrome mode used in the episode. Nemi's rounded warm plum/rose pen and ADB's compact slate pen come from their separate `common/storytime/profiles/` files. Use `ProfileAssets.mark(author, ...)` for handwritten marks and set completed ink `progress = 1.0`. Thumbnail decorations may use white ink while retaining the author's paths. Do not invent a second private doodle renderer. Bold typeset headline text is editorial typography, not character handwriting; use existing project fonts. The white outline/aura belongs around the rendered silhouette; it must not repaint the character. A quiet stationary texture in an intro-inspired background is allowed. Avoid painterly skin, fake character lighting or a different illustration genre.

Headline and picture must describe the story honestly. Do not add injury, fire, blood, a villain or an outcome absent from the episode. Avoid implying the Waymo caused Nemi's accident: her human-driven airport taxi was rear-ended. Catchiness is an artistic aim; do not claim higher click-through or audience approval without data.

## Build and inspect

1. Save a brief: episode/title, exact story evidence, visual hook, art sources, type/colour choice and what the thumbnail edit may change.
2. Instantiate the existing rig in a separate Godot static composition. Let `_ready` run, disable autonomous processing, then apply supported controls once. Keep eyes, mouth and identifying hair readable. Use the episode's existing prop/scenery helpers. Render a fresh framebuffer with a real graphics renderer; headless dummy rendering is not image evidence.
3. Rerasterize vector artwork at the master resolution. A useful starting point is a native 3840×2160 master and a 1920×1080 JPG/PNG delivery image, with 320×180 and optionally 160×90 feed previews. Downsampling a native vector capture is acceptable; label an upscale honestly.
4. Inspect the full composition and reduced image. Check expression, fingers, arm overlap, crop, story-object contact/orientation, text clipping, contrast, clutter and the bottom-right duration-overlay area. Revise when the face or action becomes ambiguous. A file's existence does not prove visual quality.
5. Save exact output dimensions, file sizes, hashes, source provenance and which images were actually inspected. Record the rendering command and any unperformed checks. Keep a recommended option and an alternate only when the alternate offers a meaningful hook. Final approval/real audience performance remains with the user.

Provenance should say “Godot render using existing production rig/art; AI-assisted direction/code” where appropriate. Do not describe AI-assisted vector composition as entirely human handmade, or assert an unverified history for existing assets. No generative image service is part of this thumbnail workflow.

## Reproducible first example

`nemi/episodes/ep09_sf_accident/thumbnail/render_thumbnail.gd` is an episode-specific static composition, not a movie-stage replacement or universal thumbnail schema. Current `layout.json` records Nemi, background, placements and the single MY TAXI GOT HIT headline. Revision 1 is preserved under `thumbnail/revisions/r1/`. It uses:

- `nemi/characters/nemi/nemi.tscn` and its existing colour, expression, pupil/gaze and arm controls;
- `common/storytime/production/TravelArt.gd` for both cars;
- `common/storytime/ProfileAssets.gd` for Nemi's underlines and impact marks;
- the project's `Impact.ttf` for the single editorial headline;
- `tools/storytime/ThumbnailStyle.gd` for the shared background, external silhouette aura and image export treatment.

From the repository root, using the installed Godot executable:

```sh
"$GODOT_BIN" --path . --log-file /tmp/nemi_ep09_thumbnail.log --script nemi/episodes/ep09_sf_accident/thumbnail/render_thumbnail.gd
```

The example rerenders its own named thumbnail outputs only. Adapt a separate source composition for the next episode; do not mechanically reuse the taxi crash, Nemi reaction or headline. For ADB, instantiate `adb/characters/adb/ADB.tscn`, read his supported controls and choose his restrained acting and pen rather than copying Nemi's mannerisms. The shared `PerformancePlayer.gd` supplies existing per-author performance combinations if useful.

ADB's first example is `adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/thumbnail/render_thumbnail.gd`: existing shy-confession performance, canonical rig, `SchoolGags.crush_heart`, the golden background and **SHE LIKED ME?!** headline. Run with the same Godot command and that script path. Each example exports a native 4K master, 1920×1080 delivery copies and 320×180/160×90 reviews. Read its `BRIEF_AND_REVIEW.md` and `provenance_and_qa.json` for performed inspection and source hashes.
