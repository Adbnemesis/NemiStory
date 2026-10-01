# ART PROVENANCE & ASSET IMPLEMENTATION DIRECTORY

This document details the exact origin and implementation source of every reusable visual element in the carousel production engine.

## 1. Zero External Generative Asset Policy
No visual asset is generated via AI services, diffusion models, or external graphics APIs. All visual assets are locally stored and procedurally drawn in Godot Engine.

---

## 2. Character Geometry Provenance
* **Nemi Carousel Character (`carousel/nemi/character/`)**:
  * **Canonical Visual Reference**: `references/main_character/nemi_sheet.png` and `nemi/docs/Nemi_Character_Bible.md`.
  * **Implementation**: `NemiVectorGeometry.gd` and `NemiCarouselCharacter.gd`.
  * **Technique**: Procedural 2D polygonal tessellation (`draw_colored_polygon`), variable-width calligraphic contours (`draw_polyline` / ribbon polygons).
  * **Head & Cheeks**: 94px wide × 112px high oval, tapered chin, mid-cheek fullness (92px).
  * **Hair Parts**: Crown dome, bangs fringe, cheek-framing side tresses, ahoge bounce lock.
  * **Costume**: Oversized sage green cowl hoodie, forest pleated skirt, chunky platform sneakers.
* **ADB Carousel Character (`carousel/adb/character/`)**:
  * **Canonical Visual Reference**: `references/adb_model_sheet.jpg` and `adb/docs/ADB_CHARACTER_GUIDE.md`.
  * **Implementation**: `ADBVectorGeometry.gd` and `ADBCarouselCharacter.gd`.
  * **Technique**: Clean polygonal vector meshes, charcoal contour strokes.
  * **Head & Jaw**: Lean softly angular chin, almond anime eye contours.
  * **Hair Parts**: Tousled dark slate volume with middle-part curtain bangs.
  * **Costume**: Oatmeal knit half-zip sweater with ribbed collar/hem, dark crewneck inner tee, straight dark slate trousers, white low-top canvas sneakers.

---

## 3. Vector Props Provenance
* **Drawing Tablet & Stylus**: Procedurally constructed in `NemiCarouselProps.gd` using beveled rectangles, stylus ink tip, and screen glow.
* **Gaming Controller**: Procedurally constructed in `ADBCarouselProps.gd` using curved ergonomic grip polygons, D-pad, thumbsticks, and face buttons.
* **Mechanical Keyboard**: Procedurally constructed in `ADBCarouselProps.gd` with subtle row profiles and keycap bevels.
* **Coffee Mug**: Procedural ceramic cylinder with curved handle and steam plume vectors.
* **Timeline Scrubber**: Procedural UI strip with frame ticks, keyframe diamonds, and playhead marker.

---

## 4. Typography Provenance
* `assets/fonts/PatrickHand-Regular.ttf`: Open Font License (OFL) locally stored font.
* `assets/fonts/Caveat-Bold.ttf`: Open Font License (OFL) locally stored font.
* `assets/fonts/GochiHand-Regular.ttf`: Open Font License (OFL) locally stored font.
* `assets/fonts/Impact.ttf`: System standard locally stored font.
