# EP09 — locations, props and scale revision

The user explicitly authorized revising EP09 and EP08 on 2026-10-02. EP09 now lives in `nemi/episodes/ep09_sf_accident/`. The Antigravity scene and reading receipt are preserved as historical originals. Its existing recordings, 18 spoken turns, source settings, word timestamps and 120-second duration are preserved. Two caption transcription spellings were corrected (rode, Waymo); narration was not regenerated, rewritten or accelerated again. Shortening the story requires a separate approved audio edit and rebuilt timing.

## Direction and staging

See `DIRECTION_REVISION.md`. Nemi is scaled against transport, furniture and locations instead of repeated large paper-screen layouts. Held travel objects return through the story. A city, event venue, bridge, cabin, airport road and roadside are authored sets. The empty driver seat and turning wheel replace a generic label. The brake cue follows the actual brakes word at 79.355714 seconds; rear bumper contact follows into at 86.839649. The intact and damaged cab keep the same body color. Police, cones and a report establish the aftermath. A quiet crying reaction and intact/dented car callback lead into a held final face. Four existing catalog SFX are selective accents; no added voices or music. Stable authored ink uses Nemi's profile; completed ink holds still. Existing rigs, hands, pose/expression libraries and voice identity remain intact.

## Reproduce

```sh
python3 tools/storytime/preflight.py status --folder nemi/episodes/ep09_sf_accident
python3 nemi/episodes/ep09_sf_accident/tools/build_revision.py
python3 tools/storytime/validate_scene.py nemi/episodes/ep09_sf_accident/scene.json
python3 tools/storytime/render_scene.py --spec nemi/episodes/ep09_sf_accident/scene.json --start 42 --duration 10 --output renders/ep09_sf_accident_revision/new_cabin_proof.mp4
python3 tools/storytime/render_scene.py --spec nemi/episodes/ep09_sf_accident/scene.json --output renders/ep09_sf_accident_revision/new_full_review.mp4
python3 nemi/episodes/ep09_sf_accident/tools/check_capture.py renders/ep09_sf_accident_revision/new_full_review.mp4
```

Use a new output filename every time. Source voice files remain local under `renders/nemi_sf_accident/source_voice/`; the approved narration/timeline remain under `renders/nemi_sf_accident/audio/`. They are intentionally excluded from Git. A checkout without these originals cannot render or reconstruct them by guessing. Historical builder outputs are explicitly named as rebuilds and cannot replace the revision. Do not run the archived generator for this revision.

## Workflow correction

The previous starter placed every production in examples and both gate and renderer rejected numbered episode folders. Real episode starters now default to `<author>/episodes/epNN_slug/`; `--study` explicitly chooses examples. Duplicate episode numbers are refused. Both character skills name the canonical path, require real location/prop decisions and scale checks, and retain the mandatory current document gate. Fourteen gate tests cover numbered paths, stale/copied records and refused duplicate numbers. A delivery receipt documents reading and application notes; it cannot prove comprehension or artistic quality.

## Export reliability

The full test exposed native occlusion leaving recorded pictures stale while the scene clock continued. The exporter explicitly defers a draw after authored sampling/redraw requests and checks decoded raw frame count. The engine’s automatic draw statistic excludes some explicit refreshes, so decoded boundaries are checked directly. Explicit drawing uses the documented [RenderingServer.force_draw API](https://docs.godotengine.org/en/stable/classes/class_renderingserver.html). The established ten-second proof checks actual encoded cut frames 103, 131 and 249. EP09's additional check samples decoded background colors at early and late authored boundaries, including the final studio cut; video duration alone cannot catch stale pictures. Failed trial movies are local diagnostics and are not review deliverables.

Final numerical and sampled visual evidence is saved in `review/set_scale_qa.json` and `review/set_scale_contact.jpg`. Muted sampled playback and stills verify selected visible moments, not uninterrupted viewing or listening. Final sound listening remains pending.

Final review movie: `renders/ep09_sf_accident_revision/EP09_SF_Accident_Reviewed.mp4` (1920×1080, 30 FPS, 3,600 decoded frames). Eight location boundaries match the authored frames, including the final studio at frame 3295. Sixteen stills were inspected; final sampled muted playback checked road staging and police visibility. Encoded audio is −18.1 LUFS and −1.8 dB true peak. Five existing engine checks, both skill validations and fourteen preflight tests pass. The protected 267-file inventory has no hash changes. EP09 remains two minutes; shortening has not been silently applied.
