# ADB Character Guide
## Visual Identity, Rig Architecture, Facial Performance, and Acting Dynamics

**Document Status**: AUTHORITATIVE CHARACTER GUIDE  
**Character**: ADB (Nemi's Partner & Best Friend)  
**Debut Episode**: Episode 02 (*"How I Met My Partner"*)  
**Engine**: Godot 4.x (Procedural Vector & Rig Controller, `characters/adb/ADB.gd`)  
**Linework Standard**: Hand-Drawn Charcoal Ink (`#2b2623`, 2.8px–3.5px line weight)  
**Authoritative Locations**:
- `characters/adb/ADB_Character_Guide.md`
- `nemi/characters/adb/ADB_Character_Guide.md`

---

## 1. Core Visual Identity & Design Philosophy

ADB is introduced as an independent, fully realized co-star in the Nemi universe. ADB is **NOT** a recolored Nemi, nor an adaptation of any existing rig.

```
       ┌────────────────────────────────────────────────────────┐
       │                 ADB CHARACTER ESSENCE                  │
       │  "Cool, Confident, Understated, with a Secretly Cute   │
       │   and Anime-Obsessed Core"                             │
       └───────────────────────────┬────────────────────────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          ▼                        ▼                        ▼
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ COOL SILHOUETTE  │     │  CUTE CONTRAST   │     │  ORGANIC INKING  │
├──────────────────┤     ├──────────────────┤     ├──────────────────┤
│ • Dark slate hair│     │ • Sudden blush   │     │ • Master #2b2623 │
│ • Relaxed knit   │     │ • Caught offguard│     │   charcoal ink   │
│   oatmeal sweater│     │ • Sheepish smile │     │ • Controlled     │
│ • Slender, calm  │     │ • Mutual teasing │     │   asymmetry      │
│   confidence     │     │ • Deadpan humor  │     │ • Warm cream base│
└──────────────────┘     └──────────────────┘     └──────────────────┘
```

### Aesthetic Contrast with Nemi
* **Nemi**: Expressive ginger bun (`#b84328`), oversized dark olive-green hoodie (`#536b5c`), energetic forward-leaning posture, round wide expressive eyes.
* **ADB**: Layered dark slate/indigo hair (`#232836`), relaxed oatmeal cream knit sweater (`#e6ded1`), inner charcoal shirt (`#2a2c33`), relaxed dark trousers (`#1e222b`), sharp anime-friendly almond eyes, calmer and more composed posture.

### Master Palette Table
| Component | Hex Code | Purpose & Aesthetic |
|---|---|---|
| **Ink Contour** | `#2b2623` | Master charcoal/sepia hand-drawn linework |
| **Skin Base** | `#fbeddb` | Warm ivory peach skin tone |
| **Cheek Blush** | `rgba(242, 162, 155, 0.65)` | Soft watercolor pink wash for cute/embarrassed moments |
| **Hair Base** | `#232836` | Dark slate indigo charcoal with layered anime silhouette |
| **Hair Highlight**| `#353c4f` | Subtle top hair glint strokes |
| **Sweater Knit** | `#e6ded1` | Relaxed oatmeal cream knit texture |
| **Inner Shirt** | `#2a2c33` | Deep charcoal inner collar tee |
| **Trousers** | `#1e222b` | Relaxed dark trousers |
| **Iris** | `#2b2623` | Sharp, cool charcoal pupil with white catchlight |

---

## 2. Rig Architecture & Movement Capabilities

ADB is constructed as a 100% engine-native vector character in Godot (`characters/adb/ADB.gd`).

### Movement API
```gdscript
# Directorial posing
adb.set_pose("cool_idle", 0.20)      # Default relaxed posture
adb.set_pose("cute_wave", 0.25)      # Subtle cute shoulder-level wave
adb.set_pose("teasing_poke", 0.22)   # Playful finger poke toward Nemi
adb.set_pose("deadpan_freeze", 0.10) # Instant 0-motion freeze
adb.set_pose("phone_texting", 0.22)  # Two-handed phone texting pose
adb.set_pose("supportive_nod", 0.25) # Warm reassuring posture

# Facial performance
adb.set_expression("neutral")        # Calm, understated confidence
adb.set_expression("cute")           # Soft brow softening, cheek blush, small smile
adb.set_expression("smug")           # Asymmetric eyebrow arch, dry smirk
adb.set_expression("embarrassed")    # Full cheek blush, wide eyes, small 'o' mouth
adb.set_expression("deadpan")        # Horizontal straight dash mouth (- -), narrowed eyes
adb.set_expression("excited")        # Wide open anime eyes, happy open mouth
adb.set_expression("annoyed")        # Furrowed brows, dash mouth, sideways glare

# Gaze & micro-acting
adb.look("camera")                   # Direct eye contact with viewer
adb.look("nemi")                     # Looking toward Nemi (camera left)
adb.blink(0.12)                      # Natural quick blink
adb.head_tilt_to(degrees, duration)  # Expressive head tilt
adb.freeze_stillness(duration)       # Absolute comedic stillness
```

---

## 3. The Cool $\leftrightarrow$ Cute Dynamic

The core acting mechanic for ADB is the **Cool $\leftrightarrow$ Cute Contrast**:
1. **Normal Baseline**: ADB stands with relaxed, calm, understated confidence.
2. **Cute Interruption**: When Nemi gives ADB a compliment, or when an anime topic is mentioned, ADB is caught off guard $\rightarrow$ cheeks flush soft pink, eyes widen slightly, small shy smile appears.
3. **Cool Recovery**: Within 1–2 seconds, ADB blinks, straightens posture slightly, and smoothly resumes the calm, composed exterior.

---

## 4. Interaction Dynamic with Nemi

* **Teasing & Mutual Irritation**: ADB playfully teases Nemi; Nemi gets annoyed; ADB smirks. In reverse, Nemi does something goofy; ADB delivers an unimpressed deadpan glare. The relationship is strictly 50/50 balanced.
* **Shared Anime Passion**: When anime is mentioned, ADB's calm demeanor shatters into instant enthusiastic excitement alongside Nemi.
* **Mutual Support**: When challenges occur, ADB is dependable, attentive, and offers quiet, steadfast help without drama.
* **Best Friends Core**: Their connection is grounded in mutual comfort, shared humor, and total ease in each other's presence.
