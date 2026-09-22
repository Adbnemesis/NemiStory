# EPISODE 02 — ASSET MANIFEST & TECHNICAL REGISTRY
## "How I Met My Partner"

---

## 1. Character Rigs & Controllers

| Asset ID | Path | Type | Description |
|---|---|---|---|
| `char_nemi` | `characters/nemi/nemi.tscn` | Godot 2D Vector Rig | Authoritative Nemi character rig (Bone2D, procedural facial & expression FX) |
| `char_adb` | `characters/adb/ADB.tscn` | Godot 2D Vector Rig | **Brand-new reusable ADB character rig** (procedural anime-friendly vector character) |
| `controller_adb` | `characters/adb/ADB.gd` | GDScript | ADB directorial API controller (acting, facial states, poses, cool/cute dynamics) |
| `guide_adb` | `characters/adb/ADB_Character_Guide.md` | Markdown Spec | Official ADB visual identity & acting guide |

---

## 2. Props & Illustrated World Assets

| Asset ID | Path | Type | Description |
|---|---|---|---|
| `prop_video_call` | `episodes/ep02_partner/props/PropVideoCallWindow.gd` | GDScript Prop | Hand-drawn split video-call window with avatar frames and Wi-Fi icon |
| `prop_drink_glasses` | `episodes/ep02_partner/props/PropDrinkGlasses.gd` | GDScript Prop | Two hand-drawn tumblers with amber liquid for drunk clinking beat |
| `prop_phone` | `world/props/PropPhone.gd` | GDScript Prop | Hand-drawn smartphone prop used during texting montage |
| `doodle_toolkit` | `episodes/ep02_partner/Ep02Doodles.gd` | GDScript Toolkit | Progressive dark ink doodles (lock, chat bubbles, calendar, puzzle, manga, scale, connected pair) |

---

## 3. Audio & Voice Assets

| Asset ID | Path | Format | Duration | Description |
|---|---|---|---|---|
| `ep02_voice_master` | `episodes/ep02_partner/audio/EP02_voice.wav` | 24 kHz WAV | 102.06s | Master voiceover track (Qwen3-TTS Sohee, 22 dialogue segments) |
| `ep02_audio_sfx_master` | `episodes/ep02_partner/audio/EP02_audio_sfx_master.wav` | 48 kHz WAV | 102.06s | Master mixed audio track (Voice + 15 precision SFX cues, $\ge 1.0$ dBFS headroom) |
| `ep02_audio_sfx_stem` | `episodes/ep02_partner/audio/EP02_audio_sfx_only.wav` | 48 kHz WAV | 102.06s | Isolated SFX stem |
| `voice_alignment_json` | `episodes/ep02_partner/timing/voice_alignment.json` | JSON | 102.06s | Authoritative master timing manifest driving all subtitles and choreography |
| `sfx_timeline_json` | `episodes/ep02_partner/ep02_sfx_timeline.json` | JSON | 102.06s | Precision timecodes and dB gains for all 15 sound effects |

---

## 4. Beat Scenes & Master Coordinator

| Asset ID | Path | Scene / Script | Duration |
|---|---|---|---|
| `ep02_beat01` | `episodes/ep02_partner/beats/Beat01_Secret.tscn` | `Beat01_Secret.gd` | 7.08s |
| `ep02_beat02` | `episodes/ep02_partner/beats/Beat02_Reveal.tscn` | `Beat02_Reveal.gd` | 2.76s |
| `ep02_beat03` | `episodes/ep02_partner/beats/Beat03_OnlineCollege.tscn` | `Beat03_OnlineCollege.gd` | 10.51s |
| `ep02_beat04` | `episodes/ep02_partner/beats/Beat04_TextingMontage.tscn` | `Beat04_TextingMontage.gd` | 9.14s |
| `ep02_beat05` | `episodes/ep02_partner/beats/Beat05_GettingCloser.tscn` | `Beat05_GettingCloser.gd` | 9.06s |
| `ep02_beat06` | `episodes/ep02_partner/beats/Beat06_DrunkStory.tscn` | `Beat06_DrunkStory.gd` | 9.79s |
| `ep02_beat07` | `episodes/ep02_partner/beats/Beat07_ADBAnime.tscn` | `Beat07_ADBAnime.gd` | 16.61s |
| `ep02_beat08` | `episodes/ep02_partner/beats/Beat08_MutualIrritation.tscn` | `Beat08_MutualIrritation.gd` | 17.21s |
| `ep02_beat09` | `episodes/ep02_partner/beats/Beat09_HelpingEachOther.tscn` | `Beat09_HelpingEachOther.gd` | 6.82s |
| `ep02_beat10` | `episodes/ep02_partner/beats/Beat10_BestFriends.tscn` | `Beat10_BestFriends.gd` | 13.08s |
| `ep02_master` | `episodes/ep02_partner/EP02_Partner.tscn` | `EP02_Partner.gd` | 102.06s |
