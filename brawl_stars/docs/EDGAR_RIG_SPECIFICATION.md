# EDGAR — Reusable Brawl Stars Character Rig Specification

## Overview
**Edgar** is the Epic Assassin and Gift Shop attendant of Brawl Stars, reinterpreted into our **hand-drawn illustrated YouTube storytelling aesthetic**.
The rig is 100% native Godot 2D procedural vector art (`CanvasItem._draw()`, `CosmoInkStroke.gd`), strictly self-contained within `brawl_stars/` with zero runtime dependencies on external character modules.

---

## Node Hierarchy & Z-Ordering

```
Edgar (Edgar.gd - Master Director)
└── EdgarVisual (EdgarVisual.gd - Coordinate, Style & Pivot Manager)
    ├── Limbs (EdgarLimbs.gd, z_index = 1, pos = Vector2(0, -25))
    │   ├── Charcoal skinny emo jeans (#1e1b24) with bold crimson side pinstripe (#dc2626)
    │   ├── Chunky black emo creeper shoes (#111827) with thick grey platform rubber soles (#4b5563)
    │   └── Hands (natural warm light skin #f6d8be, fingerless purple knit gloves #6b21a8 with white "X" stitches):
    │       ├── "idle_hands" (hands loosely hanging or tucked in vest)
    │       ├── "holding_phone" (gripping dark smartphone scrolling toxic Starr Park social media)
    │       ├── "fists_clenched" (angsty clenched fists held tense by sides)
    │       ├── "arms_crossed" (sullen crossed arms posture)
    │       └── "panic_flail" (dramatic teenage emo panic)
    ├── Torso (EdgarTorso.gd, z_index = 2, pos = Vector2(0, -85))
    │   ├── Black undershirt (#18181b) with distressed white punk skull graphic (#f4f4f5)
    │   ├── Deep crimson sleeveless punk vest (#991b1b, shadow #7f1d1d) with notched lapels
    │   ├── Lapel badges: Starr Park logo pin (#e11d48) & acidic yellow smiley face (#facc15)
    │   └── Studded emo belt (#09090b) with metallic grommets & light blue skull buckle (#7dd3fc)
    ├── Scarf (EdgarScarf.gd, z_index = 4, pos = Vector2(0, -90))
    │   ├── Living sentient knit scarf with alternating purple (#6b21a8) & white (#f8fafc) stripes
    │   ├── Bulky layered neck cowl wrap with procedural respiratory breathing oscillation
    │   ├── Left and right animated scarf arms with articulated demon fist knuckles:
    │   │   ├── "idle_drape" (casually hanging down with organic physics sway)
    │   │   ├── "crossed" (scarf arms crossed over chest in haughty contempt)
    │   │   ├── "punch_ready" (coiled spring-loaded demonic fists prepared to strike)
    │   │   ├── "thumbs_down" (notorious toxic thumbs-down emote fist)
    │   │   └── "facepalm" (scarf fist covering Edgar's exasperated face)
    │   └── Punching extension mechanics with velocity impact shockwaves
    └── HeadPivot (Node2D, z_index = 5, pos = Vector2(0, -170) + head_offset)
        ├── Head (EdgarHead.gd, z_index = 0)
        │   ├── Natural warm light skin base (#f6d8be, shadow #d89e72) with silver gothic ear stud piercings
        │   ├── Jet-black sweeping emo bangs (#09090b) completely masking the right eye
        │   └── Spiky layered punk hair crest on the left crown with calligraphic ink strokes
        └── Face (EdgarFace.gd, z_index = 1)
            ├── Visible left eye: blank white emo pupil/sclera with thick heavy black eyeliner
            ├── Purple fatigue under-eye bags (#c084fc, 70% alpha) from staying up scrolling
            ├── Curved ink nose bridge arc above mouth
            ├── Dynamic eyebrow (scowl, disdain, surprise, sarcastic arch)
            ├── Emo mouth visemes (sneer, sigh, grimace, open shout, smirk)
            └── Expressive FX Overlays (Sweat Drop, Anger Cross, Dark Despair Lines, Toxic Sparkle)
```

---

## Directorial API (`Edgar.gd`)

### 1. Emotional Expressions (14-State Matrix)
```gdscript
edgar.set_expression(expr_name: String)
```
| Expression | Eye State | Eye Openness | Eyebrow State | Mouth Shape | Head Tilt | Special FX Overlays |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `"neutral"` | blank_white| 1.0 | `"low"` | `"grimace"` | 0.0 | None |
| `"brooding"` | squint | 0.7 | `"frown"` | `"grimace"` | 0.08 (+5°) | Dark Despair Lines |
| `"sigh"` | squint | 0.5 | `"low"` | `"sigh"` | -0.10 (-6°) | Dark Despair Lines |
| `"annoyed"` | squint | 0.8 | `"frown"` | `"grimace"` | 0.06 | Anger Cross Mark |
| `"enraged"` | wide | 1.3 | `"frown"` | `"shout"` | 0.0 | Anger Cross Mark |
| `"disgusted"` | squint | 0.6 | `"frown"` | `"grimace"` | 0.14 (+8°) | None |
| `"cynical"` | squint | 0.75 | `"arch"` | `"smirk"` | -0.08 | None |
| `"toxic_smug"`| squint | 0.8 | `"arch"` | `"smirk"` | 0.12 (+7°) | Toxic Sparkle |
| `"sarcastic"` | blank_white| 0.9 | `"arch"` | `"smirk"` | 0.10 | None |
| `"panicked"` | shock_dot | 1.4 | `"high"` | `"open_talk"` | -0.12 | Sweat Drop |
| `"shocked"` | shock_dot | 1.45 | `"high"` | `"open_talk"` | 0.0 | Sweat Drop |
| `"deadpan"` | squint | 0.45 | `"flat"` | `"grimace"` | 0.0 | None (0-motion hold) |
| `"triumphant"`| squint | 0.85 | `"arch"` | `"smirk"` | 0.10 | Toxic Sparkle |
| `"tsundere"` | squint | 0.7 | `"frown"` | `"grimace"` | -0.14 | Sweat Drop |

---

### 2. Body Posing & Staging
```gdscript
edgar.set_pose(pose_name: String, duration: float = 0.2)
```
- `"idle"`: Sullen slouch stance (shoulders slouched, scarf subtly breathing, weight on one heel).
- `"sullen_slouch"`: Deep teenage angst slouch (torso lean forward +0.16 rad, hands in pockets).
- `"phone_scroll"`: Addicted phone posture (head bowed forward, holding phone, thumb scrolling).
- `"scarf_punch_prep"`: Coiled assassin ready stance (torso lean back -0.15 rad, scarf fists raised).
- `"toxic_pin"`: Showboat victory stance (torso upright, scarf displaying thumbs-down).
- `"deadpan_freeze"`: 100% rigid 0-motion freeze (slumped posture, flat glare, 0 procedural motion).
- `"recoil"`: Backward stagger (-0.26 rad, dramatic emo despair recoil).

---

### 3. Gaze & Eye Tracking
```gdscript
edgar.set_gaze(direction: Vector2)              # Normalized vector (-1.0 to +1.0)
edgar.look_at_point(global_pos: Vector2)         # Calculates vector toward world point
edgar.blink()                                    # Snappy 0.14s eye blink
edgar.double_blink()                             # Natural double-blink sequence
```

---

### 4. Live Illustrative Lip-Sync & Speech Visemes
```gdscript
# Text-Driven Speech with syllabic timing (~12-15 FPS cadence)
await edgar.speak(text: String, duration: float = -1.0, emotion: String = "normal")

# Audio-Driven Speech locked to recorded .wav voice tracks
await edgar.speak_audio(audio_path_or_stream: Variant, text: String = "", emotion: String = "normal")

# Immediate speech cessation and clean rest-shape closure
edgar.stop_speech(rest_shape: String = "deadpan")
edgar.is_speaking() -> bool

# Manual viseme and syllable overrides
edgar.set_viseme(viseme: String)
edgar.talk_syllable(viseme: String = "small_open", duration: float = 0.15)
```
- **Canonical Speech Visemes (Articulating Above Knit Scarf Collar)**:
  - `"closed"`: Tight cynical lip seal (for M, P, B consonants and pauses).
  - `"small_open"`: Narrow conversational slit with dark interior (consonants and unstressed vowels).
  - `"ae"`: Wide cynical horizontal speech opening (*"cat"*, *"say"*, *"whatever"*, *"super"*).
  - `"o_u"`: Rounded pursed pouty "O" shape peeking over scarf collar (*"you"*, *"who"*, *"no"*).
  - `"wide"`: Wide indignant sarcastic exclamation opening for dramatic outbursts.
  - `"smirk"`: Sarcastic one-sided smirk.
  - `"deadpan"`: Signature flat cynical horizontal line (`--`).
  - `"shout"`: Rare explosive breakdown shout with gaping dark interior.
  - `"sarcastic_frown"` / `"frown"`: Downturned sneer.
- **Emotion Precedence**: During deadpan and cynical deliveries, viseme movement is tightly restrained with narrow openings to preserve his signature unbothered emo persona. When rage screams hit, wide jaw drops take precedence.

---

### 5. Sentient Scarf Directorial Controls
```gdscript
edgar.set_scarf_state(state: String)            # "idle_drape", "crossed", "punch_ready", "thumbs_down", "facepalm"
edgar.trigger_scarf_punch(side: String, target_offset: Vector2) # High-velocity punch extension
edgar.set_phone_visible(visible: bool)          # Toggle smartphone prop
edgar.set_art_mode(EdgarStyle.ArtMode.COLOR)    # Full canonical emo punk palette
edgar.set_art_mode(EdgarStyle.ArtMode.MONOCHROME)# Hand-drawn ink-wash storytime rendering
```

---

## Storytime Reaction Doodling (`EdgarDoodleDirector.gd`)

Implements the hand-drawn sketch overlay sequence: **DRAW -> HOLD -> ERASE**.
- `spawn_scarf_punch(from, to)`: Demon fist impact burst with calligraphic "WHAM!" lettering and speed streaks.
- `spawn_thumbs_down_badge(pos)`: Notorious red toxic thumbs-down circular badge with salty sprinkles.
- `spawn_super_jump_arc(start_pos, apex_pos, crash_pos)`: Parabolic vault trajectory ending in a disastrous failure "X".
- `spawn_emo_stormcloud(pos, size)`: Raincloud hovering over head with descending rain streaks and lightning zigzag.
- `spawn_chat_alert(pos, text)`: Toxic notification pop-up bubble with red exclamation mark.
- `spawn_annotation(pos, text)`: Handwritten calligraphic emo complaint with ink underline.

---

## Showcase Test Harness (`brawl_stars/scenes/EdgarShowcase.tscn`)

Interactive directorial test harness featuring a 24-step automatic sequence:
- **Steps 1–14**: All 14 emotional expressions with blank white eyeliner eyes, dynamic brow, and visemes.
- **Steps 15–18**: Saccadic gaze tracking, double blinks, and living scarf breathing sway.
- **TEST A**: High-speed double scarf punch with "WHAM!" doodle and screen shake.
- **TEST B**: Toxic thumbs-down emote pin celebration with salty sprinkles doodle.
- **TEST C**: Super jump catastrophe into Shelly super blast (jump arc doodle + fail "X").
- **TEST D**: Sullen phone doomscrolling session with toxic chat alert.
- **TEST E**: Comedic deadpan hold (0-motion freeze after an awkward customer interaction).
- **Art Mode**: Monochrome ink-wash storytelling mode switch.
