# Expressive retakes for the external edit

These recordings address the user's rejected flat voice performance while retaining the canonical Aiden speaker, Qwen CustomVoice model, language, sample rate and exact base identity paragraph. Each request adds a separately recorded performance direction. Shared voice configuration and engine were not edited. There is no pitch, formant or EQ processing.

Each source take is one coherent paragraph. Adjacent JSON files retain the exact script, delivery direction, seed and source/configuration hashes. Earlier rejected voices and movies are preserved.

| Take | Duration | Purpose |
| --- | ---: | --- |
| A | 16.64 s | Confident challenge; more upward inflection in the middle |
| B | 15.76 s | Brisker candidate with a measured lowering into the payoff |
| C | 17.12 s | Concise performance paragraph; slower resulting delivery |
| D | 16.08 s | Shorter challenge wording and understated direction |

A–C say: “A message to every storytime animator. My name is A D B. I'm dangerously underwatched. And I'm gonna steal your watch time. By becoming the biggest storytime animator in the world. I've already got the stories. Now I just gotta be the biggest.”

D replaces the challenge with “Stealing your watch time. Becoming the biggest storytime animator in the world.”

`edit_timeline.json` and `narration_25s.wav` prepare take B. The `d_` counterparts prepare D. Individual thought-section WAVs retain natural internal pauses and receive only 3 ms edge ramps. D's challenge is 4.83 seconds and can occupy 9.50–14.33 seconds. Source takes remain uncut alongside these derived files.

Large-v3-turbo ASR recognized all intended words in all four takes; word timing accompanies each source. No clipped samples were found in A–D. Rough per-keyword F0/energy/duration evidence is saved with the generation scripts at `nemi/episodes/ep17_message_to_storytime_animators/audio/edit_r8/KEYWORD_PROSODY.json`. These measurements do not certify naturalness or perceived emotion; no subjective listening approval is claimed.

## Final external edit mix

`mix_r8.wav` is the current 25-second stereo 48 kHz PCM24 mix; `final_narration_edited.wav` contains narration alone. B supplies hook/name/identity/payoff and D supplies the shortened challenge. `final_words.json` has current semantic word times. Exact source bounds, hashes and mix settings are in `FINAL_MIX_PROVENANCE.json` and the episode's `edit_rebuild/sound_timeline.json`.

The reference hybrid soundtrack retains its source clock and gain. Actual spoken thought intervals duck it by 24 dB, with 50 ms attack and 80 ms release. One constant narration balance gain targets a −6 dBFS peak before mastering; one constant master gain produces −17.99 LUFS integrated and −1.62 dBTP. The 256 kbps AAC check decodes at −18.00 LUFS and −1.63 dBTP. No dynamics processor, EQ, pitch or formant processing was used, and no extra SFX were added. Emotional listening quality remains unverified.
