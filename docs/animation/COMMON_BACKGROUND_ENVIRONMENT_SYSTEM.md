# Common Background & Environment System
## Illustrated Environments, Paper Textures, and Staging Standards

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Shared across all storytime characters (Nemi, ADB, and future productions)  
**Location**: `docs/animation/COMMON_BACKGROUND_ENVIRONMENT_SYSTEM.md`

---

## 1. Visual Philosophy

> **SAME VISUAL LANGUAGE — DIFFERENT AUTHENTIC ENVIRONMENTS.**
> 
> Nemi and ADB share the illustrated sketchbook aesthetic, but they do NOT live in identical clones of the same room. Each character's living or studio space should reflect their individual personality, habits, and story context, while adhering to the common hand-drawn paper world standards.

---

## 2. Canvas & Paper Foundation

* **Base Paper Tones**:
  - `WARM_CREAM`: `#faf6ee` (Standard daytime sketchbook canvas).
  - `OATMEAL_PAPER`: `#f4ede2` (Slightly deeper organic paper texture).
  - `WARM_DUSK`: `#eae1d2` (Evening or introspective story beats).
  - `MIDNIGHT_SKETCH`: `#1c1f26` (Special inverted comic moments with cream ink `#faf6ee`).
* **Paper Texture Grain**: Subtle, non-distracting organic noise or parchment texture (`0.03`–`0.06` opacity) providing tactile depth without introducing digital noise.
* **Vignette**: Very soft, warm falloff around screen perimeters to focus attention inward toward the character and storytelling area.

---

## 3. Environmental Simplicity & Depth Layers

Backgrounds are minimalist and supportive; they never compete with the character or doodles for visual dominance.

```
┌────────────────────────────────────────────────────────┐
│ [LAYER 1: FAR BACKGROUND]                              │
│ Clean warm canvas, subtle room horizon or corner line  │
├────────────────────────────────────────────────────────┤
│ [LAYER 2: MIDGROUND ENVIRONMENT]                       │
│ Simplified sketched bookshelf, window frame, wall art  │
├────────────────────────────────────────────────────────┤
│ [LAYER 3: IMMEDIATE FURNITURE]                         │
│ Character's chair, desk, easel, coffee table           │
├────────────────────────────────────────────────────────┤
│ [LAYER 4: CHARACTER & DIRECT PROPS]                    │
│ Primary acting plane (Pelvis Y=0 grounded at floor)    │
└────────────────────────────────────────────────────────┘
```

---

## 4. Character-Specific Environment Personas

While maintaining the shared illustrated style:
* **Nemi's Environment**: Cozy, slightly cluttered artistic studio, warm wooden desk, ginger cat sleeping in corner, sketches pinned to wall, warm lamp glow.
* **ADB's Environment**: Clean, minimalist modern workspace, sleek desk with clean cable management, headphones hanging neatly, subtle anime or tech poster sketch in background, understated architectural lines.

---

## 5. Continuity Across Camera Cuts

1. **Spatial Consistency**:
   - If a desk sits on screen right in the wide shot, it must not magically appear on screen left when cutting to a medium shot.
   - Floor line and horizon angles must maintain perspective continuity.
2. **Visual Metaphor Cutaways**:
   - When the narrator launches into an anecdote (e.g., *"Picture this: high school hallway..."*), the background can smoothly wipe or pop into a stylized, abstract environment (classroom desk, street corner, cafe table), then snap back cleanly to the home room when the anecdote finishes.

## New scene/environment workflow

[Storytime Direction Workflow](STORYTIME_DIRECTION_WORKFLOW.md) provides room, paper, thought and evening shots, explicit actor blocking, and shared camera transforms. Cut when the thought changes; established scenery should not redraw continuously.
