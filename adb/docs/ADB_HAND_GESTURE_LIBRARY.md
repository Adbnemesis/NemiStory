# ADB Hand Gesture Library
## Independent Hand Shapes, Prop Grips, and Gesture Standards

**Document Status**: LOCKED & AUTHORITATIVE HAND SPECIFICATION  
**Character**: ADB (Independent Storyteller)  
**Location**: `adb/docs/ADB_HAND_GESTURE_LIBRARY.md`

---

## 1. Hand Design Philosophy

> **ADB HANDS ARE AUTONOMOUS, SLENDER, AND EXPRESSIVE.**
> 
> ADB's hands do not share Nemi's hand assets or geometry. ADB has slightly more elongated, slender fingers, refined knuckle tapers, and a modern illustrated drawing style adhering to the `#2b2623` master contour ink.

---

## 2. Core Hand Shape Catalog

The ADB hand controller supports discrete, hand-authored vector hand shapes selectable for left and right wrists independently:

```
  RELAXED               OPEN_PALM             POINTING
   ╭───╮                 ╭───╮                 ╭───╮
  │ │ │ │               │ │ │ │               │ ┃ │ │
  │ │ │ │               │ │ │ │               │ ┃ │ │
   ╰───╯                 ╰───╯                 ╰───╯
(Gentle rest)        (Presenting / Honest)   (Clean index finger)

   FIST                  THUMB_UP              SHRUG_UP
   ╭───╮                   ▲                   ╭───╮
  │█ █ █│                 ╭┴──╮               │ \ / │
  ╰─────╯                 │█ █│                ╰───╯
(Clenched resolve)   (Approval / Affirm)     (Palms up angled)

 HOLDING_PHONE         HOLDING_CUP           HAND_TO_CHIN
   ╭───╮                 ╭───╮                 ╭───╮
  │ 📱  │                │ ☕  │                │ 💭 │
   ╰───╯                 ╰───╯                 ╰───╯
(Grip around edge)   (C-curl fingers)       (Index along jaw)
```

| Hand ID | Anatomical Configuration | Directorial Usage |
|---|---|---|
| `relaxed` | Natural soft curl; fingers gently separated; thumb resting along index. | Default resting state when arm is at side or on lap. |
| `open_palm` | Fingers extended and slightly spread; palm facing upward or toward viewer. | Explaining, welcoming, presenting ideas, honest confessions. |
| `pointing` | Index finger extended straight; middle, ring, pinky curled; thumb resting. | Pointing to diagrams, doodles, text callouts, or comedic targets. |
| `fist` | All four fingers curled into palm; thumb tucked across first knuckles. | Comedic determination, suppressed frustration, intense focus. |
| `thumb_up` | Fist with thumb extended upright in confident angle. | Approval, sarcastic affirmation, casual agreement. |
| `shrug_open` | Fingers fanned outward, wrist rotated supine (palms facing skyward). | "Who knows?", "Not my problem", baffled comedy shrugs. |
| `holding_phone`| Fingers curled around phone chassis; thumb resting above touchscreen. | Texting montage, checking notifications, showing screen to camera. |
| `holding_cup` | Fingers forming an organic 'C' clamp around mug body; thumb on rim. | Drinking coffee, holding tea, casual relaxed sitting. |
| `holding_book` | Palm flat supporting notebook back; thumb curled over front edge. | Holding sketchbook, reading notes, showing drawing. |
| `hand_to_chin` | Index finger extended along jawline; knuckle supporting chin; thumb tucked. | Deep thought, inspecting artwork, calculating problem. |
| `waving` | Open palm with fingers together, oscillating gently left-right. | Friendly intro greeting or outro farewell. |
| `reaching` | Fingers slightly curved forward in foreshortened reach toward lens. | Dramatic comedy grab, reaching for fallen object. |

---

## 3. Prop Attachment Anchors

Every hand shape features an internal attachment anchor coordinate (`prop_anchor: Vector2`):
- When a prop (such as `PropPhone` or `PropCup`) is attached to ADB's hand, it binds automatically to the hand's anchor point and inherits arm motion and rotation seamlessly.
- Ensures zero prop drift or floating during animated gestures.
