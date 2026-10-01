# Common Subtitle System
## Restrained Word Pacing, Voice Synchronization, and Visual Typography Standards

**Document Status**: LOCKED & AUTHORITATIVE COMMON SPECIFICATION  
**Scope**: Shared across all storytime channels (Nemi, ADB, and future productions)  
**Location**: `docs/animation/COMMON_SUBTITLE_SYSTEM.md`

---

## 1. The Golden Rule of Storytime Subtitles

```
┌────────────────────────────────────────────────────────┐
│               THE MANDATORY SUBTITLE RULE              │
│                                                        │
│            MAXIMUM 5 VISIBLE WORDS PER CARD            │
│               (OPTIMAL RANGE: 2 TO 4 WORDS)            │
└────────────────────────────────────────────────────────┘
```

> [!CRITICAL]
> **Subtitles exist to assist comprehension, not to replace the animation.**
> 
> When viewers are forced to read full paragraphs or sentences of 8–15 words, their eyes leave the character's facial acting and hand-drawn doodles to read text. By restricting each subtitle card to **$\le 5$ words** synced precisely to speech cadence, the viewer reads the card in a split-second peripheral glance and keeps their attention locked on the performance.

---

## 2. Pacing & Chunking Rules

1. **Short, Natural Phrases**:
   - Break long sentences along grammatical and spoken pause boundaries.
   - Example Sentence: *"So I went down to the store and bought three giant boxes of cereal."*
     - Card 1: *"So I went down..."* (4 words)
     - Card 2: *"to the store..."* (3 words)
     - Card 3: *"and bought three..."* (3 words)
     - Card 4: *"giant boxes of cereal."* (4 words)
2. **Zero Word Streaming / Karaoke**:
   - Do **NOT** use flashing word-by-word karaoke bouncing or rainbow coloring.
   - The entire 2–4 word chunk appears cleanly, holds while spoken, and vanishes or swaps to the next chunk.
3. **No Subtitle Drift**:
   - Subtitle cards must never linger on screen into dead pauses or overlap into the next sentence.
   - When speech pauses for $\ge 0.35s$, clear the subtitle card to let the visual stillness breathe.

---

## 3. Visual Styling & Typography

At native 1920×1080 canvas:

* **Font Family**: Clean, highly legible sans-serif or crisp rounded sans (e.g., modern legible grotesque or display typography).
* **Font Size**: `32px` to `38px` (large enough for mobile readability without dominating the screen).
* **Text Color**: Clean white (`#ffffff`) or warm light cream (`#faf8f5`).
* **Outline / Stroke**: Solid charcoal/black outline (`#23211f`) with thickness `8px` to `10px`.
* **Screen Placement**:
  - Horizontal: Dead-center horizontally.
  - Vertical: Anchored to the bottom margin: `offset_top = -90px`, `offset_bottom = -25px`.
  - Margin buffer: Ensure subtitles never cover characters' feet, sitting chair bases, or foreground desk props.

---

## 4. Subtitle QA Verification Checklist

- [ ] Does any single subtitle card exceed 5 words? If yes, **FAIL**.
- [ ] Do words appear before the voice speaks them? If yes, **FAIL**.
- [ ] Do subtitles linger after the speaker has stopped talking? If yes, **FAIL**.
- [ ] Are subtitles covered by props or doodles? If yes, **FAIL**.
- [ ] Is the outline thick enough to read clearly over both dark clothing and light paper backgrounds? If no, **FAIL**.
