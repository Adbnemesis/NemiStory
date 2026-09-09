# NEMI — OFFICIAL VOICE PROFILE (V1)
## Character Voice Specification, Candidate Evaluation, and Performance Directives

---

## 1. Selected Voice Specification

* **Primary Approved Voice**: **`af_heart`**
* **Model Engine**: Kokoro-82M (`hexgrad/Kokoro-82M`)
* **Voice Architecture**: American Female (`af_*`), 24 kHz uncompressed PCM
* **Apparent Age**: 22–26 (Matches Nemi’s canon age of 24)
* **Tone**: Warm, conversational, intelligent, subtly playful, and naturally expressive

```
                      ┌──────────────────────────────┐
                      │     NEMI'S VOCAL PROFILE     │
                      │       Voice: af_heart        │
                      └──────────────┬───────────────┘
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         ▼                           ▼                           ▼
┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
│  CONVERSATIONAL  │        │   INTELLECTUAL   │        │     DEADPAN      │
│     WARMTH       │        │    HYPERFOCUS    │        │    UNDERSTATE    │
├──────────────────┤        ├──────────────────┤        ├──────────────────┤
│ • Natural breath │        │ • Rapid cadence  │        │ • Flat inflection│
│ • Intimate clip  │        │ • Pop-culture/   │        │ • Preserved gaps │
│ • No broadcaster │        │   tech passion   │        │ • Zero melodram. │
│   hype           │        │ • Clear diction  │        │ • Comic drop     │
└──────────────────┘        └──────────────────┘        └──────────────────┘
```

---

## 2. Why `af_heart` Fits Nemi

During our audition process across official female Kokoro voices (`af_heart`, `af_bella`, `af_sky`, `af_sarah`), `af_heart` proved to be the superior fit for Nemi's identity for the following reasons:

1. **Avoids the "Anime Mascot" Trap**: Nemi has anime/manga visual influences, but her character bible explicitly forbids high-pitched, squeaky, or childish delivery. `af_heart` sits comfortably in an authentic young adult chest-to-mid register.
2. **Conversational Intimacy**: Unlike `af_bella` (which sounds slightly formal and audiobook-like) or `af_sarah` (which has a slightly sharper, presenter-like edge), `af_heart` sounds like a real person sitting across a table talking directly to the viewer.
3. **Deadpan Capability**: The voice transitions into understated flatness on punchlines without sounding robotic or hollow.
4. **Natural Cadence**: Handles conversational fragments (*"Wait, wait, wait—"*, *"As it turns out: extraordinarily hard"*) with organic phrasing.

---

## 3. Audition Comparative Analysis

Audition files are rendered and stored in [`audio/nemi/auditions/`](file:///Users/talus/Documents/adb/audio/nemi/auditions/) using the standardized test script:

| Voice | Audition File | Duration | Vocal Qualities | Assessment for Nemi |
| :--- | :--- | :--- | :--- | :--- |
| **`af_heart`** | `audition_af_heart.wav` | **31.00s** | Warm, natural pacing, youthful mid-20s, expressive micro-intonation. | **SELECTED PRIMARY**. Most natural balance of wit, warmth, and self-awareness. |
| **`af_bella`** | `audition_af_bella.wav` | 33.05s | Deeper, slightly slower, more deliberate, formal. | Strong alternative for narrative documentary / historical essay videos. |
| **`af_sky`** | `audition_af_sky.wav` | 31.70s | Lighter, slightly brighter register, breezy. | Good candidate for sunny slice-of-life or high-energy short clips. |
| **`af_sarah`** | `audition_af_sarah.wav` | 33.75s | Clean, articulate, slightly crisp commercial feel. | Slightly too polished for Nemi's messy, self-deprecating creative persona. |

---

## 4. Emotional Performance Target Matrix

Because Kokoro TTS produces natural variations through segmentation, speed, and punctuation rather than arbitrary emotion tags, Nemi's vocal performance is steered using the following segment parameters:

| Emotional Mode | Target Speed | Typical Pause | Vocal Characteristic | Script Example |
| :--- | :--- | :--- | :--- | :--- |
| **BASELINE** | `1.00x` | `0.30s – 0.40s` | Calm, relaxed, conversational. | *"Hi. I’m Nemi. I’m 24."* |
| **THE HOOK** | `1.05x` | `0.20s – 0.25s` | Urgent, conversational, scroll-stopping. | *"Wait, wait, wait—listen to me."* |
| **EXCITED / HYPE** | `1.05x – 1.10x` | `0.20s – 0.30s` | Brisk, forward-leaning, bright. | *"'How hard could that possibly be?'"* |
| **DEADPAN** | `0.90x – 0.95x` | `1.20s – 1.80s` | Flat, restrained, lingering silence. | *"Half. A. Second."* / *"...In slow motion."* |
| **EMBARRASSED** | `0.95x` | `0.40s – 0.60s` | Slightly soft, hesitant, self-effacing. | *"...Except last Tuesday when the window was not rolled up..."* |
| **SHOCKED / PANIC** | `1.10x – 1.15x` | `0.15s – 0.25s` | Fast, abrupt, rising intonation. | *"Wait—did I leave the microphone gain at 200%?!"* |
| **SINCERE / WARM** | `0.98x` | `0.35s – 0.45s` | Soft, measured, direct eye contact. | *"If that sounds like something you’d enjoy... I’d love it if you stayed."* |

---

## 5. Voice Switching Protocol

To switch Nemi's voice in future episodes without altering the pipeline architecture:
1. Update `voice: str = "<new_voice>"` in `tools/tts/config.py`, or:
2. Pass `--voice <new_voice>` to `tools/generate_nemi_voice.py`.

No code modifications, file renames, or structural adjustments are required.
