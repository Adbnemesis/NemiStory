# Native character material for the approved message edits

The external edit retains the approved EDIT R9 logical composition, author poses, layered book/hand contacts, typography, cut frames, four-frame dissolve, narration and mix. Only output raster density changes.

`../capture_message_plates_4k.gd` derives from the approved canonical character capture. Pose, IK and recipe function bodies are identical; its viewport is4000×4400, rig origin2000,2200 and rig scale9.0. It saves new static character alpha/mouth/foreground-hand PNGs under `renders/message_to_storytime_rebuild/character_plates_4k/`; existing2000×2200 character inputs are preserved. Godot supplies these character assets only. It never composes the final movies.

`capture_manifest.json` pins the local66 PNGs and capture source. `anchors.json` records raw2× positions, and `anchors_logical.json` retains the approved registration. Raw anchor error against exactly2× the originals is at most1.01e−11 pixels; hand angles are identical. The source sibling inspected downsampled silhouettes and contacts. Differences at pixel edges are expected native antialiasing, not a new pose.

Typography and book/desk paths are evaluated at3840×2160. The existing studio background is1672×940 and is resized with Lanczos; it is honestly an upscaled raster source within the4K composite. The bright insert gradient is evaluated at output dimensions. Character rigs, definitions, hands, expressions, voice settings and sound mix remain unchanged.

Each episode's `review/edit_4k/1080P_EXTERNAL_EDIT_APPROVAL.json` records the actual human approval, approved completeR9 movie/input hashes, and the exact preserved approved AAC archive. No Godot movie approval receipt is fabricated. After episode-scoped replacement cleanup, the compositor accepts the archived AAC only if the exact approved preview's deletion is documented in a hash-bound successful cleanup record. These native PNGs and original source assets stay local; source JSON/GDScript/Python and QA records remain reproducible without bundling generated media.

Final output uses `tools/edits/storytime_message_edit.py --4k` and verification uses `tools/edits/verify_message_4k.py`. Both keep the same750 frames at30fps. An independent keyframe at22.1 seconds prevents faint H.264 prediction residues in the all-black ending.
