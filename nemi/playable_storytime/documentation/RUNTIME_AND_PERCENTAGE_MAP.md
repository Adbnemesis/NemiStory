# Full-film runtime and native number landings

The isolated full-episode validator accepts 180–360 seconds at 24, 30 or
60 fps. A full movie still needs exact scene coverage, matching gameplay
duration, valid authored routes and the honest no-automatic-state contract.
Auditions retain their separate 30–60-second, explicitly nonplayable route.

The original user brief says, “Target a roughly 4–6 minute experience, but adjust
duration based on the pacing and quality of the interactive moments.” Its
four-minute target is flexible. R9's faster conversational pace and preserved
short waits therefore use the current **220-second** full cut. This updates an
overly strict isolated validator minimum; it does not bypass production
preflight, scene, voice, media or approval validation.

Native YouTube digit destinations are fractions of the **actual encoded whole
movie duration**. Recompute them whenever the runtime changes:

`destination_seconds = encoded_duration_seconds × key / 10`

The complete current R9 files decode to220.000seconds at30fps with6,600frames; all ten percentage destinations have zero error. See `episodes/episode_002/review/r9_digit_media_qa.json` and the two full-media QA reports. For a220-second/30fps movie, the decoded count is6,600frames.
The ten equal slots last 22 seconds:

| Key | Time | Encoded frame |
| --- | --- | --- |
| 0 | 0:00 | 0 |
| 1 | 0:22 | 660 |
| 2 | 0:44 | 1,320 |
| 3 | 1:06 | 1,980 |
| 4 | 1:28 | 2,640 |
| 5 | 1:50 | 3,300 |
| 6 | 2:12 | 3,960 |
| 7 | 2:34 | 4,620 |
| 8 | 2:56 | 5,280 |
| 9 | 3:18 | 5,940 |

The natural successful continuations into the next situations are 66, 132 and
198 seconds. All spoken/printed numbers, native chapters, route targets,
interaction windows, environment events, motion paths and final voice-dependent
tracks must use the new clock. Retain the stable actor/material viewpoint
anchors at those joins. A shorter voice in an unchanged24-second slot can
reintroduce empty waiting, so author slot duration and narration placement
together.

The matching planning example is
`documentation/examples/runtime_220_contract.json`. It is an expected clock,
not a complete scene spec or proof that the encoded movie matches it. Validate
the actual exported duration, frame count and all ten decoded arrivals before
changing the current preview pointer. Do not append an intro/outro/logo after
locking the map. Earlier240-second maps remain valid for their preserved
movies and are not current R9 evidence.

Local preview choice buttons and optional view assistance belong to that
webpage. The uploaded movie supplies authored picture/audio and relies on
native percentage keys or matching chapters; it cannot detect choices or
control a viewer's preserved 360 viewpoint. Exact native-platform and physical
phone checks remain separately recorded.

Run the regression with:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s nemi/playable_storytime/tests -p test_full_runtime.py -v
```

This clock change and revised voice/picture require a fresh complete 1080p
review. Earlier satisfaction or technical checks do not authorize 4K.
