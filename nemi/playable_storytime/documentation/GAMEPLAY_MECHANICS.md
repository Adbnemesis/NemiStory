# Playable mechanics and interaction contracts — R9

R9 is an original fictional story about Nemi signing a school volunteer form because it promised free pudding, then discovering that she volunteered to host. Her dialogue runs in connected conversational thoughts; instructions arrive as requests inside the embarrassment. Sandwich, stationery-cupboard and school-furniture detours develop the same predicament.

The viewer makes **three named choices**. Teach one practice press first, then show only the current options. A label states the result before the viewer acts: “3 — Use star badge” opens “3 — Badge found.” The movie supplies authored routes; it does not detect answers, store inventory or know which object the viewer inspected.

## One repeated interaction

1. Look at the current objective and two options.
2. On desktop, focus the video picture and press one displayed top-row number once. On the YouTube app, select the matching numbered chapter.
3. The destination opens with the same number, route name and a visible result. If paused, K / Play resumes.
4. A result supplies one clearly labeled continuation. Choose it when ready, or keep watching for the complete story.

The first practice offers only **1 — Start: badge round**. It must teach all necessary controls before asking the viewer to jump. Do not expose ten route labels as the main game interface. Captions remain ordinary dialogue captions, and the final movie contains no clickable drawn buttons.

## Episode 001 route map

| Key | Exact start | Arrival |
| --- | --- | --- |
| 0 | 0:00 | PRESS 1 |
| 1 | 0:24 | BADGE OR LUNCH |
| 2 | 0:48 | SANDWICH ROUTE |
| 3 | 1:12 | BADGE FOUND |
| 4 | 1:36 | CHOOSE THE ROOM |
| 5 | 2:00 | PUDDING ROUTE |
| 6 | 2:24 | ASSEMBLY REACHED |
| 7 | 2:48 | HIDE OR HOST? |
| 8 | 3:12 | HIDING ROUTE |
| 9 | 3:36 | ON STAGE |

The three rounds offer **2 — Inspect sandwich / 3 — Use star badge**, **5 — Try pudding room / 6 — Go to assembly**, and **8 — Hide in plain sight / 9 — Take the microphone**. These are genuine authored alternatives with matching arrivals. Sandwich, pudding and hiding are comic routes with simple continuations, rather than a separate hint/retry vocabulary. Result continuations are 3, 4, 6, 7 and 9; the ending offers 0 to play again.

The passive sequence covers every section and still tells a coherent story. A joke must acknowledge passive arrival when necessary; never claim the movie detected a choice. The interactive direct path is 0→1→3→4→6→7→9. Optional paths include 1→2→3, 4→5→6 and 7→8→9.

## Exact native control contract

YouTube documents desktop digits 1–9 as 10–90 percent seeking and 0 as restart. Episode 001 is locked to **240.000 seconds, 30 FPS and 7,200 frames**, so each numbered landing starts 24 seconds apart. Validate `actual encoded duration × digit / 10` against the final movie. An appended intro, outro, logo or padding changes every destination. [Official shortcuts](https://support.google.com/youtube/answer/7631406?hl=en)

Mobile viewers use a current YouTube app to swipe, then choose the matching numbered chapter through its chapter list or description. That is a separate native menu action, not a touch target inside the movie. Chapter availability depends on the channel/player. Keep recovery chapter links in the description. [360 playback](https://support.google.com/youtube/answer/6178631?hl=en), [chapter selection](https://support.google.com/youtube/answer/12825599?hl=en)

## Arrival and orientation contract

Viewpoint direction survives native seeking. A viewer facing the sandwich must still recognize the badge result after pressing 3. Put the same short number/result confirmation on all four wall directions, followed by a clear landmark for returning to Nemi. R9 uses a compact front receipt beside the continuously visible performer and larger peripheral receipts; directed camera framing must keep a receipt readable during its hold. Do not rely on the viewer facing the default front or on a local recenter helper. Show result feedback before the next task and keep its promise consistent in narration, artwork, chapter name and local status.

Each `interaction_scenes` item declares `id`, `start`, `end`, `objective`, `feedback` and its current `choices`. Each choice supplies `key`, plain action `label` and target `chapter`. The ten navigation destinations bind those chapter IDs to the percentage clock. Validate every target and printed/spoken action together. A correct timestamp with a confusing or hidden arrival is a user experience failure.

## Local review player

Launch `PYTHONDONTWRITEBYTECODE=1 python3 nemi/playable_storytime/previews/serve.py --port 8768`, then open `http://127.0.0.1:8768/previews/`. Load the actual encoded tagged sphere with its matching timeline. The standard director review is a flat inspection movie; playing it in an ordinary media player does not provide the game controls.

The retained local player implements keyboard handling across the focused viewer, matching media/timeline identity, a seeking cover and confirmation after the requested frame is available. Stale media cannot accept current-game choices. It uses its own HTML Play/progress/mute controls because native WebView video controls swallowed digits; choice clicks return focus to the panorama. Those buttons and recentering are local review conveniences, not features uploaded with the MP4.

Historical R7 browser checks passed for keys after controls, choice clicks, pause/resume and route arrivals. Fresh actual R9 browser checks remain pending; the earlier results do not validate this new movie/timeline pair. Exact YouTube controls, physical mobile behavior and complete continuous playback/listening are also pending. The earlier responsive override yielded a 645-pixel browser, not verified phone-size behavior.

## Review the experience, not only the map

| Path | Required observation |
| --- | --- |
| First visit | A person follows the practice without knowing percentage seeking; instructions precede the jump. |
| Direct route | Each of three choices names the scene that arrives; one task and at most two options are current. |
| Comic routes | Sandwich, pudding and hiding arrive as promised and show one clear way forward. |
| Passive | The full story is coherent without input and does not blame the viewer for an unmade choice. |
| Facing away | Every landing remains understandable from front, left, right and back; Nemi is recoverable. |
| Focus and seeking | Play/control clicks do not silently disable local keys; old pixels are not presented as arrival. |
| Mobile | Real YouTube app chapter choice reaches the same named outcome; a resized window is not a phone test. |

Retain conventional captions. C / CC toggles available captions; essential choices also exist in picture and narration. Caption dragging, custom input callbacks and automatic answer evaluation are not supported contracts. YouTube end screens are unavailable on 360 videos. [Caption settings](https://support.google.com/youtube/answer/100078?hl=en), [end-screen limits](https://support.google.com/youtube/answer/6388789?hl=en)

Save source hashes, actual media checks, performed playback results and device details. Source validation and sampled stills are technical evidence; user clarity and enjoyment require the complete experience to be played and reviewed.
