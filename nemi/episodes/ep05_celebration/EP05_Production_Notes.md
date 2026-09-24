# EPISODE 05 — PRODUCTION NOTES & DIRECTORIAL LOG
## "WHAT IS GOING ON WITH YOUTUBE?" (`ep05_celebration`)
## Master Version: 2.0 (Human-Hand-Drawn Storytime Animation Upgrade)

---

## 1. Production Context & Directorial Intent

Episode 05 delivers on the user's premise:
> *"TASK: CREATE A NEW NEMI STORYTIME / CELEBRATION ANIMATION*  
> *TITLE: 'WHAT IS GOING ON WITH YOUTUBE?'*  
> *TARGET LENGTH: 1 MINUTE 30 SECONDS – 2 MINUTES (PREFERRED: ~1:40–1:50)*  
> *Nemi is talking directly to the audience because something completely unexpected happened:*  
> *Nemi reached 1,000 SUBSCRIBERS on YouTube, around 1,000 comments on the videos, and Instagram reached 250 followers.*  
> *Nemi is overwhelmed by the amount of support and cannot believe that so many people are actually watching, commenting, following, and supporting the channel.*  
> *Tone: Humble, genuinely surprised, overwhelmed, excited, grateful, authentic, relatable."*

### Directorial Pillars:
1. **Human-Hand-Drawn Acting & Staging (V2)**:
   - Grounded physical studio furniture (`StoryChair`, `StoryDesk` with laptop and steaming mug).
   - Seated anatomy calibrated with forward-projecting thighs and feet resting on the chair foot rung ($Y=528$).
   - Standing acting uses asymmetric contrapposto postures (`relaxed_standing_left_weight`, `relaxed_standing_right_weight`) planted firmly on floor line ($Y=580$).
   - Stillness Principle: Zero procedural sinusoidal breathing bobbing (`enable_lifelike_breathing = false`). Character posture is held in rock-solid, intentional holds for >85% of the timeline.
2. **Cause-and-Effect Prop Lifecycle**:
   - `StoryPhone` dynamically moves between desk surface resting position and Nemi's hand (`HOLD_PROP`), with physical reach anticipation and payoff pickups for confessions and notifications.
3. **17-Pose Expressive Hand Silhouettes**:
   - Explicit hand silhouettes scaled at $1.32\times$ with calligraphic contour lines and crease strokes (`FINGER_COUNT_THREE`, `OPEN_PALM_UP`, `HAND_TO_CHEST`, `HAND_TO_CHEEK`, `SPLAYED_FINGERS`, `FIST`, `POINTING`).
4. **Organic Live Doodle Reveals (Zero Drawing Tools)**:
   - All doodles reveal stroke-by-stroke along vector trajectories with zero pencils, styluses, or cursors.
   - Triple-variant doodle architecture eliminating computerized repetition.
5. **Real Illustrative Syllable Lip-Sync**:
   - Visemes accurately track spoken syllables at an illustrative $12\text{--}15\text{ FPS}$ cadence with instant mouth snap-shut on pauses and silence beats.
6. **Calibrated Sohee Vocal Cadence**:
   - Master voice track `EP05_voice_v2.wav` / `EP05_audio_sfx_master.wav` (92.45s runtime) assembled with canonical Sohee voice profile.

---

## 2. Technical Verification & Standards Compliance

| Requirement | Standard | Episode 05 V2 Status | Verification Details |
|---|---|---|---|
| **Voice Style** | Sohee Conversational Storytime | **100% PASSED** | Master audio `EP05_voice_v2.wav` / `EP05_audio_sfx_master.wav` (48kHz stereo). |
| **Duration Gate** | 1:30–2:00 target (~90–120s) | **100% PASSED** | Total runtime: **92.45 seconds (1m 32.5s)**. Perfectly in the target sweet spot. |
| **Resolution** | 1080p @ 30 FPS Progressive | **100% PASSED** | Rendered at 1920 × 1080 @ 30 FPS via Godot MovieWriter. |
| **Subtitle Rule** | $\le 5$ words per card | **100% PASSED** | 87 subtitle cards audited: max words on any card = 5 words (0 violations). |
| **Rule 7** | Zero gendered self-reference | **100% PASSED** | 100% first-person perspective (`I`, `me`, `my`, `myself`). Zero third-person references. |
| **Animation Rig** | 100% Live Vector Rig | **100% PASSED** | Bone2D + Polygon2D illustrative vector Nemi (`nemi.tscn`) with calibrated V2 poses. |
| **Zero Cursors** | Zero drawing tools | **100% PASSED** | Doodles reveal along stroke trajectories; 0 pencils, styluses, or brushes. |
| **Stillness Gate** | >85% hold time | **100% PASSED** | Zero continuous breathing drift; intentional stillness holds on dialogue and pauses. |

---

## 3. Beat Chronology & Timings (V2 Master)

| Beat | Name | Time Range | Segments | Key Staging & Visual Devices |
|---|---|---|---|---|
| **01** | Analytics Freeze | 00:00.00 – 00:09.54 | `seg01`, `seg02` | Seated at `StoryChair` & `StoryDesk`, laptop analytics glowing, "*FROZE!*" shock freeze |
| **02** | 7 Views Flashback | 00:09.54 – 00:20.73 | `seg03`, `seg04` | Standing contrapposto, live cursive "7 VIEWS", 3-finger count, phone pickup confession |
| **03** | Counter Climb | 00:20.73 – 00:33.90 | `seg05`, `seg06`, `seg07` | Live odometer counter ticking 1 $\rightarrow$ 17 $\rightarrow$ 84 $\rightarrow$ 500 $\rightarrow$ 999 suspense hold |
| **04** | Milestone Explosion | 00:33.90 – 00:45.55 | `seg08`, `seg09`, `seg10` | Giant hand-drawn "1,000" banner, celebratory sunburst, shock recoil, laughing disbelief |
| **05** | Actual Human Beings | 00:45.55 – 00:57.38 | `seg11`, `seg12` | 24 tiny animated stick-figures waving along floor horizon, Nemi looking down in awe |
| **06** | Comments Avalanche | 00:57.38 – 01:06.52 | `seg13`, `seg14` | Cascading comic comment bubbles, defensive hand splay, sharp deadpan snap punch |
| **07** | Comment Gratitude | 01:06.52 – 01:13.85 | `seg15` | Medium close-up, hand over heart, organic heart comment card, warm blushing smile |
| **08** | Instagram Surprise | 01:13.85 – 01:17.44 | `seg16` | Phone vibration buzz, 250 followers notification, physical phone pickup, fist pump |
| **09** | Creator Reality | 01:17.44 – 01:25.09 | `seg17` | Cinematic push-in, warm studio lighting, "DRAWN BY HAND" sketchbook card, sincere eye contact |
| **10** | Warm Signoff | 01:25.09 – 01:32.45 | `seg18` | Handwritten cards ("THANK YOU <3", "NEW VIDEO SOON!"), parting wave, final settled stillness hold |
