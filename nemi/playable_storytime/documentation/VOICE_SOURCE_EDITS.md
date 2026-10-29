# Explicit source recording edits

The canonical Sohee model, speaker, identity prompt, source recordings, pitch,
formants and EQ stay unchanged. `tools/voice.py` optionally accepts the episode's
`audio/source_edit_plan.json` before its existing pitch-preserving tempo pass.
The tool does not discover, suggest or trim silence automatically.

```json
{
  "version": 1,
  "notes": "Selected ordinary gaps only; preserve breaths and emotional holds.",
  "clips": {
    "example_take": {
      "source_sha256": "EXACT_64_CHARACTER_SHA256_OF_ORIGINAL_WAV",
      "remove_ranges": [
        {"start": 9.65, "end": 10.95, "reason": "Shorten the ordinary hesitation after you know"}
      ]
    }
  }
}
```

Bounds are seconds in the original unprocessed recording. Replace the example
hash and clip ID with measured production values. The R8 production plan and
`review/r8_source_edit_proposal.json` are the applied example and the numeric
evidence behind its selected ranges.

Each range must be ordered, nonoverlapping and strictly inside its exact hashed
source. It must occupy one gap between independently measured source words,
retaining at least 60 milliseconds next to each word. Approximate recognition
alone is insufficient: the actual removed samples must also measure at or below
−58 dBFS RMS and −45 dBFS peak. These conservative thresholds reject audible
speech or breath energy even when recognition boundaries are wrong. They do
not establish a perceptual listening pass.

Only the listed samples are removed. Every other source sample is retained in
order; there is no blanket silence pass, generated replacement, fade, identity
change or substituted take. The edited array then uses the existing approved
tempo processor. The complete edit-plan SHA256 enters the edited processed
filename, every clip record, assembled timeline and voice provenance. A changed
plan cannot silently reuse an old edited waveform or assembled narration.

Final processed recordings receive fresh independent word alignment. Captions,
mouth intervals, acting, camera and SFX must be rebuilt from those final times.
`voice.py check` revalidates the plan hash, source hash, cuts, protected edges,
sample energy, edited filename, processed alignment and full narration hash.
Preserve the original source, every rejected processed variant and the previous
revision before making a new plan. Story tempo remains normally 1.00–1.12; do
not solve an overflow by silently raising it beyond the reviewed limit.

Run the meaningful bounds/energy/cache tests with:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s nemi/playable_storytime/tests -p test_source_edits.py -v
```
