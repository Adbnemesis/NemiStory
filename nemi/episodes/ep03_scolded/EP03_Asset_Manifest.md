# EPISODE 03 — ASSET MANIFEST & TECHNICAL REGISTRY
## "My Mom Scolded Me"

---

## 1. Character Rigs & Controllers

| Asset ID | Path | Type | Description |
|---|---|---|---|
| `char_nemi` | `nemi/characters/nemi/nemi.tscn` | Godot 2D Vector Rig | Authoritative Nemi character rig (Bone2D, procedural facial expressions & gesture micro-acting) |
| `char_mom` | `nemi/characters/mom/Mom.tscn` | Godot 2D Vector Rig | **Brand-new Mom character rig** matching Nemi's hand-drawn illustrated style (procedural dark ink linework, soft apron tint, maternal aura FX) |
| `controller_mom` | `nemi/characters/mom/Mom.gd` | GDScript | Mom directorial API controller (states: `departure`, `arms_crossed`, `hands_on_hips`, `scolding_wag`, `silent_stare`, `tired_sigh`; aura pulses, radar scanning arcs) |

---

## 2. Props & Illustrated World Assets

| Asset ID | Path | Type | Description |
|---|---|---|---|
| `prop_chicken` | `nemi/episodes/ep03_scolded/props/PropChicken.tscn` | GDScript Prop | Hand-drawn vector whole chicken prop with states `frozen` (solid ice block casing, frost sparkles, clink physics) and `defrost_fail` (steaming exterior, rock-hard frozen center) |
| `prop_hairdryer` | `nemi/episodes/ep03_scolded/props/PropHairdryer.tscn` | GDScript Prop | Hand-drawn vector hairdryer prop with states `off` and `blast` (hot wind turbulence streaks, heat wave distortions, cord wiggle) |
| `doodle_toolkit` | `nemi/episodes/ep03_scolded/Ep03Doodles.gd` | GDScript Toolkit | Progressive dark ink doodles (`#2b2623`): Gavel stamp, glowing sticky note, crown & sparkles, spinning clock, tire soundwaves, permafrost temperature gauge, microwave lightning sparks, maternal target reticle, cereal dinner payoff |

---

## 3. Audio & Voice Assets

| Asset ID | Path | Format | Duration | Description |
|---|---|---|---|---|
| `ep03_voice_master` | `nemi/episodes/ep03_scolded/audio/EP03_voice.wav` | 24 kHz WAV | 110.89s | Master voiceover track (Qwen3-TTS Sohee, 23 dialogue segments, Rule 7 compliant) |
| `ep03_audio_sfx_master` | `nemi/episodes/ep03_scolded/audio/EP03_audio_sfx_master.wav` | 48 kHz WAV | 110.89s | Master mixed audio track (Voice + 16 precision SFX cues, -1.20 dBFS peak, 1.20 dB headroom) |
| `ep03_audio_sfx_stem` | `nemi/episodes/ep03_scolded/audio/EP03_audio_sfx_only.wav` | 48 kHz WAV | 110.89s | Isolated SFX stem for re-mixing or balance auditing |
| `voice_alignment_json` | `nemi/episodes/ep03_scolded/timing/voice_alignment.json` | JSON | 110.89s | Authoritative master timing manifest driving subtitles and beat transitions |
| `sfx_timeline_json` | `nemi/episodes/ep03_scolded/ep03_sfx_timeline.json` | JSON | 110.89s | Precision timecodes, durations, and dB gains for all 16 sound effects |

---

## 4. Beat Scenes & Master Coordinator

| Asset ID | Path | Scene / Script | Duration |
|---|---|---|---|
| `ep03_beat01` | `nemi/episodes/ep03_scolded/beats/Beat01_Hook.tscn` | `Beat01_Hook.gd` | 13.67s |
| `ep03_beat02` | `nemi/episodes/ep03_scolded/beats/Beat02_ThePlan.tscn` | `Beat02_ThePlan.gd` | 8.67s |
| `ep03_beat03` | `nemi/episodes/ep03_scolded/beats/Beat03_Overconfidence.tscn` | `Beat03_Overconfidence.gd` | 11.09s |
| `ep03_beat04` | `nemi/episodes/ep03_scolded/beats/Beat04_CreativeTrap.tscn` | `Beat04_CreativeTrap.gd` | 9.32s |
| `ep03_beat05` | `nemi/episodes/ep03_scolded/beats/Beat05_PanicArrival.tscn` | `Beat05_PanicArrival.gd` | 8.60s |
| `ep03_beat06` | `nemi/episodes/ep03_scolded/beats/Beat06_ThePermafrost.tscn` | `Beat06_ThePermafrost.gd` | 11.73s |
| `ep03_beat07` | `nemi/episodes/ep03_scolded/beats/Beat07_EmergencyDefrost.tscn` | `Beat07_EmergencyDefrost.gd` | 18.77s |
| `ep03_beat08` | `nemi/episodes/ep03_scolded/beats/Beat08_TheScolding.tscn` | `Beat08_TheScolding.gd` | 16.36s |
| `ep03_beat09` | `nemi/episodes/ep03_scolded/beats/Beat09_PayoffOutro.tscn` | `Beat09_PayoffOutro.gd` | 12.68s |
| `ep03_master` | `nemi/episodes/ep03_scolded/EP03_Scolded.tscn` | `EP03_Scolded.gd` | 110.89s |
