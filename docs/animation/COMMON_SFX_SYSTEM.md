# Common SFX & Sound Design System
## Event-Based Audio Punctuation, Voice Dominance, and Silence Standards

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Shared across all storytime channels (Nemi, ADB, and future productions)  
**Location**: `docs/animation/COMMON_SFX_SYSTEM.md`

---

## 1. Core Sound Philosophy

> **SFX ARE SELECTIVE EXCLAMATION POINTS — NOT A CONTINUOUS WALL OF NOISE.**
> 
> In storytime animation, the spoken human voice is the centerpiece of the entire audio mix. Sound effects exist exclusively to punctuate physical interactions, emphasize comedic beats, and anchor hand-drawn visual events to tangible reality.

---

## 2. Voice Dominance & Mixing Hierarchy

```
┌────────────────────────────────────────────────────────┐
│ 1. SPOKEN NARRATION                                    │
│ Peak: -2.0 dB to -3.5 dB True Peak. Master presence.   │
├────────────────────────────────────────────────────────┤
│ 2. DIRECT EVENT SFX (Pops, Clicks, Impacts, Whooshes)  │
│ Mix Level: -6.0 dB to -14.0 dB below dialogue.         │
├────────────────────────────────────────────────────────┤
│ 3. FOLEY & SURFACE INTERACTIONS (Page turns, cloth)    │
│ Mix Level: -16.0 dB to -22.0 dB. Subtle tactile depth. │
├────────────────────────────────────────────────────────┤
│ 4. BACKGROUND MUSIC (BGM)                              │
│ STRICT POLICY: OFF BY DEFAULT.                         │
└────────────────────────────────────────────────────────┘
```

---

## 3. Strict Rules for Sound Effects

1. **Short & Crisp**:
   - Event SFX must have instantaneous transients and short decays (`0.05s` to `0.45s`).
   - ❌ **NEVER** use 3-to-5-second sound files as punctuation cues.
2. **Selective & Event-Based**:
   - Only trigger an SFX when an explicit visual event occurs:
     - Doodle draw-on / sketch: light pencil scritch or `pop.mp3`.
     - Prop placed on desk: tactile wood tap (`wood_tap.ogg`).
     - Camera punch-zoom: subtle air whoosh (`whoosh.mp3`).
     - Lightbulb realization: gentle chime (`chime.mp3`).
     - Deadpan realization: comedic fail tone or record scratch.
   - Do **NOT** add SFX to every single arm movement, eye blink, or breath.
3. **The Absolute BGM Policy**:
   - **BGM is OFF by default**.
   - Background music fills dead space, preventing comedic silence from functioning.
   - Comedic timing relies heavily on awkward pauses where the audio drops to near-silence, making the visual deadpan hilarious.
   - Music is only permitted for deliberate stylized parodies (e.g., an 80s montage parody or anime battle theme gag lasting $\le 5$ seconds).

---

## 4. Curated Core Sound Palette

All sounds must be sourced from the verified CC0 / Public Domain catalog in `common/audio/sfx/`:

| Sound ID | File Reference | Primary direct use |
|---|---|---|
| `pop_crisp` | `common/audio/sfx/pop.mp3` | Doodle reveals, thought bubbles, lightbulb moments |
| `click_soft` | `common/audio/sfx/click.mp3` | UI snaps, button presses, lock-ins |
| `whoosh_subtle` | `common/audio/sfx/whoosh.mp3` | Rapid camera reframing, arm sweeps, entrances |
| `chime_bright` | `common/audio/sfx/chime.mp3` | Positive epiphany, sparkle doodle burst |
| `page_turn` | `common/audio/sfx/paper/paper_page_turn_01.wav` | Notebook flips, book reading |
| `typing_burst` | `common/audio/sfx/computer/computer_laptop_typing_fast_01.wav` | Laptop comedy, coding, frantic texting |
| `bruh_comedic` | `common/audio/sfx/bruh.mp3` | Sudden disbelief, dumbfounded deadpan pause |
| `anime_wow` | `common/audio/sfx/anime-wow.mp3` | Exaggerated cute or awe reaction |

## New-production sound mixing

[Storytime Direction Workflow](STORYTIME_DIRECTION_WORKFLOW.md) mixes narration-only audio plus punctual cue clips. The renderer and live stage use the same times/gains, with no automatic sound for every drawing. Preserve the dry-line aftermath.
