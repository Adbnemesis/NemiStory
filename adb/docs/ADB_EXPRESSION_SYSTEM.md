# ADB Expression System
## Facial States, Expression Matrix, Micro-Events, and Eye Mechanics

**Document Status**: LOCKED & AUTHORITATIVE SPECIFICATION  
**Character**: ADB (Independent Storyteller)  
**Location**: `adb/docs/ADB_EXPRESSION_SYSTEM.md`

---

## 1. Master Expression Matrix

The ADB facial system is driven by parametric vector controls governing eyes, eyebrows, mouth shapes, and cheek blush:

| State | Eyes | Eyebrows | Mouth | Blush | Character Vibe |
|---|---|---|---|---|---|
| **NEUTRAL** | Almond, calm open (1.0) | Level, relaxed | Small gentle line | 0.0 | Calm, composed baseline |
| **CUTE** | Soft curved, open (1.1) | Softened, gentle arch | Tiny warm smile | 0.65 | Caught off guard, sheepish |
| **DEADPAN** | Narrowed slit (0.45) | Flat horizontal | Straight dash line (`-`) | 0.0 | Unimpressed comedic stare |
| **SMUG** | Half-lidded (0.75) | Asymmetric (one arched up) | Dry corner smirk | 0.0 | Confident, teasing wit |
| **EXCITED** | Wide sparkle (1.30) | High arched | Happy open smile | 0.40 | Anime/creative passion |
| **EMBARRASSED**| Wide stunned (1.25) | Furrowed slant | Small round 'o' | 0.90 + hatch | Flustered exposure |
| **ANNOYED** | Sharp narrowed (0.50) | Inward furrowed | Tight grimace dash | 0.0 | Mild irritation |
| **CONFUSED** | Uneven (one wide, one squint)| Asymmetrical slant | Wavy uncertain curve | 0.0 | Perplexed incomprehension |
| **SHOCKED** | Maximum wide (1.40) | Raised to hairline | Dropped jaw oval | 0.0 | Sudden jaw-drop revelation |
| **HAPPY** | Curved crescent (0.85) | High relaxed | Warm open smile | 0.25 | Genuine laughter / warmth |
| **AMUSED** | Playful squint (0.65) | Soft arch | Suppressed chuckle | 0.20 | Secretly entertained |
| **TIRED** | Heavy droop (0.35) | Drooping outer slant | Slack open slit | 0.0 | Sleep-deprived burnout |
| **SURPRISED** | Sudden widen (1.20) | High alert | Small open circle | 0.15 | Unexpected discovery |
| **FRUSTRATED** | Tightly clenched (0.20)| Low heavy furrow | Sharp downturned zigzag | 0.0 | Comedy exasperation |

---

## 2. Micro-Events & Eye Mechanics

Natural human faces constantly experience subconscious micro-adjustments. The ADB rig provides dedicated micro-event methods:

### 1. Blinking Mechanics
* `blink(duration = 0.12s)`: Standard conversational blink. Eyelids snap closed in `0.04s`, hold for `0.02s`, open in `0.06s`.
* `half_blink(duration = 0.14s)`: Eyelids lower to 40% openness and rise slowly, communicating dry boredom or skepticism.

### 2. Gaze Tracking & Eye Darts
* `look("camera")`: Direct eye contact with the viewer down the camera lens (default).
* `look("side_eye")`: Pupils flick to extreme corner without head turning (classic meme reaction).
* `look("up")`: Looking upward while thinking or recalling a memory.
* `look_at_pos(Vector2)`: Parametric gaze targeting props, doodles, or co-stars.
* **Micro-Saccades**: Subtle random jitter of pupils (`±1.5px`) occurring every 2.5–4.0 seconds during speech prevents the eyes from looking dead.

### 3. Asymmetric Eyebrow Control
* The left and right eyebrows can be manipulated independently via `brow_left_angle`, `brow_right_angle`, and `brow_height`.
* A single raised eyebrow paired with narrowed eyes is ADB's signature skeptical expression.
