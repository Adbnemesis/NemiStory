# Ref03: actual held-art motion, joins and music relations

Inspected 2026-10-06 from the exact supplied source video. All627 picture frames were decoded at30fps; all16 layouts and all15 joins have fresh within-layout/boundary sequences. The source SHA256 is `10193f4051d2314740b6835fe538055a669d192f27916f9d8f69050a8ab0438f`. The decoded picture lasts20.9s; container/audio lasts20.949333s. Source remains unchanged. This study describes visible craft, not audience retention statistics.

The reference’s motion comes primarily from **held illustrated cards with camera/art-layer pushes, pulls and directional exits continuing through the thought**. Most hands, faces, hair and clothing lines remain fixed relative to each other. A few strong close/miniature contrasts and one short shame-head shake passage supply disproportionate energy. A six-frame entrance followed by a long frozen drawing would miss this grammar, even if it had many poses. The source also deliberately lets one attractive close portrait stay quiet before its directional exit; continuous motion everywhere is our requested adaptation, not a factual description of every source frame.

## How the evidence was measured

`analyze_motion.py` verifies the original hash, decodes actual frames, draws16 within-layout sheets and15 join sheets, and tracks dark-contour features with forward/back-checked optical flow plus a robust partial affine fit. The full-width y420..545 caption band is masked out (all three outlined lines in this360×640source). Fits generally use layout start+6 through end−7 to avoid entrance/departure extremes. Some directional exits start earlier than that margin; layout03’s final fit therefore fails once the portrait exits, and the directly inspected sequence is authoritative. `held_motion.csv` reports only that subsection’s net transform; it must not be read as the total shot amplitude. `tracking.json` contains every fitted sample, inlier count and residual; `motion_map.json` joins those numbers to the inspected editorial observations. Sparse paper, moving/blurred art, face edits and ghost trails can produce ambiguous fits. “Camera” here means a net screen transform of coherent artwork; the mixed export cannot tell whether the creator moved a camera or an art layer.

Most credible held-phase pushes are about2–7%; one miniature pull is about9%. Selected lateral movement is about32–38px in this360-wide source (~96–114px at1080). One selected medium group fit includes roughly−2.35° roll. Other rolls below0.5° should be treated cautiously. These are descriptive estimates, not targets to repeat in every shot. Larger framing differences come mainly from different drawings/cuts, not from slowly zooming one drawing throughout the entire movie.

## All layouts

| Layout | Actual interval | Audience focus | Net held-subsection affine estimate | Evidence |
|---|---|---|---|---|
| 01 | f0–48 / 0.000–1.633s | Blushing opening, medium torso | -3.37% scale, [7.215, -8.077]px central shift, -0.05° | [within-shot sequence](layout_01.jpg) |
| 02 | f49–79 / 1.633–2.667s | Crush gesturing to faceless group | +2.65% scale, [-0.594, 4.326]px central shift, +0.00° | [within-shot sequence](layout_02.jpg) |
| 03 | f80–123 / 2.667–4.133s | Attractive profile/threequarter face close | Fit fails once departure enters measured window; use sequence | [within-shot sequence](layout_03.jpg) |
| 04 | f124–155 / 4.133–5.200s | Reverse crowd/cap wearer, medium group | -3.67% scale, [-31.844, 0.767]px central shift, -2.32° | [within-shot sequence](layout_04.jpg) |
| 05 | f156–201 / 5.200–6.733s | Cap wearer reverse close view | +4.38% scale, [7.124, 12.696]px central shift, -0.03° | [within-shot sequence](layout_05.jpg) |
| 06 | f202–237 / 6.733–7.933s | Small happy protagonist reaction | -8.89% scale, [0.91, 9.888]px central shift, -0.40° | [within-shot sequence](layout_06.jpg) |
| 07 | f238–280 / 7.933–9.367s | Small head-down reaction | -0.10% scale, [5.413, 3.521]px central shift, -0.04° | [within-shot sequence](layout_07.jpg) |
| 08 | f281–333 / 9.367–11.133s | Flustered hand-to-mouth close | +4.40% scale, [-0.634, 12.287]px central shift, -0.09° | [within-shot sequence](layout_08.jpg) |
| 09 | f334–360 / 11.133–12.033s | Shame miniature/shaking head | Finite shake/ghost passage; single affine summary is not authoritative | [within-shot sequence](layout_09.jpg) |
| 10 | f361–394 / 12.033–13.167s | Protagonist among faceless crowd | +6.97% scale, [-5.493, -3.549]px central shift, +0.07° | [within-shot sequence](layout_10.jpg) |
| 11 | f395–434 / 13.167–14.500s | Half-lidded woman close | +1.62% scale, [9.169, 4.046]px central shift, +0.49° | [within-shot sequence](layout_11.jpg) |
| 12 | f435–470 / 14.500–15.700s | Opposite-facing full figures | -4.45% scale, [-0.51, -3.809]px central shift, +0.12° | [within-shot sequence](layout_12.jpg) |
| 13 | f471–515 / 15.700–17.200s | Strained smiling reverse close | +2.48% scale, [2.343, 0.884]px central shift, -0.07° | [within-shot sequence](layout_13.jpg) |
| 14 | f516–550 / 17.200–18.367s | Nervous hand near cheek, torso | -1.74% scale, [0.219, -4.16]px central shift, -0.29° | [within-shot sequence](layout_14.jpg) |
| 15 | f551–591 / 18.367–19.733s | Startled greeting with HEY bubble | -2.63% scale, [2.723, -10.601]px central shift, -0.26° | [within-shot sequence](layout_15.jpg) |
| 16 | f592–626 / 19.733–20.900s | Split disappointment/normal-face payoff | +4.27% scale, [3.824, -1.309]px central shift, +0.09° | [within-shot sequence](layout_16.jpg) |

### 01. Blushing opening, medium torso

**Picture motion:** Whole drawing gently pulls smaller/upward, then briefly grows again immediately before f49. Shirt/hair/eye linework stays coherent. The opening is readable from f0, without an entrance wipe.

**Inside the drawing:** No independent hand/head/eye change established in inspected samples; facial blush and shut-eye expression are held.

**Useful adaptation:** Use a finite pull then a short anticipation push. The last-frame push prepares the attention cut rather than a perpetual breathing loop. [Inspected samples](layout_01.jpg).

### 02. Crush gesturing to faceless group

**Picture motion:** Small ongoing push/downward move, then a sharper final enlargement at f79. All group lines move together.

**Inside the drawing:** Pointing hand, mouth and hair are held drawings in inspected frames; the gesture is conveyed by the pose and camera, not visible finger cycles.

**Useful adaptation:** Push over the conversation thought; reserve a selected quick focal enlargement for a musical/attention accent. [Inspected samples](layout_02.jpg).

### 03. Attractive profile/threequarter face close

**Picture motion:** f80..approximately f114 is a substantially held portrait; from f116..f123 the art accelerates left with a blurred departure. Fixed caption and vignette do not leave.

**Inside the drawing:** No clear internal acting change detected before departure; the attractive expression gets a quiet readable interval.

**Useful adaptation:** Allow a quiet held beauty face, then a purposeful directional exit. Do not label every hold as poor retention. [Inspected samples](layout_03.jpg).

### 04. Reverse crowd/cap wearer, medium group

**Picture motion:** Incoming group enters from the right f124..f130 following the departing leftward art. It then continues a shallow left drift/pull; affine fit has about−2.35° roll in f130..f149, treated as an estimate rather than proof of a physical camera.

**Inside the drawing:** Faceless extra and cap/backpack contours retain their relationship; no automatic walking/contact is shown.

**Useful adaptation:** Maintain sweep direction across old/new drawings; continue a mild finite camera move after the arrival instead of stopping at six frames. [Inspected samples](layout_04.jpg).

### 05. Cap wearer reverse close view

**Picture motion:** New close drawing at f156; slow push/downward follow across the held phase (~4.4% scale increase f162..f195).

**Inside the drawing:** Hand, backpack straps, cap and talking expression remain stable in inspected samples.

**Useful adaptation:** Close-detail reveal followed by a slow push. Props must remain in the same transform as the held body. [Inspected samples](layout_05.jpg).

### 06. Small happy protagonist reaction

**Picture motion:** Strong close→miniature contrast at f202. This simplified drawing itself gently pulls smaller (~9% f208..f231) with modest downward drift.

**Inside the drawing:** Small smile/head/hair are held; the change from detailed crush art to a miniature reaction carries the thought.

**Useful adaptation:** Use an actual simplified reaction drawing plus measured scale contrast; the camera path should reinforce the emotional withdrawal. [Inspected samples](layout_06.jpg).

### 07. Small head-down reaction

**Picture motion:** A pose cut at f238 keeps the miniature scale family. Only a shallow drift is visible (~5.4px right,3.5px down from f244..f274,360-wide source).

**Inside the drawing:** Hair-covered face and shoulder drawing are held. The view/pose change supplies the feeling, with tiny travel keeping spatial continuity.

**Useful adaptation:** Use a restrained finite move here; avoid flooding this quiet beat with effects. [Inspected samples](layout_07.jpg).

### 08. Flustered hand-to-mouth close

**Picture motion:** Large miniature→close jump at f281, followed by an ongoing mild push/downward movement (~4.5% scale and12px central shift f287..f327).

**Inside the drawing:** The hand stays at the mouth; hair, sleeve and cheek hatching remain coherent. No hand separation or repeated gesture entry is visible.

**Useful adaptation:** A hand contact close should share head/contact motion; camera can develop the embarrassment while the grip/art stays stable. [Inspected samples](layout_08.jpg).

### 09. Shame miniature/shaking head

**Picture motion:** At f334, large close switches to small tilted simplified head. Over the finite27-frame interval, orientation flips/rotates and faint displaced copies alternate. A single rigid affine fit fails some samples.

**Inside the drawing:** This is the clearest finite local performance/effect passage: a small illustrated shake with mirrored/oriented cards and ghost trail, rather than ordinary gentle limb animation.

**Useful adaptation:** Use one short semantic shake/recoil phrase at the embarrassment peak. Do not repeat it as a background idle everywhere. [Inspected samples](layout_09.jpg).

### 10. Protagonist among faceless crowd

**Picture motion:** Clean cut at f361; foreground body/crowd slowly enlarges (~7% f367..f388) and later edges spread outward. Pale background figures remain intentionally subordinate.

**Inside the drawing:** Expression is held. Pale extra outlines are not sufficient evidence of an animated dissolve; direct join samples show an abrupt new composition.

**Useful adaptation:** Group reveal with a finite push centered on the readable face; extras stay less prominent. [Inspected samples](layout_10.jpg).

### 11. Half-lidded woman close

**Picture motion:** Cut at f395, slight steady push/right/down shift (~1.6% and9px x overf401..f428). Small fitted roll≈0.5°, near the limit of obvious visual notice.

**Inside the drawing:** Half-lidded eyes/mouth stay essentially fixed; eye attitude does the comic work.

**Useful adaptation:** A low-amplitude drift can keep a held reaction readable; do not count blinks alone as meaningful performance. [Inspected samples](layout_11.jpg).

### 12. Opposite-facing full figures

**Picture motion:** Full-body contrast at f435. Group pulls smaller (~4.4% f441..f464); aroundf466..f470 the left cap wearer slides out left while the right figure stays, with a faint trail.

**Inside the drawing:** Walking is suggested by separately drawn stance art, not established as a continuous foot/contact cycle. The selective character departure differs from a whole-screen pan.

**Useful adaptation:** Use actual grounded held stance art. An isolated figure exit can carry the thought, but do not fake walking by floating the root. [Inspected samples](layout_12.jpg).

### 13. Strained smiling reverse close

**Picture motion:** Cut at f471. Short progressive push (~2.6% f477..f509); final framing relaxes slightly beforef516.

**Inside the drawing:** Eye/mouth/sweat drawing stays coherent. No reliably separate lip animation established.

**Useful adaptation:** Let camera gently approach a held uncomfortable expression; tiny authored eye/head responses are an adaptation, not a claim about this source. [Inspected samples](layout_13.jpg).

### 14. Nervous hand near cheek, torso

**Picture motion:** Cut at f516, slow pull/up drift (~1.8% scale decrease f522..f544).

**Inside the drawing:** Cheek/hand contact, tired face and shirt drawing hold in samples.

**Useful adaptation:** Use a finite pull/settling camera thought plus one contact-preserving head/eyeline response. [Inspected samples](layout_14.jpg).

### 15. Startled greeting with HEY bubble

**Picture motion:** Immediate pose/ink burst cut atf551. Slow pull/up shift (~2.6% shrink and10.6px up f557..f585), then a short end enlargement atf591.

**Inside the drawing:** Startled limbs, spiky marks and greeting bubble form one held illustrated event composition. This is not evidence of an audible shout.

**Useful adaptation:** Give the arrival a readable semantic reaction; let its finite camera phrase continue under the music and resolve before payoff. [Inspected samples](layout_15.jpg).

### 16. Split disappointment/normal-face payoff

**Picture motion:** Cut atf592. Both halves and split stroke progressively push (~4.3% f598..f620), keeping the caption fixed.

**Inside the drawing:** The contrasting faces and hand gestures are held. The split itself establishes the final meaning.

**Useful adaptation:** A final gentle push can keep the ending alive; the payoff must remain legible and differ from the opening. [Inspected samples](layout_16.jpg).

## Every join: departure, intermediate and arrival

These sequences contain frames cut−8,−5,−3,−1,cut,cut+1,+3,+5,+8. Frames carry their decoded timestamp. Clean cuts are included: do not invent a smear or dissolve when the evidence is an immediate new drawing.

- **f49 / 1.633s — Anticipation punch → clean context cut.** f41..48 opening drawing grows before f49; f49 is a complete new group composition. No wipe/flash. [Nine-frame join sequence](join_01_f049.jpg).
- **f80 / 2.667s — Group → matching face reveal.** f79 group has enlarged; f80 replaces it with a distinct face drawing, readable immediately. No ghost trail across this cut. [Nine-frame join sequence](join_02_f080.jpg).
- **f124 / 4.133s — Directional blurred departing/arriving art.** f116 still readable; f119/121 departing portrait shifts left with blur; f123 only its far-left sliver remains; f124 new group begins at right; f129/132 arrives and resolves. Caption remains fixed. [Nine-frame join sequence](join_03_f124.jpg).
- **f156 / 5.200s — Reverse medium → reverse close snap.** f155 preceding cap group has a brief blur/scale change; f156 switches to a close reverse cap drawing; f159/164 remains coherent. [Nine-frame join sequence](join_04_f156.jpg).
- **f202 / 6.733s — Detailed close → simplified small reaction.** f201 detailed cap/backpack close; f202 tiny happy protagonist replaces it. The scale/detail contrast is part of the thought. [Nine-frame join sequence](join_05_f202.jpg).
- **f238 / 7.933s — Miniature reaction pose swap.** f237 happy mini; f238 hair-covered/head-down mini. Clean drawing swap at comparable small scale. [Nine-frame join sequence](join_06_f238.jpg).
- **f281 / 9.367s — Small reaction → large hand-contact close.** f280 tiny head-down; f281 hand-to-mouth close appears whole. No two-body overlap. [Nine-frame join sequence](join_07_f281.jpg).
- **f334 / 11.133s — Large close → small finite shake.** f333 large embarrassed portrait; f334 tilted mini. Following frames alternate rotated/mirrored head cards with faint displaced trails. [Nine-frame join sequence](join_08_f334.jpg).
- **f361 / 12.033s — Shake → crowd context cut.** f360 mini head; f361 crowd context composition. Pale extras are a held design choice, not proof of a gradual dissolve. [Nine-frame join sequence](join_09_f361.jpg).
- **f395 / 13.167s — Crowd → bored face reveal.** f394 crowd composition; f395 close bored woman. Immediate new drawing, then small drift. [Nine-frame join sequence](join_10_f395.jpg).
- **f435 / 14.500s — Face → opposite full figures.** f434 close half-lidded face; f435 two full stances, separated spatially. Clear size/context contrast. [Nine-frame join sequence](join_11_f435.jpg).
- **f471 / 15.700s — Selective figure exit → reverse close.** f466 left cap figure becomes faint/displaced; f468..470 leaves left while other person remains; f471 reverse female close replaces stage. [Nine-frame join sequence](join_12_f471.jpg).
- **f516 / 17.200s — Reverse close → nervous torso.** f515 reverse smiling close; f516 nervous front torso/contact pose. Clean cut. [Nine-frame join sequence](join_13_f516.jpg).
- **f551 / 18.367s — Nervous torso → startled greeting.** f550 held nervous pose; f551 startled illustration and HEY burst land together. Printed speech does not confirm recorded dialogue. [Nine-frame join sequence](join_14_f551.jpg).
- **f592 / 19.733s — Greeting → split payoff.** f591 greeting reaction enlarges briefly; f592 split illustration replaces it; f595..600 progressively enlarges. No outro. [Nine-frame join sequence](join_15_f592.jpg).

## Music relation, with limits

The source contains a melodic mixed vocal track. The prior study estimated ~92BPM with184BPM double-time ambiguity; no bar/downbeat phase is confirmed. This pass independently recomputed positive spectral-flux candidates from the actual audio at an11.61ms hop. Candidates are dense (~.16s apart in much of the passage), so proximity alone cannot establish deliberate sync. A negative offset below means the picture anchor precedes that candidate; positive follows it. Flux is normalized against this file’s maximum and is not a stem loudness measurement.

| Picture anchor | Nearest flux candidate | Picture minus candidate | Candidate flux | Inspected relation |
|---|---|---|---|---|
| f49 / 1.633s | 1.6718s | -38.5ms | 0.516 | Anticipation punch → clean context cut |
| f80 / 2.667s | 2.7167s | -50.1ms | 0.498 | Group → matching face reveal |
| f124 / 4.133s | 4.1215s | +11.8ms | 0.793 | Directional blurred departing/arriving art |
| f156 / 5.200s | 5.2825s | -82.5ms | 0.673 | Reverse medium → reverse close snap |
| f202 / 6.733s | 6.7454s | -12.1ms | 0.580 | Detailed close → simplified small reaction |
| f238 / 7.933s | 7.8948s | +38.5ms | 0.374 | Miniature reaction pose swap |
| f281 / 9.367s | 9.3693s | -2.6ms | 0.705 | Small reaction → large hand-contact close |
| f334 / 11.133s | 11.1804s | -47.1ms | 0.469 | Large close → small finite shake |
| f361 / 12.033s | 11.9931s | +40.2ms | 0.723 | Shake → crowd context cut |
| f395 / 13.167s | 13.1425s | +24.2ms | 0.583 | Crowd → bored face reveal |
| f435 / 14.500s | 14.4544s | +45.6ms | 0.350 | Face → opposite full figures |
| f471 / 15.700s | 15.7780s | -78.0ms | 0.649 | Selective figure exit → reverse close |
| f516 / 17.200s | 17.2408s | -40.8ms | 0.724 | Reverse close → nervous torso |
| f551 / 18.367s | 18.3902s | -23.5ms | 0.381 | Nervous torso → startled greeting |
| f592 / 19.733s | 19.7137s | +19.6ms | 0.442 | Greeting → split payoff |

The decisive directional sweep starts before thef124 anchor: departing art is already moving/blurred aroundf117–123, and the new group begins atf124 (about12ms after the4.1215s flux candidate), then continues arriving to aboutf130. This is a passage with preparation and follow-through, not simply a cut quantized to one drum. Thef281 hand-contact reveal is within3ms of a candidate; the split payofff592 is about20ms after one. Other changes can be50–83ms away. Do not force all actions onto inferred quarter beats; audition our actual track, choose the focal attack/vocal accent, and plan preparation → accent → follow-through around it. This source does not establish separate SFX gains, an audible greeting, or narration identity.

## Concrete Godot motion recipe for our Shorts

1. Keep the approved ink artwork and distinct pose story. Assign one audience focus per thought: body/stance, face, held prop or duo contrast. Preserve an immediate readable opening.
2. Author a **camera phrase across the thought**, often a3–7% push/pull over18–40frames, with an intentional10–45px pan at1080 rather than a default bob. Use a stronger full/close/miniature cut when the feeling reverses. A lateral sweep can use more travel only when it conveys changed attention; do not add±120px everywhere.
3. Use the optional maintained `shot.camera` path with a screen focus and absolute frame keys. Let the destination key choose linear/smooth/out/in easing. A selected attack can have a small2–3% two-frame camera accent followed by a6–10frame return, on the same named music clock. The final key holds; no sine idle, random shake or endless zoom.
4. Add a tiny **finite acting answer** while the pose holds: eyes notice first, head follows1–3°, grounded upper-body weight/lean answers0.5–2°, then settles. Keep the hand/prop contact matrix coherent. Do not repeatedly re-enter gesture0→1 merely to make every frame different. Continuous little acting is our adaptation requested by the user; most source cards themselves are held.
5. Connect transitions to the moving camera state. Sample the outgoing drawing atcut−1 with its actual camera/travel transform. Prepare a directional exit, land the incoming pose on the chosen accent, continue its gentle camera phrase, then hold for comprehension. A foreground wipe must hide a meaningful pose/page swap and reveal the intact drawing.
6. Share only the small camera delta with physical door/runway/column contours. Keep the caption and page/viewfinder graphics readable in screen space. Position named-event marks at the intended focus; avoid crossing faces, grips or the groin.
7. Inspect actual beginning/middle/end of every thought, departure/intermediate/arrival of every join, and the encoded music/acting clock. Then watch the whole edit at phone size. Pixel movement and pose counts cannot prove a compelling or high-retention result.

Supported API/ranges live in [`V3_SCHEMA.md`](../../../godot/V3_SCHEMA.md); creation/render steps in [`V3_WORKFLOW.md`](../../../godot/V3_WORKFLOW.md). This study is an input to direction, not permission to copy the reference characters, exact romance premise or its video frames into production.
