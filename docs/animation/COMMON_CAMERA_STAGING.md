# Common Camera & Staging System
## Cinematic Framing, Shot Presets, and Narrative-Driven Camera Language

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Shared across all storytime characters (Nemi, ADB, and future productions)  
**Location**: `docs/animation/COMMON_CAMERA_STAGING.md`

---

## 1. Core Rule

> **THE CAMERA RESPONDS TO THE STORY — NEVER TO AN ARBITRARY TIMER.**
> 
> ❌ **STRICTLY FORBIDDEN**: Continuous rhythmic zooming in and out (the "TikTok jitter" loop).  
> Camera movements must occur only at intentional narrative punctuation points: a comedic realization, an emotional whisper, a sudden shock, or a transition to an illustrated diagram.

---

## 2. Standardized Shot Presets

At native 1920×1080 resolution, camera framing maps to these standardized presets:

```
┌────────────────────────────────────────────────────────┐
│ WIDE SHOT (Scale 0.85x – 1.0x)                         │
│ Shows character seated/standing in full environment.   │
│ Use for: Intros, two-person dialogue, physical comedy. │
├────────────────────────────────────────────────────────┤
│ MEDIUM SHOT (Scale 1.15x – 1.25x) [DEFAULT BASELINE]   │
│ Torso up to head. Balances acting gestures & doodles.  │
│ Use for: General storytelling, explanations.           │
├────────────────────────────────────────────────────────┤
│ ASYMMETRIC / RULE-OF-THIRDS (Offset X ±220px)          │
│ Character pushed left or right, leaving open canvas.   │
│ Use for: Active doodle demonstrations, prop focus.     │
├────────────────────────────────────────────────────────┤
│ CLOSE-UP (Scale 1.45x – 1.65x)                         │
│ Chest, neck, and face. Intimate, focused.              │
│ Use for: Vulnerable confessions, whispers, realization.│
├────────────────────────────────────────────────────────┤
│ REACTION PUNCH-ZOOM (Scale 1.75x – 2.0x, Snap 0.10s)   │
│ Extreme focus on eyes/mouth with zero movement hold.   │
│ Use for: Comedic freeze, shock, deadpan disbelief.     │
└────────────────────────────────────────────────────────┘
```

---

## 3. Staging and Negative Space

1. **The 60/40 Rule**:
   - The character should never sit permanently dead-center in the screen.
   - Stage the character slightly off-center (e.g., `X = 720` or `X = 1200` on a 1920-wide canvas).
   - This leaves a dedicated 40% area of negative space for draw-on doodles, floating diagrams, and handwritten callouts that clarify the dialogue without obscuring the character's face or body.
2. **Eye Line & Headroom**:
   - Keep character eyes approximately at the upper third line (`Y ≈ 360` to `420`).
   - Avoid excessive dead headroom above the hair or cropping the chin inappropriately.

---

## 4. Camera Transitions

* **Snap Cuts (0.00s)**:
  - Instantaneous cut on sudden punchlines, blackout stamps, or scene transitions.
* **Punch Zooms (0.08s – 0.16s)**:
  - Rapid snap zoom with `Tween.TRANS_BACK` or `Tween.TRANS_CUBIC` and `Tween.EASE_OUT` for impactful emphasis.
* **Gentle Reframes (0.35s – 0.60s)**:
  - Smooth pan/zoom when the narrator turns from talking to the audience to examining a prop on their desk.
* **Comedic Hold After Zoom**:
  - Whenever the camera punches into a close-up, lock the camera position rigidly. Do not let it drift or wander.
