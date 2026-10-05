# Godot music-edit Shorts workflow

Use this pipeline for the separate ADB/Nemi music edits. The approved starting direction is the 12-second monochrome R3 proof: thin contours, readable viewpoint changes, held illustrations, one stable premise and brief reframes on music accents. Version 2 adds authored contact poses, gray washes/hatching, sparse stages and event-linked doodles. It is separate from episode production. Keep all new source, music, renders and reviews under `shorts/`; preserve the approved proof and every existing storytime episode.

## Make one distinct edit

1. Choose a single visual idea and payoff. Save the board beside the spec. Give the short a recognizable device: headphones and sound arcs, a doorway reveal, pencil/page graphics, contrasting personalities, or camera framing. Use enough empty space for the face and hands to remain legible at phone size.
2. Select a saved music recording and section. Batch 01 uses five actual public Apple/iTunes AAC previews, decoded to unchanged-speed 48 kHz stereo PCM. Source metadata, original/decoded SHA-256 hashes, analysis and candidate edit clocks live in `shorts/assets/music/batch01/`. `sourceStart` refers to the downloaded preview, whose offset within the full song is unknown. These are recognizable reference-fit recordings; no current platform trend rank has been established.
3. Audition the section and choose meaningful accents. Candidate onsets and pulse fits help locate them; they do not establish downbeats automatically. Author picture and event positions on the 30 fps clock, recording source time, picture frame and rounding error in a cue map. A nearest-frame cut can differ from the measured accent by up to 16.67 ms.
4. Copy a version-2 spec and author actor cues, shot compositions, theme and finite events. See [SCHEMA.md](SCHEMA.md). Physical props are part of authored held drawings. Cut between those poses unless a continuous contact animation has actually been drawn.
5. Validate, render stills, inspect the composition, then render the movie. Watch the exported movie with audio; a successful render does not establish creative quality. Save source provenance, actual beat checks, audible SFX checks and remaining limits under that production's `review/`.

## Commands

The headphone edit is a runnable version-2 production example. Replace its path with the selected batch folder:

```sh
.venv/bin/python shorts/godot/validate_ink.py shorts/godot/batch01/01-my-song/short.json
.venv/bin/python shorts/godot/render_ink.py shorts/godot/batch01/01-my-song/short.json r2 --stills
.venv/bin/python shorts/godot/render_ink.py shorts/godot/batch01/01-my-song/short.json r2
```

Choose a new revision for every replacement movie. The renderer refuses to overwrite an existing movie. Stills land in `review/stills/<revision>/`; capture logs and source/export records remain in `review/`. Version-2 movies use the spec `id` in `renders/<id>_<revision>_1080x1920.mp4`. The still route captures frame 0, the final frame and seven frames after each shot change; inspect transition frames separately when a contact, whip or brief flash needs it.

The current renderer expects the project's Python environment, FFmpeg/FFprobe and `/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot`. Its portrait project settings must be present before MovieWriter starts.

## What draws the picture

- `InkPoseArt.gd` contains the approved manually authored Bezier/line/polygon illustrations. `BatchPoseArt.gd` extends them with gray wash shapes, hatching, authored hands and attached phone/sketchbook/pencil/headphone/glasses details. These are editable supplemental Shorts drawings. They are not sprites taken from the reference videos and do not use generated bitmap artwork.
- `InkEdit.gd` creates hidden original ADB/Nemi rig instances and samples existing controls with runtime-only recipes. Original rig, hand, face and pose source files stay unchanged. The hidden samples do not supply the visible body drawing. Visible art is selected by `view`, `emotion` and `action`, with horizontal gaze and a brief head settle. Rig `pose`, `expression`, `eyes`, `motion`, `duration` and `blinks` should not be described as a complete visible performance system here.
- `BatchEdit.gd` selects the theme and finite camera move. Cuts hold; punches/pulls ease to their framing; whips have an authored direction. `angle` is an initial tilt that settles to zero. The drawings stop moving after their short settle.
- `BatchAccentArt.gd` draws stage graphics and doodles behind the characters. Doodles scale into place for four frames, remain still, then end at their specified frame. The pencil wipe and brief flash occupy a separate foreground layer; the pencil crosses the frame during its finite event. Paper grain is spatially fixed in the backdrop shader. There is no per-frame random ink or endless bobbing.

`listen`, `phone`, `sketch`, `glasses`, `peace`, `wave` and `point` are static authored contact/gesture poses. This is pose choreography: there is no automatic walking, physical pickup/release, or general inverse-kinematics contact system. In the current drawing source, ADB's back view returns before accessory/gesture additions; use it as a resting back illustration. Do not imply an unseen hand/device interaction from a cut.

## Sound and export

The validator checks every referenced audio file's exact SHA-256 and source interval with FFprobe. An SFX must point to a named visual event, use a saved recording under `common/audio/sfx/`, and begin at a legal scene frame after its optional offset. Select the exact original root/category recordings and preserve their provenance; the path/hash check does not replace checking the original inventory. Do not synthesize substitute SFX.

Live Godot playback follows the music clock and triggers event-linked SFX. Movie capture samples the same visual frame clock manually. The renderer makes a temporary Godot project with **native 1080 × 1920 settings**, read-through links to existing assets and the existing import cache. It validates capture dimensions/count and rejects Godot error logs. It does not rewrite the root project or episode files.

Godot draws every visual frame. FFmpeg trims only surplus capture frames, encodes H.264/AAC, selects the saved music section, applies gain and mixes the recorded SFX at event time. It does not add visual animation or restyle frames. Final SFX delay is rounded to milliseconds; verify the encoded mix for headroom, audibility and timing. The recorded raw capture count is retained in each render report.

## Review and isolation

Inspect settled stills and actual playback, including the first and final frame, face/hand readability, contact silhouettes, cut/beat alignment, finite transitions and the visual payoff. Compare at phone size with the supplied reference. Record only checks actually performed; source boards and candidate beat maps are not completed export QA.

At the end of batch 01, verify the protected storytime source and existing outside-Shorts status:

```sh
.venv/bin/python shorts/tools/audit_isolation.py check shorts/godot/batch01/review/isolation-before.json shorts/godot/batch01/review/isolation-after.json
```

The baseline hashes 1,081 editable protected source files and records pre-existing changes. See [batch01/review/ISOLATION.md](batch01/review/ISOLATION.md) for the exact scope and limitations.

## Verify a checked movie

```sh
.venv/bin/python shorts/godot/inspect_export.py shorts/godot/batch01/01-my-song/short.json shorts/godot/batch01/01-my-song/renders/my-song_r2_1080x1920.mp4
.venv/bin/python shorts/godot/verify_audio.py shorts/godot/batch01/01-my-song/short.json shorts/godot/batch01/01-my-song/renders/my-song_r2_1080x1920.mp4 shorts/godot/batch01/01-my-song/review/audio.json
.venv/bin/python shorts/godot/test_validate.py
```

The audio checker independently reconstructs the configured music and recorded SFX, estimates decoded latency, compares source-omission hypotheses for each effect, and rejects clipping or true peak above−1dBTP. It does not apply an assumed codec-delay correction or change the movie. After selecting checked revisions in `review/current.json`, regenerate the batch documents and gallery with `document_batch.py` and `build_review.py`.
