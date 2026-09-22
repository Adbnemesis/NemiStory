# COLONEL RUFFS — Reusable Brawl Stars Character Rig Specification

## Overview
**Colonel Ruffs** is the commander of the Starr Force starship, a canine space officer known for his strict military discipline, calculated tactical ricochet blaster shots, and orbital supply drops. In our **hand-drawn illustrated YouTube storytelling aesthetic**, he balances stoic commander composure with comedic canine instincts (ear twitches, bone thought bubbles, happy panting tongue).

The rig is 100% native Godot 2D procedural vector art, strictly independent and self-contained in `brawl_stars/characters/ruffs/` with zero runtime dependencies on other character worlds.

---

## Node Hierarchy & Z-Ordering

```
Ruffs (Ruffs.gd - Master Director)
└── RuffsVisual (RuffsVisual.gd - Coordinate, Style & Pivot Manager)
    ├── Limbs (RuffsLimbs.gd, z_index = 1, pos = Vector2(0, 0))
    │   ├── Left Arm & Paw (Magenta Sleeve, Rolled Pink Cuff, Orange Paw)
    │   ├── Coat Lower Hem Skirt (Magenta #9d266e with Diagonal Gold Flap & Button)
    │   ├── Dark Purple Military Trousers (#2a1a38)
    │   └── Sturdy Officer Boots (Attention stance, clicked heels, parade rest)
    ├── Torso (RuffsTorso.gd, z_index = 2, pos = Vector2(0, -45))
    │   ├── Double-Breasted Officer Coat (#9d266e with cel shadow #621846)
    │   ├── High Navy Collar (#1e2844) with Gold Piping Accents
    │   ├── Diagonal Gold Button Flap (#f6c33a with 4 embossed brass buttons)
    │   ├── Gold Shoulder Epaulettes (#f6c33a) with Commander Fringe
    │   ├── Gold Dog-Bone Military Medal on Left Chest with Blue Ribbon (#42a5f5)
    │   └── Navy Belt (#1e2844) with Winged Silver Shield Buckle
    ├── RightArm (RuffsRightArm.gd, z_index = 6, pos = Vector2(0, -45))
    │   ├── Right Shoulder Pivot attached at (-42, -34) matching epaulettes
    │   ├── Upper Arm & Forearm Magenta Sleeve (#9d266e)
    │   ├── Officer Sleeve Cuff (#d84b8a)
    │   └── Expressive Orange Canine Paw (Salute, Aim Blaster, Command Point, On Hip)
    └── HeadPivot (Node2D, z_index = 5, pos = Vector2(0, -85) + head_offset)
        ├── Head (RuffsHead.gd, z_index = 0)
        │   ├── Floppy Basset Hound Ears (Brown #6e3d23 with shadow folds, independent tilt)
        │   ├── Peaked Commander Cap Dome (Flared crown #9d266e with split cel shadow)
        │   ├── Navy Cap Band (#1e2844) & Dual Comm Pods (#42cbf5)
        │   ├── Winged Silver Commander Badge with Purple Shield & Anchor
        │   └── Glossy Black Cap Visor / Brim (#1c1a24)
        └── Face (RuffsFace.gd, z_index = 1)
            ├── Orange-Brown Fur Base (#d47228 with shadow #a84814)
            ├── Right Eye (Determined pupil, tracking gaze, brow tilt)
            ├── Left Eye Eyepatch (Glossy black diamond patch with stitched white "X")
            ├── Canine Mouth Visemes (Neutral, Bark, Growl, Smirk, Deadpan, Panting Tongue)
            ├── Massive Puffy Cream Drooping Jowls (#ede0cb) with whisker follicles
            ├── Big Shiny Black Dog Nose with specular highlight
            └── Expressive FX Overlays (Sweat Drop, Anger Mark, Star Sparkle)
```

---

## Directorial API (`Ruffs.gd`)

### 1. Emotional Expressions (14-State Matrix)
```gdscript
ruffs.set_expression(expr_name: String)
```
| Expression | Eye State | Openness | Mouth Viseme | Brow Tilt | Ear Angles | FX Overlays |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `"neutral"` | normal | 1.0 | `"neutral"` | 0.0 | 0.0 | None |
| `"curious"` | normal | 1.1 | `"neutral"` | -0.18 | -0.15 / +0.05 | Inquisitive head tilt (-8°) |
| `"analytical"` | analytical | 0.72 | `"deadpan"` | +0.22 | 0.0 | Furrowed brow, gaze tracking |
| `"happy"` | happy (`^`) | 0.0 | `"smirk"` | 0.0 | +0.10 / -0.10 | Upturned cream jowls |
| `"excited"` | normal | 1.3 | `"panting"` | 0.0 | -0.22 / +0.22 | Pink dog tongue, Star sparkle |
| `"confused"` | suspicious | 0.85 | `"deadpan"` | -0.25 | +0.18 / -0.12 | Asymmetric head cock (+11°) |
| `"surprised"` | shock | 1.35 | `"bark"` | 0.0 | -0.30 / +0.30 | Ears flare outward, wide pupil |
| `"shocked"` | shock | 1.45 | `"bark"` | 0.0 | +0.25 / -0.25 | Drooping ears, sweat drop |
| `"annoyed"` | analytical | 0.8 | `"growl"` | +0.30 | 0.0 | Bared teeth growl, Anger mark |
| `"worried"` | suspicious | 0.88 | `"neutral"` | -0.22 | +0.22 / -0.22 | Sad ear droop, sweat drop |
| `"smug"` | analytical | 0.78 | `"smug"` | -0.12 | -0.10 / +0.05 | Cocky smirk, chin raised |
| `"deadpan"` | deadpan (-) | 0.55 | `"deadpan"` | 0.0 | 0.0 | 0-motion freeze, flat stare |
| `"disciplined"` | normal | 1.05 | `"neutral"` | +0.15 | 0.0 | Rigid attention, straight spine |
| `"mission_accomplished"` | happy | 0.0 | `"smirk"` | 0.0 | -0.12 / +0.12 | Proud grin, star sparkle |

---

### 2. Body Posing & Staging
```gdscript
ruffs.set_pose(pose_name: String, duration: float = 0.2)
```
- `"parade_rest"`: Classic military stance (hands tucked behind back, chest puffed, heels clicked).
- `"salute"`: Snappy military salute (right paw raised to cap visor brim, rigid attention posture).
- `"aim_blaster"`: Right arm raised forward holding double-barrel laser blaster, forward lean.
- `"command_point"`: Right paw pointing forward authoritatively giving orders to fleet.
- `"on_hip"`: Right paw resting on waist belt, confident swagger stance.
- `"recoil"`: Backward torso lean (-0.22 rad), arm pulled close to chest in shock/surprise.
- `"curious_lean"`: Forward torso lean (+0.16 rad), inspecting tactical monitors or maps.

---

### 3. Canine Ear Dynamics & Twitches
```gdscript
ruffs.twitch_ears() # Cute double twitch of floppy hound ears
ruffs.perk_ears()   # Ears angle alertly upward
ruffs.droop_ears()  # Ears hang limp/low (sad/worried/exhausted)
ruffs.reset_ears()  # Smooth return to natural resting hang
```

---

### 4. Gaze & Eye Tracking
```gdscript
ruffs.set_gaze(direction: Vector2)      # Single right eye tracking (-1.0 to 1.0)
ruffs.look_at_point(global_pos: Vector2) # Looks directly at target point in scene
ruffs.blink()                            # Quick 0.14s eye blink
ruffs.double_blink()                     # Saccadic double blink
```

---

### 5. Canine Mouth Visemes
```gdscript
ruffs.set_mouth_viseme(viseme: String)
```
- `"closed"`: Neutral resting jowl contour.
- `"bark"`: Open shout mouth (jaw dropped below cream jowls).
- `"growl"`: Bared upper teeth and snarling lip.
- `"smirk"`: Single curled smile corner.
- `"deadpan"`: Perfectly flat horizontal line.
- `"panting"`: Pink canine tongue hanging down over bottom lip!

---

### 6. Art Mode Switching
```gdscript
ruffs.set_art_mode(RuffsStyle.ArtMode.COLOR)      # Full saturated military palette
ruffs.set_art_mode(RuffsStyle.ArtMode.MONOCHROME) # Hand-drawn ink-wash comic aesthetic
```

---

## Tactical Props

### 1. Double-Barrel Laser Blaster (`RuffsBlaster.tscn`)
- Navy officer casing with gold military accents and cream grip.
- Twin barrels firing parallel cyan and red/magenta laser bolts with muzzle flashes.
- `is_firing: bool`, `is_monochrome: bool`, `aim_angle: float`.

### 2. Starr Force Supply Drop Crate (`RuffsSupplyDrop.tscn`)
- Heavy octagonal steel supply pod with Starr Force star insignia and hazard chevrons.
- Ground impact shadow with radial scorch cracks.
- Floating Golden Dog-Bone Power-Up Badge with glowing cyan aura rings and sparkles.
- `is_deployed: bool`, `show_powerup_badge: bool`, `is_monochrome: bool`.

---

## Tactical Doodle Director (`RuffsDoodleDirector.gd`)
Implements physical YouTube storytime sketch animations: **DRAW -> HOLD -> ERASE**.
- `spawn_ricochet_trajectory(start, wall, end)`: Twin laser reflection vector with angle annotation (`THETA_1 = THETA_2`) and wall barrier hatching.
- `spawn_lz_target(center, radius)`: Starr Force orbital targeting reticle with concentric circles and `AIRSTRIKE LZ` label.
- `spawn_bone_thought(pos)`: Comedic canine thought bubble of a golden dog bone (`?!`) disrupting military discipline.
- `spawn_arrow(from, to)`: Double-line hatched tactical maneuver arrow.
- `spawn_circle(center, radius)`: Objective focus highlight circle.
- `spawn_annotation(pos, text)`: Handwritten military notes with card pill backgrounds.

---

## Verification & Showcase Video
- **Showcase Scene**: `brawl_stars/scenes/RuffsShowcase.tscn` (25 automated steps).
- **Automated Verification**: `brawl_stars/test/verify_ruffs.gd` (captures QA test frames into `scratch/ruffs_verification/`).
- **1080p Render**: `tools/render_ruffs_showcase.py` outputs the single canonical video file to:
  `renders/ruffs_showcase_1080p.mp4`.
