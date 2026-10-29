# Repeatable production pipeline

Run commands from the repository root. All new source, dependency copies, caches and outputs remain under `nemi/playable_storytime/`. Read the current Nemi production guidance and complete an episode-specific preflight before authoring. Never treat another episode's reading or approval receipt as reusable evidence.

## 1. Preserve and inspect

Compare the existing isolation baseline with `tools/isolation.py check`; do not replace it to hide a detected change. Keep canonical rigs/voice copies byte-identical. Before a material revision, preserve the previous movie, script, voice, timeline and QA under revision names. Bootstrap verifies the frozen dependencies instead of silently taking future changes from the normal storytime workflow.

## 2. Author the viewer's action and expectation

Save the promise/want/choice/consequence/payoff, thought beats and dialogue. R9 begins with one practice, then three two-option rounds. Each action label names its destination; each destination begins with the same number/name and a visible consequence. Result sections offer one continuation. Do not expose a ten-key route table as the primary game interface or require a separate hint/retry vocabulary.

Episode 001 uses exactly 240 seconds, with ten 24-second sections. The map is practice0; badge choice1; sandwich2; badge result3; room choice4; pudding5; assembly6; final choice7; hiding8; stage9. The direct route is 0→1→3→4→6→7→9. Comic paths merge through 2→3, 5→6 and 8→9. Passive playback must remain coherent without claiming a detected choice.

Declare `interaction_scenes` with objective, current choices and feedback. Each choice names a key, action label and target chapter. Validate the percentage clock, labels, artwork, narration and arrival together. Teach focus, looking and mobile chapter selection before the first requested jump. The movie cannot wait indefinitely for a key press, detect an answer or make a drawn button clickable.

Use short result receipts across all four wall directions because native viewpoint orientation survives seeking. R9 keeps Nemi visible beside the compact front receipt; larger side/back receipts retain orientation guidance. Hold director framing wide until the receipt can be read. A front-only result is insufficient when the clue was behind Nemi. Establish stable landmarks and an understandable way back to the narrator. Keep one audience focus, concise directions and purposeful search/comic holds.

Write an actual story before breaking it into inputs: connected thoughts, a specific temptation, an escalating consequence and a payoff. R9 uses ten longer connected takes rather than thirty chopped instructional clips. Numbers remain brief, concrete requests. Do not announce every scene as a route or round in narration.

`python3 nemi/playable_storytime/tools/prepare_episode.py --episode PATH` builds dialogue, spatial timeline and interaction contracts; after final voice exists, it compiles the version-2 stage, mouths, captions, camera and event-linked sound. Author `acting_beats` against exact measured words with varied supported motion/gaze/face/hands, and chapter `camera_beats` for whole-world director yaw/pitch/FOV. The frozen render validator independently checks camera bounds and transition ownership. Optional chapter headings/props can be omitted; use bounded `additional_props` and held/live evidence only when the thought needs them. See `engine/godot/SCHEMA.md`.

## 3. Prepare canonical voice and sound

Use the existing `.venv/bin/python` for `voice.py setup-models` and `voice.py generate --episode episodes/episode_001`, substituting the new episode when appropriate. Cached exact models and unchanged Sohee identity settings are retained. Source/final clips have hashes; narration that exceeds authored windows is rejected rather than truncated.

Review pronunciation, inflection, prolonged gaps and joke timing. Edit pace through phrase-specific pitch-preserving tempo or explicit source bounds, keeping breaths and emotional holds. Re-align final audio and rebuild dependent mouths, caption cards, gestures, camera and sound events. ASR words are approximate alignment, not a phoneme or listening verdict. Use existing recorded SFX with honest provenance and any authorized music; recalibrate and measure encoded peaks after changes. R9 retains the canonical Sohee identity, phrase-specific 1.08/1.12 tempos and seven explicit quiet source cuts totaling 5.5 seconds across the host and stationery passages. The cut plan records source bounds, hashes, energy and reasons; it does not blanket-trim silence or prove natural delivery. Rebuild all dependent timing from final edited audio.

R9 uses only four short original piano phrases (13 notes, about 9.48 seconds with nonzero samples). The HOST reveal, pencil discovery, school-furniture freeze and final pudding callback have protected music silence. This is sparse punctuation, not a repeating bed. Existing recorded event SFX remain separate; listen to the final exported mix before claiming audibility or comic timing.

## 4. Validate source and runtime

Run `validate_episode.py`, then `render.py --validate-only --mode review --output NEW_PATH.mp4` for full frozen production validation. Run relevant tests after material changes. A passing percentage equation establishes timing; it does not establish clear instructions, a visible arrival or an enjoyable experience.

Local player checks must include source identity, keyboard focus after Play/control clicks, feedback while seeking, and actual arrival after decode. Show only current actions. Do not silently accept current-game choices against a stale or mismatched movie. Local buttons are review conveniences; native YouTube behavior is checked separately. Actual current R9 local checks passed for number keys, choice buttons, Play/progress, K pause/resume, main/comic routes, preserved viewpoint, rapid choice ownership and old-movie rejection. Evidence: review/r9_browser_route_checks.json under Episode001. Exact YouTube behavior, physical mobile testing and full continuous playback/listening also remain pending. The local player retains its own HTML Play, progress and mute controls because native WebView video controls swallowed digits. Those controls do not accompany the uploaded MP4. The earlier responsive override produced an effective width of 645 pixels, not verified phone-size behavior.

## 5. Render short and integrated reviews

Render a fresh ten-second mechanism proof and a 30–60 second integrated sequence. Inspect stills and playback for Nemi identity, expression/body progression, wrists, hands, feet, contact, recognizable settings, stable held ink, finite effects, readable prompts and event-linked audio. Check the first practice and the consequence immediately after a choice. Correct issues before the complete export.

## 6. Render complete review movies

Render the full director review at 1920×1080 and the mono equirectangular review at 2160×1080. Verify the actual 240.000 seconds, 30 FPS and 7,200 decoded frames for Episode 001 R9, plus H.264 4:2:0, AAC 48 kHz, audio headroom, no black gaps and current source/input hashes. Use new revision filenames; preserve earlier movies. Save capture logs/reports under `review/render_records/` and the movie index under `review/RENDERS.md`.

Inject equivalent V2/V1 spherical metadata into a new file, inspect it and confirm encoded media samples are preserved. A correct metadata parse is separate from correct panoramic pixels and actual YouTube processing.

## 7. Check encoded landings and the complete experience

Use `tools/digit_media_qa.py --episode EPISODE_PATH --video TAGGED_SPHERE_PATH --output NEW_REPORT.json` to compare actual duration/FPS against each number destination and save sampled frames. Inspect the current helper's captured scope; add manual views where result cards or changed scenes need broader evidence. Do not append runtime after checking the digit map.

Play the practice, direct route, all three comic routes and the passive story. Repeat jumps from front, left, right, behind and between those directions. A reader must understand what action is offered, what just happened and what to do next. Look for focus loss, stale pixels during seeking, hidden results and unexplained automatic transitions. Check both small text readability and full-body contact shots.

Listen through the complete cut for pronunciation, music/voice balance, audible event SFX and pauses. Record performed checks, failed expectations and remaining limits honestly. Source inspection, automated listeners and contact sheets are not complete first-time-user testing. R9 full listening and exact YouTube/mobile playthrough remain pending until actual evidence exists.

## 8. Obtain complete-review satisfaction, then export 4K

Deliver the complete current 1920×1080 cut. The Nemi storytime workflow explicitly requires the user's satisfaction with that exact full movie before any 4K episode proof/master. Technical checks, an excerpt or an earlier cut do not qualify. Bind the actual user quote, scene/input hashes and full preview/report hashes in the receipt; material changes invalidate it.

Then render the native 3840×1920 sphere through `render.py --mode sphere --4k`, inject metadata into a new upload filename and repeat media/readability checks. Never invent an approval quote or silently upscale a review movie.

## 9. Verify the actual platform and package

An authorized unlisted upload of the current tagged review sphere can establish compatibility before 4K approval. Final public delivery still waits for approved media and explicit publication authorization. Scoped R9 local-browser route/control checks passed. Unlisted upload, native YouTube behavior, compressed readability, physical mobile chapter availability and full continuous playback/listening remain pending until recorded.

Wait for YouTube 360 processing, then test the actual native controls and every named result. Test the practice with a fresh viewer, player focus, paused K/Play recovery and non-front arrival. Test a real current YouTube mobile app, not only a narrow browser window. Save URL, uploaded-file hash, device/browser/app versions and results. Use matching numbered chapters, description, conventional captions and the user-selected thumbnail. Keep alternatives until selection.

Official basis: [number controls](https://support.google.com/youtube/answer/7631406?hl=en), [360 verification](https://support.google.com/youtube/answer/6178631?hl=en), [chapter selection](https://support.google.com/youtube/answer/12825599?hl=en).

## 10. Preserve evidence and hand off

Recheck isolation. Retain voice, script, source assets, hashes and QA. After the approved final 4K replacement passes checks, apply the episode-scoped final-only movie retention preference; logs and QA belong outside `renders/`. Do not clean unrelated episodes. Review source sizes/secrets before a normal authorized Git push; exclude generated media, model weights and caches.

The conversational rewrite began in R8. R9 keeps its identical voice, performance, music and mix, shortening all front receipt subtitles to at most 32 characters after full-cut inspection found two spilling outside the compact cards. The previous cut and exact source snapshot are retained; the frozen-input guard rejected the stale sphere when source preparation overlapped that earlier capture. Current delivery must use only the completed R9 reports.
