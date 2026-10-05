# Storytime isolation

The before/after audit passed for **1,081 protected editable files**, with zero source changes, additions or removals. Original `adb/`, `nemi/`, `common/`, `docs/animation/`, `tools/storytime/`, and root Godot settings remain unchanged. Existing unrelated dirty files and generated media were preserved.

The only explicitly authorized outside-Shorts status changes are `AGENTS.md` routing and the three new `.agents/skills/{adb,nemi,duo}-ink-shorts/` directories. The audit names these paths and records their before/after status separately; it does not exclude any protected source hashes.

See [before snapshot](isolation-before.json) and [after comparison](isolation-after.json). New animation art/directors, media and production reviews remain under `shorts/`. Local discoverable skill symlinks point to the canonical repository source and do not alter episodes.

The rejected Shorts cleanup targeted only `shorts/adb`, `shorts/nemi` and obsolete Shorts pipeline paths, never the top-level storytime folders. [The cleanup manifest](legacy-cleanup.json) records 36 removed targets, 9,898 files (mostly obsolete dependency files), 31 prototype movies and 414,013,963 bytes. Accepted Godot proof/batch01, current music and supplied reference videos were retained.
