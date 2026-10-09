# EP03 art source verification

The new computer-lab/channel catalog uses the existing shared version-2 art/background registration and `LiveDrawing` geometry. No character rig, definition, expression/pose/hand/mouth library, narration or old episode source/render was changed by this extension.

Read current refinement, direction, character drawing kit, ADB acting and colour-theme guides through the existing episode preflight reader. The root's episode-specific preparation receipt remains intact; no required document was edited. Inspected actual EP02 rendered ADB frame `review/r2_stills/r2_01_hook.jpg` and EP06's actual movie frame at27s (`review/reference/ep06_27s.png`). The symbolic bust follows the actual green shirt/slate curtain hair, and the set follows cream paper, soft neutral furniture, pale window washes and bounded red play emphasis.

Performed:

- `python3 tools/storytime/check_engine.py` passed all five existing engine suites: live ink, author identity, production, refinement and integrated review story.
- A temporary headless Godot catalog exercise loaded all seven kinds through `SceneArt.make("adb", kind)`, verified complete held art, sought backward/forward without mutating geometry, and confirmed disappearance at the lifetime end. It passed. The first run completed the art checks but reported an unwritable default user log; rerunning with a temporary explicit log path passed without source changes. The known macOS certificate diagnostic is unrelated to art.

Catalog documentation and the small field excerpt are under `docs/animation/catalogs/SCHOOL_YOUTUBE_ART.md` and episode `assets/school_youtube_example.json`. The excerpt is not a standalone playable scene, timing proof or approval receipt.

Pending: actual rendered art/staging inspection in the root's freshly validated EP03 1080p proof, full playback and sound review. Source checks do not establish visual, contact, acting or full-cut approval. Source is now held stable for those scheduled captures.
