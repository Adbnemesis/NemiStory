# EP15 voice R5 — 150.200 seconds

This pacing revision reuses all 12 exact approved Sohee source WAVs. Their hashes, speaker, model, identity prompt and 1.00× synthesis provenance were checked against source metadata and current canonical Nemi configuration. No voice was generated; no speaker, pitch, formant or EQ setting changed. The same R1 phrase tempos remain: lines 00, 01, 02 and 06 at 1.08×; all other lines at 1.00×.

The user reported large pauses and a slow episode. Eleven explicitly selected, waveform-reviewed silent windows remove 5.459630s. These are fixed authored source bounds, not threshold-based automatic trimming. The longest deleted window is 0.92s after “moved on”; quiet tails and lead-ins around it remain. Every removed window measures RMS below −60dBFS and peak below −40dBFS. All 384 measured source word intervals remain once, with no deletion touching a measured word. R1 and the canonical recordings remain preserved.

| Source line | Deleted source seconds | Boundary | RMS dBFS | Peak dBFS |
| --- | --- | --- | --- | --- |
| 00 | 8.12–8.42 | contract. / They | -64.4 | -45.7 |
| 00 | 11.06–11.52 | conversation. / I'm | -71.9 | -60.8 |
| 01 | 5.38–6.02 | there. / We | -79.6 | -55.8 |
| 04 | 1.36–1.87 | say. / I | -76.8 | -56.7 |
| 04 | 5.89–6.53 | lives. / But | -73.3 | -56.5 |
| 06 | 9.18–9.63 | energy. / I'd | -77.7 | -66.2 |
| 06 | 11.66–12.11 | say. / Then | -76.6 | -61.1 |
| 07 | 9.02–9.42 | fix. / Maybe | -80.6 | -70.3 |
| 08 | 2.15–2.57 | too. / Neeko | -99.5 | -72.2 |
| 09 | 8.98–9.90 | on. / Sometimes | -80.7 | -64.7 |
| 11 | 6.26–6.70 | hold. / I'll | -83.2 | -56.3 |

Opening lead stays 0.60s. Authored after-line holds total 14.15s, reduced from 18.90s. Rejection, wanting to feel missed, Neeko and the ending still have deliberate reactions. Emotional source pauses after “hurting”, “all”, “them”, “after”, “much”, “people”, “miss them”, “down” and “lot” remain intact. The 2.90s ending hold requires purposeful closing performance. Picture should develop each remaining hold with one readable audience focus, not add dead padding.

Complete duration is 150.200s (2:30.2), 10.200s shorter than R1, within the user's 150–180s requirement. The unrounded authored clock is 150.188148148s; 30fps frame rounding adds 0.011851852s. Last measured speech ends 147.128148s; last source tail ends 147.288148s.

| Source line | Final start | Final end | Tempo | Hold after |
| --- | --- | --- | --- | --- |
| 00 | 0.600000 | 12.711111 | 1.08 | 0.55 |
| 01 | 13.261111 | 23.038889 | 1.08 | 0.70 |
| 02 | 23.738889 | 34.553704 | 1.08 | 0.75 |
| 03 | 35.303704 | 45.783704 | 1.00 | 1.30 |
| 04 | 47.083704 | 58.493704 | 1.00 | 1.10 |
| 05 | 59.593704 | 69.593704 | 1.00 | 1.40 |
| 06 | 70.993704 | 83.938148 | 1.08 | 0.80 |
| 07 | 84.738148 | 95.778148 | 1.00 | 1.00 |
| 08 | 96.778148 | 107.478148 | 1.00 | 1.40 |
| 09 | 108.878148 | 122.038148 | 1.00 | 0.95 |
| 10 | 122.988148 | 134.508148 | 1.00 | 1.30 |
| 11 | 135.808148 | 147.288148 | 1.00 | 2.90 |

`timing_reference_r5.json` rebuilds every word interval through the retained source ranges. It does not reuse R1 scene-clock word times or redistribute words proportionally. `timing_lines_r5.json` groups global word and clip indices by original source line. `retiming_r5.json` supplies all 384 exact old/new word pairs plus piecewise intervals for kept audio, removed silence, and revised holds. Caption, mouth, acting, camera and sound cues must use the new clock. Shared audio placement rounds offsets to milliseconds (at most 0.5ms); metadata retains the exact planned clock.

Measured final WAV: 24000Hz mono, 150.200s, peak -4.38dBFS, RMS -26.16dBFS, zero clipped samples. SHA256 `d0f344c6575bc5201688db498b37fa49dcbad6dcce83716b599fba11ceb677d6`. Machine source/timing/waveform checks passed. An offline cached large-v3-turbo recognition of the completed R5 WAV found 384 words in the same normalized lexical order as the preserved R1 final-ASR pass, with no new word change. The recognizer repeats the existing missed/miss, I/I'd and Neeko/Nico source/final variants; these do not trigger invented source edits. Median endpoint difference from exact source-bound word timing is 0.008148s; maximum endpoint difference is 0.151852s. ASR sometimes places onsets into preceding silence and is used only as a completeness cross-check. See `review/audio/pacing_crosscheck_r5.json`. Direct human acoustic audition has not been performed; neither naturalness nor full-movie mix approval is claimed. The root production review must inspect actual playback.

The longest measured internal pause is now 0.84s (the preserved emotional breath after “hurting”), reduced from 1.32s. Median word-to-word interline gap falls from 1.66s to 1.18s; maximum falls from 2.16s to 1.62s. The 47 piecewise clock intervals are continuous and cover the complete old and new timelines.
