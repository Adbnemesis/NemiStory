# VISUAL DESIGN SYSTEM

## 1. Native Vector Architecture
All graphics in the carousel system are rendered via Godot Engine mathematical 2D vector calls:
* Outlines use variable-width calligraphic polyline/polygon drawing with natural tapered endpoints.
* Fills use `draw_colored_polygon()` with curated HSL color constants.
* Backdrops utilize warm paper tones (`#faf7f5` for Nemi, `#faf6ee` for ADB) layered with subtle procedural paper texture.
* Zero raster sprites, zero external image generation, zero AI diffusion artifacts.

---

## 2. Canvas & Safe Zones (1080 × 1350 px)
* **Canvas Dimensions**: `1080px × 1350px` (Vertical 4:5 Mobile Ratio).
* **Safe Zone Margins**:
  * Top Margin: `100px` (avoids Instagram header UI and profile badges).
  * Bottom Margin: `120px` (avoids carousel navigation dots and comment buttons).
  * Side Margins: `80px` (avoids screen borders and thumb swipe gestures).
* **Content Safe Rect**: `Rect2(80, 100, 920, 1130)`. All critical text, headlines, and call-to-actions must remain inside this rectangle. Character limbs, hair bounce, or doodle accents may bleed into outer margins for dynamic framing.

---

## 3. Brand Visual Divergence
* **Nemi**: Warm, organic, round contours, sage green hoodie, copper red hair, deep blackberry inking (`#38101e`), calligraphic tooth, warm peach watercolor markers.
* **ADB**: Understated, clean geometry, oatmeal knit pullover, dark slate indigo curtain bangs, deep charcoal inking (`#2b2623`), subtle drafting dot grid, minimalist charcoal block callouts.
