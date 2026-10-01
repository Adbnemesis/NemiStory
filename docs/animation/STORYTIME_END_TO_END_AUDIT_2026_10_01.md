# Nemi / ADB storytime audit — 1 October 2026

## Conclusion

The largest opportunity is stronger direction: readable framing, a clear change of thought, selective movement, and precise voice-driven timing. The shared live-ink system and separate drawing profiles provide a useful foundation. They do not, by themselves, make a compelling episode. The current ten-second direction proof also needs stronger framing and more dramatic acting contrast before it should become an artistic benchmark.

Keep both character rigs, definitions, pose/expression libraries, hands and lip systems intact. Improve external direction, new scene assets, audio preparation and production checks. Existing episodes remain unchanged; they are evidence for this audit.

## Scope and evidence boundary

Reviewed the production workflow, character guides, script/style/reference analysis, shared stage/acting/ink/audio code, voice generation/segmentation, representative episode choreography, timing/subtitle generators, scripts or saved spoken segments for Nemi EP01–08 and ADB EP00, and their existing masters. Inspected sampled frames from all nine masters, both local Pegi references, and the new ten-second proof. Measured durations, narration energy gaps and exported audio loudness. Ran local cached Whisper Tiny on three short voice excerpts to spot-check word timing.

This is a source, measurement and sampled-frame audit. It does **not** certify full continuous playback, subjective voice quality, manually verified phoneme alignment, or audience retention. No channel analytics were available. Creative judgments below are editorial assessments; retention effects remain hypotheses to test.

Raw results, input hashes and method: [measurements](audits/2026-10-01_measurements.json). Local contact sheets: `renders/storytime_audit/nemi_early.jpg`, `nemi_recent.jpg`, `adb_references_proof.jpg`.

Preservation check: all 2,168 files in the existing character/episode protection baseline retain their recorded hashes. This audit adds documentation and separate diagnostic stills only; it introduces no production behavior change.

## 1. Framing and visual attention — highest creative priority

Many sampled episode shots show a relatively small standing character, room furniture and substantial empty canvas. Facial changes become hard to read at phone size. EP08's two-character layouts further reduce each face. The new proof retains much of this wide composition.

The sampled Pegi frames frequently make the face, shoulders and gesture the main image. They also change visual scale and representation: a close character portrait, a simplified aside, a prop or an image. This is a useful compositional lesson, rather than a requirement to copy those drawings.

For new episodes:

- Establish the room when its geography matters, then use a readable medium or close view for narration and reactions.
- Reserve full-body shots for a physical gag, contact, entrance or spatial relationship.
- Compose dialogue around who is thinking or reacting. Use reaction singles, a prop insert and a return to the two-shot where appropriate.
- Give each beat one primary focus: face, object, illustration or written aside. Reduce background detail behind that focus.
- Check the actual rendered composition at roughly phone viewing size. Readability must survive downscaling; a 4K export does not solve weak composition.

The new stage supports static camera framing per shot. Continuous camera moves and more complex shot choreography still need external, authored support. A closeup can use the existing vector rigs without changing them.

## 2. Hooks, story structure and endings

EP03 has a strong causal story: an instruction, overconfidence, distraction, increasingly absurd attempts, discovery and a concrete consequence. EP07 also has a clear bad decision and payoff. EP01 has a specific discovery and a warm emotional resolution. Preserve those strengths.

Several other scripts lean on introductions, explanation, lists of interests, generic surprise, repeated reassurance or repeated channel promotion. These can express personality, but the viewer's reason to continue needs to remain clear.

Specific observations:

- **EP07:** the exam-change email arrives at 46.33 seconds of source time, about 40.29 seconds in the sped-up export. Exam day arrives around 63.42 exported seconds. Much of the first half explains circumstances after the opening already promises zero marks. Future stories could reach the decision and disruption sooner, then spend more time on the surprising consequences.
- **ADB EP00:** sports, gaming, anime, gym and work create a biography/list structure. The opening and closing shove give it a useful callback. Future ADB stories would benefit from one central predicament that connects these details.
- **EP08:** the repeated refusals form a usable comic escalation. The ending promotes the channel in both ADB's introduction and Nemi's following turn. A future promotional story could land one clear invitation and finish on the stronger character joke.
- **EP02:** mutual support and friendship recur in the final lines. Choose the strongest emotional statement and let a specific image carry the rest.
- **EP06:** the process explanation takes about 13 seconds before the first step; the ending explains the journey again. A future process story could open on a concrete production mishap, explain the necessary steps, and resolve that mishap.

For each new story, write five answers before expanding the script: What does the character want? What choice creates trouble? What changes the plan? Why does this matter personally? What is the final payoff or emotional change? Pixar's teaching on [stakes](https://www.khanacademy.org/computing/pixar/storytelling/character/v/stakes) is useful here: the consequences of choices give the audience a reason to care.

The first shot and line should deliver the title/thumbnail promise with a specific situation, contradiction or question. Generic “Wait,” “Guys,” or “I have a problem” can be part of a voice, but should not become the default opening architecture. Avoid postponing the actual premise behind throat-clearing.

During the middle, connect events through choices and consequences. Escalate the problem or reinterpret it. A new background or effect should support that change. An intimate story can build curiosity and emotional understanding without forcing a crisis or a gag every few seconds.

At the end, resolve the promise, leave room for the reaction, and finish on a callback, revealing image or concise emotional line. Choose any call to action deliberately. A warm ending and a comedy button need different timing.

## 3. Voice pace and the proposed 1.15× speed

Measured rates below count words in the matching saved spoken segments and divide by full duration, including pauses. They are **wall-clock delivery rates**, not articulation speed or universal targets.

| Production | Voice source | Export duration | Source words/min | Export words/min |
|---|---:|---:|---:|---:|
| Nemi EP01 | 81.33 s | 81.33 s | 125 | 125 |
| Nemi EP02 | 102.06 s | 102.06 s | 102 | 102 |
| Nemi EP03 | 110.89 s | 110.89 s | 135 | 135 |
| Nemi EP04 | 73.20 s | 73.20 s | 107 | 107 |
| Nemi EP05, current v2 | 92.45 s | 92.47 s | 129 | 128 |
| Nemi EP06 | 141.75 s | 141.77 s | 121 | 121 |
| Nemi EP07 | 136.89 s | 119.03 s | 116 | 134 |
| Nemi EP08, both speakers | 95.41 s | 95.40 s | 118 | 118 |
| ADB EP00 | 132.41 s | 132.41 s | 133 | 133 |

The user's impression of slow delivery has measurable support in several Nemi sources. However, slower delivery in a vulnerable or reflective story is not automatically a flaw.

Two different mechanisms matter:

1. Punctuation and synthesis can create pauses inside a voice segment.
2. The concatenators add `pause_after` after the complete segment, including any existing trailing silence. EP07 declares 17.85 seconds of these gaps; EP08 approximately 13.73 seconds. This can produce unnecessarily separated delivery when both mechanisms supply the same pause.

The energy analysis found about 39.36 seconds of low-energy runs in EP02 and 50.38 seconds in EP06, using a −35 dBFS threshold and runs of at least 250 ms. Quiet phonemes, breaths and useful dramatic space can be included. These figures identify material to review; they are **not** instructions to delete that much audio.

### Speed is currently inconsistent across paths

- `tools/tts/engine.py` accepts `speed` but does not use it in the CustomVoice generation branch. Passing `speed=1.15` there alone does not apply a tempo change.
- `tools/tts/segmenter.py` does not parse the script's `[SPEED: ...]` annotations; it includes hardcoded introduction-specific adjustments instead.
- EP07's exporter explicitly applies video PTS scaling and audio `atempo=1.15`. Its existing exported master is **already** sped up.
- EP05 has an older explicit tempo-processing route and a separate current v2 recording. Its old 110.807-second timing manifest does not describe the current 92.45-second voice master.
- EP08 controller/export comments mention 1.15× while its current generator declares native speed and the inspected exporter does not implement that tempo transform. Comments are not evidence of applied speed.

### Recommended policy for new productions

First tighten redundant wording and review unintentional leading/trailing pauses. Then compare a new representative Nemi excerpt at 1.00×, 1.10× and 1.15× with pitch-preserving tempo processing. FFmpeg provides an [audio tempo filter](https://ffmpeg.org/ffmpeg-filters.html#atempo).

Use 1.10–1.15× as an audition range for explanatory passages, subject to listening. Preserve deliberately authored breaths, punchline holds and emotional pauses. Keep ADB's dry rhythm distinct rather than automatically applying Nemi's pace to both speakers. A uniform 1.15× transform shortens everything by about 13%, including important reaction time.

Finalize this edited recording **before** word alignment and animation. Save both source and final audio identities and the exact transformation. Recalculate every cue from the final voice. Subsequent blanket movie acceleration also changes pen cadence, physical motion and reading time.

Prosody needs its own review: emphasis, question intonation, certainty, embarrassment and warmth should follow the thought. Generate coherent thought-sized passages where practical, and use character-specific vocal direction. Rushed flat delivery can still feel mechanical.

## 4. Acting and animation principles through the existing rigs

The external recipe system improves stable holds, staggered joint travel and grounded standing. Fourteen recipes per character are a starting vocabulary. Their fixed durations and generic arcs are insufficient to direct every situation naturally.

Representative legacy choreography frequently assigns a pose or expression to each short subtitle card. EP07's opening changes pose repeatedly within roughly five seconds. Subtitle segmentation is a reading decision; an acting beat is a change of intention. Treating both as the same clock division creates regular pose cycling.

For new acting, record the character's objective, attention target, feeling before/after, main gesture and reason to hold. Direct a thought across several caption cards when appropriate.

| Principle | External directing improvement |
|---|---|
| Staging / appeal | Clear face, hand and body silhouette; keep the main action readable at small size |
| Anticipation | A small preparation or look before a committed action; author the lead relative to the final voice |
| Timing / spacing | Choose a crisp pose cut, a brief stepped change or a smooth travel according to the beat |
| Arcs | Block a hand's actual action path; avoid identical generic arcs for showing, grabbing and recoiling |
| Overlap / follow-through | Eyes register, body commits, arm arrives and settles; selectively preserve supported secondary response |
| Weight / balance | Support leg, pelvis and torso agree; author foot release/contact during steps |
| Exaggeration | Build from restrained reaction to a larger existing pose only when escalation earns it |
| Secondary action | A meaningful blink, finger adjustment or glance that supports the main thought |

Naturalism here means believable intent, attention and weight. A deliberate held drawing can express those qualities. Increasing interpolation or continuous movement alone will not solve them.

**Faces:** author mixed feelings and different intensities with existing eye/brow/gaze/mouth controls. Give a realization time to register. ADB's composure can crack briefly; Nemi can register a thought more openly. Avoid resetting the whole expression merely because the next caption appears.

**Hands:** use a dominant gesture and a quieter supporting hand. Point toward the actual object, maintain grip during travel, and let the hand settle. Reusing open-palm explanation everywhere flattens personality.

**Legs:** the new planted-foot solve covers standing cues. Stepping, sitting, leaning on furniture, recoil with foot travel and walking need authored contact sequences. Some legacy scenes reposition the character root between cards without showing foot transfer. Those examples should not become future directing patterns.

**Character distinction:** Nemi can have quicker visible changes of thought, rounded gestures and warmer recovery; ADB can use longer attention, economical gestures and a small break in composure. Treat these as flexible tendencies with exceptions. Different colors and pen profiles are not sufficient to distinguish performance.

## 5. Doodles, handwriting and props

Preserve the successful live-ink behavior: distance-based reveals, stable completed ink, authored pen lifts and separate Nemi/ADB profiles. Move the next investment toward narrative use and integration.

For each visual, choose its job: establish a fact, provide evidence, contradict the narration, reveal private thought, revise a claim or deliver a visual joke. A literal annotation of every spoken noun adds clutter without adding meaning.

Use established drawings and props freely. Use live drawing when the audience benefits from watching an idea appear or change. A shape should finish in time to understand it and remain long enough to read. There is no required live-drawing percentage.

Remaining limits:

- Some profile glyphs still derive from a shared alphabet; marks are distinct, but the complete alphabet is not independently drawn throughout.
- New production prop construction largely shares silhouettes and changes author ink. Extend high-use objects with character-specific contour, proportion and surface habits as needed.
- The production catalog is a small starter set. Author scene-specific objects when the story needs them.
- Hand attachment proves a grip point follows the hand. It does not prove an object looks supported, has correct finger occlusion, or travels convincingly from a surface into a grip.
- The proof demonstrates holding an object; pickup, use and put-down sequences remain a separate directing task.

Prioritize a few recurring objects with convincing contact, layer order and useful states: open/closed notebook, active laptop, phone, mug, pen and papers. Inspect important lettering for contrast and readability at phone size; the new proof's small annotations also need that review.

## 6. Backgrounds, camera and scene continuity

The legacy episodes already contain varied environments. The new kit exposes four basic backdrop kinds. Neither fact guarantees that the environment carries the story.

Give Nemi and ADB recognizably different home/work spaces. Build a small vocabulary of story locations with stable floor, desk and seating relationships. Use environment changes for time, place, imagination or emotional interpretation.

A meaningful cutaway shows the event: an exam paper, a deadline, an impossible workload or an interaction. Merely changing the wall color behind the same standing explanation may not advance the scene.

Maintain geography and relevant object state across cuts. Use scene-specific inserts, reaction closeups and occasional simplification to paper. Add a camera move only when it reveals information or changes emotional pressure. Reserve shakes and dramatic punch-ins for the intended impact; repeated accents lose contrast.

## 7. VFX and sound design

Finite, event-linked VFX are a good foundation. Give effects different intensities and narrative roles: recognition, strain, impact, embarrassment, escalation. Protect the character's face and the primary drawing from visual competition. Prepare the action, land the effect, settle, and let the consequence remain legible.

The sound catalog is broad enough for purposeful foley. Use a paper contact, key tap, mug placement or chair shift when it anchors an actual action. Maintain the existing music-off default and allow quiet aftermaths. A distinct sonic tendency per character can help without becoming a sound on every gesture.

The new mix applies gains and reserves 2 dB on narration, but this is not loudness normalization, automatic ducking, or a true-peak guarantee. Relative voice/SFX balance depends on each source file.

Measured exported audio:

| Master | Integrated loudness | Decoded true peak |
|---|---:|---:|
| EP06 | −20.4 LUFS | −1.1 dBFS |
| EP08 | −15.9 LUFS | +0.2 dBFS |
| ADB EP00 | −17.2 LUFS | approximately 0 dBFS |

EP08 is 4.5 LU higher than EP06 in this measurement. Its decoded true peak is above full scale; this flags inadequate peak headroom, without establishing audible distortion. Normalize the intended dialogue level across future productions, check SFX against it, and measure the final encoded master. Select a consistent internal loudness/peak target and verify listening clarity; a peak-only rule does not define perceived loudness.

The older SFX documentation calls the catalog CC0/public domain, while catalog entries include Mixkit's own license. Future documentation should describe the recorded per-asset provenance accurately rather than flattening those distinctions.

## 8. Synchronization, mouths and captions — highest technical priority

Several legacy card generators allocate fractions of each segment's duration. That establishes sentence coverage, not actual word boundaries. The corresponding choreography and speech calls inherit those approximate timings.

Approximate Whisper Tiny spot-checks on EP06 illustrate the concern:

| Text | Saved card starts | Estimated spoken start | Difference |
|---|---:|---:|---:|
| “But here's what” | 9.755 s | 10.74 s | about 0.99 s early |
| “No.” | 115.690 s | 116.62 s | about 0.93 s early |
| “Unacceptable.” | 116.986 s | 118.14 s | about 1.15 s early |

These are machine estimates, not certified manual boundaries. They warrant listening/waveform review before claiming precision. They also demonstrate why a validator passing “five words per card” cannot establish sync quality.

The new proof uses actual word timestamps, but chooses broad mouth shapes over word spans. It explicitly does not provide measured phoneme boundaries. That is adequate for a limited proof; closeups need a more carefully authored or reviewed viseme track using the existing mouths.

For new productions:

- Freeze final audio and save its hash. Generate word alignment from that exact asset.
- Separate spoken intervals, breaths, deliberate pauses and reaction holds.
- Use captions grouped by meaning with readable durations. Check phrase completeness, contrast, placement and competing handwritten text as well as word count.
- Review mouth closure on rests and key consonant/vowel shapes at important closeups. Caption text must not determine speech activity by itself.
- Define an event's semantic landing point and allow explicit preparation, reveal completion and reaction offsets. Some cues should start before the word and others after it.
- Preserve the new single scene clock and seekable evaluation. Legacy frame-count waits at a hardcoded 30 FPS accumulate rounding and depend on processing conditions; they should remain historical examples, not the template for new scenes.
- Store source-to-export time mapping where a final tempo transform exists, as in EP07.

Named-event equality checks are useful for simultaneous cues. They cannot judge whether the named time matches the intended spoken accent, or whether a live drawing completes at the right moment.

## 9. Documentation and reliable handoff to smaller models

The executable starter, schemas, accepted recipes and validation are substantial improvements. The remaining risk is contradictory artistic instructions and impressive-looking claims that are not enforced.

Older guides prescribe an 85% hold ratio, events every few seconds, an eight-beat formula, generic hook phrases and fixed pause ranges. Another Nemi guide permits breathing oscillation and procedural blinks despite the new workflow's still-hold and authored-blink rules. Several documents describe themselves as locked/authoritative. The new workflow establishes precedence, but a smaller model can still copy the wrong older paragraph.

Future documentation work should:

1. Label one current entry point and explicitly label older specifications as context/legacy.
2. Separate required technical contracts, character tendencies and optional artistic examples.
3. Explain when to hold, snap, step or travel with paired good/bad new examples and reasons.
4. Use a compact director brief per beat: thought, objective, feeling before/after, focus, final voice anchor, main visual action, preparation/impact/recovery, mouth/caption treatment and silence.
5. Give a small model exact templates, accepted field names, asset lookup, failure messages and a correction sequence.
6. Save reproducible voice settings, final asset hashes, timings, spec, preview and honest QA status together.
7. Separate structural pass from artistic approval. Review at actual speed, with audible sound, at small size and at important contact frames.
8. Explain that a ten-second proof checks local behavior. A separate new 30–45-second scene is useful for testing escalation, recurring layouts and pacing across multiple beats.

Specific source-level debt to address in a later implementation pass: speaker-specific parsing in the common segmenter, ignored speed tags, CustomVoice tempo handling, inconsistent timing keys/list shapes, obsolete duration/speed comments, and the concatenator's fallback `self.config.voice` field (current main callers pass `voice` explicitly). The current pipeline should fail clearly when a requested setting cannot be applied.

Do not promise that any model will make identical artistic choices. Make good choices easier to copy and poor choices easier to detect.

## 10. Audience evaluation

No retention graph or viewer-response evidence was available. The proposed creative changes should be tested on future work rather than described as proven audience gains.

YouTube's [retention guidance](https://support.google.com/youtube/answer/9314415?hl=en) defines the intro measure at 30 seconds and explains top moments, dips and spikes. Use that report to connect actual audience behavior to the script and beat sheet. A spike can indicate enthusiasm or unclear information requiring rewatching.

Record the video's title/thumbnail promise, opening premise, first complication, key payoffs and ending. Compare similar-length future episodes and distinguish new from returning viewers where data allows. Review likely causes of a dip: slow setup, repetition, unreadable image, confusing cut, early end signal or promotion. Change one major variable where practical; topic and audience differences prevent clean causal conclusions from a simple two-video comparison.

## Recommended order of work

| Priority | Work on new material | Reviewable result |
|---|---|---|
| 1 | Final voice editing, real word alignment, explicit pace policy, consistent sound level | New short narration comparison and trustworthy timing/mix record |
| 2 | Specific hook, causal script, readable close/medium framing, stronger ending | New storyboard/animatic whose story is clear without decorative effects |
| 3 | Thought-driven face/body acting, deliberate snap/step/travel, differentiated Nemi/ADB performance | Separate new acting proof with readable reactions and stable contact |
| 4 | Prop use/contact, meaningful cutaways, selective art/VFX/foley | New interaction proof showing preparation, use, consequence and recovery |
| 5 | Reconcile docs, package templates/examples and add perceptual QA | Reproducible new multi-beat scene a smaller model can build and review |

These priorities can proceed through separate new proofs without modifying established episodes or rigs. The central goal is that each beat makes the viewer understand something, anticipate something, or feel something—and that every visual and sound supports that purpose.

## Measurement reproduction

Durations/stream sizes were read with `ffprobe -show_entries format=duration:stream=index,codec_type,width,height,r_frame_rate -of json`. Loudness used `ffmpeg -i <master.mp4> -map 0:a:0 -af ebur128=peak=true -f null -` and the final summary. Energy analysis used SoundFile and NumPy, averaging channels and measuring nonoverlapping 10 ms RMS blocks below −35 dBFS; only contiguous runs of at least 250 ms were summed. This proxy must not be interpreted as phoneme-level speech detection.

Frame sampling used FFmpeg at 0.7 seconds and 24%, 62%, 93% of each exported duration, downscaled to 320×180 for comparison. ASR used the existing cached `mlx-community/whisper-tiny` with English and word timestamps, on EP06 0–13.2 s, EP06 104.5–121 s and EP08 0–6.7 s. No new model downloads or voice synthesis were used. These excerpts and intermediate diagnostics were generated separately; the original files were read only.
