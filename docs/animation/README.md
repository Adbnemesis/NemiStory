# Storytime animation documentation

**Creating an episode in Codex or Antigravity? Start with [Episode Start](EPISODE_START.md).** Separate Nemi/ADB skills load the required documentation and the shared tools check current preparation before export.

**Start with [Current Storytime Refinement Workflow](STORYTIME_REFINEMENT_WORKFLOW.md)**, then [Version-2 field reference](STORYTIME_DIRECTION_WORKFLOW.md) and [Character drawing identities](CHARACTER_DRAWING_PRODUCTION_KIT.md). New scenes use the [complete ten-second example](../../common/storytime/examples/refinement_10s/scene.json).

These are the current operational instructions. The older documents below supply artistic context; their fixed percentages, procedural idle motion and approximate timing are superseded for new productions. Voice identity, rigs and existing episodes are protected.

Welcome to the central documentation hub for the Storytime Animated Storytelling Production Pipeline.

---

## 1. Master Architecture & Shared Animation Language

* **[Storytime Animation Architecture](STORYTIME_ANIMATION_ARCHITECTURE.md)**: Master architecture establishing the separation between Common Animation Language and Independent Character Systems.
* **[Common Storytime Animation Style](COMMON_STORYTIME_ANIMATION_STYLE.md)**: Universal visual language, hand-drawn inking, organic imperfection, and comedic stillness.
* **[Common Hand-Drawn Doodle System](COMMON_HAND_DRAWN_DOODLE_SYSTEM.md)**: Authored doodle standards, imperfect geometry, and progressive stroke reveals.
* **[Common Handwriting System](COMMON_HANDWRITING_SYSTEM.md)**: Organic hand-lettering standards, irregular baselines, and text-in-illustration rules.
* **[Common Prop System](COMMON_PROP_SYSTEM.md)**: Illustrated prop philosophy, depth layering, and surface contact standards.
* **[Common Background & Environment System](COMMON_BACKGROUND_ENVIRONMENT_SYSTEM.md)**: Warm paper textures, depth layers, and room continuity.
* **[Common Camera & Staging](COMMON_CAMERA_STAGING.md)**: Cinematic shot presets, rule-of-thirds staging, and narrative-driven cuts.
* **[Common Voice-Beat Timing](COMMON_VOICE_BEAT_TIMING.md)**: Voice master clock, beat taxonomy, and millisecond synchronization.
* **[Common Subtitle System](COMMON_SUBTITLE_SYSTEM.md)**: Mandatory $\le 5$ words per card rule and visual typography.
* **[Common SFX System](COMMON_SFX_SYSTEM.md)**: Event audio punctuation, voice dominance, and zero-BGM policy.
* **[Common Storytime Production Pipeline](COMMON_STORYTIME_PRODUCTION_PIPELINE.md)**: Step-by-step 10-phase production workflow.
* **[Common Animation QA](COMMON_ANIMATION_QA.md)**: Master four-gate quality verification checklist.

---

## 2. Character Documentation Families

### ADB Character System (`adb/`)
* **[ADB Character Guide](../../adb/docs/ADB_CHARACTER_GUIDE.md)**: Core visual identity, silhouette, design breakdown, and aesthetic contrast.
* **[ADB Rig Specification](../../adb/docs/ADB_RIG_SPECIFICATION.md)**: Engine-native 2D vector rig hierarchy, separable parts, and transform controls.
* **[ADB Acting Guide](../../adb/docs/ADB_ACTING_GUIDE.md)**: Performance personality, calm composure, cool $\leftrightarrow$ cute dynamics, and body acting.
* **[ADB Expression System](../../adb/docs/ADB_EXPRESSION_SYSTEM.md)**: Facial expression matrix, micro-events (blinks, eye darts, side-eye).
* **[ADB Lip Sync Guide](../../adb/docs/ADB_LIP_SYNC_GUIDE.md)**: Independent mouth rig shapes and voice synchronization.
* **[ADB Pose Library](../../adb/docs/ADB_POSE_LIBRARY.md)**: Relaxed, conversational, emotional, and comedic pose catalog.
* **[ADB Hand Gesture Library](../../adb/docs/ADB_HAND_GESTURE_LIBRARY.md)**: 12+ hand shapes and prop grip attachments.
* **[ADB Character QA](../../adb/docs/ADB_CHARACTER_QA.md)**: Rig and character-specific quality verification.

### Nemi Character System (`nemi/`)
* **[Nemi Production Bible](NEMI_ANIMATION_PRODUCTION_BIBLE.md)**: Nemi-specific character standards and historical reference.
* **[Nemi Character Bible](../Nemi_Character_Bible.md)**: Nemi character identity, costume specifications, and psychology.
* **[Nemi Acting & Personality Guide](../Nemi_Animation_Personality_Guide.md)**: Nemi-specific emotional states and comedy progressions.
* **[Old ADB Archive Guide](../../nemi/characters/old_adb/Old_ADB_Archive_Guide.md)**: Deprecated EP02 archive rig reference.

---

## 3. Audio & SFX Assets

* **[SFX System Guide](../audio/SFX_System_Guide.md)**: Curated audio effects catalog.
* **[SFX License & Provenance Registry](../audio/SFX_License_Registry.md)**: CC0 / Public Domain provenance log.

## Live doodling implementation

See [Live Doodling Workflow](LIVE_DOODLING_WORKFLOW.md) for the shared stroke engine, original lettering, episode integration, preview, and remaining migration scope. Render the proof with `python3 tools/render_live_doodle.py`.

## New scene workflow: character drawing identities

[Character Drawing Production Kit](CHARACTER_DRAWING_PRODUCTION_KIT.md) documents the separate pen identities and the original version-1 comparison, including sixteen initial external acting recipes, timing fields, validation, export, and model handoff.

## Full scene direction

[Storytime Direction Workflow](STORYTIME_DIRECTION_WORKFLOW.md) is the version-2 entry point for scene variety, grounded face/hand/leg performance, prop contact, finite VFX, voice/SFX, exact event timing, and model handoff.
