# Common Handwriting System
## Organic Illustrated Lettering, Hand-Drawn Annotations, and Text-in-Scene Standards

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Shared across all storytime channels (Nemi, ADB, and future productions)  
**Location**: `docs/animation/COMMON_HANDWRITING_SYSTEM.md`

---

## 1. Core Principle

> **TEXT SHOULD LOOK DRAWN INTO THE ILLUSTRATION.**  
> 
> Words appearing in the frame are not UI elements or graphic overlays; they are annotations penned onto the sketchbook page by the illustrator as part of the live storytelling process.

---

## 2. The Strict NEVER List

* ❌ **NO Dialogue UI Boxes**: Never place text inside floating rounded rectangles, message cards, or comic UI speech boxes unless deliberately parodying a smartphone screen.
* ❌ **NO Corporate Callout Cards**: Never use drop shadows, flat vector badges, glassmorphic pill buttons, or corporate slide graphics.
* ❌ **NO Generic Handwriting-Font Look**: Avoid repetitive TTF fonts where every instance of the letter 'e' or 't' has the exact same identical vector shape.
* ❌ **NO Floating UI Labels**: Text must feel anchored to physical or conceptual space (next to a character, pointing to a prop, or scribbled as a margin note).

---

## 3. Visual Characteristics of Hand-Authored Lettering

1. **Irregular Baseline**:
   - The baseline gently waves, tilts, or angles upward slightly (+2° to +6°), reflecting natural human hand drift across paper.
2. **Organic Spacing & Kerning**:
   - Natural, human rhythm between characters. Letters are neither sterilely grid-locked nor awkwardly overlapping.
3. **Varied Sizing for Emphasis**:
   - Words emphasized by the speaker swell in scale (1.2x to 1.8x).
   - Quiet, sheepish confessions or parenthetical asides shrink down (0.7x to 0.85x) and tilt.
4. **Authored Accents**:
   - Text is accompanied by hand-drawn underlines (wavy or double charcoal strokes).
   - Arrows drawn from the text point directly at the subject being discussed.
   - Enclosing circles, squiggly brackets, or star doodles wrap around key punchline words.

---

## 4. Hierarchy and Placement

| Role | Usage | Styling | Placement |
|---|---|---|---|
| **Punchline Annotation** | Comedic realization or label | All-caps or bold script, high contrast, slight angle | Floating near character's head or gaze target |
| **Diagram Label** | Pointing out an absurd detail on a prop or doodle | Lowercase cursive or neat print with hand-drawn arrow | Directly pointing at the target element |
| **Aside / Muttering** | Quiet self-deprecating comment | Small, condensed, subtle ink wash | In negative space opposite the main character |
| **Sound Word (SFX Graphic)** | Dramatic impact or realization | Large bold calligraphic lettering | Overlapping the point of action |

---

## 5. Technical Implementation Guidelines

* When utilizing engine-native vector text or custom fonts (such as curated hand fonts like `Caveat-Bold` or `GochiHand-Regular`), always:
  1. Add subtle rotation (`-3.0°` to `+4.0°`) to prevent mechanical alignment.
  2. Pair with authored hand-drawn InkStroke underlines or circles.
  3. Ensure ink color matches the master contour `#2b2623`.
  4. Animate text entrance with a crisp snap-pop (`0.12s` scale from 0.85 to 1.0 with subtle overshoot), never a corporate slide-fade.

## Executable character handwriting profiles

New scenes must select an explicit Nemi or ADB profile through [Character Drawing Production Kit](CHARACTER_DRAWING_PRODUCTION_KIT.md). Shared stroke playback does not imply the same handwriting: use the separate authored letter alphabets and pen settings. Generic lettering remains a legacy fallback, not the default for both authors.
