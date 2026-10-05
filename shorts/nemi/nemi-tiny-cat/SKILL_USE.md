# Forward test: nemi-ink-shorts

**Invoked skill:** `.agents/skills/nemi-ink-shorts/SKILL.md` (source hash and reading record in `review/skill-authoring.json`).

**Fresh request:** “Nemi says just one tiny doodle, turns a moon into a sleepy cat, and ends with a delighted cute hand gesture. Music-led 12–25s, dynamic poses and intentional doodle/VFX, no still >1.5s.”

The skill’s current rules, V3 workflow/schema, character direction, closest upgraded QuickDoodle source/direction, documented music provenance and helper help were read before authoring. Direction was saved before the spec. This is a new solo Nemi production; it is not a retrospective label on the five upgraded edits.

**Source decisions:** 14.5 seconds;16 authored thought/image changes;88 visible motion keys;14 finite or stable drawing events. The later Cheri Cheri Lady preview section begins12.7826s and ends27.2826s at original speed/pitch. Lavender dream-page marks and a matched moon-to-cat wipe provide a different visual device from QuickDoodle’s green page constellation/book-show cat. The final hand gesture is an actual finger-heart silhouette. Full-body, pen detail, profile and hand/face framing are authored.

**Actual helper check performed:**

```sh
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py validate shorts/nemi/nemi-tiny-cat/short.json
```

Result: `Validated Just one tiny moon cat: 16 shots / 435 frames, source audio hashes and event-linked drawings`. Author scope and version3 passed. The longest planned shot interval is1.067s; that is source timing, not decoded-video stillness proof.

**Ambiguities resolved from maintained docs:** The engine supports separate `moon` and `cat` drawings, but no arbitrary continuous path morph. Their change is therefore a deliberate pencil-wipe/match cut, honestly documented. Cat’s curved closed eyes provide the sleepy expression. The actual attached sketchbook contains its authored generic doodle; the new moon/cat narrative is explicitly the larger dream-page beside Nemi, rather than falsely claiming the fixed prop drawing itself transforms. Back art uses `rest` and never implies a rear pencil interaction. Root recorded whoosh provenance is retained exactly.

**Pending evidence:** Root will run the skill’s `stills` and `build` actions with fresh revisions, inspect hand/pencil/sleeve contact, review the exported section with sound, and record exact-source audio and decoded-static checks. The upgraded example source was read; its actual exported movie still needs a phone-size playback inspection before this forward test is complete. No actual section audition, exported still, rendered movie, audibility, pixel pacing or creative playback approval has been claimed here. The wrapper’s future technical-pass record does not replace those observations.

**Skill/helper failures:** No helper failure occurred in authoring/validation. Full build and playback remain untested at this handoff; their results belong in this document and `review/QA.md` after they occur. Preserve earlier revisions and source audio; keep every artifact under this production or shared `shorts/` assets. Existing storytime rigs, episodes and source are untouched.


## Final exported evidence

Root completed the actual skill helper still/build path for revisionr1. Strict validation, native Godot capture, encoded frame/cut checks, source music/SFX reconstruction and decoded pacing all passed. Godot proof and encoded contact sheets were inspected; details in [review/QA.md](review/QA.md), with native playback observations in review/playback.json. This supersedes the earlier source-stage pending status without pretending validation alone proved the finished picture.
