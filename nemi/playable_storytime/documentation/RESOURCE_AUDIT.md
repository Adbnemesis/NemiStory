# Resource audit and reuse boundary

Audited 25 October 2026. The production directory is `nemi/playable_storytime/`. Existing storytime episodes, Shorts, rigs, settings, shared code, root manifests and lockfiles are read-only inputs. New adapters, copied resources, model/cache data, generated media and review records stay in this directory.

## Actual installed capabilities

| Resource | Original location | Isolated use |
| --- | --- | --- |
| Godot desktop executable | `/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot` | The renderer makes a portable local copy under `cache/godot/`; it does not alter the original application. |
| FFmpeg / FFprobe | `/opt/homebrew/bin/ffmpeg`, `/opt/homebrew/bin/ffprobe` | Existing tools encode, mux, inspect and measure output. No installation or root configuration change. |
| Python ML runtime | Repository `.venv/bin/python`, Python 3.11 | Existing MLX Audio 0.5.3, MLX, MLX Whisper, NumPy and SoundFile packages are read-only dependencies. |
| Canonical Nemi voice | `tools/tts/config.py`, `engine.py`, `pacing.py` | Byte-identical copies under `engine/voice/canonical/`, pinned by SHA-256. Exact Sohee speaker, English, identity instruction and model settings preserved. |
| Cached voice weights | Existing local Hugging Face Qwen3-TTS 1.7B CustomVoice bf16 snapshot | Dereferenced byte-identical copy under `.cache/models/qwen/`; provenance lists every file hash. 4,520,195,613 bytes copied. |
| Cached word recognizer | Existing local MLX Whisper Tiny snapshot | Dereferenced copy under `.cache/models/whisper/`; 74,420,189 bytes copied and checked. Approximate words, not phoneme alignment. |

Local voice generation succeeded only after granting the process access to the Mac's Metal GPU. It uses local copied weights with offline flags; no substitute voice or model download was used. Temporary files, model/runtime caches and bytecode are redirected inside this project.

## Animation resources reused without changing originals

The frozen Godot workspace contains 233 copied dependency files, recorded in `engine/godot/dependency_provenance.json`. Bootstrap checks these copies before reuse and refuses changed frozen dependencies rather than silently pulling later edits from the normal workflow.

- Nemi rig and controls: `nemi/characters/nemi/`, including `nemi.tscn`, existing poses, expressions, hands and mouth shapes.
- ADB rig/pose dependencies: `adb/characters/adb/` and `adb/poses/`, required because the shared production stage preloads both authors; this episode still performs Nemi.
- Existing version-2 direction, grounded acting and stable live drawing: `common/storytime/`, `common/engine/` and copied validator/preflight modules.
- Character-specific profile: `common/storytime/profiles/nemi.json` and its lettering alphabet. Rounded warm plum ink and authored Nemi marks remain distinct.
- Original technical references and required production readings are copied alongside the isolated stage; episode-specific reading receipts remain under Episode 001.

The original `tools/storytime/render_scene.py` writes repository-root `override.cfg` and `.godot/` state, so this project does not invoke that renderer against the original root. Its isolated adapter validates the copied production scene and renders into in-project paths. The adapter adds spherical composition without rewriting the character rig or live-ink player.

## Actual visual references

The current colour reference is the actual movie `nemi/episodes/ep06_how_i_animate/renders/EP06_How_I_Actually_Make_Storytime_Animations_1080p.mp4`. The approved balance reference is EP11 R10, with its saved scene and `NEMI_EP11_I_Really_Need_Your_Help_r10_4K_FINAL.mp4` master. These files are read-only references, not source footage to insert into the new fictional story.

The required treatment is cream paper, readable dark ink, soft neutral washes, canonical auburn hair/sage clothing and selective clue emphasis. Episode-specific school scenery and puzzle props are authored inside this project.

## Sound provenance

Episode 001 copies four existing recorded Mixkit SFX selections: a single book-page sound, cartoon bounce, camera transition and pencil lettering. `episodes/episode_001/sound_plan.json` records their original vault paths, URLs, recorded commercial-use license, hashes and cue intentions. The source vault remains unchanged. These are existing recordings, not procedural replacements. Recorded provenance is retained honestly; this audit does not claim a new independent legal determination.

The root meme MP3 inventory was inspected. Its licenses are explicitly unrecorded, so those clips are not described as cleared. Older procedural placeholder SFX are excluded. Commercial song previews in the Shorts library and music extracted from another creator's video were not treated as licensed music for this production.

Episode 001 instead has an original score, **A Small Favour**, authored in `tools/score.py`: 78 explicit keyboard-note events rendered with a deterministic soft electric-piano instrument. It contains no sampled recording. `episodes/episode_001/audio/score_composition.json` records the note list, synthesis method, speech ducking and output hash. This is musical composition; event SFX remain the separately sourced recordings.

## Verification boundaries

The isolation baseline/report and frozen dependency hashes provide technical preservation evidence. Voice checks confirm exact source/final hashes, canonical module hashes, measured word timing, authored windows and the exact authored narration duration (240 seconds for R6). They do not establish perceptual listening quality.

Actual full-movie review, thumbnail inspection, spherical viewpoint playthrough and YouTube processing/playback are separately recorded QA stages. A local spherical preview does not prove YouTube compatibility. No production approval receipt is created by tests; all approval-guard fixtures are disposable synthetic data. The current complete 1920×1080 review still requires the user's explicit satisfaction before a 4K movie export.
