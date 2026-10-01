# ADB Character Guide
## Official Visual Identity, Silhouette, Master Palette, and Design Breakdown

**Document Status**: LOCKED & AUTHORITATIVE MASTER SPECIFICATION  
**Character**: ADB (Independent Storyteller & Creator)  
**Channel**: Independent ADB YouTube Storytime Channel  
**Engine**: Godot 4.x Native Vector Rig (`res://adb/characters/adb/ADB.tscn`)  
**Design Reference**: [`adb/docs/adb_model_sheet.jpg`](file:///Users/talus/Documents/adb/adb/docs/adb_model_sheet.jpg)  
**Location**: `adb/docs/ADB_CHARACTER_GUIDE.md`

---

## 1. Character Essence & Core Concept

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           ADB CHARACTER ESSENCE                          │
│                                                                          │
│               "COOL, RELAXED, EXPRESSIVE, AND MEMORABLE                  │
│             WITH AN ADORABLY DISARMED AND ANIME-LOVING CORE"             │
└──────────────────────────────────────────────────────────────────────────┘
```

ADB is a fully independent storytime animation protagonist. ADB is **NOT** a recolored Nemi, nor an adaptation of Nemi's proportions or node tree, nor "male Nemi." ADB possesses an autonomous visual silhouette, distinctive acting temperament, and independent production pipeline.

### Core Persona Pillars
1. **Calm Composure Baseline**: ADB approaches storytelling with relaxed confidence, grounded posture, dry wit, and subtle micro-reactions rather than manic hyperactivity.
2. **The "Secretly Cute" Dynamic**: When genuinely surprised, praised, embarrassed, or discussing a beloved anime/creative topic, ADB's calm armor momentarily melts into an adorable, flushed reaction before smoothly recovering composure.
3. **Deadpan Mastery**: Strong comedic timing characterized by sudden 0-velocity freezes, unimpressed eyebrow raises, and straight-dash mouth stares directly down the camera lens.
4. **Understated Modern Streetwear**: Elegant, comfortable, and timeless aesthetic—an oversized oatmeal half-zip knit sweater, layered dark crewneck tee, relaxed straight-leg dark slate trousers, and clean white canvas sneakers. (No goggles, no cyber armor, no overdesigned clutter).

---

## 2. Silhouette & Anatomical Contrast with Nemi

```
              NEMI                                   ADB
      (Ginger Storyteller)                  (Independent Creator)
    ┌──────────────────────┐              ┌──────────────────────┐
    │ Height: ~1.00x       │              │ Height: ~1.20x       │
    │ Build: Compact, cozy │              │ Build: Slender, tall │
    │ Hair: Ginger bun     │              │ Hair: Slate curtain  │
    │ Top: Olive hoodie    │              │ Top: Oatmeal knit    │
    │ Bottom: Dark skirt   │              │ Bottom: Straight pant│
    │ Eyes: Round, wide    │              │ Eyes: Almond anime   │
    │ Energy: Forward-lean │              │ Energy: Relaxed ease │
    └──────────────────────┘              └──────────────────────┘
```

* **Height & Proportions**: ADB stands noticeably taller with elongated, relaxed proportions (~1.20x vertical scale relative to Nemi's compact frame).
* **Jawline & Face**: Leaner, softly angular jawline with refined chin contours, contrasting with Nemi's rounded chibi cheeks.
* **Hairstyle**: Tousled, layered dark slate hair featuring modern middle-part curtain bangs that frame the forehead and cheekbones, with organic flick strands and layered back volume.
* **Eyes**: Almond-shaped anime eyes with calm upper eyelid weights, dark slate-espresso irises, crisp white catchlights, and highly expressive mobile eyebrows.

---

## 3. Master Color Palette

All colors are calibrated against the warm paper backdrop (`#faf6ee`):

| Component | Swatch | Hex Code | Visual Role & Material |
|---|---|---|---|
| **Master Contour Ink** | Charcoal Ink | `#2b2623` | Universal organic hand-drawn linework |
| **Skin Base** | Porcelain Ivory | `#fcf2e9` | Warm, healthy porcelain skin tone |
| **Skin Shadow** | Soft Peach Ochre | `#eed4c4` | Subtle under-chin and ear fold shadows |
| **Cheek Blush** | Watercolor Pink | `rgba(244, 143, 137, 0.55)` | Soft transparent wash for cute/flustered moments |
| **Blush Hatch** | Crimson Charcoal | `#a83b3b` | Calligraphic hatch lines during intense embarrassment |
| **Hair Base** | Dark Slate Indigo | `#1e222d` | Deep charcoal slate with subtle cool indigo base |
| **Hair Midtone** | Muted Slate Blue | `#2d3545` | Interior strand depth and shadow separation |
| **Hair Highlight** | Soft Steel Glint | `#4a5770` | Hand-drawn top specular highlights |
| **Sweater Knit** | Oatmeal Cream | `#e8dfd5` | Soft textured knit half-zip pullover |
| **Sweater Ribbing** | Sandy Oatmeal | `#d8cdc0` | Ribbed texture at collar, cuffs, and hem |
| **Inner Tee** | Dark Charcoal | `#23262f` | Clean crewneck undershirt framing the neck |
| **Zipper Hardware** | Brushed Silver | `#9aa2b4` | Metallic half-zip slider and teeth |
| **Trousers** | Deep Slate Black | `#1d212a` | Straight relaxed-fit casual trousers |
| **Trouser Seam** | Muted Charcoal | `#2e3442` | Pocket seams and cuff contour lines |
| **Sneaker Upper** | Crisp Canvas White | `#f5f6f8` | Clean minimalist low-top sneakers |
| **Sneaker Soles** | Warm Off-White | `#e2e4e8` | Lightweight vulcanized rubber sole |
| **Sneaker Tread** | Slate Charcoal | `#282c37` | Base contact ground line |

---

## 4. Model Sheet Turnaround & Parts Breakdown

As documented in [`adb/docs/adb_model_sheet.jpg`](file:///Users/talus/Documents/adb/adb/docs/adb_model_sheet.jpg):

1. **Front View**:
   - Relaxed vertical posture, arms resting comfortably at sides with slight elbow bends.
   - Symmetrical collar zip opening revealing dark inner tee.
2. **Three-Quarter View (Default Acting View)**:
   - Primary storytelling camera angle.
   - Distinctive depth between left and right curtain bangs; natural shoulder foreshortening.
3. **Profile Side View**:
   - Upright spinal alignment with subtle cervical curve.
   - Clean profile nose bridge and chin taper.
4. **Back View**:
   - Clean layered hair distribution tapering down the nape of the neck.
   - Relaxed shoulder drop across the knit yoke.

---

## 5. Canonical Vocal Identity (Qwen3-TTS: Aiden)

* **Engine**: Qwen3-TTS 1.7B CustomVoice (`mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16`)
* **Voice Actor**: **Aiden** (Official Predefined Speaker Embedding)
* **Sampling Rate**: `24,000 Hz` (PCM 16-bit Mono WAV)
* **Median Pitch (F0)**: `147.7 Hz` (Natural young adult male chest voice)
* **Core Directive**:
  > *"Cool, relaxed young adult male around 24, calm conversational speech, confident, subtle dry wit, understated and natural."*
* **Acoustic Role**:
  - Provides a grounded, relaxed, witty counterpoint to Nemi's high-energy rapid delivery (Sohee).
  - Permanent 100% acoustic consistency across all episodes (zero speaker drift).
* **Detailed Documentation**:
  - [`ADB_VOICE_PROFILE.md`](file:///Users/talus/Documents/adb/adb/docs/ADB_VOICE_PROFILE.md): Full performance specification & emotional matrix.
  - [`ADB_TTS_PROVENANCE.md`](file:///Users/talus/Documents/adb/adb/docs/ADB_TTS_PROVENANCE.md): Model architecture, package manifest, and hardware stack.
  - [`ADB_TTS_SETUP.md`](file:///Users/talus/Documents/adb/adb/docs/ADB_TTS_SETUP.md): Production pipeline, synthesis commands, and pause engine policies.
  - [`ADB_QWEN_VOICE_ACTORS_AUDITION.md`](file:///Users/talus/Documents/adb/adb/docs/ADB_QWEN_VOICE_ACTORS_AUDITION.md): Complete audition records & acoustic metrics across all candidate voice actors.

---

## 6. Canonical Backstory & Biography Facts (Locked Lore)

As established in ADB Episode 00 (*"HI, I'M ADB."*), only the following canonical facts are authorized:

1. **Age**: 24 years old. Natural pronouns: `I`, `me`, `my`, `he`, `him`, `his`.
2. **Athletic Past**: Former national-level table tennis player. Experienced in high-velocity rallies, intense tournament focus, and spin technique before retiring the paddle to focus on engineering and adulthood.
3. **Gaming**: Enjoys competitive shooters, RPGs, and strategy games; frequently loses sleep over ranked ladder grinds.
4. **Anime**: Has watched hundreds of anime across all genres (action, shonen, slice of life, psychological thrillers). Famously characterizes it as "thorough cultural research."
5. **Gym & Fitness**: Regular gym enthusiast focused on form and progressive overload, punctuated by comedic vulnerability (inability to walk up stairs after leg day).
6. **Career**: Works a full-time engineering job.
7. **Animation Journey**: Entirely new to storytime animation. Ambitious, self-aware, and slightly overwhelmed by the thousands of frames required.
8. **Girlfriend Support & Mystery Silhouette Policy**:
   - Supported by his girlfriend behind the scenes (*"made sure my character didn't look like a potato"*).
   - **STRICT REVEAL BAN**: The girlfriend character is represented strictly as an obscured, solid black/softly blurred silhouette (`MysterySilhouette`).
   - Under NO circumstances may Nemi's face, rig, colors, or identifiable character design be exposed. The mystery gag must remain intact.
