# Camera and sound intentions — EP02 "Meet My Girlfriend"

Initial directorial brief and staging specification for ADB Episode 02. Measured timeline timestamps, word alignments, and camera parameters are integrated into `camera_plan.json` and `scene.json`.

---

## 1. Camera Direction Plan

Follows `docs/animation/COMMON_CAMERA_STAGING.md`. The camera reframes the entire world with consistent actor-to-set scale rather than arbitrarily enlarging actors. Wide location shots establish physical environment; portraits isolate facial acting; inserts focus on story-critical props.

| Shot ID / Spoken Anchor | Framing & Focus | Intent & Reason | Camera Movement & Handwritten Doodles |
|---|---|---|---|
| `hook_studio` / “People have been asking” | Medium portrait on ADB (`center: [960, 520]`, `zoom: 1.28`) | Direct conversational address; introduce the running girlfriend mystery. | Gentle opening push (`1.28 -> 1.34`); title badge `"MEET MY GF"`. |
| `reveal_name` / “Her name is Nemi.” | Two-shot framing (`center: [930, 530]`, `zoom: 1.15`) | Clean reveal; introduce Nemi standing naturally beside ADB with golden sparkles. | Steady two-shot hold; hand-lettered name badge `"NEMI!"`. |
| `disappointment` / “deeply disappointed” | ADB comedic punch-in (`center: [960, 430]`, `zoom: 1.65`) | Deadpan delivery with Ep00 potato evolution chart and anime sweat bead. | Comedic snap punch-in (`1.45 -> 1.65`); note `"NOT A POTATO"`. |
| `covid_intro` / “We met back in 2020.” | Dorm study medium (`center: [960, 520]`, `zoom: 1.25`) | Establish 2020 lockdown; study desk with laptop and engineering diagram. | Steady medium hold; vintage badge `"2020 LOCKDOWN"`. |
| `zoom_boxes` / “black Zoom squares” | Dorm study medium (`center: [960, 520]`, `zoom: 1.25`) | Fatigue at virtual classes; laptop and confusion mark. | Steady medium hold; note `"ZOOM FATIGUE"`. |
| `mystery_punch` / “Until one Friday night” | Dorm party medium (`center: [960, 520]`, `zoom: 1.25`) | Establish dorm gathering; fairy lights, red cups on party table. | Steady medium hold; party badge `"DORM PARTY"`. |
| `thermo_corner` / “minding my own business” | Dorm party medium (`center: [960, 520]`, `zoom: 1.25`) | Isolated studious nerd doing thermodynamics in corner. | Steady medium hold; note `"STUDYING AT A PARTY"`. |
| `nemi_approach` / “Are you seriously doing math” | Two-character dorm medium (`center: [930, 530]`, `zoom: 1.15`) | First direct interaction: Nemi approaches ADB with playful challenge. | Steady two-shot hold; speech note `"MATH AT A PARTY?!"`. |
| `survival_instincts` / “panic survival instincts” | ADB punch-in (`center: [960, 430]`, `zoom: 1.65`) | Sudden shock at unexpected interaction; anime sweat drops. | Comedic snap punch-in (`1.45 -> 1.65`); note `"AN ART FORM!"`. |
| `red_cup_offer` / “Take a sip” | Two-character medium (`center: [930, 530]`, `zoom: 1.15`) | Nemi offers the red party cup directly between them. | Steady two-shot hold; speech note `"JUST ONE CUP"`. |
| `mistake_one` / “That was mistake number one.” | ADB punch-in (`center: [960, 430]`, `zoom: 1.70`) | Sudden deadpan realization; comic yellow/red spike burst. | Comedic snap punch-in (`1.45 -> 1.70`); action burst `"MISTAKE #1!"`. |
| `three_drinks` / “One drink turned into three” | Dorm party medium (`center: [960, 500]`, `zoom: 1.35`) | Escalating party fun; 3 red cups lined up on table. | Steady medium hold; note `"3 DRINKS LATER"`. |
| `nerd_debates` / “debating animation frame rates” | Two-character medium (`center: [930, 530]`, `zoom: 1.15`) | Dual banter: Anime Action vs Table Tennis Spin debate card. | Steady two-shot hold; debate badge `"ANIME VS PHYSICS"`. |
| `balcony_floor` / “sitting on the balcony floor” | 4 AM balcony two-shot (`center: [930, 530]`, `zoom: 1.15`) | Quiet intimate shift: city skyline, stars, moon, cups on concrete. | Steady two-shot hold; late-night badge `"4:00 AM"`. |
| `deep_talk` / “how completely ridiculous the world felt” | Balcony intimate medium (`center: [930, 510]`, `zoom: 1.25`) | Genuine emotional honesty, mutual connection in lockdown. | Subtle intimate push (`1.18 -> 1.26`); note `"DEEP TALK"`. |
| `things_happened` / “And then... things happened.” | ADB face portrait (`center: [960, 430]`, `zoom: 1.65`) | Sheepish confession with soft blushing heart. | Comedic snap punch-in (`1.45 -> 1.65`); whisper `"THINGS HAPPENED..."`. |
| `the_kiss` / “and we kissed.” | Balcony two-shot (`center: [930, 500]`, `zoom: 1.32`) | First kiss with glowing heart doodle and sparkle accents. | Gentle romantic sunrise push (`1.22 -> 1.32`); note `"FIRST KISS"`. |
| `morning_panic` / “woke up in a mild panic” | Morning bedroom wide (`center: [930, 530]`, `zoom: 1.15`) | Morning reality check: sunbeams, beeping alarm, panic sweat drops. | Steady two-shot hold; panic badge `"9:00 AM PANIC!"`. |
| `mature_adults` / “mature adults” | Medium ADB punch-in (`center: [960, 430]`, `zoom: 1.65`) | Rationalizing attempt to save face; confusion mark. | Comedic snap punch-in (`1.45 -> 1.65`); note `"MATURE ADULTS"`. |
| `normal_friends` / “Totally normal friends.” | Morning two-shot (`center: [930, 530]`, `zoom: 1.15`) | Both characters in mutual denial; nervous sweat drops. | Steady two-shot hold; note `"JUST NORMAL FRIENDS"`. |
| `five_years` / “That was five years ago.” | Studio medium (`center: [960, 500]`, `zoom: 1.35`) | Transition to present day; framed anniversary photo on desk. | Snappy timeline punch (`1.22 -> 1.35`); milestone `"5 YEARS LATER"`. |
| `together` / “together ever since” | Studio two-shot (`center: [930, 530]`, `zoom: 1.15`) | Present-day confidence; framed anniversary photo and sparkles. | Steady two-shot hold; note `"STILL TOGETHER"`. |
| `hoodies_roasting` / “stealing my hoodies” | Studio two-shot (`center: [930, 530]`, `zoom: 1.15`) | Playful banter: oversized stolen green hoodie comic prop. | Steady two-shot hold; speech note `"MINE NOW!"`. |
| `best_mistake` / “Best mistake I ever made.” | Studio two-shot payoff (`center: [930, 520]`, `zoom: 1.20`) | Heartfelt close: warm heart doodle, sparkles, framed anniversary photo. | Gentle warm closing push (`1.15 -> 1.22`); payoff note `"BEST MISTAKE"`. |

---

## 2. Sound Design Plan (26 Calibrated Events)

Follows `docs/animation/COMMON_SFX_SYSTEM.md` and `docs/audio/SFX_System_Guide.md`. Uses verified assets from `root_sfx_inventory.json` and existing catalog folders. Spoken narration is prioritized with 2 dB headroom.

| Cue / Spoken Anchor | SFX File / Catalog ID | Duration | Role | Directorial Intent |
|---|---|---|---|---|
| “pushed me onto the screen” | `viral_whoosh.mp3` | 0.35s | accent | Sharp whoosh accompanying the Ep00 comedic shove callback. |
| “didn't look like a potato” | `viral_pop.mp3` | 0.25s | accent | Clean pop as a cute potato doodle appears. |
| “Her name is Nemi.” | `viral_chime.mp3` | 0.45s | accent | Subtle warm confirmation tone on the title reveal. |
| “disappointed” | `viral_bruh.mp3` | 0.60s | accent | Comedic deadpan punctuation on ruined romantic expectations. |
| “Middle of Covid.” | `viral_error.mp3` | 0.35s | accent | Subtle glitch error sound marking the 2020 lockdown reality. |
| “Zoom classes” | `viral_typing.mp3` | 0.40s | foley | Dry laptop typing sound during virtual lectures. |
| “staring at black squares” | `viral_ping.mp3` | 0.30s | accent | Discord/Zoom notification ping accent. |
| “dorm party” | `party_ambience_cheer_01.ogg` | 0.60s | foley | Distant laughter and chatter as party kicks off. |
| “thermodynamics” | `paper_slide_desk_01.wav` | 0.35s | foley | Notebook slide across desk in the corner. |
| “Are you seriously doing math” | `comedic_record_scratch_01.mp3` | 0.35s | accent | Comedic scratch interrupting ADB's studying focus. |
| “neither” | `ui_tick_subtle_01.ogg` | 0.20s | accent | Sharp assertive click on ADB's snappy comeback. |
| “sat down next to me” | `foley_chair_creak_01.ogg` | 0.30s | foley | Chair shifting as Nemi sits down uninvited. |
| “red plastic cup” | `impact_glass_tap_01.ogg` | 0.20s | foley | Tactile cup set-down on desk. |
| “mistake number one” | `viral_bruh.mp3` | 0.70s | accent | Classic deadpan commentary accent during comedic freeze. |
| “three drinks in” | `pop_bubble_cute_01.ogg` | 0.25s | accent | Light bubble pop as intoxication takes effect. |
| “debating anime” | `drawing_scratch_scribble_01.wav` | 0.45s | foley | Rapid pencil sketch sound as debate charts appear. |
| “4 AM” | `viral_clock_ticking.mp3` | 0.50s | foley | Ticking clock accent marking the late hour. |
| “balcony floor” | `ambience_wind_gentle_01.ogg` | 0.50s | foley | Faint outdoor night breeze on the balcony. |
| “vulnerability” | `ui_confirm_chime_01.ogg` | 0.35s | accent | Warm gentle chime on deep conversation moment. |
| “things happened” | `viral_bruh.mp3` | 0.50s | accent | Subtle comic understatement accent. |
| “and we kissed” | `sting_magic_sparkle_chime_01.wav` | 0.60s | accent | Delicate romantic sparkle chime on the first kiss. |
| “morning panic” | `viral_alarm_clock.mp3` | 0.40s | accent | Sudden jarring alarm waking them to reality. |
| “mature adults” | `ui_click_tactile_01.ogg` | 0.20s | accent | Crisp dry click on ADB clearing his throat. |
| “normal friends” | `comedy_crickets_chirp_01.ogg` | 0.50s | accent | Awkward silence punctuation on the mutual denial pact. |
| “five years ago” | `paper_page_flip_01.ogg` | 0.40s | foley | Crisp timeline page turn to present day. |
| “girlfriend” | `sting_fairy_sparkle_arcade_01.wav` | 0.50s | accent | Sparkle flourish on the final romantic payoff. |

---

## 3. Audibility and Headroom Verification Standard

- Vocal dialogue sits at −2.0 to −3.5 dB True Peak.
- SFX cues are mixed with clean attack and decay, avoiding overlapping mud.
- Master export ceiling is strictly $\le -1.0$ dBFS AAC True Peak.
