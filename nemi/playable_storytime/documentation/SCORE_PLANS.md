# Authored original piano phrases

`tools/score.py` uses the episode's optional `audio/score_plan.json`. An episode
without that file keeps the existing legacy chapter-motif behavior. The R8 plan
uses four short, deliberately placed musical phrases instead of notes recurring
at the same eight offsets in every chapter. Original musical composition is
separate from event-linked SFX, which remain existing recorded assets.

The version-1 plan contains `title`, `narration_sha256`, `phrases` and optional
`silent_ranges`. Every phrase supplies a unique `id`, explicit scene-clock `at`,
story `intent` and notes. Notes supply relative `offset`, integer piano `midi`
(21–108), `duration` (0.1–8 seconds), linear amplitude `velocity` (0.001–0.6),
and optional stereo `pan` (−1 to 1). Notes are ordered; simultaneous chord notes
can share an offset. Every complete note tail must fit the full scene clock.

An optional phrase `anchor` records `clip_id`, exact measured `word`, optional
zero-based `occurrence` and optional offset (within ±2 seconds). Its explicit
`at` must agree with the final audio word time within 1 millisecond. A narration
hash mismatch, missing anchor, unsafe value or overlap with a protected silence
fails instead of being silently truncated or retimed. See the actual episode's
`audio/score_plan.json` as the complete production example.

`silent_ranges` are explicit `{start,end,reason}` objects. R8 leaves the HOST
shock, pencil discovery, furniture freeze and final date joke free of music.
Its phrases support the pudding temptation, sandwich confidence, toy rehearsal
relief and warm thank-you. These are melodic phrases, not generated event SFX.

The deterministic soft piano instrument uses explicitly pitched notes with
authored velocity and natural amplitude decay. Existing narration ducking stays
at 42% during speech, with 150 ms approaches/releases. The result is a full-scene
48 kHz stereo WAV containing long intentional silent regions. Existing score
files are never overwritten; preserve a rejected revision before recomposing.

`audio/score_composition.json` records every rendered note, phrase intention,
anchor, protected silence, score-plan hash, narration hash, instrument/license,
output hash and honest listening status. Numeric note/energy checks do not
establish subjective musical quality or audibility in the final mixed movie.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s nemi/playable_storytime/tests -p test_score_plan.py -v
PYTHONDONTWRITEBYTECODE=1 .venv/bin/python nemi/playable_storytime/tools/score.py
```
