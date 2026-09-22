# Pikachu Vector Rig Specification

## Overview
The Pikachu character rig in `pokemon/characters/pikachu/` is a 100% native 2D vector rig constructed with procedural polygon geometry, calligraphic ribbon inking, layered z-ordering, and parametric articulation.

---

## Node Hierarchy & Z-Ordering

```
Pikachu (Pikachu.gd - Master Director)
└── PikachuVisual (PikachuVisual.gd - Coordinate & Pivot Manager)
    ├── Tail (PikachuTail.gd, z_index = -1)
    │   └── 3-Segment Lightning Vector Polygon + Base Brown Patch
    ├── Limbs (PikachuLimbs.gd, z_index = 0)
    │   ├── Body Pear Silhouette (Yellow Fill #FED933)
    │   ├── Two Dark Brown Back Stripes (#7C4524)
    │   ├── Left Paw & Right Paw (5-digit calligraphic inking)
    │   └── Grounded Feet
    └── Head (Node2D, Pivot = Vector2(0, -60), z_index = 1)
        ├── Ears (PikachuEars.gd, z_index = -1 relative to Head)
        │   ├── Left Pointed Ear + Black Dipped Tip
        │   └── Right Pointed Ear + Black Dipped Tip
        ├── HeadBase (PikachuHeadBase.gd, z_index = 0 relative to Head)
        │   └── Organic Round Head Silhouette with Cheek Bulges
        └── Face (PikachuFace.gd, z_index = 1 relative to Head)
            ├── Left Eye & Right Eye (Dark Iris, Upper Rim, Specular Catchlights)
            ├── Cheeks (Two Circular Crimson Pouches #E83628 + Spark Points)
            ├── Nose (Subtle Triangular Ink Dot)
            ├── Mouth (Cat-lip Visemes with Tongue & Dark Interior)
            └── Secondary Overlays (Blush Hatching, Sweat Droplets, Spark FX)
```

---

## Part Specifications

### 1. Tail (`PikachuTail.gd`)
- **Geometry**: Procedural lightning bolt constructed from 3 articulated trapezoidal segments and an interlocking triangular jagged tip.
- **Coloration**:
  - Base Segment: Dark warm brown `#7C4524`.
  - Mid & Tip Segments: Electric vibrant yellow `#FED933`.
- **Motion Controls**:
  - `wag_amplitude` (float): Angular sway range (default: `0.12`, happy: `0.25`, sprint: `0.35`).
  - `wag_frequency` (float): Oscillation speed (idle: `4.0`, happy: `8.0`, excited: `12.0`).
  - `is_zapping` (bool): Triggers yellow/white electrical spark accents and jagged displacement.
  - `is_drooped` (bool): Lowers tail to ground level during fear, sadness, or exhaustion.

### 2. Ears (`PikachuEars.gd`)
- **Geometry**: Elegant pointed vector ovals with calligraphic tapering and distinct angled black tips covering the outer 30% of each ear.
- **Resting Angles**: Left: `-0.45` rad (~$-26^\circ$), Right: `0.52` rad (~$+30^\circ$).
- **Motion Controls**:
  - `left_ear_angle` / `right_ear_angle` (float, radians): Independent rotation about ear base roots.
  - `ear_droop` (float, 0.0 to 1.0): Interpolates ear rotation down to $\pm 1.4$ rad, flattening ears against the head.
  - `ear_twitch` (float): High-frequency micro-jitter for nervous or alert states.

### 3. Face & Head Base (`PikachuHeadBase.gd`, `PikachuFace.gd`)
- **Geometry**: Head silhouette features signature chubby cheek contours tapering slightly toward the crown.
- **Eyes**:
  - `eye_state`:
    - `"normal"`: Round anime eyes with dark brown/black iris, top eyelid stroke, and bright white specular highlight.
    - `"happy"`: Curved upward arc-eyes ("^ ^").
    - `"shock"`: Constricted pinprick pupil surrounded by wide sclera.
    - `"spiral"`: Dazed double-spiral lines.
    - `"squint"`: Narrowed aggressive or skeptical slits.
    - `"sad"`: Down-turned half circles.
    - `"deadpan"`: Flat blank dot pupils.
  - `eye_openness` (float): $0.0$ (closed) to $1.4$ (wide open shock).
  - `gaze_direction` (Vector2): Clamped between $(-1.0, -1.0)$ and $(1.0, 1.0)$.
- **Electric Cheek Pouches**:
  - Position: Lateral cheeks, colored vivid electric red `#E83628`.
  - Spark FX: `is_sparking = true` renders procedural jagged electric sparks emitting from cheek centroids.
- **Mouth Visemes**:
  - `"cat"`: Signature '3'-shaped upper lip curve with tiny center notch.
  - `"open_happy"`: Cat-lip split opening with pink tongue fill (`#E25A70`).
  - `"open_shout"`: Wide rounded open mouth with dark cavity and interior tongue.
  - `"shock_o"`: Small circular open 'O'.
  - `"wavy"`: Squiggly line representing worry or nausea.
  - `"grit"`: Clenched teeth with horizontal biting crease.
  - `"dash"`: Flat straight cynical line.
  - `"frown"`: Downward arc curve.
  - `"deadpan"`: Tiny minimalist horizontal stroke.

### 4. Limbs & Body Silhouette (`PikachuLimbs.gd`)
- **Body**: Pear-shaped silhouette with low center of gravity.
- **Back Stripes**: Two dark brown calligraphic curved wedges on upper back.
- **Arm Poses**:
  - `"rest"`: Paws resting neatly against upper chest/tummy.
  - `"cheer"`: Both arms raised enthusiastically above head.
  - `"point"`: Right arm extended forward pointing at target.
  - `"recoil"`: Paws tucked inward defensively.
  - `"wave"`: Right paw raised and animated in welcoming gesture.
  - `"hold"`: Arms positioned in front to clasp props.
- **Squash & Stretch**:
  - `squash_stretch(factor: Vector2, duration: float)`: Modulates `body_scale` smoothly with spring back to `Vector2.ONE`.

---

## Palette Constants (`PikachuStyle.gd`)

| Role | Color Name | Hex Code |
| :--- | :--- | :--- |
| Primary Fur | `FUR_YELLOW` | `#FED933` |
| Fur Highlight | `FUR_HIGHLIGHT` | `#FFF37A` |
| Fur Shadow | `FUR_SHADOW` | `#DEB71F` |
| Ear Tips & Eyes | `INK_BLACK` | `#262224` |
| Stripes & Base Tail | `EAR_BROWN` | `#7C4524` |
| Electric Cheeks | `CHEEK_RED` | `#E83628` |
| Inner Mouth | `MOUTH_DARK` | `#631826` |
| Tongue | `MOUTH_TONGUE`| `#E25A70` |
| Spark FX | `ELECTRIC_SPARK`| `#FFEE55` |
