# EP15 R5 final actor/timing audit

Reviewed scene SHA256 `881d034f25fc1989c223ad9dec5fe3b687d2054b64d6c9892370066fa6dd27e1`. This supersedes the earlier single-instance timing review. No source or production files were changed by this audit.

The final scene uses two instances of the same unchanged Nemi rig (`author: nemi`); the rig directory has no Git diff. Scene metadata differs from canonical R5 only by 61 city-word actor aliases. All 384 words/times, source hashes, clip authors, identity policy and audio hash are identical. Scene metadata SHA256 `ff910561950ffb319ded0d2ee350ab37c5b7ee71fd5bb78151b46204717e6a0d`; canonical metadata `eba5ef301e6dc633435a79e0cf093d152ce82fc351244d864b0ecca26009b7fa`; narration `d0f344c6575bc5201688db498b37fa49dcbad6dcce83716b599fba11ceb677d6`.

All 107 captions cover every word once with exact text/endpoints and the correct actor alias. All 823 word-derived mouth intervals reconstruct exactly: 692 main + 131 city, positive and nonoverlapping inside measured words. All 12 script groups match the same final clock and alias. Last speech/mouth ends at 147.128148s; total remains 150.200s within the user's 150–180s request. No stale R1 word clock was found.

Full Stage sampling checked all **4,506 output frames**: exactly one Nemi instance is visible throughout. The city instance owns 23.618889–46.963704. Across all 700 city-phone frames, the visible hand stays in grip shape 10, the phone geometry stays inside the frame, and maximum socket/grip error is **0.000152588 screen px**. Maximum consecutive phone world-origin step is 0.8143px. At the city-end cut, the phone clears and the visible main hand is relaxed. These frame/contact checks do not replace visual review for layering.

Final contact still passes: initial visibility has grip 10; held-to-resting phone origin jump at 137.768148 is **0.000000000px**, with continuous 90° tilt and bottom y510. The hand withdraws to relaxed shape 0. Hand-window-end jump at 138.418148 is **0.000251654px**, with a stable −41° wrist. The final portrait clears the phone with a relaxed hand. Detailed samples and exact probe source are saved in `render_records/r5_final_actor_timing_probe.json`.

The unchanged canonical voice retains the prior identity/waveform review. Watch the missed-too 1.56s hold, Neeko 1.50s hold and final 3.072s speech-to-end hold in playback for emotional pacing. No further audio cuts are recommended. This audit verifies timing, visibility and sampled contact; current integrated/full playback approval remains pending.
