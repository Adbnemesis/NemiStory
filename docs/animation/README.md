# STORYTIME ANIMATION PRODUCTION DOCUMENTATION

Welcome to the central documentation hub for the Storytime Animated Storytelling Production Pipeline.

---

## 1. Master Architecture & Shared Animation Language

* **[Storytime Animation Architecture](file:///Users/talus/Documents/adb/docs/animation/STORYTIME_ANIMATION_ARCHITECTURE.md)**: Master architecture establishing the separation between Common Animation Language and Independent Character Systems.
* **[Common Storytime Animation Style](file:///Users/talus/Documents/adb/docs/animation/COMMON_STORYTIME_ANIMATION_STYLE.md)**: Universal visual language, hand-drawn inking, organic imperfection, and comedic stillness.
* **[Common Hand-Drawn Doodle System](file:///Users/talus/Documents/adb/docs/animation/COMMON_HAND_DRAWN_DOODLE_SYSTEM.md)**: Authored doodle standards, imperfect geometry, and progressive stroke reveals.
* **[Common Handwriting System](file:///Users/talus/Documents/adb/docs/animation/COMMON_HANDWRITING_SYSTEM.md)**: Organic hand-lettering standards, irregular baselines, and text-in-illustration rules.
* **[Common Prop System](file:///Users/talus/Documents/adb/docs/animation/COMMON_PROP_SYSTEM.md)**: Illustrated prop philosophy, depth layering, and surface contact standards.
* **[Common Background & Environment System](file:///Users/talus/Documents/adb/docs/animation/COMMON_BACKGROUND_ENVIRONMENT_SYSTEM.md)**: Warm paper textures, depth layers, and room continuity.
* **[Common Camera & Staging](file:///Users/talus/Documents/adb/docs/animation/COMMON_CAMERA_STAGING.md)**: Cinematic shot presets, rule-of-thirds staging, and narrative-driven cuts.
* **[Common Voice-Beat Timing](file:///Users/talus/Documents/adb/docs/animation/COMMON_VOICE_BEAT_TIMING.md)**: Voice master clock, beat taxonomy, and millisecond synchronization.
* **[Common Subtitle System](file:///Users/talus/Documents/adb/docs/animation/COMMON_SUBTITLE_SYSTEM.md)**: Mandatory $\le 5$ words per card rule and visual typography.
* **[Common SFX System](file:///Users/talus/Documents/adb/docs/animation/COMMON_SFX_SYSTEM.md)**: Event audio punctuation, voice dominance, and zero-BGM policy.
* **[Common Storytime Production Pipeline](file:///Users/talus/Documents/adb/docs/animation/COMMON_STORYTIME_PRODUCTION_PIPELINE.md)**: Step-by-step 10-phase production workflow.
* **[Common Animation QA](file:///Users/talus/Documents/adb/docs/animation/COMMON_ANIMATION_QA.md)**: Master four-gate quality verification checklist.

---

## 2. Character Documentation Families

### ADB Character System (`adb/`)
* **[ADB Character Guide](file:///Users/talus/Documents/adb/adb/docs/ADB_CHARACTER_GUIDE.md)**: Core visual identity, silhouette, design breakdown, and aesthetic contrast.
* **[ADB Rig Specification](file:///Users/talus/Documents/adb/adb/docs/ADB_RIG_SPECIFICATION.md)**: Engine-native 2D vector rig hierarchy, separable parts, and transform controls.
* **[ADB Acting Guide](file:///Users/talus/Documents/adb/adb/docs/ADB_ACTING_GUIDE.md)**: Performance personality, calm composure, cool $\leftrightarrow$ cute dynamics, and body acting.
* **[ADB Expression System](file:///Users/talus/Documents/adb/adb/docs/ADB_EXPRESSION_SYSTEM.md)**: Facial expression matrix, micro-events (blinks, eye darts, side-eye).
* **[ADB Lip Sync Guide](file:///Users/talus/Documents/adb/adb/docs/ADB_LIP_SYNC_GUIDE.md)**: Independent mouth rig shapes and voice synchronization.
* **[ADB Pose Library](file:///Users/talus/Documents/adb/adb/docs/ADB_POSE_LIBRARY.md)**: Relaxed, conversational, emotional, and comedic pose catalog.
* **[ADB Hand Gesture Library](file:///Users/talus/Documents/adb/adb/docs/ADB_HAND_GESTURE_LIBRARY.md)**: 12+ hand shapes and prop grip attachments.
* **[ADB Character QA](file:///Users/talus/Documents/adb/adb/docs/ADB_CHARACTER_QA.md)**: Rig and character-specific quality verification.

### Nemi Character System (`nemi/`)
* **[Nemi Production Bible](file:///Users/talus/Documents/adb/docs/animation/NEMI_ANIMATION_PRODUCTION_BIBLE.md)**: Nemi-specific character standards and historical reference.
* **[Nemi Character Bible](file:///Users/talus/Documents/adb/docs/Nemi_Character_Bible.md)**: Nemi character identity, costume specifications, and psychology.
* **[Nemi Acting & Personality Guide](file:///Users/talus/Documents/adb/docs/Nemi_Animation_Personality_Guide.md)**: Nemi-specific emotional states and comedy progressions.
* **[Old ADB Archive Guide](file:///Users/talus/Documents/adb/nemi/characters/old_adb/Old_ADB_Archive_Guide.md)**: Deprecated EP02 archive rig reference.

---

## 3. Audio & SFX Assets

* **[SFX System Guide](file:///Users/talus/Documents/adb/docs/audio/SFX_System_Guide.md)**: Curated audio effects catalog.
* **[SFX License & Provenance Registry](file:///Users/talus/Documents/adb/docs/audio/SFX_License_Registry.md)**: CC0 / Public Domain provenance log.

## Live doodling implementation

See [Live Doodling Workflow](LIVE_DOODLING_WORKFLOW.md) for the shared stroke engine, original lettering, episode integration, preview, and remaining migration scope. Render the proof with `python3 tools/render_live_doodle.py`.

## New scene workflow: character drawing identities

[Character Drawing Production Kit](CHARACTER_DRAWING_PRODUCTION_KIT.md) is the executable entry point for new Nemi/ADB scenes, including separate pens, sixteen external acting recipes, timing fields, validation, export, and model handoff.

## Full scene direction

[Storytime Direction Workflow](STORYTIME_DIRECTION_WORKFLOW.md) is the version-2 entry point for scene variety, grounded face/hand/leg performance, prop contact, finite VFX, voice/SFX, exact event timing, and model handoff.
