# NEMI ep04_scared thumbnail brief — 2026-10-04

User authorized revising all existing episode thumbnails. Apply the animation-art workflow with one headline, white silhouette aura and author-specific completed doodles. Nemi’s blue background and ADB’s gold background follow the latest accepted examples. Existing root thumbnail files remain preserved as historical media; the new recommended delivery is `thumbnail/thumbnail.jpg`.

## Story application before authoring

Read the episode’s subtitle transcript. Evidence: She fears her YouTube animation channel will not work, sees seven views, and decides to keep making the next video.

Chosen headline: **WHAT IF I FAIL?**. Worried face and the film’s illustrated play button; remove its optional annotation. No horror imagery or claim that she quit. This is an editorial portrait/object collage; scales are intentionally separate, not a literal room scene. Use existing production assets only; no generative image service, rig/library edits or new animation scene.

Viewed two actual movie frames on the episode-reference contact sheet, at 14.64s and 47.58s from `nemi/episodes/ep04_scared/renders/EP04_Guys_Im_Scared_4K_Master.mp4`. They establish the episode’s existing character construction, colour mode and pen language. The stills were extracted at 640×360 and the contact sheet displayed at 1106×2048. Source hashes and later performed export review are recorded separately.

## Performed export review

Final GPU batch passed with all ten completion markers and no errors/warnings. Individually viewed the 1920×1080 JPG and inspected native 320×180/160×90 previews in the complete collection sheets. Decoded the native 3840×2160 master and checked dimensions; did not individually view that master during this collection pass. Worried eyes/frown readable; channel play icon clear; optional annotation omitted; no underline crosses the button.

Initial drafts were revised for overlapping type and decorative lines touching art. New compositions omit the optional underline; existing accepted examples retain theirs. Supporting portrait/ear positions were revised where needed. Cat final uses Neeko’s existing curious state for open readable eyes. Source hashes and exact exports are in `provenance_and_qa.json`; final engine output is in `render.log`. Native media stays local.

Recommended file: `thumbnail.jpg`. Edit `layout.json`, then render this folder’s `render_thumbnail.gd` with installed Godot, `--path . --script <renderer-path>`. This delegates only static composition to `tools/storytime/ThumbnailBatch.gd`; it does not bypass the movie-stage validator because no movie scene is authored.

Provenance: **Godot render using existing production rig/art; AI-assisted direction/code**. No generative image service. User approved the channel styling examples; each new composition remains available for feedback. No upload or audience-performance result claimed.
