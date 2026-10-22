# EP17 reproduction

Run from repository root. Existing source audio is protected by text/identity/hashes and is reused; resynthesis cannot reuse stale timings. The final scene is scene_r6_1080p.json, prepared narration is voice/narration_r3.wav and exact input timeline is timing_reference_r3.json. Source WAVs and movies are local media excluded from Git.

`python3 tools/storytime/validate_scene.py nemi/episodes/ep17_i_thought_1000_subscribers_would_fix_everything/scene_r6_1080p.json`

`python3 tools/storytime/render_scene.py --spec nemi/episodes/ep17_i_thought_1000_subscribers_would_fix_everything/scene_r6_1080p.json --output nemi/episodes/ep17_i_thought_1000_subscribers_would_fix_everything/renders/NEMI_EP17_1000_Subscribers_r6_1080p_REVIEW.mp4`

The renderer refuses existing names; choose a fresh revision if regenerating. No4K request or approval receipt exists. Do not rerun the pace builder into an existing output; protected plans and sources remain alongside the episode.

Fresh proof uses --start24 --duration10. Integrated review uses --start54 --duration60, on original scene clock. All export windows align to30fps frames.
