# NEMI — EPISODE 01 PRODUCTION NOTES
## "Storytime: I Used To Have A Cat"
**Production Date**: September 2026  
**Director / Autonomous Agent**: Antigravity Studio Engine  
**Standards Bible**: `docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md` (v1.0 Refined Pass)  
**Status**: 1080P REVIEW COMPLETE / VERIFIED  

---

## 1. Executive Summary & Production Standards

Episode 01 represents the major visual refinement, fact correction, and illustration density upgrade pass executed under the locked specifications of the *Nemi Animation Production Bible*. The story recounts a relatable, warm, and humorous real-life experience: finding an abandoned kitten behind mailboxes at age 16, caring for it, facing parental rejection, placing it with the corner shopkeeper, and finding it a loving forever home.

### Key Milestones & Corrective Passes:
1. **Strict Fact Correction**:
   - Nemi's age at discovery is canonically established: *"I was sixteen when I found her..."* (Beat 2, Segment 003).
   - The invented "Friday" detail was strictly eliminated and replaced with *"And finally..."* (Beat 8, Segment 016).
   - Adherence to Rule 28 (Fact Discipline): Zero invented days, dates, weather conditions, or emotional backstories.
2. **Doodle Color Overhaul (Near-Black Ink Standard)**:
   - Shifted all doodle and annotation inking from red dominance to **Black / Near-Black Ink (`#232026`)**.
   - Red dominance has been completely eliminated across the episode. Accent colors (e.g., `#f06292` small heart) are strictly restrained.
3. **Hard Subtitle Rule ($\le 5$ Words)**:
   - 100% of subtitle cards across all 19 dialogue segments display $\le 5$ words simultaneously (averaging 2–4 words), completely eliminating screen clutter.
4. **Visual Density & Anti-Stagnation**:
   - Zero static talking heads. Mini-scenes are visually staged with micro-acting:
     - Beat 3: Discovery walk, damp cardboard box with shivering kitten.
     - Beat 4: Care sequence with sliding ceramic milk saucer, shoelace hiss, and folded linen cat blanket (`PropBlanket.gd`) with physics squish.
     - Beat 6: Corner store mini-scene with shelves, jars, service bell, and animated friendly shopkeeper nodding in approval.
     - Beat 7: Peak search montage with texting phone doodle and progressive three-house adoption search drawn in black ink.
5. **Development Resolution Gate**:
   - In accordance with Section 31 of the Bible: **NEVER RENDER 4K DURING DEVELOPMENT**.
   - Rendered natively at **1920×1080 @ 30 FPS** (`EP01_Cat_1080p_Review.mp4`). Stop condition honored.

---

## 2. Voice Acting & Audio Architecture

* **Engine**: Qwen3-TTS CustomVoice (`mlx-audio` running locally on Apple Silicon).
* **Voice Profile**: Locked actor `Sohee` (`spk_id: 2864`), calibrated to Nemi's conversational tempo (1.0x baseline, natural cadence with organic hesitation and micro-pauses).
* **Duration**: Exactly **81.33 seconds** across 19 segments and 9 beats.
* **Master Audio Track**: `episodes/ep01_cat/audio/EP01_audio_sfx_master.wav` (48,000 Hz, 24-bit Stereo PCM, -3.08 dBFS peak headroom).

---

## 3. Character Animation & Acting Highlights

### 3.1. Nemi (The Protagonist)
* **Rig**: Live Godot 2D bone rig (`characters/nemi/nemi.tscn`). Zero AI image generation for character poses or expressions.
* **Acting Rhythm**: Follows the mandatory three-phase cycle: **Action $\rightarrow$ Settle $\rightarrow$ Stillness Hold**.
  - *Beat 1*: Darting glance into camera, quick blink, lean on "Wait."
  - *Beat 2*: Defensive shrug on "not like that", head shake, glance to "AGE 16" annotation.
  - *Beat 3*: Step-in discovery, two-inch finger bracket on "fit-in-my-pocket tiny."
  - *Beat 4*: Milk saucer slide, recoil on shoelace hiss, hand-on-heart blush on lawnmower purr.
  - *Beat 5*: Hopeful hands + pink heart $\rightarrow$ sudden collapse $\rightarrow$ dark cross-out "NO PETS" $\rightarrow$ 0.8s deadpan freeze.
  - *Beat 6*: Shop counter gesture, proud smirk as Neeko runs the register.
  - *Beat 7*: Fast thumb texting on phone doodle, inquiring shrug on "every single customer."
  - *Beat 8*: Warm sigh of relief on "And finally...", heartfelt smile on naming Neeko.
  - *Beat 9*: Reflective upward glance, sincere direct eye contact into camera, gentle nod.

### 3.2. Neeko (The Cat)
* **Design**: Pen-and-ink hand-drawn aesthetic (`characters/neeko/Neeko.tscn`).
* **Active Behaviors**:
  - Box shivering with procedural oscillation.
  - Inquisitive crouch and cautious saucer sniff.
  - Playful arched-back hiss at shoelaces.
  - Curling into happy loaf on the folded blanket.
  - Perching tall and proud as shop manager behind the counter.
  - Trotting happily into the forever home.

---

## 4. Technical Specs & Verification Metrics

| Metric | Required Bible Standard | Achieved in EP01 Refined Pass | Status |
|---|---|---|---|
| **Development Resolution** | 1920×1080 @ 30 FPS | 1920×1080 @ 30 FPS | **PASS** |
| **Subtitle Rule** | Max 5 words / card | 100% cards $\le 5$ words | **PASS** |
| **Doodle Inking** | Black/Near-Black `#232026` | `#232026` (Zero red dominance) | **PASS** |
| **Fact Discipline** | "Age 16", No "Friday" | "I was sixteen", "And finally..." | **PASS** |
| **Master Clock** | 60–100s window | 81.33s exact duration | **PASS** |
| **Audio Headroom** | $\ge 1.0$ dBFS | 3.08 dBFS headroom (-3.08 peak) | **PASS** |
| **Delivery Gate** | STOP at 1080p Review | Review MP4 generated, 4K gated | **PASS** |

---

## 5. Review Deliverables
* **Primary Review Video**: `episodes/ep01_cat/previews/EP01_Cat_1080p_Review.mp4` (1920×1080 @ 30 FPS, 6.21 MB)
* **Audit Frames Directory**: `episodes/ep01_cat/previews/audit_1080p/` (18 key audit frames)
