# LEON — Reusable Brawl Stars Character Rig Specification

## Overview
**Leon** is the Legendary Sneaky Assassin of Brawl Stars, reinterpreted into our **hand-drawn illustrated YouTube storytelling aesthetic**.
The rig is 100% native Godot 2D procedural vector art (`CanvasItem._draw()`, `CosmoInkStroke.gd`), strictly self-contained within `brawl_stars/` with zero runtime dependencies on external character modules.

---

## Node Hierarchy & Z-Ordering

```
Leon (Leon.gd - Master Director)
└── LeonVisual (LeonVisual.gd - Coordinate, Style & Pivot Manager)
    ├── Limbs (LeonLimbs.gd, z_index = 1, pos = Vector2(0, -25))
    │   ├── Denim / Indigo shorts (#2563eb) with rolled cuffs
    │   ├── Stylized bare legs (#fcd34d) with organic kneecap linework
    │   ├── Chunky blue slip-on sneakers (#1d4ed8) with thick white rubber soles
    │   └── Blue mitten hands (#0284c7) with multiple pose configurations:
    │       ├── "in_pockets" (clasped inside kangaroo pouch)
    │       ├── "gesture_pitch" (salesman / con-artist pitch hands)
    │       ├── "panic_flail" (spread trembling mittens)
    │       ├── "on_hips" (cocky assassin rest)
    │       └── "pointing" (direct finger point)
    ├── Torso (LeonTorso.gd, z_index = 2, pos = Vector2(0, -85))
    │   ├── Vibrant chameleon-green hoodie body (#22c55e, shadow #15803d)
    │   ├── Front bright blue kangaroo pouch pocket (#0ea5e9, shadow #0284c7)
    │   ├── Oversized metallic silver zipper slider (#d8e2ee) & chunky pull tab
    │   └── Contrast orange bottom waist hem band (#f97316)
    ├── Shurikens (LeonLollipopShuriken.gd, z_index = 3, pos = Vector2(40, -100))
    │   ├── 3-blade fidget-spinner spinning ninja star shurikens (#0ea5e9, #38bdf8)
    │   ├── Swirling translucent speed lines & motion blur circular trails
    │   ├── Blue candy/metallic hub center with specular star highlights
    │   └── Thrown spinning projectile trajectory mode with velocity physics
    └── HeadPivot (Node2D, z_index = 5, pos = Vector2(0, -170) + head_offset)
        ├── Hood (LeonHood.gd, z_index = 0)
        │   ├── Deep green chameleon cowl hood (#22c55e, fold shadow #15803d)
        │   ├── Bold orange median crest stripe (#f97316) from forehead to rear
        │   ├── Left & right protruding BLUE chameleon eye turrets (#1d8cf8, #0a5ec2) with crescent pupils
        │   ├── Red oval visor brim flap (#e11d48, #9f1239) on the lower-right brow opening
        │   └── Curled chameleon tail extending behind with procedural wag oscillation
        └── Face (LeonFace.gd, z_index = 1)
            ├── Rich caramel/tan skin base (#c86a38, shadow #96421a)
            ├── Cute curved black ink nose stroke above mouth
            ├── Deep cowl shadow gradient cast over upper face (#0b1d0d, 78% alpha)
            ├── Expressive mischievous eyes peeking through shadow:
            │   ├── Sharp white sclera wedges with jet pupils and specular gleams
            │   └── Shapes: normal, mischievous, wide, squint, shock_dot, closed_happy
            ├── Mischievous tooth smirk / mouth speech visemes
            ├── Signature magenta/pink lollipop candy (#f43f5e) with white plastic stick
            └── Expressive FX Overlays (Sweat Drop, Anger Mark, Star Sparkle, Shock Lines)
```

---

## Directorial API (`Leon.gd`)

### 1. Emotional Expressions (14-State Matrix)
```gdscript
leon.set_expression(expr_name: String)
```
| Expression | Eye State | Eye Openness | Mouth Shape | Gaze Vector | Head Tilt | Special FX Overlays |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `"neutral"` | normal | 1.0 | `"smirk"` | (0, 0) | 0.0 | None |
| `"mischievous"`| mischievous| 1.1 | `"smirk"` | (0.35, -0.15)| 0.08 (+5°) | Star Sparkle |
| `"playful"` | closed_happy| 0.0 | `"grin"` | (0, 0) | -0.10 (-6°) | Star Sparkle |
| `"confident"` | squint | 0.8 | `"smirk"` | (0.2, 0.0) | 0.05 | None |
| `"suspicious"` | squint | 0.65| `"neutral"` | (-0.45, 0.1)| 0.12 (+7°) | None |
| `"surprised"` | wide | 1.35| `"open_talk"` | (0, -0.25) | -0.06 | None |
| `"shocked"` | shock_dot | 1.4 | `"open_talk"` | (0, 0) | 0.0 | Shock Lines, Sweat Drop |
| `"panicked"` | shock_dot | 1.25| `"wavy"` | (0.2, -0.3) | -0.14 | Sweat Drop |
| `"annoyed"` | squint | 0.7 | `"frown"` | (-0.3, 0.1) | 0.08 | Anger Cross Mark |
| `"deadpan"` | squint | 0.5 | `"neutral"` | (0, 0) | 0.0 | None (0-motion hold) |
| `"smug"` | mischievous| 0.9 | `"grin"` | (0.4, -0.1) | 0.14 (+8°) | Star Sparkle |
| `"scheming"` | squint | 0.6 | `"smirk"` | (0.45, 0.2) | 0.16 (+9°) | None |
| `"victorious"` | closed_happy| 0.0 | `"shout"` | (0, 0) | -0.08 | Star Sparkle |
| `"invisible_stealth"` | squint | 0.85| `"smirk"` | (0.3, -0.1) | 0.0 | Invisibility Fade |

---

### 2. Body Posing & Staging
```gdscript
leon.set_pose(pose_name: String, duration: float = 0.2)
```
- `"idle"`: Casual assassin slouch (hands deep in pockets, subtle tail wag).
- `"sneak"`: Low assassin crouch (torso lean forward +0.22 rad, knees bent, tail twitching).
- `"throw_shuriken"`: Dynamic attack stance (torso torque, arm back, shuriken spinning).
- `"hands_in_pockets"`: Relaxed street kid stance (shoulders loose, tail wagging).
- `"pitch_sales"`: Huckster / salesman lean forward (+0.14 rad, mitten gesturing out).
- `"deadpan_freeze"`: 100% rigid 0-motion freeze (arms limp, flat stare, 0 procedural motion).
- `"recoil"`: Backward lean (-0.24 rad, mittens flailing back, surprised recoil).

---

### 3. Gaze & Eye Tracking
```gdscript
leon.set_gaze(direction: Vector2)              # Normalized vector (-1.0 to +1.0)
leon.look_at_point(global_pos: Vector2)         # Calculates vector toward world point
leon.blink()                                    # Snappy 0.14s eye blink
leon.double_blink()                             # Natural double-blink sequence
```

---

### 4. Live Illustrative Lip-Sync & Speech Visemes
```gdscript
# Text-Driven Speech with syllabic timing (~12-15 FPS cadence)
await leon.speak(text: String, duration: float = -1.0, emotion: String = "normal")

# Audio-Driven Speech locked to recorded .wav voice tracks
await leon.speak_audio(audio_path_or_stream: Variant, text: String = "", emotion: String = "normal")

# Immediate speech cessation and clean rest-shape closure
leon.stop_speech(rest_shape: String = "smirk")
leon.is_speaking() -> bool

# Manual viseme and syllable overrides
leon.set_viseme(viseme: String)
leon.talk_syllable(viseme: String = "small_open", duration: float = 0.15)
```
- **Canonical Speech Visemes**:
  - `"closed"`: Cheeky closed mouth line with slight upward curve and dimple (for M, P, B consonants and pauses).
  - `"small_open"`: Subtle conversational opening showing top teeth strip (consonants and unstressed vowels).
  - `"ae"`: Wide horizontal mouth opening showing teeth and red tongue (*"cat"*, *"say"*, *"bed"*, *"trophies"*).
  - `"o_u"`: Rounded pursed circular mouth aperture (*"go"*, *"you"*, *"who"*, *"oh"*).
  - `"wide"`: Energetic, wide open mouth with full teeth and tongue for loud con-artist pitching and shouting.
  - `"smirk"`: Signature cheeky tooth grin.
  - `"deadpan"`: Perfectly flat horizontal deadpan line.
  - `"shout"`: Screaming panic wide-open mouth with dropped jaw.
- **Dynamic Lollipop Handling**: When speech visemes open, the lollipop stick automatically pivots and angles slightly into the right cheek corner (`+0.15 * mouth_openness` rad) to avoid obscuring the mouth aperture.

---

### 5. Signature Assassin Capabilities
```gdscript
leon.set_lollipop_visible(visible: bool)        # Toggle blue candy pop in mouth
leon.set_stealth_alpha(alpha: float, dur: float)# Smoke bomb invisibility fade (0.0 to 1.0)
leon.trigger_shuriken_spin(active: bool)        # Spin 3-blade fidget shurikens with speed trails
leon.set_art_mode(LeonStyle.ArtMode.COLOR)      # Full canonical green/orange assassin palette
leon.set_art_mode(LeonStyle.ArtMode.MONOCHROME) # Hand-drawn ink-wash storytime rendering
```

---

## Storytime Reaction Doodling (`LeonDoodleDirector.gd`)

Implements the hand-drawn sketch overlay sequence: **DRAW -> HOLD -> ERASE**.
- `spawn_smoke_cloud(center, radius)`: Ninja smoke bomb "POOF" with puffy outline and centered question mark.
- `spawn_bush_outline(center, size)`: Hand-drawn Showdown green bush outline with two glowing chameleon eyes lurking inside.
- `spawn_shuriken_trail(start_pos, target_pos)`: High-speed projectile streak with spinning spiral arc.
- `spawn_pitch_arrow(start_pos, target_pos, label)`: Con-artist hand-drawn callout arrow with "FREE TROPHIES!" or custom pitch.
- `spawn_annotation(pos, text)`: Progressive calligraphic handwriting with ink underline.

---

## Showcase Test Harness (`brawl_stars/scenes/LeonShowcase.tscn`)

Interactive directorial test harness featuring a 24-step automatic sequence:
- **Steps 1–14**: All 14 emotional expressions with dynamic eye pupils and visemes.
- **Steps 15–18**: Saccadic gaze tracking, double blinks, and chameleon tail wag.
- **TEST A**: Ninja smoke bomb stealth transition (smoke poof doodle + alpha fade).
- **TEST B**: Showdown bush-camping strategy (bush doodle with peeking eyes).
- **TEST C**: Rapid fidget-spinner shuriken barrage with speed trails.
- **TEST D**: Con-artist / scammer trophy pitch ("FREE TROPHIES!").
- **TEST E**: Comedic deadpan hold (0-motion freeze after caught in 4K).
- **Art Mode**: Monochrome ink-wash storytelling mode switch.
