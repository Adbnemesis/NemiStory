# EPISODE 03 — PRODUCTION NOTES & DIRECTORIAL LOG
## "Storytime: My Mom Scolded Me"

---

## 1. Production Context & Directorial Intent

Episode 03 fulfills the user's explicit directive:
> *"TASK: CREATE A COMPLETE NEMI STORYTIME ANIMATION*  
> *STORY: 'MY MOM SCOLDED ME'*  
> *This should be a PERSONAL STORYTELLING VIDEO where Nemi is telling the audience about a time her mom scolded her.*  
> *IMPORTANT: NEMI IS THE STORYTELLER.*  
> *The video should feel like Nemi is casually sitting/talking to the audience and narrating something that happened in her life, while the animation continuously VISUALIZES, exaggerates, illustrates, and jokes around with what she is saying.*  
> *Do NOT treat this as a conventional cartoon episode where Nemi and her mom simply act out a scene from beginning to end.*  
> *The storytelling is driven by Nemi's narration, while the visuals creatively represent the story."*

### Key Narrative & Visual Pillars
1. **Nemi as Sole Storyteller**: Nemi commands the fourth wall from the very first frame. The scene transitions, props, and flashback moments exist as playful, illustrative extensions of her spoken story.
2. **Visual Exaggeration & Metaphors**: When Nemi mentions the frozen chicken, it isn't just cold—it's an impenetrable block of prehistoric permafrost with a -40°C temperature gauge. When the emergency defrost protocol begins, Nemi pulls out a hairdryer like a blaster and sparks fly from the microwave.
3. **Maternal Presence & Respect**: Mom is rendered in Nemi's authentic hand-drawn vector art style (`nemi/characters/mom/Mom.tscn`), featuring expressive dark linework, a soft apron tint, maternal aura pulses, and scanning radar arcs. The scolding is depicted not as abusive screaming, but as the universally recognized, deeply devastating quiet maternal disappointment.
4. **Comedic Deadpan Holds**: The episode utilizes absolute stillness beats (e.g. after the gavel stamp, during the 4-hour realization freeze, during the cold cereal dinner) to let the comedic timing breathe with zero audio or visual clutter.
5. **Cereal Dinner Payoff**: The humble aftermath where Nemi and Mom eat cold cereal for dinner while the rock-hard chicken watches them from across the kitchen with a "STILL FROZEN" sign.

---

## 2. Rule Compliance Log

| Rule / Requirement | Mandate | Implementation & Verification Status |
|---|---|---|
| **Rule 7** | Zero Gender Self-Reference for Nemi | **100% PASSED**. Master script and subtitles audited. Zero occurrences of `she`, `her`, `herself`, `girl`, `woman` used by Nemi to refer to Nemi. All self-references use first-person (`I`, `me`, `my`, `myself`). |
| **Directorial Mandate** | Personal Storytime Format | **100% PASSED**. Visuals illustrate, exaggerate, and joke around with Nemi's continuous first-person narration rather than enacting a dry cartoon play. |
| **Duration Gate** | 1.5 – 2.0 Minutes (90 – 120s) | **100% PASSED**. Total master duration is **110.89 seconds (1.85 minutes)** across 23 spoken segments and 9 beats. |
| **Resolution Gate** | 1080p @ 30 FPS ONLY (Strictly No 4K) | **100% PASSED**. Built and rendered at **1920 × 1080 @ 30 FPS**. |
| **Subtitles Gate** | $\le 5$ Words Per Card | **100% PASSED**. `Episode03Subtitles.gd` parses all 23 segments into bite-sized cards of 2 to 4 words (maximum 5 words) with zero overflow. |
| **Doodle Style** | Dark Ink Hand-Drawn Linework | **100% PASSED**. `Ep03Doodles.gd` uses master charcoal ink (`#2b2623`) with organic line variation and hand-drawn accents. |
| **Audio & SFX Policy** | Voice Clock, BGM Off, Sparse SFX $\le 2$s | **100% PASSED**. Voice is master clock (`EP03_voice.wav`, Sohee Qwen3-TTS); BGM is OFF; 16 event SFX mixed in `EP03_audio_sfx_master.wav` with -1.20 dBFS peak and $\ge 1.0$ dB headroom; deadpan pauses preserved in silence. |
| **Mom Co-Star Rig** | Hand-drawn vector character matching style | **100% PASSED**. `Mom.tscn` / `Mom.gd` implements hand-drawn vector linework matching Nemi, with full pose and aura states. |
