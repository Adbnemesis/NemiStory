# Nemi EP09 thumbnail revision 3 — 2026-10-04

The user rejected revision 2’s burgundy/pink background and said ADB’s background was fine. This change revises only Nemi’s colour field; keep the single **MY TAXI GOT HIT** headline, shocked production-rig portrait, cream rear-end collision art, white silhouette aura and completed Nemi-profile doodles.

Revision 2 source, exports, log and provenance are preserved under `revisions/r2/`; revision 1 remains under `revisions/r1/`. Actual episode/script evidence and art sources are unchanged: human-driven airport taxi rear-ended, Nemi in the back; both cars face left and follower nose meets taxi rear. This is an editorial portrait/event collage.

## Palette application and review

Rendered and viewed blue (`#183b57` to `#508aa8`), warm brown (`#603b35` to `#bc825a`) and lavender (`#3e3b66` to `#7c79ac`) full compositions in Godot. Chose navy-to-denim blue for clear warm/cool separation from Nemi’s red hair, readable cream/white type and a quieter field behind the aura. Brown is close to her hair hue; lavender has softer value separation. This is assistant visual judgment, not user approval or audience-performance evidence.

Fresh final Godot render completed with `THUMBNAIL_OK nemi_ep09_revision3` and no errors/warnings. Viewed final 1920×1080 JPG, 320×180 phone preview, 160×90 tiny preview and native 3840×2160 master displayed at 2048×1152. Headline readable at reduced sizes; eyes and face remain clear; white aura/marks and existing bumper contact retained. Bottom-right wheels remain close to a potential platform duration overlay, with no critical headline/face there. No upload or CTR measurement performed.

Recommended delivery: `thumbnail.jpg`. Editable layout: `layout.json`; static renderer: `render_thumbnail.gd`; shared styling: `tools/storytime/ThumbnailStyle.gd`. Source/output dimensions, sizes and hashes are recorded in `provenance_and_qa.json`; engine output is in `render.log`. Native masters/previews stay local. From the repository root:

```sh
/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot --path . --log-file /tmp/nemi_ep09_thumbnail_r3.log --script nemi/episodes/ep09_sf_accident/thumbnail/render_thumbnail.gd --quit-after 180
```

Renderer optionally accepts `-- --layout=<json-path> --output=<file-prefix>` for isolated colour studies. Default invocation exports the episode’s current selected layout. Canonical rig/prop geometry, art palette, expression, placement and type remain unchanged; no episode animation/audio/movie edits. Shared document, AGENTS routing and Nemi skill now record the rejected background preference without treating blue as a permanently approved channel palette. ADB remains unchanged.

Provenance: **Godot render using existing production rig/art; AI-assisted direction/code**. EP00 remains a historical reference for aura/doodle treatment, with no old generated pixels copied.
