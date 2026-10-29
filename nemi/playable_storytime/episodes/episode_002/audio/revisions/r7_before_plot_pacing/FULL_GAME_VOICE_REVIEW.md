# Full drawing-escape voice review

240.000-second canonical Sohee narration is ready: 13clips, 441scriptwords, 442measuredASRwords. No full-scale or nonfinite samples. Narration SHA-256: `674ddd89c33bd8fc9229bb134535958d564d41755ccdb697bf411c0d3e6c568c`.

The approved R4 hook, door admission and tear discovery recordings were reused byte-for-byte. The old 40-second narration, exact dialogue, provenance, timing and mix are hash-preserved under `revisions/r4_before_full_game/`.

Only `bridge_choice` uses the root-approved 1.08 pitch-preserving tempo: 24.080s source becomes 22.305917s and fits its 23.1s window. Every other take remains 1.00. No source cuts, pitch/formant/EQ changes or identity substitutions.

The first race-failure take contained only the opening fragment. It was not accepted as valid narration: its source, processed audio and both alignments are preserved under `revisions/failed_race_take/`. The replacement exact-text recording lasts 20.240s and matches all 42 script words in normalized ASR.

|Clip|At|Finalduration|End|Windowend|Tempo|
|---|---:|---:|---:|---:|---:|
|drawing_hook|0.350|17.280|17.630|17.900|1.00|
|phone_chapter_hint|18.100|4.080|22.180|23.750|1.00|
|door_admission|24.400|7.527|31.927|33.000|1.00|
|door_recovery|34.000|9.600|43.600|47.500|1.00|
|tear_discovery|48.300|8.320|56.620|57.500|1.00|
|desk_beyond|58.000|9.760|67.760|71.500|1.00|
|bridge_choice|72.400|22.306|94.706|95.500|1.08|
|bridge_failure|96.400|16.640|113.040|119.500|1.00|
|fold_cross|120.400|20.800|141.200|143.500|1.00|
|eraser_choice|144.400|16.400|160.800|167.500|1.00|
|race_failure|168.400|20.240|188.640|191.500|1.00|
|eraser_ride|192.400|18.800|211.200|215.500|1.00|
|studio_ending|216.400|17.600|234.000|239.500|1.00|

ASR differences are retained honestly: doorknob→door knob; recoverytear→tier; deskparagrapha→the; bridgeroute→root andfour→for; finalfoldThere→They’re. These are recognizer hypotheses, not a hearing judgment. The root may review same-unit spelling captions without changing raw alignments; do not silently infer phonemes or claim listened pronunciation.

Voice checker passes canonical implementation/source/final/processed alignment hashes, exact dialogue placements, authored windows and complete 240-second float PCM format. All source and final word measurements are preserved. Human naturalness/pronunciation review and final encodedmix listening remain pending.
