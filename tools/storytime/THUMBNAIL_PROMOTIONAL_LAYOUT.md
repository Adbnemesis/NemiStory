# Static promotional layout contract

This is a thumbnail-only adapter around the existing static compositor/illustration/rig controls, not a storytime animation schema or another drawing player. Current saved examples are the six layouts listed by `thumbnail_promotional_2026-10-06.json`; ADB's crush A is a complete example. Preserve character definitions and production libraries.

Required layout fields: `format: storytime-static-promotional-v1`, `author: adb|nemi`, `episode`, `variant: a|b`, `revision`, `title`, `thumbnail_phrase`, `story_evidence`, `application`, `background: {top,bottom}`, `headline`, and ordered `layers`. Geometry is authored on a logical 1920×1080 canvas and rendered natively at 3840×2160. Several headline lines may typeset the same single phrase; no secondary captions. Fonts/resources must resolve in the project.

Layer types:

- `character`: required unique `id`, `author`, canonical `rig`, `position`, `scale`; supported pose/expression/recipe controls come from the existing `ThumbnailEpisodeSet` and actual rig API. ADB requires a catalog recipe; optional `gaze`, `eyes`, `tilt`, `blush`, `mouth`, and `hand_targets` direct existing controls. Nemi supports existing pose/expression/gaze/eyes/pupils/tilt/arms plus `mouth` and existing authored hand targets. Do not invent control names or silently fall back from unsupported poses.
- `prop`: same `kind: scene|script` and existing legacy static prop kinds. Scene assets use `SceneArt`; a script creates a Node2D with `.new()`. Optional `controls` configure supported properties once. Newly authored symbolic props belong in the episode thumbnail folder and use the correct profile/fill language.
- `scenery`: a `source` GDScript with `static make(author,variant,part) -> Node2D`. `part` is a named part declared by that local factory, such as background/foreground/food/burst; the static validator checks it against the declared branches. Optional position/scale/angle transform a local illustration group.
- `mark`: supported per-author profile mark plus position/scale/angle/colour/weight from the existing decoration route.

Normal transformed layers use `position: [x,y]`, scalar or vector `scale`, and optional `angle` in degrees. Scene factories may use canvas coordinates without a transform. Layer z-indices advance in steps of30, preserving internal rig part order while allowing a later foreground prop to occlude a torso. Headlines are above the art.

For a held prop, `attachment: {actor: id, hand: left|right, grip_local: [x,y]}` anchors its local grip coordinate to that actor's actual hand/wrist node. The actor must precede the prop. `grip_overlay: true` duplicates the existing hand drawing at its exact transform above the prop; no new hand geometry or rig change. `contact_geometry.json` records the measured anchor error. A zero anchor error does not prove that the fingers look correct; visually inspect grip, wrist, sleeve overlap and face clearance.

Nemi's existing hand targets support actor-local `position` or `head_offset`, a supported `hand`, wrist `angle` and optional `elbow_side` to choose an existing IK branch while preserving segment lengths. ADB targets use actor-local position and existing `HandPaths`, plus a supported independent hand type. All controls are static once the rig has initialized.

Supporting artwork uses the existing `LiveDrawing` and profile assets, prepared with completed `progress = 1.0`. Its renderer draws fills before strokes within one object. Use separate ordered Drawing children for overlapping objects when a foreground fill must cover an earlier outline. Do not rely on a later fill in the same object to hide earlier strokes.

Validate before GPU export:

```sh
.venv/bin/python tools/storytime/validate_thumbnail_pilots.py
"$GODOT_BIN" --path . --log-file /tmp/promotional.log --script tools/storytime/ThumbnailPromotional.gd
```

Single layout: validator `--layout <project-relative-layout>`; renderer `-- --layout=res://<layout>`. The validator can accept an alternate manifest with `--manifest`. The earlier rejected `storytime-static-pilot-v1` format remains readable for preservation, not a current art-direction template.

Check the render log for errors as well as completion markers; a Godot script assertion can interrupt one function without making the process return a nonzero exit. A marker alone cannot approve a broken render. Inspect full JPGs, text-free captures and 320/160 reductions; preserve drafts before revision. Save honest performed/unperformed checks and output/source hashes. Run `package_promotional_thumbnails.py` only after the final reviewed exports exist. It verifies dimensions, hashes and ZIP content, not artistic quality or CTR.
