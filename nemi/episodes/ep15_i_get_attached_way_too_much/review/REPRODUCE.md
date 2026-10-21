# EP15 current production source

The current cut is directed by `scene.json` and preserved as `scene_r4_1080p.json`. Runtime is 160.4 seconds (2:40.4), under the user's 180-second maximum and within the requested 150–180 seconds.

Stable source branch: `codex/nemi-ep15-review`. Picture revision commit: `5af2e0f`. Active managed checkout: `/Users/talus/.codex/worktrees/nemi-ep15-review/adb`.

This isolated checkout is necessary because another production added shared artwork during the first main-checkout capture. The normal renderer correctly rejected that unstable capture. It has not been bypassed or changed. All exports use the normal file-based validator, current episode preparation and shared renderer. A fresh Godot checkout needs its normal editor import/class-cache initialization; standard engine checks also need their existing small narration fixtures.

Voice originals, final narration and movies remain local. The source metadata and voice plan pin exact original SHA-256 hashes. Copy the declared existing narration and SFX paths when reproducing this checkout; do not synthesize replacements and reuse old word times. The canonical Sohee config and actual synthesis-engine hashes are recorded separately. Later source regeneration may vary and needs new alignment.

The complete 1080p cut is the user review deliverable. No 4K was rendered and no user approval receipt exists. Preserve this stable checkout and its declared narration/SFX until the user is satisfied and any approved 4K is complete. A future 4K must use this exact preview/input signature and the user's real satisfaction quote through the normal gate. Main-checkout shared source changes do not authorize rebinding approval.

Logs, encoded audio reports and actual render stamps belong in `review/render_records/`; movie indices belong in `review/RENDERS.md`. Earlier proof movies and the superseded R3 full cut are retained. Final-only cleanup applies only after the user-approved final 4K passes checks. No unrelated episode cleanup is authorized.
