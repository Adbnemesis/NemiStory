# Nemi — Expression FX & Visual Reaction System V1 (Guide & Specification)

## 1. System Overview

The **Nemi Expression FX & Visual Reaction System** is a 100% Godot-native, procedural vector illustration system designed to give Nemi an expressive, hand-drawn reaction vocabulary.

### Core Principles
1. **Zero External Raster Images / Stickers**: Every effect (sweat, blush, sparkles, shock rays, question marks, anger veins, lightbulbs) is drawn procedurally via Godot vector/curve calls with calligraphic stroke tapering (`InkStroke.gd`, `IllustrationCanvas2D.gd`).
2. **Bone2D Tracking**: FX dynamically anchor to Nemi's skeleton landmarks (`HEAD_TOP`, `HEAD_LEFT`, `HEAD_RIGHT`, `FACE_CENTER`, `CHEEKS`, `SHOULDER_LEFT/RIGHT`, `HAND_LEFT/RIGHT`, `TORSO_CENTER`) and follow head tilts, body recoils, and camera zooms organically.
3. **Controlled & Non-Destructive**: Cartoon deformations (e.g. shock eye widening, brow furrow, mouth scale) are strictly temporary via spring tween recovery back to base design proportions.
4. **Intensity Scaling (1–5)**: All FX scale artistically across intensities from subtle micro-ticks to comedic anime exaggeration.

---

## 2. Emotional Reaction Presets

Trigger complete modular compositions via `nemi.react(preset_name, intensity, duration)`:

| Preset Name | Composed Elements | Facial Exaggeration | Anchor | Default Duration |
| :--- | :--- | :--- | :--- | :--- |
| `"shocked"` / `"shock"` | Wide eyes, shock mouth, torso recoil, radial shock rays + exclamation | Eye scale 1.35x, mouth scale 1.45x | `HEAD_TOP` | 1.1s |
| `"confused"` / `"confusion"` | Eye shift, asymmetric brow furrow, head tilt, calligraphic `?` + squiggle | Eye scale 0.85x, brow compression 3.5 | `HEAD_RIGHT` | 1.4s |
| `"embarrassed"` | Eyes glance away, dual cheek blush hatches (`///`), awkward sweat drop | Eye scale 0.9x, mouth scale 0.8x | `CHEEKS` | 1.6s |
| `"nervous"` | Darting eyes, mouth `small_open`, teardrop sweat beads + jitter ticks | Subtle squint | `HEAD_RIGHT` | 1.3s |
| `"angry"` / `"anger"` | Compressed brows, mouth frown, hand-drawn stress vein (`💢`) + jagged spikes | Brow compression 6.0, mouth scale 1.25x | `HEAD_RIGHT` | 1.2s |
| `"excited"` / `"confident"` | Chest puff upright, wide smile, 4-point sparkle stars + radiant glimmer | Eye scale 1.2x, mouth scale 1.35x | `HEAD_LEFT` | 1.4s |
| `"realization"` / `"idea"` | Eye widen, brow raise, hand-drawn lightbulb doodle with glowing filament | Eye scale 1.2x | `HEAD_TOP` | 1.4s |
| `"panic"` | Multiple flying sweat drops, head vibration ripples, dark scribble cloud | Eye scale 1.4x, mouth scale 1.5x | `HEAD_TOP` | 1.3s |
| `"sad"` | Downward vertical gloom hatch lines, falling teardrop bead | Eye scale 0.85x, frown | `HEAD_LEFT` | 1.4s |
| `"relief"` | Gentle smile, soft head tilt, curving exhale breath swoosh (`💨`), soft sparkle | Neutral smile | `HEAD_RIGHT` | 1.3s |
| `"deadpan"` | Direct eye contact, neutral mouth, stillness hold, horizontal dash / `...` | Baseline proportions | `FACE_CENTER` | 1.6s |

---

## 3. Low-Level FX Primitives & API

You can also instantiate and fine-tune individual FX elements:

```gdscript
# Spawn specific FX element with custom anchor and intensity
nemi.fx("sweat", "head_right", 3, 1.2)
nemi.fx("shock", "head_top", 4, 1.0)
nemi.fx("sparkles", "head_left", 5, 1.5)

# Direct convenience helpers
nemi.show_sweat("head_right", 3)
nemi.show_question_mark("head_right", 2)
nemi.show_shock_lines("head_top", 4)
nemi.show_blush(3)
nemi.show_stress_marks("head_right", 4)
nemi.show_sparkles("head_left", 3)
nemi.show_lightbulb("head_top", 4)

# Visual attention directors
nemi.fx_director.draw_attention_circle(Vector2(50, -20), 42.0)
nemi.fx_director.draw_attention_arrow(Vector2(-60, -40), Vector2(0, 0))
nemi.fx_director.draw_attention_highlight(Vector2(0, 30), 75.0)

# Clear all active FX
nemi.clear_all_fx()
```

---

## 4. Anchor Landmarks

| Anchor Enum | String Key | Landmark Description |
| :--- | :--- | :--- |
| `HEAD_TOP` | `"head_top"`, `"top"` | Apex above hair crown and ahoge cowlick |
| `HEAD_LEFT` | `"head_left"`, `"top_left"` | Upper left hair crest |
| `HEAD_RIGHT` | `"head_right"`, `"top_right"` | Upper right hair crest |
| `FACE_CENTER` | `"face_center"`, `"face"` | Mid-face between eyes and nose |
| `CHEEKS` | `"cheeks"`, `"blush"` | Both cheeks simultaneously (dual blush) |
| `SHOULDER_LEFT` | `"shoulder_left"` | Left upper arm root |
| `SHOULDER_RIGHT` | `"shoulder_right"` | Right upper arm root |
| `HAND_LEFT` | `"hand_left"` | Left hand bone |
| `HAND_RIGHT` | `"hand_right"` | Right hand bone |
| `TORSO_CENTER` | `"torso_center"`, `"torso"` | Center chest / hoodie |
| `PROP_ANCHOR` | `"prop"`, `"custom"` | Arbitrary target position |

---

## 5. Intensity Scale (1 to 5)

- **Intensity 1 (Subtle)**: Delicate single line, tiny tick, understated micro-expression.
- **Intensity 2 (Mild)**: Clear visual accent, conversational reaction.
- **Intensity 3 (Normal / Default)**: Standard YouTube storytime reaction (e.g. clear question mark + squiggle, distinct sweat drop).
- **Intensity 4 (Strong)**: Bold emphasis, punchline accent.
- **Intensity 5 (Exaggerated / Comedic)**: Extreme anime recoil, double punctuation (`??`, `!!`), full radial burst, dark panic scribble cloud.

---

## 6. Entrance & Exit Styles

- **Entrances**:
  - `POP`: Fast overshoot scale bounce (ideal for shock, sweat, lightbulb).
  - `DRAW_ON`: Realistic line-growth along the stroke trajectory (ideal for arrows, circles, question marks).
  - `SNAP`: 1-frame instant cut-in (ideal for deadpan and rapid recoil).
  - `SLIDE`: Directional slide-in with overshoot (ideal for teardrops and sighs).
  - `FADE`: Smooth alpha blend (ideal for blush).
- **Exits**:
  - `FADE`: Alpha fadeout.
  - `ERASE`: Stroke un-draws or wipes away backwards.
  - `SNAP`: Immediate cut disappearance.
  - `SHRINK`: Scales down to zero.

---

## 7. Camera Reaction Helpers (`StoryCamera2D`)

```gdscript
# Dramatic or comedic closeup focusing on Nemi's face
camera.reaction_closeup(nemi.global_position, 1.85, 0.22)

# Punchline punch bump (zooms in 10% and bounces back)
camera.subtle_punch(1.10, 0.15)

# Multi-step zoom progression for rhythmic emphasis (e.g. "Half." -> "A." -> "Second.")
camera.face_zoom_progression(nemi.global_position, [1.5, 1.85, 2.2], 0.25)
```

---

## 8. Rendering & Layering Architecture (The `z_index = 25` Standard)

### 8.1 Foreground Layering Rule
To prevent reaction marks from rendering behind character geometry, both `NemiFXDirector` and all individual `NemiFXElement` instances are strictly assigned:
```gdscript
z_index = 25
```
This guarantees that vector reaction marks (sweat beads, blush hatches, shock rays, question marks) render **in front of** all character layers:
* Face visual: `z_index = 8`
* Bangs & fringe: `z_index = 7`
* Back & side hair: `z_index = 9`
* Limbs & torso: `z_index = 10`

### 8.2 Subtitle Collision Prevention
* Subtitle cards are anchored to the bottom edge of the screen (`offset_top = -85px`, `offset_bottom = -15px`).
* Expression FX dynamically track upper skeletal landmarks (`HEAD_TOP`, `HEAD_LEFT`, `HEAD_RIGHT`, `CHEEKS`).
* If a reaction occurs during a low-framing shot, FX must be shifted upward rather than shrunk. FX must never be obscured by subtitle cards.

### 8.3 FX Visibility & Timing Rules
* **Minimum Readable Hold**: Reaction marks must remain on screen for at least 0.8s to 1.6s so viewers can visually absorb the hand-drawn mark. Never trigger 0-frame or single-frame FX unless intentionally instantaneous.
* **Camera Distance Scaling**: When camera punches in to a tight close-up (1.5x+), FX elements naturally scale with character transform; ensure they remain within the visible canvas viewport.

