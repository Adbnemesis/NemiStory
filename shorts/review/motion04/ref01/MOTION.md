# Ref01: motion within the pose

The actual campus reference keeps a held drawing moving through its shot. The visible effect is predominantly **continuous focal scale/position change**, followed by a quicker accent or directional exit. A full-body reveal then a moving face crop is one visual thought. Our previous stopped camera plus brief head settle did not reproduce that cadence.

This is a fresh read-only analysis of the exact [source manifest](../../references/manifest.json) entry, verified SHA256 `bd6fbd8fcda6ad977ae5c27939ad5d0fc60192abc822461f9a007625bef25028`, 412 decoded frames,480×854 at30fps. Evidence contains actual before/mid/end frames, dense arrival strips, registration images and [measurements](measured_motion.json). No production source was changed.

## Camera and internal movement map

The percentages below use SIFT feature matching plus RANSAC similarity registration between the specified decoded frames. These are drawing-scale changes visible in the finished movie, not the unavailable original camera settings. Rotation estimates generally stay within1°; the reverse warning has approximately1.3°. Translation is reported as the displacement of the decoded frame-center `(240,427)` under the fitted transform; a zoom about an off-center face produces translation too. It must not be mistaken for independent character root travel. Units are source pixels; multiply by2.25 to compare with our1080px export.

| Layout / source interval | Inspected stable span | Scale change | Motion / internal art observation |
|---|---|---:|---|
| Walking setup,0–1.167s | f2→32 | −9.3% | Gentle pull-out/upward reframe. Fixed walking silhouette; this is not a confirmed animated walk cycle. Head, strap grip and leg contours retain their relationships. |
| Annoyed reaction,1.167–~2.167s | f37→56 | +16.5% | Ongoing push on the closed-eye annoyed drawing. Hair, eyes, fist and sleeves register together. From f58 it accelerates into a blurred rightward departure. |
| Reverse warning,~2.167–3.300s | f80→96 | −3.1% | Reverse drawing enters from the left during the preceding whip; after landing, a slight pull and ~1.3° tilt continue. No observed internal eye/limb redrawing in the stable span. |
| Duck/recoil and passer,3.300–4.300s | f101/113/126 | Separate layers | The recoiling protagonist and large passing figure translate independently with horizontal streaks. One global camera fit is inappropriate. The protagonist remains a held duck drawing while foreground crossing supplies action. |
| Hoverboard reveal,4.300–5.033s | f131→145 | +4.3% before late ramp | Slow push on the held rider/board, then stronger scale/blur over the last3–6frames. Feet/board contact stays locked. |
| Warning face,5.033–5.967s | f153→176 | +20.7% | Continuous push, with larger positive vertical image displacement because the focus is high. Face, cap, shoulder and elbow remain one drawing. |
| Skateboard reveal,5.967–6.867s | f181→203 | +18.1% | Ongoing push, late blur before the face reframe. Board and planted shoes stay one drawing; no verified wheel/leg animation. |
| Skater face,6.867–7.833s | f208→232 | +34.6% | Strongest close-face push. Full affine and similarity registration agree closely; head/hood/arm geometry aligns, so apparent motion is principally reframing. |
| Scooter reveal,7.833–8.700s | f237→258 | +18.0% | Ongoing push on the distinctive seated silhouette and tool. Its absurd pose does the comic work; hands/handle remain fixed. |
| Scooter face,8.700–9.667s | f263→287 | +13.2% | Continuous face push. Eye, hair bun, glasses and folded arm relationships remain stable. |
| Bicycle reveal,9.667–10.467s | f296→307 | +5.8% before late ramp | Slow held-art push then a faster blurred advance before the face cut. Whole-span initial optical flow loses the drawing during the late zoom and is not a reliable internal-motion measurement. |
| Cyclist face,10.467–11.467s | f316→341 | +16.9% | Continued push, faint surrounding marks. No resolved eye blink, hand shift or independent head turn in the inspected registered frames. |
| Stress miniature,11.467–13.733s | f346→409 | −20.3% | Long pull-out shrinks the protagonist, increasing empty space and comic defeat. Head/hand/clothing align after registration; purple stress strokes accompany the held reaction. |

Stable transform details are saved in [stable_sift.json](stable_sift.json), with reproducible [measurement script](measure_stable_sift.py). A registered pair and `stable-before-mid-end.jpg` are saved per measured layout.

| Layout | Center-image displacement, x/y source px | Rotation | Matched inliers |
|---|---:|---:|---:|
| 01 | +11.8 / -24.0 | -0.18° | 84 |
| 02 | -7.7 / +10.8 | -0.92° | 135 |
| 03 | -7.8 / -6.2 | +1.28° | 166 |
| 05 | -3.2 / -4.6 | +0.15° | 138 |
| 06 | +3.5 / +79.5 | -0.30° | 214 |
| 07 | +0.2 / +33.9 | -0.03° | 65 |
| 08 | -14.4 / +142.5 | +0.09° | 95 |
| 09 | -16.7 / +19.2 | -0.54° | 122 |
| 10 | -14.7 / +32.5 | -0.07° | 219 |
| 11 | +2.9 / +14.8 | -0.04° | 311 |
| 12 | +1.3 / +23.1 | -0.16° | 177 |
| 13 | +3.0 / -13.4 | -0.01° | 231 |

These center displacements combine focus-anchored scale and pan. Layout4 needs separate moving layers and is intentionally not given a misleading whole-frame transform. The matched drawing landmarks typically have subpixel-to1px median reprojection residuals; it does not establish unseen subpixel acting.

The exploratory Lucas-Kanade trajectories in `measured_motion.json` are candidates, not final motion facts. In particular, its layout2 endpoint crossed into the reverse drawing; layout4 mixes independently moving art; layout11 loses correspondence during the late ramp. The stable SIFT spans in this table supersede those unreliable estimates. The old reference notes used f78 as the reverse-layout anchor: fresh dense frames show it is an arrival/landing anchor, not the first reverse drawing. The actual outgoing-to-incoming swap occurs near f65 (~2.167s).

## Transition timing and shape

[Reaction-to-reverse strip](reaction-to-reverse_57_78.jpg) shows the deliberate broad whip: at f57 the outgoing reaction is readable, f58–64 accelerates right with blur, f65–70 swaps to the incoming reverse drawing at the opposite edge, and f72–78 resolves. This device lasts roughly20frames (~.67s), longer than our current brief pose joins. The caption stays fixed while drawings move; completed ink geometry does not crawl.

The transport montage favors a different join. It keeps pushing the current full drawing, accelerates/softens its last3–6frames, then snaps to the face crop or next rider with continued motion immediately afterward. See [hoverboard→face](cut_151_dense.jpg), [rider→skater](cut_179_dense.jpg), and [skater→face](cut_206_dense.jpg). It is not a long crossfade or an identical slide on every cut. The full/detail pairing preserves viewer orientation. Blur in this compressed source does not establish the original blur implementation.

A fresh positive spectral-flux pass uses exact mixed source audio,11.61ms hop. Several picture changes are close to measured attacks: f151/5.033s is+6ms from5.027s; f206/6.867s is−6ms from6.873s; f290/9.667s is+19ms from9.648s; f314/10.467s is+18ms from10.449s; f344/11.467s is−4ms from11.471s. Other changes intentionally differ: f179 is+34ms; f235+55ms; f129−77ms. Candidates are not confirmed musical downbeats. The transition can begin before its useful attack; the new drawing/face becomes the visual landing. Matching every cut to the old approximate quarter grid would miss several stronger subdivisions.

## Transfer into Godot

Use a finite camera track over **the whole pose**, rather than a1%travel that ends early. As starting design values for our art, test a6–12%body push/pull over24–36frames and a10–20%face push over24–30frames. Reserve25–35%close pushes for a strong reaction with enough canvas margin. Choose a focus/eyeline so the face or prop stays legible; keep captions on their separate screen plane. These are proposed safe starting values, not universal reference rules or retention guarantees.

Keep finished vector contours stable. Give the character a small thought-specific eye lead, head answer and restrained upper-body/weight response, each with authored finite endpoints; preserve standing feet and prop-grip matrices. These tiny internal movements address the user's latest direction, but are **our addition**: this reference mainly obtains life from its camera and held drawing changes. Do not claim that the reference demonstrates constant redraw, breathing loops or wrist cycling.

Link camera anticipation to the selected attack: a gentle ongoing move, a bounded2–4frame pre-accent speed change, a clear new pose/crop on the attack, then motion continuing through the next thought. Use one directional whip where attention reverses; use match/detail cuts for the rest. Verify both contact geometry and phone-size framing at maximum scale, including palms and finished pages. A finite camera can move a held pose; it cannot supply missing walking, pickup or handoff choreography.

## Evidence and limits

Each `layout_XX/` stores original decoded before/mid/end PNGs, a labelled triptych, and available registration evidence. Dense boundary sheets expose anticipation, motion blur and landing rather than hiding them in averaged cuts. Source files and production originals were untouched. This review inspected decoded frames and temporal sequences; it does not assert isolated SFX audibility, original animation cadence, actual audience retention or a complete listening review.
