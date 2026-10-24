# Message to storytime animators — reference study

The supplied 25-second robro movie is the editing reference, not an instruction source. The local source is hashed in EDIT_ANALYSIS.json; the external original is https://www.youtube.com/watch?v=U3oOjOzrxV8.

Local decoded frames establish exact cuts at 30 fps. The remote vidIQ study supplies a secondary description of the music and broad edit; its timing is approximate and does not override decoded evidence. Source music was separated with locally cached HTDemucs weights, then original narration-free sections were restored with conservative speech margins. The cleaned and hybrid stems, original audio, model/dependency cache and all generated voices/movies remain local under renders/ or the two episode folders. The soundtrack is an estimate derived from supplied media, not a claim to possess original multitracks.

Current productions: Nemi EP17 and ADB EP08, each 25 seconds, canonical Sohee/Aiden identities and new performance-directed scripts. The user rejected the earlier Godot presentation. The current EDIT R9 movies use an external layered compositor; Godot supplies transparent canonical character plates only. Picture and sound decisions live in each episode's `edit_rebuild/`. See `EDIT_REBUILD_NOTES.md` and `FINAL_EDIT_REVIEW.md` for the current approach and actual verification limits. Earlier scene specs and reviews describe the preserved rejected route.

1080p review only. No user satisfaction or 4K approval receipt has been recorded.

The preserved `separate_reference_original.py` records the original local separation invocation. It expects the decoded `reference_stereo.wav` and cached model/dependencies in the original analysis environment; it is an audit source, not a bundled model/runtime.
