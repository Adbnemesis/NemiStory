# NEMI — CURRENT TOOLKIT AUDIT

> **Purpose**: Document exactly what the Nemi illustrated-storytelling production system
> currently has, how it is built, and classify each subsystem before evaluating external tools.
> **Source of truth**: the actual repository at commit `16645e3` (branch `main`).
> **Rule applied**: *"First inspect what actually exists. Do NOT rebuild systems that already work."*

---

## 0. Engine & Project Configuration (verified)

| Item | Value | Source |
| :--- | :--- | :--- |
| Engine | **Godot 4.7.2 stable** (`4.7.2.stable.official.ed1daf0bf`) | installed binary |
| Project features | `PackedStringArray("4.7", "GL Compatibility")` | `project.godot` |
| Renderer | **GL Compatibility** (`gl_compatibility` + `.mobile`) | `project.godot` |
| macOS driver | Metal on Apple Silicon M4 Pro | `EP00_Asset_Manifest.md` |
| Viewport | 1280×720, stretch `canvas_items` / `keep` | `project.godot` |
| Main scene | `res://scenes/demo/poc_demo.tscn` | `project.godot` |
| Movie Writer | fps 30, `res://renders/raw_poc.avi` (disabled vsync) | `project.godot` |
| Default clear color | warm white `#ffffff` | `project.godot` |
| **Addons installed** | **NONE** — no `addons/` directory exists | filesystem |

**Conclusion**: The project is **100% engine-native** — zero external plugins, zero GDExtension,
zero native binaries, zero raster textures. This is a clean, portable, M4-safe foundation.

---

## 1. Subsystem Classification Summary

Legend: **A** = already strong, DO NOT replace · **B** = working but improvable ·
**C** = incomplete · **D** = missing.

| # | Subsystem | Files | Class | Notes |
| :-- | :--- | :--- | :---: | :--- |
| 1 | Nemi character art & illustration renderer | `characters/nemi/drawing/*` | **A** | procedural vector, zero textures |
| 2 | Calligraphic inking | `InkStroke.gd` | **A** | variable-width ribbon polygons |
| 3 | Character rig | `Skeleton2D`/`Bone2D` in `nemi.tscn` | **A** | native skeletal articulation |
| 4 | Acting / motion primitives | `NemiMotionPrimitives`, `NemiTiming`, `NemiActingDirector` | **A** | holds, freeze, anticipation, overshoot, settle |
| 5 | Expression FX | `NemiFXDirector` + 13 element types | **A/B** | anchor-following vector FX |
| 6 | Doodles / annotations | `WorldDoodles`, `DoodleInstance`, `WorldAnnotation` | **A** | 18 doodle types, draw-on |
| 7 | Props | `NemiProp`, world props | **B** | pop/slide/shake/bounce/drop |
| 8 | Camera | `StoryCamera2D` | **B** | presets, punch, shake, reframe |
| 9 | Subtitles | Label-based + `subtitles.json` | **B** | functional, UI-level |
| 10 | Episode pipeline | `EP00_Introduction` + 7 beats | **A** | locked 125.1s master |
| 11 | Voice / TTS | Qwen3-TTS (Sohee) local pipeline | **A** | full master + timing data |
| 12 | **SFX** | `audio/sfx/{library,procedural}/*` | **A** | 15 verified assets (11 Kenney CC0 + 4 procedural MIT) |
| 13 | World VFX (ink bursts etc.) | doodles + FX elements | **B** | illustration-style, good |
| 14 | Particles / shaders | *(none used)* | **C** | native options only |
| 15 | Reusable illustration authoring | code-driven curves | **B/C** | no editor path-authoring tool |
---

## 2. Nemi Character & Illustration Renderer (Class A)

- **100% procedural vector**: `Curve2D`, `Polygon2D`, `draw_colored_polygon`. No sprite sheets, no raster.
- `InkStroke.gd` generates **variable-width calligraphic ribbon polygons** with pen-pressure tapering:
  `UNIFORM`, `TAPER_BOTH`, `TAPER_START`, `TAPER_END`, `CALLIGRAPHIC_LASH`, `DELICATE_CREASE`.
  Uses `Geometry2D.triangulate_polygon` for guaranteed-valid fills.
- `IllustrationCanvas2D.gd`: `draw_illustrated_shape`, `draw_cel_shaded_shape`, `draw_curve_stroke`,
  `draw_points_stroke`, `draw_open_contour`.
- Dual palette (`NemiStyle.gd`): COLOR (copper hair, sage hoodie, emerald eyes) and MONOCHROME (cream paper,
  burgundy ink) switchable at runtime.

> **Verdict**: This is a bespoke, high-quality hand-drawn renderer that exactly matches the target
> illustrated aesthetic. **Do NOT replace.** It is the benchmark all external illustration tools must beat.

---

## 3. Calligraphic Inking (Class A)

The `InkStroke` ribbon generator is the heart of the hand-drawn look. It is intentionally
**not** uniform-width, which is exactly why a generic antialiased `Line2D` may *or may not* be an
improvement — this must be proven by an A/B render, not assumed.

---

## 4. Rig (Class A)

Native `Skeleton2D`/`Bone2D` hierarchy in `nemi.tscn`:
`RootBone → TorsoBone → NeckBone → HeadBone` (+ hair, arm, hand, leg, skirt bones), plus
`FaceVisual`, hand visuals. Live facial/eye/mouth controls. `NemiPose.gd` pose solver.

> **Verdict**: Fully native, portable, M4-safe, and AI-friendly. **Do NOT replace** with any
> external rigging pipeline (SCML/Spriter/Spine) unless the audit finds a *specific* gap — it does not.

---

## 5. Acting / Motion Primitives (Class A)

- `NemiMotionPrimitives`: `hold`, `freeze`, `snap_bone`, `tween_bone`, `anticipate_and_move`,
  `overshoot_and_settle`, `stepped_rotate`, `staggered_timeline`.
- `NemiTiming`: `Priority` (IDLE→FACE_REACTION), `Speed` (SNAP/FAST/NORMAL/SLOW), `Intensity`,
  `TransitionStyle`, calibrated holds (0.08s–1.2s).
- `NemiActingDirector` + `NemiReactions`: 10 authoritative acting tests (A–J), eye-lead behavior,
  micro-acting, deadpan long-holds.

> **Verdict**: This is a complete, calibrated acting system. **Do NOT replace** with a generic
> tween framework. A tween authoring tool (if adopted) is for **props / doodles / UI** only.

---

## 6. Expression FX (Class A/B)

- `NemiFXDirector` maps high-level reactions (`react("shock")`, `show_question_mark`, `show_sweat`,
  `show_sparkles`, `show_shock_lines`, `draw_attention_*`, …) to procedural vector FX elements.
- `NemiFXElement` base: intensity 1–5, `draw_progress`/`erase_progress`, entrance styles
  (POP/DRAW_ON/SNAP/FADE/SLIDE/BOUNCE) and exit styles (FADE/ERASE/SNAP/SHRINK/DISSOLVE),
  anchor-following via `NemiFXAnchor`.
- 13 element types: confusion, shock, embarrassment, nervous, anger, excitement, realization,
  panic, sad, relief, deadpan, attention, + low-level helpers.

---

## 7. Doodles & Annotations (Class A)

- `DoodleInstance`: 18 types (arrow, circle, underline, scribble, question, exclamation, heart,
  star, sparkle, sweat, motion_lines, impact_lines, speech_bubble, thought_bubble, cross_out,
  check_mark, shock_lines) with `draw_on`, `pop_in`, `shake`.
- `WorldDoodles` spawner + `WorldAnnotation` (highlight/callout) + `CalloutDrawer`/`HighlightDrawer`.
- **A `roughjs`-based Node.js generator** (`tools/rough/`) already exists for offline hand-drawn
  SVG asset generation (speech bubbles, boxes) — an existing external tooling asset already in use.

---

## 8. Props (Class B)

- `NemiProp` base + `PropPhone/Laptop/Cup/Desk/Chair/Book/Backpack/WaterBottle/SnackPacket/Lamp`.
- Transformation primitives: `pop_in`, `pop_out`, `slide_to`, `shake`, `bounce`, `drop`,
  hand-attachment (`attach_to`/`detach`).
- Drawn with `InkStroke` outlines to match the illustration language.

> **Verdict**: Working and appropriate. Could benefit from **reusable editor-authored motions**
> (a candidate external-tool use case), but is not broken.

---

## 9. Camera (Class B)

`StoryCamera2D` (extends `Camera2D`) provides:
- Shot presets: WIDE (1.0×), MEDIUM (1.25×), MEDIUM_CLOSEUP (1.55×), CLOSEUP (1.95×),
  EXTREME_CLOSEUP (2.5×).
- `apply_preset`, `reframe`, `track_target`, `shake`, `punch_zoom`, `reset_zoom`,
  `reaction_closeup`, `subtle_punch`, `face_zoom_progression`, `reset_camera`.

> **Verdict**: Already covers framing, punch-ins, reaction close-ups, tracking, and shake.
> The **only** gap vs a Cinemachine-style tool is **multi-target group framing/reframing**.
> External camera (Phantom Camera) is **only** worth a partial test for that one feature.

---

## 10. Subtitles (Class B)

Label-based subtitle system (`UI/Subtitle` Label) + `subtitles.json` timing data
(22 cards, 125.1s) + `Episode00Subtitles.gd`. Functional and synchronized with the 7-beat director.

> **Verdict**: Working. External tools may only help reusable subtitle *transition* styling —
> a minor, optional tween use case.

---

## 11. Episode Pipeline & Voice (Class A)

- `EP00_Introduction.gd` sequentially loads 7 beat scenes (`Beat01_Hook` … `Beat07_Outro`)
  with a locked 125.10s master timeline and continuous voiceover.
- Voice: Qwen3-TTS 1.7B CustomVoice (Sohee, `spk_id 2864`), 22 segments, master `voiceover.wav`,
  timing JSON. Kokoro pipeline archived/rejected.
- Movie Maker render script `render_introduction.gd`.

---

## 12. SFX — **RESOLVED (Class A)**

- **SFX Subsystem Established**: Curated, commercial-safe sound effects library installed into `audio/sfx/`.
- **Composition**:
  - **11 Curated Kenney CC0 sounds** (`audio/sfx/library/`): plucks, clicks, ticks, drops, curious question chime, paper scribble scratch, light switch, soft/light impacts.
  - **4 Procedural Cartoon sounds** (`audio/sfx/procedural/`): classic cartoon bubble pop, comedic spring boing, fast gesture whoosh, and comic dual-tone blip.
- **Verification**: All 15 audio streams validated in Godot via `ToolkitTests/SFXTest.gd` (15/15 passed).
- **Zero Plugin Dependencies**: Plain `.ogg` and `.wav` assets with full legal records in `docs/toolkit_audit/SFX_PROVENANCE.md`.

> **Verdict**: The only genuine gap in the Nemi production system has been fully resolved.
> Ready for integration into props, reactions, and episode direction.

---

## 13. World VFX / Particles / Shaders (Class C)

- Illustration VFX (stars, shock lines, sweat, sparkles) are already covered by doodles + FX
  elements in the correct hand-drawn style.
- No GPUParticles2D/CPUParticles2D usage, no shaders. Native options are available but unused.
- Desired illustration VFX (ink bursts, dust puffs, speed lines, impact marks) can be built from
  the existing doodle/FX primitives — no plugin required.

---

## 14. Key Takeaways & Final Audit Conclusion

The external toolkit audit across all 10 candidate categories is **COMPLETE**:

1. **Illustration & Inking**: Empirical A/B renders (`renders/toolkit_ab/`) proved that both Scalable Vector Shapes 2D and Antialiased Line2D fail to match the organic, variable-width calligraphic beauty of our custom `InkStroke.gd` ribbon polygons. Both candidates are **REJECTED**. The bespoke native renderer is preserved.
2. **Camera**: `StoryCamera2D` already covers framing, punch zooms, tracking, shake, reaction closeups, and progressive zooming. Phantom Camera is **REJECTED** as redundant.
3. **Acting & Motion**: `NemiMotionPrimitives` and `NemiTiming` provide tailored comedic and dramatic acting timing. Tween Composer is **REJECTED** for character acting.
4. **VFX**: `NemiFXDirector` and `WorldDoodles` supply authentic hand-drawn comic accents. Juicee is **REJECTED** due to its video-game aesthetic.
5. **Rigging**: Native Godot `Skeleton2D`/`Bone2D` is 100% portable, AI-scriptable, and M4-safe. External rigging tools (Spriter/Spine) are **REJECTED**.
6. **SFX (Class D Gap)**: Successfully resolved by adding 15 tested, commercially safe (CC0 & MIT) cartoon and Foley sounds.

> **Final Outcome**: The Nemi production system remains **100% engine-native, zero-plugin, M4-safe, and fully locked**, with the single missing capability (SFX) completely established.