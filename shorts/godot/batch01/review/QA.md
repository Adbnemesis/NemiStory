# Batch01 — final technical and visual review

Five complete exports, each 15.00s / 450 decoded frames /1080×1920 /30fps /H.264 + stereo 48 kHz AAC. All visuals are Godot-authored, with no image generation or reference-video sprites.

| Edit | Revision | Picture accents after opening | Audio source correlation | LUFS | True peak |
| --- | --- | --- | --- | --- | --- |
| My song just came on | r2 | ≤6.200ms | 0.99923 | -13.96 | -4.92dBTP |
| Wrong-class runway | r2 | ≤9.200ms | 0.99869 | -14.13 | -3.91dBTP |
| One quick doodle | r3 | ≤11.300ms | 0.99869 | -15.91 | -3.16dBTP |
| Same beat, different energy | r1 | ≤15.567ms | 0.99781 | -14.06 | -3.17dBTP |
| The camera likes her | r1 | ≤14.400ms | 0.99448 | -14.04 | -2.93dBTP |

All source hash/range checks, actual encoded cut checks, recorded-SFX contribution checks, audio latency/headroom checks and eight validator rejection tests passed. Decoded audio has zero clipped samples and no measurable source-clock delay. The opening compositions appear immediately and need not land on the first analyzed onset. Later cut timing is measured against selected exact-recording accents; the onset detector is not a downbeat oracle.

Reviewed settled native Godot stills and actual browser playback for all five edits. The art proof caught an ADB sleeve patch and a hand hidden behind hair; both were corrected before the final exports. Phone/pencil grip details are drawn with fixed contact; feet are visible in the wide shots. Handheld props do not slide independently. Doodles enter briefly and then hold; the foreground pencil is one finite wipe, the camera wash lasts two frames, and the duo dark/paper reversals hold between phrase changes.

Each raw Godot capture contains 451 decoded frames. The packager retains exactly 450 authored frames and trims the surplus trailing frame. Godot's summary frame counter does not include every explicit forced-draw call; actual FFprobe decoded counts, encoded cue changes and still/playback inspection are the export evidence. The still route also forces drawing to avoid waiting on a window-dependent frame callback.

Source/level checks establish the encoded sound mix and recorded clip presence; no human audition or current trend rank is claimed. The five last holds close their visual ideas. Native replay is a semantic restart; no seamless full-song audio seam is certified. The user accepted the earlier r3 proof; this batch remains available for their creative review. No retention/CTR/virality gain is inferred without audience data.

Per-short `review/QA.md`, `export.json`, `audio.json`, current revision render records, contact sheets, directions and cue maps are the detailed evidence. [MANIFEST.json](../MANIFEST.json) retains checked export/source identities.

## Isolation

Final [isolation-after.json](isolation-after.json) passed: zero changed/added/removed protected source files; 1,081 original editable files unchanged, root project settings unchanged, and all 347 existing outside-Shorts status entries preserved. Original episodes and their generated media were not edited or cleaned up. Binary media was excluded from hashing; all batch write targets were under `shorts/` or temporary capture directories.
