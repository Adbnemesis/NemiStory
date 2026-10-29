# EP18 QA Report — Halloween Giveaway Announcement

## 1. Episode Summary

- **Episode Path**: `nemi/episodes/ep18_giveaway_announcement`
- **Current Delivery**: [ep18_giveaway_announcement_r5_1080p.mp4](../renders/ep18_giveaway_announcement_r5_1080p.mp4)
- **Target & Actual Duration**: Exactly 40.000 seconds (1200 authored frames @ 30 FPS, strictly within the $\le 40.0$s cap)
- **Video Specifications**: 1920×1080 H.264, 30 FPS, profile High, yuv420p
- **Audio Specifications**: AAC stereo, 48,000 Hz, 128 kbps
- **Integrated Loudness**: `-17.9 LUFS` (broadcast target per `AUDIO_TARGETS.md`: $-18.0 \pm 1.0$ LUFS)
- **True Peak**: `-2.1 dBFS` (safety margin $\le -1.5$ dBFS, zero clipping)

---

## 2. Voice & Audio Architecture

1. **Voice Synthesis**:
   - Synthesized using canonical `NemiVoiceConfig` (speaker `sohee`, Qwen3-TTS bf16, English 24 kHz) into 5 cohesive story lines.
   - Word alignment generated with local `mlx_whisper`.
   - Complete audio releases preserved: `clip['start'] = 0.0` and `clip['end'] = dur` so natural breathing, room tone, and trailing phonemes are 100% intact. Zero words or sentences are cut off mid-speech.
2. **Audio Preparation & Pacing**:
   - Paced using `tools/storytime/prepare_voice.py` at tempo `1.08x` with pitch preservation.
   - 0.40s silent breathing pauses authored between all 5 thoughts (pause valleys measured at RMS 0.0000).
   - Ending resting hold of 0.72s lands smoothly on exactly 40.000s.
   - Timeline and source recordings archived under `audio/prepared_r5/`.
3. **Sound Effects & Mix**:
   - 12 event-linked SFX cues sourced from canonical `common/audio/sfx/root_sfx_inventory.json`:
     - `pop.mp3` at 0.20s (intro wave pop)
     - `chime.mp3` at 2.30s (giveaway reveal chime)
     - `riser.mp3` at 6.90s (drumroll tension build)
     - `stings/sting_happy_bells_01.wav` at 9.00s (prizes fanfare)
     - `chime.mp3` at 11.15s (Custom PFP reveal)
     - `chime.mp3` at 13.65s (Spooky Doodle reveal)
     - `chime.mp3` at 16.35s (Channel Shoutout reveal)
     - `pop.mp3` at 18.50s (Discord checklist pop)
     - `pop.mp3` at 21.60s (YouTube sub checklist pop)
     - `error.mp3` at 28.15s (comedy accent on shadow clones rule)
     - `clock-ticking.mp3` at 31.20s (48 hours countdown ticking)
     - `stings/sting_happy_bells_01.wav` at 38.00s (Happy Halloween outro cheer)

---

## 3. Visual & Performance Directing

1. **Shot Progression & Framing**:
   - **Shot 1 (0.0s – 5.40s)**: Creator studio medium-wide, Nemi waves energetically with sparkle stars and "HALLOWEEN GIVEAWAY!" banner (`pleased` and `school_gasp` recipes).
   - **Shot 2 (5.40s – 18.10s)**: Drumroll suspense build into excited fanfare. Wide studio showcase, drawing tablet grounded on the desk, Nemi presenting the 3 prizes as they ink live (`prop_present`, `school_point`).
   - **Shot 3 (18.10s – 24.10s)**: Requirements checklist with Discord phone prop on the right, live inking with clean separation (`explaining`, `school_explain`, `school_point`).
   - **Shot 4 (24.10s – 33.40s)**: Comedic rules delivery, Nemi on the left reacting with confusion marks ("No shadow clones or burner alts!"), rules cleanly stacked on right, timer prop at desk (`skeptical`, `school_resolve`).
   - **Shot 5 (33.40s – 40.00s)**: Outro celebration, Nemi centered waving cheerfully, "HAPPY HALLOWEEN!" circled overhead, framed with floating heart doodle and sparkle stars (`school_relief`, `pleased`).
2. **Camera Cut Placement**:
   - Zero camera cuts occur during active speech.
   - All 4 shot transitions occur strictly inside the silent inter-sentence pauses:
     - Shot 1 $\to$ 2: at 5.40s (pause is 5.16s – 5.56s)
     - Shot 2 $\to$ 3: at 18.10s (pause is 17.93s – 18.33s)
     - Shot 3 $\to$ 4: at 24.10s (pause is 23.89s – 24.29s)
     - Shot 4 $\to$ 5: at 33.40s (pause is 33.18s – 33.58s)
3. **Visual Invariants & Ink**:
   - All illustrations and lettering use canonical Nemi ink `#513541`.
   - Text positioned with generous safety margins; zero overlap with character or props.
   - 25 caption cards strictly adhering to $\le 5$ words per card.

---

## 4. Visual Evidence & Checks

- Stills extracted across all 5 story beats in `review/stills_r5/`:
  - `still_01.5s_r5.png` (Intro greeting)
  - `still_03.5s_r5.png` (Halloween giveaway lettering)
  - `still_07.5s_r5.png` (Drumroll anticipation)
  - `still_10.0s_r5.png` (Prize 1 reveal)
  - `still_14.0s_r5.png` (Prize 2 reveal)
  - `still_17.0s_r5.png` (Prize 3 reveal)
  - `still_20.0s_r5.png` (Requirements - Discord & intros)
  - `still_23.0s_r5.png` (Requirements - YouTube & DMs)
  - `still_26.0s_r5.png` (Rule 1: 1 entry per person)
  - `still_29.0s_r5.png` (No shadow clones comedic squint)
  - `still_32.0s_r5.png` (48 hours countdown timer)
  - `still_36.5s_r5.png` (Good luck sendoff)
  - `still_38.5s_r5.png` (Happy Halloween finale)

---

## 5. Review Gate

Awaiting user satisfaction with the 1080p master review cut before rendering any 4K proof. All intermediate renders (`r1` to `r5`) preserved.
