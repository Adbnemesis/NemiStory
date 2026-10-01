---
name: nemi-storytime
description: Create, script, animate or continue a new NEMI storytime episode in this repository, loading shared and character-specific production documents before authoring. Excludes unrelated code maintenance and historical-episode migrations.
---

# NEMI storytime episode start

Work from the repository root containing `tools/storytime/preflight.py`. Read `docs/animation/EPISODE_START.md` for the shared procedure. Nemi uses the warmer, expressive personality and rounded/looser story pen. Read her character bible, acting and dialogue guides selected by the manifest; canonical voice is Sohee.

1. Resolve the requested story and narrator from the user's brief. Use a separate new folder; preserve the existing episodes, rigs, poses, expression/hand/mouth libraries and canonical voice settings.
2. Start with `python3 tools/storytime/new_scene.py --author nemi --name <new_name>`. This makes only a silent placeholder and pending reading record. For an existing new production, use its `preflight.json`; do not overwrite it. If the new folder has no record, initialize it with `python3 tools/storytime/preflight.py init --folder <folder> --authors nemi`.
3. Run `python3 tools/storytime/preflight.py status --folder <folder>`. Read each listed document in order through `read --folder <folder> --document <path> --part <number>`. Read **all** displayed parts into context. Then `ack --folder <folder> --document <path> --note '<how this document changes this episode>'`. Use specific notes, not automated boilerplate or invented evidence of reading. These subcommands all belong to `python3 tools/storytime/preflight.py`.
4. For a guest character, extend with `--authors nemi adb` and read the other skill/added documents. If required features change, extend the feature set. On resume, inspect current notes and `status`; reread changed material or material absent from the current context. Read the actual docs, not filenames or only their headings.
5. Once ready, write the story brief and beat sheet; then author with the shared version-2 stage. Preserve voice identity, choose pace by the phrase, measure final word times, use purposeful held/live drawings and readable framing, and author continuous contacts through existing controls. The current workflows supersede historical percentages, procedural idle motion, old APIs and voice audition alternatives.
6. Validate through `validate_scene.py`, render through `render_scene.py`, review a focused proof and a 30–60 second integrated sequence when scope requires it, and record actual visual/audio QA. Keep unperformed checks explicit. Save/push source and small artifacts within the user's authorization; large media remains local.

Do not bypass preparation by using version 1, direct Godot export, low-level schema validation, forged receipts, or changes to the historical-spec exemption list. Preparation is not artistic approval and does not expand authorization to old episodes or rig changes. Use the common manifest as the document list; do not maintain a second stale copy here.
