# Common Storytime Production Pipeline
## Step-by-Step Workflow from Narrative Voice to 1080p MovieWriter Master Render

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Standardized Production Workflow for all Storytime Episodes (Nemi, ADB, and future productions)  
**Location**: `docs/animation/COMMON_STORYTIME_PRODUCTION_PIPELINE.md`

---

## 1. Pipeline Overview

The storytime production pipeline is an audio-driven, procedural animation workflow built inside Godot 4.x. It transforms a recorded voice track into a frame-accurate, hand-drawn storytime video through 10 structured phases:

```
[Phase 1: Script & Narration Recording]
                 │
                 ▼
[Phase 2: Audio Alignment & Millisecond Timing Generation]
                 │
                 ▼
[Phase 3: Beat Segmentation & Choreography Mapping]
                 │
                 ▼
[Phase 4: Scene Setup & Camera Presets]
                 │
                 ▼
[Phase 5: Character Rig Performance & Posing]
                 │
                 ▼
[Phase 6: Prop Staging & Physical Grounding]
                 │
                 ▼
[Phase 7: Hand-Drawn Doodles & Lettering Integration]
                 │
                 ▼
[Phase 8: Subtitle Card Synchronization (<= 5 Words)]
                 │
                 ▼
[Phase 9: Event SFX Punctuation Pass]
                 │
                 ▼
[Phase 10: Headless QA Audit & 1080p 30 FPS MovieWriter Render]
```

---

## 2. Phase-by-Phase Execution Standards

### Phase 1: Script & Narration Recording
* Record final narration with authentic human cadence, breathing, and natural comedic pauses.
* Clean audio: remove unwanted clicks, normalize voice track to `-3.0 dB` True Peak.

### Phase 2: Audio Alignment & Millisecond Timing
* Use alignment tools (e.g., Whisper, CTC forced alignment, or segmenter script) to produce a `timing.json` file.
* Every sentence and pause is cataloged with exact start and end timestamps.

### Phase 3: Beat Segmentation
* Decompose the episode into 6–12 distinct directorial beats (Explanation, Reaction, Joke, Hold, Reveal, Visualization, Cutaway).
* Create a Visual Event Map documenting what happens on screen every 2–4 seconds.

### Phase 4: Scene Setup & Camera
* Setup the beat scenes (e.g., `Beat01_Intro.tscn`, `Beat02_Problem.tscn`).
* Anchor the `StoryCamera2D` with appropriate presets (`WIDE`, `MEDIUM`, `CLOSE_UP`, `ASYMMETRIC`).

### Phase 5: Character Rig Performance
* Drive the character rig via its directorial API:
  - `set_pose(pose_name, duration)`
  - `set_expression(expression_name, duration)`
  - `look("camera" | "target")`
  - `head_tilt_to(degrees, duration)`
  - `blink(duration)`
  - `set_mouth(shape)` / lip-sync streaming.
* Implement anticipation before gestures and lock into comedic holds after punchlines.

### Phase 6: Props & Environment
* Instantiate required props (`PropCup`, `PropLaptop`, `PropPhone`, etc.).
* Verify z-index depth stack and ensure physical contact with tables or hands.

### Phase 7: Doodles & Handwriting
* Add draw-on doodles (`draw_arrow`, `draw_circle`, `draw_star`, `draw_diagram`).
* Apply organic handwritten annotations with irregular baselines and hand-drawn underlines.

### Phase 8: Subtitle Synchronization
* Implement subtitle card events.
* Enforce **$\le 5$ words per card**. Verify cards clear during spoken pauses.

### Phase 9: SFX Punctuation
* Place event SFX at exact millisecond cues supporting visual impacts.
* Verify dialogue clarity; ensure SFX do not mask words. Confirm BGM is OFF.

### Phase 10: QA & Master Rendering
* Run headless Godot test suite.
* Render with MovieWriter mode at **1920×1080 @ 30 FPS** (`--fixed-fps 30`).
* Inspect rendered MP4 for visual clipping, audio sync, and comedic pacing.

## Executable workflow for new productions

Follow [Character Drawing Production Kit](CHARACTER_DRAWING_PRODUCTION_KIT.md) for the saved scene spec, script/beat sheet pattern, profile selection, acting recipes, timing validation, and fresh ten-second proof. Existing episode migration is outside the current improvement scope.

Full scene implementation and model handoff now use [Storytime Direction Workflow](STORYTIME_DIRECTION_WORKFLOW.md), not the fixed comparison layout.
