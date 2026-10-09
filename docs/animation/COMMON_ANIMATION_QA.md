# Common Animation QA Standards
## Verification Audit Checklist: Visual, Motion, Audio, and Anti-Artificiality Gates

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Mandatory QA Gate for all storytime renders (Nemi, ADB, and future productions)  
**Location**: `docs/animation/COMMON_ANIMATION_QA.md`

---

## 1. Overview of Quality Gates

No storytime episode or character test may be approved for final release without passing all four quality gates:

```
┌────────────────────────────────────────────────────────┐
│                   THE FOUR QA GATES                    │
├────────────────────┬───────────────────────────────────┤
│ GATE 1: VISUAL     │ Physics, depth, clipping, inking  │
│ GATE 2: MOTION     │ Weight, anticipation, holds, acting│
│ GATE 3: AUDIO      │ Voice sync, <= 5 words, no BGM    │
│ GATE 4: ARTIFICIAL │ Zero repeated stock, zero templates│
└────────────────────┴───────────────────────────────────┘
```

---

## 2. Gate 1: Visual Inspection & Physics

- [ ] **Surface Contact & Grounding**: Are character feet, chair legs, and desk items firmly grounded on floor/desk baselines? (Zero hovering elements).
- [ ] **Zero Clipping & Intersection**: Do arms, clothing folds, hair strands, and held props overlap with correct anatomical and physical z-ordering? (Zero impossible limb intersections).
- [ ] **Depth Stacking**: Does the 10-layer depth hierarchy hold? (Character hands over props, props over desks, desks over chair seats, etc.).
- [ ] **Organic Hand-Drawn Inking**: Does linework preserve the author-specific contour/mark language and the current [episode colour theme](STORYTIME_EPISODE_COLOUR_THEME.md), with readable ink, natural taper and subtle asymmetry?
- [ ] **Doodle Quality**: Are circles, arrows, and stars individually drawn? (Zero stock SVG icons or noisy vector jitter filters).
- [ ] **Handwriting Quality**: Does on-screen text appear handwritten into the sketchbook? (Zero dialogue UI boxes or corporate callout badges).
- [ ] **Background Continuity**: Do background horizons, perspectives, and environmental props remain consistent across camera reframes?
- [ ] **Simple Recognizable Settings**: Does the background still establish a place with grounded scenery while leaving the current thought readable?

---

## 3. Gate 2: Motion, Acting & Timing

- [ ] **Body Acting Participation**: Does the entire body react to emotional shifts, including torso tilt, shoulder elevation, and weight shift? (Not just mouth flapping + single arm tween).
- [ ] **Anticipation & Follow-Through**: Do major gestures have brief anticipation lead time (`0.08s`–`0.15s`) before the spoken syllable, and subtle settling upon arrival?
- [ ] **Comedic Holds**: Do punchlines and deadpan reactions lock into absolute 0-velocity holds (`0.4s` to `1.5s`) without procedural jitter or float?
- [ ] **Asymmetry**: Does the pose exhibit natural human asymmetry? (Uneven shoulder line, one dominant acting arm, weight on one hip).
- [ ] **Micro-Events**: Are natural blinks, eye darts, and subtle head tilts integrated organically throughout conversational passages?
- [ ] **Accepted Visual Balance**: Do thought-specific expressions, poses, props, held/live doodles, camera and finite VFX develop sequentially throughout the episode, with one focus at a time and deliberate emotional stillness? Review both sparse stretches and competing simultaneous actions; cue counts are not quotas. Use [EP11's accepted balance guidance](STORYTIME_REFINEMENT_WORKFLOW.md).

---

## 4. Gate 3: Audio, Voice & Subtitles

- [ ] **Voice Dominance**: Is narration clearly audible in the exported mix, with encoded peak/headroom checks from the current [refinement workflow](STORYTIME_REFINEMENT_WORKFLOW.md)? Numerical levels do not replace listening.
- [ ] **Lip-Sync Precision**: Do mouth shapes match spoken vowels and consonants with zero drift across the entire episode?
- [ ] **Subtitle <= 5 Words Rule**: Does EVERY subtitle card contain 5 or fewer words? (Strict rejection if any card has 6+ words).
- [ ] **Subtitle Clean Removal**: Do subtitles clear immediately during natural spoken pauses $\ge 0.35s$?
- [ ] **SFX Restraint**: Are sound effects short, crisp, event-driven, and mixed cleanly below the voice?
- [ ] **SFX Presence**: Are chosen prop, drawing and reaction accents actually audible in the export, with intentional silence where the emotion needs space?
- [ ] **Conversational Pace**: Have slow phrases and prolonged non-emotional gaps been reviewed against the final audio while preserving the approved voice identity, emotional breaths and meaningful holds? Nemi may use phrase-specific pitch-preserving tempo and selected source-bound pause edits; rebuild dependent word, mouth, caption, acting, camera, ink and sound timing after changes.
- [ ] **Strict BGM Policy**: Is background music OFF by default? (Zero continuous music tracks filling comedic silence).

---

## 5. Gate 4: Artificiality & Anti-Slop Check

- [ ] **No Repeated Stock Poses**: Does the scene avoid mechanical cycling through a fixed loop of 2–3 generic poses?
- [ ] **No Repetitive Doodles**: Are doodle assets customized to the specific humorous beat rather than identical copy-pastes?
- [ ] **No VTuber Idling**: Is the character free from continuous procedural breathing sway or bobbing?
- [ ] **Authored Character Identity**: Does the character look and act like an authentic human storyteller rather than an avatar?

## Executable direction checks

Use `tools/storytime/test_production_validator.py` and `tools/storytime/test_production.gd` for new scene contracts, foot contact, grip alignment, seekable cuts, and mixed held/live artwork. Follow the [direction workflow](STORYTIME_DIRECTION_WORKFLOW.md) and record whether playback/audio checks were actually performed.
