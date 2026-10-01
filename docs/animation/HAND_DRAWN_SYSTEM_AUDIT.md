# Hand-drawn storytime system audit

Date: 2026-09-30

## Scope and preservation boundary

Improve the entire storytelling system: doodles, lettering, props, backgrounds, script direction, audio/visual timing, and episode integration. Preserve the existing Nemi and ADB rigs, geometry, proportions, face designs, and character assets. Build improvements outside those implementations, using existing interfaces where needed.

This is the original audit and proposed implementation sequence. The first implementation is now documented in [Live Doodling Workflow](LIVE_DOODLING_WORKFLOW.md); the full episode migration is still pending.

## Evidence reviewed

- Sampled frames extracted directly from both local Pegi reference videos in `references/`.
- Sampled frames from `ADB_INTRO_1080P_REVIEW.mp4`.
- Shared doodle, ink, handwriting, prop, camera, and timing code.
- ADB EP00 doodles, props, choreography, and timing manifests.
- Nemi EP08 doodles, choreography, subtitle integration, and script text.
- Existing reference analysis and production/style guides.

The older reference document's motion percentages and cut counts have not been independently reproduced. Sampled still frames support visual comparisons, not a complete assessment of motion or vocal delivery. Audio listening and continuous playback remain necessary before approving final timing and voice changes.

## What the references clarify

The reference frames show annotations composed for particular situations: small uneven marginal notes, arrows pointing to a specific detail, loosely drawn counters, scratch-outs, and occasional scene-specific visual jokes. Simple empty backgrounds let these marks read clearly. Text and drawings vary in size, density, and finish according to their role.

The target is an authored illustrated scene. A mathematically imperfect icon or a handwritten-looking font alone does not establish that quality. Reusable machinery is useful; repeatedly identical artwork and presentation make its reuse conspicuous.

## Concrete implementation gaps

| Area | Observed evidence | Consequence / proposed response |
| --- | --- | --- |
| Lettering | `Ep08Doodles.gd` renders its annotation texts with `ThemeDB.fallback_font`, despite its header claiming no system fonts. | Replace episode-specific rendering paths with an actual shared lettering service. |
| Letter shapes | `ADBIntroDoodles.gd` uses one uppercase polygonal template per supported character, with sine/cosine baseline and height offsets. Unsupported characters silently produce no strokes. | Add curved, authored glyph alternatives, lowercase, complete required punctuation, measured spacing, and explicit missing-glyph validation. Compose prominent phrases individually. |
| Shared handwriting | `CommonHandwriting.gd` arranges font labels by word and fades them in. It is not a pen-stroke renderer. | Separate instant lettering, word reveals, and actual handwriting into explicit modes. |
| Ink quality | ADB EP00 and Nemi EP08 render their own constant-width polylines instead of using `CommonInkStroke`. | Improve and adopt a shared stroke renderer; keep episode-specific artwork as asset data. |
| Shape construction | Shared and episode doodles include trigonometric ovals/spirals and short straight-segment paths. | Author contours for recognizable drawing character; use procedural construction only where its appearance suits the scene. |
| Reveal timing | Episode renderers divide progress equally among strokes, then reveal whole vertices by point count. Two-point strokes appear all at once. | Reveal by distance along the path with interpolated tips and per-stroke timing, pen lifts, and holds. Preserve authored pressure rather than recomputing the whole visible stroke's taper as it grows. |
| Shared animation updates | Shared doodle/handwriting tweens refresh drawing or visibility on `step_finished` and completion, without a per-frame progress setter/update. | Verify continuous progress in a focused preview and fix invalidation before migrating episodes. |
| Entrance/exit vocabulary | Episode doodles commonly share short ease-out draw-ons and timed fades. | Support intentional cuts, handwritten additions, replacements, scratch-outs, and small authored frame sequences. Choose per narrative purpose. |
| Prop integration | ADB table-tennis choreography assigns the paddle position at individual callbacks using character position plus local hand coordinates. | Use external attachments with correct coordinate conversion and authored grip offsets; verify contact across the movement and scale changes. |
| Synchronization | ADB EP00 uses accumulated delta time plus separate relative beat tweens. Nemi EP08 waits rounded 30 FPS frame counts per card. | Establish one explicit timeline with fixed-frame export evaluation and audio-aware preview timing. Schedule visual cues independently of subtitle boundaries. |
| Script direction | The script guide proposes a timed eight-beat structure; episode choreography repeatedly associates subtitle changes with visual events. | Treat structure as optional guidance. Write spoken thought and visual counterpoint together; avoid requiring a gesture or doodle for every card. |

These are findings from the inspected paths, not claims that every episode has identical problems.

## Proposed system

1. **Shared illustrated asset format:** authored paths, per-point pressure, stroke order, optional fills/hatching, anchor points, lettering placement, and deliberate alternate drawings. Assets stay stable during holds.
2. **Shared ink and lettering renderers:** curved paths, distance-based reveal, pen lifts, proper text bounds, complete glyph coverage, and authored phrase artwork for important moments.
3. **Presentation choices:** instant appearance, selective draw-on, staged annotation, scratch-out/replacement, or short stepped animation. Do not make every object draw itself or bounce into view.
4. **Prop/annotation relationships:** distinguish world objects, hand-held objects, and screen annotations. Support attachment, grip offset, layering, and endpoints that actually reach their subject.
5. **Story cue timeline:** attach cues to words, pauses, actions, and reactions; include lead/lag offsets. Coordinate drawings, camera, subtitles, voice, and SFX through the same timing source.
6. **Writing and directing workflow:** script -> spoken read -> visual counterpoint/storyboard -> timed cues -> preview -> editorial revision. Preserve each character's voice. Let some lines remain visually quiet.
7. **Episode migration:** route real production episodes through the shared services. Updating `common/` alone will not change episodes with private renderers.

## First implementation milestone

Build a shared style proof containing an arrow, circle, scratch-out, handwritten aside, emphasized phrase, hand-held prop, and a brief scene combining them. Include both quiet and energetic timing. Use the existing rigs unchanged.

Review the artwork as stills first, then the reveals, then a short voice-synchronized scene. Compare identical story/audio material before and after. Only then migrate one Nemi scene and one ADB scene to prove that the foundation is shared.

## Acceptance checks

- Every protected rig/character asset remains byte-for-byte unchanged.
- Repeated glyphs and marks have deliberately drawn alternatives, without continuous random jitter.
- Strokes reveal continuously where intended; short strokes do not accidentally pop because of vertex count.
- Lettering remains readable at final output size, with no silent missing characters.
- Held drawings remain stable; exits and replacements occur on intended cues.
- Props stay attached through position, rotation, and scale changes.
- Subtitles do not dictate every visual change; the image sometimes contributes information beyond the spoken line.
- Identical timeline inputs produce repeatable renders, including during seeking and frame-rate changes in supported preview modes.
- A visual comparison demonstrates improvement. Code comments and compliance labels are not evidence of aesthetic quality.
