# Pokémon Character Animation System — Director's Guide

## Overview
This document provides complete directorial and developer documentation for the **Pikachu** and **Ash Ketchum** live native 2D Godot character animation system.

Both characters are built from the ground up as genuine 2D vector rigs drawn using custom calligraphic tapered ribbon polygons, dynamic vector fills, articulated bone pivots, and rich facial acting controls. They are 100% native Godot characters with zero pre-rendered frame swaps or static puppet PNG cutouts.

---

## Directory & File Structure

```
pokemon/
├── assets/
│   └── props/
│       ├── PokeBall.gd           # Illustrated Poké Ball prop with open/pop logic
│       └── PokeBall.tscn         # Instantiable Poké Ball scene
├── characters/
│   ├── ash/
│   │   ├── parts/
│   │   │   ├── AshHead.gd        # Cap (Indigo League), hair spikes, ears, backward cap toggle
│   │   │   ├── AshFace.gd        # Eyes, pupils, highlights, brows, "Z" cheek marks, mouth visemes
│   │   │   ├── AshTorso.gd       # Neck, inner black shirt, open blue vest, yellow trim, belt/buckle
│   │   │   └── AshLimbs.gd       # Denim jeans, rolled cuffs, sneakers, arms & fingerless gloves
│   │   ├── Ash.gd                # Master directorial interface for Ash
│   │   ├── Ash.tscn              # Ash character scene
│   │   ├── AshStyle.gd           # Color palette, line hierarchy, COLOR / MONOCHROME switch
│   │   └── AshVisual.gd          # Visual layer coordinator and head pivot
│   └── pikachu/
│       ├── parts/
│       │   ├── PikachuEars.gd     # Articulated ears with black dipped tips & droop
│       │   ├── PikachuFace.gd     # Anime eyes, catchlights, red electric pouches, cat-lip visemes
│       │   ├── PikachuHeadBase.gd # Head round silhouette and facial underlay
│       │   ├── PikachuLimbs.gd    # Pear body silhouette, brown stripes, paws, grounded feet
│       │   └── PikachuTail.gd     # 3-segment lightning tail, brown base, wag & spark emission
│       ├── Pikachu.gd             # Master directorial interface for Pikachu
│       ├── Pikachu.tscn           # Pikachu character scene
│       ├── PikachuStyle.gd        # Color palette, line hierarchy, COLOR / MONOCHROME switch
│       └── PikachuVisual.gd       # Visual layer coordinator and head pivot
├── docs/
│   ├── POKEMON_CHARACTER_SYSTEM_GUIDE.md
│   ├── PIKACHU_RIG_SPECIFICATION.md
│   └── ASH_RIG_SPECIFICATION.md
├── scenes/
│   ├── PokemonShowcase.gd         # 28-step test harness & directorial demonstration
│   └── PokemonShowcase.tscn       # Showcase stage with lighting, props, and live cameras
└── scripts/
    ├── PokemonBaseProp.gd         # Reusable prop physics/tweens (pop, drop, bounce, socket)
    ├── PokemonDoodleDirector.gd   # Progressive calligraphic doodles (arrows, circles, sparkles)
    └── PokemonInkStroke.gd        # Core ribbon polygon inker with tapering profiles
```

---

## Design System & Art Rules

### Organic Pen & Ink Stroke Line Hierarchy
All linework adheres strictly to hand-drawn pen-and-ink aesthetics:
- **Ink Color**: Canonical warm organic charcoal `#262224` (never harsh pure `#000000`).
- **Primary Outlines**: $4.5\text{px} - 5.5\text{px}$ width with gentle calligraphic tapering at corners and endpoints.
- **Secondary Feature Lines**: $2.5\text{px} - 3.5\text{px}$ for facial contours, ear folds, vest collars, and shoe straps.
- **Delicate Inner Creases**: $1.2\text{px} - 1.8\text{px}$ for eyelid creases, nose ticks, cheek Z-marks, and fabric folds.

### Color Modes
Both characters support instant global art mode toggles without rebuilding nodes:
- `PikachuStyle.ArtMode.COLOR` / `AshStyle.ArtMode.COLOR`: Rich storybook color fills.
- `PikachuStyle.ArtMode.MONOCHROME`: Manga / storyboard grayscale linework and ink tones.

---

## Directorial API: Expressions & Acting

Both `Pikachu` and `Ash` expose 20 canonical storytelling expressions:

| Expression | Pikachu Facial Acting | Ash Facial Acting |
| :--- | :--- | :--- |
| `neutral` | Calm circular eyes, cat-lip smile | Confident subtle smile, balanced brows |
| `happy` | Arched upward curved eyes, open cat mouth | Uplifted brows, wide toothy grin |
| `excited` | Wide open eyes (1.2×), shout mouth, rapid tail wag | Raised arched brows, wide shout |
| `surprised` | Wide eyes (1.3×), 'O' mouth, erect ears | Raised brows (-8px), round 'O' mouth |
| `shocked` | Pinprick shock pupils, dropped jaw, tail zapping | Large shock eyes, dropped jaw, brows peaked |
| `confused` | Spiral eyes, wavy mouth, tilted head (+0.15) | Asymmetric brows (one raised, one lowered), tilted head |
| `worried` | Down-turned eyes, wavy mouth, sweat droplet | Angled worry brows, wavy mouth, sweat |
| `embarrassed`| Soft half-lids, blush cheeks, sweat | Averted gaze, blush cheek patches, sweat droplet |
| `annoyed` | Slanted squint eyelids, horizontal dash mouth | Lowered brows (+4px), flat dash mouth |
| `angry` | Narrowed fierce eyes, teeth grit, cheek sparks | V-angled scowl brows (+6px), teeth grit |
| `frustrated` | Squeezed shut curved eyes, teeth grit, ear twitch | Tightly shut curved eyes, scowl, teeth grit |
| `scared` | Shock pupils, drooping ears, wavy mouth, tail tucked | Peaked brows, shock pupils, wavy mouth, sweat |
| `suspicious` | Sideways squint gaze, slight head tilt | One brow lowered, horizontal side gaze |
| `smug` | Half-lids, side glance, proud grin | One brow raised, cocky smirk, side glance |
| `exhausted` | Drooping heavy eyelids, sweat droplet, slumped ears | Drooped heavy lids, sweat droplet, loose smile |
| `relieved` | Gentle closed curve eyes, soft smile, sigh sweat | Soft curved eyes, sighing smile, sweat bead |
| `nervous` | Shifty glancing eyes, sweat droplet, twitching ears | Shifty glancing eyes, wavy mouth, sweat |
| `determined` | Focused fierce lids, teeth grit, electric spark ready | Angled brows, intense gaze, grit mouth |
| `sad` | Drooping brow line, frown mouth, drooped ears & tail | Inverted brows, downturned frown mouth |
| `deadpan` | Flat dot pupils, straight line mouth, absolute freeze | Flat unblinking eyes, deadpan mouth, total freeze |

---

## Gaze Tracking & Eye Controls

Characters can be directed to look anywhere in the frame using named presets or continuous coordinates:

```gdscript
# Named direction presets:
pikachu.look("camera")       # Look directly at viewer
ash.look("down_right")       # Look toward Pikachu standing nearby
ash.look("pikachu_right")    # Dedicated helper alias

# Continuous target tracking:
ash.look_at_target(pikachu.global_position)
pikachu.look_at_pos(ash.global_position + Vector2(0, -145))

# Blinking:
ash.blink(0.12)              # Single natural blink
pikachu.double_blink()       # Comic timing double blink
```

---

## Posing & Gestures

```gdscript
# Pikachu Poses:
pikachu.set_pose("idle")             # Relaxed breathing stance
pikachu.set_pose("happy_bounce")     # Bouncy squash & stretch
pikachu.set_pose("curious_tilt")     # Head tilted, paws together
pikachu.set_pose("cheering")         # Arms raised in victory
pikachu.set_pose("alert_stand")      # Pointing paw forward
pikachu.set_pose("shock_recoil")     # Lean back with flattened ears
pikachu.set_pose("battle_stance")    # Low aggressive forward crouch with electric cheeks
pikachu.set_pose("deadpan_freeze")   # Zero-wag freeze frame hold

# Ash Poses:
ash.set_pose("idle")                 # Natural standing stance
ash.set_pose("confident_fist")       # Clenched fist forward, chest out
ash.set_pose("point_forward")        # Iconic "I choose you!" index finger point
ash.set_pose("arms_crossed")         # Casual confident folded arms
ash.set_pose("holding_pokeball")     # Arm positioned forward ready to hold Poké Ball
ash.set_pose("scratch_head")         # Hand behind neck in comedic sheepishness
ash.set_pose("shrug")                # Both hands raised with palms up
ash.set_pose("look_at_pikachu")      # Turns head and glances downward at partner

# Cap Direction Toggle:
ash.turn_cap(true)                   # Turns cap backward for serious battles
ash.turn_cap(false)                  # Returns cap forward to Indigo League visor mode
```

---

## Secondary Motion, Doodles & Props

### Lightning Tail & Electric Sparks
```gdscript
pikachu.wag_tail(intensity, speed)   # Dynamic tail wagging
pikachu.trigger_spark_fx(0.8)        # Sparks on red cheeks and tail tip
```

### Progressive Calligraphic Doodles
`PokemonDoodleDirector` generates animated chalk/ink doodles:
- `draw_doodle_arrow(from_pos, to_pos, color, duration)`
- `draw_doodle_circle(center_pos, radius, color, duration)`
- `draw_doodle_label(text, pos, color, duration)`
- `draw_doodle_sparkles(pos, count, radius, duration)`

### Poké Ball Interaction
`PokeBall.tscn` supports physical animations and visual popping:
```gdscript
pokeball.pop_in(Vector2(500, 300))
pokeball.open_ball()                 # Opens top hemisphere with energy flash
pokeball.bounce(Vector2(0, 100))
```
