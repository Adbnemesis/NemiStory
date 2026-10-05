# Batch 01 music sources

Five different recordings were downloaded on 5 October 2026 from the public Apple/iTunes preview endpoints. Each is an actual recording by the named artist, not a synthesized substitute. The original AAC preview, unchanged API response, decoded 48 kHz stereo PCM, SHA-256 records, source analysis and proposed edit clock are saved together here.

The previews are approximately 29.98 seconds long. Their position inside the full song is not supplied by the API. All `sourceStart` values below refer to the **downloaded preview timeline**. The recommended duration is 15 seconds; the director may shorten it while retaining the same source clock. The recordings keep their original speed and pitch.

These were chosen as recognizable music that fits the supplied edit references. No current YouTube Shorts, Instagram or TikTok trend rank has been verified, so the batch does not claim that they currently hold a trending position. Artist/catalog identity was checked against the primary sources linked below. Historical reach does not prove a current trend or predict the Shorts' performance.

| Recording | Exact downloaded version | Proposed start | Measured pulse | Suggested gain | Edit fit |
|---|---|---:|---:|---:|---|
| Modern Talking — Cheri Cheri Lady | catalog original, Apple track 348891989 | 0.1393s |114.03 BPM |−5.07dB | Romantic confidence, profile glances, restrained heart doodles |
| Aaron Smith feat. Luvli — Dancin | Krono Remix, Apple track 1882003938 | 4.1680s |119.98 BPM |−6.81dB | Loose confident groove, grounded shoulder/head reactions, silhouette switches |
| Britney Manson — FΛSHION | **Clean Version**, Apple track 1764031281 | 0.0108s |120.00 BPM |−3.64dB | Runway poses, angular accents, crisp garment hatching |
| Jain — Makeba | original album recording, Apple track 1046165672 | 0.7546s |116.02 BPM |−4.83dB | Percussive hand/pen accents and playful author doodles |
| VØJ & Narvent — Memory Reboot | original single recording, Apple track 1663317235 | 10.3848s |162.76/81.38 BPM |−6.18dB | Darker shading and silhouette hold before a stronger reveal at scene 4.000 s |

Gains are source-level suggestions aiming for up to −14 LUFS with at least −2 dBTP source headroom. They use gain only. They are not a finished mix report; the encoded Shorts need their own checks, especially if SFX are added.

## Primary identity and editorial context

- [Cheri Cheri Lady — Apple Music](https://music.apple.com/us/song/348891989). The [official Modern Talking video](https://www.youtube.com/watch?v=eNvUS-6PTbs) corroborates the original track identity. This download is the catalog original, not the “New Version” or an unofficial sped-up edit.
- [Dancin — Krono Remix single, Apple Music](https://music.apple.com/us/album/dancin-feat-luvli-krono-remix-single/1882003937). [Aaron Smith's Apple Music artist page](https://music.apple.com/us/artist/aaron-smith/42760745) lists the Krono Remix among his top songs and describes its historical meme resurgence. That history supports familiarity, not a current chart claim.
- [FΛSHION — Clean Version, Apple Music](https://music.apple.com/us/album/f%CE%BBshion-clean-version/1764031029?i=1764031281). The [original official artist release](https://www.youtube.com/watch?v=yycVNcishrE) describes a confident fashion premise; this batch uses the explicitly named Clean Version in the catalog.
- [Makeba — Apple Music](https://music.apple.com/us/song/1046165672). [Jain's Apple Music artist page](https://music.apple.com/us/artist/jain/334329603) identifies its worldwide success and musical context. The percussive recording is useful for visible contact and small rhythmic pose changes.
- [Memory Reboot — Apple Music](https://music.apple.com/us/album/memory-reboot/1663316684?i=1663317235). The [official Narvent video](https://www.youtube.com/watch?v=wL8DVHuWI7Y) identifies the collaboration and synthwave/retrowave style. The downloaded version is the original recording, not a slowed or ambient remix.

## Cue-map evidence and limits

`*.analysis.json` records STFT spectral-flux onset candidates at an 11.61 ms analysis hop. `*.edit-plan.json` refines the pulse from recurring strong accents, maps candidates to the proposed source offset, and records each nearest 30 fps picture frame and quantization error. These are measured editing candidates. They are not automatically confirmed downbeats, chorus boundaries or drops.

Cheri, Dancin and FΛSHION have recurring approximately half-second accents. Makeba's strongest repeating accents are roughly 1.034 seconds apart, compatible with a 116 BPM pulse. Memory Reboot's stronger repeating section supports both 162.76 BPM and its 81.38 BPM half-time reading. Its source 14.3848 s accent is a useful reveal candidate at scene 4.000 s with the proposed 10.3848 s start. The final director should choose fewer meaningful cues from these maps and check the exported playback.

## Reproduce and preserve

`fetch_music.py` resolves the five exact track IDs, downloads their public AAC previews and decodes PCM without creative audio changes. Re-running it can fetch a changed CDN asset; it must not silently replace a music master already referenced by a finished spec. Finished specs should always validate the saved PCM hash.

`prepare_edit_plans.py` makes the proposed scene-clock cue candidates from the saved analysis. `catalog.json` and each track's metadata preserve both raw and decoded hashes. Local audio stays inside `shorts/assets/music/batch01/`; the batch does not touch storytime voice, SFX or episode media.
