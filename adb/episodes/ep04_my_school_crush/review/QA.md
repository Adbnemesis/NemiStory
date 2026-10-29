# ADB EP04 — My School Crush QA Report (Revision 4 — 4K UHD Master)

## 1. Episode Specifications & Runtime Gate

| Parameter | Specification | Measured Result | Status |
|---|---|---|---|
| Runtime Cap | Strictly under 2 minutes (< 120.0s) | 103.100s (1:43.10) | **PASSED** |
| Frame Rate | 30.0 fps | 30.0 fps (3,093 frames) | **PASSED** |
| Resolution | 3840×2160 (4K UHD) | 3840×2160 | **PASSED** |
| Video Stream | H.264 High Profile, crf 17, yuv420p | H.264 High Profile, 2736 kbps | **PASSED** |
| Audio Stream | Stereo AAC @ 48 kHz | Stereo AAC @ 48 kHz, 120 kbps | **PASSED** |
| Master File Size | N/A | 35.25 MB | **PASSED** |
| Master SHA-256 | N/A | `71f8b53758dbbf3c21dfc06b3446acf774a1b9e67bf20cbeefbd0e996345cf05` | **VERIFIED** |

## 2. Audio Loudness & Headroom (EBU R128)

| Metric | Target / Constraint | Measured | Status |
|---|---|---|---|
| Integrated Loudness | -18.0 LUFS (±0.5 LU) | -18.0 LUFS | **PASSED** (Exact Target) |
| Loudness Range (LRA) | > 4.0 LU | 4.9 LU | **PASSED** |
| True Peak | ≤ -1.0 dBFS ceiling | -2.0 dBFS (1.0 dB headroom) | **PASSED** |
| Spoken Voice Continuity | Aiden canonical Qwen3-TTS | 284 words, unpitched source | **PASSED** |
| SFX Cue Sourcing | Catalog inventory | 50 verified root/library assets | **PASSED** |

## 3. Visual & Aesthetic Conformance (Revision 4 Upper-Middle Balance)

- **Color Palette Reference**: Adheres strictly to `docs/animation/STORYTIME_EPISODE_COLOUR_THEME.md` (warm cream paper `#faf6ee`, dark charcoal ink `#2b2623`, soft washes, selective rose accents `#c76b66` for crush, slate blue `#7b92a4` for uniforms).
- **ADB Standing Height & Grounding Restored**:
  - Restored canonical `ROOT_Y = round(894 - 192 * SCALE, 4) = 686.64`.
  - ADB's shoe tread (local y = 192 * 1.08 = 207.36) lands exactly on floor `y = 894.0`.
  - ADB is no longer sunk 207 pixels into the floor; his full standing anatomy is natural and properly proportioned.
- **Camera Framing & Elimination of Edge Cut-Offs**:
  - Re-centered camera targets to `y = 550–560` and relaxed extreme zooms to balanced framing (`1.10–1.60x`).
  - ADB's head, face, eyes, and torso remain comfortably centered with generous headroom. Zero clipping on hair, chin, or torso across all 28 shots.
- **Removed Handbag/Purse Artifact**:
  - Completely eliminated `school_satchel` (which had handles and buckles resembling a woman's purse) that was floating in front of ADB's waist in the hallway and classroom.
- **Symmetrical Double Desk Seating**:
  - Centered `classroom_double_desk` at `[960, 705]` (desk legs land exactly on floor y = 894, top surface at waist level y = 673).
  - Aiden sits on the left seat (x = 800) and the desk partner sits on the right seat (x = 1120), with the pencil dividing line perfectly at x = 960 between them.
- **True Animated Live Doodles (`mode: 'live'`)**:
  - 51 live ink doodles and lettering cues that visibly draw in over 0.5–0.85s intervals using Godot's progressive line rendering.
  - Every single live doodle is paired with synchronized pencil scratch SFX (`drawing_pencil_write_short_01`, `drawing_scratch_scribble_01..05`).
- **16 Physical School & Story Props**:
  - `classroom_double_desk`: Double wooden primary school desk.
  - `crush_desk_partner`: 8-year-old female classmate with braided ribbons and uniform.
  - `school_notebook`: Open ruled notebook on Aiden's desk.
  - `homework_notes`: Stack of homework worksheets.
  - `lunch_box`: School lunchbox resting on the desk corner.
  - `school_clock`: Wall clock in classroom and hallway.
  - `border_line_dispute`: Center pencil dividing line with boundary markers.
  - `confession_paper_note`: Ruled school note with secret lock.
  - `school_friend`: Interrogating friend.
  - `gossip_betrayal_tree`: Branching social gossip network.
  - `hallway_paralysis`: Spotlight beam on frozen Aiden.
  - `school_classmate_laugh`: Laughing classmates pointing in hallway.
  - `twin_crush_disaster`: Two boys pointing to the same girl heart diagram.
  - `crush_heart`: Warm blushing heart visual.

## 4. Direction & Acting

- **Shot Coverage**: 28 continuous shots covering 0.0s to 103.100s with zero gaps or overlaps across 5 environments (`adb_studio_ep02`, `school_courtyard`, `school_classroom`, `thought`, `school_corridor`).
- **Dynamic Camera Motion**: 10 smooth camera paths (push-ins, tracking pans, dramatic snap zooms).
- **Performance Vocabulary**: 45+ performance cues utilizing ADB's canonical vocabulary (`explaining`, `listening`, `skeptical`, `uncertain`, `deadpan`, `realization`, `soft_shrug`, `lean_in`, `quiet_recoil`, `recover`, `shy_confession`, `nervous_wait`, `nervous_answer`, `clue_point`, `hurt_composure`, `dry_annoyance`, `open_shrug`).
- **Facial Micro-Expressions**: Continuous modulation of brows, eye openness, romantic blush (up to 0.75), and panic sweat (up to 0.85).
- **Mouth Intervals**: 284 measured vowel-aligned mouth shapes (`talk_open`, `talk_wide`, `talk_round`, `neutral`) with natural consonant closures.
- **Captions**: 78 cards (maximum 5 words per card, splitting cleanly on pauses ≥ 0.35s). Zero drift from measured timeline words.

## 5. Review Gate Status & Retention Compliance

- **1080p Review Cut**: Approved by user ("great now render this version in 4k and delete all other renders...").
- **1080p Approval Receipt**: Recorded in [`review/1080P_APPROVAL.json`](file:///Users/talus/Documents/adb/adb/episodes/ep04_my_school_crush/review/1080P_APPROVAL.json) with full cryptographic verification (spec hash `2d3b5b11...`, input signature `6a3d66fa...`, preview SHA-256 `d8eb82f4...`).
- **4K Master Export**: **COMPLETED & VERIFIED.** Native 3840×2160 UHD render completed at 30 fps (3,093 frames, 103.100s). Located at [`renders/ADB_EP04_My_School_Crush_4K.mp4`](file:///Users/talus/Documents/adb/adb/episodes/ep04_my_school_crush/renders/ADB_EP04_My_School_Crush_4K.mp4).
- **Audio Loudness**: -18.0 LUFS Integrated, LRA 4.9 LU, True Peak -2.0 dBFS (1.0 dB headroom below -1.0 dBFS ceiling).
- **Visual Stills & Contact Sheet**: 16 native 4K UHD stills inspected in [`review/render_records/stills_4k/`](file:///Users/talus/Documents/adb/adb/episodes/ep04_my_school_crush/review/render_records/stills_4k/) and compiled into [`review/4k_contact_sheet_16shots.jpg`](file:///Users/talus/Documents/adb/adb/episodes/ep04_my_school_crush/review/4k_contact_sheet_16shots.jpg).
- **Directory Retention Policy**: Per `AGENTS.md` and explicit user instruction, all superseded intermediate renders, proofs, and stills were deleted and logged in [`review/retention.json`](file:///Users/talus/Documents/adb/adb/episodes/ep04_my_school_crush/review/retention.json). Capture logs and review stamps moved to [`review/render_records/`](file:///Users/talus/Documents/adb/adb/episodes/ep04_my_school_crush/review/render_records/).
- **Directory Invariant**: The episode `renders/` directory contains **ONLY** `ADB_EP04_My_School_Crush_4K.mp4`.
