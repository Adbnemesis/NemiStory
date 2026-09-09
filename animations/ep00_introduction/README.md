# EPISODE 00: NEMI DEBUT INTRODUCTION
## Dedicated Animation Package for Nemi's First YouTube Video

This is the dedicated production package for Nemi's debut introduction video (target duration: 1:30 – 2:00 / 90–120s).

---

## Production Specifications

* **Episode ID**: `ep00_introduction`
* **Title**: Nemi Debut Introduction
* **Target Duration**: 1:30 – 2:00 (90 to 120 seconds)
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
├── script/                        # Script and subtitle data (to be written in next phase)
│   ├── script.md                  # Complete spoken script with acting and camera cues
│   └── subtitles.json             # Timestamped subtitle definitions
├── voiceover/                     # Voiceover, sfx, and music assets
│   ├── voiceover.wav              # Spoken audio track
│   ├── sfx/                       # Sound effects
│   └── music/                     # Background music
├── renders/                       # Output video assets
│   ├── ep00_introduction.mp4      # Final master video render
│   └── thumbnail.png              # YouTube video thumbnail
├── introduction_scene.tscn        # Godot 2D scene
├── introduction_director.gd       # 8-beat choreography director script
└── render_introduction.gd         # Standalone CLI Movie Maker render script
```

---

## Status
* **Phase**: Foundational Directory Setup Complete
* **Next Immediate Step**: Write the final 1:30–2:00 script in `script/script.md`.
