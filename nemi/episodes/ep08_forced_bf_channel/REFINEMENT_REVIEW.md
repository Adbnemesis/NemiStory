# EP08 revision — same narration and script, clearer staging and sound

User explicitly requested improving this existing episode on 2026-10-02. Episode 9 is being produced separately in Antigravity; this revision changes only EP08 files and creates new review outputs under `renders/ep08_refinement/`. The old MP4 is preserved.

## Direction

Promise: Nemi has convinced her boyfriend to create a channel, and the viewer gets to see who he is. Want: turn a shared animation project into two storytellers. Choice: redesign ADB, then keep asking him to make a channel. Consequence: both now have a platform for their mutual teasing. Payoff: his unexpectedly normal introduction leaves Nemi pleading for the effort to have been worthwhile.

The original 30 spoken segments, all 69 caption cards, saved timing, voice audio and 95.405-second scene clock are fixed. No text rewrite, regeneration, speed change, pitch change, EQ or compression. The shared mixer applies constant gain to narration/SFX for headroom. The rendered video uses 2,862 frames (95.4 seconds) at 30 FPS, matching the original frame duration.

## What changed and why

- Larger characters and 52-pixel captions improve phone-size readability. Nemi's existing legs are planted with the shared external solver; the rig files are preserved.
- A card's visual action now waits for its original timestamp before starting. Each card ends at its absolute timestamp, avoiding cumulative rounding of every separate pause and phrase. Caption text and times are unchanged.
- `sfx_cues.json` links 18 short sounds to named caption/visual events. Preview and offline mixing use this one schedule; the final export previously discarded all beat audio and muxed only narration.
- The opening uses one short accent rather than an exclamation, stress spiral, sweatdrop and question marks competing for attention. Ordinary props and reaction marks arrive fully inked; selected annotation/revision marks still draw live.
- Existing shared lettering uses Nemi's alphabet for her notes and ADB's for his refusal and imagined story notebook. The shared ink player remains the only drawing player.
- New ADB's reveal is a planted pose cut. Nemi's repeated request no longer slides her root across the floor. The floating microphone and isolated foot-step cue are removed.
- Supported existing poses replace unrecognized ADB crossed-arms/shrug/casual-lean calls and Nemi presentation, pleading, recoil and defeat calls that were silently falling back to a generic standing pose. Nemi facial calls use her actual supported expressions, with restrained mouth scaling. His introductory passage gains one held story notebook; his oversharing line and Nemi's dry response remain quiet.
- Subscribe/confetti accents clear before the final plea. The ending holds on the face without a fresh doodle or sound.

## Sound selection and provenance

All assets come from the existing catalog. Each cue records its exact file, duration, gain and catalog license. Sounds are selective paper turns, a short drawing scratch, soft whooshes, taps and quiet UI accents. No music, ambience bed, added voice or downloads. The mix uses `tools/storytime/audio_mix.py`; the previous 2.2x amplification and limiter are replaced with one measured constant gain. Source recording hashes are validated before export.

## Reproduction

```sh
python3 nemi/episodes/ep08_forced_bf_channel/tools/render_ep08_master.py --validate-only
python3 nemi/episodes/ep08_forced_bf_channel/tools/render_ep08_master.py --proof --output renders/ep08_refinement/new_proof.mp4
python3 nemi/episodes/ep08_forced_bf_channel/tools/render_ep08_master.py --output renders/ep08_refinement/new_full_review.mp4
```

Every render is fresh and uses a private temporary directory. Capture must include every caption/action cue within one frame of the original timeline and enough raw frames for the beat; missing choreography cannot be filled by duplicating frames. Existing outputs are refused. This is the explicitly authorized legacy EP08 pipeline; it does not migrate the episode into a new version-2 spec or relax the new-episode preflight gate. Keep EP09 files and shared project settings out of this revision's commits.

## Verification record

Final full review rendered as `renders/ep08_refinement/EP08_Forced_BF_Channel_Refined.mp4`: 1920×1080, 30 FPS, 2,862 frames, approximately 95.4 seconds. All nine beats completed without script errors, with all 69 caption/action cues observed at their expected capture frames (maximum rounding 0.016334 seconds). Capture completeness and original text/audio checks pass. The encoded mix measured −18.5 LUFS and −1.4 dB true peak. The final ten-second reveal excerpt is `renders/ep08_refinement/EP08_final_reveal_proof_10s.mp4`.

Twelve final stills were inspected across all nine beats. Muted browser playback was sampled across the opening/development and the ending; this verifies displayed motion and framing at sampled points, not uninterrupted attention to every frame or listening. Source files, original movie and rig hashes remain unchanged in the 127-file protected inventory. Sound selection, event synchronization and encoded levels were checked; listening to the final mix remains pending. Small saved evidence: `review/refinement_contact.jpg` and `review/refinement_qa.json`. Earlier failed trial captures remain local diagnostics and are not the delivered movie. The focused ten-second reveal proof was rendered and inspected: larger framing, visible feet, floor contact and stable reveal art. Original voice/text/timing/rig/movie hashes match the saved pre-edit inventory. The plan validator checks all 69 caption records against the original timing JSON, narration/timing hashes, cue times and licensed real sound assets. Encoded audio levels and exact frame counts are measured for every export. Automated numerical checks do not replace listening.
