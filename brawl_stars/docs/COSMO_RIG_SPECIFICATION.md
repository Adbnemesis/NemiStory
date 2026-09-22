# COSMO — Reusable Brawl Stars Character Rig Specification

## Overview
**Cosmo** is the lead astronomer at Starr Park's Observatory, a Mythic Controller brawler reinterpreted into our **hand-drawn illustrated YouTube storytelling aesthetic**.
The rig is 100% native Godot 2D procedural vector art, strictly independent and self-contained in `brawl_stars/` with zero runtime dependencies on other character worlds.

---

## Node Hierarchy & Z-Ordering

```
Cosmo (Cosmo.gd - Master Director)
└── CosmoVisual (CosmoVisual.gd - Coordinate, Style & Pivot Manager)
    ├── Limbs (CosmoLimbs.gd, z_index = 1, pos = Vector2(0, -25))
    │   ├── Robotic Pelvis (Dark Slate #363846) + Top Magnetic Receptor Ring
    │   ├── Spherical Hip Pivot Sockets (Dual Mechanical Joints)
    │   ├── Corrugated / Accordion Flexible Cylindrical Legs (Horizontal Segmented Rings)
    │   ├── Robotic Boots with Flared Ankle Cuffs & Angled Soles
    │   └── Left Arm (Royal Blue Coat Sleeve #2464c8, Rolled Teal Cuff #58b4d8, Robotic Hand)
    ├── Torso (CosmoTorso.gd, z_index = 2, pos = Vector2(0, -95))
    │   ├── Bottom Waist Levitation Ring (Floating Magnetic Halo #60d0ff, 45% alpha)
    │   ├── Royal Blue Trench Coat Body (#2464c8, Peaked Lapels, Flared Tail Hem)
    │   ├── Crimson / Magenta Knit Sweater Vest (#c4285e, Ribbed Hem)
    │   ├── Crisp White Shirt Collar Lapels (#f4f6fa) + Amber-Orange Necktie (#f07820)
    │   └── Open Neck Magnetic Levitation Socket (#60d0ff, 45% alpha)
    ├── AttractorArm (CosmoAttractorArm.gd, z_index = 4, pos = Vector2(0, -95))
    │   ├── Right Upper Arm Sleeve (#2464c8)
    │   ├── Signature Attractor Device (Industrial Silver Collar #dce2ee)
    │   ├── Red Curved Underside Manifold / Handle (#dc3232)
    │   ├── Yellow Hazard Caution Triangle Badge (#f8be28)
    │   └── Articulated 4-Fingered Dark Slate Robotic Hand (#363846)
    └── HeadPivot (Node2D, z_index = 5, pos = Vector2(0, -185) + head_floating_offset)
        ├── Head (CosmoHead.gd, z_index = 0)
        │   ├── Floating Neck Energy Aura (Ethereal Cyan Rings)
        │   ├── Asymmetric Observatory Dome Shell (#dde2ed, Shadow #b0b8cb)
        │   ├── Lateral Ear Swivel Brackets (#c0c8d8) + Mechanical Pivot Screws (#505568)
        │   └── Top Dome Antenna Fin Ridge (#c0c8d8)
        └── Face (CosmoFace.gd, z_index = 1)
            ├── Cyclops Telescope Barrel Casing (Dark Slate Metal #2a2b36)
            ├── Cosmic Violet Lens Interior (#3d1a58) + Specular Glass Glints
            ├── Luminous Pill / Slit / Circle Pupil (#ffffff Core with #d870f0 Aura)
            ├── 4-Segment Amber Speaker / Teeth Grill Mouth (#f6d678)
            └── Expressive FX Overlays (Sweat Drop, Eureka Sparkle, Anger Mark)
```

---

## Directorial API (`Cosmo.gd`)

### 1. Emotional Expressions (14-State Matrix)
```gdscript
cosmo.set_expression(expr_name: String)
```
| Expression | Eye State | Openness | Grill Mouth Shape | Gaze Vector | Head Tilt | FX Overlays |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `"neutral"` | normal | 1.0 | `"neutral"` (4 slots) | (0, 0) | 0.0 | None |
| `"curious"` | curious | 1.1 | `"neutral"` | (0.45, -0.3) | -0.12 (-7°) | None |
| `"analytical"` | analytical | 0.75 | `"deadpan"` | (0.2, 0.4) | 0.08 (+5°) | None |
| `"happy"` | happy (`^`) | 0.0 | `"smile"` | (0, 0) | 0.0 | None |
| `"excited"` | normal | 1.3 | `"shout"` (jaw dropped) | (0, 0) | -0.05 | Eureka Sparkle |
| `"confused"` | normal | 0.9 | `"wavy"` (undulating) | (-0.55, -0.2) | 0.16 (+9°) | None |
| `"surprised"` | normal | 1.35 | `"shock_o"` (tall oval) | (0, -0.2) | -0.08 | None |
| `"shocked"` | shock (dot) | 1.4 | `"open_talk"` | (0, 0) | 0.0 | Sweat Drop, Recoil |
| `"annoyed"` | analytical | 0.8 | `"frown"` (grimace) | (-0.35, 0.1) | 0.06 | Anger Cross Mark |
| `"worried"` | normal | 0.85 | `"wavy"` | (0, 0) | -0.10 | Sweat Drop |
| `"smug"` | analytical | 0.8 | `"smug"` (cocked smirk) | (0.4, -0.1) | 0.12 (+7°) | None |
| `"deadpan"` | deadpan (-) | 0.6 | `"deadpan"` (flat bar) | (0, 0) | 0.0 | None (0-motion hold) |
| `"fascinated"` | fascinated | 1.25 | `"grin"` | (0.2, -0.3) | -0.08 | Starry Highlight |
| `"realization"` | fascinated | 1.35 | `"shock_o"` | (0, -0.4) | -0.04 | Eureka Sparkle |

---

### 2. Body Posing & Staging
```gdscript
cosmo.set_pose(pose_name: String, duration: float = 0.2)
```
- `"idle"`: Classic resting pose (Attractor open palm hover, left hand on hip, neutral stance).
- `"observing"`: Torso lean forward (+0.14 rad), attractor pointed forward, left arm on hip.
- `"explaining"`: Torso slight upright lean (-0.06 rad), attractor gesturing upward, wide stance.
- `"operating_telescope"`: Torso lean forward (+0.22 rad), attractor hand on focus wheel, left arm pointing.
- `"realization_freeze"`: Rigid upright spine, attractor open palm, wide stance.
- `"deadpan_freeze"`: 100% rigid 0-motion freeze, arms relaxed/curled, flat mouth.
- `"recoil"`: Backward torso lean (-0.22 rad), attractor gauntlet shielding chest, recoil stance.
- `"curious_lean"`: Forward torso lean (+0.18 rad), attractor pointing forward, gesturing.

---

### 3. Gaze & Eye Tracking
```gdscript
cosmo.set_gaze(direction: Vector2)              # Normalized vector (-1 to 1)
cosmo.look_at_point(global_pos: Vector2)         # Calculates vector toward world point
cosmo.look_into_telescope(telescope: Node2D)     # Aligns gaze directly with telescope eyepiece
cosmo.blink()                                    # Snappy 0.14s eye blink
cosmo.double_blink()                             # Natural double-blink sequence
```

---

### 4. Mouth Visemes for Dialogue
```gdscript
cosmo.set_mouth_viseme(viseme: String)
```
- Supported visemes: `"closed"`, `"slight_open"`, `"talk_a"`, `"talk_o"`, `"smile"`, `"frown"`, `"shout"`, `"deadpan"`.

---

### 5. Art Mode & Levitation Controls
```gdscript
cosmo.set_art_mode(CosmoStyle.ArtMode.COLOR)       # Full canonical astronomer colors
cosmo.set_art_mode(CosmoStyle.ArtMode.MONOCHROME)  # Pure hand-drawn ink-wash storytime rendering
cosmo.trigger_levitation_bob(true / false)         # Art-directed floating vertical oscillation
```

---

## Scientific Props & Visual VFX

### 1. Observatory Telescope (`brawl_stars/assets/props/CosmoTelescope.tscn`)
- Brass and navy optical tube mounted on an adjustable wooden tripod.
- Eyepiece calibrated on the left (facing Cosmo) for direct eye alignment.
- Adjustable `elevation_angle` (radians) for tracking stars across the sky.
- `is_discovering = true`: Emits radiant celestial discovery beam from objective lens.
- Supports instant `is_monochrome = true` switching.

### 2. Celestial Orbs (`brawl_stars/assets/props/CosmoCelestialOrbs.tscn`)
- 3 hand-drawn planetary bodies manipulated by Cosmo's Attractor Gauntlet:
  1. Ringed Planet (Saturn-style azure planet with cloud bands and elliptical rings).
  2. Blue Moon (Bright cyan sphere with crater dots).
  3. Gravitational Bubble (Translucent plasma sphere with specular glint).
- Modes:
  - `"hover_palm"`: Canonical orbit closely hovering above palm.
  - `"expand_orbit"`: Expanding orbit (Main Attack: Orbit).
  - `"home_target"`: Elliptical homing path (Super: Gravitational Pull).
  - `"idle"`: Stationary floating.

### 3. Hand-Drawn Doodle Director (`brawl_stars/scripts/CosmoDoodleDirector.gd`)
- Physical sketching sequence: **DRAW -> HOLD -> ERASE**.
- Spawners:
  - `spawn_arrow(from, to)`: Organic calligraphic ink arrows with tapered heads.
  - `spawn_circle(center, radius)`: Hand-drawn focus circles with organic start/end overlap.
  - `spawn_orbit_diagram(center, rx, ry)`: Orbital ellipse with central star and satellite dot.
  - `spawn_gravity_concept(center)`: Central gravitational mass with 4 inward force vectors.
  - `spawn_magnetic_pull(from, target)`: Dipole magnetic flux arcs curving toward target.
  - `spawn_annotation(pos, text)`: Progressive handwritten text reveal with ink underline.

---

## Showcase Test Harness (`brawl_stars/scenes/CosmoShowcase.tscn`)

Interactive test scene demonstrating all capabilities:
- **Steps 1–14**: All 14 emotional expressions with cyclops eye and teeth visemes.
- **Steps 15–18**: Saccadic eye tracking, double blinks, gauntlet aim, and levitation float.
- **TEST A**: Cosmo looks through the Observatory Telescope.
- **TEST B**: Cosmo notices something unusual in the deep sky.
- **TEST C**: Cosmo studies a hand-drawn orbital diagram.
- **TEST D**: Cosmo demonstrates Gravity and Magnetic Pull.
- **TEST E**: Cosmo experiences a scientific eureka realization.
- **TEST F**: Comedic deadpan hold (0-motion freeze after a calculation error).
- **Art Mode**: Finished Monochrome ink-wash storytelling mode.
