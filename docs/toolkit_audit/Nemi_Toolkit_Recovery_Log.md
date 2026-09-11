# NEMI — TOOLKIT RECOVERY LOG

> **Date**: September 10, 2026  
> **Environment**: Godot 4.7.2 stable (`4.7.2.stable.official.ed1daf0bf`), macOS Metal on Apple Silicon M4 Pro  
> **Target**: Nemi Illustrated YouTube Storytelling System (Repository: `/Users/talus/Documents/adb`)  

---

## 1. Previous Task Status

The previous task was **"NEMI PROJECT — EXTERNAL TOOLKIT / ASSET / PLUGIN AUDIT + SELECTIVE INTEGRATION"**.
Before interruption, the previous task had successfully completed:
- Complete research on all 10 candidate categories against the 15 existing subsystems.
- Authored `docs/toolkit_audit/Nemi_Current_Toolkit_Audit.md` (classification of subsystems A-D, identifying SFX as the sole Class D missing gap).
- Authored `docs/toolkit_audit/Nemi_External_Toolkit_Research.md` (detailed evaluation of SVS 2D, Antialiased Line2D, Phantom Camera, Tween Composer, Juicee, GodotSfxr, gdfxr, Kenney CC0, Spriter/Spine, shaders).
- Established `docs/toolkit_audit/SFX_PROVENANCE.md` legal/provenance framework.
- Downloaded and safely vendored candidates into isolated sandbox `ToolkitTests/_vendor/` (zero pollution of `addons/` or `project.godot`):
  - `ToolkitTests/_vendor/scalable_vector_shapes/`
  - `ToolkitTests/_vendor/antialiased_line2d/`
- Created support utilities (`BezierUtil.gd`, `StrokePainter.gd`).
- Authored isolated test scenes:
  - `ToolkitTests/VectorIllustrationTest.tscn` + `.gd`
  - `ToolkitTests/LineQualityABTest.tscn` + `.gd`
- Authored `tools/render_toolkit_ab.gd` to render comparative screenshots.

---

## 2. Error Identified (Root Cause Analysis)

### Failure Point
When running `tools/render_toolkit_ab.gd`, execution halted with:
1. `SCRIPT ERROR: Invalid assignment of property or key 'text' with value of type 'String' on a base object of type 'Nil'. at: _update_status (res://ToolkitTests/LineQualityABTest.gd:163)`
2. `ERROR: Parameter "t" is null at texture_2d_get` when run with `--headless` because the headless dummy rasterizer cannot capture viewport textures.

### Why It Failed
In `ToolkitTests/LineQualityABTest.gd`, lines 37–40 (`_build_current_column`, `_build_aa_column`, `_build_ui`, `_apply_zoom(1.0)`) were inadvertently placed inside `_generate_aa_texture()` **after** the `return ImageTexture.create_from_image(image)` statement. Consequently:
- Neither test column was built.
- `_build_ui()` was never invoked, leaving `label_status` as `null`.
- When `_apply_zoom()` was called during capture, `label_status.text` threw a null-pointer error on the base Nil object.
- Additionally, `ToolkitTests/VectorIllustrationTest.gd` instantiated `ScalableVectorShape2D` without setting `update_curve_at_runtime = true` and without triggering `_update_curve()`, causing column B (SVS) to render blank in initial test runs.

---

## 3. Recovered Work

All previously authored research and test files were completely preserved:
- `docs/toolkit_audit/Nemi_Current_Toolkit_Audit.md` (retained, 100% valid)
- `docs/toolkit_audit/Nemi_External_Toolkit_Research.md` (retained, updated with empirical results)
- `docs/toolkit_audit/SFX_PROVENANCE.md` (retained, updated with 15 verified assets)
- `ToolkitTests/_vendor/` (vendored SVS and Antialiased Line2D retained in sandbox)
- `ToolkitTests/_support/` (retained)

---

## 4. Continuing From

Continued from the **first unfinished step**:
1. Fix `LineQualityABTest.gd` indentation and UI initialization bug.
2. Fix `VectorIllustrationTest.gd` runtime curve generation for SVS.
3. Run live A/B renders via `tools/render_toolkit_ab.gd` with Godot's live Metal rasterizer.
4. Visually inspect rendered outputs (`line_ab_*.png`, `vector_ab_*.png`) across normal (1.0x), medium close-up (1.55x), and extreme close-up (2.5x).
5. Address the primary missing subsystem: **SFX (Class D)** by establishing a vetted, commercial-safe, minimal library.

---

## 5. Newly Completed in This Session

1. **Bug Fixes**:
   - Corrected `ToolkitTests/LineQualityABTest.gd` so `_build_current_column`, `_build_aa_column`, `_build_ui`, and `_apply_zoom` execute cleanly in `_ready()`.
   - Updated `ToolkitTests/VectorIllustrationTest.gd` to enable `update_curve_at_runtime` and call `_update_curve()`.

2. **Live A/B Rendering & Visual Verification**:
   - Rendered 6 high-resolution comparison frames into `renders/toolkit_ab/`:
     - `line_ab_1x.png` (zoom 1.0x)
     - `line_ab_mcu.png` (zoom 1.55x)
     - `line_ab_ecu.png` (zoom 2.5x)
     - `vector_ab_1x.png` (zoom 1.0x)
     - `vector_ab_mcu.png` (zoom 1.55x)
     - `vector_ab_ecu.png` (zoom 2.5x)
   - Visually inspected each image using image tooling.
   - **Empirical Findings**:
     - **InkStroke vs Antialiased Line2D**: `InkStroke` produces superior calligraphic weight, organic pen pressure, and lively comic ink ribbons. `Antialiased Line2D` creates uniform wire-like strokes with visible round caps. **Decision: KEEP CURRENT `InkStroke`. REJECT Antialiased Line2D.**
     - **InkStroke vs Scalable Vector Shapes (SVS)**: SVS delegates to native `Line2D` without calligraphic tapering. It functions as an editor dock tool but does not improve the illustrated visual substrate. **Decision: KEEP CURRENT `InkStroke`. REJECT SVS for character/doodle rendering.**

3. **SFX Subsystem Solved (Class D Gap Resolved)**:
   - Built `tools/setup_nemi_sfx.py`.
   - Curated and extracted **11 Kenney CC0 sounds** (`pluck_001`, `pluck_002`, `click_001`, `tick_001`, `drop_001`, `drop_002`, `question_001`, `scribble_001`, `switch_001`, `impact_soft_001`, `impact_light_001`).
   - Procedurally synthesized **4 bespoke cartoon sounds** via NumPy/wave (`nemi_pop_001.wav`, `nemi_boing_001.wav`, `nemi_whoosh_001.wav`, `nemi_blip_001.wav`).
   - Created `ToolkitTests/SFXTest.gd` automated test suite.
   - Executed Godot asset import and ran `SFXTest.gd`: **15 passed, 0 failed**.
   - Updated `docs/toolkit_audit/SFX_PROVENANCE.md` with complete metadata.

4. **Documentation**:
   - Created this recovery log.
   - Updated `Nemi_External_Toolkit_Research.md` and `Nemi_Current_Toolkit_Audit.md` with final empirical findings, adopted stack, and closure of the SFX gap.

---

## 6. Remaining Work

- None for the Toolkit Audit. The audit, all 10 candidate evaluations, live A/B renders, SFX gap resolution, and documentation are **100% complete**.
- The project is in a clean, stable state with zero unvetted dependencies and all systems locked per the project bible.
