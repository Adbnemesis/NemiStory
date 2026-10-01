# ADB — OFFICIAL VOICE PROFILE (QWEN3-TTS CUSTOMVOICE: AIDEN)
## Character Vocal Identity, Acoustic Parameters, and Performance Specification

**Document Status**: LOCKED & AUTHORITATIVE MASTER SPECIFICATION  
**Character**: ADB (Independent Storyteller & Creator)  
**Channel**: Independent ADB YouTube Storytime Channel  
**Engine**: Qwen3-TTS 1.7B CustomVoice (`mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`)  
**Voice Actor**: **Aiden** (Official Pretrained Speaker Embedding)  
**Runtime**: Apple Silicon MLX (`mlx-audio`) on M4 Mac  
**Sampling Rate**: 24,000 Hz uncompressed 16-bit PCM WAV  
**Location**: [`adb/docs/ADB_VOICE_PROFILE.md`](file:///Users/talus/Documents/adb/adb/docs/ADB_VOICE_PROFILE.md)  

---

## 1. Core Identity & Voice Actor Specification

* **Character Identity**: ADB (Age: 24, Male, Animator & Storyteller)
* **Voice Actor**: **Aiden** (Official Qwen3-TTS Predefined Male Speaker)
* **Voice Directive Prompt**:
  > *"Cool, relaxed young adult male around 24, calm conversational speech, confident, subtle dry wit, understated and natural."*

```
                      ┌──────────────────────────────┐
                      │      ADB'S VOCAL PROFILE     │
                      │  Qwen3-TTS CustomVoice: AIDEN │
                      └──────────────┬───────────────┘
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         ▼                           ▼                           ▼
┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
│  CALM COMPOSURE  │        │   DEADPAN WIT    │        │  "SECRETLY CUTE" │
│  (HERO BASELINE) │        │ (COMEDIC FREEZES)│        │   (ANIME PASSION)│
├──────────────────┤        ├──────────────────┤        ├──────────────────┤
│ • Grounded chest │        │ • Flat pitch     │        │ • Sudden warmth  │
│   resonance      │        │ • Lingering pause│        │ • Flustered rush │
│ • Relaxed ease   │        │ • Understatement │        │ • Sheepish laugh │
│ • No forced hype │        │ • Zero melodram. │        │ • Adorable geek  │
└──────────────────┘        └──────────────────┘        └──────────────────┘
```

---

## 2. ADB Performance Profile Breakdown

| Vocal Parameter | Specification & Directive |
| :--- | :--- |
| **Perceived Age** | **Around 24 years old**. Authentic young adult male in his mid-20s. Must NOT sound like a high schooler or shonen kid. Must NOT sound like a middle-aged narrator. |
| **Pitch & Register** | **Medium-low chest register (Median F0 ~147.7 Hz)**. Grounded, relaxed, masculine resonance without forced artificial bass or vocal fry. |
| **Tone** | **Cool, relaxed, dry, and charismatic**. Sounds like a witty, intelligent creative friend leaning back in a chair casually recounting an experience. |
| **Warmth** | **Understated natural warmth**. Calm, approachable, and intimate without aggressive friendliness. |
| **Cadence & Rhythm** | **Unrushed, natural flow**. Comfortable with pauses. Never rushes through sentences like a commercial ad. |
| **Deadpan & Timing** | **Master of dry comedy**. Flat, deadpan delivery accompanied by intentional 1.2s–1.6s comedic holds (*"Instead, I looked like an origami kite."*). |
| **Smug Smirk** | **Subtle playful superiority**. Slightly lifted cadence with a suppressed smirk (*"Sit down, because we need to talk."*). |
| **Secretly Cute** | **Passionate geek warmth**. When talking about anime sakuga or creative passions, his cool demeanor cracks into excited, boyish enthusiasm before catching himself (*"Wait, why are you smiling like that?"*). |
| **Contrast with Nemi** | **Grounded Low/Mid vs Energetic Mid/High**. Nemi (Sohee, F0 ~210 Hz) provides bright, rapid, bouncy forward momentum. ADB (Aiden, F0 ~148 Hz) provides relaxed, grounded, dry comedic counterpoint. |

---

## 3. What ADB Is NOT (Vocal Anti-Patterns)

* **NOT a Hype YouTube Influencer**: No shouting, no screaming *"WHAT'S UP GUYS"*, no fake forced enthusiasm.
* **NOT an Action Anime Protagonist**: No loud battle cries, no strained shonen grunts, no overacting.
* **NOT a Radio/Movie Trailer Voice**: No exaggerated radio-announcer rasp or artificial movie-trailer bass.
* **NOT Monotone Robot TTS**: No flat machine-like cadence with identical pauses at every punctuation mark.

---

## 4. Emotional Performance Matrix

| Emotional Mode | Target Speed | Typical Pause | Vocal Characteristic | Script Example |
| :--- | :--- | :--- | :--- | :--- |
| **BASELINE (Cool)** | `1.00x` | `0.30s – 0.35s` | Calm, relaxed, grounded conversation. | *"Look, I wasn't gonna say anything."* |
| **THE HOOK (Smug)** | `1.02x` | `0.20s – 0.25s` | Confident, slightly amused smirk. | *"Sit down, because we need to talk."* |
| **DEADPAN (Freeze)** | `0.92x – 0.95x` | `1.30s – 1.60s` | Flat, dry, understated delivery. | *"...Instead, I looked like an origami kite."* |
| **PASSIONATE GEEK** | `1.05x – 1.08x` | `0.20s – 0.30s` | Quickened cadence, bright enthusiasm. | *"The sakuga, the hair physics—it was insane!"* |
| **FLUSTERED / CUTE** | `0.96x` | `0.40s – 0.50s` | Slightly soft, sheepish, caught off-guard. | *"...Wait, why are you smiling like that?"* |
| **SARCASTIC WIT** | `0.98x` | `0.50s – 0.70s` | Dry, drawled observation. | *"Yeah, great idea. What could possibly go wrong?"* |

---

## 5. Permanently Locked Consistency Architecture

Every line in any ADB episode maintains **100% identical vocal identity** because it utilizes the official predefined speaker **Aiden** in Qwen3-TTS CustomVoice.

1. **Zero Speaker Drift**: The speaker embedding is hardcoded into the neural talker weights. Every segment uses the exact same vocal tract, throat resonance, and timbre.
2. **Contextual Emotion Modulation**: Prompt directives modulate tone, speed, and energy (smug, deadpan, flustered) without altering his core acoustic identity.
3. **Reproducibility**: Running `python3 tools/generate_adb_voice.py --speaker aiden` will always produce the exact same ADB voice.
