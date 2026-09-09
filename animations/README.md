# NEMI ANIMATION PRODUCTION SYSTEM
## Dedicated Animation Directory Architecture & Standard Operating Procedure

Every animation, episode, and short produced in the Nemi storytelling project lives in its own self-contained, dedicated directory inside `animations/`.

---

## 1. Directory Structure per Animation

Each animation folder is completely self-contained and standardized across four core pillars:

```
animations/<animation_id>/
├── README.md                      # Episode metadata, synopsis, status, and production log
├── script/                        # The written word, beat markers, and subtitle data
│   ├── script.md                  # Complete script with dialogue, acting cues, and camera directions
│   └── subtitles.json             # Timestamped captions with emphasis metadata
├── voiceover/                     # Audio assets
│   ├── voiceover.wav              # Primary recorded/generated dialogue voice track
│   ├── sfx/                       # Episode-specific sound effects (pops, wooshes, bells)
│   └── music/                     # Background music and ambience tracks
├── renders/                       # Output video assets
│   ├── <animation_id>.mp4         # Final exported MP4 video (H.264 / AAC)
│   ├── thumbnail.png              # YouTube video thumbnail (1280x720 or 1920x1080)
│   └── raw/                       # Intermediate Godot Movie Maker capture (ignored by git)
├── <animation_id>_scene.tscn      # Godot 2D scene with Nemi, camera, background, props, and UI
├── <animation_id>_director.gd     # The choreography / timeline runner script
└── render_<animation_id>.gd       # Standalone CLI Movie Maker render script
```

---

## 2. The Four Production Pillars

### Pillar 1: `script/`
* **`script.md`**: Written strictly in accordance with `Nemi_Character_Bible.md` and `Nemi_Dialogue_Guide.md`. Contains:
  * Dialogue lines formatted for spoken delivery.
  * Explicit acting directions in brackets (`[Nemi blinks, turns head 10 degrees]`).
  * Camera cues (`[Punch-zoom 1.4x on face]`).
  * Prop & doodle cues (`[Spawn doodle: *YAPPING*]`).
  * Deadpan pause durations (`[PAUSE: 1.5s hold]`).
* **`subtitles.json`**: Structured subtitle cues formatted according to `Nemi_Subtitle_Visual_Guide.md` for runtime injection or external editing.

### Pillar 2: `voiceover/`
* **`voiceover.wav`**: Master vocal track (44.1 kHz or 48 kHz, 16-bit or 24-bit PCM WAV, mono).
* **`sfx/`**: Clean sound effects timed to punchlines, impacts, or doodles.
* **`music/`**: Muted background music tracks (ducked -18dB under dialogue).

### Pillar 3: `renders/`
* **`<animation_id>.mp4`**: High-quality compressed video suitable for YouTube or local review.
* **`thumbnail.png`**: High-contrast, expressive thumbnail featuring Nemi's silhouette and bold typography.
* **`raw/`**: Working directory for raw Movie Maker AVI captures or PNG sequences (git-ignored).

### Pillar 4: The `.gd` and `.tscn` Engine Files
* **`<animation_id>_scene.tscn`**: Instantiates:
  1. `Nemi` (`res://characters/nemi/nemi.tscn`).
  2. `Camera2D` (`res://world/camera/StoryCamera2D.gd`).
  3. `DynamicBackground` (`res://world/backgrounds/DynamicBackground.gd`).
  4. `DoodleManager` (`res://world/doodles/DoodleManager.gd`).
  5. `Props` (`res://world/props/`).
  6. `SubtitleOverlay` (Centered lower-third Label).
* **`<animation_id>_director.gd`**: Coordinates the temporal timeline. Synchronizes dialogue playback with Nemi's facial expressions, bone poses, gaze directions, camera punch-zooms, background color shifts, and subtitle displays.
* **`render_<animation_id>.gd`**: Allows rendering the video headlessly from the command line without opening the Godot editor.

---

## 3. Creating a New Animation

To scaffold a new animation package in seconds, use the automated generator:

```bash
python3 tools/create_animation.py <animation_id> --title "Episode Title"
```

Example:
```bash
python3 tools/create_animation.py ep01_gym_disaster --title "Gym Disaster"
```

This automatically copies `animations/_template/`, configures all script and scene paths, and produces a ready-to-run package.

---

## 4. Production Workflow Cycle

```
[1. SCRIPT] ───────► [2. VOICEOVER] ───────► [3. CHOREOGRAPHY] ───────► [4. RENDER]
 script.md            voiceover.wav           director.gd                 render.gd
 Dialogue & cues      Recorded / synced       Godot acting timeline       MP4 export
```

1. **Write the Script**: Draft `script/script.md` using Nemi's character bible, ensuring 0–3s hook, rapid context, deadpan pauses, and Rule 7 compliance (no gender self-reference).
2. **Record / Prepare Audio**: Place dialogue in `voiceover/voiceover.wav`. Measure syllable onsets and pause durations.
3. **Stage in Godot**: Open `<animation_id>_scene.tscn`. Sequence poses, camera punches, and doodle triggers in `<animation_id>_director.gd`.
4. **Render Movie**: Run the render script via Godot Movie Maker mode, then compress to `.mp4` using `ffmpeg`.
