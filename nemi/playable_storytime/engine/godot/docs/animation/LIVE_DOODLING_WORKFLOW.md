> For new scenes, start with [Character Drawing Production Kit](CHARACTER_DRAWING_PRODUCTION_KIT.md): separate Nemi/ADB profiles, acting recipes, validated scene specs, and a new ten-second proof. This page records the earlier shared-engine pass.

# Live doodling: implementation and authoring

The first implementation is available in `common/engine/illustration/`.
Nemi and ADB's protected character/rig implementations are unchanged.

## What is implemented

- `LiveInk.gd`: distance-based pen-tip reveal, per-stroke pen lifts and timing, curved paths, pressure evaluated against the complete stroke, stable holds, and safe rendering of crossing scribbles.
- `LiveDrawing.gd`: reusable illustration playback with absolute-time sampling, legacy reveal/play_draw adapters, optional fills, and independent exit control.
- `DrawnLettering.gd` and `common/assets/lettering/story_pen.json`: original uppercase/lowercase centerline alphabet, digits, punctuation, and selected authored alternate glyphs. Unsupported characters produce a visible question mark plus a warning. Celebration/bell emoji normalize to a drawn asterisk.
- `StoryMarks.gd`: authored arrow, circle with a pen-lift gap, underline, question/exclamation, star, check, bracket, scratch-out, notebook, and emphasis marks.
- `IllustrationTrack.gd`: seekable illustration cue track, driven by the caller's time source.
- `PropAttachment.gd`: external prop grip attachment that respects parent rotation and scale.
- Existing `CommonDoodle` and `CommonHandwriting` interfaces now use these renderers. Handwriting is actual stroke geometry rather than word-opacity animation.
- ADB EP00 and Nemi EP08 doodle players now share the renderer and lettering engine. Selected basic marks use the authored catalog. Legacy complex illustration geometry remains available.
- The initial table-tennis grip attachment and EP08 articulation-rate adjustment were reversed when the scope changed to new productions only. Existing EP00/EP08 doodle adapters remain from the earlier pass; missing original backups prevented an exact rollback.

## Preview

`renders/live_doodle/Live_Doodling_Proof.mp4` is a 1080p, 30 FPS proof:

1. 0–8 seconds: quiet live notebook, lettering, arrow, and scratch-out study.
2. 8–20.27 seconds: ADB confession excerpt, original recorded voice, new visual counterpoint.
3. 20.27–29.03 seconds: Nemi asking ADB excerpt, original recorded voice, successive drawn responses.

The first eight seconds are intentionally silent. The scene is `tools/LiveDoodleShowcase.tscn`; it is separate from existing episode masters. It uses the original rigs and existing mouth shapes. Articulation in this proof is illustrative cycling during subtitle intervals, not phoneme alignment.

## Authoring a drawing

A stroke is a dictionary:

```gdscript
{
    "pts": PackedVector2Array([Vector2(0, 0), Vector2(25, -8), Vector2(62, 5)]),
    "smooth": true,
    "w": 3.0,
    "col": Color("#49303a"),
    "pause": 0.06,
    "duration": 0.28,
    "pressure": PackedFloat32Array([0.5, 0.9, 1.0, 0.65, 0.3])
}
```

Use separate strokes for deliberate gaps and pen lifts. Keep corners unsmoothed where needed. Pressure values remain attached to the full path; previously drawn ink stays still. A drawing's requested overall reveal duration scales its stroke timings proportionally. Do not pack a sentence into a 0.2-second reveal unless an almost-instant appearance is intentional.

Call `prepare()` after editing stroke geometry, text, or fills. Progress changes redraw automatically. Use `sample(time, start, duration, end)` or an `IllustrationTrack` for deterministic playback. Existing `reveal`, `play_draw`, `dismiss`, and `auto_dismiss` remain available for episode callbacks. Exits default to cuts; pass a positive fade duration only when wanted.

## Directing and writing

Start from a spoken thought, then decide what the drawing contributes:

- **Evidence:** a tiny sketch that makes the claim believable.
- **Contradiction:** narration claims confidence; the drawn plan is visibly empty.
- **Aside:** a little note says what the narrator will not admit.
- **Revision:** a word is crossed out and replaced when the thought changes.
- **Silence:** let a finished drawing sit while the line lands.

Record/choose the voice before final cue timing. Give each illustration a start, drawing duration, and end relative to a word or pause. Subtitles can change without a new drawing. Sound should punctuate a meaningful action; do not add a whoosh or pop to every mark.

Review still artwork first, then watch its reveal, then watch the whole spoken beat. Hand-drawn appearance needs authored assets and composition as well as a stroke renderer.

## Verification and limits

Run `tools/tests/test_live_ink.gd` with Godot in headless mode. It covers short-line reveal, pen-lift gaps, backward seeking, reproducible lettering, both production adapters, prop grip transforms, and loading the touched episode scenes. The visual proof was rendered with the desktop graphics renderer.

This is the first shared foundation and integration pass, not a full re-authoring of all episodes. Other Nemi episodes still contain private renderers. Complex legacy shapes, existing episode reveal durations, scene composition, scripts, full audio alignment, and background art need individual editorial migration. `IllustrationTrack` coordinates drawings; it does not yet replace every episode's audio, subtitle, and camera clocks. Exact handwriting variants are currently provided for selected common lowercase letters; remaining glyphs use one authored form with stable placement variation.
