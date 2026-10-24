# External edit rebuild — current EDIT R9

The earlier Godot presentation was rejected. These replacements are actual layered video edits: independent character alpha footage, a detailed dim studio background, bright close-up inserts, oversized serif words behind the head, purposeful prop montage, one brief source-like dissolve and a dry uncaptained ending. Godot supplies only canonical character art; it does not assemble these movies.

The current complete review movies are:

- Nemi: `nemi/episodes/ep17_message_to_storytime_animators/renders/Nemi_Message_EDIT_R9_1080p.mp4`
- ADB: `adb/episodes/ep08_message_to_storytime_animators/renders/ADB_Message_EDIT_R9_1080p.mp4`

Both are25.000seconds,1920×1080,30fps. The exact source cut rhythm is the base; a coherent sketchbook close-up/oversized hoist replaces Minecraft props. The short dissolve is deliberate: exact source frames confirm an overlapping-character transition in the same montage. R9 removes four optional arm-settle frames from the preserved R8 cut because the source cuts directly to an already committed open-arm pose.

Four coherent full voice takes per author were generated with the unchanged canonical Sohee/Aiden models and base identity paragraphs, plus separate requested performance direction. B supplied the hook/name/identity/payoff; D supplied the shortened challenge. Delivery direction is amused self-belief, stress on the absurd boast and a lowering dry final sentence. No pitch/formant/EQ changes or tempo acceleration were used. Source takes, request metadata, exact bounds and final word times remain local under each episode's `audio/edit_r8/` or `voice/edit_r8/`.

The soundtrack uses the existing reference-derived hybrid bed on its original25-second clock, ducked under the new actual speech. It preserves musical entrances, silences and source accents. It is estimated separation from supplied media, not original multitrack audio. No new synthetic SFX were added.

Production source is `tools/edits/storytime_message_edit.py`; the two episode `edit_rebuild/` folders contain picture/sound decision lists and current narration. Small canonical capture sources/anchors/manifest are backed up in `rebuild_assets/`. All generated media, voices, rejected movies and local capture assets remain preserved. Existing rigs, shared libraries and voice configuration were not changed by this rebuild.

## Generated studio image

The built-in image-generation tool created only the background. Local native PNG: `renders/message_to_storytime_rebuild/assets/studio_background.png`. Its original dimensions, hash, input reference and recorded prompt are in `BACKGROUND_PLATE.json`; the readable prompt is in `BACKGROUND_PLATE.md`. The raster is resized by the compositor; the1080p movie does not imply native1080p background generation. Character identity/art comes from the canonical rigs, not generated character replacements.

## Review status

See `FINAL_EDIT_REVIEW.md` and each episode's `review/edit_r8/FINAL_R9_CHECKS.json`. Whole-file decoded audio/timing/black-tail checks pass. Contact sheets spanning both full cuts and selected native-resolution boundaries/prop contacts were inspected. These are sampled visual and technical checks, not a claim of full-speed perceptual listening or emotional approval. Current complete1080p movies are for user review. No4K movie or human-satisfaction receipt was created. All prior rejected cuts remain intact.
