# NEMI — RIG V1 MASTER ARCHITECTURE & CONTROLLER GUIDE

## 1. Executive Summary

**Nemi Rig V1** transforms the approved hand-drawn Nemi character artwork into a **real, live, articulated 2D character** inside Godot 4.3+.

- **Zero Image Dependencies**: Zero PNGs, zero JPGs, zero sprite crops, zero frame-by-frame sheets. Every pose, gesture, glance, and expression is generated purely via Godot nodes, `Skeleton2D`, `Bone2D`, transforms, and procedural vector drawing.
- **Approved Art Preserved**: The character's approved visual design, silhouette, color palette, and illustration language are 100% locked and preserved.
- **Live Articulated Rig**: Full body skeleton controlling torso, neck, head, arms, elbows, hands, skirt, legs, knees, ankles, feet, and independent hair masses with secondary motion.
- **Procedural Facial System**: Live continuous eye gaze, pupil scaling, programmatic in/out blink tweening, independent eyebrow raising/tilting, vector mouth shapes, and comic micro-accents.
- **Dual-Mode System**: Instantaneous switching between canonical **COLOR Mode** and **FINISHED MONOCHROME Ink Mode** on the exact same character instance.

---

## 2. Articulated Bone Hierarchy & Pivots

```
Skeleton2D
│
└── RootBone (Pelvis origin: (0, 0))
    ├── TorsoBone (Body lean / chest pivot: (0, 0))
    │   ├── TorsoVisual (Hoodie, cowl collar, drawstrings — z_index: 5)
    │   ├── BagVisual (Crossbody bag — z_index: 11)
    │   │
    │   ├── NeckBone (Pivot: (0, -74))
    │   │   ├── NeckVisual (Slender neck — z_index: 4)
    │   │   └── HeadBone (Pivot: (0, -18))
    │   │       ├── HeadTipBone (Length: 16, Angle: -90°)
    │   │       ├── HeadVisual (Head base & ears — z_index: 6)
    │   │       ├── BangsVisual (Forehead fringe & ahoge — z_index: 7)
    │   │       ├── FaceVisual (Live eyes, lashes, mouth, blush — z_index: 8)
    │   │       │
    │   │       ├── HairBackBone (Pivot at skull nape: (0, -60))
    │   │       │   ├── HairBackVisual (Cascading mane — z_index: 1)
    │   │       │   └── HairBackTipBone (Length: 16, Angle: 90°)
    │   │       │
    │   │       ├── HairLeftBone (Pivot at left temple/ear: (-35, -50))
    │   │       │   ├── HairLeftVisual (Left wavy tress — z_index: 9)
    │   │       │   └── HairLeftTipBone (Length: 16, Angle: 90°)
    │   │       │
    │   │       └── HairRightBone (Pivot at right temple/ear: (35, -50))
    │   │           ├── HairRightVisual (Right wavy tress — z_index: 9)
    │   │           └── HairRightTipBone (Length: 16, Angle: 90°)
    │   │
    │   ├── LeftUpperArmBone (Pivot at left shoulder: (-44, -68))
    │   │   └── LeftLowerArmBone (Pivot at left elbow: (0, 62))
    │   │       └── LeftHandBone (Pivot at left wrist: (0, 52))
    │   │           ├── LeftHandVisual (Relaxed, Pointing, Open, Fist — z_index: 10)
    │   │           └── LeftHandTipBone (Length: 12, Angle: 90°)
    │   │
    │   └── RightUpperArmBone (Pivot at right shoulder: (44, -68))
    │       └── RightLowerArmBone (Pivot at right elbow: (0, 62))
    │           └── RightHandBone (Pivot at right wrist: (0, 52))
    │               ├── RightHandVisual (Relaxed, Pointing, Open, Fist — z_index: 10)
    │               └── RightHandTipBone (Length: 12, Angle: 90°)
    │
    ├── SkirtBone (Waistband pivot: (0, 0))
    │   ├── SkirtVisual (Stepped knife-pleated skirt — z_index: 4)
    │   └── SkirtTipBone (Length: 16, Angle: 90°)
    │
    ├── LeftThighBone (Pivot at left hip: (-16, 8))
    │   └── LeftShinBone (Pivot at left knee: (0, 82))
    │       └── LeftFootBone (Pivot at left ankle: (0, 86))
    │           ├── LeftFootVisual (Platform dad sneaker — z_index: 2)
    │           └── LeftFootTipBone (Length: 12, Angle: 90°)
    │
    └── RightThighBone (Pivot at right hip: (16, 8))
        └── RightShinBone (Pivot at right knee: (0, 82))
            └── RightFootBone (Pivot at right ankle: (0, 86))
                ├── RightFootVisual (Platform dad sneaker — z_index: 2)
                └── RightFootTipBone (Length: 12, Angle: 90°)
```

---

## 3. High-Level Character API Reference

All character methods are available directly on the [`Nemi`](file:///Users/talus/Documents/adb/characters/nemi/nemi.gd) node:

### Character Lifecycle & Posing
```gdscript
# Reset character to default neutral idle rest pose (0 rotations, neutral face, centered gaze)
nemi.reset()

# Sets character pose by preset name ("idle", "casual_standing", "pointing", "thinking", "excited", "recoiling", "walking", "novel_pose")
# If transition_time == 0.0, performs 0-frame snap cut (storytime comic style).
nemi.set_pose(pose_name: String, transition_time: float = 0.0)

# Sets the body lean angle in degrees (positive = forward/left, negative = backward/right)
nemi.lean(angle_deg: float, duration: float = 0.2)

# Triggers comedic shock recoil backward with screen trauma shake
nemi.recoil(strength: float = 0.4)

# Trauma camera/character shake
nemi.shake(trauma: float = 0.5)
```

### Head & Gaze System
```gdscript
# Turns the head horizontally with natural neck coordination and motivated hair sway
nemi.head_turn(angle_deg: float, transition_time: float = 0.2)

# Tilts the head left/right
nemi.head_tilt(angle_deg: float, transition_time: float = 0.2)

# Quick conversational affirmative nod
nemi.nod(amount: float = 1.0, duration: float = 0.3)

# Discrete directional eye gaze ("left", "right", "up", "down", "up_left", "up_right", "down_left", "down_right", "center")
nemi.look(dir_name: String)

# Continuous 2D gaze vector (clamped range [-1.0, 1.0])
nemi.look_at_direction(dir: Vector2)

# Triggers organic quadratic in/out blink
nemi.blink(duration: float = 0.18)
```

### Live Facial Controls
```gdscript
# Sets procedural facial expression ("neutral", "happy", "excited", "confused", "angry", "sad", "embarrassed", "shocked", "smug", "annoyed", "laughing")
nemi.set_expression(expr_name: String)

# Sets procedural mouth shape ("neutral", "smile", "smile_wide", "open_excited", "open_shocked", "surprised", "smirk", "wavy", "frown", "pout")
nemi.set_mouth_shape(shape_name: String)

# Independent eyebrow control: side ("left"|"right"|"both"), raise_amount (px), tilt_amount (rad)
nemi.set_eyebrow(side: String, raise_amount: float, tilt_amount: float)

# Eye openness (0.0 = closed/blink/smile, 1.0 = normal, 1.35 = wide shocked)
nemi.set_eye_openness(openness: float)

# Pupil scaling (0.3x constriction to 2.2x dilation)
nemi.set_pupil_scale(scale: float)

# Toggles micro-expression comic accents: "blush", "sweat", "sparkles", "question", "shock_lines"
nemi.set_micro_accent(accent_name: String, active: bool)
```

### Limbs, Hands & Hair Controls
```gdscript
# Independent arm control: upper arm rotation (deg), lower arm elbow bend (deg), hand pose ("relaxed"|"pointing"|"open"|"fist")
nemi.set_arm(is_left: bool, upper_rot_deg: float, lower_rot_deg: float, hand_pose_str: String = "relaxed", transition_time: float = 0.0)

# Independent leg control: thigh rotation (deg), shin knee bend (deg), foot ankle tilt (deg)
nemi.set_leg(is_left: bool, thigh_rot_deg: float, shin_rot_deg: float, foot_rot_deg: float, transition_time: float = 0.0)

# Sets hand gesture pose ("relaxed", "pointing", "open", "fist")
nemi.set_hand_pose(is_left: bool, pose_str: String)

# Sets hair mass sway angles (back mane deg, left tress deg, right tress deg)
nemi.set_hair_sway(back_deg: float, left_deg: float, right_deg: float, transition_time: float = 0.2)
```

### Style & Debug Overlays
```gdscript
# Switches palette mode ("color" or "monochrome")
nemi.set_style(style_name: String)
nemi.set_art_mode(mode: NemiStyle.ArtMode)
nemi.toggle_art_mode()

# Toggles real-time visual Rig Debug Overlay (pivots, bones, labels)
nemi.set_rig_debug(visible: bool)
nemi.toggle_rig_debug()
```

---

## 4. Interactive Test Harness (`NemiRigTest.tscn`)

Run the test harness in Godot:
```bash
/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot --rendering-driver metal characters/nemi/test/NemiRigTest.tscn
```

### Interactive Features & Hotkeys:
- `1` - `8`: Instant rig poses (`Idle`, `Casual`, `Point`, `Think`, `Excited`, `Recoil`, `Walk`, `Lean`)
- `Space`: Procedural Blink
- `Arrow Keys`: Directional Eye Gaze
- `A` / `D`: Head Turn Left / Right
- `C` / `M`: Toggle COLOR ↔ MONOCHROME mode
- `G` / `D`: Toggle Rig Debug Overlay
- `P`: **[★ Live New-Pose Test]** — Generates a novel pose purely from transforms
- `E`: **[★ Live New-Expression Test]** — Generates a novel expression combination live
- `R`: Character Reset to default neutral idle

---

## 5. Automated Verification Test Tool

Run the automated verification suite:
```bash
/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot --rendering-driver metal -s tools/verify_nemi_rig_v1.gd
```
Output screenshots are saved to [`characters/nemi/renders/rig_v1/`](file:///Users/talus/Documents/adb/characters/nemi/renders/rig_v1/):
- `01_rig_v1_idle_baseline.png`: Neutral idle baseline
- `02_rig_v1_debug_overlay.png`: Live Rig Debug visualizer overlay (Bones & Joint Pivots)
- `03_rig_v1_novel_pose_color.png`: Requirement 24 Live New-Pose Test in Color mode
- `04_rig_v1_novel_expression_closeup.png`: Requirement 25 Live New-Expression Test in close-up framing
- `05_rig_v1_novel_pose_monochrome.png`: Requirement 18 & 29 Finished Monochrome mode switch
- `06_rig_v1_articulation_sweep.png`: Articulation sweep exercising arms (open & fist), turned head, and swaying hair
