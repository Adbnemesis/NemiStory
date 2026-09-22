# Episode 00 — Production Asset Manifest
**Title**: *"Wait, Listen to Me"*  
**Episode Code**: `ep00_introduction`  
**Master Audio**: `animations/ep00_introduction/voiceover/voiceover.wav`  
**Voice Actor**: Sohee (Qwen3-TTS 1.7B CustomVoice, spk_id: 2864)  
**Total Duration**: 125.10 seconds (02:05.10)  
**Character**: 100% Vector Godot Rig (`characters/nemi/nemi.tscn`)  
**Resolution**: 1280 × 720 @ 60 FPS  

---

## 1. Scene & Beat Hierarchy

| Beat | Name | Time Range | Duration | Scene File | Preview Artifact |
|:---|:---|:---|:---|:---|:---|
| **Beat 1** | The Hook | `00:00.00 – 00:14.70` | 14.70s | `episodes/ep00_introduction/beats/Beat01_Hook.tscn` | `previews/EP00_beat01_preview.mp4` |
| **Beat 2** | Identity & Premise | `00:14.70 – 00:31.54` | 16.84s | `episodes/ep00_introduction/beats/Beat02_Identity.tscn` | `previews/EP00_beat02_preview.mp4` |
| **Beat 3** | The Animation Struggle | `00:31.54 – 00:51.31` | 19.77s | `episodes/ep00_introduction/beats/Beat03_Struggle.tscn` | `previews/EP00_beat03_preview.mp4` |
| **Beat 4** | Hobbies as Story Fuel | `00:51.31 – 01:17.72` | 26.41s | `episodes/ep00_introduction/beats/Beat04_Hobbies.tscn` | `previews/EP00_beat04_preview.mp4` |
| **Beat 5** | The Rabbit Hole | `01:17.72 – 01:44.38` | 26.66s | `episodes/ep00_introduction/beats/Beat05_RabbitHole.tscn` | `previews/EP00_beat05_preview.mp4` |
| **Beat 6** | Channel Vision | `01:45.18 – 01:54.14` | 8.96s | `episodes/ep00_introduction/beats/Beat06_ChannelVision.tscn` | `previews/EP00_beat06_preview.mp4` |
| **Beat 7** | Understated Outro | `01:54.49 – 02:05.10` | 10.61s | `episodes/ep00_introduction/beats/Beat07_Outro.tscn` | `previews/EP00_beat07_preview.mp4` |
| **Master** | Master Assembly | `00:00.00 – 02:05.10` | 125.10s | `episodes/ep00_introduction/EP00_Introduction.tscn` | `previews/EP00_introduction_preview.mp4` |

---

## 2. Props & Doodle Visual Assets

All props are implemented as procedural vector Godot 2D drawings with drop shadows, hand-drawn sketchcard styling, and organic tween animations:

1. **`PropDistortedTeacup.gd`** (`episodes/ep00_introduction/props/PropDistortedTeacup.gd`):
   - Used in **Beat 1** on dialogue: *"I have an oddly shaped teacup..."*
   - Features: Parchment sketchcard base, intentionally misshapen teacup resembling a ginger root, floating steam wisps, and a hand-drawn red arrow with handwritten annotation `"THIS IS SUPPOSED TO BE A TEACUP"`.
2. **`PropStylus.gd`** (`episodes/ep00_introduction/props/PropStylus.gd`):
   - Used in **Beat 3** on dialogue: *"I’m an animator..."*
   - Features: Digital drawing stylus held outward, LED indicator light, stylus tip with glowing particle spark, and subtle idle breathing float.
3. **`PropDumbbell.gd`** (`episodes/ep00_introduction/props/PropDumbbell.gd`):
   - Used in **Beat 4** on dialogue: *"I go to the gym..."*
   - Features: Heavy iron dumbbell with knurled grip, weight plates, and a sudden downward thud drop onto the canvas (`drop_in`).
4. **`PropSteeringWheel.gd`** (`episodes/ep00_introduction/props/PropSteeringWheel.gd`):
   - Used in **Beat 4** on dialogue: *"And I sing. Mostly in my car with the windows rolled up."*
   - Features: Classic three-spoke steering wheel doodle with horn center and leather texture, popping into frame in front of Nemi.
5. **`PropVictorianBridge.gd`** (`episodes/ep00_introduction/props/PropVictorianBridge.gd`):
   - Used in **Beat 5** on dialogue: *"exact structural tension of Victorian iron bridges..."*
   - Features: Elaborate blueprint card with arched iron trusses, diagonal lattice cross-bracing, piers, water line, tension vectors (`T = 42,800 kN`), and humorous annotations (`* 6 HOURS SPENT RESEARCHING *`, `SCREEN TIME: 0.50 SECONDS`, `100% ARCHITECTURALLY SOUND`).
6. **`PropTypingHands.gd`** (`episodes/ep00_introduction/props/PropTypingHands.gd`):
   - Used in **Beat 5** on dialogue: *"six entire hours researching..."*
   - Features: Animated frantic cartoon doodle hands oscillating rapidly at 32 Hz over a laptop keyboard with floating sound effect bursts (`"CLACK!"`, `"TAP TAP"`, `"WIKIPEDIA"`, `"PDF 1884"`).

---

## 3. Subtitle Cards & Synchronized Dialogue

All 22 dialogue segments (`001.wav` – `022.wav`) from `animations/ep00_introduction/voiceover/voiceover.wav` are mapped to on-screen subtitle cards:

| Card | Segment | Time Range | Dialogue Text | Visual / Acting Cues |
|:---:|:---:|:---:|:---|:---|
| **1** | `001` | 00:00.00 – 00:02.00 | *"Wait, wait, wait—listen to me."* | Wide Shot, darting eyes, urgent posture lean |
| **2** | `002` | 00:02.25 – 00:04.60 | *"I have an oddly shaped teacup,"* | 0-frame punch zoom 1.35x, teacup sketchcard pops in |
| **3** | `003` | 00:04.95 – 00:07.75 | *"a notebook full of terrible ideas,"* | Skeptical brow, shrug gesture |
| **4** | `004` | 00:08.10 – 00:14.20 | *"and an irrational amount of determination. Which means—clearly—I should start a YouTube channel."* | Deadpan head tilt, wry smile, pause hold |
| **5** | `005` | 00:14.70 – 00:18.06 | *"Hi. I’m Nemi. I’m 24."* | Zoom resets, bashful cheek blush, warm wave |
| **6** | `006` | 00:18.41 – 00:23.21 | *"And this is the channel where I make animated stories about... honestly, whatever I can’t stop thinking about."* | Thinking chin-tap, soft gaze up-right |
| **7** | `007` | 00:23.56 – 00:27.76 | *"Awkward encounters. Overambitious projects that spiraled out of control."* | Smug chest puff, `*YEAR 1 ON YOUTUBE*` badge |
| **8** | `008` | 00:28.11 – 00:31.19 | *"The kind of things that make you go: 'Well. That was a choice.'"* | Shrug, `*FAMOUS LAST WORDS*` badge, deadpan pause |
| **9** | `009` | 00:31.54 – 00:34.90 | *"By day, I’m an animator. Which sounds glamorous..."* | Cool gray desaturated wash, digital stylus appears |
| **10** | `010` | 00:35.25 – 00:40.40 | *"...until you realize it means sitting in a dark room moving tiny shapes by three pixels for eight consecutive hours."* | Slouch posture, exhausted droop, grimace |
| **11** | `011` | 00:40.75 – 00:46.43 | *"You start questioning reality around hour six. 'Is this hand anatomically correct? Does anyone have five fingers?'"* | Hand inspect, squint, nervous twitch |
| **12** | `012` | 00:46.78 – 00:50.96 | *"'Am I even real?' ...And then you hit render, and your computer sounds like a jet engine taking off."* | Direct stare, absolute freeze on engine, deadpan finish |
| **13** | `013` | 00:51.31 – 01:01.23 | *"I go to the gym. Where I walk in with the confidence of an anime hero in a tournament arc... and walk out two sets later completely paralyzed by leg day."* | Solid crimson wash, dumbbell thud, heroic puff -> tremble, `*DOMS ACTIVATED*` |
| **14** | `014` | 01:01.58 – 01:08.14 | *"And I sing. Mostly in my car with the windows rolled up."* | Steering wheel pops in, operatic closed-eye stance |
| **15** | `015` | 01:08.49 – 01:17.37 | *"...Except last Tuesday when the window was not rolled up, and a mail carrier heard me hit a high G with absolute vibrato."* | Snap head turn left, eyes wide, sweat drop, mortification freeze |
| **16** | `016` | 01:17.72 – 01:27.16 | *"Like last week, when I spent six entire hours researching the exact structural tension of Victorian iron bridges..."* | Frantic typing hands, Victorian bridge blueprint pop-in, screen shake |
| **17** | `017` | 01:27.51 – 01:32.95 | *"...just to draw one single background that is on screen for half a second."* | Typing hands vanish, eyes narrow into camera |
| **18** | `018` | 01:33.30 – 01:35.38 | *"Half. A. Second."* | 1-frame snap zoom 1.4x into face/eyes, rigid statue hold |
| **—** | `PAUSE` | 01:35.38 – 01:37.18 | *(1.8s Deadpan Silence)* | Background drains to stark monochrome gray, single slow blink |
| **19** | `019` | 01:37.18 – 01:44.38 | *"...My posture was ruined. My tea was ice cold. But the bridge was architecturally sound."* | Slouch -> smug chest nod, weary eye-roll, zoom resets |
| **20** | `020` | 01:45.18 – 01:54.14 | *"I don't really know where this channel is going yet, but I want to have fun with it, get better at animation, and hopefully meet some cool people."* | Warm cream wash restored, welcoming gesture -> sincere hand-on-heart |
| **21** | `021` | 01:54.49 – 02:00.57 | *"So, if any of that sounds like something you’d enjoy... I’d love it if you stayed."* | Sincere eye contact, warm smile, gentle head tilt |
| **22** | `022` | 02:00.92 – 02:04.60 | *"Thank you for watching my very first video. See you in the next one. Bye!"* | Casual two-finger wave, cheerful smile, fade to warm paper texture |

---

## 4. Technical Specifications Summary

- **Engine**: Godot v4.7.2 (Compatibility / Metal renderer on macOS Apple Silicon M4 Pro)
- **Audio Sample Rate**: 48,000 Hz, 16-bit PCM stereo (`voiceover.wav`)
- **Video Framerate**: Fixed 60.0 FPS, deterministic process-frame synchronization
- **Encoding Pipeline**: Uncompressed AVI via Godot Movie Maker -> `ffmpeg` H.264 (CRF 18, preset fast, pix_fmt yuv420p) + AAC 192kbps
- **Staging Positioning**:
  - Resolution: 1280 × 720
  - Camera Center: `(640, 360)`
  - Nemi Base Position: `(640, 390 – 430)`
  - Nemi Base Scale: `(1.15, 1.15)`
