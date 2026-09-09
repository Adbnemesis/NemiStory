# NEMI — INTRODUCTION VIDEO REQUIREMENTS (V1)
## Structural Architecture, Narrative Milestones, Hook Candidates, and Production Constraints
### DO NOT WRITE THE FINAL SCRIPT YET — THIS DOCUMENT DEFINES REQUIREMENTS ONLY

---

## 1. Project Scope & Mandate

This document formally specifies the narrative and production requirements for Nemi’s eventual **1:30 – 2:00 (90 to 120 seconds)** debut introduction video on YouTube.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           STRICT BOUNDARY NOTICE                            │
│                                                                             │
│  • DO NOT create the final introduction script in this phase.               │
│  • DO NOT create storyboards, animatics, or final video renders.            │
│  • DO NOT create new character art or redesign the Godot rig.              │
│                                                                             │
│  This document defines WHAT the introduction must achieve, HOW it must be   │
│  structured, and the CONSTRAINTS it must obey.                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Core Objectives of the Debut Video

The introduction video must accomplish eight distinct narrative milestones within 90–120 seconds:

1. **Establish Identity Naturally**: Name (`Nemi`) and Age (`24`) introduced conversationally, without reading a bulleted biography.
2. **Declare the Core Mission**: Establish that this is her **first serious, committed attempt** at telling personal stories through 2D animation on YouTube.
3. **Frame the Channel as a Journey, Not a Masterclass**: She is learning the craft, making mistakes, and inviting the audience along for the ride.
4. **Demonstrate Personality Through Action**: Her observational wit, self-doubt, creative overthinking, and deadpan honesty must be *shown* through storytelling, never announced in exposition.
5. **Integrate Hobbies as Narrative Engines**: Weave singing, anime/manga, and the gym naturally into the narrative as sources of hilarious situations, rather than reciting a list.
6. **Showcase the Vector Animation Engine**: Seamlessly utilize the Godot acting system (snappy pose holds, punch-zooms, doodle annotations, deadpan pauses, and monochrome/color synergy).
7. **Strict Rule 7 Adherence**: Zero verbal self-reference as "a girl", "a woman", or third-person pronouns for herself.
8. **Provide an Understated Reason to Return**: Conclude with a warm, self-aware invitation to stick around, avoiding generic YouTuber begging.

---

## 3. Pacing & Time Budget (90s – 120s Breakdown)

Based on the quantitative metrics extracted from the reference videos (`REFERENCE_VIDEOS_ANALYSIS.md`), the 1:30–2:00 video must allocate time across eight rhythmic beats:

```
0:00        0:06           0:20           0:40           1:00           1:25           1:45      2:00
 │           │              │              │              │              │              │         │
 ├───────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼─────────┤
   BEAT 1       BEAT 2         BEAT 3         BEAT 4         BEAT 5         BEAT 6         BEAT 7    BEAT 8
   HOOK         IDENTITY &     ANIMATION      HOBBIES AS     COMEDIC        CHANNEL        WARM      STINGER
   (0-6s)       MISSION        STRUGGLE       SITUATIONS     ESCALATION     VISION         OUTRO     (1:52-2:00)
                (6-20s)        (20-40s)       (40-60s)       (1:00-1:25)    (1:25-1:45)    (1:45-1:52)
```

| Beat | Timestamp | Duration | Narrative Purpose & Requirements |
| :--- | :--- | :--- | :--- |
| **Beat 1: The Hook** | `0:00 – 0:06` | ~6s | Immediate scroll-stopping disruption. Starts mid-predicament or with conversational urgency. No generic greeting. |
| **Beat 2: Identity & Premise** | `0:06 – 0:20` | ~14s | Names herself (Nemi), age (24), and states the premise: starting an animated storytime channel. |
| **Beat 3: The Animation Struggle** | `0:20 – 0:40` | ~20s | The reality of digital drawing vs. imagination. Frame rates, hand anatomy, or tablet software crashes. |
| **Beat 4: Hobbies as Story Fuel** | `0:40 – 1:00` | ~20s | Anime deep-dives, gym ambitions, or car singing woven into the narrative as relatable domestic chaos. |
| **Beat 5: Comedic Escalation** | `1:00 – 1:25` | ~25s | A compounding blunder (e.g., spending 6 hours on a single 1-second doodle or an awkward public miscalculation). |
| **Beat 6: What to Expect** | `1:25 – 1:45` | ~20s | Setting expectations: stories about awkward encounters, creative obsessions, and little moments of life. |
| **Beat 7: Understated Outro** | `1:45 – 1:52` | ~7s | Warm, direct address to the individual viewer. An invitation to stay without desperation. |
| **Beat 8: Post-Credit Stinger** | `1:52 – 2:00` | ~8s | A 5-frame stepped panic loop, sudden realization, or self-aware visual gag as the video ends. |

---

## 4. Candidate Hook Directions (For Future Scripting)

When the scriptwriting phase begins, the writer should choose from one of these four curated hook architectures:

### Candidate Hook A: The Artistic Evidence Hook (Recommended)
* **Mechanic**: Immediately points to a distorted drawing on screen and demands the viewer's attention.
* **Conceptual Direction**:
  > *"Wait—do not scroll yet. Look at this drawing right here. I have been staring at this single frame for four hours, and I need an objective human opinion on whether this looks like an elbow or a baked yam."*
* **Why It Fits Nemi**: Drops the viewer straight into her creative dilemma, shows her art immediately, and sets a self-deprecating tone within 4 seconds.

### Candidate Hook B: The Relatable Confession Hook
* **Mechanic**: Opens mid-conversation with a universal behavioral check.
* **Conceptual Direction**:
  > *"Please tell me I'm not the only person who will spend three weeks researching the optimal way to learn animation, and exactly fourteen seconds actually opening the software."*
* **Why It Fits Nemi**: Validates the viewer's own procrastination and invites immediate conspiratorial empathy.

### Candidate Hook C: The Physical Reality Hook
* **Mechanic**: Opens on an awkward physical posture or gym aftermath.
* **Conceptual Direction**:
  > *"I walked into the gym today with the confidence of an anime hero in a tournament arc. I am currently sitting here unable to lift my drawing stylus."*
* **Why It Fits Nemi**: Introduces her fitness interest immediately through a humorous collision with physical reality.

### Candidate Hook D: The Direct Interruption Hook
* **Mechanic**: High urgency, conversational disruption inspired by Reference Video 2.
* **Conceptual Direction**:
  > *"Wait, wait, wait—stop scrolling for a second. Okay. Breathe. Apparently, I am making YouTube videos now. Nobody warned me how much drawing that actually involves."*
* **Why It Fits Nemi**: Brisk, self-aware, and immediately addresses the platform context.

---

## 5. Visual Storytelling Opportunities Checklist

The eventual introduction script must be written to actively trigger the following Godot visual systems:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       VISUAL STORYTELLING ASSET CHECKLIST                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  [ ] 0-Frame Pose Cuts: Instant snaps on vocal inflections (avg every 2s)   │
│  [ ] Dynamic Punch-Zoom: 1.3x - 1.5x snap zoom on a confessional beat       │
│  [ ] On-Screen Hand-Drawn Doodles: Floating tags (`*YAPPING*`, `*PANIC*`)   │
│  [ ] Mood Background Swaps: Pale wash -> Crimson panic -> Slate dread       │
│  [ ] Monochrome / Color Contrast: Starting or ending in ink mode            │
│  [ ] Deadpan Freeze: 1.5s hold with procedural eye blinks only              │
│  [ ] Stepped Comedic Cycle: 3-frame panic loop held on 3s for the stinger   │
│  [ ] Graphic Subtitles: Centered lower-third text with selective bolding    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Candidate Outro & Sign-Off Directions

The ending must feel like a natural conversation concluding, avoiding broadcast television or desperate influencer clichés:

### Candidate Outro 1: The Creative Exit
> *"Anyway, my drawing tablet is radiating the heat of a small sun, and I should probably stretch before my spine permanently fuses into a shrimp. If you like stories about someone trying their best to make weird art... I’d love it if you stayed. I’ll see you soon. Bye!"*

### Candidate Outro 2: The Posture Check & Promise
> *"I don't really know where this channel is going yet, but I really want to make something fun here and hopefully meet some cool people along the way. Straighten your posture right now. See you in the next one."*

### Candidate Outro 3: The Self-Aware Post-Credit Panic
> *[Formal video closes gracefully]*  
> *[Cut to black for 0.4s]*  
> *[Stinger: Nemi stepped panic run cycle across screen]*  
> *"Wait, did I leave the microphone on the entire time I was singing that anime opening?! NO NO NO—"*

---

## 7. Next Phase Handoff Criteria

This specification is complete. The next phase will be:
> **WRITE THE FINAL 1:30–2:00 NEMI INTRODUCTION SCRIPT**  
> adhering strictly to `Nemi_Character_Bible.md`, `Nemi_Dialogue_Guide.md`, `Nemi_Script_Style_Guide.md`, and these introduction requirements.
