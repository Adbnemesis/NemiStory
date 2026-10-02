# Current storytime directing workflow

For a new episode, enter through [Episode Start](EPISODE_START.md): complete the character-specific preparation record before authoring. The file-based validator/renderer checks this for new version-2 specs; existing exact review proofs remain reproducible.

Use this page first, then [the exact version-2 field reference](STORYTIME_DIRECTION_WORKFLOW.md) and [the two drawing identities](CHARACTER_DRAWING_PRODUCTION_KIT.md). The [end-to-end audit](STORYTIME_END_TO_END_AUDIT_2026_10_01.md) explains the evidence behind this refinement. These pages are the operational instructions for new productions. Older style/episode guides remain personality and artistic context; their hard percentages, automatic breathing/blinking, approximate sentence timing and fixed camera defaults must not override this workflow.

The approved Nemi/ADB rigs, pose/expression/hand/mouth libraries, voice configuration and old episodes remain untouched. The new code directs existing controls externally. Do not migrate old episodes as part of this improvement.

## Voice identity is fixed; pacing is editorial

Use the character's exact approved recordings whenever possible. Never change model, speaker, identity prompt, pitch, formants or voice EQ to make a scene faster. Nemi's approved CustomVoice identity is Sohee; ADB's is Aiden, with their existing settings in `tools/tts/config.py`. Do not substitute a speaker or rewrite the identity prompt. A new recording can vary naturally; it is not the same performance as a saved recording.

For an existing recording, change tempo with FFmpeg `atempo`, which preserves nominal pitch. Do not speed up audio by changing its sample rate. Start at **1.00×**; try **1.08–1.12×** for a slow explanatory passage, and audition before using up to **1.15×**. Those are working ranges, not a blanket Nemi speed rule. Preserve hesitation, breath, emotional pauses and the joke's landing. Faster speech cannot fix a repetitive script.

Split only at intentionally chosen phrase/pause boundaries. `prepare_voice.py` accepts a source hash, explicit source bounds, tempo, final placement and measured source word times. It never automatically removes silence or resynthesizes speech. The transformed word timestamps are a starting alignment: time stretching can move individual consonant onsets slightly. Listen against the final recording and refine important words. Word alignment is not phoneme alignment.

The general TTS engine now applies requested speed **after** generation through the same pitch-preserving tempo operation; it passes the unchanged identity settings to CustomVoice. `[SPEED: 1.12]` and `[PAUSE: 0.5s]` are parsed explicitly. The old introduction-specific punctuation/speed overrides are removed. `parse_intro_script(..., speaker='ADB')` selects ADB dialogue correctly. These are changes for future generation, not instructions to regenerate episodes.

Do not process an already accelerated master again without inspecting its history. EP07's saved export already uses 1.15×. Record source and final durations alongside the applied tempo.

## Write for a viewer from the first frame through the ending

Before animating, save five plain sentences in `direction`: `promise`, `want`, `choice`, `consequence`, `payoff`. Then divide the actual recording into thought beats. Every beat declares `start`, `end`, `thought`, `focus`, `visual`, `intent`. The validator checks that these exist and fit the clock; a model still has to make them meaningful.

- **Opening:** make the central tension or an intriguing consequence understandable immediately. A relatable specific situation is better than a generic introduction. Give the viewer a reason to want the answer; do not rely on a title card to supply it.
- **Development:** each beat changes the situation, the speaker's belief, or what the viewer knows. Cut repeated explanation before speeding up speech. Let an image provide evidence or contradict the line rather than illustrating every noun.
- **Escalation:** make the character's choice cause the next problem. Specific objects, places and reactions make the sequence memorable. A visual callback should mean something new when it returns.
- **Payoff:** answer or reverse the opening promise. Let the face and silence carry the reaction. Finish once the idea lands; extra doodles, sounds and moral summaries can dilute it.

There is no compulsory cut every two seconds or guaranteed retention score. A long hold with a changing thought can engage; a busy frame without a clear focus can lose people. Test the opening, the moment before the payoff and the last image at phone size. Audience retention still needs real viewing data.

## Choose the next image by its job

Use one primary action per beat. Pick a closer face shot for recognition, a wider shot for physical geography, an insert for an important object, an imagined scene for a consequence, or a quiet hold for a dry line. Establish where things are before changing contact or orientation. Judge scale against the set: a standing person must make sense beside the desk, chair, door, vehicle and other characters. A visible full body alone does not prove believable size. The starter uses a modest 1.25 actor scale, not a universal shot setting. Establish the location with authored scenery and relevant objects before choosing a closer face shot. A city trip needs a city/landmark; a car story needs an actual car/cabin/road, not only handwritten place names. Choose closer shots deliberately when expressions need emphasis, rather than applying close framing throughout.

Held props and finished doodles should be fully drawn when introduced. Use live ink when creation, revision or discovery is part of the joke. Completed lines stay still. Backgrounds establish place/mood; change them when the thought or location changes. New `studio_nemi` and `studio_adb` environments supplement `paper`, `room`, `thought`, `evening`. They are modest authored sets, not a complete location library.

Nemi keeps her rounded, looser pen; ADB keeps his compact, economical pen. Phone/mug outlines now differ by author as well as ink. Other production prop silhouettes still share construction; new important props should be authored with the appropriate character's habits. Do not add random trembling, broken pixels or changing line geometry to simulate drawing.

## Act the thought, then settle

Use one of the 14 existing external recipes per character. Eyes register; body/head commit; the gesture resolves; then hold. ADB's economy and Nemi's more expressive response should remain distinguishable. A held pose is useful; an unchanged emotional state through several different thoughts is not.

Choose `motion: smooth` for contact or a fluid commitment, `stepped` for an authored reaction sampled at 8/10/12/15 drawings per second, or `snap` for a deliberate pose cut. Stepping affects that acting transition, not voice, the scene clock, live ink, camera paths or independent hand paths. Do not quantize everything. No endless idle bobbing or random blink timers.

Use bounded `face` controls for a particular asymmetric brow, eye openness or pupil emphasis. Exact fields and units are in the field reference. Use the existing expression as the foundation; add a small adjustment with an intention. Blinks are explicit and normally fit a thought boundary or glance. Mouth cues remain authored through existing shapes, with silence closed/restored to expression; closeups need refined consonant closures and vowel intervals.

Standing feet remain planted through the external solver. Root movement does not create walking. A real step, run, seated contact, turn or larger weight transfer needs authored blocking and separate verification. This refinement does not add replacement poses or a universal movement generator.

For pickup/putdown use `hand_paths` and bounded `attach_start`/`attach_end`. Path points are actor-local; resting prop position is world-local. Put the hand socket on the prop grip at the boundary, hold the grip during travel, and return it to the surface before release. Use a compatible existing hand shape. Nemi's two-bone hand solve clamps unreachable positions, so visually check reach rather than assuming every coordinate can be attained. Verify the contact at just before/after each boundary; automatic validation cannot prove surface geometry.

## Synchronize preparation, contact and the spoken word

Everything uses seconds on one scene clock. Measure the final recording before finalizing cuts, gestures, mouths and captions. Named events anchor important words/contact. `event_offset` expresses purposeful anticipation: for example a hand begins reaching before an object sound, or a live replacement starts slightly before its spoken noun. The validator checks `at == event.at + event_offset`; it does not decide whether the timing is funny.

Caption cards contain at most five words and use word-index ranges into `audio_metadata`. Full validation verifies the final narration hash, speaker, text and caption boundaries. `--structure-only` checks schema/times without proving assets or alignment. If audio changes, reannotate and retime dependent cues; never treat old timestamps as authoritative for a new recording. Use `caption_size: 52` as a starting point and check long cards at phone size.

SFX underline a selected action. Do not sound every doodle or cut. Use the existing catalog/provenance; keep voice primary and allow silence. Calibrate the final mix after changing audio or SFX. Calibration applies one constant gain, with default −18 LUFS target and −1.5 dB true-peak ceiling; it prioritizes headroom if both cannot be met. This is a house starting point, not a platform mandate. No compression, EQ, limiting or pitch effect is added. Export checks the encoded AAC peak (must stay at or below −1 dBFS) and saves an audio QA record. Numerical levels do not replace listening.

## Reproduce and hand off

Current complete example: `common/storytime/examples/refinement_10s/scene.json`, `voice_plan.json`, and [script/beat sheet](../../common/storytime/examples/refinement_10s/SCRIPT_AND_BEATS.md). Large voice/video files remain local under `renders/`.

For a new story:

```sh
python3 tools/storytime/new_scene.py --author nemi --episode 9 --name my_new_story
# Replace the silent starter's story, shots and actions; save approved recordings.
python3 tools/storytime/prepare_voice.py --plan path/to/new_voice_plan.json --output renders/my_new_story/audio
# Save final narration/timeline paths in scene.json; author mouths and word-linked captions.
python3 tools/storytime/calibrate_mix.py --spec nemi/episodes/ep09_my_new_story/scene.json --output nemi/episodes/ep09_my_new_story/scene_calibrated.json
python3 tools/storytime/validate_scene.py nemi/episodes/ep09_my_new_story/scene_calibrated.json
python3 tools/storytime/render_scene.py --spec nemi/episodes/ep09_my_new_story/scene_calibrated.json --output renders/my_new_story/proof.mp4
```

The preparer/calibrator refuse overwriting their outputs. Source-only checks can use `validate_scene.py ... --structure-only`. If measured word timings are missing, use `align_voice.py --audio <approved.wav> --actor nemi --output <new.json>` with `.venv/bin/python` and the existing cached Whisper model. No network/model download is attempted. It marks ASR output as needing review; review uncertain words against the recording before creating a voice plan. It cannot identify multiple speakers automatically.

To rebuild this exact ten-second example with its exact saved source clips present:

```sh
python3 tools/storytime/build_refinement_proof.py
python3 tools/storytime/test_validator.py
python3 tools/storytime/test_production_validator.py
python3 tools/storytime/test_audio_mix.py
.venv/bin/python tools/storytime/test_pacing.py
python3 tools/storytime/check_engine.py
python3 tools/storytime/render_scene.py --spec common/storytime/examples/refinement_10s/scene.json --output renders/storytime_refinement/One_Tiny_Plan_10s.mp4
python3 tools/storytime/test_render_timing.py
```

The builder hashes the original recordings in `renders/storytime_direction/audio/`. It reuses a matching prepared narration; a changed plan/source requires a new output folder and fresh timing review. A source-only checkout cannot reproduce identical audio from nothing. Supply the approved hashed originals, or make a separate new test from approved recordings and annotate it. Do not synthesize a substitute and keep the old word times.

Save beside each proof: script/beat sheet, source hashes and pace plan, final timing metadata, spec, small contact sheet, audio QA, tests performed, subjective review performed, and remaining limits. Mark an unheard or unwatched check as pending. Preserve rigs/old episodes. Push source and small review artifacts; exclude movies, generated audio and model weights.


## Integrated review after the short proof

A ten-second proof isolates a mechanism; it does not verify the whole animation system. For a broader change, also render a 30–60 second story with enough time to inspect full-body acting, prop contact, expressions, environments, held art, both authors’ live ink, narration, captions, selective VFX/SFX and an ending. Use `common/storytime/examples/story_review_48s/scene.json` and its review guide. Keep feet and hands visible in review shots; do not default to close framing throughout.

ADB authored hand paths now preserve 58/55 local-unit arm lengths. Unspecified wrist angles follow the forearm. Existing rig and hand drawings are unchanged. Optional actor `hand_path_window: [start,end]` limits path ownership to that interval; elsewhere the performance recipe controls the arms. Validate and inspect both boundaries. This is not an automatic anatomy or walking system.
