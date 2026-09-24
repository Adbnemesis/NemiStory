# EPISODE 05 — ASSET MANIFEST
## "WHAT IS GOING ON WITH YOUTUBE?" (`ep05_celebration`)

---

## 1. Production Master Renders
- **Master 1080p Video**: `nemi/episodes/ep05_celebration/renders/EP05_What_Is_Going_On_With_YouTube_1080p_Master.mp4` (110.81s, H.264 + AAC 1080p FHD 1920x1080 @ 30 FPS, Directive 47 Compliant)
- **Episode Thumbnail**: `nemi/episodes/ep05_celebration/thumbnail.png` (1920x1080)

## 2. Audio Master Assets
- **Full Master Voiceover**: `nemi/episodes/ep05_celebration/audio/EP05_voice.wav` (110.81s / 1m 50.8s, Qwen3-TTS Sohee 48kHz stereo)
- **Voice + SFX Master Track**: `nemi/episodes/ep05_celebration/audio/EP05_audio_sfx_master.wav` (110.81s, 35 calibrated SFX cues, -4.74 dBFS peak headroom)
- **Master Voiceover MP3**: `nemi/episodes/ep05_celebration/audio/EP05_voice.mp3`
- **Segment Voice Files** (`nemi/episodes/ep05_celebration/audio/segments/`):
  - `seg01_freeze.wav` (12.27s)
  - `seg02_seven_views.wav` (10.48s)
  - `seg03_counter_climb.wav` (11.66s)
  - `seg04_explosion_1000.wav` (7.95s)
  - `seg05_human_beings.wav` (11.78s)
  - `seg06_comments_avalanche.wav` (8.27s)
  - `seg07_reading_comments.wav` (12.93s)
  - `seg08_instagram_surprise.wav` (11.94s)
  - `seg09_creator_reality.wav` (12.45s)
  - `seg10_warm_signoff.wav` (11.07s)
- **SFX Timeline**: `nemi/episodes/ep05_celebration/ep05_sfx_timeline.json` (35 SFX cues mapped across 10 beats)

## 3. Scenes and Choreography
- **Base Beat Class**: `nemi/episodes/ep05_celebration/Ep05BaseBeat.gd`
- **Dynamic Backdrop System**: `nemi/episodes/ep05_celebration/Ep05CelebrationBackdrop.gd` (5 multi-state lighting/wall themes)
- **Procedural Doodle & Prop Library**: `nemi/episodes/ep05_celebration/Ep05Doodles.gd` (Counter, Giant 1000, Comment Bubbles, 24 Tiny Humans, Phone IG, Physical Cards)
- **Subtitle System**: `nemi/episodes/ep05_celebration/Episode05Subtitles.gd` (87 cards, strictly <= 5 words per card)
- **Master Controller**:
  - `nemi/episodes/ep05_celebration/EP05_Celebration.gd`
  - `nemi/episodes/ep05_celebration/EP05_Celebration.tscn`
- **Beat Scenes & Scripts** (`nemi/episodes/ep05_celebration/beats/`):
  - `Beat01_AnalyticsFreeze.tscn` / `.gd` (Desk freeze, TODO sticky note, shock snap)
  - `Beat02_SevenViewsFlashback.tscn` / `.gd` (EP04 callback, 2:04 AM 7 views card, sheepish blush)
  - `Beat03_CounterClimb.tscn` / `.gd` (Animated ticking subscriber counter 1 -> 17 -> 84 -> 500 -> 999)
  - `Beat04_MilestoneExplosion.tscn` / `.gd` (Celebration wall, giant hand-drawn 1000, streamer confetti)
  - `Beat05_HumanBeings.tscn` / `.gd` (Visual metaphor: 24 tiny animated waving stick figures)
  - `Beat06_CommentsAvalanche.tscn` / `.gd` (Cascading comic comment bubbles with genuine community remarks)
  - `Beat07_CommentGratitude.tscn` / `.gd` (Intimate close-up, sketch heart card, emotional warmth)
  - `Beat08_InstagramSurprise.tscn` / `.gd` (Smartphone buzz, 250 followers notification, energetic fist pump)
  - `Beat09_CreatorReality.tscn` / `.gd` (Sincere warm studio lighting, animation timeline sketchbook)
  - `Beat10_WarmSignoff.tscn` / `.gd` (Physical handwritten "THANK YOU <3" & "NEW VIDEO SOON" cards, warm parting wave)

## 4. Render & Automation Tooling
- **Pipeline Runner**: `nemi/episodes/ep05_celebration/tools/render_ep05.py`
- **SFX Mixer**: `nemi/episodes/ep05_celebration/tools/mix_ep05_sfx.py`
- **Review Previews** (`nemi/episodes/ep05_celebration/previews/`):
  - 14 high-resolution visual audit review frames (`audit_frames/`)
