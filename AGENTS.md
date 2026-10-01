# Storytime animation work

For new ADB/Nemi animation work, first read `docs/animation/STORYTIME_REFINEMENT_WORKFLOW.md`, then `docs/animation/STORYTIME_DIRECTION_WORKFLOW.md`, then `docs/animation/CHARACTER_DRAWING_PRODUCTION_KIT.md`, then the relevant character acting guide linked there. Start from the saved JSON example and use the validator and renderer. Do not invent API names or build another private doodle player.

- Preserve existing character rigs, character definitions, pose libraries, expression libraries, and hand/lipsync systems. Direct their existing controls from external production code.
- Do not edit existing episodes or overwrite episode renders for this improvement project. Create a separate new scene/spec and render under `renders/`.
- Do not live-draw every scene. Choose held art, prop contact, a scene/environment cut, live revision, or stillness based on the thought. Use version-2 specs for full scenes and version-1 only for the original comparison.
- Every illustration must select `author: nemi` or `author: adb`. Shared playback does not mean shared handwriting or mark geometry.
- Completed ink stays still. Never use per-frame randomness, sliding masks, opacity-only word reveals, or constant bobbing as a substitute for authored drawing/acting.
- Choose a performance recipe by the thought being expressed. Eyes lead, body/head follow, gesture settles, then hold. Do not repeatedly trigger speaking/blink tweens every frame.
- Use existing supported hand shapes, finite VFX lifetimes, and grounded standing cues. Walking/contact choreography needs an authored sequence; never fake it with floating root motion.
- Link simultaneous drawing/VFX/SFX cues to named events. The validator must pass before export; do not bypass missing assets or unknown fields.
- Preserve the exact approved voice identity/settings. Pacing only: use approved source recordings with hashes and pitch-preserving tempo, normally 1.00–1.12 and at most 1.15 for the new recording preparer. Never change speaker/model/identity prompt/pitch/formants/EQ or reuse stale word times after audio changes. Do not automatically cut emotional pauses.
- Save a direction brief (promise/want/choice/consequence/payoff) and thought beats with one audience focus each. Use readable framing and a meaningful ending, not a fixed cut rate or effects quota.
- Pickup/release needs authored hand paths and a continuous grip/resting contact. Stepped acting is optional; completed ink remains still.
- Voice timing, mouth intervals, captions, acting, and drawings use seconds on one scene clock. Audio does not automatically produce phonemes. Author and check mouth intervals against the actual recording.
- Validate the spec, run relevant engine checks, render a fresh ten-second proof, inspect stills AND playback, and record what was verified. A render existing on disk is not evidence that it looks good.
- Existing episode adapters from the earlier shared-ink pass remain historical work; do not migrate more episodes or attempt to reconstruct missing originals without a separate user request.

The refinement and version-2 direction workflows are the authoritative executable workflow for new storytime scenes. Older style documents remain artistic context. If extending a mark, letter, recipe, or field, update the profile/schema documentation and example in the same change.

The user authorized pushing current and previously unpushed project source to GitHub, excluding large files. Preserve local generated media; use normal pushes, never force-push. Review staged file sizes and secrets before pushing.
