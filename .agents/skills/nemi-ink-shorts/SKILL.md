---
name: nemi-ink-shorts
description: Create or improve solo Nemi music-led ink Shorts in Godot, with whole-body poses, expressive subtle acting, directed camera movement and verified music edits. Use for Nemi ink edits, reels or Shorts; excludes storytime episodes and thumbnails.
---

# Nemi ink Shorts

Direct **Nemi only**. Use observant curiosity, art/music excitement and self-aware overthinking, followed by a shy or deadpan realization. Let her eyes notice first and her head/hands answer; warmer gestures and soft page marks can contrast with one crisp comic snap. She has opinions and agency, rather than being a generic cute mascot. Premise text in her voice uses first person and avoids gendered self-descriptions. Use the approved long-hair ink silhouette, not older storytime design or hold rules.

The matched starting examples are [My song](../../../shorts/nemi/my-song/short.json) and [One quick doodle](../../../shorts/nemi/quick-doodle/short.json), with sibling `Edit.tscn` scenes. Read the closest example and its direction, then create a different visual sequence. If the user asks for both characters, switch to `$duo-ink-shorts`.

## Use the maintained motion-edit route

Work in the repository containing `shorts/godot/validate_ink.py`; the helper resolves its real repository path, or accepts `--repo /path/to/adb`. Read [Shorts rules](../../../shorts/AGENTS.md), [current workflow](../../../shorts/godot/V3_WORKFLOW.md), [schema](../../../shorts/godot/V3_SCHEMA.md) and [character direction](../../../shorts/godot/CHARACTER_DIRECTION.md). Before authoring, read the relevant supplied-reference motion analysis: [ref03 reaction/framing and join notes](../../../shorts/review/motion04/ref03/MOTION.md). Inspect its linked actual frames/video and record which observed device applies. Read another reference report when borrowing its different device. Do not infer unobserved internal acting from camera-transformed held art.

[Motion04](../../../shorts/review/motion04/index.html) is the current review target. The canonical example source/cue map is the editing entry; `review/current.json` and actual QA identify which exported revision passed. Revision03 is preserved interim pose work, not automatically a completed approved batch. Compare the matched example and relevant reference at phone size with sound before treating it as visual direction.

Godot draws every visual frame from separate editable Shorts vector art. Original episodes, character rigs/definitions, pose/face/hand libraries, voice recordings and settings stay protected. No imagegen, bitmap restyling, reference-video sprites, alternate player or narration by default. Storytime keeps its separate production route.

## Direct the thought, pose and continuing movement

Save `DIRECTION.md` first: readable promise/want, visible choice, consequence/reversal and payoff. List one audience focus per thought. Begin with a recognisable first-second situation/posture. Choose12–25s for the real visual/music phrase; stop after the useful payoff and remove repeated closing cards rather than padding to15s. Retention is an aim, not a guarantee from a pose count.

Plan supported whole-body pose/view/action cards, then give each a subtle ongoing eye lead, head/grounded torso response and meaningful settle. A new crop or hand shape is not another body pose. Show the principal silhouettes with grounded feet; use a face/prop/single crop only when attention changes and return wider when the payoff needs it. Keep supported fingers/props locked. No fake walking, pickup or exchange. If `pageArt` matters, author its continuity on every relevant sketch cue; a generic cat prop cannot truthfully stand for an unrevealed moon.

Direct `shot.camera` as a finite base push/pull/pan through that thought. Add a smaller short impulse only at a selected audible source attack. Use its actual screen focus and absolute-frame `factor`, `pan`, `roll`, `ease` keys from the schema; choose camera or legacy travel, not both. Inspect speed through joins and safe hands/feet/props across the entire path. Avoid copying one camera/acting recipe into every card. Stable completed ink means coherent world-space lines; the camera may move them on screen. Avoid random redraws, universal periodic bob, hand/sleeve loops or meaningless drift.

Use clean cuts where readable; named finite smear/whip/match/focus wipes can anticipate a selected accent and land the target drawing through `poseFrame`. A match needs actual framing/scale/focus contrast. Then let the camera and internal thought continue rather than leaving an idle card. Selected VFX emphasize focus without masking faces or grips; completed doodles stay fixed after drawing.

## Direct actual music and sound

Read [recording provenance](../../../shorts/assets/music/batch01/MUSIC_SOURCES.md), selected track metadata/analysis and [beat-direction evidence](../../../shorts/review/motion04/BEAT_DIRECTION.md) where useful. Audition the real chosen interval. Preserve artist/version/source URLs, raw/decoded hashes, preview-relative sourceStart, duration and gain. Keep source rate/pitch unchanged. A famous recording is not proof of a current trend rank; the user removed the copyright-selection gate.

Link pose arrivals, internal response and small camera impulses separately in `CUE_MAP.json`. Use meaningful source attacks/texture changes, not every spectral-flux peak. Low-band/body, bright/percussive and vocal/mixed attacks are not interchangeable confirmed downbeats or phrase labels. End audition verifies a proposed trim; source measurements alone cannot establish a lyric/tonal cadence or seamless loop. Use only exact recorded root/category SFX linked to named events, retaining hashes/attack trims. No synthesized replacements or meme vocal as new dialogue.

## Create, render and review

Canonical folder: `shorts/nemi/<short-slug>/`. Source/scene/direction/cue map at root; movies in `render/`; evidence/stills/logs in `review/`; optional unique assets in `assets/`. Shared art/engine lives in `shorts/godot/`, recordings in `shorts/assets/music/`. Start with the helper, then adapt the copied matched template before rendering:

```sh
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py new new-music-moment
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py validate shorts/nemi/new-music-moment/short.json
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py stills shorts/nemi/new-music-moment/short.json --revision r1
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py build shorts/nemi/new-music-moment/short.json --revision r1
```

The helper enforces cast/version/canonical layout and uses the maintained validator/renderer. Use an unused revision. Inspect fresh native settled poses, internal-action/contact samples, camera extrema/impulses and transition before/mid/end, plus real-speed motion; a still does not prove continuous feel. Fix cropped palms, slipping props, stage/contact mismatch, hidden thought or a dead between-pose slab before full export.

For an existing movie:

```sh
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py check shorts/nemi/new-music-moment/short.json --movie shorts/nemi/new-music-moment/render/new-music-moment_r1_1080x1920.mp4
```

Build/check independently verifies actual encoded picture, exact-source decoded music/SFX and static runs≤1.5s. It fails on missing/pacing/audio evidence; do not bypass errors. These tests do not rate creativity. Watch the entire exported clip with sound at phone size: hook, causal reversal/payoff, internal nuance, camera development/joins, real music alignment, SFX balance, correct ending duration and restart. Repair and rerender when it fails. Save only performed observations in `review/QA.md`, then select `review/current.json` and update the render index/gallery. Technical pass deliberately leaves playback/creative review pending.

For recuts, preserve prior source/review/movie before edits. Current history uses `review/source-r1/`, `review/r1/` and `review/source-motion03/`; earlier movies stay in `render/` until replacement QA. Source hashes belong to their actual revisions. For shared-engine/batch work, snapshot/compare protected storytime source/settings and record authorized skill/routing changes separately. Deliver checked playable media and editable source; generated media stays local. Publishing, external messaging and unrelated episodes require their own request.
