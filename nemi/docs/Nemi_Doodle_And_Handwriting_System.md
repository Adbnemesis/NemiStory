# Nemi Hand-Drawn Doodle & Handwriting Production System
**Version:** 3.0 (Master Canonical Standard)  
**Scope:** Universal Storytime Visual Language for all Nemi Episodes  
**DNA:** Hand-Authored Vector Ink, Paper Warmth, Tactile Audio Anchoring, Character Continuity  

---

## 1. Core Philosophy: Human Hand-Drawn Storytime vs. Digital Perfection

In Nemi's animated storytime universe, every visual element must feel **alive, intimate, and authentically hand-drawn**. Mathematical straight lines, sterile UI shapes, digital sans-serif labels, and robotic geometric primitives break immersion. Every doodle, handwritten note, speech balloon, badge, arrow, and caption must embody the cozy imperfection of a creator drawing in their personal sketchbook late at night.

### The Four Sacred Pillars
1. **Zero Digital UI Crutches**: Never use standard UI buttons, rectangular text containers, or bare system font `Label` nodes to represent in-world thoughts. Text and graphics must be vector ink strokes on paper.
2. **Deterministic Organic Geometry**: Every line, border, and curve contains natural organic micro-wobble generated via multi-frequency sinusoidal displacement and authored vector anchors. Never use per-frame random jitter/noise, which looks like a technical glitch rather than hand-drawn art.
3. **Continuous Studio Atmosphere**: The warm studio paper backdrop (`CANVAS_PAPER = Color("#fcf8f2")`) remains unbroken. Story elements exist *inside* Nemi's sketchbook world. Technical deep-dives (e.g. inspecting an animation frame or single pixel) must be framed using in-universe tactile props (such as a brass magnifying loupe with reflective glare or a sketched CRT monitor on paper), never pitch-black radar or sniper cutaways.
4. **Auditory-Visual Lockstep**: Every visual stroke, pop, stamp, or gesture is anchored to frame-accurate tactile sound effects (pencil scratches, bubble pops, plucks, soft drops). Without sound, visuals feel disconnected; with tactile SFX, they feel physical and alive.

---

## 2. Vector Stroke Handwriting Engine

### The Problem It Solved
Previous iterations relied on digital fonts (`Label` nodes with TTF rendering). Even informal fonts look static, rigid, and digitally composited when placed beside an expressive vector character.

### The Solution: Procedural Vector Lettering (`Ep06Doodles.gd`)
The Vector Stroke Handwriting Engine constructs every character as a sequence of discrete `PackedVector2Array` paths drawn directly via Godot's `draw_polyline` and `draw_circle` end-caps:

```gdscript
# Canonical Inking Parameters
const INK_MAIN: Color = Color("#2e1822") # Berry-espresso black (Nemi linework DNA)
const INK_SOFT: Color = Color("#6b5763") # Graphite secondary ink
const INK_RED:  Color = Color("#d63031") # Comic exclamation red
const INK_GOLD: Color = Color("#d35400") # Warm amber accent
const INK_BLUE: Color = Color("#0984e3") # Blueprint cyan/blue
const INK_MINT: Color = Color("#009470") # Forest mint green
```

### Character Stroke Construction Rules
1. **Character Slant**: Apply a natural `-2.5°` to `+3.0°` forward italic tilt to letter paths.
2. **Stroke Width**: Standard stroke thickness is `w = 3.5px` to `4.2px`.
3. **Rounded Ink Terminals**: Every stroke starts and ends with a solid circle cap (`draw_circle(pt, w * 0.48, col)`) to mimic liquid ink pooling at the start and release of a pen nib.
4. **Pen Lift Segmentation**: Multi-stroke letters (such as `E`, `H`, `A`, `K`, `4`) must have their strokes separated into discrete sequential paths so that draw-in reveals emulate a human hand lifting the pen between strokes:
   - Stroke 1: Downward spine.
   - Stroke 2: Top crossbar.
   - Stroke 3: Middle crossbar.
   - Stroke 4: Bottom baseline.

### Sequential Stroke Reveal Animation
To animate handwriting writing itself onto the page:
```gdscript
var total_strokes := stroke_list.size()
var scaled_prog := progress * float(total_strokes)

for i in range(total_strokes):
    var s = stroke_list[i]
    var pts: PackedVector2Array = s["pts"]
    var stroke_prog := clampf(scaled_prog - float(i), 0.0, 1.0)
    if stroke_prog <= 0.001:
        continue
    var count := int(ceil(float(pts.size()) * stroke_prog))
    count = clampi(count, 2, pts.size())
    var drawn_pts := PackedVector2Array()
    for p in range(count):
        drawn_pts.append(pts[p])
    if drawn_pts.size() >= 2:
        draw_polyline(drawn_pts, s["col"], s["w"], true)
        draw_circle(drawn_pts[0], s["w"] * 0.48, s["col"])
        draw_circle(drawn_pts[drawn_pts.size() - 1], s["w"] * 0.48, s["col"])
```

---

## 3. Organic 32-Point Badge & Stamp Formula

### The Anti-Pattern
Never use 4-point straight-line rectangles, CSS rounded boxes, or geometric circle nodes for badges, labels, or stamps.

### The Canonical 32-Point Formula
All stamps, badges, and post-it annotations must generate a rounded, wobbled perimeter using 32 discrete sample points perturbed by layered harmonics:

```gdscript
func create_organic_badge_polygon(center: Vector2, radius_x: float, radius_y: float, wobble_seed: float = 1.0) -> PackedVector2Array:
    var poly := PackedVector2Array()
    const SAMPLES: int = 32
    for i in range(SAMPLES):
        var angle := (float(i) / float(SAMPLES)) * TAU
        # Primary organic wobble + secondary harmonic
        var wobble := 1.0 + sin(float(i) * 1.3 + wobble_seed) * 0.028 + cos(float(i) * 2.7) * 0.012
        var vx := center.x + cos(angle) * (radius_x * wobble)
        var vy := center.y + sin(angle) * (radius_y * wobble)
        poly.append(Vector2(vx, vy))
    return poly
```

### Aesthetic Staging Guidelines
1. **Paper Fill**: Soft tinted paper fill using `Color("#fffef8").lerp(accent_color, 0.45)`.
2. **Hand-Stamped Tilt**: Always rotate the badge container by `-2.0°` to `-3.5°` (`rotation_degrees = -2.5`).
3. **Ink Border**: Outline the polygon with `INK_MAIN` (`#2e1822`) at `w = 3.2px`, closed with rounded caps.
4. **Accompanying SFX**: Play `cartoon_pop_bubble_01` (at `-1.0 dB`) or `impact_drop_soft_01` (at `-2.0 dB`) on entrance.

---

## 4. Directional Speech Balloons

Speech balloons must feel like quick, expressive comic panels drawn directly into the scene.

### Key Anatomical Rules
1. **Directional Tail Positioning (`flip_tail`)**:
   - The balloon tail must point toward Nemi's head.
   - When Nemi is staged on the left, `flip_tail = false` (tail points down-left toward stage left).
   - When Nemi is staged on the right, `flip_tail = true` (tail points down-right toward stage right).
2. **Non-Crossing Vertex Order**:
   - The tail triangle vertices must be spliced into the perimeter loop in strict angular order:
     `Perimeter arc [0..tail_start] -> Tail tip point -> Tail base return -> Perimeter arc [tail_end..32]`.
   - Never draw the tail as an overlapping secondary polygon that creates internal crossing black lines.
3. **Hand-Drawn Interior Text**:
   - Text inside the speech balloon is rendered using the Vector Stroke engine or bold comic lettering with rounded contours.
4. **Elastic Entrance & SFX**:
   - Scale entrance: `scale = Vector2(0.0, 0.0) -> Vector2(1.15, 1.15) -> Vector2(1.0, 1.0)` over `0.22s` (`TRANS_BACK`, `EASE_OUT`).
   - Trigger `cartoon_pop_bubble_01` or `whoosh_camera_punch_03` at frame 0.

---

## 5. Background & Environmental Continuity

### The Universal Atmosphere Rule
> [!CRITICAL]
> **NEVER CUT TO A PITCH-BLACK VOID, MATRIX SCREEN, OR RADAR GRID.**
> Nemi's universe is set in a warm sketchbook / creative studio space. Cutting to pure black destroys visual continuity and makes the video look like an unfinished tech demo.

### Canonical Background Modes (`Ep06Backdrop.gd`)
1. **Mode 0: WARM STUDIO PAPER (Standard Baseline)**
   - Color: `Color("#fcf8f2")` (Warm cream paper).
   - Overlay: Subtle parchment grain, faint pencil margins.
2. **Mode 1: SKETCHBOOK BLUEPRINT (Design / Planning)**
   - Color: `Color("#1e3799")` (Deep cozy blueprint navy).
   - Overlay: Hand-drawn faint graph lines, chalk accents.
3. **Mode 2: DARK STUDIO / 2:00 AM (Late Night Animation)**
   - Color: `Color("#1e151b")` (Warm charcoal berry, never #000000).
   - Lighting: Warm glowing desk lamp cone, string lights.

### In-Universe Framing for Technical Beats
When the script calls for examining technical details (e.g. zooming in on an animation timeline, a bug, or an individual pixel):
- **Correct**: Spawn an in-universe prop—such as a hand-drawn brass magnifying loupe with glass glare highlights, or a sketched wooden-frame CRT monitor sitting on warm paper.
- **Forbidden**: Switching the entire canvas to black `#000000` with high-contrast computer grids.

---

## 6. Doodle Lifecycle & Safe Dismissal Protocol

### The Trailing Artifact Bug
In early implementations, dismissing doodles by animating stroke progress backwards (`progress -> 0.0`) caused severe visual glitches: multi-stroke characters like `A`, `E`, and `4` left disconnected, orphaned line segments floating in space as individual strokes vanished out of order.

### The Canonical Dismissal Standard
```gdscript
func dismiss(duration: float = 0.18) -> Signal:
    if _tween and _tween.is_valid():
        _tween.kill()
    _tween = create_tween()
    _tween.tween_property(self, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    _tween.finished.connect(queue_free)
    return _tween.finished
```
- **Rule**: ALWAYS fade alpha (`modulate:a -> 0.0`), NEVER reverse `progress`.
- **Auto-Dismiss Lifespan**: Use `.auto_dismiss(lifetime)` with standard durations between `2.0s` and `3.5s`, timed to match the spoken subtitle phrase.

---

## 7. Sound Effects (SFX) Standard: Famous, Tasteful, & Unobtrusive

> [!CRITICAL]
> **NEVER OVERDO SOUND EFFECTS.**
> Sound effects must only be used where they naturally fit narrative and comedic beats. Continuous abrasive scratching/scribbling or harsh electronic chirps are strictly prohibited—they irritate the listener and distract from Nemi's voice performance.

### The Canonical Storytime SFX Palette (`common/audio/sfx/`)
Only use famous, high-clarity, culturally recognizable sound effects sitting gently in the mix:

| Sound Name | File Path | Gain Offset | Narrative Purpose |
| :--- | :--- | :---: | :--- |
| **`pop`** | `common/audio/sfx/pop.mp3` | `-3.0 dB` | Doodles appearing, question bursts, badge spawns, checkmarks. |
| **`whoosh`** | `common/audio/sfx/whoosh.mp3` | `-6.0 dB` | Fast camera punch-ins, snap zooms, quick comedic turns. |
| **`click`** | `common/audio/sfx/click.mp3` | `-4.0 dB` | Laptop interaction, selecting keyframes, writing a joke. |
| **`ping`** | `common/audio/sfx/ping.mp3` | `-5.0 dB` | Lightbulb realization, idea sparks, fixing a microscopic bug. |
| **`chime`** | `common/audio/sfx/chime.mp3` | `-4.0 dB` | Celebration moments, render complete, friendly signoff sparkles. |
| **`bruh`** | `common/audio/sfx/bruh.mp3` | `-5.0 dB` | Classic storytime deadpan defeat ("I wish.", staring at blank screen). |
| **`error`** | `common/audio/sfx/error.mp3` | `-6.0 dB` | The overwhelming crash/scare ("forty keyframe tracks"). |

### Prohibited Audio Anti-Patterns
1. **No Harsh Continuous Scratching**: Do not trigger mechanical scribbling loops (`drawing_scratch_scribble`) on every single doodle or stroke. Doodles look hand-drawn through their vector geometry; they do not need grinding pencil noise.
2. **No Robotic Chirps / Glitch Beeps**: Never use generic electronic downward chirps (`cartoon_digital_chirp_down_01`) on dialogue holds.
3. **Tasteful Density**: An episode should feature roughly 10–18 well-timed sound accents across 2 minutes—never 50+ sound triggers firing every half-second.

### Audio System Configuration (`NemiAudio.gd`)
- `sfx_volume_db`: `-4.0 dB` (Sits comfortably and warmly under narration, never peaking harshly).
- Direct file resolution: Supports `NemiAudio.play("pop")`, `NemiAudio.play("whoosh")`, `NemiAudio.play("bruh")` directly.
- Audio Bus: All sounds route to `Master` to guarantee 100% synchronous capture in Godot MovieWriter.

---

## 8. Master Transcode & 4K UHD Render Pipeline

To preserve 100% audio fidelity and pristine 4K video:

### 1. MovieWriter Audio Capture
Godot's `--write-movie` records video (`Stream #0:0`) and uncompressed 48 kHz stereo audio (`Stream #0:1`) simultaneously.
```bash
/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot \
    --path /Users/talus/Documents/adb \
    --write-movie /tmp/ep_master_raw.avi \
    --fixed-fps 30 \
    --resolution 1920x1080 \
    res://path/to/MasterScene.tscn
```

### 2. FFmpeg Master Muxing & Lanczos 4K Upscale
```bash
ffmpeg -y \
    -i /tmp/ep_master_raw.avi \
    -map 0:v:0 \
    -map 0:a:0 \
    -c:v libx264 -crf 16 -preset slow \
    -vf "scale=3840:2160:flags=lanczos" \
    -pix_fmt yuv420p \
    -c:a aac -b:a 320k \
    -movflags +faststart \
    Master_Episode_4K.mp4
```

> [!CRITICAL]
> **NEVER MAP `-map 1:a:0` FROM RAW VOICE AUDIO FILES.**
> Mapping voice files directly discards Godot's in-engine audio stream containing all the synchronized SFX. Always map `-map 0:a:0` directly from the MovieWriter capture stream to preserve the complete audio mix.

---

## 9. Checklist for Future Nemi Episodes

Before approving any episode for release, audit the production against this checklist:
- [ ] **Handwriting**: All on-screen words are drawn using vector strokes (`draw_polyline`) with rounded caps—zero digital UI font labels.
- [ ] **Badges & Stamps**: All containers use 32-point sinusoidal contours with `-2.5°` hand-stamped rotation—zero 4-point rectangles.
- [ ] **Speech Balloons**: Balloon tails point directly toward the speaking character without overlapping or self-intersecting lines.
- [ ] **Background**: Continuous studio paper backdrop (`#fcf8f2`) maintained throughout—zero pitch-black cutaways.
- [ ] **Doodle Dismiss**: All doodle dismissals use alpha fade (`modulate:a -> 0.0`)—never backwards progress animation.
- [ ] **Audio Mix**: Selective famous SFX (`pop`, `whoosh`, `ping`, `bruh`, `error`, `chime`) only where they naturally fit (~8–15 across the episode), sitting gently in the mix (`-4.0 dB` base), zero harsh scratching or chirps.
- [ ] **Subtitle Cards**: Strictly $\le 5$ words per card across the entire episode.
- [ ] **Master Deliverable**: Final render encoded at 4K UHD (`3840x2160`), 30 FPS, CRF 16, 320k AAC audio.
