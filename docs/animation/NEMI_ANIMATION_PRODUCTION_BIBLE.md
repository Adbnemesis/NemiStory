# Nemi Animation Production Bible
## The Universal Direction, Animation, Timing, Visual & Sound Standard for Nemi Storytelling

**Document Status**: LOCKED & AUTHORITATIVE MASTER SPECIFICATION  
**Version**: 1.0  
**Applicability**: Universal across all episodes (Episode 00, Episode 01, Episode 02, Episode 03, and all future Nemi productions)  
**Target Engine**: Godot 4.x (Compatibility Renderer, 1280×720 Canvas with `canvas_items` stretch for 4K 3840×2160 native rendering, Frame-Accurate MovieWriter Mode)  
**Primary Aesthetic**: Hand-Drawn Illustrated Storytelling (Organic Pen & Ink, Selective Detail, Living Rig Acting, Controlled Stillness)  
**Authoritative Location**: `docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md`

---

## TABLE OF CONTENTS
1. [Purpose](#1-purpose)
2. [Core Creative Vision](#2-core-creative-vision)
3. [Character Lock](#3-character-lock)
4. [Live Character / Rig Rules](#4-live-character--rig-rules)
5. [Acting Philosophy](#5-acting-philosophy)
6. [Facial Acting](#6-facial-acting)
7. [Lip Sync](#7-lip-sync)
8. [Voice / Timing Architecture](#8-voice--timing-architecture)
9. [Visual Event System](#9-visual-event-system)
10. [Visual Density](#10-visual-density)
11. [Hand-Drawn Doodle System](#11-hand-drawn-doodle-system)
12. [Props](#12-props)
13. [Cutaways / Visual Metaphors](#13-cutaways--visual-metaphors)
14. [Expression FX](#14-expression-fx)
15. [Camera](#15-camera)
16. [Composition](#16-composition)
17. [Subtitles](#17-subtitles)
18. [SFX](#18-sfx)
19. [Ambience](#19-ambience)
20. [BGM Policy](#20-bgm-policy)
21. [Silence](#21-silence)
22. [Color / Monochrome](#22-color--monochrome)
23. [Hand-Drawn Visual Language](#23-hand-drawn-visual-language)
24. [Reusable Systems](#24-reusable-systems)
25. [Tool / Plugin Philosophy](#25-tool--plugin-philosophy)
26. [Licensing / Asset Safety](#26-licensing--asset-safety)
27. [Antigravity Rules](#27-antigravity-rules)
28. [Episode Production Workflow](#28-episode-production-workflow)
29. [Review / QA](#29-review--qa)
30. [Common Failure Modes](#30-common-failure-modes)
31. [Master Checklist](#31-master-checklist)
32. [Change Log](#32-change-log)

---

## 1. Purpose

This document is the **SINGLE SOURCE OF TRUTH** for how all Nemi animated videos are directed, animated, timed, visualized, subtitled, and sound-designed. 

It defines the universal production standards established, battle-tested, and locked during the creation of Nemi and Episode 00. Every future production task—whether executed by human directors or Antigravity AI agents—must treat this document as the foundational authority.

### Scope & Universal Applicability
* **Universal Standard**: Applies identically to Episode 00, Episode 01, Episode 02, Episode 03, and all subsequent videos.
* **Separation of Concerns**: This master document establishes the **production rules, creative principles, and architectural standards**. Episode-specific documents (such as scripts, beat manifests, or visual event maps) contain episode-specific content.
* **Zero Episode-Specific Pollution**: This document does **NOT** contain:
  - Episode 00-only timestamps or beat cues.
  - One-off episode jokes or narrative gags.
  - Episode-specific prop manifests.
  - Temporary engineering hacks or one-off test scripts.
* **Velocity Goal**: The overarching goal of this Bible is to make future Antigravity tasks exponentially faster. When an episode begins, Antigravity references this Bible, adheres to its locked systems, and focuses purely on creative, episode-specific execution.

---

## 2. Core Creative Vision

### Foundational Principle
> **NEMI IS A STORYTELLER, NOT A TALKING AVATAR.**

The viewer must always feel:
> *"A real person is telling a personal story through live, hand-drawn illustration."*  
> **NOT**: *"An animated puppet or VTuber is mechanically reciting a script."*

The goal of our production is **NOT "more animation"**—the goal is **"more storytelling through animation."** Every frame, movement, line, and sound exists solely to clarify, enhance, or punctuate the spoken narration.

### What We Are NOT Building
* **Not a VTuber / Talking Avatar**: No procedural floating, no automated head-sway idling, no random periodic eye darting, no continuous mouth-flapping loops.
* **Not a Game Character**: No physics ragdoll drift, no floaty procedural secondary physics, no constant idle bouncing.
* **Not Generic Motion Graphics**: No sterile corporate easing curves, no kinetic typography templates, no generic stock transitions.
* **Not a TikTok Caption Edit**: No overwhelming text walls, no bouncy karaoke animations, no emoji bombardment.
* **Not an AI-Generated Video**: No flickering diffusion frames, no morphing limbs, no inconsistent character redraws.

### The Visual Storytelling Hierarchy
When staging any moment, follow this strict priority hierarchy:
1. **Story / Narration**: The voice, cadence, and meaning of the line.
2. **Nemi's Acting**: Body posture, staging, gestures, and holds.
3. **Facial Emotion**: Eye contact, eyebrow angle, mouth state, and blush.
4. **Meaningful Visual Illustration**: Hand-drawn doodles, diagrams, and sketches clarifying the spoken thought.
5. **Props / Cutaways**: Tangible physical objects Nemi interacts with or full comic cutaways.
6. **Camera**: Snap reframing, close-ups, and punch-zooms for emphasis.
7. **Expression FX**: Authored reaction marks (sweat drops, anger veins, shock lines).
8. **Subtitles**: Clean, restrained $\le 5$-word chunks.
9. **SFX**: Punctuation audio cues strictly supporting actions.
10. **Decoration**: Negative space and ambient staging.

> [!IMPORTANT]
> **No lower-level element may ever distract from, cover, or conflict with a higher-level element.**

---

## 3. Character Lock

Nemi's visual identity, silhouette, proportions, and design are **PERMANENTLY LOCKED PRODUCTION CONSTANTS**.

### Locked Design Parameters
The following visual elements are fixed across all episodes and must **never** be casually altered or redesigned:
* **Face Identity**: Eye shape, iris proportion, facial contour, and hand-drawn pen-and-ink line hierarchy.
* **Hair Design & Color**: Signature ginger/auburn tone (`#b84328` base), parted fringe, side strands, and loose bun silhouette.
* **Eyes & Pupils**: Dark expressive pupils with white catchlights; responsive to fourth-wall engagement.
* **Core Outfit**: Signature oversized dark olive-green hoodie (`#536b5c`), relaxed collar, cream drawstring details, and dark leggings/shorts.
* **Basic Proportions**: Slender, slightly stylized 2D proportions; expressive hands with delicate pen lines.
* **Illustration Language**: Organic linework with controlled pen taper, subtle hand-drawn asymmetry, and warm cream canvas background (`#faf7f2`).
* **Core Color Palette**:
  - Background Canvas: `#faf7f2`
  - Nemi Hair: `#b84328`
  - Nemi Hoodie: `#536b5c`
  - Skin Tone: Warm peach ivory
  - Ink Lines: Deep charcoal/sepia `#2b2623` (never harsh pure `#000000`)

### No Per-Episode Redesigns
* Do **NOT** create alternative character versions for individual episodes.
* Do **NOT** dress Nemi in completely different clothes unless a specific narrative sequence explicitly demands a temporary costume (e.g. gym gear or winter coat), which must be approved as a deliberate production exception.
* The live Godot Nemi character (`characters/nemi/Nemi.tscn`) is the sole authoritative representation.

---

## 4. Live Character / Rig Rules

Nemi must always remain a **LIVE, RIGGED GODOT CHARACTER** (`Skeleton2D` + `Bone2D` + Procedural Canvas Item Rig).

```
characters/nemi/
├── Nemi.tscn                       # Root scene with high-level API
├── Nemi.gd                         # Primary directorial interface
├── actor/
│   ├── NemiActor.gd                # Skeleton2D controller & bone solver
│   ├── NemiEyes.gd                 # Pupil tracking & blink system
│   ├── NemiMouth.gd                # Viseme & illustrative mouth shapes
│   └── NemiBrows.gd                # Independent asymmetric eyebrow controller
└── fx/
    ├── NemiFXDirector.gd           # Procedural reaction FX toolkit
    └── FXShock.gd, FXSweat.gd, ... # Specialized vector FX instances
```

### Absolute Rig Prohibitions
* **NO Image Generation for Nemi**: Do NOT use AI image generators (Midjourney, Stable Diffusion, Imagen, etc.) to produce Nemi poses, expressions, turnaround sheets, or animation frames.
* **NO Sprite-Sheet Swaps**: Do NOT animate Nemi by flipping through pre-rendered full-body PNG sprites.
* **NO Cropped Screenshots**: Do NOT crop past render screenshots to fake poses.
* **NO Pre-baked Frame Sequences**: Nemi is posed and animated live in-engine via code and bone tweens.

### Allowed Deformation & Stylization
* **Procedural Squash and Stretch**: Controlled scale tweens on the root rig or bone nodes (e.g. $1.08\times$ squash on heavy landings, $0.94\times$ stretch on surprise jumps) are fully supported.
* **Cartoon Deformations**: Dynamic bone rotations, snappy snap-poses, and expressive posture shifts executed through the live Godot rig are encouraged.

---

## 5. Acting Philosophy

### Movement Rhythm: The Lifecycle of a Performance
Nemi does **NOT** move constantly. Constant motion produces visual fatigue and robs comedic beats of impact. The preferred acting rhythm is:

$$\text{STILLNESS} \longrightarrow \text{ATTENTION} \longrightarrow \text{MICRO-ACTION} \longrightarrow \text{REACTION} \longrightarrow \text{ACTION} \longrightarrow \text{SETTLE} \longrightarrow \text{STILLNESS}$$

1. **Stillness**: Stable, grounded hold while delivering exposition.
2. **Attention**: Subtle eye dart or brow shift signaling an incoming thought.
3. **Micro-Action**: Small head tilt or finger adjustment.
4. **Reaction**: Snappy emotional response to a realization or spoken line.
5. **Action**: Striking a definitive key pose (pointing, shrugging, slumping).
6. **Settle**: Brief cushion tween into the final resting pose (2–4 frames).
7. **Stillness**: Holding the pose with zero micro-jitter until the narrative shifts.

### Snappy Poses with Intentional Holds
* **Snappy Pop**: Transitions between poses should be fast and punchy (typically $0.12\text{s}$ to $0.25\text{s}$). Avoid slow, rubbery cross-fades between poses.
* **The Golden Hold**: Once Nemi strikes a pose, **HOLD IT** for $0.8\text{s}$ to $3.0\text{s}$. Do not apply procedural breathing drift or random noise while holding. The stillness conveys confidence and deliberate comedic timing.

### Micro-Acting
Micro-acting enriches quiet moments without introducing distracting large-body movements:
* **Eye Darts**: Shifting gaze from the camera to the upper-left when recalling an embarrassing memory.
* **Eyebrow Cock**: Lifting one brow while the other remains neutral to express skepticism.
* **Head Tilt**: A subtle $4^\circ$ to $8^\circ$ tilt to convey curiosity or perplexity.
* **Shoulder Drop**: Dropping the torso by 4 pixels on an exasperated sigh.
* **Selective Application**: Never activate every micro-action at once. Pick **one** micro-gesture to punctuate a phrase.

### Gesture Language
All gestures must communicate specific narrative intent. Reusable, canonical gestures include:
* `point`: Index finger extended to indicate a prop, doodle, or camera frame.
* `open_palm`: Explaining a concept with open, honest vulnerability.
* `gesture_self`: Pointing or tapping her own chest when discussing personal blunders.
* `gesture_outward`: Presenting an absurd external situation to the viewer.
* `count_fingers`: Ticking off points, failed attempts, or rules.
* `shrug`: Palms up, shoulders raised, head cocked on a deadpan concession.
* `hand_on_chest`: Genuine surprise, mock modesty, or catching breath.
* `thinking`: Hand near chin, eyes averted upward.
* `hands_together`: Pleading, hoping, or introducing an earnest request.
* `small_wave`: Intimate fourth-wall greeting or farewell.
* `heroic_pose`: Hands on hips, chest puffed out, chin high before an inevitable fail.
* `recoil`: Head and torso pulled back sharply in shock or second-hand embarrassment.

---

## 6. Facial Acting

The face is the primary emotional focal point of every shot. A convincing emotional reaction is never achieved by changing the mouth alone; it requires a coordinated symphony across the entire facial system.

```
                  ┌───────────────────────────────┐
                  │          FACIAL ACTING        │
                  └───────────────┬───────────────┘
          ┌───────────────────────┼───────────────────────┐
          ▼                       ▼                       ▼
    [EYES & GAZE]          [EYEBROWS]               [MOUTH]
    • Camera (4th wall)    • Asymmetric Skepticism  • Illustrative Visemes
    • Averted (Recalling)  • Raised (Surprise)      • Expressive Shapes
    • Drifting (Awkward)   • Furrowed (Frustration) • Deadpan Dash
          │                       │                       │
          └───────────────────────┼───────────────────────┘
                                  ▼
                     [HEAD ANGLE & CHEEK BLUSH]
                     • Tilt on curiosity / doubt
                     • Pink blush on genuine shame
```

### Core Facial Elements
* **Pupil Tracking (`NemiEyes.gd`)**:
  - `camera`: Direct eye contact with the viewer. Used for intimacy, direct confessions, and staring down the lens during deadpan punchlines.
  - `averted_left` / `averted_right`: Looking away while remembering, calculating, or evading truth.
  - `wide`: Constricted small pupils within wide sclera for shock, horror, or panic.
* **Eyebrows (`NemiBrows.gd`)**:
  - Eyebrows carry $80\%$ of emotional tone.
  - Asymmetric configurations (e.g. left brow arched, right brow flat) communicate dry irony, sarcasm, and self-awareness.
  - Symmetrical high arch communicates genuine surprise or innocent inquiry.
  - Symmetrical furrow communicates stubborn determination or mounting irritation.
* **Cheek Blush (`blush`)**:
  - Soft watercolor pink wash on the cheeks.
  - Strictly reserved for genuine embarrassment, extreme physical exertion, or heartfelt vulnerability. Never leave blush on permanently.
* **Blinking**:
  - Blinks occur on narrative punctuation marks, after sudden camera cuts, or to emphasize a cognitive pause.
  - Never trigger blinks on an automated periodic clock (e.g. "blink every 3.5 seconds").

---

## 7. Lip Sync

### Illustrative, Lightweight Visemes
Nemi uses an **illustrative, stylized approach to lip-sync**, inspired by classic hand-drawn cartooning.
* **The Goal**: The viewer can clearly and instantly tell that Nemi is speaking.
* **What It is NOT**: It is **NOT** anatomical, 60 FPS phoneme tracking. Mechanical lip flapping looks robotic and conflicts with the hand-drawn aesthetic.

### Canonical Mouth States
The mouth controller (`NemiMouth.gd`) exposes broad, expressive shapes:
* `REST`: Neutral, soft closed line.
* `CLOSED`: Tight closed seal (used for $M, P, B$ consonants and tight pauses).
* `SMALL_OPEN`: Subtle opening for conversational delivery and unstressed vowels.
* `A_E`: Wide horizontal opening for vowels like *"cat"*, *"bed"*, *"say"*.
* `O_U`: Rounded, pursed circular mouth for *"go"*, *"you"*, *"two"*.
* `WIDE`: Large open mouth for shouting, high-energy emphasis, or excited projection.
* `SMILE`: Upturned happy conversational mouth.
* `FROWN`: Downturned exasperated or disappointed mouth.
* `LAUGH`: Wide open laughing crescent.
* `SHOCK`: Small vertical oval or wide open dropped jaw.
* `DEADPAN_DASH`: Perfectly straight horizontal pen stroke ($-\;-$). The signature Nemi reaction.

### Rules of Engagement
1. **Never Flap Continuously**: Do not cycle mouth shapes rapidly without regard to syllable structure. Viseme changes should occur at an illustrative cadence of $12\text{--}15\text{ FPS}$.
2. **Emotion Overrides Lip Sync**: When a strong emotion hits (shock, deadpan, horrified realization), **EMOTION TAKES PRECEDENCE**. If Nemi delivers a dry punchline with a deadpan expression, the mouth remains locked in `DEADPAN_DASH` or `REST` even while speaking, or moves with minimal opening.
3. **Instant Closure on Silence**: The exact millisecond dialogue pauses, the mouth snaps shut to `REST` or `DEADPAN_DASH`. Never leave the mouth hanging open during a pause.

---

## 8. Voice / Timing Architecture

### The Central Law: Voice is the Master Clock
> [!CAUTION]
> **THE RECORDED VOICEOVER AUDIO IS THE SOLE TIMING AUTHORITY FOR THE ENTIRE PRODUCTION.**

Never calculate animation, subtitle, or SFX timing from:
* Script character count or word count.
* Guessed average words-per-minute estimates.
* Rough sentence counts.
* Manual guesswork.

### The Downstream Production Flow
All timing flows strictly downstream from the audio waveform:

$$\boxed{\textbf{VOICE AUDIO}} \longrightarrow \boxed{\textbf{AUDIO ALIGNMENT}} \longrightarrow \boxed{\textbf{TIMING DATA}} \longrightarrow \begin{cases} \textbf{Lip-Sync Visemes} \\ \textbf{Subtitle Chunks} \\ \textbf{Acting Keyframes} \\ \textbf{Doodle Draws} \\ \textbf{Camera Snaps} \\ \textbf{SFX Cues} \end{cases}$$

### Audio Alignment Data
* Every episode processes the locked master voice track through an audio alignment pipeline (e.g. Whisper word timestamps or gentle acoustic forced alignment) to produce authoritative JSON timing data (`speech_active_intervals`, `word_timestamps`, `silence_intervals`).
* **The canonical script** remains authoritative for correct spelling, capitalization, and punctuation.
* **The alignment data** provides the exact microsecond timestamps.

### Never Alter Audio to Fix Animation
* If a visual gag is late, **adjust the animation code**.
* If a subtitle card drifts, **adjust the subtitle timing**.
* **NEVER**:
  - Time-stretch or compress the voice track.
  - Move the voice track relative to global zero.
  - Re-record or modify pronunciation to compensate for animation lag.

### Deterministic Frame-Accurate Clock
In Godot, MovieWriter mode renders offline frames deterministically at 60 FPS:

$$\text{Frames} = \text{round}(\text{timestamp\_seconds} \times 60.0)$$

All timelines, beat coordinators, and subtitle managers must track integer frames or calculate `time = frame / 60.0` rather than relying on non-deterministic system clocks (`Time.get_ticks_msec()`) or wall-clock timers.

---

## 9. Visual Event System

### Definition of a Visual Event
A **VISUAL EVENT** is any authored change in the visual state of the frame that delivers new narrative information or emotional punctuation to the viewer:
* Key pose shift or posture change.
* Facial expression or eyebrow change.
* Eye gaze redirection.
* Illustrative mouth shape transition.
* Hand gesture initiation or settle.
* Hand-drawn prop appearance, drop, or pickup.
* Doodle draw-on or graphic underline.
* Procedural expression FX trigger (sweat drop, shock line).
* Camera punch-zoom, snap cut, or reframe.
* Subtitle card transition.
* Background color wash shift.
* Cutaway illustration reveal.
* **Intentional complete freeze** (the sudden absence of motion is an active visual event).

### Directorial Intent: "Why Now?"
Every visual event must have an immediate narrative justification:
* *Why did the camera zoom?* $\longrightarrow$ To punch in on an awkward realization.
* *Why did the arrow draw?* $\longrightarrow$ To direct attention to the dumbbell weight mark.
* *Why did Nemi freeze?* $\longrightarrow$ To honor the deadpan silence after a failed attempt.
* **If there is no clear narrative answer to "Why?", DELETE THE EVENT.**

---

## 10. Visual Density

### The 2–3 Second Stagnation Check
As an overarching storytelling guideline, review the timeline roughly every **2 to 3 seconds** and ask:
> *"Has the viewer received a new meaningful visual idea?"*

```
[0.0s] Nemi delivers premise (Rest Pose, medium shot)
  │
[1.8s] Mentions research struggle ──► Hand-drawn CLOCK doodle begins drawing
  │
[3.6s] Spoken word "disaster" ──► Nemi head tilts, brow raises, Level 2 sweat drop
  │
[5.2s] Deadpan realization ──► Camera punches 1.35x, Nemi freezes in deadpan hold
  │
[7.0s] Recovery line ──► Doodle clears, camera snaps wide, Nemi shrugs
```

### Crucial Distinctions: Anti-Stagnation $\ne$ Hyperactivity
* **The rule does NOT mean**:
  - Spawn an object every 2 seconds.
  - Move the camera every 2 seconds.
  - Force Nemi to wave her arms every 2 seconds.
* **Rich, Not Busy**: Visual density means visual ideas, not visual clutter.
* **Stillness is Valid**: If Nemi has just delivered an absurd punchline and the scene demands an awkward 1.5-second freeze, **PRESERVE THE STILLNESS**. Do not inject random doodles or twitching to satisfy an artificial timer.

### Visual Stagnation Checklist
If you identify a 4+ second stretch where:
- Nemi is centered in the same pose,
- The camera is stationary,
- No doodle or prop is active,
- Dialogue is continuing,
**Then visual stagnation has occurred.** Immediately introduce one purposeful element:
1. An illustrated doodle annotating the keyword.
2. A subtle micro-acting gesture or eye shift.
3. A camera snap to medium close-up.
4. A story-specific prop interaction.

---

## 11. Hand-Drawn Doodle System

The Doodle / Ink Storytelling System makes future Nemi videos feel as though **the story is being actively illustrated and annotated in real time as Nemi tells it**.

```
world/doodles/
├── NemiDoodleDirector.gd          # Central doodle orchestrator
├── DoodleInstance.gd              # Base drawing canvas & stroke animator
└── InkStroke.gd                   # Mathematical curved stroke generator
```

### Architectural Separation
To maintain modularity and prevent visual chaos, three distinct graphic systems are enforced:
1. **Expression FX**: Emotional reaction marks mounted to Nemi's character rig (`NemiFXDirector.gd`).
2. **Props**: Tangible, interactable objects Nemi physically touches or manipulates (`NemiPropLibrary.gd`).
3. **Doodles**: Living drawings, ink annotations, arrows, sketches, and graphic labels drawn onto the environment canvas (`NemiDoodleDirector.gd`).

### Core Philosophy: Progressive Draw-On
* **Never Simply Fade In**: A static PNG fading in looks like a slideshow. Doodles feel hand-drawn because they reveal along an ink stroke path ($0\% \longrightarrow \text{partial} \longrightarrow 100\%$).
* **Stroke Progression Examples**:
  - *Arrow*: Shaft initiates at root $\longrightarrow$ line sweeps forward $\longrightarrow$ arrowhead chevrons snap into place.
  - *Circle*: Arc starts at 12 o'clock $\longrightarrow$ sweeps around clockwise $\longrightarrow$ closes with a slight hand-drawn overlap.
  - *Underline*: Snappy left-to-right organic pen stroke beneath a key word.
  - *Checkmark*: Short downward stroke $\longrightarrow$ snappy upward hook.
  - *Diagram / Blueprint*: Major structural lines draw first $\longrightarrow$ cross-hatching and annotations draw second.

### Controlled Imperfection (No Random Jitter)
* **Authored Human Inking**: Doodles possess organic line-weight modulation, slight curvature imperfections, and tapered ink ends.
* **Deterministic Math**: Use fixed seed curves, sine modulation, and authored vector points. **NEVER use per-frame random jitter/noise.** Jittering lines look like technical glitching rather than intentional pen-and-ink art.
* **No Stock Graphics**: Absolutely no generic SVG icons, stock emojis, or corporate clip art. Every doodle shares Nemi's sketchbook linework.

### World-Space vs Screen-Space
* **World-Space Doodles** (`z_index = 15` behind Nemi, `z_index = 25` in front of Nemi): Placed inside the room/environment coordinate system. When the camera pans or punches in, world doodles scale and move naturally with the scene.
* **Screen-Space Doodles** (`z_index = 100` via CanvasLayer): Pinned to the camera viewport (e.g. editorial margin brackets, screen-edge question marks, or fourth-wall pointers).

### Density & Lifecycle
* **Transient Storytelling**: Doodles are temporary aids. Once the spoken point has been made, clear them via `erase(duration)`, `fade_out(duration)`, or `shrink_out(duration)`.
* **Density Balance**: Do not let annotations pile up until the screen resembles a cluttered whiteboard, unless a deliberate comedic escalation (e.g. "conspiracy theory board") is specifically required.

---

## 12. Props

Props are living, tangible illustration assets that exist in Nemi's world.

### The Canonical Prop Lifecycle
Props should not abruptly materialize in mid-air and freeze. Follow the standard lifecycle:

$$\boxed{\textbf{ENTER}} \longrightarrow \boxed{\textbf{NOTICE}} \longrightarrow \boxed{\textbf{INTERACTION}} \longrightarrow \boxed{\textbf{REACTION}} \longrightarrow \boxed{\textbf{PAYOFF}} \longrightarrow \boxed{\textbf{EXIT}}$$

1. **Enter**: Prop enters the scene with physical personality (`pop_in()`, `drop()` from top of frame, or `slide_in()`).
2. **Notice**: Nemi's gaze or head turns toward the prop.
3. **Interaction**: Nemi points to it, picks it up, lifts it, or types on it.
4. **Reaction**: The prop causes a consequence (e.g. dumbbell drops heavily, phone screen flashes).
5. **Payoff**: Comedic beat lands.
6. **Exit**: Prop exits cleanly (`drop()`, `fade_out()`, or `put_down()`).

### Canonical Reusable Prop Behaviors (`BaseProp.gd`)
All props in `world/props/NemiPropLibrary.gd` implement standardized behavioral primitives:
* `pop_in(duration)`: Snappy elastic pop with $10\%$ scale overshoot.
* `drop(distance, duration)`: Gravity fall with ground thud rebound.
* `bounce(height, duration)`: Comedic vertical bounce.
* `shake(intensity, duration)`: Vibration under strain or ringing.
* `slide_to(target_pos, duration)`: Smooth illustrative repositioning.
* `attach_to(bone_node, offset)`: Locks prop transform to Nemi's hand or body bone.
* `detach()`: Releases prop back into world space.

### Aesthetic Quality & Linework
* Props share Nemi's organic charcoal/sepia pen outline (`#2b2623`, 3–4px line weight).
* Flat, restrained color fills harmonized with the master palette.
* Never use textured 3D models or photorealistic PNGs.

---

## 13. Cutaways / Visual Metaphors

Nemi does not need to remain on screen for every single sentence. Visual cutaways provide comedic breathing room and expand the world.

### Cutaway Modalities
1. **Full Illustrated Cutaway**: The scene transitions completely to an imagined flashcard or hypothetical scenario (e.g. stick-figure walking, slipping on bananas, or an absurd historical diagram).
2. **Comic Split-Card / Inset Card**: A framed rectangular comic panel drops into the upper portion of the frame ($y = 120\text{px}$) while Nemi remains grounded below, pointing upward and reacting to the illustration.

### Visual Metaphors
When dialogue expresses an abstract concept or idiom, ask: **"Can this be visualized literally for comedic effect?"**
* *"Down a rabbit hole"* $\longrightarrow$ Cutaway of an actual underground burrow packed with useless trivia books.
* *"Six hours of research"* $\longrightarrow$ Fast-spinning clock face surrounded by crumpled ink papers.
* *"Brain shut down"* $\longrightarrow$ Small doodle brain displaying a cartoon loading spinner or error code.
* *"Confidence of an anime hero"* $\longrightarrow$ Dramatic background speed lines, glowing sparkle, and extreme low-angle heroic chin tilt.

### Consistency Rule
All cutaways and visual metaphors must be drawn in the **identical hand-drawn art style** as Nemi. They must never look like imported foreign assets.

---

## 14. Expression FX

Expression FX are authored, procedural 2D visual accents that amplify character emotions. They are managed centrally via `characters/nemi/fx/NemiFXDirector.gd`.

### The Canonical Reaction Toolkit
| FX Type | Visual Manifestation | Narrative Context |
|---|---|---|
| `shock` | Sharp radiating vector lines, pupil shrink | Sudden realization, catastrophic error, startling noise |
| `sweat` | Organic teardrop beads sliding down temple | Embarrassment, awkward social tension, panic |
| `anger` | Four-pronged red/crimson tension cross | Frustration, stubborn defiance, boiling irritation |
| `confusion` | Hand-drawn question mark or spiral scribble | Baffling instructions, unexpected outcomes |
| `sparkle` | Four-point golden star glint | Smug pride, breakthrough idea, heroic confidence |
| `gloom` | Vertical dark hatched drop lines | Crushing defeat, fatigue, DOMS collapse |
| `vibration` | High-frequency physical trembling of the rig | Extreme physical strain, lifting heavy weights |
| `panic` | Orbiting sweat droplets + scribble cloud | Complete loss of control, multitasking disaster |
| `deadpan` | Zero marks, horizontal dash mouth, silence | Dry realization, absurd pause, staring at camera |

### The Absolute Rules of Expression FX
> [!IMPORTANT]
> 1. **Strictly Explicit (Zero Automatic FX)**: FX must NEVER appear automatically as a byproduct of changing expressions, pausing speech, or switching scenes. Every FX trigger must be an intentional directorial call (`nemi.fx(...)`).
> 2. **NO Automatic Ellipsis (`...`)**: The three-dot reaction is **NOT** a default animation. Floating dots look cheap when automated. The canonical Nemi deadpan is pure stillness and a horizontal pen dash mouth. Ellipsis FX is strictly opt-in on explicit director request.
> 3. **Intensity Levels ($1\text{--}5$)**:
>    - **Level 1 (Subtle)**: Single tiny sweat drop, single small question mark.
>    - **Level 2 (Mild)**: Noticeable reaction mark, soft brow shift.
>    - **Level 3 (Normal)**: Standard animated FX with corresponding head tilt.
>    - **Level 4 (Strong)**: Dramatic multi-element FX with body recoil.
>    - **Level 5 (Climactic)**: Full-screen comedic payoff (reserved for peak episode climaxes).
> 4. **Rig Anchoring**: FX attach to defined skeleton sockets (`head_top`, `head_left`, `head_right`, `forehead`, `chest`) rather than hardcoded global screen coordinates.

---

## 15. Camera

The camera is an instrument of **comedic punctuation and narrative focus**, not a wandering observer.

### Camera Movement Philosophy
* **Snap Cuts & Punch-Zooms**: The camera does not drift slowly around the room. It cuts instantly ($0\text{ frames}$) or snaps aggressively in $3\text{--}6\text{ frames}$ with a snappy cubic ease.
* **Camera as Punctuation**: A camera snap lands precisely on an accented syllable, a punchline word, or a sudden silence.
* **No Continuous Drift**: Do not apply continuous procedural handheld sway or drone panning. It induces motion sickness and destroys the hand-drawn composition.

### Standard Framing Concept Scale
* **Wide Shot ($1.0\times$ Zoom)**: Shows full upper body, desk environment, and staging for props. Used for introductions, physical demonstrations, and establishing beats.
* **Medium Shot ($1.15\times$ Zoom)**: Default conversational framing. Balances Nemi's facial performance with room for lower-third subtitles and floating doodles.
* **Medium Close-Up ($1.30\times$ Zoom)**: Intimate storytelling, personal confessions, and focused dialogue.
* **Punch Close-Up ($1.45\times\text{--}1.55\times$ Zoom)**: Focuses tightly on Nemi's face. Reserved for sudden shock, mortifying embarrassment, deadpan camera stares, and climactic punchlines.
* **Prop Close-Up**: Camera reframes and shifts center to spotlight a specific prop or illustration.

---

## 16. Composition

### Layout & Negative Space
* **Rule of Thirds**: Nemi should typically occupy the left third or center-left of the canvas ($x \approx 420\text{--}520\text{px}$ in $1280\times 720$ coordinates). This leaves the entire right half open for doodles, diagrams, and props.
* **Negative Space is Mandatory**: Do not feel compelled to fill every pixel. Clean cream canvas space (`#faf7f2`) provides visual elegance and allows the eye to rest.
* **No Center-Lock Monotony**: Avoid keeping Nemi dead-center at $1.15\times$ zoom for more than two consecutive beats. Alternate staging (Nemi left + prop right; punch-zoom center; cutaway panel right).

### Layer Hierarchy (Z-Index Standards)
To prevent visual collisions, respect the established layer stack:
```
Layer 0  (z = -50) : Background canvas wash & room wall art
Layer 1  (z = -10) : Grounded environment props (desk, chair)
Layer 2  (z =  15) : Background Doodles (drawn behind character)
Layer 3  (z =  20) : Nemi Character Rig (Skeleton2D, body, face)
Layer 4  (z =  25) : Foreground Doodles & Held Props (in hand)
Layer 5  (z =  40) : Expression FX (sweat, shock, sparkles)
Layer 6  (z =  60) : Cutaway Inset Cards & Comic Panels
Layer 7  (z = 100) : Subtitles & Screen-Space UI Elements
```

### Collision Rules
* **Eyes & Mouth Clear**: Doodles, props, and subtitles must **never** occlude Nemi's eyes or mouth.
* **Subtitle Safety Corridor**: The bottom $120\text{px}$ of the frame ($y = 600\text{--}720\text{px}$) is reserved exclusively for subtitles. Never place props or critical illustration details in this zone.

---

## 17. Subtitles

Subtitles are a core component of the visual storytelling language, ensuring accessibility and underscoring comedic rhythm.

### The Immutable Word Limit
> [!CAUTION]
> **HARD RULE: MAXIMUM 5 WORDS VISIBLE AT ONE TIME.**
> 
> * **Approved**: 2 to 4 words per card (e.g. `Wait.`, `Hear me out.`, `Turns out... geometry has hands.`).
> * **STRICTLY PROHIBITED**: 6+ words, full sentence blocks, multi-line paragraphs, or walls of text.

### Visual Styling & Typographic Standard
* **Font**: Clean, highly readable, modern geometric sans-serif (Inter, Outfit, or Roboto).
* **Fill & Border**: Crisp white fill (`#ffffff`) with a solid, dark charcoal outline (`#2b2623`, 4–6px stroke) or soft semi-transparent backing capsule for absolute legibility.
* **Position**: Centered horizontally ($x = 640\text{px}$), anchored in the lower safety corridor ($y = 650\text{--}660\text{px}$).
* **No Word-by-Word Karaoke Bounce**: Subtitle cards appear as complete phrases and hold steadily until the next chunk. Do NOT use rapid word-by-word bouncing, rainbow color cycles, or hyperactive TikTok text animations.

### Timing Precision
* Subtitle cards are generated directly from **authoritative aligned word timestamps**.
* Never divide a sentence into equal-duration mechanical slices.
* The card appears exactly when the first word is spoken and disappears cleanly when speech pauses.

---

## 18. SFX

Sound effects are **AUDIO PUNCTUATION**, not continuous sonic wallpaper.

### Philosophy of Restraint
* **Normal Dialogue**: Frequently has **ZERO SFX**. Let the voice carry the performance.
* **Physical Action**: Exactly **ONE** crisp sound cue (e.g. a dull thud when placing a mug, a snap on a gesture).
* **Comedic Climax**: 1–2 well-timed cues (e.g. record scratch into sudden silence).
* **Layered Audio**: Reserved strictly for major climactic payoffs.

### Event SFX Duration Limits
* **Target Duration**: **0.1 seconds to 2.0 seconds**.
* **2.0s to 2.5s**: Inspect closely; trim tail if necessary.
* **Over 3.0s**: **PROHIBITED as an Event SFX**. Sounds $>3.0\text{s}$ are ambience or sustained beds.
* **10+s / 30–40s**: **NEVER trigger as an event sound.** Continuous long-form audio belongs in dedicated ambience streams.

### The Keyboard Typing Rule
> [!IMPORTANT]
> **NEVER play a continuous 30-second typing sound bed underneath dialogue.**
> Typing audio is strictly event-based:
> 1. Play a short burst ($0.5\text{s}$ to $1.25\text{s}$) while Nemi is actively, visibly typing on screen.
> 2. Stop audio immediately when hands lift or speech resumes.
> 3. Optional second short burst only if typing resumes.

### Explicit Directorial Triggering
* SFX do **NOT** trigger automatically when Nemi blinks, when the camera moves, when subtitles change, or when an expression shifts.
* Every sound effect must be explicitly called by the director (`sfx.play_event("impact_light_01")`).

---

## 19. Ambience

Ambience represents the physical acoustic reality of the space (room tone, gym reverberation, outdoor air).

### Ambience Principles
* **Distinct Subsystem**: Ambience is routed through dedicated background audio buses and looping players, completely separate from one-shot Event SFX.
* **Subtle & Subservient**: Ambience must sit far below dialogue, typically at **$-18\text{ to } -24\text{ dBFS}$**. The viewer should perceive the room tone subconsciously, never consciously fight it to hear Nemi.
* **Instant Ducking on Punchlines**: During deadpan pauses or sudden comedic cuts, cut or duck ambience instantly to zero to heighten the awkwardness.

---

## 20. BGM Policy

### BGM is OFF BY DEFAULT
> [!IMPORTANT]
> **DO NOT ASSUME EVERY NEMI VIDEO REQUIRES BACKGROUND MUSIC.**
> 
> The default, canonical sound design for Nemi storytime videos is:
> $$\textbf{VOICE} \;+\; \textbf{SELECTIVE SFX} \;+\; \textbf{DELIBERATE SILENCE}$$

### When BGM is Permitted
Background music may only be introduced when:
1. The script specifically calls for a stylized musical parody (e.g. dramatic anime tournament choir, elevator music in an awkward pause, 8-bit retro gaming sequence).
2. A scene genuinely benefits from an emotional acoustic shift.
3. A deliberate musical sting is used as a punchline.

### Prohibitions
* Never add generic lo-fi hip-hop or elevator music simply because the timeline feels "empty."
* Never allow music to obscure vocal articulation or speech frequencies ($1\text{kHz}\text{--}4\text{kHz}$).

---

## 21. Silence

> **SILENCE IS THE FUNNIEST PUNCHLINE IN THE ENTIRE SHOW.**

In Nemi's storytelling, silence is not an empty gap waiting to be filled—it is an active, deliberate comedic weapon.

### The Anatomy of a Deadpan Silence Beat
When an absurd admission, shocking realization, or catastrophic mistake occurs:
1. **Dialogue stops** instantly.
2. **SFX stops** instantly.
3. **Ambience/music cuts** to absolute zero.
4. **Nemi freezes completely**: $0$ motion, $0$ blink, straight horizontal dash mouth, eyes locked directly on the lens.
5. **Hold duration**: Hold for **$0.8\text{s}$ to $1.8\text{s}$**.
6. **Resolution**: A single tiny blink, an averted eye shift, or a soft, understated *"Cool."*

### Zero Nervous Fillers
Never fill awkward pauses with nervous soundboard clicks, procedural camera drift, or background sweeps. Honor the silence.

---

## 22. Color / Monochrome

Color transitions are narrative storytelling devices, never random aesthetic filters.

### Approved Color Modalities
* **Default Palette**: Warm cream paper background (`#faf7f2`), ginger auburn hair (`#b84328`), olive green hoodie (`#536b5c`), warm ivory skin.
* **Monochrome Ink-Drain (Exhaustion / Despair)**:
  - On total physical or creative collapse (e.g. post-leg-day DOMS, realizing an animation file didn't save), desaturate Nemi to ash-grey line art (`#6e6e6e`).
  - Accompanied by vertical gloom hatch marks and complete physical slump.
* **Crimson / Midnight Wash (Anime Tension / High Stakes)**:
  - Background shifts to deep maroon/crimson (`#4a2028`) or midnight navy (`#1c202c`) to evoke dramatic shonen battle stakes during trivial everyday challenges (e.g. attempting to lift an Olympic barbell).
* **Warm Amber Spotlight**:
  - Soft amber vignette for nostalgic childhood memories or quiet, sincere reflections.

---

## 23. Hand-Drawn Visual Language

The entire visual ecosystem of Nemi—character, props, doodles, cutaways, and text—must stem from the same cohesive **pen-and-ink illustration sketchbook**.

### Aesthetic Pillars
* **Organic Linework**: Ink lines feature natural hand-drawn contours, subtle pressure variation, and soft tapered terminals.
* **Controlled Imperfection**: Angles are slightly softened; boxes and circles have slight organic wobble. They look authored by a skilled human artist, not rendered by a CAD application.
* **Restrained Palette**: Clean cream canvas background with harmonized accent tones (olive, ginger, warm gold, crimson).
* **Prohibited Visual Aesthetics**:
  - ❌ Glossy 3D models or specular highlights.
  - ❌ Photorealistic textures or stock photography.
  - ❌ Generic vector clipart or corporate flat infographics.
  - ❌ Neon glowing shaders or particle emitters.
  - ❌ Stock digital emoji sets.

---

## 24. Reusable Systems

Every technical implementation must favor clean, reusable primitives over messy, copy-pasted one-off code.

### Canonical Directorial APIs
Future episode scripts must invoke standardized API calls rather than writing hundreds of lines of bespoke tweens:

```gdscript
# CHARACTER ACTING & POSING
nemi.pose("smug", 0.15)                         # Snappy key pose
nemi.pose("defeat", 0.25)                       # Exhausted slump posture
nemi.freeze_stillness(1.50)                     # Deadpan pause hold

# FACIAL & EMOTIONAL PERFORMANCE
nemi.set_expression("deadpan")                  # Straight dash mouth, neutral eyes
nemi.set_expression("shock")                    # Wide pupils, arched brows, dropped jaw
nemi.actor.eyes.look("camera")                  # Direct fourth-wall engagement
nemi.actor.eyes.look("averted_up_left")         # Recalling memory

# PROCEDURAL REACTION FX (Explicit Only)
nemi.fx("anger", "head_right", 2, 1.8)          # Level 2 anger vein, holds 1.8s
nemi.fx("sweat", "head_left", 3, 2.0)           # Level 3 sweat drop, holds 2.0s
nemi.fx("shock", "head_top", 4, 1.5)            # Level 4 radial shock burst

# HAND-DRAWN DOODLES
var arrow = doodle_director.draw_arrow(start_pos, end_pos, 0.35)
var circle = doodle_director.draw_circle(target_pos, radius, 0.40)
var label = doodle_director.draw_label("6 HOURS", label_pos, 0.25)
await arrow.erase(0.20)

# REUSABLE PROPS
var prop = NemiPropLibrary.create_prop("dumbbell")
add_child(prop)
prop.attach_to(nemi.actor.right_hand, Vector2(12, -4))
await prop.pop_in(0.20)
await prop.shake(0.5, 0.2)
prop.drop(150.0, 0.25)

# AUDIO SFX
sfx.play_event("impact_heavy_01")
sfx.play_event("scribble_fast_02")
```

---

## 25. Tool / Plugin Philosophy

Do not install third-party plugins, addons, or external libraries simply because they exist.

### The Adoption Protocol
$$\boxed{\textbf{AUDIT}} \longrightarrow \boxed{\textbf{TEST}} \longrightarrow \boxed{\textbf{COMPARE}} \longrightarrow \boxed{\textbf{ADOPT ONLY IF SUPERIOR}}$$

1. **Audit**: Does Godot's built-in engine feature (e.g. `Tween`, `Line2D`, `MovieWriter`, `AudioStreamPlayer`) already solve the problem cleanly? If yes, use built-in.
2. **Test**: Isolate candidate plugins in a sandbox test project (`ToolkitTests/`).
3. **Compare**: Measure frame-rate stability, memory footprint, headless compatibility, and Apple Silicon / Metal compatibility.
4. **Adopt Only If Superior**: Adopt external tools only if they dramatically simplify code or enhance visual quality without introducing bloat.

### Toolkit Standards
* Zero bloat: Keep the minimal set of reliable systems.
* Commercial safety: Permissive open-source licenses (MIT, Apache 2.0, CC0) only.
* Deterministic rendering compatibility: Must operate flawlessly with Godot's offline frame capture.

---

## 26. Licensing / Asset Safety

Every asset introduced into the Nemi project repository must undergo strict provenance verification.

### Provenance Verification Rules
* **Commercial Safety**: Assets must be verified as **CC0 1.0 Universal, Public Domain, or commercial-safe MIT/Apache 2.0**.
* **Zero Ambiguous Downloads**: Never import sound files or graphics from "free download" websites without explicit, verifiable license grants.
* **Registry Logging**: Every external audio file must be cataloged in `docs/audio/SFX_License_Registry.md` with:
  - Source URL
  - Author / Creator
  - Stated License
  - Duration in seconds
  - Master peak dBFS
  - Narrative usage classification

---

## 27. Antigravity Rules

When Antigravity AI agents operate on the Nemi codebase, they must follow these strict operational rules:

1. **Inspect Existing Architecture First**: Never invent new frameworks or directories when working systems already exist.
2. **Read This Bible**: Adhere strictly to the established visual, timing, acting, subtitle, and audio standards.
3. **No Blind Rebuilding**: Enhance existing beat scenes incrementally; never overwrite working scenes with scratch code.
4. **Never Use Image Models for Nemi**: Nemi is a live rigged character. Never propose generating PNG poses via external image generators.
5. **Deterministic MovieWriter Rules**: Never use `create_timer()` or real-time wall-clock functions for MovieWriter rendering. Use frame-accurate counting (`RenderingServer.frame_post_draw` or integer frame tracking).
6. **Inspect Actual Renders**: Do not assume code that compiles correctly looks good. Review rendered video frames and audit outputs before declaring tasks complete.

---

## 28. Episode Production Workflow

Every future Nemi episode follows the strict **18-Step Production Pipeline**:

```
[CONCEPT & PRE-PRODUCTION]
 1. Core Narrative Concept & Anecdote
 2. Script Writing & Beat Partitioning (7–8 narrative beats)
 3. Voiceover Audio Generation (Locked Master WAV)
 4. Voice Alignment & Timestamp Extraction (Authoritative JSON)
 5. Visual Beat Map Authoring (EPXX_Visual_Event_Map.md)

[PLANNING & CHOREOGRAPHY]
 6. Character Acting & Posture Plan
 7. Doodle & Illustration Plan
 8. Story-Specific Prop Plan
 9. Expression FX Reaction Plan
10. Camera Framing & Punch-Zoom Plan
11. Subtitle Timing Plan (≤5 words per card)
12. SFX Punctuation Plan (Short event cues)

[IMPLEMENTATION & RENDERING]
13. Beat-by-Beat Godot Implementation
14. Individual Beat Preview Render & Audit
15. Full Episode Offline MovieWriter Render (4K Native canvas_items)
16. Multi-Perspective Review Pass (Mute, Audio-Only, Subtitle)
17. Audio Mastering & Headroom Verification (>1.0 dBFS safety)
18. Final Master Video Delivery
```

---

## 29. Review / QA (The 6-Way Audit)

Before declaring any episode complete, execute the mandatory **6-Way Audit**:

1. **Watch with Full Audio**: Does Nemi feel like a living storyteller? Are voice and physical gestures harmonized?
2. **The Mute Test (Visual Clarity)**: Watch the entire video muted. Does the narrative still make sense visually through acting, props, doodles, and cutaways?
3. **The Audio-Only Test (Vocal Clarity)**: Listen with eyes closed. Is Nemi's vocal delivery clear, engaging, and intelligible? Do SFX punctuate without masking words?
4. **The Subtitle Audit**: Inspect every single card across the entire timeline. Verify that **zero cards exceed 5 words** and that timing matches speech onset.
5. **The Close-Up & Rig Audit**: Inspect punch close-ups. Verify no bone clipping, clean ink lines, and correct pupil direction.
6. **The Headroom & SFX Audit**: Verify all event SFX are $\le 2.0\text{s}$, typing audio is in short bursts only, and audio mix maintains $\ge 1.0\text{ dBFS}$ headroom with zero clipping.

---

## 30. Common Failure Modes

| Failure Mode | Root Cause | Immediate Production Remedy |
|---|---|---|
| **Hyperactivity / Flailing** | Moving Nemi constantly to prevent "boredom" | Enforce $0.8\text{s}\text{--}2.5\text{s}$ holds; restrict movement to narrative punctuation |
| **Visual Stagnation** | Character sits in one pose for 4+ seconds | Add a hand-drawn doodle, micro-acting gesture, or camera snap |
| **Random Three-Dot Ellipsis** | Triggering floating `...` automatically | Ellipsis is strictly opt-in; default deadpan is pure stillness and dash mouth |
| **Typing Sound Bed** | Continuous 30s typing audio under dialogue | Trim typing SFX to $0.5\text{s}\text{--}1.25\text{s}$ event bursts only while visibly typing |
| **Subtitle Paragraphs** | Displaying entire sentences (6–12 words) | Split strictly into $2\text{--}4$ word cards matching spoken syllables |
| **Floating / Orphan Props** | Props spawning in empty air with no follow-through | Ground props on desk/floor, attach to hands, and give them a full lifecycle |
| **Lip-Sync Drift** | Calculating mouth movement from script text | Drive visemes exclusively from aligned speech intervals; snap shut on pauses |
| **Subtitle Timing Drift** | Dividing lines into equal-duration slices | Drive card transitions directly from aligned word timestamps |
| **Camera Nausea** | Continuous procedural camera floating | Lock camera; use camera exclusively as instant or snappy snap-zooms |
| **SFX Clutter / Ear Fatigue** | Triggering sounds on every single movement | Silence is normal; restrict SFX to physical contacts and key punchlines |
| **Doodles Look Like Clip Art** | Using static geometric primitives or SVG icons | Draw progressively along organic curved ink strokes with tapered ends |
| **Audio Clipping / Distortion** | Layering multiple loud SFX over dialogue | Attenuate SFX; enforce $-1.0\text{ dBFS}$ master ceiling; duck under voice |
| **BGM Monotony** | Playing a looping music track through the whole video | BGM is OFF by default; rely on voice, selective SFX, and silence |
| **Automatic Expression FX** | Tying sweat drops to expression state transitions | Decouple FX from expressions; require explicit `nemi.fx(...)` calls |
| **Unexplained Directorial Events** | Inserting zooms or doodles without narrative reason | Ask *"Why now?"*; if no narrative answer exists, delete the event |
| **Constant Visual Density** | Every beat has the identical amount of visual action | Establish clear dynamic arcs: Minimal $\rightarrow$ Rising $\rightarrow$ Peak $\rightarrow$ Empty |

---

## 31. Master Checklist

Before exporting and signing off on any final episode master, every box must be checked:

### Character & Rig
- [ ] Nemi's visual identity, hair, colors, and proportions strictly match locked specifications.
- [ ] Nemi is animated live via the Godot character rig (zero AI image generation for poses).
- [ ] No bone clipping or abnormal rig deformations during extreme poses.

### Acting & Performance
- [ ] Nemi exhibits clear performance rhythms (action $\rightarrow$ settle $\rightarrow$ holding stillness).
- [ ] Poses hold cleanly without procedural jitter, floating drift, or breathing wobble.
- [ ] Micro-acting (eye darts, brow shifts, head tilts) is used selectively.
- [ ] Gestures have clear narrative meaning (zero generic decorative waving).

### Facial Acting & Lip-Sync
- [ ] Facial expressions combine eyes, brows, mouth, and head tilt.
- [ ] Lip-sync visemes accurately reflect speech syllables ($12\text{--}15\text{ FPS}$ illustrative rhythm).
- [ ] Emotion overrides ordinary mouth flapping during shock, deadpan, and laughter.
- [ ] Mouth snaps shut instantly when dialogue pauses.

### Voice & Timing
- [ ] Voiceover audio is the master clock; all timelines derive from actual waveform alignment.
- [ ] Canonical script wording matches spoken audio exactly.
- [ ] Audio is never stretched, compressed, or shifted to fit visual timing.

### Doodles & Storytelling
- [ ] Doodles feel actively drawn onto the scene (progressive stroke reveal).
- [ ] Linework exhibits authored organic variation with zero per-frame random jitter.
- [ ] Doodles are cleared when narrative points conclude (no cluttered whiteboard).

### Props & Cutaways
- [ ] Props follow complete lifecycles (enter $\rightarrow$ interact $\rightarrow$ payoff $\rightarrow$ exit).
- [ ] Props share the pen-and-ink linework of the character.
- [ ] Cutaways and visual metaphors expand the narrative without clashing with the art style.

### Expression FX
- [ ] All FX are explicitly called; zero automatic marks on pauses or scene changes.
- [ ] No automatic three-dot ellipsis; deadpan uses pure stillness and horizontal dash mouth.
- [ ] FX are anchored to character rig bones.

### Camera & Composition
- [ ] Camera is used for punctuation (reveals, punchlines, emotional escalation).
- [ ] No continuous, nauseating camera drift.
- [ ] Rule of thirds respected; Nemi staged to leave open space for doodles/props.
- [ ] Subtitle safety corridor ($y = 600\text{--}720\text{px}$) kept clear of character faces and critical props.

### Subtitles
- [ ] **HARD RULE VERIFIED**: Every card contains $\le 5$ visible words (target $2\text{--}4$ words).
- [ ] Cards synchronize precisely to aligned speech onset.
- [ ] Clean, legible typography with solid outline; no bouncy karaoke word-effects.

### Audio & Sound Design
- [ ] Event SFX durations are within $0.1\text{s}\text{--}2.0\text{s}$ (no $>3.0\text{s}$ sounds in event pool).
- [ ] Typing SFX occurs only in short bursts ($0.5\text{s}\text{--}1.25\text{s}$) while visibly typing.
- [ ] Ambience is separate, subtle ($-18\text{ to } -24\text{ dBFS}$), and ducks on punchlines.
- [ ] BGM is OFF by default; silence is preserved as an active comedic punchline.
- [ ] Audio mix maintains $\ge 1.0\text{ dBFS}$ headroom with zero digital clipping.

### Review Passes
- [ ] Full video watched with audio.
- [ ] Mute test passed (story clearly readable without sound).
- [ ] Audio-only test passed (narration crystal clear and engaging).
- [ ] Subtitle audit passed ($\le 5$ words verified frame-by-frame).
- [ ] 4K native offline render completed without dropped frames or visual artifacts.

---

## 32. Change Log

### Version 1.0
* **Date**: September 2026
* **Author**: Antigravity Studio Engine Team
* **Source Foundation**: Consolidated lessons, architectural specifications, and locked standards from the development of Nemi and Episode 00 (*"Wait, Listen to Me"*).
* **Summary of Changes**:
  - Established the definitive, universal 32-section Animation Production Bible.
  - Formally locked Nemi's visual design, character proportions, and live Godot rig architecture.
  - Codified the Voice Master Clock pipeline and audio-alignment timing architecture.
  - Standardized the illustrative lip-sync model and emotion-override hierarchy.
  - Enforced the hard $\le 5$-word subtitle rule and banned word-by-word karaoke bouncing.
  - Formalized the 3-system separation: Expression FX (`NemiFXDirector.gd`), Props (`NemiPropLibrary.gd`), and Doodles (`NemiDoodleDirector.gd`).
  - Banned automatic ellipsis FX and automated reaction marks; established explicit-only FX triggers.
  - Standardized Event SFX duration bounds ($0.1\text{s}\text{--}2.0\text{s}$) and banned continuous 30-second typing audio beds.
  - Set BGM as OFF by default; elevated intentional silence as a first-class comedic punchline tool.
  - Codified the 18-step episode workflow and the mandatory 6-Way QA Audit.
