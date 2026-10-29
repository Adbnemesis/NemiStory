# ADB EP06 — My Crush Said I Know QA Report (Final 4K UHD Master)

## 1. Episode Specifications & Runtime Gate

| Parameter | Specification | Measured Result | Status |
|---|---|---|---|
| Runtime Cap | Around 2 mins & strictly under 2 minutes (< 120.0s) | 93.167s (1:33.17) | **PASSED** |
| Frame Rate | 30.0 fps | 30.0 fps (2,795 frames) | **PASSED** |
| Resolution | 3840×2160 (4K UHD) | 3840×2160 | **PASSED** |
| Video Stream | H.264 High Profile, crf 17, yuv420p | H.264 High Profile, 2032 kbps | **PASSED** |
| Audio Stream | Stereo AAC @ 48 kHz | Stereo AAC @ 48 kHz, 120 kbps | **PASSED** |
| File Size | N/A | 23.98 MB (25,148,911 bytes) | **PASSED** |
| SHA-256 | N/A | `1118dbd8d0223522bdec1722ce843f0678ab139f317ec3a53832d198c3a75d96` | **VERIFIED** |

---

## 2. Audio Loudness & Headroom (EBU R128)

| Metric | Target / Constraint | Measured | Status |
|---|---|---|---|
| Integrated Loudness | -18.0 LUFS (±0.5 LU) | -18.0 LUFS | **PASSED** (Exact Target) |
| Loudness Range (LRA) | > 3.0 LU | 3.8 LU | **PASSED** |
| True Peak | ≤ -1.0 dBFS ceiling | -2.5 dBFS (1.5 dB headroom) | **PASSED** |
| Spoken Voice Continuity | Aiden canonical Qwen3-TTS | 234 words, 1.00x source tempo | **PASSED** |
| SFX Cue Sourcing | Catalog inventory | 43 verified root/library assets | **PASSED** |

---

## 3. Visual & Aesthetic Conformance

- **Color Palette Reference**: Adheres strictly to `docs/animation/STORYTIME_EPISODE_COLOUR_THEME.md` (warm cream paper `#faf6ee`, dark charcoal ink `#2b2623`, soft washes `#ece5d8`, selective soft blue `#6b9bc7` for lockers and phone interface, rose accent `#c76b66` for blush/crush).
- **ADB Grounding & Height**:
  - Planted at canonical `ROOT_Y = round(894 - 192 * SCALE, 4) = 686.64` with `SCALE = 1.08`.
  - Aiden's shoe treads rest firmly on floor `y = 894.0`. Standing anatomy is natural and grounded.
- **Camera Framing & Elimination of Edge Cut-Offs**:
  - Camera centers at `y = 540–560` and balanced moderate zooms (`1.05–1.55x`).
  - ADB's head, face, eyes, and torso remain comfortably centered with generous headroom across all 26 continuous shots.
- **10 Custom Hand-Inked Vector Props (`HighSchoolCrushArt.gd`)**:
  - `high_school_reshuffle_board`, `trio_seating_diagram`, `quiet_corner_desk`, `friend_group_doodle`, `why_did_you_block_me_bubble`, `she_forgot_doodle`, `math_half_yearly_exam`, `confession_text_screen`, `i_know_reply_bubble`, `high_school_anticlimax_badge`.
- **True Animated Live Doodles (`mode: 'live'`)**:
  - 40+ live ink doodles and lettering cues that visibly draw in over 0.5–0.7s intervals using progressive line rendering.
  - Every single live doodle is paired with synchronized pencil scratch SFX (`drawing_pencil_write_short_01`, `drawing_scratch_scribble_01..05`).
- **Dynamic 4-Environment Staging**:
  - `adb_studio_ep02`, `school_corridor`, `school_classroom`, `thought`.

---

## 4. Direction & Acting

- **Story Promise**: High school brings Aiden, his crush, and her boyfriend into the exact same Japanese class. He builds courage to ask why she blocked him, discovers she doesn't even remember, texts her again after the math exam, and receives a blunt two-word reply: "I know."
- **Audience Focus**: Single clear focus per thought beat. Secondary accents rest or clear when the thought finishes.
- **Performance Progression**: 48 cues directing brow height/angle, eye openness, blush, sweat, and head tilts without per-frame tween jitter.
- **Mouth Synchronization**: 272 spoken vowel-aligned mouth shapes strictly bounded to measured Whisper timestamps.
- **Review Evidence**: 16 stills captured in native 4K at [`review/render_records/stills_4k/`](file:///Users/talus/Documents/adb/adb/episodes/ep06_my_crush_said_i_know/review/render_records/stills_4k/) and assembled into [`review/4k_contact_sheet_16shots.jpg`](file:///Users/talus/Documents/adb/adb/episodes/ep06_my_crush_said_i_know/review/4k_contact_sheet_16shots.jpg).
