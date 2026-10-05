# Four supplied Shorts — measured reference study

Analyzed 2026-10-05. Source filenames and SHA-256: `review/references/manifest.json`. Evidence for each: half-second contact sheets, adjacent-frame boundary sheets, per-frame luma deltas, STFT onset measurements, waveform, draft transcription, annotated pulse/event CSV and editorial JSON. Source files remain untouched. Playback was opened in the local review player; boundary images were separately inspected. Transcription is a tiny local Whisper draft, unreliable on singing and foreign-language vocals. It is not an approved dialogue transcript.

## Measurement limits and terminology

Container duration includes audio tails; decoded video duration is frame count / FPS. “Layout” counts a new drawing, deliberate crop, dark text card or costume switch. A two-frame dark card counts as a layout, not a new narrative scene. Motion peaks alone do not count as cuts. Boundary timestamps marked ~ are transitions with multiple changed frames; others are inspected adjacent-frame anchors. No view/retention statistics were supplied: the following explains craft, not proven virality. Compression and camera transforms prevent duplicate-frame statistics from establishing the original drawing cadence. Stem levels, exact downbeat phase, audio source speed and source SFX cannot be recovered confidently from these mixed downloads. No invented dB separation is presented.

| Ref | Format duration | Decoded picture | Resolution / ratio | FPS | Approx layouts / boundaries | Average / shortest / longest layout | Pulse estimate |
|---|---:|---:|---|---:|---:|---|---|
| 01 campus transport | 13.792653s | 13.733333s / 412f | 480×854 / 0.562 | 30 | 13 / 12 | 1.056 / .700 / 2.267s | ~130 BPM, also 65 half time |
| 02 mother argument | 19.157333s | 19.100000s / 573f | 360×640 / 9:16 | 30 | ~39 / 38 incl dark cards | .490 / .067 / 1.600s | ~120 BPM |
| 03 distant crush | 20.949333s | 20.900000s / 627f | 360×640 / 9:16 | 30 | ~16 / 15 | 1.306 / .900 / 1.767s | ~92 BPM, strong 184 double-time ambiguity |
| 04 trust/tool dance | 17.879365s | 17.800000s / 267f | 720×720 / 1:1 | 15 | 7 / 6 main layouts | 2.543 / .533 / 3.733s | ~137 BPM; 68.5 half time |

“Major transition” depends on counting: 01 uses about 12 snap changes/reframes plus a shake near 1.93; 02 contains about 38 cards/changes but roughly 10 conspicuous blur/wipe/flip passages; 03 has 15 changes, around 5 with pronounced sweep/dissolve emphasis; 04 has six principal tool/plane wipes. Evidence remains available to revise editorial counts.

## Ref 01 — campus transport

### Picture and event timeline

| Seconds / frame anchor | Audience focus / event |
|---|---|
| 0–.30 | Full standing/walking figure and readable situation caption are already present. No intro. |
| .30–1.167 / f35 | Slow scale/position change on held walk art; setup readable by .5–1s. |
| 1.167–1.933 | Cut to close reaction, small frustration doodle; camera continues push. |
| 1.933–2.600 / f78 | A sharp jitter/blur reinforces reaction; this is not a separate drawing cut. |
| 2.600–3.300 / f99 | Backpack reverse angle, warning bubble; direction establishes approaching hazard. |
| 3.300–4.300 / f129 | Duck/recoil pose, moving passer and horizontal streaks. Anticipation becomes consequence. |
| 4.300–5.033 / f151 | Hoverboard full-body reveal; wheels/contact remain visible. |
| 5.033–5.967 / f179 | Rider warning close view; mouth/eye attitude supplies the joke. |
| 5.967–6.867 / f206 | Skateboard full shot; stretched stance communicates speed. |
| 6.867–7.833 / f235 | Match punch into skateboard rider's face, same direction. |
| 7.833–8.700 / f261 | Scooter full pose; deliberately unusual seated posture. |
| 8.700–9.667 / f290 | Scooter face crop, hold expression. |
| 9.667–10.467 / f314 | Bicycle reveal, wheel dominates lower frame. |
| 10.467–11.467 / f344 | Bicycle face crop: final attractive rider is a visual variation. |
| 11.467–13.733 | Small simplified distressed protagonist, purple stress marks. Escalation resolves in reaction, not outro. |

### Audio and sync

Music identification candidate: LMFAO, *Sexy and I Know It*, from local vocal transcription and title/lyric matching; source speed/version unverified. The measurable late pulse is ~.462s; subdivisions ~.231s. Example grid: 4.911, 5.373, 5.834, 6.296, 6.757, 7.219, 7.680, 8.142, 8.603, 9.065, 9.527, 9.988, 10.450, 10.911, 11.373. Stronger rhythmic passage starts around 4.91. Cuts are **not all exact beats**: f151 at 5.033 is ~122ms after 4.911, f179 at 5.967 is ~132ms after 5.834. A recurring two-pulse transport/reaction alternation creates musical coherence without quantizing every cut. Read `ref01/event_beat_map.csv` for all deltas. Downbeat/bar phase is inferred, not verified. No separate spoken dialogue is established. Warning bubbles are drawn speech, not confirmed recorded speech. Mixed waveform does not establish isolated whoosh/impact gains.

### Art, acting, camera, text and retention

Thin variable sketch contours, gray paper/vignette, angular anime eyes, long limbs and sparse facial shadow. Transport objects carry the environment; otherwise background is almost empty. Hair/ears/clothing lines are detailed in close drawings, while the final stress pose becomes small and simplified. Movement is predominantly held art with continuous camera push, directional smear/streak at the near-collision, and drawing swaps. No evidence supports 60 FPS drawing or blanket animation on twos. Camera remains active during holds, but it moves gently rather than shaking continuously; maximum strictly static interval cannot be separated from small encoding noise. Opening hook is a caption-backed relatable problem; first major change at 1.167. Meaningful layouts average ~1.06s, faster .7–1s montage, then 2.267s payoff hold. Fixed lower-middle, white rounded sans text with black outline explains the situation; transport bubbles are secondary authored art. Ending differs from opening pose and framing: semantic replay, not seamless visual loop. Suitable ADB technique: grounded full-shot reveal → deadpan face crop. Suitable Nemi: readable eye reaction and selective stressed miniature. Avoid borrowing exact vehicles/characters/joke.

## Ref 02 — mother argument

### Frame-level editorial timeline

0–.667: bag-face protagonist holding apology sign; words change immediately (first 3–8 frames contain motion). .667–1.933: sunglasses parent close-up; vocal phrase and mouth gestures drive the cut. 1.933–2.067 (f58–62): dark word card → couch entrance. 2.067–2.500: character enters couch composition. 2.500–2.600 (f75–78): dark interruption → seated game pose. 2.600–3.000: seated game pose. 3.000–3.067 (f90–92): dark card → teal couch variation. 3.067–3.400: seated pose; 3.400–3.900 dark-card passage; 3.900–3.967 upside-down pose flash; 3.967–5.500: family gesture, couch, dropping/sinking figure. 5.500–5.967: parent; 5.967–7.000: child front, unhappy face, raised hands. 7.000–8.600: parent gesturing, close → broader framing. 8.600–8.667: iris/object wipe passage; 8.667–9.067 parent full; 9.067–9.567 shoe insert including blur at9.167; 9.567–10.433 hooded dark figure with face scribble. 10.433–10.833 parent flip/blur; 10.833–11.267 child full. 11.267–11.667 face push; 11.667–12.067 hoodie with red backdrop; 12.067–12.167 orange/costume passage; 12.167–12.433 graduation costume; 12.433–12.567 bag; 12.567–12.667 hoodie; 12.667–12.800 graduation; 12.800–13.067 casual; 13.067–13.433 hooded dark variants. 13.433–13.567 casual; 13.567–13.667 bag; 13.667–13.800 bag continuation; 13.800–14.233 graduation close; 14.233–14.967 approving figure; 14.967–15.800 graduation face with punch/blur; 15.800–16.233 dark stressed face; 16.233–17.500 graded-paper montage; 17.500–18.167 eye close with paper overlay; ~18.167–19.100 child surrounded by papers.

Some costume switches count as separate layouts while motion/repeated bag holds do not; ~39 layouts is an editorial estimate. First .3s: unusual bag face + sign + word. .5s: apology situation. 1s: relationship cut clarifies recipient. 2s: couch symbolism turns words into a visible scenario.

### Audio / mix / music-to-picture

Likely *I'm Sorry Mom* by Marino, based on local draft vocals and title lookup; no source stem/version confirmation. ~120 BPM/.5s quarter, .25s eighths, with frequent .125s word/costume runs. Representative pulse: .156, .656, 1.156, 1.656, 2.156, 2.656, 3.156, 3.656, 4.156. Actual onset samples include .6502, .9172, 1.1610, 1.3816, 1.6486. Vocal accents often matter more than the nearest quarter: parent cut .667 aligns within ~17ms of onset .650; the intense 12–14s costume run uses several sub-beat changes. Dark cards remove visual detail while preserving the focal word. Flip/blur occurs between accented landings, not indiscriminately on each drum. Vocals lead understanding; instrumental bed remains persistent. Separate diegetic dialogue/SFX levels cannot be measured from this mixed file. Do not treat sung parent/child voices as our characters' dialogue or change approved character voice.

### Visual and motion grammar

Flat vivid pink/orange/teal backgrounds, dark cool couch/hoodie, restrained shadows. Thick, rough contour, rectangular bag-face substitute, simplified anime face, readable hand silhouettes. Mostly expression/mouth swaps and pose snaps; selected full-body entrances and tool/paper movements. Directional smear/blur, perspective flips, wipes, RGB edge separation and extreme face crops are selective accents. Longest layout is ~1.6s, though words/hands change inside it. Fully static picture intervals occur as short holds; 5.6% near-duplicate frames are evidence of holds but not original drawing FPS. Captions: central bold uppercase sans, white or teal emphasis, roughly one emphasized word at a time, often over upper chest/face. Caption cadence can be faster than shot cadence. Payoff unfolds as costume expectation vs struggling grades in final third; ending is a continued phrase and papers, not matching opening. Reuse vocal-cue-driven cuts, contrast palette, meaningful costume/prop escalation; avoid .067s identity flashes where our joke needs comprehension. This density suits a brief Nemi breakdown, not ADB's baseline.

## Ref 03 — distant crush

### Picture timeline

0–1.633/f49: blushing standing protagonist, fixed explanatory caption. 1.633–2.667/f80: speaking crush and anonymous figures. 2.667–4.133/f124: attractive face close, camera drifts. 4.133–5.200/f156: turn/cut to cap wearer and anonymous person; 5.200–6.733/f202 close reverse cap view. 6.733–7.933/f238: tiny happy protagonist; 7.933–9.367/f281: head down/hair-covered, scale communicates withdrawal. 9.367–11.133/f334: flustered hand-to-mouth close. 11.133–~12.033/f361: shame miniature (transition boundary). ~12.033–~13.167/f395: crowd view / dissolve; ~13.167–14.500/f435: bored half-lidded woman close. 14.500–~15.700/f471: opposite-facing full figures; ~15.700–17.200/f516: strained smiling reverse view. 17.200–18.367/f551: nervous protagonist with hands near face. 18.367–19.733/f592: startled greeting/recoil burst. 19.733–20.900: split reaction and normal crush face. Ending embodies the title's disappointment; no seamless frame loop.

### Music, acting and sound

Mixed melodic vocal track, identity/language not reliably recognized by tiny Whisper. STFT candidates 184.57, 92.29 and 123.05; select ~92 pulse with .326 subdivisions for annotation and retain ambiguity. Example pulse .035, .687, 1.339, 1.992, 2.644, 3.296, 3.948, 4.600; later subdivisions have stable .162–.174 intervals. Some cut anchors are close to onsets:2.667 vs2.6935 (~27ms),9.3667 vs9.3693 (~3ms),19.7333 vs19.7137 (~20ms). Other cuts serve pose comprehension rather than beat landing. No confidently isolated dialogue/FX event; a printed greeting at18.367 cannot be called an audible shout without confirming it. Phrase/drop markers are unknown, not fabricated.

### Style / camera / retention

Same sparse sketch/paper/vignette family as01. Slender silhouette; soft blush hatching, narrowed eyes, baggy layers. Faceless extras reduce competition. Several reaction miniatures contrast large romantic close-ups. Camera pushes/slides or holds drawings; completed linework remains stable. Some sweeps have blurred departing art; dissolve/ghost at crowd changes. No photographic background, bloom, reactive hue or constant particles observed. Fixed lowercase rounded sans situation caption spans ~three centered outlined lines; occasional authored speech/expression marks are supplementary. First .3/.5/1s shows blushing character + situation; curiosity depends on relatable caption, not a new cut. First new drawing at1.633. Average layout1.306s; first setup survives a1.63s hold, strongest late interruption greeting18.367 then split payoff19.733. Movement frequency alone would miss the buildup. Reuse small/large reaction contrast and a quiet held face before payoff. Avoid their exact romance premise; no proof of frame interpolation or twos.

## Ref 04 — trust/tool dance

### Timeline and frame anchors (15 FPS)

0–.3: tiny line-art cartoon already dancing. .3–1.067: limbs/face redraw with varied poses. 1.067–2.667: tool spins above character; character reaches. 2.667–3.000: tool becomes dominant; 3.000–3.467: tool turns and grows; 3.467–3.733/f56: tool smear fills foreground → colored kitchen plane. 3.733–7.400/f111: extended tool, body/expression cycles; plane skews/rocks inside gray corners. 7.400–10.133/f152: tool wipe reveals reverse restaurant plane; character reacts, blink and stance change. 10.133–10.933/f164: airborne spinning environment. 10.933–14.533/f218: kitchen cycle repeats. 14.533–17.267/f259: reverse plane cycle repeats. 17.267–17.800: flight repeat, cut off during movement.

### Audio mapping

Likely Pandora, *Trust Me*, from local vocal draft/title matching; independent tempo lookup also suggests137, but use measured local timestamps. Quarter~.438, eighth~.219. Onsets .0580,.2554,.4760,.6966,.9172,1.1262,1.3468. Build change around3.733 aligns onset3.7616 within28ms and introduces color/setting on the sung hook. Tool reverse wipe7.400 is between onsets7.2678 and7.4884: transition begins before the next landing. Flight10.133 aligns10.1123 within21ms. Return10.933 aligns10.9946 within62ms at coarse15fps resolution. Repeated layout transitions separated by~7.13s preserve phrase structure. Continuous music/vocals, no verified spoken cartoon dialogue. Bubbles/tool action could have SFX, but source isolation is unavailable. No fabricated whoosh gain.

### Art / motion / loop

Black line-art first section switches to recognizable detailed colored cartoon settings/figure. These identities are reference only, never copied. Background is illustrated, mapped to a tilted rectangular plane with empty gray wedges; camera illusion comes from whole-plane transforms. Actual limbs, hands, eyes and mouth redraw throughout; pose-changing movement runs at exported15fps. No reason to assume60fps source/interpolation. Camera is essentially fixed relative to character within the plane for several seconds; plane itself is moving. This disproves “camera never static” as a universal rule. No narrative captions; visible animation-app watermark is not content grammar. Hook atframe1 is movement, but tiny figure/large white field is weaker mobile readability than our intended framing. Major color payoff3.733; second flight payoff10.133; repeated~7.13s dance makes replay plausible, but final flight does not match first drawing. Reuse tool-led wipe, phase repetition and beat-landed body poses. Avoid tiny hook art, gray blank corners and IP/art reuse.

## Shared editing grammar and differences

01/03 are drawing montages with ~.7–1.8s layouts, stable paper backgrounds and gently moving camera.02 is vocal typography/pose/costume montage with .125–.5s accents;04 is a repeated animated performance with3–4s setting holds. All introduce a visual situation immediately, all preserve an audience focus, and all have high-contrast changes around useful musical/vocal events. None proves a fixed every-.4s activity rule, fixed palette, mandatory subtitles or seamless loop. Saturation, FPS and text treatment differ substantially.

ADB: larger held body pose, observational setup, crisp prop reveal, long-enough deadpan reaction, isolated camera kick. Nemi: anticipatory eye dart, flexible hair follow-through, playful tool rhythm, single burst of expressive exaggeration, return to vulnerable calm. Both: record primary visual event on exact source cue; begin anticipation2–4 export frames earlier and settle5–9 frames later, checking the actual render. These are our chosen choreography rules, not claimed measurements from all references.

The executable grammar is in `SHORTS_GRAMMAR.md`; raw pulse estimates remain drafts. Approved music cue maps must be measured again after any segment/rate change.
