# Common Prop System
## Hand-Drawn Prop Philosophy, Depth Layering, and Character Interaction Standards

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Shared across all storytime characters (Nemi, ADB, and future productions)  
**Location**: `docs/animation/COMMON_PROP_SYSTEM.md`

---

## 1. Core Philosophy

> **PROPS MUST FEEL HAND-DRAWN, SCENE-SPECIFIC, AND AUTHORED.**
> 
> A prop is never just "an icon dropped onto the screen." Every mug, phone, notebook, microphone, or pencil must look as if it was sketched by the same artist who drew the character and the environment, utilizing the same charcoal ink, paper lighting, and organic imperfections.

---

## 2. Aesthetic Standards

* **Organic Contour Inking**: Every prop uses the master `#2b2623` charcoal contour line with subtle line-weight tapering (`2.5px`–`3.8px`).
* **Subtle Asymmetry**: A coffee mug's handle has slight organic thickness variation; a laptop screen has softly rounded hand-drawn corners; a notebook page has an organic wave.
* **Muted, Harmonious Shading**: Shading uses 1–2 flat color tones with warm shadows matching the paper base (`#faf6ee`).
* **The Anti-Pattern List**:
  - ❌ No sterile SVG icons downloaded from stock libraries.
  - ❌ No pure mathematical geometry (perfect circles, razor-sharp rectangles).
  - ❌ No gradients with sterile computer-generated linear blends.
  - ❌ No generic placeholders or disconnected 3D renders.

---

## 3. Physical Placement & Surface Grounding

1. **Believable Contact**:
   - Props resting on surfaces (desks, tables, floors) must have a clear baseline or cast shadow grounding them. They must never hover in mid-air.
2. **Chair & Desk Interactions**:
   - When a character is seated, the chair seat, desk surface, and character body parts must respect physical volume.
   - Legs go under the desk; forearms rest on top of the desk; hands wrap cleanly around objects.
3. **Holding Props**:
   - Hands must grip props purposefully. Fingers curl over the handle or chassis; thumbs lock over the rim or screen.
   - The prop must attach to the hand/wrist coordinate space so when the arm moves or gestures, the prop moves naturally with it.

---

## 4. Depth Ordering & Z-Index Hierarchy

To prevent awkward visual clipping and layering artifacts, follow this standardized depth stack:

```
[Layer 10: Foreground Annotations]   <-- Draw-on subtitles, emphasis scribbles
[Layer 9:  Foreground Acting Hand]   <-- Hand reaching toward camera or over prop
[Layer 8:  Active Held Prop]         <-- Phone, mug, stylus currently being held
[Layer 7:  Character Torso / Face]   <-- Head, torso, facial expressions
[Layer 6:  Character Secondary Arm]  <-- Arm resting behind or along side
[Layer 5:  Interactive Surface Props]<-- Laptop, desk items, papers on desk
[Layer 4:  Foreground Furniture]     <-- Desk top, counter surface
[Layer 3:  Character Lower Body]     <-- Legs, chair seat
[Layer 2:  Background Furniture]     <-- Chair backrest, rear wall elements
[Layer 1:  Paper Backdrop]           <-- Base warm canvas, room outline
```

---

## 5. Prop Lifecycle in Storytime Beats

* **Entrance**: Props appear with intention: either already present in the environment (world staging), brought into frame by the character's hand, or popping on screen simultaneously with a crisp sound effect (`pop.mp3`, `click.mp3`).
* **Purpose**: Props exist to support an anecdote. If a prop is no longer relevant to the conversation, smoothly dismiss it or transition the camera.

## Executable prop contact for new scenes

Use version 2 of [Storytime Direction Workflow](STORYTIME_DIRECTION_WORKFLOW.md): choose a fully drawn prop, an existing supported grip, a prop-local contact point, and the hand socket. The stage updates contact after acting and keeps world/parent scales consistent. Do not substitute a new hand renderer.
