# Character plates for the external edit rebuild

These are transparent canonical character captures. Godot is used only to pose and capture the characters; it does not create the final edit, typography, background, transitions, soundtrack, or compositing.

`nemi/` and `adb/` contain 2000 × 2200 RGBA PNGs. The shared canvas has rig origin `(1000, 1100)` and scale `4.5`. Keep this registration while layering props and foreground hands, then crop the assembled insert for the edit. `_closed` uses a confident smirk, with a neutral dry mouth on pose 06. `_open` and `_wide` are optional expressive mouth inserts rather than a word-triggered flap cycle.

The numbered acting choices are direct confidence, a smug lean with folded arms, arms spread in bravado, a pointed challenge, a raised-hand self-presentation, a still dry payoff, sketchbook clutch, oversized sketchbook hoist, and chin thought. Pose 10 was an attempted hands-back variant and still reads folded because of canonical drawing order; do not use it for a behind-back claim. Prefer a crop of 01 for the proud portrait. The first audition was rejected during internal review because the legacy Nemi library arm directions crossed the intended wide gestures. `rejected_initial_pose_audition.jpg` preserves that diagnostic; use the current per-author audition sheets.

`anchors.json` provides actual raw-canvas wrist and palm positions, hand rotations, chin positions and approximate head tops for each static pose. For poses 07, 08 and 09, `_hands.png` contains the actual character hands on transparency at the exact same canvas registration. Composite character, prop, then foreground hands to preserve contact. The hoist is designed for an oversized sketchbook graphic sitting across the two palms. The clutch is designed for a smaller sketchbook spanning the palms in front of the chest.

Each `motion_NN_to_NN` directory contains 12 ordered RGBA frames sampled over 0.4 seconds using the existing `common/storytime/production/ActingTimeline.gd` and `PerformancePlayer.gd`. These are finite gesture transitions with eyes/head/arms arriving at different times and a stable endpoint. Their per-frame `anchors.json` keeps prop contact available to the compositor. Recipe adjustments are installed in memory in the capture script; existing rigs, pose libraries and expression libraries are preserved.

The capture script and log are retained here for reproducibility. These assets require the final editor's full-cut review; their existence does not approve the finished video or authorize a 4K movie export.
