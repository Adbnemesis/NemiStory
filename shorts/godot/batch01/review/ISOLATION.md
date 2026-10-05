# Storytime isolation — five Shorts batch

The five new Shorts are a separate Godot music-edit production under `shorts/`. They do not require changing a storytime episode, rig, pose library, voice setting, or original project setting. Original character controls may be read by the Shorts director; new visible pose art belongs to `shorts/godot/`.

## Baseline captured 5 October 2026

`isolation-before.json` records the exact relative path, SHA-256 and byte size of **1,081 protected editable source files**:

| Protected location | Files hashed |
| --- | ---: |
| `adb/` | 156 |
| `nemi/` | 801 |
| `common/` | 57 |
| `docs/animation/` | 28 |
| `tools/storytime/` | 38 |
| Root `project.godot` | 1 |

The root `override.cfg` was absent. Its continued absence is part of the final check. Text, Godot scene/resource, JSON, production documents and editable vector source are included. Binary media/fonts, generated `.uid`/`.import` sidecars, symlinks, and `renders/` contents are excluded from source hashing. The complete suffix and directory rules are saved in the baseline. This is a source isolation check; it is not a byte-for-byte audit of every large media file.

The original Nemi and ADB main scripts, pose libraries, five geometry/style source files, and root project settings all matched the hashes saved with the approved monochrome proof. **All 10 historical provenance checks passed.**

## Existing changes preserved

The repository already had **347 nonignored Git status entries outside `shorts/`** at the start of this batch. Most are generated Godot UID/import files and prior review/render artifacts. The 12 tracked changes were:

- Eleven deleted render logs/audio reports in `adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/renders/`.
- The modified `nemi/episodes/ep09_sf_accident/renders/RENDERS.md`.

Every path and status is listed in `isolation-before.json`. These pre-existing changes are preserved; the final check compares against that baseline rather than requiring an initially clean repository. No cleanup of older storytime media is authorized by this batch.

## Final verification

After the five Shorts have rendered, run this read-only check from the workspace root:

```sh
.venv/bin/python shorts/tools/audit_isolation.py check shorts/godot/batch01/review/isolation-before.json shorts/godot/batch01/review/isolation-after.json
```

The check exits successfully only if all protected source hashes and paths, root setting existence, and the exact Git status outside `shorts/` remain unchanged. The final report names any changed, added or removed protected file. A baseline alone does not establish that the completed batch remained isolated; completion requires the final report to pass.

The final rendered batch comparison passed on 5 October 2026. [isolation-after.json](isolation-after.json) records zero changed, added or removed protected files and the unchanged outside-Shorts status.
