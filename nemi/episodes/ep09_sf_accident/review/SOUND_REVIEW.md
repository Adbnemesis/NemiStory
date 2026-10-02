# Expanded sound pass — 2026-10-02

34 authored event cues, using 28 catalog sounds. Replaced the former quiet/limited mix with familiar comic reversals, chimes, boings, clear prop/illustration accents and motivated transitions. Timing follows original caption/word cues; no borrowed vocal reactions. Saved plans include intent, catalog/license, level and nearby-dialogue measurements.

Measured cue RMS relative to nearby narration: -14.3 to 0.8 dB. No cue fell below the -18 dB review threshold. Short transients and longer textures differ; these measurements do not prove subjective balance. Peak-safe constant master calibration was rerun after all cue changes. See `sound_1080p_qa.json` and EP08's `sound_4k_qa.json` for encoded media checks.

Sound-only re-export mixes the approved original narration and the new cues, never the old mixed soundtrack. Approved picture streams are byte-identical by video stream hash; resolution/duration/frame counts match. The previous still/playback camera review therefore remains applicable. Original character rigs, narration identity/pitch/tempo, timing, captions and script are unchanged; protected-source comparison passed for 267 files. A complete human listening review is not claimed. Preview the current master at normal listening volume for final subjective balance.

User explicitly requested removal of previous renders. Only superseded exports/associated generated sidecars in these two episode render folders were removed after replacement checks. Source recordings, animation source and review history remain. See `render_cleanup.json` for filenames. Current masters are listed in `../renders/RENDERS.md`.

Reproduce cue choices with `.venv/bin/python tools/storytime/revise_ep08_ep09_sound.py` (specifically writes both authorized episodes). Re-export a new master with `.venv/bin/python tools/storytime/reexport_episode_sound.py --episode 9 --picture <current master> --output <new revision filename in this episode renders/>`. Reusing approved pictures is appropriate only for sound-only changes.
