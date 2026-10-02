# Storytime sound direction

Required for Nemi and ADB productions. Sound design is an authored story layer: plan recognizable reactions, object sounds, illustration accents and meaningful scene transitions alongside the spoken beats. A voiced episode must not default to narration plus two barely audible effects. Review every thought beat for a useful sound opportunity; explicitly choose silence where it helps. No fixed effects quota or automatic sound on every blink/gesture.

## Plan and palette

Save an episode sound plan with scene seconds, the spoken/visible cue, catalog ID, duration, source gain, intended prominence and reason. Link version-2 SFX to named scene events using supported `event`/`event_offset`; timings use the approved recording clock. Nemi can use playful boings, curious chimes and sharper comic reversals; ADB generally uses dry taps, understated confirmations and a well-timed fail accent. Character distinction is timing and selection, not a different voice recording.

Use the existing root MP3s and existing library recordings under `common/audio/sfx/`. **Do not synthesize/generate SFX or silently substitute older procedural assets.** First inspect `root_sfx_inventory.json`: it lists the exact root `bruh.mp3`, `fahhh.mp3`, `get-out.mp3`, `anime-wow.mp3`, `a-few-moments-later.mp3`, `pop.mp3`, `whoosh.mp3` and other user-selected clips with measured durations and SHA-256 hashes. They remain at their original paths so existing callers keep working. The combined catalog now indexes them as `viral_*` IDs alongside the category folders. “Viral” identifies the user's palette, not independently verified popularity.

Choose the actual recognizable root clip for a comic aside or reversal, and use library pencil/page/cloth/impact/chime sounds for story detail. No automatic memes on every sentence. Vocal meme clips are external commentary accents; they do not replace Nemi/ADB dialogue, mouths or voice identity. Keep speech intelligible. Longer source clips may use a documented <=2.5-second excerpt retaining the recognizable attack; do not pitch/tempo-process or invent a substitute. Example: `{"file":"res://common/audio/sfx/bruh.mp3","at":7.053571,"duration":0.817,"gain_db":-12,"event":"normal_reversal"}` with that named event at the same scene time.

Use `tools/storytime/sfx_assets.py` to check existing-file provenance and reject procedural substitutes. Root MP3 checks pin path/hash to the inventory; library assets retain their catalog license checks. User requested these existing clips for production, but their original licenses were not recorded: do not mark them CC0/commercial-safe or fold them into the old 172-asset verified-license claim. Record this provenance accurately without replacing the user's requested assets.

## Audible mixing

A source `gain_db` is attenuation applied to that file, **not** a measured distance below dialogue. Different clips have different native levels and leading silence. Blindly applying -20 to -29 dB made many earlier cues effectively disappear. Start important accents around -6 to -10 dB and quieter surface sounds around -10 to -14 dB, then measure and audition the actual mix. These are starting settings, not guaranteed loudness targets. Supported version-2 source gains remain -60..-6 dB; choose a suitable source if it cannot be heard within that range.

Compare each rendered SFX segment's RMS/peak to nearby narration after its fixed -2 dB mixer gain. Short hero transients may approach dialogue prominence; longer tones should sit beneath it. Report quiet cues and overlapping clusters instead of counting cues as evidence they can be heard. Source truncation should retain the recognizable attack and avoid abrupt audible tails. Preserve speech clarity and purposeful silence after a reaction. Do not create continuous loud ambience or stack effects indiscriminately.

Use `audio_mix.py` for the same clock/gains in exports. Recalibrate constant master gain after changing cues; check the **encoded** movie for true peak <= -1 dBFS. Do not alter voice identity, pitch, formants, EQ, tempo or timing for a sound-only pass. Master level gain affects loudness only. No automatic narration ducking or compression.

## Review and delivery

Validate source, inspect cue timing against the actual scene and listen to representative mixes on ordinary playback volume. Numeric audibility checks do not prove perceptual balance or replace listening; record unperformed listening honestly. Save cue count, palette, relative-level measurements, encoded peak and voice/source hashes in the episode review folder.

For sound-only changes, a validated re-export may reuse the approved video stream with `-c:v copy` and newly mix the original narration plus SFX. Verify video stream hashes/duration/resolution; this preserves camera/animation exactly and retains native 4K. Never add effects on top of the old mixed soundtrack. A visual change still needs a fresh visual render. Save current masters in the episode `renders/` folder and update its index. Only remove superseded exports when the user requests cleanup, after replacements pass checks; never remove approved voice/script/assets as render cleanup.
