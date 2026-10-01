# Common Voice-Beat Timing System
## Voice as Master Clock, Storytime Beat Classification, and Timing Alignment Standards

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Universal across all productions (Nemi, ADB, and future characters)  
**Location**: `docs/animation/COMMON_VOICE_BEAT_TIMING.md`

---

## 1. Core Principle: Voice is the Master Clock

> **VOICE IS THE MASTER CLOCK OF ANIMATION.**
> 
> In storytime animation, animation does not dictate speech—**actual recorded narration dictates every visual event**.
> * We never guess timings.
> * We never animate to placeholder speech.
> * We never time beats by arbitrary keyframe spacing.
> 
> The audio waveform of the final voice recording is analyzed down to the millisecond. Every character gesture, facial snap, camera punch, doodle draw-on, subtitle card, and SFX cue is anchored to explicit spoken timestamps.

---

## 2. Storytime Beat Classification Taxonomy

Every narrative script is broken down into structured directorial beats. Each beat falls into one of these canonical categories:

```
┌─────────────────┬────────────────────────────────────────────────────────┐
│ BEAT TYPE       │ PURPOSE & DIRECTORIAL TREATMENT                        │
├─────────────────┼────────────────────────────────────────────────────────┤
│ 1. EXPLANATION  │ Conversational flow. Character explains a concept with │
│                 │ natural posture shifts, hand gestures, and eye contact.│
├─────────────────┼────────────────────────────────────────────────────────┤
│ 2. REACTION     │ Instantaneous emotional shift. Eyes widen or narrow,   │
│                 │ eyebrows cock, posture snaps. Freeze on hold.          │
├─────────────────┼────────────────────────────────────────────────────────┤
│ 3. JOKE         │ Setup to punchline. Pacing accelerates into punchline, │
│                 │ punctuated by camera snap or sudden doodle.            │
├─────────────────┼────────────────────────────────────────────────────────┤
│ 4. PAUSE / HOLD │ Absolute comedic silence (0.4s – 1.5s). Zero character │
│                 │ movement, straight dash mouth, letting the joke land.  │
├─────────────────┼────────────────────────────────────────────────────────┤
│ 5. REVEAL       │ Sudden visual entrance of a character, prop, or truth. │
│                 │ Camera punches in; audio SFX pops.                     │
├─────────────────┼────────────────────────────────────────────────────────┤
│ 6. VISUALIZATION│ Hand-drawn doodle, diagram, or graph draws live to     │
│                 │ clarify or satirize what the speaker is discussing.    │
├─────────────────┼────────────────────────────────────────────────────────┤
│ 7. CUTAWAY      │ Full scene shift into an illustrative anecdote or comic│
│                 │ memory vignette before returning to main studio.       │
├─────────────────┼────────────────────────────────────────────────────────┤
│ 8. NEXT IDEA    │ Transitional breath, character shifts weight to other  │
│                 │ leg or leans forward, resetting staging for new beat.  │
└─────────────────┴────────────────────────────────────────────────────────┘
```

---

## 3. Beat Manifest Schema (`timing.json`)

All production episodes must generate and maintain a formal JSON timing manifest aligning voice segments to directorial events:

```json
{
  "episode_id": "ep_example",
  "master_duration_seconds": 94.50,
  "beats": [
    {
      "beat_id": "beat_01",
      "name": "The Setup",
      "type": "EXPLANATION",
      "time_start": 0.00,
      "time_end": 7.45,
      "camera_preset": "MEDIUM",
      "primary_character": "ADB",
      "segments": [
        {
          "segment_id": "001",
          "start": 0.00,
          "end": 2.40,
          "spoken_text": "I need to confess something.",
          "subtitle_card": "I need to confess something.",
          "acting_note": "Look at camera, slight head tilt, hand to chest.",
          "sfx_cues": []
        },
        {
          "segment_id": "002",
          "start": 2.65,
          "end": 4.10,
          "spoken_text": "I am terrible at drawing hands.",
          "subtitle_card": "terrible at drawing hands.",
          "acting_note": "Deadpan straight face, quick blink, hand morphs to blob doodle.",
          "sfx_cues": [{"time": 3.80, "name": "comedic_boing", "volume_db": -6.0}]
        }
      ],
      "post_beat_hold": 0.60
    }
  ]
}
```

---

## 4. Millisecond Synchronization Rules

1. **Anticipation Lead Time**:
   - Physical body gestures (raising a hand, turning head) should begin `0.08s` to `0.15s` *before* the primary accented word is spoken, mirroring natural human kinesics.
2. **Impact Alignment**:
   - Hand impacts (slapping desk, pointing finger, prop placement) land *exactly* on the first consonant of the accented syllable.
3. **Comedic Hold Buffer**:
   - Always allocate explicit post-beat buffer time (`0.40s` to `0.80s`) at the end of strong jokes before launching into the next narration segment.

## One clock for new productions

[Storytime Direction Workflow](STORYTIME_DIRECTION_WORKFLOW.md) coordinates narration, spoken turns, mouth intervals, captions, acting, illustration, VFX and trimmed/delayed SFX. Named events reject drift between simultaneous cues. The proof uses actual word timestamps; precise phoneme alignment still requires review.
