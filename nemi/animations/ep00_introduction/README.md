# EPISODE 00: NEMI DEBUT INTRODUCTION
## Dedicated Animation Package for Nemi's First YouTube Video

This is the dedicated production package for Nemi's debut introduction video (target duration: 1:55 – 2:10 / current master: 2:05 / 125.10s).

---

## Production Specifications

* **Episode ID**: `ep00_introduction`
* **Title**: "Wait, Listen to Me"
* **Master Duration**: 2:05 (125.10 seconds)
* **Target Spec**: 1:55 – 2:10 window
* **Voice Actor**: Sohee (`spk_id: 2864`, Qwen3-TTS 1.7B CustomVoice)
* **Total Spoken Segments**: 22 (`001.wav` – `022.wav`)
* **Master Specification**: [`docs/Nemi_Introduction_Video_Requirements.md`](file:///Users/talus/Documents/adb/docs/Nemi_Introduction_Video_Requirements.md)
* **Character Bible**: [`docs/Nemi_Character_Bible.md`](file:///Users/talus/Documents/adb/docs/Nemi_Character_Bible.md)
* **Dialogue Guide**: [`docs/Nemi_Dialogue_Guide.md`](file:///Users/talus/Documents/adb/docs/Nemi_Dialogue_Guide.md)
* **Script Style Guide**: [`docs/Nemi_Script_Style_Guide.md`](file:///Users/talus/Documents/adb/docs/Nemi_Script_Style_Guide.md)
* **Animation Personality Guide**: [`docs/Nemi_Animation_Personality_Guide.md`](file:///Users/talus/Documents/adb/docs/Nemi_Animation_Personality_Guide.md)
* **Subtitle Guide**: [`docs/Nemi_Subtitle_Visual_Guide.md`](file:///Users/talus/Documents/adb/docs/Nemi_Subtitle_Visual_Guide.md)

---

## Directory Inventory

```
animations/ep00_introduction/
├── README.md                      # This production index
├── script/                        # Script and subtitle data
│   ├── script.md                  # Complete 22-segment spoken script with acting and camera cues
│   └── subtitles.json             # Timestamped subtitle definitions (22 cards, 125.1s)
├── voiceover/                     # Voiceover, sfx, and music assets
│   ├── voiceover.wav              # Master spoken audio track (125.10s / 2:05)
│   ├── segments/                  # 22 individual audio segments (001.wav - 022.wav)
│   ├── timing/                    # nemi_intro_timing.json & Nemi_Intro_Voice_Timing.md
│   ├── sfx/                       # Sound effects
│   └── music/                     # Background music
├── renders/                       # Output video assets
│   ├── ep00_introduction.mp4      # Final master video render
│   └── thumbnail.png              # YouTube video thumbnail
├── introduction_scene.tscn        # Godot 2D scene
├── introduction_director.gd       # 7-beat choreography director script
└── render_introduction.gd         # Standalone CLI Movie Maker render script
```

---

## Status
* **Voiceover & Timing Pipeline**: Complete (22 segments, 125.10s, Sohee CustomVoice)
* **Script & Subtitles**: Complete & fully synchronized (`script.md`, `subtitles.json`)
* **Choreography Director**: Aligned with 22 segments in `introduction_director.gd`
* **Next Immediate Step**: Godot scene verification and animation visual review.
