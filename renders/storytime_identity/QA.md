# Character identity proof — 2026-10-01

New scene: `common/storytime/examples/two_authors_10s.json`.
Render: `Two_Drawing_Hands_10s.mp4`, H.264, 1920×1080, 30 FPS, 300 frames, exactly 10.000 seconds. Silent by design. This does not update any episode master.

Passed:
- Engine parse/load and all 16 external acting recipes.
- Distinct Nemi/ADB lettering; repeatable authored paths and all seven mark types per author.
- Backward seeking restores acting/drawing state, stable holds survive process frames, manual mouth intervals restore expression mouths when seeking outside them.
- Valid scene plus nine rejected authoring mistakes: unknown author/glyph/recipe, invalid duration, overlapping transition, misplaced blink, other character's mouth name, long caption, misspelled field.
- Inspected sampled rendered sequence in `contact_sheet.png` and full-resolution `final_frame.png`: readable notes, separate pen personalities, progressive line reveal, corrections, gesture changes, no artwork clipped by frame. Automated hold checks supplement these still inspections; no claim of full subjective playback QA or recorded-speech alignment.
- Hash checks: all 149 original protected rig files unchanged; all 909 files in the current pass's protected rig/episode baseline unchanged. That latter baseline was captured after reversing the two precisely reversible earlier integration edits. Earlier doodle adapter edits remain, as recorded in the guide.

Limits: this is a comparison layout, not a complete new episode. No narration/SFX are synthesized here. Optional imported voice playback and export muxing are implemented; real-voice lip alignment still requires manual cue authoring and listening review. Standing performance recipes reuse existing rig poses; new walking/contact choreography requires a separately authored sequence.

Reproduce with the validator, engine test, and renderer commands in `docs/animation/CHARACTER_DRAWING_PRODUCTION_KIT.md`. All future model work starts through root `AGENTS.md` and that guide.
