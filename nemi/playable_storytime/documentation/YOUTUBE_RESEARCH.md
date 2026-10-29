# YouTube playability and export research

Research date: 25 October 2026. Technical claims below use primary YouTube/Google sources. Platform documentation, tests on existing creator uploads, local fixture tests, and tests of this episode are different evidence classes.

## Feasibility decision

R6 uses panoramic observation puzzles with quick native number choices on desktop. The viewer looks for evidence inside the rendered sphere, finds a digit and presses it to open an authored outcome. YouTube handles the input through its percentage-seeking shortcut. Playback contains no executable game state. A change of viewpoint reveals different pixels without grading the answer or collecting an object.

The format supports discovery and alternative scenes while retaining an enjoyable passive route. Keep instructions short, introduce the first action promptly, and fold hints into story progression. Use conditional reaction lines rather than pretending to know what the viewer did. The final upload must work independently of the local review website.

## Confirmed native controls

YouTube documents current desktop Chrome, Firefox, Edge and Opera support, WASD rotation, a pan control, and click-and-drag viewpoint movement. It recommends the current YouTube app on mobile. This establishes supported platform behavior, not universal device compatibility. After upload, spherical processing can take up to an hour; check the pan control and rotation before publishing. [YouTube 360 upload/playback guidance](https://support.google.com/youtube/answer/6178631?hl=en-GB)

Desktop number keys are the primary R6 choice input: 1–9 seek to 10–90%, and 0 restarts. The viewer must click the video player before using shortcuts; instructions recommend the top-row digits. K plays/pauses and C toggles available captions. Do not depend on a seek automatically resuming a paused video. [Keyboard shortcuts](https://support.google.com/youtube/answer/7631406?hl=en)

Episode 001 R6 deliberately locks its full runtime to **240.000 seconds**, with ten **24-second** slots. Keys 3, 6 and 9 land at 1:12, 2:24 and 3:36; retry keys 1, 4 and 7 land at 0:24, 1:36 and 2:48. Optional hints use 2 and 8; the wrong-choice pudding scene uses 5. The exact final file must preserve this duration. Adding a logo, outro or padding without rebuilding the key map breaks the controls.

On mobile, use the current YouTube app for viewpoint movement and select the matching numbered chapter. YouTube exposes chapters through the player chapter title and description. This is a separate menu interaction; a number printed in the picture is not a touch button. Description timestamp links and the progress bar remain recovery options. [Seeking and chapter selection](https://support.google.com/youtube/answer/12825599?hl=en)

Chapters start at 00:00, contain at least three ascending markers, and require at least ten seconds per chapter. Access can depend on channel eligibility. A description timestamp/manual scrubbing fallback must remain usable when chapters are unavailable. [Chapter requirements](https://support.google.com/youtube/answer/9884579?hl=en)

Conventional end screens are unavailable on 360 videos. They are not a route mechanism for this engine. [End-screen restrictions](https://support.google.com/youtube/answer/6388789?hl=en)

## Creator reference observations: actual desktop YouTube tests

These observations were made on the real YouTube pages in a desktop browser on the research date. They do not prove our episode has passed YouTube processing.

| Reference | What was inspected/tested | Result and limit |
| --- | --- | --- |
| [Firerama: This Video is a Game — Interactive Maze](https://www.youtube.com/watch?v=_luzD0pMb3o) | Actual player, opening instruction, description, spherical widget; paused at 00:18 and held A for 600 ms | The maze visibly rotated while the timestamp stayed at 00:18. Opening said to enable captions; the accessibility tree exposed a square caption reticle. No collision or item-collection detection was observed or claimed. |
| [Lagarto Films: YOU CONTROL THIS VIDEO WITH YOUR KEYBOARD](https://www.youtube.com/watch?v=Uq-MfY981i4) | Actual 10:00 upload, its description and chapters; pressed 3 with player focus | Player moved to 03:00 and chapter “3 - PINK.” Description maps 1–9 to nine experiments at 01:00–09:00. This is native percentage seeking, not custom keyboard code in the movie. |

Firerama's description also links a mobile-friendly time-skip playlist. That is creative precedent, not evidence that every spherical/caption interaction works on every phone. The reusable lesson is to explain an honest control contract quickly, let viewers enforce a challenge rule, and reward exploration with authored scenes. We do not copy their layouts, puzzles, footage or soundtracks.

## Captions: useful accessibility, unsuitable essential game state

YouTube accepts WebVTT positioning with limited text styling and supports some TTML styling/positioning. Caption appearance is viewer-configurable, and captions can be disabled. These are timed text features, with no documented cross-device caption-drag callback, clickable answer button or game-state interface. R6 retains conventional dialogue captions; essential clues remain in scene art and narration. C/CC may reveal an optional hint, but the essential route must work with captions either on or off. [Supported caption files](https://support.google.com/youtube/answer/2734698?hl=en), [viewer settings](https://support.google.com/youtube/answer/100078?hl=en)

The IFrame API exposes spherical view properties to JavaScript on an external website, with device limitations. That requires a surrounding application and does not make an ordinary YouTube upload execute puzzle logic. It is deliberately excluded from essential gameplay. [Official IFrame API](https://developers.google.com/youtube/iframe_api_reference)

## Genuine spherical frames and metadata

A full monoscopic equirectangular frame covers 360° horizontally and 180° vertically, using a 2:1 image. The forward direction is at the image center; poles are at the top and bottom. Important clues belong near the horizon, with large readable forms, seam clearance, and multiple orientation hints. A 16:9 rectilinear review shows one viewport and must not be mislabeled a spherical upload file.

Google's current V2 metadata places `sv3d` inside the video sample entry. Its `svhd`, `proj`, `prhd` and `equi` describe source, orientation and projection. Uncropped equirectangular bounds are zero. `st3d` mode 0 represents mono. Equivalent V1 metadata can coexist, with V2 taking priority. [Google Spherical Video V2 specification](https://github.com/google/spatial-media/blob/master/docs/spherical-video-v2-rfc.md)

V1 uses the video track's `uuid` atom with identifier `ffcc8263-f855-4a93-8814-587a02521fdd` and namespaced UTF-8 spherical XML. Required fields mark the image spherical, stitched and equirectangular and identify the software. Generic comment tags are insufficient. [Google V1 specification](https://github.com/google/spatial-media/blob/master/docs/spherical-video-rfc.md)

The isolated exporter `tools/spatial_metadata.py` writes V2 plus equivalent V1 by default. It changes only `moov`, preserves media samples, and adjusts `stco`/`co64` offsets when metadata growth moves subsequent media. It preserves faststart layout. It refuses fragmented/indexed MP4s and unsupported video sample entries rather than silently damaging offsets. This small implementation is independently written from the published specification; a network attempt to retrieve Google's package failed DNS resolution, so no unpinned third-party code was installed. Google's own injector remains a useful reference implementation. [Official injector source](https://github.com/google/spatial-media/blob/master/spatialmedia/__main__.py)

Use progressive H.264 High Profile, 4:2:0, AAC-LC stereo at 48 kHz, BT.709 and faststart. Keep the authored and encoded frame rate the same. High spherical resolution improves the smaller visible viewport; exact render dimensions are production choices, subject to the full-1080p approval gate before 4K. [YouTube encoding recommendations](https://support.google.com/youtube/answer/1722171?hl=en)

## Evidence ledger

| Capability | Official documentation | Existing reference upload tested | Local implementation tested | Our episode on YouTube |
| --- | --- | --- | --- | --- |
| Desktop 360 viewpoint | Confirmed | A rotation on Firerama confirmed | Preview implementation supplied; browser visual review separately recorded | Not verified |
| Native number choices | Confirmed | 3 → 03:00 on Lagarto confirmed | R6 targets specified on the exact 240-second grid; current validation is recorded in QA | R6 upload not verified |
| Metadata injection | Google V1/V2 specified | Not applicable | Eight exporter tests passed, including actual FFmpeg faststart/end-moov fixtures | Not verified |
| HTTP byte-range seeking | Standard local server feature | Not applicable | Four handler tests passed: range/suffix, invalid range, default document, traversal denial | Not applicable |
| Phone swipe/orientation | Supported app guidance; device-dependent | Not tested | Pointer/touch handlers implemented; actual device test pending | Not verified |
| Caption game-object movement | No reliable cross-device contract established | Square reticle observed only | Excluded from essential mechanics | Not verified |
| Automatic collisions/answer grading | Not provided by an uploaded MP4 | Not observed | Deliberately absent | Unsupported |

Test command: `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s nemi/playable_storytime/tests -p 'test_spatial_metadata.py' -v` (8 passed), and the same command with `test_preview_server.py` (4 passed). Real fixtures used 160×80 video for metadata preservation; they are technical fixtures, not episode-quality proofs. Decoded video hashes and complete `mdat` sample payloads matched before/after injection, including the encoded audio samples. FFprobe detected spherical side data.

Actual loopback HTTP checks also passed: the preview returned 200, forward and suffix MP4 byte ranges each returned 206 with exactly 32 requested bytes, and an outside-project traversal returned 404. Browser picture/input review and real mobile tests are separate. Detailed results are saved in `EXPORT_PREVIEW_TEST_RESULTS.json`.

## Required upload verification

The exact R6 upload, real mobile app and complete R6 playback remain unverified until their checks are recorded. After the complete current 1080p review has earned explicit user satisfaction, produce the approved high-resolution spherical master. Use an authorized unlisted workflow if available; public publication requires explicit authorization. Wait for spherical and high-resolution processing. Confirm the actual upload's pan widget, default direction, WASD/drag and all digit landings 0–9. Exercise PRESS 3/6/9, retries 1/4/7, hints 2/8 and wrong choice 5 with the player focused, including a paused choice followed by K/Play. Check clue readability after compression, conventional captions and sound. Test numbered chapter selection and swipe on real current Android/iPhone apps when available, recording device and version. Exercise passive, success, wrong, retry, exploratory and unexpected-orientation paths. Local checks establish preparation; only testing the actual processed upload establishes its YouTube behavior.
