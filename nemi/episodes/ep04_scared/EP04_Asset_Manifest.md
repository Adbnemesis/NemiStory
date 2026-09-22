# EPISODE 04 — ASSET MANIFEST
## "Guys, I'm Scared." (`ep04_scared`)

---

## 1. Production Master Renders
- **Master 4K Video**: `nemi/episodes/ep04_scared/renders/EP04_Guys_Im_Scared_4K_Master.mp4` (64.28 MB, 73.20s, H.264 + AAC 4K UHD 3840x2160 @ 30 FPS)
- **Episode Thumbnail**: `nemi/episodes/ep04_scared/thumbnail.png` (1920x1080)

## 2. Audio Master Assets
- **Full Master Voiceover**: `nemi/episodes/ep04_scared/audio/EP04_voice.wav` (73.20s, Qwen3-TTS Sohee)
- **Master Voiceover MP3**: `nemi/episodes/ep04_scared/audio/EP04_voice.mp3`
- **Approved Preview Reference**: `nemi/episodes/ep04_scared/audio/EP04_sohee_human_preview.mp3`
- **Segment Voice Files** (`nemi/episodes/ep04_scared/audio/segments/`):
  - `seg01_terrified.wav` (9.52s)
  - `seg02_not_horror.wav` (6.88s)
  - `seg03_love_making.wav` (6.88s)
  - `seg04_refresh_2am.wav` (8.64s)
  - `seg05_what_if.wav` (7.44s)
  - `seg06_other_animators.wav` (7.12s)
  - `seg07_because_i_care.wav` (6.40s)
  - `seg08_overthinking.wav` (6.72s)
  - `seg09_signoff.wav` (9.60s)

## 3. Scenes and Choreography
- **Base Beat Class**: `nemi/episodes/ep04_scared/Ep04BaseBeat.gd`
- **Subtitle System**: `nemi/episodes/ep04_scared/Episode04Subtitles.gd`
- **Doodle & Storycard Toolkit**: `nemi/episodes/ep04_scared/Ep04Doodles.gd`
- **Master Controller**:
  - `nemi/episodes/ep04_scared/EP04_Scared.gd`
  - `nemi/episodes/ep04_scared/EP04_Scared.tscn`
- **Beat Scenes & Scripts** (`nemi/episodes/ep04_scared/beats/`):
  - `Beat01_RawConfession.tscn` / `.gd`
  - `Beat02_NotHorror.tscn` / `.gd`
  - `Beat03_ObsessingFrames.tscn` / `.gd`
  - `Beat04_Refresh2AM.tscn` / `.gd`
  - `Beat05_OverthinkingDoubts.tscn` / `.gd`
  - `Beat06_ProdigiesAndChaos.tscn` / `.gd`
  - `Beat07_BecauseICare.tscn` / `.gd`
  - `Beat08_GroundedDetermination.tscn` / `.gd`
  - `Beat09_CasualSignoff.tscn` / `.gd`

## 4. Render & Automation Tooling
- **Pipeline Runner**: `nemi/episodes/ep04_scared/tools/render_ep04.py` (Supports `--mode all`, `--mode beat`, `--mode audit`, `--force`)
- **Review Previews** (`nemi/episodes/ep04_scared/previews/`):
  - Individual beat preview MP4s (Beats 1–9)
  - 18 high-resolution audit review frames (`audit_1080p/`)
