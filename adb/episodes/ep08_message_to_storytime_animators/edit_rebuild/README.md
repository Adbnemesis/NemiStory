# Approved edit and4K delivery

The user approved the complete EDIT R9 with “great, now render both in4k…” on24October2026. Current final export is indexed at `../review/RENDERS.md`;4K approval/source/codec checks are under `../review/edit_4k/`. The earlier R9 delivery description below is retained as production history. Superseded movies are removed only after replacement verification, per the project retention preference; source/voice/art/QA remain. The renderer can verify the preserved approved AAC archive after documented cleanup.

# ADB — externally edited message promo

Current final cut: `../renders/ADB_Message_EDIT_R13_4K_FINAL.mp4`, 25.000 seconds, 3840×2160, 30 fps. Approved source: external EDIT R9 1080p. R9 removes four optional arm-settle frames so the7.6s insert cuts directly to the committed arms-open pose. Superseded movie cleanup was applied only after the final4K replacement passed checks; source and QA are retained.

The user explicitly requested an edit with Godot allowed only for character material. `picture_timeline.json` is the current picture decision list. `sound_timeline.json` is the selected final narration/music assembly. `narration.txt` transcribes that assembly; old episode scene/script files describe the rejected route and are not the current compositor input.

The external compositor is `tools/edits/storytime_message_edit.py`: background → giant red serif behind the head → canonical character alpha/real foreground hands → opening caption. It builds purposeful close-up and prop inserts, one short source-like dissolve, a quiet uncaptained payoff and solid black at22.1s. Godot supplies transparent character plates only. Existing rigs/libraries are unchanged.

Canonical voice: Aiden, unchanged model and base identity paragraph. Separate performance direction asks for amused swagger and a dry closing line. Selected B-take thoughts plus the shortened D challenge remain at tempo1.00. Source WAVs, request metadata and final timing are preserved in `../voice/edit_r8/`. Four coherent whole takes were generated rather than disconnected word fragments. The reference-derived hybrid music bed preserves the source musical windows/dropouts; it is an estimated separation, not original multitrack audio.

Render with `.venv/bin/python tools/edits/storytime_message_edit.py --author adb --output adb/episodes/ep08_message_to_storytime_animators/renders/ADB_Message_EDIT_R10_1080p.mp4 --stills` from the repository root. Use a fresh revision path; overwrite is refused. Keep existing local plates/background/mix. Source-only capture backup and background provenance live in `docs/animation/reference_studies/message_to_storytime_animators/`.

Full source/input/movie hashes: `../review/edit_r8/render_records/ADB_Message_EDIT_R9_1080p.json`. Decoded checks: `../review/edit_r8/FINAL_R9_CHECKS.json`. Visual evidence: `../review/edit_r8/full_r9_decoded/`. Audio evidence: `../review/edit_r8/audio/r9_FINAL_MUX_AUDIO_QA.json`. The `edit_r8` folder name identifies this rebuild and includes R9 evidence.

No perceptual listening/emotional-quality certification is asserted by ASR, waveform matching, or sampled images. The user approved the current complete1080p edit and requested4K. The actual approval and exact R9 input hashes are recorded under `../review/edit_4k/`; no Godot final-movie receipt is asserted.

## Approved4K completion

Final movie: `../renders/ADB_Message_EDIT_R13_4K_FINAL.mp4`. See `../review/RENDERS.md`, `../review/edit_4k/render_records/FINAL_4K_CHECKS.json` and `../review/edit_4k/CLEANUP_FINAL_4K.json`. The approved picture decision list and sound assembly remain unchanged. Native character capture source/anchors/manifest are backed up under `tools/edits/message_assets_4k/`.

A fresh4K export uses `.venv/bin/python tools/edits/storytime_message_edit.py --author adb --4k --output adb/episodes/ep08_message_to_storytime_animators/renders/ADB_Message_EDIT_R14_4K_FINAL.mp4`. Use a new filename. After documented cleanup, the compositor verifies the exact approved AAC archive and successful cleanup receipt before allowing that archive as the audio source. Keep local canonical character plates/background assets; generated media is excluded from Git.
