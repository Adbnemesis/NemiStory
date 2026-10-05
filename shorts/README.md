# ADB + Nemi Shorts — Godot ink edits

Five complete 15-second Shorts extend the user-approved monochrome r3 direction with gray washes/hatching, additional hands/props and distinct doodle accents. **Godot draws every visual frame; no image generation.**

[Watch all five](review/batch01/index.html) · [Batch direction and exports](godot/batch01/README.md) · [Workflow](godot/WORKFLOW.md) · [Schema](godot/SCHEMA.md) · [QA](godot/batch01/review/QA.md)

| Short | Visual idea | Music |
| --- | --- | --- |
| My song just came on | Nemi headphones and confidence switch | Dancin — Krono Remix |
| Wrong-class runway | ADB fashion crops and doorway reversal | FΛSHION — Clean Version |
| One quick doodle | Nemi pencil wipe and page constellation | Makeba |
| Same beat, different energy | Duo pose contrast and reversed ink | Memory Reboot |
| The camera likes her | Viewfinder, photo comparison and photographer reaction | Cheri Cheri Lady |

All exports are native 1080×1920, 30 fps, H.264/AAC. Five exact official public preview recordings were downloaded; source versions, URLs, original/decoded hashes, selected sections and beat measurements are retained under [assets/music/batch01/](assets/music/batch01/MUSIC_SOURCES.md). These are recognizable reference-fit choices; current platform trend ranks remain unverified. Each short has one exact original recorded SFX linked to a named visual event.

The visible art is authored Godot curves/lines/polygons in `godot/InkPoseArt.gd` and `godot/BatchPoseArt.gd`. Actual profile/back illustrations, fixed hand/prop contact, held doodles and finite punches/pulls/whips supply the edit. Original rig controls are sampled in hidden read-only instances; they do not supply the visible supplemental drawings. The pipeline does not imply automatic walking, pickup or a general dance rig.

Everything new stays under `shorts/`. [The isolation comparison](godot/batch01/review/ISOLATION.md) passed for all 1,081 protected editable storytime files and all 347 existing Git status entries outside Shorts. Original episodes, rigs, pose/face/hand/voice source and root project settings were unchanged. The accepted proof remains at [review/rebuild/](review/rebuild/index.html).

## Edit and reproduce

Each production has its own `Edit.tscn`, `short.json`, `DIRECTION.md`, source-clock `CUE_MAP.json`, `renders/` exports and `review/` evidence. Open its scene in Godot or direct the saved timeline. For example:

```sh
.venv/bin/python shorts/godot/validate_ink.py shorts/godot/batch01/01-my-song/short.json
.venv/bin/python shorts/godot/render_ink.py shorts/godot/batch01/01-my-song/short.json r3 --stills
.venv/bin/python shorts/godot/render_ink.py shorts/godot/batch01/01-my-song/short.json r3
```

Choose a new revision; earlier movies are preserved. The renderer uses an isolated temporary native portrait Godot project. FFmpeg packages the capture and recorded sound, with no visual animation/restyling. Strict validation, decoded picture/audio checks, source hashes and review evidence accompany the exports. See [WORKFLOW.md](godot/WORKFLOW.md) for the review and sound verification commands.

The review page can be served with the existing local preview server:

```sh
.venv/bin/python shorts/tools/review_server.py
```

Open `http://127.0.0.1:8768/shorts/review/batch01/index.html`. The range-aware player supports seeking, playback and downloads. Generated media stays local and is excluded from source Git commits. Music can be fetched again with `shorts/assets/music/batch01/fetch_music.py`; asset hashes must be rechecked and timings revised if a catalog preview changes.

## Earlier work

The first four caption-led Remotion prototypes were rejected as too close to storytime. They remain [iteration history](review/legacy-prototypes.html), with earlier analysis/tools retained. They are not the active visual renderer or approved style examples. The generated image atlas was removed from this project and is not used.

Reference analysis is retained in [REFERENCE_ANALYSIS.md](REFERENCE_ANALYSIS.md) and [the exact supplied films](review/references/index.html). The approved r3 proof established the new direction; these five new Shorts have passed source/export/isolation checks and are available for the user’s creative review. Audience performance and current trend ranks are not inferred from a successful render.
