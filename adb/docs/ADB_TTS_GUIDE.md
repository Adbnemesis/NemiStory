# ADB Qwen3-TTS CustomVoice Pipeline — Operations Guide
## Local Speech Synthesis, Script Formatting, and Audio Production for ADB

**Document Status**: LOCKED & AUTHORITATIVE OPERATIONS MANUAL  
**Character**: ADB (Independent Storyteller & Creator)  
**Model**: `mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`  
**Default Voice Actor**: **Aiden** (`--speaker aiden`)  
**Runtime**: 100% Offline Local Apple Silicon MLX GPU/Neural Engine  
**Location**: [`adb/docs/ADB_TTS_GUIDE.md`](file:///Users/talus/Documents/adb/adb/docs/ADB_TTS_GUIDE.md)  

---

## 1. Quick Start Commands

All speech synthesis runs completely offline and locally using Apple Silicon's unified memory on your M-series Mac:

```bash
# Generate voiceover for an ADB episode from a markdown script:
./.venv/bin/python3 tools/generate_adb_voice.py \
  --script adb/episodes/ep00_intro/source/script.md \
  --output audio/adb/ep00_intro \
  --project-id adb_ep00_intro \
  --title "ADB Introduction"

# Re-run or preview candidate male voice actors:
./.venv/bin/python3 tools/audition_adb_voices.py
```

---

## 2. Directory Architecture for ADB Audio

```
audio/adb/
├── auditions/
│   └── custom_actors/
│       ├── aiden/                  # Individual line WAVs for Aiden
│       ├── aiden_full_showcase.wav # Full 3-line continuous audition track
│       ├── ryan/
│       ├── ryan_full_showcase.wav
│       ├── dylan/
│       └── eric/
├── reference/
│   ├── adb_golden_reference.wav   # Authoritative vocal anchor
│   └── adb_golden_reference.txt
└── ep00_intro/
    ├── master/
    │   └── adb_ep00_intro_voice_master.wav
    ├── segments/
    │   ├── adb_001_intro.wav
    │   ├── adb_002_hook.wav
    │   └── ...
    ├── timing/
    │   ├── adb_ep00_intro_timing.json
    │   └── adb_ep00_intro_voice_timing.md
    └── metadata/
        └── voice_metadata.json
```

---

## 3. Script Writing Guidelines for ADB's Voice

ADB's delivery thrives on **relaxed conversational pacing**, **dry deadpan pauses**, and **flustered anime tangents**. To get the best synthesis results from Qwen3-TTS, format scripts following these rules:

1. **Use Em-Dashes (`—`) for Abrupt Thoughts**:
   * *Good*: `"Okay, but listen—the animation in episode four was actually insane!"`
   * Creates an authentic conversational pivot rather than a robotic comma pause.

2. **Use Ellipses (`...`) for Deadpan Comedic Holds**:
   * *Good*: `"Instead, I looked like an origami kite... in broad daylight."`
   * Prompts the model to add a natural beat pause before dropping the punchline.

3. **Tag Spoken Beats with Acting Directives**:
   * When using the pipeline, you can attach acting notes per beat (e.g., `[Directive: deadpan comedic timing]` or `[Directive: quiet, embarrassed confession]`). The pipeline passes these directives to Aiden's emotion conditioning without altering his voice identity.

---

## 4. Contextual Pause Engine

ADB's timing engine is calibrated differently from Nemi's rapid-fire rhythm to accentuate his cool, unbothered deadpan style:

| Pause Category | Duration | Typical Usage in ADB Episodes |
| :--- | :---: | :--- |
| **Short Pause** | `0.20s` | Thought transitions and comma pauses |
| **Medium Pause** | `0.35s` | Natural sentence endings |
| **Thought Pause** | `0.45s` | Reflective transitions between beats |
| **Smug Pause** | `0.60s` | Sarcastic beat pause after an ironic remark |
| **Dramatic Pause** | `0.75s` | Setup before a major reveal |
| **Deadpan Pause** | `1.40s` | 0-velocity comedic freeze holds |
