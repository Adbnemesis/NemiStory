# Expressive retakes for the external edit

The user rejected the prior flat, disconnected voice performance. These recordings keep the exact canonical Sohee speaker, Qwen CustomVoice model, English language, 24 kHz output and unchanged base identity paragraph. A separate performance direction was appended to each request. Shared voice configuration and engine were not edited. No pitch, formant or EQ processing was applied.

Each source take is one coherent paragraph rather than individually generated phrases. Adjacent JSON files record the exact script, separate delivery direction, combined request, seed, source hashes and shared configuration/engine hashes. All rejected recordings and movies remain preserved.

| Take | Duration | Purpose |
| --- | ---: | --- |
| A | 17.04 s | Firm, mischievous challenge with dry ending |
| B | 17.28 s | Daring and amused, stronger stress contrast |
| C | 18.48 s | Shorter performance paragraph; slower resulting delivery |
| D | 16.48 s | Understated direction and tighter challenge wording |

A–C say: “A message to every storytime animator. My name's Nemi. I'm an undiscovered menace. And I'm gonna steal your watch time. By becoming the biggest storytime animator in the world. I'm already the most dramatic. Now I just gotta be the biggest.”

D replaces the challenge with “Stealing your watch time. Becoming the biggest storytime animator in the world.” This was requested as a tighter candidate by the edit director. It preserves montage time without synthetic acceleration.

`edit_timeline.json` and `narration_25s.wav` prepare take B; `d_edit_timeline.json` and `d_narration_25s.wav` prepare D. The individual WAVs are cut at thought boundaries with 3 ms boundary ramps. All natural pauses within each thought remain. The D challenge is 5.17 seconds and can occupy 9.14–14.31 seconds. Take B's payoff has a more pronounced measured lowering than D and is available independently as `payoff.wav`.

Large-v3-turbo ASR recognized every word of all four takes as intended; the analysis files carry measured word times. No clipped samples were found in A–D. `KEYWORD_PROSODY.json` records rough keyword F0, energy and duration observations, including the source reference. These measurements have octave/word-boundary uncertainty and cannot certify perceived emotional quality, naturalness or an exact match to the reference. No subjective listening approval is asserted.

Production scripts live here: `generate_expressive.py`, `analyze_takes.py`, `prepare_sections.py`, `keyword_prosody.py`. They also prepare the ADB version under that episode's `voice/edit_r8/` folder.

## Final external edit mix

`mix_r8.wav` is the current 25-second stereo 48 kHz PCM24 mix; `final_narration_edited.wav` contains the selected narration alone. `build_final_mix.py` selects B for hook/name/identity/payoff and D for the shortened challenge. `final_words.json` maps those exact selected source words to the final scene clock. The current authoritative bounds and mix receipt are `FINAL_MIX_PROVENANCE.json` and the episode's `edit_rebuild/sound_timeline.json`.

The reference hybrid soundtrack remains on its original clock at source gain 0 dB. Actual spoken thought intervals duck it by 24 dB with 50 ms attack and 80 ms release. Narration receives one constant balance gain to peak at −6 dBFS before mastering. One constant master gain gives −18.63 LUFS integrated and −1.50 dBTP. A 256 kbps AAC transcode decodes at −18.61 LUFS and −1.56 dBTP. No limiter, compression, EQ, pitch or formant processing was used. The final files contain exactly 25 seconds.

No extra SFX were added; the supplied soundtrack accents remain. Further paper/prop cues require verified matching visible contact in the external edit. Technical levels and source ASR do not constitute emotional listening approval.
