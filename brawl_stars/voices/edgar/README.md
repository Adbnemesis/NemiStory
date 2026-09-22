# Edgar Voice Performance Bible (Cutenemi / Brawl Stars)

> **Vocal Identity**: Young adult male American English (18–21 impression), lower-mid pitch register, relaxed, skeptical, cynical gamer. Unimpressed by grandiosity, masters the flat matter-of-fact deadpan delivery (*"He died."*, *"Yeah, that's probably fine."*). Sounds like a real human comedy voice actor performing with dry comic timing and unbothered irony.
>
> 📖 **Writing Comedy Dialogue?** Refer to the [Brawl Stars Comedy Scriptwriting Bible](file:///Users/talus/Documents/adb/brawl_stars/voices/COMEDY_SCRIPTWRITING_GUIDE.md) for scene formulas and formatting tricks.

---

## 1. Master Reference Anchors

Edgar's voice is cloned from the master comedic performance anchor (`edgar_anchor_master.wav`).

Master anchor files are located in [`brawl_stars/voices/edgar/selected/`](file:///Users/talus/Documents/adb/brawl_stars/voices/edgar/selected/):

1. **Master Anchor**: [`edgar_anchor_master.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/edgar/selected/edgar_anchor_master.wav) (4.10s)
   - *Verbatim*: *"But you're level 50, I'm pretty sure the main legendary Pokemon is usually like level 70 or something. Yeah, I'm not using my Master Ball on you."*
2. **Casual Throwaway Anchor**: [`edgar_anchor_casual.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/edgar/selected/edgar_anchor_casual.wav) (3.30s)
   - *Verbatim*: *"Yeah, and I'll catch you with an Ultra Ball instead, wait."*
3. **Annoyed Anchor**: [`edgar_anchor_annoyed.wav`](file:///Users/talus/Documents/adb/brawl_stars/voices/edgar/selected/edgar_anchor_annoyed.wav) (1.60s)
   - *Verbatim*: *"Hey, can you please stop flying around me?"*

---

## 2. Emotional Acting Presets

Defined in [`brawl_stars/voices/edgar/config/edgar_presets.json`](file:///Users/talus/Documents/adb/brawl_stars/voices/edgar/config/edgar_presets.json):

| Preset | Energy | Instruction | Best For | Example Line |
|---|---|---|---|---|
| `deadpan` | Low | `Deadpan, completely flat matter-of-fact delivery, zero drama, totally calm.` | Immediate reaction to teammate disaster | `"He died."` |
| `dry_sarcasm` | Normal | `Understated dry sarcasm, flat conversational cynicism, subtle sarcastic deadpan.` | Cynical observations, roasts | `"She has a hypercharge and you have three cubes."` |
| `tired_annoyance` | Low | `Tired, disappointed annoyance, short exasperated sighing tone.` | Teammate doing dumb play | `"Bro. Come on."` |
| `whisper_disbelief` | Low | `Soft breathy whisper of utter existential disbelief, stunned confusion.` | Watching impossible stupidity | `"...why?"` |
| `chuckle` | Normal | `Quiet sarcastic chuckle or snort before speaking, cynical amused disbelief.` | Laughing at teammate mistake | `"PFFT—bro, what did I tell you?"` |
| `casual` | Normal | `Casual, almost throwaway delivery, relaxed conversational speech.` | Baseline chill conversation | `"Yeah, that's probably fine."` |
| `explosive_shout` | Extreme | `Genuine loss of composure, sudden desperate shout, cracking with exasperation.` | Rare moments of breakdown | `"WHY WOULD YOU DO THAT?!"` |

---

## 3. How to Generate Edgar Dialogue

Use [`brawl_stars/voices/edgar/config/generate_edgar.py`](file:///Users/talus/Documents/adb/brawl_stars/voices/edgar/config/generate_edgar.py):

### Single Line Generation
```bash
# Deadpan delivery
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/edgar/config/generate_edgar.py \
  --text "He died." \
  --emotion deadpan \
  --output edgar_he_died.wav

# Dry sarcasm
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/edgar/config/generate_edgar.py \
  --text "Yeah, I'm pretty sure that's illegal." \
  --emotion dry_sarcasm \
  --output edgar_illegal.wav

# Pitch modulation (e.g., -1.5 semitones for deeper tone)
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/edgar/config/generate_edgar.py \
  --text "Bro, are you serious right now?" \
  --pitch -1.5 \
  --output edgar_deep.wav
```

### Script Batch Generation
Create a JSON file:
```json
[
  { "text": "Bro, are you seriously picking Edgar into a Shelly with Super?", "emotion": "deadpan", "output": "scene_01.wav" },
  { "text": "He died.", "emotion": "deadpan", "output": "scene_02.wav" }
]
```
Then run:
```bash
/Users/talus/Documents/adb/.venv/bin/python brawl_stars/voices/edgar/config/generate_edgar.py --script scene.json
```
