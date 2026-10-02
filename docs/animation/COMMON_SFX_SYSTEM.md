# Storytime sound direction

Required for Nemi and ADB productions. Sound design is an authored story layer: plan recognizable reactions, object sounds, illustration accents and meaningful scene transitions alongside the spoken beats. A voiced episode must not default to narration plus two barely audible effects. Review every thought beat for a useful sound opportunity; explicitly choose silence where it helps. No fixed effects quota or automatic sound on every blink/gesture.

## Plan and palette

Save an episode sound plan with scene seconds, the spoken/visible cue, catalog ID, duration, source gain, intended prominence and reason. Link version-2 SFX to named scene events using supported `event`/`event_offset`; timings use the approved recording clock. Nemi can use playful boings, curious chimes and sharper comic reversals; ADB generally uses dry taps, understated confirmations and a well-timed fail accent. Character distinction is timing and selection, not a different voice recording.

Use real entries from `common/audio/sfx/sfx_catalog.json` and verify files/licensing. Familiar available conventions include `comedic_record_scratch_01`, `comedic_wrong_buzzer_01`, `comedic_fail_low_tone_01`, `cartoon_boing_spring_01`, `cartoon_slidewhistle_up_01`, `sting_achievement_bell_01`, `sting_question_chime_01`, pencil/page sounds and camera whooshes. These are familiar sound types, not guaranteed copies of a particular viral meme. Do not fabricate `bruh.mp3`/anime samples or substitute a stranger's vocal gasp for the character. The catalog includes MIT, CC0 and commercially allowed Mixkit assets; not everything is public domain.

## Audible mixing

A source `gain_db` is attenuation applied to that file, **not** a measured distance below dialogue. Different clips have different native levels and leading silence. Blindly applying -20 to -29 dB made many earlier cues effectively disappear. Start important accents around -6 to -10 dB and quieter surface sounds around -10 to -14 dB, then measure and audition the actual mix. These are starting settings, not guaranteed loudness targets. Supported version-2 source gains remain -60..-6 dB; choose a suitable source if it cannot be heard within that range.

Compare each rendered SFX segment's RMS/peak to nearby narration after its fixed -2 dB mixer gain. Short hero transients may approach dialogue prominence; longer tones should sit beneath it. Report quiet cues and overlapping clusters instead of counting cues as evidence they can be heard. Source truncation should retain the recognizable attack and avoid abrupt audible tails. Preserve speech clarity and purposeful silence after a reaction. Do not create continuous loud ambience or stack effects indiscriminately.

Use `audio_mix.py` for the same clock/gains in exports. Recalibrate constant master gain after changing cues; check the **encoded** movie for true peak <= -1 dBFS. Do not alter voice identity, pitch, formants, EQ, tempo or timing for a sound-only pass. Master level gain affects loudness only. No automatic narration ducking or compression.

## Review and delivery

Validate source, inspect cue timing against the actual scene and listen to representative mixes on ordinary playback volume. Numeric audibility checks do not prove perceptual balance or replace listening; record unperformed listening honestly. Save cue count, palette, relative-level measurements, encoded peak and voice/source hashes in the episode review folder.

For sound-only changes, a validated re-export may reuse the approved video stream with `-c:v copy` and newly mix the original narration plus SFX. Verify video stream hashes/duration/resolution; this preserves camera/animation exactly and retains native 4K. Never add effects on top of the old mixed soundtrack. A visual change still needs a fresh visual render. Save current masters in the episode `renders/` folder and update its index. Only remove superseded exports when the user requests cleanup, after replacements pass checks; never remove approved voice/script/assets as render cleanup.
