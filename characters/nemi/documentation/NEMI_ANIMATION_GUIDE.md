# NEMI — 2D Character Animation Guide & Reference

Authoritative Visual Reference: `references/main_character/nemi_sheet.png`  
Engine Architecture: Godot 4 (Compatibility Renderer, 1280×720 Storytime Canvas)

---

## 1. Character Identity & Visual Standards

Nemi is the main protagonist of this illustrated storytelling universe. Her visual identity is locked and authoritative.

| Trait | Canonical Specification | Palette Reference |
| :--- | :--- | :--- |
| **Hair** | Long flowing reddish-ginger anime hair with ahoge flick | `#c54d42` |
| **Eyes** | Expressive anime emerald green eyes | `#245e43` / `#368d5f` |
| **Skin** | Fair / light anime skin tone with subtle warm peach blush | `#fadcc2` / `#f3b79d` |
| **Top** | Sage green oversized hoodie with drawstring neck | `#678d5f` |
| **Skirt** | Dark forest green pleated tennis skirt | `#354d44` |
| **Footwear**| White sport crew socks, white chunky sneakers with green accents | `#ffffff` / `#678d5f` |
| **Bag** | Dark forest green shoulder bag with leaf emblem | `#2f3330` |
| **Lineart** | Warm dark mahogany / burgundy storytime contour lines | `#3e081e` |

---

## 2. Character Architecture & Assets

All assets are cleanly separated with transparent alpha, preserving internal highlights and edges.

### 2.1 The 15 Canonical Story Poses (`characters/nemi/art/poses/`)

| Type | Pose Name | Filename | Description / Story Purpose |
| :--- | :--- | :--- | :--- |
| **Full-Body** | `standing` | `pose_standing.png` | Baseline relaxed neutral story pose |
| **Full-Body** | `walking` | `pose_walking.png` | Lateral walking cycle pose |
| **Full-Body** | `running` | `pose_running.png` | High-energy hurry / running action |
| **Full-Body** | `pointing` | `pose_pointing.png` | Directing attention / presentation |
| **Full-Body** | `sitting` | `pose_sitting.png` | Floor / bench sitting with knees up |
| **Bust** | `thinking` | `pose_thinking.png` | Hand to chin contemplative pose |
| **Bust** | `shrugging` | `pose_shrugging.png` | Comedic "I don't know" shrug |
| **Bust** | `leaning` | `pose_leaning.png` | Conversational engagement lean |
| **Bust** | `looking_up` | `pose_looking_up.png` | Upward gaze / daydreaming |
| **Bust** | `looking_down` | `pose_looking_down.png` | Introspective / somber reflection |
| **Bust** | `surprised` | `pose_surprised.png` | Hands tucked, wide-eyed reaction |
| **Bust** | `excited` | `pose_excited.png` | Raised arm cheer gesture |
| **Bust** | `angry` | `pose_angry.png` | Crossed arms pout |
| **Bust** | `sad` | `pose_sad.png` | Gentle downcast emotional pose |
| **Bust** | `laughing` | `pose_laughing.png` | Hands on cheeks happy laugh |

> [!NOTE]
> All full-body poses share ground-aligned bottom-center anchoring (`offset = (0, -height/2)` with `centered = true`). Swapping between `standing`, `walking`, `running`, `pointing`, and `sitting` keeps Nemi's feet planted on the floor line with zero vertical drift.

---

### 2.2 The 12 Facial Expressions (`characters/nemi/art/expressions/`)

For medium close-up and close-up conversational framing:

1. `neutral`: Baseline calm, friendly listening expression.
2. `happy`: Warm, closed-eye smiling expression (`^ ^`).
3. `excited`: Bright open smile with sparkle star accent (`✦`).
4. `confused`: Tilted head with cute question mark accent (`?`).
5. `angry`: Fierce, determined furrowed brow.
6. `sad`: Soft wistful frown and downcast gaze.
7. `surprised`: Wide open gasp with sparkle accents.
8. `embarrassed`: Soft averted gaze with prominent blush.
9. `smug`: Playful smirk with confident side-eye glance.
10. `annoyed`: Pouting face with anime frustration sweat mark (`💢`).
11. `shocked`: Stunned open mouth with pupil dilation.
12. `laughing`: Cheerful open-mouthed laughter.

---

### 2.3 Micro-Events & Sub-Frames (`characters/nemi/art/micro/`)

1. `micro_blink.png`: Closed eyelid sub-frame for 2-frame natural blinks.
2. `micro_eye_dart.png`: Sharp directional glance inset for comedic attention shifts.
3. `micro_eyebrow_raise.png`: Eyebrow pop reaction inset for inquisitive beats.
4. `micro_mouth_open.png`: Talking vowel / open mouth sub-frame.
5. `micro_mouth_close.png`: Closed resting mouth sub-frame.

---

### 2.4 Story Props & Accessories (`characters/nemi/art/props/`)

1. `prop_phone.png`: Handheld smartphone.
2. `prop_laptop.png`: Open laptop computer for desk/study scenes.
3. `prop_drink.png`: Iced coffee / matcha cup with straw.
4. `prop_bag.png`: Dark green backpack with leaf emblem.
5. `prop_snacks.png`: Snack bag of chips for casual storytelling.
6. `prop_speech_bubble.png`: Clean illustrated dialogue bubble.

---

## 3. High-Level GDScript API (`Nemi.gd`)

The `Nemi` class provides an AI-friendly, declarative script interface designed for storytime animatic directors.

### 3.1 Poses & Expressions
```gdscript
# Instant 0-frame pose swap
nemi.pose("standing")
nemi.pose("running")
nemi.pose("excited")

# High-detail bust facial expression swap
nemi.expression("neutral")
nemi.expression("smug")
nemi.expression("annoyed")
```

### 3.2 Micro-Interactions
```gdscript
# 2-frame natural blink (open -> closed -> open in 0.08s)
await nemi.blink(0.08)

# Directional eye glance reaction
await nemi.eye_dart("left", 0.4)

# Inquisitive eyebrow pop
await nemi.eyebrow_raise(0.4)
```

### 3.3 Props
```gdscript
# Equip prop with custom anchor offset
nemi.equip_prop("drink", Vector2(40, -50))
nemi.equip_prop("laptop", Vector2(10, -20))

# Unequip prop
nemi.unequip_prop()
```

### 3.4 Storytime Animatic Motion
```gdscript
# Stepped bounce on 2s (rhythmic talking animation at 6 Hz, held on 2s)
nemi.start_stepped_bounce(16.0, 6.0)
await get_tree().create_timer(1.5).timeout
nemi.stop_stepped_bounce()

# Sudden comedic recoil back with overshoot & freeze
nemi.recoil(Vector2(-35, 12), 0.12)

# Impact trauma screenshake
nemi.shake(0.8, 4.0)

# Leaning into dialogue
nemi.lean(5.0, 0.12)
nemi.reset_lean(0.1)

# Horizontal flip
nemi.set_flip_h(true)  # Face left
nemi.set_flip_h(false) # Face right
```

---

## 4. Verification & Showcase Scenes

- **Asset Overview Contact Sheet**: `characters/nemi/art/nemi_asset_overview.png`
- **Godot Showcase Scene**: `res://scenes/showcase/nemi_showcase.tscn`
- **Showcase Script**: `res://scenes/showcase/nemi_showcase.gd`
- **Rendered Output Video**: `renders/nemi_showcase.mp4`
