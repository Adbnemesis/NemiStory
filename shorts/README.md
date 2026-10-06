# ADB + Nemi · Godot ink Shorts

The current format is a 12–25 second music edit built around **whole-body pose cards, subtle ongoing acting, directed camera motion and music-led transitions**. Author-specific ink contours, gray washes/hatching, a readable situation and a cute visual payoff carry the clip. Godot draws every visual frame. No fully static interval may exceed 1.5 seconds.

[Latest motion review](review/motion04/index.html) · [Beat direction](review/motion04/BEAT_DIRECTION.md) · [Three skills](review/motion04/SKILLS.md) · [Workflow](godot/V3_WORKFLOW.md) · [Schema](godot/V3_SCHEMA.md)

Motion04 continues all eight edits with slight coherent eye/head/grounded torso movement inside each pose, purposeful camera push/pull/pan through the thought and small impacts on selected real source attacks. The approved music recording, sourceStart and gain remain; redundant closing poses are trimmed to each visual/music phrase. Current durations vary from13.5–17.567s. Revision03 is a preserved interim pose pass, with its full-batch playback still unapproved. Native pose/transition proofs and a completed exported-movie review are different stages: the latest review records must show decoded picture/audio/pacing checks and whole-clip playback before a revision is selected. Source validation or a render existing on disk does not establish creative acceptance or audience retention.

Use `$adb-ink-shorts`, `$nemi-ink-shorts` or `$duo-ink-shorts`. Start with the cast helper `new <short-name>`; it creates an editable matched template in the correct folder. Write the thought beats first, select actual whole-body `bodyPose` drawings, vary framing when attention changes, keep a small thought-specific motion path developing inside each pose, and direct a finite camera move plus selected accent response. Time both major pose arrivals and smaller camera accents against actual source evidence. Adapt the template into a distinct edit before rendering. [Follow the actionable production steps](godot/V3_WORKFLOW.md).

## Where everything lives

```text
shorts/
  adb/<short-name>/       # likewise nemi/ and duo/
    short.json           # current poses, shots, timing and sound
    Edit.tscn            # active editable Godot scene
    DIRECTION.md
    CUE_MAP.json
    render/              # immutable revision movies
    review/              # QA, stills, logs and render index
      source-r1/         # original r1 source snapshots for these recuts
      r1/                # preserved r1 review evidence
      source-motion03/   # preserved interim pose-pass source
    assets/              # optional assets unique to this Short
  godot/                 # shared editable art, engine and tools
  assets/music/          # shared recordings and provenance
  review/motion04/       # current batch gallery and motion evidence
```

Edit the source at the Short root. The archived r1 files preserve provenance; they are not the active editing entry. Keep `render/` for videos and `review/` for evidence. New productions belong in the cast folders, rather than shared `godot/` or gallery `review/`.

Read the relevant actual-reference motion notes before authoring: [ref01](review/motion04/ref01/MOTION.md) for whole-body/recoil/camera contrast and [ref03](review/motion04/ref03/MOTION.md) for large/small reactions and continuous held-camera joins. Inspect their linked original frames/playback; the tiny acting added in Motion04 is an adaptation, not an unsupported claim that every reference drawing moves internally. Stable completed ink means coherent lines in world space; a directed camera is allowed to move the entire drawing.

The shared ink drawings are `godot/DynamicPoseArt.gd` and `DynamicAccentArt.gd`; `DynamicEdit.gd` directs their finite pose arrivals. These are separate manually authored Godot illustrations. Original storytime episodes, character definitions, rigs, pose/hand/face libraries, voice recordings and project settings remain protected outside Shorts. This route is separate from narrated storytime preparation.

The music recordings are the exact official public previews cataloged in [music provenance](assets/music/batch01/MUSIC_SOURCES.md). Keep original/decoded hashes, recording version, source URLs, preview-relative selected ranges and gains. SFX uses exact existing recorded clips. Numerical music/SFX reconstruction, exported attack timing and listening review are required; no current trend rank is inferred from a famous track.

## Start and review

From the project root:

```sh
.venv/bin/python .agents/skills/nemi-ink-shorts/scripts/build_short.py new new-music-moment
```

Adapt its brief and editable source, then run that same helper’s `validate`, `stills`, `build` and `check` commands as shown in [the workflow](godot/V3_WORKFLOW.md#render-and-verify). Use an unused revision name. Inspect native settled poses and transition start/mid/end before building; watch the whole exported clip at real speed with sound before completing QA.

Serve the gallery with `.venv/bin/python shorts/tools/review_server.py`, then open `http://127.0.0.1:8768/shorts/review/motion04/index.html`. Refresh it from checked selections with `build_upgrade_review.py --output motion04`. Source and small QA records can be committed; movies, downloaded music, generated stills and caches stay local.

The [revision03 interim review](review/revision03/index.html) retains the preceding pose-source/proof work; do not infer full approval from its movies existing. The previous [upgrade02 review](review/upgrade02/index.html), accepted [batch01](review/batch01/index.html) and [original ink proof](review/rebuild/index.html) remain history. Current r1 movies/source/evidence are retained beside each recut until the replacement completes QA. Earlier directory relocation checks are in [the migration record](review/upgrade02/directory-migration.json). The rejected Leg Day and Nemi prototypes and obsolete Remotion pipeline were removed under the user’s earlier cleanup request; [the cleanup manifest](review/upgrade02/legacy-cleanup.json) preserves the exact targets. Supplied references and [their analysis](REFERENCE_ANALYSIS.md) remain available.
