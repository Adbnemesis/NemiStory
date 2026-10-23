# ADB creator message review

Current delivery: full 25.000-second R5 1080p review cut. No 4K export or user-approval receipt has been created.

## Recorded checks

- New production allocated as ADB EP08; current preflight is ready. All required document parts were delivered into context in manifest order, with episode-specific notes. Changed editorial field documentation was reread and acknowledged after both updates.
- Actual Nemi EP06 colour-reference movie sampled at 2, 42 and 78 seconds. Contact retained in `reference_colour/ep06_colour.jpg`. The ADB production uses cream, readable dark author ink, light studio washes and the current protected character assets.
- The current protected ADB rig wears a sage button shirt and off-white trousers. This differs from historical outfit prose in the character guide; the actual rig, palettes, expressions, hands, mouth and pose libraries were preserved.
- Canonical unchanged Aiden speaker and identity prompt generated five new source recordings at 24 kHz. All use 1.00× tempo. Original recordings and hashes are retained. Only 40 ms and 80 ms of unused terminal tails were bounded out of the opener and ambition clip; no sentence gaps or emotional pause were blanket-trimmed.
- Cached Whisper word measurements were saved. The compound-word corrections `storytime` and `underwatched` retain the measured union boundaries. Mouth intervals are explicit approximate articulation on those measured words, with labial/rest closures. This is not a claim of measured phoneme alignment.
- Shared full source validation passes for the final intended scene. Four selected root/library effects pass `sfx_assets.validate_asset`; hashes and honest provenance are in `sfx_provenance.json`.
- R1 ten-second proof and R2 full cut were preserved. R2 decoded as 750 frames, 1920×1080, 30 fps, exactly 25.000 seconds.
- R3 fresh ten-second proof checks the final announcement portrait scale and typography. Contact frames cover 0–9 seconds. The parent reviewed room/type framing; ADB retains an actual window/location cue behind the portrait. The cream full-body shot shows both hands and feet.
- R3 separate ten-second contact/ending proof covers original scene time 12.1–22.1. Four samples per second and full-resolution notebook grip were inspected. This identified a cropped notebook bottom; R4 widens only the notebook insert so the entire book/hand can be checked. The workload insert removes the actor to avoid an accidental edge crop. Desk notebook and paper stack have explicit surface contact. The gripping hand changes back to relaxed at the next cut.
- Exact runtime font names were queried from Godot SystemFont: Arial for intro; Times New Roman for serif. The font environment record is saved alongside this note.
- The hybrid music bed preserves source musical dropouts and uses original soundtrack only in conservative narrator-free cutaways, separated audio under voice, and a dry opening. Provenance is retained. It remains a separate scene track, not baked into narration. Source narration from Minecraft/Robro is not reused.
- The R2 decoded audio has integrated loudness −18.0 LUFS and true peak −1.6 dBFS. R4 uses the identical audio inputs, gains and timing. The audio agent's ASR check recovered the final ADB script and no reference narrator words; its JSON is retained. ASR content evidence is not subjective listening evidence.

## Final R5 checks

R4 contact proof was inspected at the notebook boundaries and after release: the supported wrapping hand meets the notebook edge, the next shot removes the actor, and laptop/page stack have authored surface contact. R5 changes only the editorial headline treatment: 580 px Times New Roman with horizontal compression, measured at roughly 36–37% picture height as in the supplied reference. The updated guide was read through all six parts and acknowledged again. A fresh R5 ten-second type proof and complete R5 movie were rendered through the shared validator/renderer.

The parent inspected the full R5 one-frame-per-second contact and revised type proof. Independent review checked critical cut, grip and rest boundaries. FINAL_R5_CHECKS.json binds the actual spec/input signature and movie hash, confirms 750 decoded frames/25.000 seconds, all 87 black tail frames from 22.100 seconds, −18.0 LUFS / −1.6 dB true peak, and exact decoded PCM identity to the earlier ASR-reviewed R2 mix. No original reference narrator words were recognized in that mix.

The separate shared 48-second integrated regression was freshly rendered and sampled across both authors, full bodies, live/held drawing, expressions, caption timing and mug contact. Engine/schema/audio checks passed. These are decoded visual, numerical and ASR checks; human perceptual listening and subjective full-speed playback remain pending review. Mouth articulation remains authored approximate word alignment, not measured phonemes.

No user approval or 4K receipt exists. Source/timing/preflight/QA are saved; movies/recordings stay local.
