# NEMI — SFX PROVENANCE LOG

> **Purpose**: Legal/attribution record for every sound effect used in production.
> **Rule**: No sound enters the production folder without a provenance record.
> **Policy**: CC0 and MIT-generated sounds are commercial-safe. CC-BY requires attribution.
> **NC-licensed sounds are NEVER used** (YouTube monetization).

---

## 1. Mandatory Fields Per Sound

| Field | Required |
| :--- | :--- |
| ID | e.g. `nemi_pop_001` |
| Category | POP / CLICK / WHOOSH / SWOOSH / DROP / IMPACT / BOING / BLIP / PAPER / INK / SCRIBBLE / COMEDIC_HIT / TINY_STING / TRANSITION |
| Source type | `procedural` or `library` |
| Source name | GodotSfxr preset / "Kenney Impact Sounds" etc. |
| Source URL | exact page |
| License | MIT (generated) / CC0 / CC-BY (attribution text) |
| Filename used | path inside repo |
| Notes | parameters or original file number |

---

## 2. Procedural SFX (MIT)

Synthesized via Python/NumPy pipeline (`tools/setup_nemi_sfx.py`) and **baked to 44.1kHz 16-bit WAV**; zero runtime generator cost, zero plugin bloat, 100% portable on Apple Silicon M4 / Godot 4.7.2.

| ID | Category | Synth Method | Parameters | File in Repo |
| :--- | :--- | :--- | :--- | :--- |
| `nemi_pop_001` | POP | Exponential sine sweep + transient click | f: 800Hz->70Hz, decay: 42/s, dur: 0.080s | `audio/sfx/procedural/nemi_pop_001.wav` |
| `nemi_boing_001` | BOING | FM modulated rising sweep + 2nd harmonic | f: 210->490Hz, mod: 28Hz @ 17Hz, dur: 0.360s | `audio/sfx/procedural/nemi_boing_001.wav` |
| `nemi_whoosh_001` | WHOOSH | Enveloped noise + sweeping bandpass | f: 900->2400Hz, sin^2 env, dur: 0.150s | `audio/sfx/procedural/nemi_whoosh_001.wav` |
| `nemi_blip_001` | BLIP | Dual-tone sine decay | f1: 880Hz, f2: 1320Hz, decay: 50/s, dur: 0.060s | `audio/sfx/procedural/nemi_blip_001.wav` |

---

## 3. Library SFX (Kenney CC0)

Curated selection from official Kenney packages — **only 11 essential files imported into project**, zero bloat.

> Kenney CC0: no attribution required; commercial YouTube use and redistribution explicitly permitted.

| ID | Category | Pack | File in Pack | URL | File in Repo |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `nemi_pluck_001` | POP | Interface Sounds | `Audio/pluck_001.ogg` | <https://kenney.nl/assets/interface-sounds> | `audio/sfx/library/nemi_pluck_001.ogg` |
| `nemi_pluck_002` | POP | Interface Sounds | `Audio/pluck_002.ogg` | <https://kenney.nl/assets/interface-sounds> | `audio/sfx/library/nemi_pluck_002.ogg` |
| `nemi_click_001` | CLICK | Interface Sounds | `Audio/click_001.ogg` | <https://kenney.nl/assets/interface-sounds> | `audio/sfx/library/nemi_click_001.ogg` |
| `nemi_tick_001` | CLICK | Interface Sounds | `Audio/tick_001.ogg` | <https://kenney.nl/assets/interface-sounds> | `audio/sfx/library/nemi_tick_001.ogg` |
| `nemi_drop_001` | DROP | Interface Sounds | `Audio/drop_001.ogg` | <https://kenney.nl/assets/interface-sounds> | `audio/sfx/library/nemi_drop_001.ogg` |
| `nemi_drop_002` | DROP | Interface Sounds | `Audio/drop_002.ogg` | <https://kenney.nl/assets/interface-sounds> | `audio/sfx/library/nemi_drop_002.ogg` |
| `nemi_question_001` | TINY_STING | Interface Sounds | `Audio/question_001.ogg` | <https://kenney.nl/assets/interface-sounds> | `audio/sfx/library/nemi_question_001.ogg` |
| `nemi_scribble_001` | SCRIBBLE | Interface Sounds | `Audio/scratch_001.ogg` | <https://kenney.nl/assets/interface-sounds> | `audio/sfx/library/nemi_scribble_001.ogg` |
| `nemi_switch_001` | CLICK | Interface Sounds | `Audio/switch_001.ogg` | <https://kenney.nl/assets/interface-sounds> | `audio/sfx/library/nemi_switch_001.ogg` |
| `nemi_impact_soft_001` | IMPACT | Impact Sounds | `Audio/impactSoft_medium_000.ogg` | <https://kenney.nl/assets/impact-sounds> | `audio/sfx/library/nemi_impact_soft_001.ogg` |
| `nemi_impact_light_001` | IMPACT | Impact Sounds | `Audio/impactGeneric_light_000.ogg` | <https://kenney.nl/assets/impact-sounds> | `audio/sfx/library/nemi_impact_light_001.ogg` |

CC0 references:
- Impact Sounds (130 files, 2019): <https://kenney.nl/assets/impact-sounds>
- Interface Sounds (100 files, 2020): <https://kenney.nl/assets/interface-sounds>

---

## 4. Placement

Selected/cooked SFX live in `animations/<episode>/voiceover/sfx/` (per-episode) or a shared
`audio/sfx/` catalog when reusable across episodes. Reusability first: keep a shared catalog for
Nemi's recurring sounds (pop, click, boing, ink, sting, transition).