# NEMI — EPISODE 01 ASSET MANIFEST
## "Storytime: I Used To Have A Cat"
**Production Date**: September 2026  
**Standards Version**: Nemi Animation Production Bible v1.0 (Refined Pass)  
**Status**: 1080P REVIEW COMPLETE / VERIFIED  

---

## 1. Executive Summary
This manifest catalogs all components, scripts, scenes, rigs, props, audio cues, and pipeline tools used in the autonomous production of **Nemi Episode 01: "I Used To Have A Cat"**. All assets strictly adhere to the locked specifications in `docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md`.

---

## 2. Character Rigs

### 2.1. Nemi (Lead Character)
* **Scene**: `characters/nemi/nemi.tscn`
* **Controller**: `characters/nemi/NemiController.gd`
* **Rig Specs**:
  - Live Godot 2D bone rig (Zero AI image generation for poses).
  - Palette: Ginger hair `#b84328`, Dark Olive Hoodie `#536b5c`, Skin `#fcefe3`.
  - Facial features: Modular 2D pen-and-ink eyes, mobile brows, and 7 illustrative mouth visemes.
  - Performance: Action $\rightarrow$ settle $\rightarrow$ stillness holds (no procedural jitter, breathing loops, or floating drift).

### 2.2. Neeko (The Cat) — *Narrative Co-Star*
* **Scene**: `characters/neeko/Neeko.tscn`
* **Script**: `characters/neeko/Neeko.gd`
* **Design**:
  - Pen-and-ink hand-drawn aesthetic matching Nemi's visual world.
  - Cream coat (`#fbf8f3`), ginger patches (`#c85a3a`), pink ears/nose (`#f4a896`), dark expressive eyes (`#2b2b2b`).
  - Subtle breathing/swaying, animated tail swish, ear twitch, and whisker trembling.
* **States & Behaviors**:
  - `neutral`: Alert sitting posture.
  - `scared`: Low crouch with shivering oscillation (`shiver_factor`).
  - `curious`: Head tilted up, large dilated pupils, upright ears.
  - `drinking`: Dipping head forward with milk surface ripple timing.
  - `happy_loaf`: Tucked paws, purring vibrato, closed curved happy eyes.
  - `proud_boss`: Puffed chest, elevated posture, looking down approvingly behind counter.
  - `playful`: Pouncing crouch, wagging tail.
  - `confused`: Asymmetric ear angle and tilted head.
* **Motion Methods**:
  - `trot_to(target_pos, duration)`: Quadruped stepping bobbing tween.
  - `curl_into_loaf(duration)`: Morph from trot/sit into tucked loaf.
  - `look_at_target(target_pos)`: Procedural eye pupil and head follow.

---

## 3. Dedicated Narrative Props & Mini-Scenes

### 3.1. Damp Cardboard Box (`PropCardboardBox.gd`)
* **Path**: `episodes/ep01_cat/props/PropCardboardBox.gd`
* **Description**: Abandoned street cardboard box with folded flaps, water damage waterlines, and hand-drawn crosshatching.
* **Features**: Soft ground impact settle tween, flap quiver reaction.

### 3.2. Ceramic Milk Saucer (`PropMilkBowl.gd`)
* **Path**: `episodes/ep01_cat/props/PropMilkBowl.gd`
* **Description**: Cream-glazed ceramic saucer with hand-drawn pen rim.
* **Features**: Liquid milk surface with animated surface ripple rings on interaction.

### 3.3. Folded Linen Cat Blanket (`PropBlanket.gd`)
* **Path**: `episodes/ep01_cat/props/PropBlanket.gd`
* **Description**: Soft folded cat blanket in warm cream tones with charcoal linen crosshatching.
* **Features**:
  - `squish()`: Physics squish-and-settle tween when Neeko steps onto it to loaf.

### 3.4. Corner Shop Counter & Shopkeeper (`PropShopCounter.gd`)
* **Path**: `episodes/ep01_cat/props/PropShopCounter.gd`
* **Description**: Corner store mini-scene with wooden paneled counter, rear shelf with jars and canned goods, brass service bell, and a friendly hand-drawn Shopkeeper with collared shirt, apron, and mustache.
* **Features**:
  - `nod_shopkeeper()`: Hand-drawn head nod animation with approving eyebrow tilt and warm smile.
  - `ring_bell()`: Brass bell depression animation with radiating acoustic soundwave doodle lines.
  - Counter ledge sized for Neeko's `proud_boss` shopkeeper pose.

---

## 4. Visual Event & Hand-Drawn Doodle System

### 4.1. Hand-Drawn Inking Overhaul
* **Color Standard**: Default doodle/annotation color is strictly **Black / Near-Black Ink (`#232026`)**.
* **Palette Tokens**: `world/style/WorldStyle.gd` updated to eliminate red dominance. Restrained accent colors (e.g., `#f06292` small heart) used sparingly.
* **Procedural Doodles in `world/doodles/DoodleInstance.gd` & `NemiDoodleDirector.gd`**:
  - `MINI_HOUSE`: Hand-drawn gable roof house with chimney and crosshatch window.
  - `MINI_CAT_HEAD`: Stylized cat head with perked ears and whiskers.
  - `MINI_PAW`: Hand-drawn cat paw print.
  - `MINI_MILK_BOTTLE`: Classic glass milk bottle with cap and label line.
  - Plus: `cat_silhouette()`, `phone()`, `bracket()`, `arrow()`, `text()`, `soundwaves()`.

---

## 5. Audio Assets & SFX Catalog

### 5.1. Master Voiceover
* **File**: `episodes/ep01_cat/audio/EP01_voice.wav`
* **Model**: Qwen3-TTS (CustomVoice)
* **Voice Actor**: `Sohee` (Speaker ID `2864`)
* **Duration**: 81.33s (Exact master clock)
* **Sample Rate**: 24,000 Hz source $\rightarrow$ 48,000 Hz master resample

### 5.2. SFX Timeline & Mixing
* **Timeline Manifest**: `episodes/ep01_cat/ep01_sfx_timeline.json`
* **Master Mix**: `episodes/ep01_cat/audio/EP01_audio_sfx_master.wav`
* **Format**: 48,000 Hz, 24-bit Stereo PCM
* **Peak**: -3.08 dBFS (Headroom: 3.08 dB $\ge 1.0$ dBFS requirement)
* **Mixer Script**: `tools/mix_ep01_sfx.py`

---

## 6. Beat Scenes & Master Orchestration

| Beat | Scene File | Script File | Duration | Segments |
|---|---|---|---|---|
| **01: Hook** | `episodes/ep01_cat/beats/Beat01_Hook.tscn` | `Beat01_Hook.gd` | 3.12s | 001 |
| **02: Clarification** | `episodes/ep01_cat/beats/Beat02_Clarification.tscn` | `Beat02_Clarification.gd` | 8.94s | 002, 003 |
| **03: Discovery** | `episodes/ep01_cat/beats/Beat03_Discovery.tscn` | `Beat03_Discovery.gd` | 8.40s | 004, 005 |
| **04: Care** | `episodes/ep01_cat/beats/Beat04_Care.tscn` | `Beat04_Care.gd` | 11.79s | 006, 007, 008 |
| **05: Problem** | `episodes/ep01_cat/beats/Beat05_Problem.tscn` | `Beat05_Problem.gd` | 9.47s | 009, 010 |
| **06: Shopkeeper** | `episodes/ep01_cat/beats/Beat06_Shopkeeper.tscn` | `Beat06_Shopkeeper.gd` | 14.96s | 011, 012, 013 |
| **07: Search** | `episodes/ep01_cat/beats/Beat07_Search.tscn` | `Beat07_Search.gd` | 10.64s | 014, 015 |
| **08: Payoff** | `episodes/ep01_cat/beats/Beat08_Payoff.tscn` | `Beat08_Payoff.gd` | 7.80s | 016, 017 |
| **09: Ending** | `episodes/ep01_cat/beats/Beat09_Ending.tscn` | `Beat09_Ending.gd` | 6.21s | 018, 019 |
| **Total Master** | — | — | **81.33s** | **All (001–019)** |

---

## 7. Subtitle Engine & Alignment Manifests
* **Subtitle Engine**: `episodes/ep01_cat/Episode01Subtitles.gd`
* **Rule Compliance**: 100% of subtitle cards contain $\le 5$ words across all 19 segments.
* **Word Alignment JSON**: `episodes/ep01_cat/timing/voice_alignment.json`
* **Timing Master JSON**: `episodes/ep01_cat/timing/ep01_cat_timing.json`

---

## 8. Render Pipeline Deliverables
* **Pipeline Script**: `tools/render_ep01.py`
* **Primary Review Deliverable**: `episodes/ep01_cat/previews/EP01_Cat_1080p_Review.mp4` (1920×1080 @ 30 FPS, H.264 CRF 18, AAC 192k)
* **Audit Directory**: `episodes/ep01_cat/previews/audit_1080p/` (18 key audit frames)
* **Strict Gate**: NO 4K rendering during development.
