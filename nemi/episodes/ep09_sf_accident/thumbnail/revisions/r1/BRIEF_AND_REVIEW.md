# EP09 thumbnail — 2026-10-04

User requested a San Francisco thumbnail using animation-matching production art, without AI image generation, plus a workflow for future Nemi/ADB thumbnails. Scope: a separate static composition and documentation; no changes to this episode's movie, scene, voice, timing or character definitions.

## Story and application notes

- Script evidence: Nemi rode a Waymo safely, then a human-driven taxi was rear-ended five minutes from SFO; she was in the back seat. Source: `../SCRIPT_AND_BEATS.md`, turns 11–14 and the direction brief.
- Primary hook: **MY TAXI / GOT HIT.** Alternate: **5 MINUTES / FROM SFO...** Both retain **I WAS IN THE BACK.** as a secondary aside. The default gives an immediate event; the alternate uses the proximity-to-safety irony. Neither suggests the Waymo crashed or adds an injury.
- Actual episode references inspected: `../review/camera_contact.jpg` and `../renders/stills_4k/05_crash_impact_4k.png`. These establish the colour rig, warm/plum ink, muted cream cars, quiet flat scenery and Golden Gate context.
- Existing rig documentation/source controls were read for colour mode, shocked expression, eye/pupil/gaze, instant arm posing and hands. The production-kit reference requires separate Nemi/ADB pen identities and unchanged rigs. This thumbnail uses Nemi's existing profile marks, completed at `progress = 1.0`, and disables autonomous rig processing.
- Composition: a large foreground reaction on a quiet postcard panel, with a separate collision vignette. Different scale is intentional editorial collage. Both cars face left; the following vehicle's front contacts the taxi's damaged rear. The actual Golden Gate backdrop is cropped behind the portrait.
- Editorial choices: project's Impact headline and Patrick Hand supporting type, canonical character palette and Nemi rose accents; no lighting/texture/style transfer. No generative image service, stock reaction face or replacement character art.

## Reproduction and files

Editable source: `render_thumbnail.gd`, with headline/palette/placements in `layout.json`. The layout is an episode-specific static-image recipe, not a version-2 animation spec. Rig/art/font and output hashes are saved in `provenance_and_qa.json`. The final engine log is `render.log`.

Run from the repository root with the installed engine:

```sh
"$GODOT_BIN" --path . --log-file /tmp/nemi_ep09_thumbnail.log --script nemi/episodes/ep09_sf_accident/thumbnail/render_thumbnail.gd
```

Recommended upload copy: `thumbnail.jpg`; alternate: `thumbnail_alt.jpg`. Both are 1920×1080. PNG delivery copies and native rerasterized 3840×2160 masters remain local alongside 320×180 and 160×90 previews. Masters are not enlarged 1080p bitmap exports. The script updates only this thumbnail folder's own outputs; preserve a reviewed revision before rerunning after user approval.

## Review

The first pose obscured the face; the revised pose still extended a hand across the event vignette. Final arm placement keeps the whole face readable and the raised hand beside the portrait. The hair tip clears the location label. Taxi and follower now make bumper contact rather than leave an obvious gap.

Inspected final recommended and alternate JPGs at 1920×1080, both previews at 320×180 and 160×90, and the native master displayed at 2048×1152. Headline and shocked face remain readable at reduced size; the secondary aside/location text can become optional detail at 160×90. No face/word clipping; no added fingers or rig art; contact accent points to the collision. Bottom-right area contains road, leaving the main face, headline and collision clear of a typical duration badge.

Both skill frontmatters passed the skill validator with the existing project Python environment. Godot's final run completed both exports without script errors or warnings. Image files decoded successfully; dimensions, sizes and SHA-256 hashes are recorded. Source diff check found no edits to the episode `scene.json`, rig, profile helper, scenery or vehicle definitions. Existing unrelated working-tree changes were preserved.

This is assistant visual review of static candidates. No new animation/movie proof, user approval, upload, click-through improvement or audience acceptance is claimed. Provenance: **Godot render using existing production rig/art; AI-assisted direction/code**. The original origins of existing character assets were not independently audited.
