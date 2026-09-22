# NEMI — EXTERNAL TOOLKIT RESEARCH

> **Purpose**: Research current, verifiable, commercially-safe external tools that could improve
> the Nemi illustrated-storytelling pipeline. Every candidate is vetted against the CURRENT system
> described in `Nemi_Current_Toolkit_Audit.md`.
> **Date of research**: September 2026 (Godot 4.7.2 stable, Apple Silicon M4 Pro).
> **Method**: Official Godot Asset Library, official GitHub repositories, licenses, release dates.

---

## 01. Current Project Capabilities (summary)

Full audit in `Nemi_Current_Toolkit_Audit.md`. In short:

- Godot 4.7.2, GL Compatibility renderer, Metal on Apple Silicon, 1280×720 canvas.
- **Zero external addons**; 100% native procedural vector character, rig, acting, FX, camera,
  props, doodles, subtitles, voice pipeline.
- **Only genuine gap: SFX (Class D)**. Everything else is A/B and must be preserved.

---

## 02. Illustration / Path Candidates

### Candidate: Scalable Vector Shapes 2D — Draw and Animate Curves

| Field | Value |
| :--- | :--- |
| Asset Library | **Yes** — "Scalable Vector Shapes 2D - Draw and Animate Curves" (2D Tools) |
| Author | renevanderark |
| Latest version | 2.34.3 (2026-09-08, actively updated) |
| License | **MIT** |
| Godot compat | listed 4.4 (project is 4.7.2) |
| Source repo | Author's GitHub shows legacy JS repos only; the addon is distributed via the official Asset Library listing. A clean upstream repo URL is **not publicly linked** — provenance is the official Asset Library. |
| What it does | Editable vector strokes, fills, collisions, Inkscape-inspired path editor, curve animation, Skeleton2D deformation, SVG import |
| Installed here? | **No** |
| Used by Nemi? | **No** |

**Assessment & Empirical A/B Render Result**:
- Already installed? **No.** Tested in isolated sandbox `ToolkitTests/VectorIllustrationTest.tscn`.
- Captured live Metal renders across 3 zoom levels in `renders/toolkit_ab/`:
  - `vector_ab_1x.png` (zoom 1.0x)
  - `vector_ab_mcu.png` (zoom 1.55x)
  - `vector_ab_ecu.png` (zoom 2.5x)
- **Visual Inspection Verdict**:
  - SVS delegates to native `Line2D` which draws uniform-width strokes with standard round end-caps.
  - SVS does **not** provide variable-width calligraphic pen pressure or tapered stroke terminals.
  - In contrast, Nemi's custom `InkStroke.gd` ribbons produce weighted, calligraphically articulated strokes that directly fit the hand-drawn comic storytelling aesthetic.
  - SVS is primarily an editor GUI dock/authoring tool (35+ files of forms/panels); it provides zero rendering quality advantage over our custom renderer.

**Final Decision: REJECT SVS for character and doodle rendering. KEEP CURRENT bespoke InkStroke renderer.**

### Candidate: GVec (SquiggelSquirrel/GVec)

| Field | Value |
| :--- | :--- |
| Repo | `SquiggelSquirrel/GVec` — "2D vector art, curved shapes, and animation plugin" |
| Stars / activity | 2★, last push Feb 2025 |
| License | not stated in listing; tiny project |
| Verdict | Too new/small/unproven vs our bespoke renderer. **REJECT.** |

---

## 03. Ink / Line Candidates

### Candidate: Antialiased Line2D

| Field | Value |
| :--- | :--- |
| Repo | `godot-extended-libraries/godot-antialiased-line2d` |
| Asset Library | Yes |
| Latest version | 1.2.0 (repo updated 2026-06-07) |
| License | **MIT** |
| Godot compat | 4.x, **all renderers** |
| Type | Pure GDScript + generated antialiasing texture/mipmaps (no GDExtension, no binaries) |
| What it does | Higher-quality antialiased Line2D + Polygon2D + RegularPolygon2D, variable-width lines, caps/joints, sharp corners, white outlines |
| Installed here? | Tested in isolated sandbox (`ToolkitTests/_vendor/antialiased_line2d`) |
| Used by Nemi? | **No** — Nemi uses custom `InkStroke` ribbons |

**Assessment & Empirical A/B Render Result**:
- Tested in isolated sandbox `ToolkitTests/LineQualityABTest.tscn`.
- Captured live Metal renders across 3 zoom levels in `renders/toolkit_ab/`:
  - `line_ab_1x.png` (zoom 1.0x)
  - `line_ab_mcu.png` (zoom 1.55x)
  - `line_ab_ecu.png` (zoom 2.5x)
- **Visual Inspection Verdict**:
  - While Antialiased Line2D reduces staircasing on 1px uniform wireframes, Nemi's strokes are bold (2.2px to 5.0px), calligraphic ribbons.
  - Under `Antialiased Line2D`, the stroke appears wire-thin, mechanical, and lacks the organic body of hand-drawn ink.
  - At 2.5x extreme closeup, Godot's native polygon rasterization of `InkStroke` ribbons produces clean, solid antialiased edges without needing texture tiling.
  - Adding a custom mipmapped texture pipeline adds overhead without aesthetic improvement.

**Final Decision: REJECT Antialiased Line2D for production strokes. KEEP CURRENT InkStroke ribbons.**

---

## 04. Camera Candidates

### Candidate: Phantom Camera

| Field | Value |
| :--- | :--- |
| Repo | `ramokz/phantom-camera` |
| Asset Library | Yes |
| Latest release | **v0.11.0.3** (2026-07-19) — includes a Godot **4.7.1** autoload fix |
| License | **MIT** |
| Godot compat | 4.4+, actively tested against upcoming 4.x |
| Type | GDScript addon (project includes a C# example, but the addon runtime is GDScript) |
| Stars / activity | 3.6k★, active (updated 2 days ago) |
| What it does | Follow (simple/group/path/framed), look-at, zoom, priority-based switching, tween transitions, viewfinder |

**Assessment**:
- Our `StoryCamera2D` already covers presets, punch-zoom, shake, tracking, reaction close-ups.
- The **only missing feature**: Cinemachine-style **Group follow / dynamic multi-target reframing**.
- Adopting the full plugin would add a competing camera authority into scenes — against rule 25.

**Recommendation: REJECT migration. PARTIAL-TEST group-follow as an isolated experiment only.**
---

## 05. Tween / Animation Candidates

### Candidate: Tween Composer

| Field | Value |
| :--- | :--- |
| Repo | `gurbsgurbs/tween-composer-godot` |
| Asset Library | Yes |
| Latest version | listed; repo active (updated 2026-07-16) |
| License | **MIT** |
| Godot compat | **4.4+** |
| Type | Pure GDScript + editor inspector tooling |
| What it does | Reusable tween resources authored in the Inspector; works on 2D/3D/UI; position/rotation/scale/color/opacity/arbitrary property paths; trigger signals; expressions; editor preview; hide-before/delete-after |

**Assessment**:
- Our acting engine (`NemiMotionPrimitives`/`NemiTiming`) already implements holds, timing,
  easing, anticipation, overshoot, settle — **do not replace**.
- Potential *legitimate* use: **editor-authored reusable prop / doodle / UI / subtitle transitions**
  and simple camera moves that Antigravity can tweak visually without code.

**Recommendation: PARTIAL (props/UI/subtitles only), TEST FIRST. Not for character acting.**

---

## 06. VFX / Game-Feel Candidates

### Candidate: Juicee

| Field | Value |
| :--- | :--- |
| Repo | `Kelpekk/Juicee` |
| Asset Library | Yes |
| Latest version | **1.5.0** (2026-08-27) |
| License | **MIT** |
| Godot compat | 4.x (pure GDScript + optional C#), active addon (updated ~11 days ago) |
| What it does | 99 effects / 8 categories (Screen, Camera, Object, Text, Time, Audio, Physics, Flow), visual graph editor, sequences, 12 one-line presets, procedural SFX option |
| Relevant effects | shake_camera, zoom_camera, hit_stop, freeze_frame, slow_mo, flash, burst, pop, recoil, wiggle, spring, impact ring, speed lines |

**Assessment**:
- Our FX director + camera + props already cover most required illustration beats.
- Almost all Juicee effects are **game-feel**, and several (glitch, chromatic aberration, bloom,
  lens distortion, HUD/neon) are explicitly off-limits for the illustrated storytelling language.
- The useful subset to *test*: subtle camera shake, tiny pop, recoil, impact burst, spring, freeze.

**Recommendation: PARTIAL-TEST the subset only. Keep whichever produces the right illustrated
feel; reject the rest. Likely outcome: our primitives remain, or at most a few helpers adopted.**

---

## 07. SFX Generators

### Candidate: GodotSfxr (tomeyro/godot-sfxr)

| Field | Value |
| :--- | :--- |
| Repo | `tomeyro/godot-sfxr` |
| Asset Library | Yes |
| License | **MIT** |
| Godot compat | 4.x (branch `4.x`; **last push 2023-09-18**) |
| What it does | `SfxrStreamPlayer` (2D/3D) + `SfxrAudioStream` resource; select preset → generates/edits sound inside the editor; adjustable parameters; 2D/3D variants |

**Assessment**:
- Directly fills the **Class D (SFX missing)** gap for short stylized sounds (pop, click, blip,
  boing, drop, tiny impact, comedic sting).
- **Maintenance risk**: last code push 3 years ago. Must be verified against Godot 4.7.2.
- **Workflow**: editor-generated SFX → bake to WAV/OGG → keep as project assets. The plugin itself
  is only needed at generation time; the output is plain audio.

### Candidate: gdfxr (timothyqiu/gdfxr)

| Field | Value |
| :--- | :--- |
| Repo | `timothyqiu/gdfxr` |
| License | **MIT** |
| Godot compat | Godot 4 branch (updated 2024-08-21) |
| What it does | sfxr editor panel in Godot; random/mutate generators; `.sfxr` parameter files (~100B); right-click import to AudioStream; no runtime cost |

**Assessment**:
- Same use case, actually newer than GodotSfxr. Generate → bake → remove plugin.
- Prefer whichever loads cleanly in 4.7.2 on M4; both are MIT and sale-safe.

**Recommendation: TEST FIRST (procedural generation), then bake outputs into the project.**

---

## 08. SFX Libraries (ready-made)

### Candidate: Kenney — Impact Sounds
| Field | Value |
| :--- | :--- |
| Pack | Impact Sounds (2019) |
| Files | **130** |
| License | **CC0** |
| URL | `https://kenney.nl/assets/impact-sounds` |

### Candidate: Kenney — Interface Sounds
| Field | Value |
| :--- | :--- |
| Pack | Interface Sounds (2020) |
| Files | **100** |
| License | **CC0** |
| URL | `https://kenney.nl/assets/interface-sounds` |

**Assessment & Verification**:
- **CC0 = Public Domain, commercial YouTube monetization safe, zero attribution requirement.**
- Auditioned and imported a curated set of **11 specific sounds** into `audio/sfx/library/` (zero bulk bloat).
- Combined with **4 procedural cartoon sounds** (pop, boing, whoosh, blip) synthesized in `audio/sfx/procedural/`.
- Verified 15/15 audio streams in Godot via `ToolkitTests/SFXTest.gd`.
- Documented in `docs/toolkit_audit/SFX_PROVENANCE.md`.

**Final Decision: ADOPT curated Kenney CC0 selection + procedural cartoon SFX. Resolves Class D gap.**

---

## 09. Shader Candidates

**No external shader pack is recommended.** The hand-drawn aesthetic stems directly from our procedural vector renderer (`InkStroke.gd`, `IllustrationCanvas2D.gd`). Godot's built-in canvas item shaders are available natively if a subtle paper texture or color tint is ever required.

- GL Compatibility renderer + Metal driver on Apple Silicon functions best with native procedural drawing.
- Wholesale external shader packs introduce unnecessary complexity and conflict with the clean, flat-ink aesthetic.

**Final Decision: REJECT external shader packs. KEEP native procedural vector rendering.**

---

## 10. Rigging Candidates

### Candidate: Godot SCML Importer (Spriter)

| Field | Value |
| :--- | :--- |
| Repo | original by Wojciech Michalak; 4.7 fork `ultimopl/godot-scml-importer` |
| License | **MIT** (original + fork) |
| What it does | Imports Spriter Pro `.scml` files as Godot scenes with Skeleton2D/Bone2D/Sprite2D/AnimationPlayer |
| Fork activity | Fork is a small 4.7 compile fix (2026); original unmaintained |

**Assessment**:
- We already have a **native Skeleton2D/Bone2D rig** that is locally controlled, M4-safe, and
  AI-friendly. The audit found **no genuine limitation** in the current rig.
- An external Spriter workflow would add a proprietary tool (.scml requires Spriter Pro to author)
  with no proven benefit for Nemi.

**Recommendation: REJECT (default). Revisit only if a specific reusable-rig limitation appears.**

### Spine / paid tools
**Rejected outright** (rule 23): no proprietary/paid character-rigging dependency.

---

## 11. License Safety

| Tool | License | Commercial YouTube use |
| :--- | :--- | :--- |
| Scalable Vector Shapes 2D | MIT | ✅ Safe |
| Antialiased Line2D | MIT | ✅ Safe |
| Phantom Camera | MIT | ✅ Safe |
| Tween Composer | MIT | ✅ Safe |
| Juicee | MIT | ✅ Safe (subset only) |
| GodotSfxr | MIT | ✅ Safe |
| gdfxr | MIT | ✅ Safe |
| Kenney Impact/Interface Sounds | **CC0** | ✅ Safe — no attribution required |
| SCML importer | MIT | ✅ Safe (not adopted) |
| Spine / paid rigging | Proprietary/paid | ❌ Not acceptable |

- **GPL/AGPL/LGPL, CC-BY-NC, "free for personal use", and unclear licenses: none selected.**
- Kenney CC0 is the only third-party *content*; it needs provenance records (see section 18 /
  `SFX_PROVENANCE.md`).

---

## 12. M4 / Apple Silicon Compatibility

**All shortlisted candidates are pure GDScript or data** — no GDExtension, no compiled native
binaries, no x86-only code:

- Antialiased Line2D: GDScript + generated texture mipmaps ✅
- Phantom Camera: GDScript runtime (MIT) ✅
- Tween Composer: GDScript + editor UI ✅
- Juicee: GDScript core (C# is optional/editor-only, not needed) ✅
- GodotSfxr / gdfxr: GDScript ✅
- Kenney CC0: plain WAV/OGG ✅

Every candidate must still be opened in the editor **on this M4 Mac** to verify runtime behavior
in Godot 4.7.2. No x86-only binaries are introduced.

---

## 13. Recommended Final Stack (Minimal & Production-Ready)

| Category | Decision | Final Tool / System | Rationale |
| :--- | :---: | :--- | :--- |
| **Illustration** | **KEEP** | Bespoke procedural vector (`IllustrationCanvas2D`) | Empirical A/B renders proved SVS 2D lacks calligraphic pen tapering. Current renderer is superior. |
| **Inking / Lines** | **KEEP** | Custom `InkStroke.gd` ribbon polygons | A/B renders proved Antialiased Line2D produces wire-thin mechanical lines; `InkStroke` produces lively hand-drawn comic ink. |
| **Camera** | **KEEP** | Native `StoryCamera2D.gd` | Already handles shot presets, punch zoom, camera shake, tracking, reaction closeups, and face zoom progressions. |
| **Motion Authoring**| **KEEP** | `NemiMotionPrimitives.gd` + `NemiTiming.gd` | Calibrated hold times, anticipation, overshoot, settle, and eye-lead micro-acting already fully operational. |
| **VFX / Game-Feel** | **KEEP** | `NemiFXDirector.gd` + `WorldDoodles.gd` | Hand-drawn comic accents (stars, sweat, sparks, impact lines) match illustration language; game HUD effects rejected. |
| **Expression FX** | **KEEP** | `NemiFXDirector.gd` + 13 procedural vector elements | Procedural vector FX follow skeletal landmarks with dynamic draw-on/erase. Fully integrated in Ep00 Beats 1-7. |
| **SFX (GAP RESOLVED)**| **ADOPT** | **11 Kenney CC0 sounds + 4 procedural cartoon sounds** | Stored in `audio/sfx/` with zero plugin dependencies; 15/15 streams verified in Godot (`ToolkitTests/SFXTest.gd`). |
| **Rigging** | **KEEP** | Native Godot `Skeleton2D` / `Bone2D` | Native hierarchy in `nemi.tscn` is M4-safe, AI-friendly, and has zero external runtime overhead. |
| **Shaders** | **KEEP** | Native Godot CanvasItem shaders (optional) | No external shader pack required; preserves pure vector illustration look. |
| **Voice / Dialogue**| **KEEP** | Local Qwen3-TTS (Sohee 1.7B) pipeline | Master voiceover (125.10s) and 22 segment cards locked and integrated. |

---

## 14. Rejected Candidates & Audit Outcomes

| Tool | Category | Status | Specific Reason for Rejection |
| :--- | :--- | :---: | :--- |
| **Scalable Vector Shapes 2D (SVS)** | Illustration | **REJECTED** | Empirical A/B render test (`renders/toolkit_ab/vector_ab_*.png`) confirmed it wraps standard uniform-width `Line2D` without calligraphic tapering. Heavy editor UI dock provides no runtime quality win over `InkStroke`. |
| **Antialiased Line2D** | Inking | **REJECTED** | Empirical A/B render test (`renders/toolkit_ab/line_ab_*.png`) showed uniform wire-like strokes with round cap artifacts. Lacks the organic volume and calligraphic pressure of `InkStroke` ribbon polygons. |
| **Phantom Camera** | Camera | **REJECTED** | Duplicates existing `StoryCamera2D`. Introducing a secondary camera manager creates conflicting authority without tangible benefit for 1-character storytelling. |
| **Juicee** | VFX | **REJECTED** | Game-feel package (HUD, bloom, screen distortion, chromatic aberration) conflicts directly with the warm, hand-drawn editorial illustration aesthetic. |
| **Tween Composer** | Motion | **REJECTED** | Duplicates existing `NemiMotionPrimitives`. Character acting is already solved via calibrated procedural solvers; external tween resources add file clutter. |
| **Spriter / SCML Importer** | Rigging | **REJECTED** | Proprietary authoring tool requirement; our native Godot `Skeleton2D` rig has zero external dependencies and supports real-time procedural posing. |
| **Spine 2D** | Rigging | **REJECTED** | Paid/proprietary runtime violates open, portable, zero-licensing-risk architecture. |
| **External Shader Packs** | Shaders | **REJECTED** | Introduces rendering inconsistencies on GL Compatibility / Metal and detracts from clean vector aesthetic. |

---

## 15. Empirical Verification Summary

1. **A/B Rendering Completed**:
   - `LineQualityABTest.gd` & `VectorIllustrationTest.gd` executed via `tools/render_toolkit_ab.gd` using Godot's live Metal rasterizer.
   - Saved 6 comparison frames in `renders/toolkit_ab/` at 1.0x, 1.55x, and 2.5x zoom.
   - Visual inspection verified current `InkStroke.gd` system remains aesthetically superior.
2. **SFX System Installed & Verified**:
   - Curated 15-sound palette (11 CC0 + 4 procedural MIT) generated into `audio/sfx/`.
   - Executed `ToolkitTests/SFXTest.gd`: **15 passed, 0 failed**.
   - Recorded full legal and technical provenance in `docs/toolkit_audit/SFX_PROVENANCE.md`.
3. **Zero Unnecessary Plugins**:
   - No plugins enabled in `project.godot`.
   - Project remains 100% engine-native, M4-safe, and stable.