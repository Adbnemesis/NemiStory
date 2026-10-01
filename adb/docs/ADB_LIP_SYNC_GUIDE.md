# ADB Lip Sync Guide
## Independent Mouth Rig, Phoneme Shapes, and Voice Synchronization Standards

**Document Status**: LOCKED & AUTHORITATIVE SPECIFICATION  
**Character**: ADB (Independent Storyteller)  
**Location**: `adb/docs/ADB_LIP_SYNC_GUIDE.md`

---

## 1. Architectural Independence

> **ADB OWNS AN INDEPENDENT MOUTH RIG AND LIP-SYNC CONTROLLER.**
> 
> ADB's speech is never wired through Nemi's facial node or mouth system. ADB has an autonomous parametric mouth subsystem optimized for ADB's slightly wider, more stylized anime mouth geometry.

---

## 2. Standardized Phoneme Mouth Shapes

The ADB mouth controller provides 8 core procedural shapes:

```
    NEUTRAL              TALK_OPEN              TALK_WIDE
   ─────────             ╭───────╮            ╭───────────╮
                         │       │            │           │
                         ╰───────╯            ╰───────────╯
   (Closed rest)       (Standard A / O)       (Broad E / AE)

    TALK_ROUND             SMALL_O                 SMIRK
      ╭───╮                 ╭──╮                   ────╭─
      │   │                 │  │                       │ 
      ╰───╯                 ╰──╯                       
   (Rounded U / W)       (Stunned O / OH)         (Teasing slant)

     DEADPAN                SMILE
   ═════════             ╰───────╯
  (Straight dash)       (Warm pleasant)
```

| Shape Key | Target Phonemes / Emotions | Visual Geometry |
|---|---|---|
| `neutral` | Silence, pause, closed consonants (M, B, P) | Gentle charcoal horizontal curve |
| `talk_open` | Standard open vowels (A, AH, UH) | Soft rounded lozenge with dark inner oral cavity |
| `talk_wide` | Wide spread vowels (EE, EH, AY, I) | Stretched horizontal opening showing subtle top teeth |
| `talk_round`| Rounded vowels (OO, OH, W) | Compact rounded circle with soft corners |
| `small_o` | Surprised gasps, whispers, tiny 'o' | Small vertical oval |
| `smirk` | Teasing, witty banter | Asymmetrical upward curve pulling toward right cheek |
| `smile` | Warmth, agreement, laughing | Wide upward crescent |
| `deadpan` | Disbelief, silent comedy hold | Rigid, flat horizontal dash line (`—`) |

---

## 3. Directorial API & Voice Synchronization

### Automatic Speech Pacing
```gdscript
# Trigger programmatic speech cadence during voice playback
adb.start_speaking(cadence_speed: float = 12.0)
adb.stop_speaking() # Instantly clamps mouth to neutral or current emotion
```

### Explicit Phoneme Streaming
```gdscript
# Precision frame-accurate mouth queuing for high-impact lines
adb.set_mouth("talk_wide")
await get_tree().create_timer(0.08).timeout
adb.set_mouth("talk_round")
await get_tree().create_timer(0.12).timeout
adb.set_mouth("neutral")
```

---

## 4. Lip-Sync Best Practices

1. **Snap, Don't Float**:
   - Mouth shapes should transition rapidly (`0.03s` to `0.05s`). Slow morphing looks rubbery and detached from human speech.
2. **Close on Pauses**:
   - The instant a spoken word ends and an audio pause begins ($\ge 0.10s$), close the mouth immediately. Never leave a gaping mouth hanging during audio silence.
3. **Comedic Silence Clamping**:
   - On deadpan punchlines, instantly clamp the mouth into the `deadpan` flat dash.
