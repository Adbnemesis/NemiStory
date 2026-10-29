# The Perfect Setup — 48-second integrated review

This replaces the ten-second clip as the broad review example. The short clip remains a focused mechanism test. No old episode or rig has been edited.

A tiny drawing becomes a preparation project. Nemi builds a perfect workspace; ADB comments on the unnecessary planning. Coffee gets made, a mug gets picked up and returned, and a circle finally becomes an employable potato.

| Time | What to inspect |
|---|---|
| 0–4.5 | Full Nemi silhouette, visible planted feet, held notebook, rounded handwriting, conversational face |
| 4.5–11.6 | Workstation background, desk/laptop/mug placement, explaining-to-doubt pose change, caption timing |
| 11.6–15 | ADB’s restrained gesture, distinct compact lettering, live diagram arrow |
| 15–20.2 | Thought-background change, prop accumulation, live correction, recoil and tension accent |
| 20.2–24.2 | Full ADB body, weight shift, quiet reaction; inspect both resting arms |
| 24.2–28.3 | Reach, mug handle grip, elbow/forearm length, lift, return, release and synchronized clink |
| 28.3–33.6 | Nemi’s decision, a line drawn visibly over time, sparse drawing sound |
| 33.6–37.8 | Finished doodle holds still; pride turns into uncertainty; finite realization accent |
| 37.8–42.3 | ADB’s dry verdict, pose change and quiet hold; no mandatory zoom |
| 42.3–48 | Both characters, evening background, live face marks, ADB’s handwritten payoff, quiet final hold |

## Corrections from the rejected closeup proof

The earlier path used a fixed elbow midpoint offset and forced a vertical wrist. Contact tests alone missed the unnatural arm silhouette. The external path solver now preserves segment lengths, uses the existing arm controls, and lets an unspecified wrist follow the forearm. The mug uses the existing cup grip and a matching handle contact. Wider review shots use scales 1.65–1.85 and keep hands/feet visible. Starter framing is widened too.

Path ownership is bounded with `hand_path_window`, so the mug action does not override unrelated gestures for the whole story. Tests check both arms’ lengths, contact continuity, visibility and ownership. This corrects external direction; no underlying hand shape, character rig or pose library was changed.

## Voice and timing

Ten new lines were generated from the existing cached CustomVoice model using the unchanged canonical Nemi/ADB speaker and identity prompts. This is new dialogue, not a claim of a bit-identical performance to earlier clips. The original generated sources are retained and hashed. Only two longer Nemi passages use 1.08× and one uses 1.05× pitch-preserving pacing; remaining dialogue is 1.00×. No pitch, formant or EQ change.

`source_words.json` stores cached Whisper Tiny word estimates/confidence. Captions follow the measured transcript (including “gonna” and “40”) rather than invented sentence fractions. Automatic recognition and broad vowel mouth cues still require listening for final production. No claim of phoneme-perfect lip sync.

## Reproduction

```sh
# Requires the existing cached model/runtime; outputs never replace old episodes.
HF_HUB_OFFLINE=1 .venv/bin/python tools/storytime/generate_review_voice.py
python3 tools/storytime/build_review_story.py
python3 tools/storytime/validate_scene.py common/storytime/examples/story_review_48s/scene.json
python3 tools/storytime/check_engine.py
python3 tools/storytime/render_scene.py --spec common/storytime/examples/story_review_48s/scene.json --output renders/storytime_review_48s/The_Perfect_Setup_48s.mp4
```

Saved source clips are reused, not synthesized again. If originals are absent, newly synthesized performance can differ: regenerate word annotations and review all timings. A changed prepared source/placement requires a new output folder, not reuse of stale metadata. The full video/audio remain local; source, timing records and small QA artifacts go to GitHub.
