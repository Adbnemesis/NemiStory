# Nemi EP09 thumbnail revision 2 — 2026-10-04

User requested **MY TAXI GOT HIT** as the only text; removal of the location label, aside and taxi roof label; EP00-inspired burgundy/pink background, little doodles and common white glow/outline. The existing storytime character and rear-end car art remain.

References inspected: Nemi EP00 thumbnail (burgundy/pink field, white compact doodles); earlier EP09 film contact sheet and collision still already inspected in this chat. Script evidence: airport taxi rear-ended, Nemi in the back. Both cars face left; follower nose meets taxi rear. Thumbnail is an editorial character/event collage. Author: nemi.

Application: recreate the background treatment in Godot rather than reusing the old generated face; external white halo is compositing around unchanged production art. Keep the existing supported Nemi shocked face, canonical colours and arms beside the face. Profile marks retain her own paths.

Revision 1 source, exports and provenance preserved in revisions/r1/.

## Final review and files

Fresh Godot exports passed with a completion marker and no errors/warnings in the final log. Inspected the 1920×1080 JPG, 320×180 preview, 160×90 preview and native 3840×2160 master displayed at 2048×1152. One headline reads at both reduced sizes; face/eyes stay clear. Native masters were rasterized from the vector rig/art before editorial compositing, not upscaled from a 1080p bitmap.

Recommended copy: `thumbnail.jpg`. Editable layout: `layout.json`; renderer: `render_thumbnail.gd`; shared external styling: `tools/storytime/ThumbnailStyle.gd`. Master and inspection PNGs remain local. Source/reference/output dimensions, sizes and hashes are in `provenance_and_qa.json`; final engine output is in `render.log`. Run the installed Godot from the repository root with `--path . --log-file /tmp/thumbnail.log --script` followed by this folder's renderer path.

Both updated skills passed the skill validator. Protected-source diff checks found no changes to the character rigs, expression/pose/hand libraries, shared props/profiles or either episode scene. No animation, voice or movie changes. The EP00 image was a visual background reference only; no old generated character, lettering or background pixels were reused. Provenance: **Godot render using existing production rig/art; AI-assisted direction/code**. No audience-performance claim or user approval is implied.

Removed the location/aside/object text. Preserved previous outputs/source/QA under `revisions/r1/`; superseded alternate files now live there. Nemi uses her own rounded double underline and impact strokes; both vehicles face left with nose-to-rear contact.
