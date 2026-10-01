# Storytime Animation Architecture
## Unified Project Structure, Common Animation Language, and Character Separation

**Document Status**: AUTHORITATIVE MASTER ARCHITECTURE SPECIFICATION  
**Applies To**: Global Project Architecture, All Production Channels (Nemi, ADB, and Future Productions)  
**Location**: `docs/animation/STORYTIME_ANIMATION_ARCHITECTURE.md`

---

## 1. Foundational Architecture Principle

```
┌──────────────────────────────────────────────────────────────────────────┐
│                   STORYTIME ANIMATION ARCHITECTURE                       │
│                                                                          │
│         "SHARE THE LANGUAGE — DO NOT SHARE THE CHARACTER IMPLEMENTATION" │
└──────────────────────────────────────────────────────────────────────────┘
```

The core architectural standard of this repository separates:
1. **The Common Storytime Animation Language**: Reusable storytelling principles, hand-drawn illustration visual language, authored doodle standards, organic handwriting rules, prop standards, camera staging, voice-beat master timing, subtitle rules, SFX philosophy, production pipeline, and QA criteria.
2. **Character-Specific Implementations**: Independent designs, rigs, facial systems, acting styles, lip-sync logic, pose libraries, hand gestures, and episode assets owned exclusively by each character.

### What is COMMON vs. What is CHARACTER-SPECIFIC

| Domain | Scope | Location | Ownership |
|---|---|---|---|
| **Common Animation Language** | Universal storytime visual language, authored doodles, handwriting rules, prop philosophy, illustrated backgrounds, camera staging, voice-driven beat timing, subtitle constraints ($\le 5$ words), SFX standards, QA | `docs/animation/COMMON_*.md`, `common/` | Shared by all characters |
| **Nemi Character System** | Nemi visual design, ginger bun, oversized olive hoodie, Skeleton2D live vector rig, Nemi facial states, Nemi poses, Nemi lip-sync, Nemi voice profile | `nemi/characters/nemi/`, `docs/nemi/`, `nemi/docs/` | Exclusively Nemi |
| **ADB Character System** | ADB visual design, stylish layered slate hair, relaxed knit cardigan & dark trousers, independent live vector rig, ADB facial states, ADB poses, ADB lip-sync, ADB personality | `adb/`, `adb/docs/` | Exclusively ADB |
| **Old ADB (Archive Only)** | Deprecated EP02 prototype rig and documentation preserved exclusively for Nemi Episode 02 backward compatibility | `nemi/characters/old_adb/` | Archived Legacy Only |

---

## 2. Directory Hierarchy & Separation of Concerns

```
adb/ (Repository Root)
├── common/                              <-- Shared engine utilities & common audio
│   ├── audio/sfx/                       <-- Curated, categorized CC0 SFX catalog
│   └── engine/                          <-- Base classes (StoryCamera, StoryProp, HandDrawnMath)
│
├── docs/
│   ├── animation/                       <-- COMMON STORYTIME ANIMATION STANDARDS
│   │   ├── STORYTIME_ANIMATION_ARCHITECTURE.md       [THIS DOCUMENT]
│   │   ├── COMMON_STORYTIME_ANIMATION_STYLE.md       [Shared visual language]
│   │   ├── COMMON_HAND_DRAWN_DOODLE_SYSTEM.md        [Authored doodle rules]
│   │   ├── COMMON_HANDWRITING_SYSTEM.md              [Organic lettering rules]
│   │   ├── COMMON_PROP_SYSTEM.md                     [Illustrated prop standards]
│   │   ├── COMMON_BACKGROUND_ENVIRONMENT_SYSTEM.md  [Warm paper & staging]
│   │   ├── COMMON_CAMERA_STAGING.md                  [Cinematic framing & cuts]
│   │   ├── COMMON_VOICE_BEAT_TIMING.md               [Master clock & beat taxonomy]
│   │   ├── COMMON_SUBTITLE_SYSTEM.md                 [<= 5 words rule]
│   │   ├── COMMON_SFX_SYSTEM.md                      [Event SFX & silence policy]
│   │   ├── COMMON_STORYTIME_PRODUCTION_PIPELINE.md   [Step-by-step workflow]
│   │   └── COMMON_ANIMATION_QA.md                    [Master quality audit]
│   │
│   ├── nemi/                            <-- Nemi-specific voice, profile, TTS docs
│   └── audio/                           <-- SFX registry and provenance
│
├── nemi/                                <-- NEMI INDEPENDENT PRODUCTION ROOT
│   ├── characters/
│   │   ├── nemi/                        <-- Master Nemi live rig (Skeleton2D, parts)
│   │   ├── old_adb/                     <-- ARCHIVED OLD ADB (Historical EP02 only)
│   │   ├── neeko/                       <-- Supporting character
│   │   └── mom/                         <-- Supporting character
│   ├── world/                           <-- Nemi scene coordinators, props, doodles
│   ├── episodes/                        <-- Nemi episodes (EP00, EP01, EP02, EP03, EP04, EP05, EP06)
│   └── docs/                            <-- Nemi production notes & character guides
│
└── adb/                                 <-- ADB INDEPENDENT PRODUCTION ROOT
    ├── characters/
    │   └── adb/                         <-- Master ADB live vector rig & parts
    ├── rig/                             <-- ADB rig controllers & node hierarchies
    ├── animation/                       <-- ADB acting director & animator classes
    ├── expressions/                     <-- ADB facial expressions & micro-events
    ├── acting/                          <-- ADB personality & performance controllers
    ├── lipsync/                         <-- ADB mouth rig & phoneme mapping
    ├── poses/                           <-- ADB pose definitions & state transitions
    ├── hands/                           <-- ADB hand gesture visual library
    ├── props/                           <-- ADB episode-specific illustrated props
    ├── doodles/                         <-- ADB episode-specific doodle assets
    ├── handwriting/                     <-- ADB episode-specific handwritten callouts
    ├── backgrounds/                     <-- ADB illustrated environments
    ├── episodes/                        <-- ADB standalone episodes (future productions)
    ├── audio/                           <-- ADB voice recordings & character audio
    ├── timing/                          <-- ADB voice alignment & beat timing manifests
    ├── test/                            <-- ADB rig verification, physics & performance tests
    └── docs/                            <-- ADB OFFICIAL CHARACTER DOCUMENTATION
        ├── ADB_CHARACTER_GUIDE.md       [Core identity & aesthetic]
        ├── ADB_RIG_SPECIFICATION.md     [Engine rig architecture & parts]
        ├── ADB_ACTING_GUIDE.md          [Acting philosophy & dynamics]
        ├── ADB_EXPRESSION_SYSTEM.md     [Facial states & micro-events]
        ├── ADB_LIP_SYNC_GUIDE.md        [Phoneme shapes & voice sync]
        ├── ADB_POSE_LIBRARY.md          [Poses: relaxed, conversational, comedic]
        ├── ADB_HAND_GESTURE_LIBRARY.md  [Hand library & prop grips]
        └── ADB_CHARACTER_QA.md          [Character-specific QA standards]
```

---

## 3. Strict Independence & Decoupling Guarantees

1. **Zero Technical Coupling**:
   - `adb/` does NOT depend on `nemi/`. An ADB episode scene can be opened, edited, run, and rendered without loading Nemi's character, scenes, or scripts.
   - `nemi/` does NOT depend on the new `adb/`. Existing Nemi episodes continue to render cleanly.
2. **Preservation of Legacy Assets**:
   - Historical Nemi Episode 02 uses `nemi/characters/old_adb/OldADB.tscn`. It remains functional, frozen in archive mode.
   - The new ADB character is built from zero in `adb/` and is NOT a modification of the old prototype.
3. **No Character Merging or Cloning**:
   - Do NOT recolor Nemi.
   - Do NOT copy Nemi's proportions or node layout onto ADB.
   - ADB has an independent silhouette, personality, acting dynamics, and technical rig.
4. **Resolution & Render Target**:
   - All development previews, tests, and production outputs run at **1920×1080 @ 30 FPS**.
   - No 4K rendering during development.

---

## 4. The Common Storytime Universe

While characters maintain 100% technical and visual independence, they belong to the same overarching storytime universe:
- Authored hand-drawn organic feeling.
- Master charcoal contour ink (`#2b2623`).
- Intentional imperfection over clinical vector geometry.
- Voice-first storytelling where character acting punctuates narration.
- Restrained, punchy subtitle pacing ($\le 5$ words).
- Selective sound effects with comedic holds and silence.

## New production boundary

The [Character Drawing Production Kit](CHARACTER_DRAWING_PRODUCTION_KIT.md) separates shared playback from character-authored ink profiles and external acting recipes. New specs coordinate acting, illustration, caption and optional mouth/audio tracks on one clock; no existing episodes load these new defaults.
