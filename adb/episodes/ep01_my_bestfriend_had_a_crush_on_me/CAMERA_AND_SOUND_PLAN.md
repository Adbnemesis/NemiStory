# Camera and sound intentions — revision 1

Exact-word anchors will become named scene events after final narration is measured. Scene seconds are pending; no guessed word/phoneme timestamps. No sound has been auditioned in an exported episode mix.

## Camera

| Event / exact anchor | Focus and framing | Reason / hold or return |
|---|---|---|
| hook / “My best friend once told me” | ADB medium portrait | Personal opening; hold through next sentence. |
| school / “Back in school” | Classroom establishing wide | Actual desks, board, windows/door and student context establish school. Labels cannot substitute. Keep actor scale consistent with furniture and full-body grounding inspectable. |
| rumor / “Bro. She likes you.” | Medium classroom reaction | Skeptical eyebrow and hold; no automatic zoom on repeated “likes.” |
| serious / “No smile. No laughing.” | Reaction with friend's screen direction preserved | Gaze registers before head/body settle. Friend is an anonymous classmate, not a reused Nemi rig. |
| belief / “And suddenly... I believed her.” | Face/shoulders portrait | Read modest smile and vulnerability. Hold without camera creep. |
| evidence / “Was borrowing my homework a sign?” | Notebook on desk insert | His reinterpretation is the joke; return to ADB on “charming.” |
| confession / “Okay, honestly, I—” | Medium classroom reaction | Let interruption happen in one image. |
| reveal / “It's a prank!” | Restrained reaction portrait | Hold silently after line; no elaborate humiliation imagery. |
| accomplice / “The classmate was laughing too.” | Classroom wide/medium | Clarify setup and established geography; inspect scale and feet. |
| sanction / “She lost borrowing privileges.” | Notebook callback insert | Object returns with changed meaning. |
| payoff / “Then I needed her science notes.” | Dry portrait | End on settled expression and final hold. |

Use supported version-2 shot.camera fields. Reframe the world together, without changing actor scale for closeups. Review headroom, chin, mouth and caption separation in portraits, plus visible feet/hands in wide/contact shots. No camera paths authored yet.

## Sound

Root inventory inspected before library selection. Existing root MP3s retain original hashes; their original licenses are not recorded. Library candidates retain catalog provenance. Existing recordings only; no synthesis, procedural placeholders or BGM.

| Beat / event | Candidate and prominence | Duration / initial source gain | Reason or silence |
|---|---|---|---|
| hook | Silence | — | Personal claim carries opening. |
| school / notebook | paper_page_flip_01, recognizable detail | Up to 0.6 s / −12 dB | Only with visible authored page action; omit for still notebook. |
| rumor / louder “LIKES” | viral_pop, short commentary | 0.72 s / −10 dB | Recognition accent clear of spoken word. |
| serious | Silence | — | Preserve credible serious delivery. |
| belief | Silence | — | Protect vulnerability and hesitation. |
| evidence | drawing_pencil_write_short_01, surface detail | Up to 0.7 s / −12 dB | Only for live question mark; completed ink stays still. |
| reveal | viral_bruh after first silent recognition | 0.816979 s / −8 dB | External commentary, not dialogue; avoid overlap with “It's a prank!” |
| accomplice | Silence | — | Performance and group-project line carry joke. |
| sanction | paper_book_close_01, dry punctuation | Up to 0.5 s / −10 dB | Only with authored notebook closing action. |
| payoff | Silence | — | Reversal and final stillness land alone. |

If compact live scratch-out replaces the notebook question mark, use drawing_scratch_scribble_01 at its named revision event, without an additional overlapping accent. No effects quota. Audition excerpt attack/tail; avoid arbitrary clipping that clicks.

Before rendering: check candidates through tools/storytime/sfx_assets.py; save original file hashes; bind cue times to measured narration; calibrate constant master gain; measure cue prominence against nearby voice and encoded peak; listen at ordinary playback volume. Source gain alone does not establish audibility.
