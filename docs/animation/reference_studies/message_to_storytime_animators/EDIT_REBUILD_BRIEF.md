# Rebuild as a video edit, 23 October 2026

The user rejected Nemi R7 and ADB R5 for weak emotional voice delivery, expressions that do not suit the reference, and an episode-like Godot presentation. This document supersedes the earlier assumption that matching the shot intervals and red words was sufficient. Preserve those rejected cuts as history. The replacement is an externally composited, voice-led 25-second video edit; Godot supplies canonical character plates only.

## Evidence inspected

Primary reference: `/Users/talus/Downloads/This Is A Message To All Minecraft Youtubers.mp4`, SHA-256 `da2e2ce404461f9823ac33213d1bc51996e60e13c51ff21e3159904a6c4682c1`. Picture stream is 640×360, 30 fps, 750 frames. The file also contains an attached image stream; the 640×360 moving picture is the reference, not its cover art.

Fresh decoding at 5 fps covers the full picture. A second 10 fps inspection covers 14.0–18.9, including the prop sequence. Contact sheets and native frames are under `renders/message_to_storytime_reference/rebuild_analysis/`. `sheet_01.jpg` through `sheet_06.jpg` establish the broad structure; `montage_detail_01.jpg` and `montage_detail_02.jpg` establish the short action inserts. Native `frame_022.jpg`, `frame_023.jpg`, `frame_054.jpg`, and `frame_061.jpg` establish the important text/actor overlap. Rejected full contact sheets and newly decoded 10.6-second stills were compared directly.

No perceptual audio playback is claimed by this visual analysis. Existing `AUDIO_STUDY.md` contains source transcripts, stem measurements, soundtrack windows, and explicit limits. Voice delivery needs separate review against the actual reference soundtrack.

## The crucial missed compositing detail

**The giant red words sit behind the foreground character.** At 4.2 s `IS`, 4.4 s `ROBRO`, 10.6 s `YOUR`, and 12.0 s `BIGGEST`, the lower central red letter strokes disappear behind the blue head. This is visible at native resolution, not an interpretation of the remote analysis.

Correct master-shot layer order, back to front:

1. Detailed room/background plate.
2. Single giant red serif word.
3. Foreground canonical character with a clean alpha edge.
4. Only for the opener: small bold red cumulative captions in front.

The previous cuts render red letter strokes over Nemi's hair/ADB's head. They also flatten the room into a blank paper field with one window. That removes the source's foreground/background separation and its dark/bright rhythm. The rejected 10.6-second stills saved in the analysis folder show this directly.

### Master geometry measured from native frames

Use these as **composition ratios**, not a demand to distort the human characters into cube proportions. In the 4.4-second source master, the square head is approximately x=254–388, y=114–247 in the 640×360 picture: horizontal centre 0.50W, head width 0.21W, top 0.317H, head bottom 0.686H. The hero's shoulders/torso reach approximately x=199–468 (0.42W overall) and continue through the bottom edge. The portrait therefore occupies the lower 0.68H; it does not float above a lower margin.

At 1920×1080 this corresponds to head top near 342 px, head width near 402 px, head bottom near 741 px, and shoulder/body width about 807 px. Retain canonical head/body proportions and increase/decrease the whole plate to obtain a similarly substantial portrait. Long hair may extend below the head zone naturally. Do not scale only the head.

The source giant words have caps from approximately y=9–10 to y=140–144: top about 0.025H, cap height about 0.37H, lower strokes reaching about 0.40H. A word thus overlaps the head's upper 0.08H. The hero must occlude that overlap. At 1080p the comparable cap area is roughly 28–430 px, with hair/top-of-head masking about 342–430 px. This is the important depth relationship.

Widths vary by word: `ROBRO` spans approximately x=112–554 (0.69W), `YOUR` x=144–499 (0.55W), while `BIGGEST` x=10–631 (0.97W). A single fixed narrow title box is wrong; fit each word to the observed emphasis while maintaining similar cap height. The opening sans captions are instead foreground lower-middle lines, approximately y=252–329 (0.70–0.91H) when complete. They cross the torso and retain a dark edge/shadow. Treat the name/challenge serif and opener sans as separate graphic layers with separate depth.

## What the source actually does

The reference has a restrained edit grammar. Its intensity comes from confident performance, strong image contrast, abrupt audio changes, close composition, and blunt word replacement. It is not a demonstration of continual effects.

| Time | Observed source picture and craft | Replacement requirement |
| --- | --- | --- |
| 0.000–2.533 | One detailed room master, avatar foreground centre, nearly locked composition. Red bold sans caption builds into two lines in the lower middle. Room is appreciably darker than the inserts. | A full-frame author workspace/background with perspective and clear midground/foreground; large foreground portrait. Direct amused address. Bold red text builds on spoken word onsets. Avoid a floating portrait beside an isolated window. |
| 2.533–3.900 | Abrupt cut to bright pale environment. Very close avatar with arm bent toward chin/chest; it fills the frame and is cropped at the lower edge. No text. | A deliberately framed self-introduction portrait insert. Visible hand near self/chin and relaxed confident smile; no explanatory caption. Lower body may be cropped. |
| 3.900–4.833 | Return to the same room. `NAME`, `IS`, `ROBRO` hard-replace as single giant red serif words, behind the hero. | Use actual final voice timing for the name words. Same master and layer order. No scale-pop easing or word accumulation. |
| 4.833–6.400 | Brighter still closer face/upper-body insert; head occupies much of the picture. It is a confident declarative presentation, not an anxious reaction. | Tighter face insert, eyes at the viewer, slight chin lift and smug/knowing mouth. Pose on the boast/identity line, not a worried default expression. |
| 6.400–7.600 | Room return: `A`, `RETIRED`, `TALENT`, with long words intentionally broad across the upper frame and masked by the head. | Corresponding concise identity words. Keep the last word long enough to register. Any author-specific joke should retain confident delivery. |
| 7.600–9.667 | Bright medium framing, one arm extended horizontally, simple pale ground texture and contact shadow. The body/gesture has a clear silhouette. | A confident pointing/presentation pose at useful scale. Do not make a tiny figure in a vast blank room merely to show the feet. Source is predominantly medium, not a standing full-body showcase. |
| 9.667–14.333 | Exact room return, giant single words progress rapidly with the boast. Red words are behind the hero. `BIGGEST`, `MINECRAFT`, `YOUTUBER` approach frame edges. Some words hold longer according to speech. | Deliver the challenge in a steady foreground portrait. The words, voice, and music dropout provide the emphasis. Target text cap height about 0.35–0.38 frame height, near the top, baseline around 0.39 frame height. Hero hair/head must mask lower middle strokes, while the word remains identifiable. |
| 14.333–15.300 | Bright side-angle insert of the avatar leaning behind a foreground table/counter. Pose and table occupy most of the lower picture; no text. | A large crop of author leaning into a real drawing desk. Forearms/contact visible; page/pen/table share perspective. This is an insert shot, not a wide stage diagram. |
| 15.300–16.200 | Closer avatar visibly clutching a large stack of bread. Strong body/prop silhouette, no text. | A striking author/storytelling prop clutched against the body: a clearly drawn, actual sketchbook or compact story stack. Hands/grip and reaction matter; the prop must not float beside a pointing hand. |
| 16.200–16.600 | Very brief detail of legs/diamond block, then a reframing with the block at the top over a smaller avatar. This is an absurd spatial/prop gag. | One deliberately absurd visual consequence involving the same prop, shown as a close detail and a changed angle/scale. For example, a ridiculous story-stack pedestal or oversized sketchbook. Make the two views one coherent gag; do not substitute an unrelated laptop closeup. |
| 16.600–18.000 | Block overhead image resolves into a large proud hands-behind-back pose; a brief double-exposure/dissolve is visible around 16.9 s. Most of the held frame is quiet. | Resolve the prop gag into a proudly pleased pose. A very short dissolve between these two inserts is the only clearly observed soft transition; do not add a transition to every cut. |
| 18.000–18.867 | Bright thoughtful arm/chin pose. High angle/pale ground, simple framing; no captions. | One short considered face/hand pose preparing the final statement. Thoughtful certainty, not alarm or emotional collapse. |
| 18.867–22.100 | Room master, no captions. The voice delivers a dry self-confident closing line over the nearly locked portrait. | Direct camera gaze and dry certainty. Let the ending be heard. Do not add a plea for viewers, a worried face, new doodles, or extra text. |
| 22.100–25.000 | Solid black after the closing sentence; audio tail may remain. | Exact solid-black picture tail. No end card. |

All cut boundaries above come from the earlier 30 fps local analysis and fresh frame comparison. The 10 fps insert study identifies the short dissolve only approximately; do not claim a frame-exact transition duration without decoding those individual frames.

### Texture, camera, and typography: observed versus invented

- The room has real spatial depth, practical objects and shadows; the pale inserts have a ground plane/contact shadows. Dark master versus high-key insert is a much stronger visual change than the two almost-identical cream canvases in the rejected cuts.
- The room camera/hero composition is essentially held. Small pixel shifts are not evidence of a major camera move. Do not add permanent push-in, shake, sway, or random bobbing.
- The body poses are mostly held after a small settling action. Hard cuts between useful poses carry the montage. Do not replace that with continual tweening or aimless gesture loops.
- Bright insert cropping varies from very close face to medium body and prop detail. The previous tiny standing shots dissipate the energy.
- Giant type resembles regular high-contrast Times-style red serif and is bluntly replaced. The installed font record already selects Times New Roman; it does not prove the creator's exact original font file. Preserve the visible weight, proportions and location. Font size/horizontal fitting may vary by word as required to resemble the source.
- The opener is smaller bold red sans with a dark edge/shadow, cumulative, in front of the character. The giant serif is not this caption system.
- No repeated flashes, film grain, chromatic aberration, speed ramps, glitch overlays, animated lower thirds, or whip transitions are established by this inspection. Adding them would be a new style rather than closer matching.
- A brief dissolve is visible around 16.9 s. The source is otherwise predominantly hard cuts; earlier descriptions of an absolutely all-hard-cut edit were too rigid.

## Why the rejected acting reads wrong

Nemi's crossed/protective arms, worried/downturned mouth, soft shrug, and uncertain face tell a story about hesitation. ADB's raised/furrowed brow and repeated anxious circular speech mouth read as discomfort, especially against empty cream space. The source communicates ridiculous self-belief. A faceless cube can do that through posture alone; these expressive characters need eyes, brows and mouths that agree with their body and narration.

The old script also changes the source's emotional destination. `I'm already the best. Now I just gotta be the biggest` is swagger. `Now I just gotta stop overthinking` and `Now, where's the audience?` turn the ending into insecurity. Even beautiful typography cannot correct that mismatch. Retain playful self-belief in the new script and final take. A self-deprecating identity joke may be delivered with a proud wink; it must not set off a whole worried performance.

## Author performance plates

These are semantic directions, **not invented Godot API names**. Select supported existing poses/expressions/hand controls. Preserve both rigs and their definitions. Create new plate assets externally directed from those controls, with alpha backgrounds; composite them in the editor. A single exported full-stage Godot scene with its own camera/type/backdrop would repeat the rejected approach.

| Beat | Nemi plate performance | ADB plate performance |
| --- | --- | --- |
| Direct opener | Small knowing smile; green eyes meet the viewer; shoulders relaxed and squared; one hand at hip or a quiet low gesture. Avoid self-hug/crossed protective arms. | Direct level gaze; one amused mouth corner; relaxed chest, one hand low/hip. Avoid furrowed worry. |
| Name/self-introduction insert | Finger/hand toward self, cheek/chin nearby; slight playful head tilt. Hold a confident closed smile after the word. | Supported chin/self-point gesture with a small cocky grin; eyes at viewer. Gesture settles after the name. |
| Identity close insert | Tiny chin lift and narrowed/knowing eyes, smiling as if the label is a boast. | Slight brow lift and amused eyes, proud compact fist/self gesture if supported. No angry clenched performance. |
| Challenge pre-roll | Clear outward pointing/presentation gesture. She has decided to say it; body is open. | One strong directional point/open arm; tall relaxed chest, mischievous confidence. |
| Giant-word challenge master | Face reads amused certainty. Keep arms composed so text and delivery remain primary. Mouth changes follow actual final audio; close at gaps. | Direct assertive eyes and slight grin. Avoid sustained round mouth or a complaint gesture. Keep large body moves out of this shot. |
| Desk insert | Lean over pages/table with genuine forearm contact and a pleased work expression. | Lean over notebook/table with grounded elbows/forearms, a knowing workmanlike smirk. |
| Prop gag | Hug/grip one actual sketchbook/story stack with open delight or proud satisfaction, not distressed self-protection. | Hold the same chosen story prop in a confident demonstrative grip; reaction suits the absurd size/weight. |
| Proud resolution | Hands behind back or composed supported proud stance; slight chin lift, closed smile. | Hands behind back/low relaxed hands; subtle smirk, chest open. |
| Thoughtful pre-ending | Brief hand at chin, eyes slightly aside/up, with small confident smile. | Brief chin gesture and side glance as though planning an inevitable win. |
| Dry ending | Return gaze to camera, level head, restrained closed smile between phrases. Stillness sells the line. | Level direct gaze, relaxed mouth corner, composed body. Self-assured deadpan rather than pleading. |

At word impacts, make eyes/brows and mouth support the same emphasis. Do not choose a random named expression simply because a new shot starts. Do not animate all controls continuously; prepare useful held plates plus a small number of visible settling/gesture/mouth variants.

## External-edit assembly

1. Finish expressive canonical voice takes first. Keep original voice identities; performance instructions/take selection must carry dry confidence, playful arrogance, brief nonverbal space, and the final understated statement. Do not time new pictures against the rejected audio merely because it already has word timestamps.
2. Build a new edit timeline in an external compositor/editor with separate character-alpha, background, type, props, and audio tracks. It must be possible to change cut timing/type/motion without opening the final Godot stage. The exact application is an implementation choice; a deterministic compositor and editable timeline/source are acceptable.
3. Construct one convincing author workspace master from canonical author art, with simple readable depth, soft paper/ink shadows and selective prop colour. Retain the cream-paper/canonical-character colour identity required by the project; the necessary room/insert contrast can come from lighting/value and detailed perspective rather than a blue wall copied from Minecraft. Do not merely darken the old isolated-window frame.
4. Use clean alpha character plates so the giant word can sit behind hair/head. Composite at 1920×1080. Keep text crisp and hero line edges clean. Draw completed props once; no drifting, sliding-mask or opacity-word fake drawing.
5. Use large purposeful insert crops, meaningful prop contact and one coherent absurd visual gag. The goal is an edited run of images and performances, not a tour of a generic animation stage.
6. Place source-style music entrances/dropouts around the speech and bright inserts. The important reference sound pattern is dry speech → music insert → dry boast → music montage → dry closing → tail. A continuous low generic bed loses the joke. Use the separately reviewed soundtrack plan; do not claim unverified source separation is flawless.
7. Rebuild word timing, mouth intervals and cut selection against the final audio. Snap cut/type boundaries to the 30 fps picture clock; retain audio sample precision. Preserve the 25.000-second picture cap and the 22.100-second black tail boundary unless a deliberately reviewed final-voice alignment requires a small named deviation.
8. Review a new short proof for depth masking, a confident face and a real insert transition. Then watch both complete 1080p cuts, checking voice emotion, expressions, clean alpha, every type change, prop contact, actual sound audibility and ending. Preserve rejected movies. No 4K until the user explicitly likes the complete current cuts.

## Acceptance questions for the new full cuts

- With the audio muted, does each character look amused and self-assured rather than worried or apologetic?
- With the picture hidden, does the voice itself make the bold joke and the closing line land?
- In the giant word shots, does the hero visibly occlude lower central letters while the word stays readable?
- Does the room master feel like a complete designed image, and does every bright insert change its value/framing decisively?
- Can the prop montage be understood as one escalating joke without a caption explaining it?
- Does every effect visible in the new cut have a grounded reference function, rather than being added to compensate for weak pictures?
- Does the final return hold with confident stillness and an uncaptained dry line, then cut cleanly to black?

Passing codec/spec checks alone answers none of those questions. The user has explicitly rejected the earlier aesthetic, so the replacement must be assessed as an edit and performance before delivery.
