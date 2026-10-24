# Nemi — externally edited message promo

Current complete cut: `../renders/Nemi_Message_EDIT_R9_1080p.mp4`, 25.000s, 1920×1080,30fps. R9 removes four optional arm-settle frames so the7.6s insert cuts directly to the committed arms-open pose. The R8 external edit and earlier rejected Godot cuts remain preserved.

The user explicitly requested an edit with Godot allowed only for character material. `picture_timeline.json` is the current picture decision list. `sound_timeline.json` is the selected final narration/music assembly. `narration.txt` transcribes that assembly; old episode scene/script files describe the rejected route and are not the current compositor input.

The external compositor is `tools/edits/storytime_message_edit.py`: background → giant red serif behind the head → canonical character alpha/real foreground hands → opening caption. It builds purposeful close-up and prop inserts, one short source-like dissolve, a quiet uncaptained payoff and solid black at22.1s. Godot supplies transparent character plates only. Existing rigs/libraries are unchanged.

Canonical voice: Sohee, unchanged model and base identity paragraph. Separate performance direction asks for amused swagger and a dry closing line. Selected B-take thoughts plus the shortened D challenge remain at tempo1.00. Source WAVs, request metadata and final timing are preserved in `../audio/edit_r8/`. Four coherent whole takes were generated rather than disconnected word fragments. The reference-derived hybrid music bed preserves the source musical windows/dropouts; it is an estimated separation, not original multitrack audio.

Render with `.venv/bin/python tools/edits/storytime_message_edit.py --author nemi --output nemi/episodes/ep17_message_to_storytime_animators/renders/Nemi_Message_EDIT_R10_1080p.mp4 --stills` from the repository root. Use a fresh revision path; overwrite is refused. Keep existing local plates/background/mix. Source-only capture backup and background provenance live in `docs/animation/reference_studies/message_to_storytime_animators/`.

Full source/input/movie hashes: `../review/edit_r8/render_records/Nemi_Message_EDIT_R9_1080p.json`. Decoded checks: `../review/edit_r8/FINAL_R9_CHECKS.json`. Visual evidence: `../review/edit_r8/full_r9_decoded/`. Audio evidence: `../review/edit_r8/audio/r9_FINAL_MUX_AUDIO_QA.json`. The `edit_r8` folder name identifies this rebuild and includes R9 evidence.

No perceptual listening/emotional-quality certification is asserted by ASR, waveform matching, or sampled images. The current complete1080p edit is for user review. No explicit satisfaction or4K approval has been recorded.
