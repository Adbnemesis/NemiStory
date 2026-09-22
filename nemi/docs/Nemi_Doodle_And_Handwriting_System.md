# Nemi Doodle & Handwriting System Specification
**Version:** 2.0  
**Scope:** Universal Storytime Visual Language for Nemi  
**Inspiration:** Pegi, Jaiden Animations, Cas van de Pol  

---

## 1. Design Philosophy: Hand-Drawn Humanity vs. Robotic Perfection

In Nemi's animated storytime universe, visual elements must feel **alive, intimate, and authentically hand-drawn**. Mathematical straight lines, sterile UI shapes, and robotic geometric primitives break immersion. Every doodle, post-it note, UI card, arrow, and caption must embody the cozy imperfection of a creator drawing in their personal sketchbook late at night.

### Core Principles
1. **Never Perfectly Straight**: Every line, border, and curve contains natural organic micro-wobble (sinusoidal displacement, subtle hand-jitter).
2. **Visible Inking Dynamics**: Lines taper slightly at the terminals, feature variable thickness (3.0px to 4.5px for key contours), and exhibit organic round caps.
3. **Sketchbook Layering**: Props slide or pop in with playful paper physics—gentle rotation (-5° to +5°), soft paper shadows, and scotch tape / push-pin accents.
4. **Comic Kinetic Accents**: Visual puns, action bursts (`*PANIK*`, `*NOPE!*`), floating souls, and sweating drops punctuate emotional beats without cluttering the screen.

---

## 2. Handwritten Typography & Subtitle System

All text in Nemi's videos adheres to a unified handwriting typographic hierarchy powered by the `Patrick Hand` font family (`res://common/fonts/PatrickHand-Regular.ttf`).

### Typographic Hierarchy

| Context | Font Size | Font Color | Outline | Rotation / Placement | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Spoken Subtitles** | 34px – 36px | `#fffef5` (warm cream) | 7px `#200b14` (dark berry espresso) | Centered, `y = 610`, `z_index = 25` | Effortless readability against all studio backdrops while maintaining handwritten charm. |
| **Sticky Post-It Notes** | 21px – 24px | `#2b2b28` (graphite ink) | None / 1px soft | `-6.0°` to `+6.0°`, pinned on wall/desk | Candid thoughts, to-do lists, self-deprecating humor. |
| **Comic Action Bursts** | 22px – 26px | `#ffffff` or `#ffebee` | 4px `#1a1a2e` | Angled in burst bubble | Sound effects & vocal reactions (`*PANIK*`, `*NOPE!*`, `*CRASH!*`). |
| **UI Callout Cards** | 18px – 22px | `#334155` (slate ink) | None | Inside hand-drawn cards | YouTube stats, timeline tracks, UI metadata. |
| **Mascot / Signoff** | 28px – 32px | `#e91e63` (warm pink) | 3px `#ffffff` | Waving alongside cat mascot | Warm, personal channel signoffs ("wish me luck! ♡"). |

### Godot 4.7 Font Fallback Architecture
To guarantee 100% headless render stability and prevent crashes when custom TTF files undergo dynamic loading:
```gdscript
var font: FontFile = load("res://common/fonts/PatrickHand-Regular.ttf") as FontFile
if not font:
    font = ThemeDB.fallback_font as FontFile
label.add_theme_font_override("font", font)
label.add_theme_font_size_override("font_size", 34)
label.add_theme_color_override("font_color", Color("#fffef5"))
label.add_theme_color_override("font_outline_color", Color("#200b14"))
label.add_theme_constant_override("outline_size", 7)
```

---

## 3. Hand-Drawn Doodle & Prop Catalog (`Ep04Doodles.gd`)

Episode 04 introduces a rich suite of vector-drawn procedural props and visual gags:

### 1. `DoodlePanicMeter`
- **Visual**: Circular hand-drawn gauge with yellow-to-red danger zones, tick marks, and a trembling needle locked in the maximum panic sector.
- **Behavior**: Needle vibrates autonomously using a fast noise sine wave (`sin(t * 32.0) * 0.15`), accompanied by a popping label `"PANIC METER: 100%"`.
- **Usage**: Triggered when admitting terror or experiencing overwhelming imposter syndrome.

### 2. `DoodleStickyNote`
- **Visual**: Soft pastel Post-it note (yellow `#fff9c4`, pink `#fce4ec`, or mint `#e8f5e9`) with tape at top center, natural curl shadow at bottom, and hand-lettered graphite text.
- **Behavior**: Pops in with slight spring overshoot (`TRANS_BACK`, `EASE_OUT`) at random hand-placed angles.
- **Usage**: `"TODO: survive 1st video"`, `"7 VIEWS (3 are mom)"`, `"FRAME 4,291"`, `"BRAIN: SHUT UP PLS"`.

### 3. `DoodleActionBubble`
- **Visual**: 12-point jagged comic burst balloon with thick ink outline and bold interior text.
- **Behavior**: Rapid elastic pop (`scale 0.0 -> 1.25 -> 1.0` in 0.2s), with gentle floating oscillation.
- **Usage**: High-energy comic punctuation: `*PANIK*`, `*NOPE!*`, `*CRASH!*`, `*LET'S GO!*`, `*BYE!! :3*`.

### 4. `DoodleHeartBurst`
- **Visual**: Cluster of 5 hand-sketched pastel hearts of varying sizes with floating sparkle ticks and soft pink modulation.
- **Behavior**: Floats upward with staggered particle lift, scaling up and pulsing gently before soft fading.
- **Usage**: Genuine expressions of artistic love, appreciation for the viewer, and heartfelt confessions.

### 5. `DoodleFacepalmChibi`
- **Visual**: Adorable hand-drawn stick-figure chibi sitting on a small sketchcard, facepalming in relatable exasperation, with a tiny sigh sweat drop.
- **Behavior**: Slides onto desk with paper wobble.
- **Usage**: Self-deprecating moments (overthinking, posture fails, cringe at analytics).

### 6. `DoodleCoffeeMug`
- **Visual**: Ceramic coffee mug sitting on desk with hand-drawn rim, cute mini-heart print on the side, and 3 curling steam wisps.
- **Behavior**: Steam wisps oscillate horizontally using procedural sine waves, giving a cozy living feel to the desk.
- **Usage**: Grounding prop for late-night desk animation sessions.

### 7. `DoodleNotificationBuzz`
- **Visual**: Smartphone resting on desk with notification bar, vibration ripple arcs, and buzzing sound effect cue.
- **Behavior**: Rapid micro-jitter on the x-axis to simulate phone motor buzzing.
- **Usage**: 2:00 AM refresh sequence and notifications.

### 8. `HandDrawnCatMascot`
- **Visual**: Round, expressive white-and-pink doodle kitten with button eyes, whiskers, and pink paw pads.
- **Behavior**: Peeks over the desk edge, waves paw, or bobs rhythmically.
- **Usage**: Emotional companion to Nemi, opening and closing the episode.

---

## 4. Dynamic Camera Choreography System

A static camera makes even great animation feel like a slide deck. The `Ep04BaseBeat` camera system provides cinematic, punchy camera moves synchronized with dialogue phrasing:

```gdscript
# Instant punch-in for comedic timing (e.g. deadpan reveals)
cam_punch(offset: Vector2, zoom_mult: float, duration: float)

# Smooth slow push-in over intimate confessions
cam_push_in(amount: float, duration: float)

# Screen shake for startled reactions, panic, or crashes
cam_shake(intensity: float, duration: float, freq: float)

# Playful Dutch tilt for confusion, overthinking, or spirals
cam_dutch(angle_deg: float, duration: float)

# Instant or interpolated framing preset transitions
cam_preset(preset: StoryCamera2D.ShotPreset, duration: float)
```

### Shot Preset Catalog
- `ShotPreset.WIDE`: Full desk studio view, establishing space and cozy room atmosphere.
- `ShotPreset.MEDIUM`: Standard storytime dialogue framing from waist up.
- `ShotPreset.MEDIUM_CLOSEUP`: Emotional focus framing for confessions and direct eye contact.
- `ShotPreset.CLOSEUP`: Dramatic framing for micro-expressions, blushes, and comedic deadpans.

---

## 5. Timeline Synchronization & Audio Constraints

All visual assets and camera cuts are locked to the calibrated 73.20s master audio track:

| Beat | Name | Audio Segment | Dialogue Dur | Pause Dur | Total Dur | Key Visual Highlights |
| :---: | :--- | :--- | :---: | :---: | :---: | :--- |
| **01** | Raw Confession | `seg01_terrified.wav` | 9.52s | 0.40s | **9.92s** | Steaming coffee mug, sticky note, cat mascot, panic meter pop + *PANIK* burst |
| **02** | Not Horror | `seg02_not_horror.wav` | 6.88s | 0.35s | **7.23s** | Ghost card slide + red X crossout + *NOPE!*, dutch tilt, YouTube card, chibi facepalm |
| **03** | Obsessing Frames | `seg03_love_making.wav` | 6.88s | 0.30s | **7.18s** | Heart burst, hunched shrimp posture doodle, frame sticky note, coffee mug |
| **04** | 2 AM Refresh | `seg04_refresh_2am.wav` | 8.64s | 0.45s | **9.09s** | Night mode shift, phone buzz, snap punch zoom to deadpan, floating soul + *sigh* |
| **05** | Overthinking Doubts | `seg05_what_if.wav` | 7.44s | 0.35s | **7.79s** | Recoil + dutch tilt, brain spiral + *SPIRAL*, overthinking arrow, panic meter, chibi |
| **06** | Prodigies & Chaos | `seg06_other_animators.wav` | 7.12s | 0.40s | **7.52s** | Star sparkles, Blender god note, timeline chaos card, camera shake + *CRASH!* |
| **07** | Because I Care | `seg07_because_i_care.wav` | 6.40s | 0.50s | **6.90s** | Slow intimate push-in, sketched heart card, floating watercolor hearts, blush accent |
| **08** | Determination | `seg08_overthinking.wav` | 6.72s | 0.45s | **7.17s** | Lightbulb pop, next video player card, "DON'T QUIT" note, camera punch + *LET'S GO!* |
| **09** | Casual Signoff | `seg09_signoff.wav` | 9.60s | 0.80s | **10.40s** | Waving cat, thank you note, *BYE!! :3*, floating hearts, cinematic wide pull-back |

**Master Duration:** `73.20s` (Preserved with frame-accurate fidelity across all 9 beats).

---

## 6. Studio Backdrop & Desk Preservation Protocol (MANDATORY)

> [!CRITICAL]
> **NEVER REMOVE THE STUDIO BACKDROP OR FOREGROUND DESK.**
> Adding doodles, props, cards, or comedic cutaways must **NEVER** result in a blank void or the deletion of Nemi's room. All storytelling elements exist *within* the physical space of her creative room.

### The Sacred Layering Hierarchy

```text
┌─────────────────────────────────────────────────────────────────────────┐
│ Z-INDEX +25 : Subtitles (Patrick Hand, 36px, centered at y = 1010)     │
├─────────────────────────────────────────────────────────────────────────┤
│ Z-INDEX +12 : Spiky Action Bubbles (*PANIK*, *BYE!! :3*), Comic Bursts │
├─────────────────────────────────────────────────────────────────────────┤
│ Z-INDEX +10 : Interactive Story Cards (YouTube player, Ghost card)     │
├─────────────────────────────────────────────────────────────────────────┤
│ Z-INDEX +8  : Desk Props (Cat Mascot, Steaming Mug, Panic Gauge)       │
├─────────────────────────────────────────────────────────────────────────┤
│ Z-INDEX +5  : Foreground Studio Desk Bar & Drawing Tablet (Covers Torso)│
├─────────────────────────────────────────────────────────────────────────┤
│ Z-INDEX  0  : Nemi 2D Rig (Torso, Head, Face Expressions, Gestures)     │
├─────────────────────────────────────────────────────────────────────────┤
│ Z-INDEX -8  : Wall Doodles (Sticky Notes, Corkboard Pins, Posters)      │
├─────────────────────────────────────────────────────────────────────────┤
│ Z-INDEX -10 : Studio Room Backdrop (Bookshelf, Window, Lights, Wall)   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Staging Rules for Props & Doodles
1. **Wall Elements (`z_index = -8`)**:
   - Pinned to the corkboard or placed on bookshelves behind Nemi.
   - Examples: `"TODO: survive 1st video"`, `"12-YR-OLD GODS OF BLENDER ★"`, `"DON'T QUIT!"`.
2. **Desk Elements (`z_index = +8`)**:
   - Placed on top of the wooden desk surface (`z_index = +5`), interacting with Nemi's workspace.
   - Examples: Chibi Cat Mascot sitting beside the drawing tablet, steaming ceramic mug, vibrating smartphone.
3. **Floating Comic Elements (`z_index = +10` to `+12`)**:
   - Appear near Nemi's head or beside her shoulders without clipping her eyes, mouth, or hair.
   - Examples: Spiky reaction bubbles, floating question mark spirals, sketched pink hearts.
4. **Atmospheric Lighting Shift (Night Mode)**:
   - In Beat 4 ("It's 2:00 AM..."), the studio backdrop does **not** disappear. It smoothly tints to a deep midnight blue (`#101020`), while the strung fairy lights glow warmly and the desk lamp casts an illuminated light cone over Nemi and her tablet.

---

## 7. Character Facial Expressions & Comic Juice FX

To prevent static poses and elevate visual entertainment, Nemi's face shifts dynamically with every emotional turn in the script:

| Expression State | Eyes / Brows | Mouth Shape | VFX Overlay | Triggers & Narrative Context |
| :--- | :--- | :--- | :--- | :--- |
| **Candid Warmth** | Relaxed open eyes, soft brows | Gentle talking cycle | Soft peach blush (`#ff8a80`, alpha 0.25) | Baseline conversational storytelling ("Okay, so..."). |
| **Terrified Confession** | Wide trembling pupils, high curved brows | Small open 'o' | Tear glints, sweat drop on temple | Admiring panic ("kind of terrified"). |
| **Deadpan Disappointment** | Flat horizontal lids, lowered deadpan pupils | Straight horizontal line | Muted gray desaturation, floating soul wisp | 7 views reveal ("half from my phone"). |
| **Brain Spiral / Panic** | Swirling spiral eyes or cross-eyed | Wobbly zig-zag mouth | Overhead cartoon spiral, question mark puff | Imposter syndrome ("my brain immediately goes..."). |
| **Intimate Sincerity** | Soft curved happy eyes (^_^) | Warm smiling curve | Sketched pink hearts, gentle blush bloom | Viewer appreciation ("I really, really care"). |
| **Determined Spark** | Focused tilted eyes with star pupils (★) | Confident grin | Star sparkles, yellow lightbulb pop | Moving forward ("I'm going to make the next one"). |
| **Playful Wink / Wave** | One wink eye, one wide open star eye | Open laugh mouth | Sparkle bursts, hand wave oscillation | Outro signoff ("Okay, bye!"). |

---

## 8. Voice Delivery & Visual Choreography Mapping

Nemi's voice performance (Sohee CustomVoice pipeline) drives the visual rhythm:

```text
VOCAL DIRECTIVE (Audio)          VISUAL CHOREOGRAPHY (Engine)
────────────────────────       ──────────────────────────────────────
[Acting: spike on "TERRIFIED"]  ──► Snap Camera Punch-In (1.15x) +
                                    DoodlePanicMeter needle jumps to 100% +
                                    Spiky Action Bubble (*PANIK!*)

[Acting: ramble the middle]     ──► Rapid hand gestures +
                                    Wobbly pencil sketch doodle progressive draw-in

[Acting: drop to deadpan]       ──► Immediate pause of all body motion +
                                    Camera snaps to flat deadpan medium close-up +
                                    Desk lamp cone spotlight + floating soul sigh

[Acting: tease / chuckle]       ──► Playful Dutch tilt (-3.5°) +
                                    Cat Mascot tilts head +
                                    Soft watercolor blush accent

[Acting: whisper / intimate]    ──► Slow, smooth camera push-in (1.25x over 5.0s) +
                                    Floating heart burst lift +
                                    Subtle hair physics sway
```

### Sound Effects (SFX) Integration
SFX cues are mixed directly into `audio/EP04_audio_sfx_master.wav` to accent the hand-drawn visuals:
- **`sfx_pop.wav`**: Accompanies sticky note appearances, lightbulb pop, and storycard slides.
- **`sfx_whoosh.wav`**: Accents rapid camera punch-ins, dutch tilts, and card wipes.
- **`sfx_needle_buzz.wav`**: Vibrating tick for the panic meter needle.
- **`sfx_phone_buzz.wav`**: Haptic motor buzz for the 2:00 AM smartphone notification.
- **`sfx_sparkle.wav`**: Soft chime for heart bursts, star glints, and determined smiles.
- **`sfx_meow.wav`**: Playful chirp when the chibi cat mascot waves at the audience.

---

## 9. Procedural Hand-Drawn Stroke Engine (`Ep04Doodles.gd`)

To ensure doodles never look like computer-generated vector art, the `HandDrawnStroke` engine applies real-time artist imperfection:

```gdscript
# Procedural wobble algorithm
func _compute_wobble_geometry() -> void:
    for i in range(raw_points.size()):
        var pt = raw_points[i]
        # Multi-frequency sine displacement mimics human hand-jitter
        var jitter = Vector2(
            sin(float(i) * 1.8 + 0.4) * wobble_amplitude,
            cos(float(i) * 2.3 + 1.1) * wobble_amplitude
        )
        _cached_wobbly_pts.append(pt + jitter)
        
        # Secondary pass: mimics double pencil lines when sketching
        if double_pencil_pass:
            var sketch_jitter = Vector2(
                cos(float(i) * 3.1) * (wobble_amplitude * 0.6),
                sin(float(i) * 2.7) * (wobble_amplitude * 0.6)
            )
            _cached_sketch_pts.append(pt + sketch_jitter)
```

### Live Write-On Reveal
Instead of popping on fully formed, doodles feature an animated `draw_progress` parameter (0.0 to 1.0) controlled by Godot Tweens:
- At `0.0s`: Pencil line starts at vertex 0.
- Over `0.25s – 0.40s`: The stroke draws itself smoothly across the screen, mimicking an artist's pen in real-time.
- Finished with an elastic micro-bounce on the final anchor point.

