# ADB EP05 — My Crush Blocked Me QA Report (Final 4K UHD Master)

## 1. Episode Specifications & Runtime Gate

| Parameter | Specification | Measured Result | Status |
|---|---|---|---|
| Runtime Cap | Around 2 mins & strictly under 2 minutes (< 120.0s) | 119.033s (1:59.03) | **PASSED** |
| Frame Rate | 30.0 fps | 30.0 fps (3,571 frames) | **PASSED** |
| Resolution | 3840×2160 (4K UHD) | 3840×2160 | **PASSED** |
| Video Stream | H.264 High Profile, crf 17, yuv420p | H.264 High Profile, 1837 kbps | **PASSED** |
| Audio Stream | Stereo AAC @ 48 kHz | Stereo AAC @ 48 kHz, 120 kbps | **PASSED** |
| Master File Size | N/A | 27.34 MB | **PASSED** |
| Master SHA-256 | N/A | `484bd137c24817071ea5bb5acfbbe55f6fb1ec1b8998c976ce34b26021b7e36e` | **VERIFIED** |

## 2. Audio Loudness & Headroom (EBU R128)

| Metric | Target / Constraint | Measured | Status |
|---|---|---|---|
| Integrated Loudness | -18.0 LUFS (±0.5 LU) | -18.0 LUFS | **PASSED** (Exact Target) |
| Loudness Range (LRA) | > 4.0 LU | 5.1 LU | **PASSED** |
| True Peak | ≤ -1.0 dBFS ceiling | -1.5 dBFS (0.5 dB headroom) | **PASSED** |
| Spoken Voice Continuity | Aiden canonical Qwen3-TTS | 294 words, unpitched 1.00x source | **PASSED** |
| SFX Cue Sourcing | Catalog inventory | 44 verified root/library assets | **PASSED** |

## 3. Visual & Aesthetic Conformance (Storytime Refinement & Upper-Middle Balance)

- **Color Palette Reference**: Adheres strictly to `docs/animation/STORYTIME_EPISODE_COLOUR_THEME.md` (warm cream paper `#faf6ee`, dark charcoal ink `#2b2623`, soft washes `#ece5d8`, selective rose accents `#c76b66` for crush and red `#c74b46` for BLOCKED stamp, soft blue `#6b9bc7` for chat interface).
- **ADB Standing Height & Grounding**:
  - Planted at canonical `ROOT_Y = round(894 - 192 * SCALE, 4) = 686.64` with `SCALE = 1.08`.
  - Aiden's shoe treads land firmly on floor `y = 894.0`. Standing anatomy is natural and properly proportioned.
- **Camera Framing & Elimination of Edge Cut-Offs**:
  - Camera centers at `y = 540–560` and balanced moderate zooms (`1.05–1.55x`).
  - ADB's head, face, eyes, and torso remain comfortably centered with generous headroom across all 24 shots.
- **10 Custom Hand-Inked Vector Props (`SchoolBlockedArt.gd`)**:
  - `japanese_classroom_desk`: Individual wooden desk showing middle school separation.
  - `japanese_blackboard`: Showing *日本語* and hiragana drills.
  - `school_chat_phone`: Smartphone showing the messaging app with header and contact card.
  - `chat_bubble_outgoing_1`: Outgoing text 1 (*"Hey, how's it going?"*).
  - `chat_bubble_outgoing_2`: Outgoing text 2 (*"Did you see my message?"*).
  - `deactivated_contact_card`: Blank gray avatar silhouette with diagonal slash and *"Account Not Found"*.
  - `peaceful_delusion_badge`: Golden halo, wings, and academic book banner (*"RESPECT"* for detox).
  - `rival_boyfriend_diagram`: Diagram linking crush girl to primary school rival with hearts and green online status.
  - `blocked_stamp`: Bold red calligraphic stamp: **BLOCKED** (`#c74b46`) with jagged border.
  - `broken_heart_doodle`: Shattered heart split in two with tear droplet.
- **True Animated Live Doodles (`mode: 'live'`)**:
  - 45 live ink doodles and lettering cues that visibly draw in over 0.5–0.85s intervals using Godot's progressive line rendering.
  - Every single live doodle is paired with synchronized pencil scratch SFX (`drawing_pencil_write_short_01`, `drawing_scratch_scribble_01..05`).
- **Dynamic 4-Environment Staging**:
  - `adb_studio_ep02`: Adult ADB introducing the memory and delivering the final comedic reflection.
  - `school_corridor`: Middle school corridor with lockers, clock, and section reshuffle doodle.
  - `school_classroom`: Japanese elective classroom with individual desks and chalkboard.
  - `thought`: Abstract thought space for smartphone chat screen, disappearing contact cards, and the BLOCKED revelation.

## 4. Direction & Acting

- **Story Promise**: An innocent elementary camaraderie turns into a desperate middle school double text, a vanishing profile, a year of delusion, and a crushing revelation: SHE BLOCKED ME!
- **Audience Focus**: Single clear focus per thought beat. Rest/clear secondary accents when thought concludes.
- **Performance Progression**: 45+ cues directing brow height/angle, eye openness, blush, sweat, and head tilts without per-frame tween jitter.
- **Mouth Synchronization**: 344 spoken vowel-aligned mouth shapes strictly bounded to measured Whisper timestamps.
- **Review Evidence**: 16 stills captured in native 4K at [`review/render_records/stills_4k/`](file:///Users/talus/Documents/adb/adb/episodes/ep05_my_crush_blocked_me/review/render_records/stills_4k/) and assembled into [`review/4k_contact_sheet_16shots.jpg`](file:///Users/talus/Documents/adb/adb/episodes/ep05_my_crush_blocked_me/review/4k_contact_sheet_16shots.jpg).
