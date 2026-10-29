# Isolation verification

All new production development lives under `nemi/playable_storytime/`. Existing episodes, Shorts, rigs, voice settings and root manifests remain read-only. Godot uses copied dependencies and a disposable copy of the installed executable. Its capture process denies file writes outside the new project. Python/model caches, temporary files, narration, score and movies are stored here.

The baseline captured 14,617 outside repository files, including SHA256 checks for 4,204 source/configuration files, while preserving 3,007 pre-existing Git status entries. The latest `isolation_check.json` reports **no outside additions, deletions or modifications**. This does not imply the original checkout was clean.

Recognized source/configuration files up to 4 MiB receive SHA256 checks. Large media and sensitive-name files use size, modification time and mode. The baseline explicitly lists excluded `.git`, `.venv`, `.godot` and `node_modules` directories. Access times are ignored because inspection can change them. These are the checker's measurement limits.

Early graphics attempts were blocked or captured an incorrect 960 × 540 image. Invalid captures were rejected before delivery. Godot's automatic macOS user-data initialization was identified; an empty external user-data directory was observed, with no files written there. Subsequent captures use a process policy that denies external writes. The repository baseline is not a forensic check of arbitrary host directories.

The 233 frozen dependency paths, hashes and origins are recorded in `engine/godot/dependency_provenance.json`. Copied rigs and libraries remain byte-identical. Referenced episode media and original voice takes are retained. The built-in image-generation tool's native outputs were copied into the episode thumbnail folder with provenance.

No original episode edit, root dependency/configuration change, unrelated cleanup or Git push was performed for this project. Movie cleanup is deferred until the approved final 4K replacement passes checks.


R6 final verification: `isolation_r6_final.json`, checked2026-10-25T13:04:59UTC. All14,617monitored outside files matched; no outside additions, deletions or modifications. R5movies/sources/voice and superseded R6proofs remain inside the isolated project. Existing coverage limitations continue to apply.

R7 final verification: `isolation_r7_final.json`, checked 2026-10-26T05:31:56UTC. All 14,617 monitored outside files matched with no additions, deletions or modifications. All 233 frozen dependency hashes also match (`episodes/episode_001/review/r7_frozen_dependencies_check.json`). R7 review media, browser evidence and final reports remain inside the isolated project. The coverage limits above still apply.

R9 final verification: `isolation_r9_final.json`, checked2026-10-26T06:51:55UTC. All14617monitored outside files match, with no additions/deletions/modifications; all233canonical dependency hashes match in `episodes/episode_001/review/r9_frozen_dependencies_check.json`. R7/R8sources and prior media remain preserved. Existing checker coverage limitations apply.
