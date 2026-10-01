---
trigger: always_on
description: Route new Nemi and ADB storytime episode requests through character-specific reading and preparation before authoring.
---

For new storytime episode creation, scripting, animation or continuation, load `.agents/skills/nemi-storytime/SKILL.md` for Nemi or `.agents/skills/adb-storytime/SKILL.md` for ADB. For a crossover load both. Apply to ordinary language, not only slash commands.

Follow `docs/animation/EPISODE_START.md`. Complete current shared/character reading and episode-specific notes with `tools/storytime/preflight.py` before authoring. On resume check for stale requirements. Normal validation/export enforces preparation. Do not bypass the gate or fabricate reading notes. Preserve rigs, voice identity and existing episodes. Tool maintenance and documentation-only requests do not require a new episode record.
