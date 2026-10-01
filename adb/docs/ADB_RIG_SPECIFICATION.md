# ADB Rig Specification
## Engine Architecture, Node Hierarchy, Separable Parts, and Directorial Transform Controls

**Document Status**: LOCKED & AUTHORITATIVE RIG SPECIFICATION  
**Target Engine**: Godot 4.x (Compatibility Renderer / Forward+, CanvasItem Vector Inking)  
**Main Scene**: `res://adb/characters/adb/ADB.tscn`  
**Root Script**: `res://adb/characters/adb/ADB.gd`  
**Location**: `adb/docs/ADB_RIG_SPECIFICATION.md`

---

## 1. Rig Architecture Overview

The ADB character rig is constructed as a **100% Godot 4-native procedural 2D vector character** designed specifically for high-precision storytime performance.

```
┌────────────────────────────────────────────────────────┐
│                   ADB RIG ARCHITECTURE                 │
│                                                        │
│               [ADB Root (Node2D, Pelvis Y=0)]          │
│                ├── [Torso Controller]                  │
│                │    ├── [Knit Pullover & Inner Tee]    │
│                │    ├── [Neck & Collar]                │
│                │    └── [Head Controller]              │
│                │         ├── [Hair Back Layer]         │
│                │         ├── [Head Base & Ears]        │
│                │         ├── [Face Visual Subsystem]   │
│                │         │    ├── [Almond Eyes]        │
│                │         │    ├── [Mobile Eyebrows]    │
│                │         │    ├── [Multi-State Mouth]  │
│                │         │    └── [Watercolor Blush]   │
│                │         └── [Hair Front Curtains]     │
│                ├── [Left Arm Chain (Upper/Forearm/Hand)]│
│                ├── [Right Arm Chain (Upper/Fore/Hand)] │
│                └── [Lower Body (Trousers & Sneakers)]  │
└────────────────────────────────────────────────────────┘
```

### Zero Texture Dependency
- All contour lines are rendered procedurally with organic calligraphic ink paths.
- Geometry uses clean parametric shapes with natural tapers, ensuring infinite sharpness at any camera zoom without pixelation or compression artifacts.

---

## 2. Anatomical Coordinate Space & Origin

* **Root Origin (0, 0)**: Set at the **Pelvis / Center of Gravity**.
* **Floor Ground Line**: At standard standing posture, feet rest at `Y ≈ +220px`.
* **Chest / Shoulder Line**: Located at `Y ≈ -100px`.
* **Chin / Head Pivot**: Located at `Y ≈ -140px`.
* **Crown of Hair**: Reaches `Y ≈ -230px`.
* **Canvas Scale**: Default `scale = Vector2(1.0, 1.0)` is calibrated for standard 1920×1080 framing.

---

## 3. Separable Body Parts for Storytime Acting

1. **Head & Neck**:
   - Independent 2D rotation pivot at neck base (`Y = -140px`).
   - Supports ±18° expressive head tilt and ±15° head turn foreshortening.
2. **Layered Hair System**:
   - `HairBack`: Depth layer positioned behind head and ears.
   - `LeftCurtainBang` & `RightCurtainBang`: Frame the forehead and eyes, responding to head movement with subtle spring-damped secondary sway.
   - `CrownFringe`: Top volume with organic pen flick locks.
3. **Face Visual Subsystem**:
   - `AlmondEyes`: Independent left and right eye openness (`0.0` closed to `1.4` wide shock).
   - `Pupils`: 2D gaze tracking with white specular catchlight and micro-saccade eye darting.
   - `Eyebrows`: Independent height, slant angle, and arch curvature.
   - `Mouth`: Vector-drawn phoneme and emotional shapes (talk open, talk wide, smirk, small 'o', deadpan dash).
   - `Blush`: Soft transparent pink wash with optional calligraphic cross-hatch.
4. **Torso & Shoulders**:
   - Parametric knit sweater contour with ribbed hem and cuffs.
   - Dual-collar fold opening revealing dark crewneck inner shirt and silver half-zip slider.
   - Torso lean and shoulder elevation parameters.
5. **Arm Chains (Left & Right)**:
   - Upper arm (`Shoulder` -> `Elbow`), Forearm (`Elbow` -> `Wrist`), and Hand visual slot.
   - Smooth knit sleeve folds at elbow creases.
6. **Lower Body (Trousers & Sneakers)**:
   - Dark slate trousers with relaxed knee break.
   - Minimalist canvas sneakers with sole contact line grounded at floor baseline.

---

## 4. Master Directorial API (`ADB.gd`)

The ADB rig is controlled in code via an expressive, clean high-level directorial API:

### Poses & Staging
```gdscript
adb.set_pose(pose_name: String, duration: float = 0.20)
# Poses: "relaxed_standing", "weight_left", "weight_right", "casual_slouch", 
# "leaning_forward", "seated_chair", "seated_slump", "explaining", "shrug",
# "hand_to_chin", "hand_to_chest", "deadpan_freeze", "facepalm", "anime_sparkle"
```

### Facial Expressions & Micro-Events
```gdscript
adb.set_expression(expr_name: String, duration: float = 0.15)
# Expressions: "neutral", "cute", "smug", "embarrassed", "deadpan", 
# "excited", "annoyed", "confused", "shocked", "tired", "happy"

adb.blink(duration: float = 0.12)
adb.half_blink(duration: float = 0.14)
adb.look(direction: String) # "camera", "left", "right", "up", "down", "side_eye"
adb.look_at_pos(global_target: Vector2)
adb.head_tilt_to(degrees: float, duration: float = 0.18)
adb.freeze_stillness(duration: float)
adb.set_blush(intensity: float, duration: float = 0.20) # 0.0 to 1.0
```

### Lip-Sync & Mouth Streaming
```gdscript
adb.set_mouth(mouth_shape: String) 
# Shapes: "neutral", "smile", "smirk", "talk_open", "talk_wide", "talk_round", "small_o", "deadpan"
```

### Hands & Gestures
```gdscript
adb.set_hand_left(hand_type: String)
adb.set_hand_right(hand_type: String)
# Shapes: "relaxed", "open_palm", "pointing", "fist", "thumb_up", 
# "holding_phone", "holding_cup", "holding_notebook", "shrug_open", "waving"
```
