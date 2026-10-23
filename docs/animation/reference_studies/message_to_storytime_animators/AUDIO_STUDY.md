# Reference audio study

Source: `/Users/talus/Downloads/This Is A Message To All Minecraft Youtubers.mp4`

SHA-256: `da2e2ce404461f9823ac33213d1bc51996e60e13c51ff21e3159904a6c4682c1`

The file's embedded metadata identifies the creator as **robro**, title **This Is A Message To All Minecraft Youtubers**, and source URL `https://www.youtube.com/watch?v=U3oOjOzrxV8`. The local file is the primary reference. The URL is a metadata-provenance link; a remote copy is not asserted to be byte-identical.

## Timing and words

Picture is 25.000 seconds, 30 fps. AAC audio is 25.054331 seconds, 44.1 kHz stereo. `reference_whisper_large.json` retains automatic word boundaries and confidences. These boundaries are approximate, particularly first words following pauses.

| Approximate phrase interval | Spoken phrase |
| --- | --- |
| 0.00–2.20 | This is a message to all the Minecraft YouTubers. |
| 3.54–4.68 | My name is Robro. |
| 6.06–7.48 | I'm a retired talent. |
| 9.24–11.08 | And I'm gonna steal your jobs. |
| 11.08–14.18 | By becoming the biggest Minecraft YouTuber in the world. |
| 18.56–19.86 | I'm already the best. |
| 19.86–21.84 | Now, I just gotta be the biggest. |

The name is transcribed imperfectly as Rybro/Rybra by ASR. Source metadata and the visible ROBRO card establish the intended name.

## Sound structure measured from the separated stems

The soundtrack's interruptions matter more than a continuous beat grid. Keep the empty spaces as part of the joke and the rhythmic contrast.

- 0.00–2.20: dry opening narration. Instrumental estimator output is approximately −61.3 dBFS and contains trace consonant artifacts.
- About 2.20–9.6: bass/percussion bed appears around the inserted images and introduction cards. It thins/ducks around spoken phrases.
- About 9.7–14.1: music is near silence under the main boast; separated bed is approximately −66 dBFS in one-second windows from 10–14 s.
- About 14.2–18.7: the percussion-heavy section returns during the insert sequence.
- About 18.8–21.8: the final lines are dry again.
- About 21.8–22.8: a short impact/tail remains, then near silence through the ending.

`music_measurements.json` contains one-second levels by stem and an automatic 129.2 BPM estimate. That number is **not a confirmed tempo**: short disconnected sections, silence and impacts can fool beat tracking. Do not force every edit to that grid. Preserve actual named picture/word cues.

## Reusable matching bed

`reference_music_bed_clean.wav` is a **model-separated estimate of the supplied soundtrack**, not a new composition or a lossless original instrumental.

- 25.000 seconds, 44.1 kHz, stereo, PCM 24-bit.
- SHA-256: `39762ef51ec9bf83f71d3d6a0449cfc4edb543497c577898a585e0a536f5fe67`.
- HTDemucs 4.0.1 with the already-cached `955717e8` model was run locally. The exact source and model hashes, transforms and output hashes are in `clean_bed_provenance.json`.
- Only the dry intro 0–2.200 s was gated to silence, with a 5 ms ramp at the soundtrack entrance. AAC excess after 25.000 s was trimmed. All substantive source music changes and rests remain on their original timeline.
- The full source narration is recognized in the isolated `reference_vocals.wav`. No complete source narrator sentences were recognized in the instrumental estimate. The estimator's dry-intro trace was removed.
- ASR cannot certify inaudibility. A perceptual playback check remains necessary for subtle voice leakage or separation artifacts.
- Original music identity and licensing were not inferred from this file.

The source is almost mono: L/R correlation is 0.99487. Plain center cancellation destroys most of the soundtrack and was rejected (`reference_side_candidate.wav` is analysis only).

## Existing music library

The available repository music is `shorts/assets/music/batch01/`: Cheri Cheri Lady, Dancin (Krono Remix), Fashion, Makeba and Memory Reboot. Those are materially different named tracks, and no matching-source relationship is established. Using a generic continuous library bed would lose the reference's abrupt dry/filled contrast. Prefer the separated supplied bed for this reference-specific adaptation after playback checks.

## Analysis limits

The local model runtime does not accept rendered audio input as perceptual evidence. Local speech recognition, separation and level/beat measurements were performed; no human listening is claimed here. A vidIQ video-watch analysis of the verified embedded source URL completed; exact output is saved as `vidiq_video_watch_result.json` and `VIDIQ_VIDEO_WATCH.md`. It describes dark modern trap/hip-hop: deep 808 bass glides, sharp clap/snare, fast rolling hats, dark synth layers and pitched vocal stabs/chops, approximately 130–140 BPM. This perceptual description agrees with the measured bass/percussion stems and tentative 129.2 BPM estimate.

The remote analysis is coarse: it misreports caption colour and compresses the giant word sequence; some timing claims conflict with local stems (including music under 9–14 s where the instrumental stem is essentially silent), and its black-ending time is approximate. Local picture frames and decoded source remain authoritative. Its final hype/chorus description is treated as a hypothesis for sound classification.

## Hybrid music bed preserving musical vocal chops

Use `reference_music_bed_hybrid.wav` for the reference-specific edit: SHA-256 `0a49be263d7419c690e13c55e338eee192763c9240c253e4deae7547e0f9d374`, 25.000 seconds, 44.1 kHz stereo PCM 24-bit. `hybrid_bed_provenance.json` records all transforms.

Demucs removes pitched musical vocal stabs along with narration. The hybrid restores the full original soundtrack only inside conservative narrator-free windows: 2.24–3.50, 4.82–5.99, 7.61–9.17, 14.30–18.44 and 22.00–25.00 seconds. Twenty-millisecond inner crossfades prevent splice clicks. Elsewhere it uses the separated bed, with the dry opening gated. The prior clean instrumental remains preserved.

The final source hype/chorus accent may be music or a separate inserted SFX; classification is uncertain. This alternate retains it for faithful soundtrack comparison. If treated as a new standalone SFX cue in production, use the authorized exact existing root/category recordings instead of silently reclassifying an uncertain source sample. No source vocal is used as new character dialogue.
