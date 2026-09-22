# NEMI — ACTING & ANIMATION LANGUAGE V1 GUIDE
## Architectural Specification & Director API Reference

## 1. Core Philosophy: The Power of Stillness & Contrast

In the tradition of authentic YouTube storytime animatics (LilyPichu, Emirichu, Jaiden Animations, TheOdd1sOut), character acting relies on **contrast**, **timing**, and **holds**:

- **Nemi should NOT constantly move**: Over 85% of screen time consists of meaningful static **HOLDS**. Continuous rubber-hose puppet bobbing, idle breathing, and random blinking make a character look like a cheap AI puppet.
- **Stillness makes action meaningful**: A sequence of `HOLD` → `tiny eye glance` → `HOLD` → `head turn` → `HOLD` → `sudden physical action` → `FREEZE` → `AFTERMATH HOLD` delivers high comedic and dramatic impact.
- **Zero Image Dependencies**: 100% generated natively via Godot nodes, `Skeleton2D`, `Bone2D` transforms, and vector procedural face drawing controls.

---

## 2. Directory Architecture

```
characters/nemi/
├── nemi.tscn / nemi.gd                 # Master production character controller
├── animation/
│   ├── NemiActingDirector.gd          # Primary actor coordinator (nemi.actor)
│   ├── NemiSequence.gd                # Fluent / async composable action queue
│   ├── primitives/
│   │   ├── NemiMotionPrimitives.gd    # Holds, freezes, snaps, anticipation, overshoot, stepped motion
│   │   └── NemiTiming.gd              # Speed presets, intensities, standard hold durations
│   ├── actions/
│   │   ├── NemiEyeActing.gd           # Gaze vectors, eye darts, non-automatic blink variations
│   │   ├── NemiHeadActing.gd          # Turns, tilts, nods, head shakes, subtle posture tilts
│   │   ├── NemiBodyActing.gd          # Leans, shock recoils, posture shifts, gestures (point, wave, shrug)
│   │   └── NemiFaceActing.gd          # Expression transitions (normal, snap, delay, escalation) & accents
│   └── reactions/
│       └── NemiReactions.gd           # Composed reactions: Notice, Confusion, Realization, Shock, Deadpan, etc.
└── test/
    ├── NemiActingTest.tscn            # Interactive test harness with UI buttons & hotkeys
    ├── NemiActingTest.gd              # Harness running the 9 authoritative test sequences
    └── NemiTimingHUD.gd / .tscn       # Real-time visual Timing & Action monitor overlay
```

---

## 3. High-Level Acting API Reference

### 3.1 Stillness, Holds & Freezes
```gdscript
# Holds the character completely still for a specific duration.
# 0 unwanted movement, 0 breathing drift, 0 secondary sway.
await nemi.hold(0.45)

# Instantly freezes all running tweens and dampens momentum to 0.
nemi.freeze()

# Resets character to default neutral baseline
nemi.reset_state()
```

### 3.2 Eye Acting & Blinking
```gdscript
# Fast illustrated eye glance (discrete direction or Vector2)
await nemi.actor.eyes.look("right", "fast")
await nemi.actor.eyes.look(Vector2(-0.85, -0.1), "fast")

# Sharp eye dart that snaps immediately and holds for a beat
await nemi.actor.eyes.eye_dart("left", 0.15)

# Deliberate, non-automatic blinking modes
await nemi.actor.eyes.blink("normal")  # 0.16s standard organic dip
await nemi.actor.eyes.blink("quick")   # 0.10s snappy comedic pop
await nemi.actor.eyes.blink("double")  # Inquisitive double-blink
await nemi.actor.eyes.blink("delayed") # 0.28s slow awkward silence blink
await nemi.actor.eyes.blink("speech")  # Subtle dip during dialogue

# Pupil dilation / constriction
nemi.actor.eyes.widen(1.35, 0.12)  # Wide eyes for shock / realization
nemi.actor.eyes.squint(0.55, 0.15) # Suspicious / skeptical squint
```

### 3.3 Head Acting
```gdscript
# Head turn with natural neck coordination and secondary hair follow-through
await nemi.actor.head.turn(16.0, "fast") # Positive = right, Negative = left

# Subtle conversational head tilt
await nemi.actor.head.tilt(4.0, 0.18)    # 3° to 5° tilt

# Snappy affirmative nod
await nemi.actor.head.nod(1.0, 1)

# Disbelief / refusal head shake
await nemi.actor.head.shake_head(1.0, 2)
```

### 3.4 Body Acting & Gestures
```gdscript
# Torso lean with skirt compensation
await nemi.actor.body.lean(-14.0, 0.22)

# Sudden comedic shock recoil with screen trauma impulse
await nemi.actor.body.recoil(1.0, true)

# Posture adjustments
await nemi.actor.body.slouch(1.0, 0.3)
await nemi.actor.body.straighten(0.22)

# Pointing gesture with overshoot
await nemi.actor.body.point("right", "fast", true)

# Comedic shrug with raised shoulders and open hands
await nemi.actor.body.shrug(1.0, 0.35)

# Conversational wave gesture
await nemi.actor.body.wave("right", 2)

# Introverted hands held together
await nemi.actor.body.hands_together(0.25)

# Casual hands down
await nemi.actor.body.hands_down(0.2)
```

### 3.5 Facial Expression Transitions
```gdscript
# Transitions: "snap" (0-frame), "normal" (0.12s), "delay" (eyes first -> mouth after)
await nemi.actor.face.set_expression("shocked", "snap")
await nemi.actor.face.set_expression("deadpan", "snap")
await nemi.actor.face.set_expression("confused", "normal")

# Comedic expression escalation
await nemi.actor.face.escalate_expression(["neutral", "confused", "shocked"], [0.3, 0.4])

# Independent eyebrow control
nemi.actor.face.set_eyebrows("left", 8.0, 0.25) # Asymmetric brow raise

# Comic micro-accents
nemi.actor.face.set_accent("question", true)
nemi.actor.face.set_accent("sweat", true)
nemi.actor.face.set_accent("sparkles", true)
nemi.actor.face.set_accent("shock_lines", true)
```

---

## 4. Fluent Composable Sequencer (`NemiSequence`)

For complex cutscenes and multi-step comedic beats, use the chained fluent builder:

```gdscript
var seq := nemi.create_sequence()
seq.look("right") \
   .hold(0.20) \
   .head_turn(14.0, "fast") \
   .hold(0.15) \
   .set_expression("shocked", "snap") \
   .recoil(0.85, true) \
   .freeze() \
   .hold(0.80) \
   .reset()

await seq.play()
```

---

## 5. The 9 Authoritative Acting Tests

| Test | Key Beats & Acting Arc | Comedic / Dramatic Function |
| :--- | :--- | :--- |
| **1. Micro Acting** | `neutral` → `hold 0.8s` → `eyes look right` → `hold 0.3s` → `blink` → `tiny head tilt (4°)` → `hold 0.6s` | Subtle, intentional thinking beats without fidgeting. |
| **2. Conversational** | `neutral` → `eyes move right` → `head follows` → `eyebrow raise` → `small smile` → `hold` → `look away` | Natural dialogue flow where gaze leads head movement. |
| **3. Confusion** | `neutral` → `eyes up-left` → `pause` → `asymmetric brows` → `head tilt` → `question mark` → `hold` | Multi-stage cognitive processing. |
| **4. Realization** | `neutral` → `notice glance` → `eyes widen` → `short pause` → `brows up` → `gasp` → `head turn` | Graduated realization on an auditory or visual reveal. |
| **5. Shock & Recoil** | `neutral` → `eyes shift` → `pause 0.12s` → `shocked snap` → `body recoil` → `freeze` → `aftermath hold` | Sudden comedic shock with trauma shake and immediate freeze. |
| **6. Deadpan** | `neutral` → `subtle eye glance` → `tiny pause` → `3° head tilt` → `deadpan face` → `long hold 1.5s` | Unamused comedic contrast; dead silence hold. |
| **7. Comedic Timing** | `SETUP` (confident point) → `PAUSE 0.5s` → `REALIZATION glance` → `REACTION shock recoil` → `AFTERMATH HOLD 0.8s` | Classical comedy pacing: letting the punchline land. |
| **8. Exaggerated Action** | `neutral` → `anticipation crouch` → `snappy point with overshoot` → `settle` → `sudden recoil` → `freeze` | High-contrast physical cartooning. |
| **9. Novel Combination**| `lean back (-14°)` + `head right (+16°)` + `gaze left (-1.0)` + `brow raise` + `point up` + `open mouth` | Composition of reusable controls with zero new assets. |
