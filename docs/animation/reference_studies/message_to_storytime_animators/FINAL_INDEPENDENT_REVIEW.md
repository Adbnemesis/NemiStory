# Independent final review

Review date: 23 October 2026. No blocking visual or media-structure defect was identified in the final decoded samples. This review covers extracted video frames, media measurements, production specs and earlier speech-recognition evidence. It does not claim human listening or real-time perceptual playback. The user's explicit satisfaction with the complete current 1080p cuts remains required before any 4K export.

## Final reviewed movies

| Author | Final 1080p movie | Movie SHA-256 |
| --- | --- | --- |
| ADB | `adb/episodes/ep08_message_to_storytime_animators/renders/ADB_Message_R5_1080p.mp4` | `6eaf768bd23e03e370db50da25e4d3b13914d6747b43c05b4eac33112bb804d4` |
| Nemi | `nemi/episodes/ep17_message_to_storytime_animators/renders/Nemi_Message_R7_1080p.mp4` | `31281274246acc7390a55543b856ef7f5b6e5d91dad6205aec16114509751969` |

Reference: the supplied `This Is A Message To All Minecraft Youtubers.mp4`; source hash and measured shot boundaries are recorded in `EDIT_ANALYSIS.json`. Earlier ADB R4 and Nemi R6 full cuts, plus ADB R4 contact proof and R5 type proof, were independently sampled before these final movies.

Both final cuts decode to 750 frames at 1920×1080, 30 fps, exactly 25.000 seconds, with 48 kHz stereo AAC audio. Every expected shot boundary has a visible decoded frame change: frames 76, 117, 145, 192, 228, 290, 430, 459, 486, 498, 540, 566 and 663. Both have 87 consecutive fully black sampled frames from frame 663 (22.100 seconds) through frame 749; the sampled decoded tail has maximum RGB value zero. This matches the reference's picture structure and runtime.

## Editorial and picture review

The final edits retain the source's room/paper alternation, progressive red opening, giant red replacement words, rapid prop inserts, uncaptained dry ending and black tail. Author identity, cream-paper treatment, performances and story-specific props are adaptations. They are not shot-for-shot replacements of Minecraft geometry or acting.

The initial review caught undersized serif type at approximately 14–16% of picture height. This was corrected before final delivery. Final ADB R5 and Nemi R7 use tall, horizontally compressed red serif words, matching the source's approximately 35–37% cap-height emphasis. Sampled headline bounds are fully inside the picture, although long words intentionally approach the side edges.

| Movie and time | Red-letter bounds, left/top/right/bottom in 1920×1080 | Height share |
| --- | --- | --- |
| ADB R5, 4.250 s, ADB | 485 / 28 / 1412 / 422 | 36.5% |
| ADB R5, 7.000 s, UNDERWATCHED | 4 / 28 / 1909 / 430 | 37.2% |
| ADB R5, 12.000 s, THE | 534 / 37 / 1388 / 422 | 35.6% |
| ADB R5, 13.000 s, STORYTIME | 24 / 28 / 1908 / 430 | 37.2% |
| Nemi R7, 4.250 s, NEMI | 376 / 37 / 1526 / 426 | 36.0% |
| Nemi R7, 7.000 s, OVERTHINKER | 13 / 29 / 1919 / 430 | 37.1% |
| Nemi R7, 13.150 s, ANIMATOR | 7 / 29 / 1919 / 430 | 37.1% |

For comparison, source THE at 12.000 seconds has bounds 170 / 12 / 454 / 141 in 640×360, equivalent to 510 / 36 / 1362 / 423 at 1080p. The final ADB THE closely matches this normalized placement and height.

Full-cut shot-midpoint contact sheets were inspected for the earlier picture-identical staging; affected typography and critical props were then re-extracted from the final movies. Final evidence also appears in each episode's `review/full_r5_contact.jpg` or `review/full_r7_contact.jpg`.

## Prop contact and staging

ADB notebook contact was inspected in the R4 contact proof at scene times 14.7, 15.3, 15.433, 15.9, 16.167 and 16.2 seconds, then reconfirmed at 15.750 seconds in the final R5 full cut. The book meets his right hand along its left edge, the hand draws in front, the complete book fits the insert, and sampled held contact is stable. The resting notebook and later laptop meet their desks. The workload close-up avoids an accidental edge crop of the actor. No remaining contact defect was identified in these samples.

Nemi's final R7 desk/laptop visibly meet at the 14.333–15.300-second insert, and her right hand meets the pages at 15.750 seconds. The 16.600–18.000-second story-page panel is intentionally held symbolic artwork beside her, not a physical stack being dropped or suspended by a grip. Its fixed placement and absence of a support surface are consistent with that stated direction. The source's broad arms-open insert is adapted to each author's existing performance rather than reproducing its arm geometry.

## Audio continuity evidence

ADB R5's decoded 32-bit float stereo PCM is byte-identical to the earlier R2 and R4 full cuts. SHA-256: `d48a5e5fab9bd2a26627a7363a0bb41900daf8d9cf252729324f65ec5d515451`.

Nemi R7's corresponding decoded PCM is byte-identical to R5 and R6. SHA-256: `c65855527eb7b8950ad4f88ef95004c77d42546f2f63c7ada806882fb3900446`.

These exact comparisons establish that picture-only revisions did not alter the encoded audio used by the earlier ASR checks. They preserve the relevance of those script/content checks. They do not certify subtle source-voice leakage, separation quality, SFX audibility or listening quality. Source soundtrack and separated/hybrid music provenance remain documented in `AUDIO_STUDY.md` and the companion JSON records. Human perceptual listening remains a review limitation, not a completed check.

No 4K export or user-approval receipt was created by this reviewer. Older movies and recordings remain preserved.
