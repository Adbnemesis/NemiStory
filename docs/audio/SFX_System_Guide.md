# NEMI — SFX & AMBIENCE SYSTEM GUIDE V1.1

> **System Purpose**: Illustrated storytelling audio layer for YouTube videos.  
> **Total Vault Assets**: 172 sound effects across 18 categories (159 Event SFX, 13 Ambience Beds).  

---

## 1. Strict Audio Classification: SFX vs. Ambience

- **Event SFX (Duration < 3.0s)**: Strictly momentary, punctual actions (pops, boings, impacts, clicks, pencil scratches, short gestures). Never placed continuously under dialogue.
- **Ambience Beds & Loops (>10.0s)**: Sustained environmental atmosphere (room tone, rain, car cabin, distant traffic). Kept strictly at background levels (-18dB to -24dB) and only used when narratively justified. Never constant across every shot.

---

## 2. Nemi Core Sound Palette (34 Go-To Sounds)

These 34 sounds define the signature auditory language of Nemi videos. Fast to reach, instantly recognizable, and perfectly calibrated.

| Core Sound ID | Category | Type | Primary Use Case | Target Mix Level |
| :--- | :--- | :--- | :--- | :--- |
| `cartoon_pop_bubble_01` | cartoon | event_sfx | Crisp cartoon bubble pop | accent (-2dB) |
| `cartoon_pop_bubble_tiny_02` | cartoon | event_sfx | High-frequency tiny bubble pop | accent (-2dB) |
| `cartoon_pluck_pop_01` | cartoon | event_sfx | Bright organic pluck / accent pop | accent (-2dB) |
| `cartoon_boing_spring_01` | cartoon | event_sfx | Comedic cartoon spring twang boing | lead (0dB) |
| `cartoon_slide_whistle_01` | cartoon | event_sfx | Classic cartoon toy slide whistle | accent (-2dB) |
| `cartoon_wobble_comic_01` | cartoon | event_sfx | Comedic horizontal wobble resonance | normal (-3dB) |
| `whoosh_gesture_fast_01` | whooshes | event_sfx | Fast arm gesture air whip | accent (-2dB) |
| `whoosh_gesture_soft_02` | whooshes | event_sfx | Soft hand pointing swoosh | low (-6dB) |
| `whoosh_camera_punch_03` | whooshes | event_sfx | Camera punch-in low air rush | accent (-2dB) |
| `whoosh_air_clean_01` | whooshes | event_sfx | Clean crisp air whoosh | normal (-3dB) |
| `impact_drop_soft_01` | impacts | event_sfx | Soft wooden/cardboard drop settle | normal (-3dB) |
| `impact_drop_soft_02` | impacts | event_sfx | Medium prop landing on surface | normal (-3dB) |
| `impact_soft_thud_01` | impacts | event_sfx | Soft body/cushion thud | normal (-3dB) |
| `impact_wood_tap_01` | impacts | event_sfx | Light wooden tap / pencil knock | normal (-3dB) |
| `impact_punch_medium_01` | impacts | event_sfx | Stylized comedic punch impact | lead (0dB) |
| `impact_slap_snap_01` | impacts | event_sfx | Comedic quick face slap / clap | lead (0dB) |
| `comedic_record_scratch_01` | comedic | event_sfx | Classic vinyl record scratch stop | lead (0dB) |
| `comedic_sad_trombone_01` | comedic | event_sfx | Classic slow sad trombone failure sound | lead (0dB) |
| `comedic_wrong_buzzer_01` | comedic | event_sfx | Game show wrong answer fail buzzer | lead (0dB) |
| `sting_question_chime_01` | stings | event_sfx | Curious upward question chime | accent (-2dB) |
| `sting_achievement_bell_01` | stings | event_sfx | Bright achievement victory bell | accent (-2dB) |
| `sting_fairy_sparkle_arcade_01` | stings | event_sfx | Cute arcade magic sparkle twinkle | accent (-2dB) |
| `sting_bell_dramatic_01` | stings | event_sfx | Heavy bell resonance chime | lead (0dB) |
| `ui_click_tactile_01` | ui | event_sfx | Clean tactile UI button click | normal (-3dB) |
| `ui_tick_subtle_01` | ui | event_sfx | Subtle clock tick / timing pulse | low (-6dB) |
| `ui_confirm_chime_01` | ui | event_sfx | Clean confirmation chime | normal (-3dB) |
| `ui_blip_comic_01` | ui | event_sfx | Comic dual-tone eye blink / realization blip | normal (-3dB) |
| `paper_page_flip_01` | paper | event_sfx | Quick notebook page turn | normal (-3dB) |
| `paper_book_open_01` | paper | event_sfx | Book / notebook opening sound | normal (-3dB) |
| `drawing_pencil_write_short_01` | drawing | event_sfx | Short pencil scribble write | accent (-2dB) |
| `drawing_scratch_scribble_01` | drawing | event_sfx | Pencil/ink on paper scratch | accent (-2dB) |
| `food_water_sip_01` | food | event_sfx | Clean sip of water from cup | normal (-3dB) |
| `ambience_room_tone_quiet_01` | ambience | ambience_bed | Clean quiet indoor room tone loop | bed (-14dB) |
| `reaction_female_gasp_surprised_01` | reaction | event_sfx | Subtle female surprised inhale gasp | accent (-2dB) |

---

## 3. Nemi Audio Principles

1. **Event Punctuation**: Sounds represent distinct physical or comic events. Never play a sound simply because time has passed.
2. **Voice Priority**: Nemi narration always sits at the top of the mix (-16 LUFS vocal target). SFX never mask vocal clarity.
3. **Deadpan Silence**: Silence is treated as an active joke element. Major punchlines and awkward beats must be left quiet.
4. **Restraint Over Clutter**: One well-placed pop or thud is far more funny than a continuous wall of Foley.
