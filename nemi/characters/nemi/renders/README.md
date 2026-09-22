# NEMI — Godot-Native 2D Rigged Character Visual Renders

All renders in this folder were captured directly from the live Godot 4 viewport (`characters/nemi/nemi.tscn`).
**Zero image textures or sprites were used** — every part of Nemi is drawn via procedural Godot 2D canvas drawing (`_draw()`), colored polygons, polylines, and a `Skeleton2D` / `Bone2D` hierarchical rig.

---

## Gallery Index

| Filename | Framing | Pose / Action | Art Mode | Description |
| :--- | :--- | :--- | :--- | :--- |
| `00_nemi_showcase_overview.png` | Overview | 12-Shot Contact Sheet | Color & Mono | All showcase renders at a glance |
| `01_nemi_fullbody_idle_color.png` | Full-Body | Master Idle | **COLOR** | Full body on floor line with sage hoodie, pleated skirt, red hair, sneakers |
| `02_nemi_fullbody_idle_monochrome.png` | Full-Body | Master Idle | **MONOCHROME** | Finished `#3E081E` burgundy ink on warm paper with blush hatching |
| `03_nemi_storytime_bust_color.png` | Medium Bust | Talking / Explaining | **COLOR** | Classic YouTube storytime waist-up framing with gaze tracking |
| `04_nemi_storytime_bust_monochrome.png`| Medium Bust | Talking / Explaining | **MONOCHROME** | Storytime waist-up framing in finished monochrome ink |
| `05_nemi_face_closeup_color.png` | Close-Up | Neutral Gaze | **COLOR** | Close-up showing emerald anime eyes, double highlights, lashes, ahoge |
| `06_nemi_face_closeup_monochrome.png` | Close-Up | Neutral Gaze | **MONOCHROME** | Close-up in finished monochrome ink mode |
| `07_nemi_pose_pointing_color.png` | Full-Body | Pointing | **COLOR** | Rigged pointing pose with index finger gesture and smile |
| `08_nemi_pose_thinking_color.png` | Medium Bust | Thinking | **COLOR** | Hand to chin contemplative pose with tilted head |
| `09_nemi_pose_excited_color.png` | Medium Bust | Excited Cheer | **COLOR** | Raised fist celebratory pose |
| `10_nemi_pose_recoiling_color.png` | Medium Bust | Shock Recoil | **COLOR** | Comedic backward lean with shocked wide eyes |
| `11_nemi_novel_rig_pose_color.png` | Full-Body | Novel Rig Pose | **COLOR** | **Definitive test**: Novel pose generated dynamically by bone angles |
| `12_nemi_novel_rig_pose_monochrome.png`| Full-Body | Novel Rig Pose | **MONOCHROME** | Novel rig-generated pose rendered in monochrome mode |
| `13_nemi_proportion_debug_overlay.png` | Full-Body | Proportion Verification | **COLOR** | Mathematical debug overlay verifying 94x112 head, 118 hair, 5.2 head ratios |

---

## How to Re-render

To re-generate all images in this directory after any code modifications:
```bash
/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot --rendering-driver metal -s res://tools/render_nemi_showcase.gd
```
