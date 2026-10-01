# Common Hand-Drawn Doodle System
## Authored Vector Doodles, Visual Metaphors, and Stroke Sequencing

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Shared across all storytime characters (Nemi, ADB, and future productions)  
**Location**: `docs/animation/COMMON_HAND_DRAWN_DOODLE_SYSTEM.md`

---

## 1. What "Hand-Drawn" Means

> [!CRITICAL]
> **HAND-DRAWN MEANS AUTHORED DRAWING.**
> * It is **NOT** a perfect geometric SVG icon.
> * It is **NOT** a circle primitive with random noise/jitter code added.
> * It is **NOT** a stock-vector icon downloaded from the web.
> * It is **NOT** a mathematical Bézier spline with perfectly uniform tangency.
> 
> A hand-drawn doodle is an **individually authored path** with intentional, human imperfections: slight wobble, pressure taper at line ends, corners where strokes intersect, and organic rhythm.

---

## 2. Inking Standards & Color Palette

* **Primary Ink Contour**: `#2b2623` (Deep charcoal sepia).
* **Accent Highlight Color**: `#d97706` (Warm amber gold), `#dc2626` (Crimson punch), or `#0284c7` (Cool azure).
* **Fill Style**: Either no fill (pure linework), light watercolor-style wash (opacity `0.15`–`0.35`), or calligraphic hatch lines.
* **Line Weight Range**: `2.8px` to `4.5px` stroke thickness, varying along the length of the stroke.

---

## 3. Core Doodle Anatomy Catalog

```
   Imperfect Circle         Authored Arrow         Sparkle / Star
      ╭──────╮                  ───╮                  ╲  │  ╱
     ╱        ╲                    │                   ──┼──
    │          │             ◄─────╯                  ╱  │  ╲
     ╲        ╱              
      ╰──────╯
  (Never pure circle)     (Organic curved path)   (Hand-flicked rays)

   Irregular Underline        Thought Scribble         Emphasis Brackets
     ~-~~--~-~~                 ( ꩜ ꩜ ꩜ )                 ╭─       ─╮
    (Double or wavy)        (Messy knot / spiral)         ╰─       ─╯
```

### 1. Imperfect Circles & Enclosures
- Drawn in 1 or 2 distinct strokes.
- Start and end points do not perfectly overlap; the tail may overshoot or slightly miss the head.
- Shape is an organic oval or soft lozenge, never mathematically round.

### 2. Hand-Drawn Directional Arrows
- Shaft is drawn with a graceful organic curve, bending naturally under the imaginary wrist.
- Arrowhead consists of two separate flick strokes meeting at an acute apex, slightly asymmetrical.

### 3. Authored Stars & Sparkle Bursts
- Central four-point diamond star with subtle curvature or 4–8 radiating flick strokes.
- Each ray has individual length variation, mimicking quick pen marks in a margin.

### 4. Underlines & Highlighting Scribbles
- Dual wavy lines, gentle zigzag underlines, or irregular rectangular brackets around key words.
- Never a straight ruler line.

### 5. Thought & Confusion Scribbles
- Tightly wound charcoal spiral knots indicating confusion, dizziness, or chaotic thoughts.
- Angular lightning or jagged zigzags indicating sudden realization or shock.

---

## 4. Draw-On Animation & Stroke Sequencing

To create the illusion that the illustration is being drawn live while the narrator speaks:

1. **Progressive Stroke Reveal**:
   - Doodles should draw on using path percentage (`0.0` to `1.0`) over `0.12s` to `0.30s`.
   - Use `Tween.TRANS_CUBIC` or `Tween.TRANS_QUAD` with `Tween.EASE_OUT` so the stroke decelerates naturally as the pen finishes.
2. **Stroke Order Hierarchy**:
   - Main shape / outline draws first.
   - Accents (arrows, sparkles, hatch lines) draw sequentially, staggered by `0.05s`–`0.10s`.
3. **Punctuation Hold**:
   - Once drawn, doodles stay completely stable during the line or hold for comedic impact.
   - Do not vibrate, wobble, or loop jitter while on screen.

---

## 5. Visual Metaphor Rules

* **Direct Support**: Doodles must explain or satirize what the character is talking about (e.g., a tiny schematic, an exaggerated graph, a tangled yarn ball representing anxiety).
* **Zero Visual Clutter**: Remove or pop-dissolve doodles the instant the narrator shifts to a new topic. Maximum 1–3 doodle elements visible simultaneously.

## Separate drawing hands for new scenes

Use [Character Drawing Production Kit](CHARACTER_DRAWING_PRODUCTION_KIT.md) for authored per-character marks, pen cadence, correction habits, and exact cue fields. Completed strokes stay still; author different geometry rather than applying random wobble to identical assets.
