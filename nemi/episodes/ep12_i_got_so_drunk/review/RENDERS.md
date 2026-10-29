# EP12 Render Index — "I Got So Drunk"

Current Final Master: [R5 Native 4K Master](../renders/NEMI_EP12_I_Got_So_Drunk_r5_4K_FINAL.mp4) — 3840×2160, 30fps, 148.2 seconds, 4,446 decoded video frames. 28,145,483 bytes; SHA-256 `75901888b4b8fbdd914bed46f5dd29bf3e03c6b8346d4aaa4c9315cc0865287d`.

The user explicitly approved the complete R5 1080p preview cut: *"okay this is awesome, not just render this in 4k, delete all others renders, do not change anything at all except the quality to 4k"*. [1080P_APPROVAL.json](1080P_APPROVAL.json) records the actual user quote and verified input hashes. The native 4K export rerasterizes the identical approved scene, timing, and mix with zero modifications to scene script, timing, or audio.

## Production & Specification Details
- **Final 4K Master**: `renders/NEMI_EP12_I_Got_So_Drunk_r5_4K_FINAL.mp4`
- **Scene Spec**: [scene.json](../scene.json) (SHA-256 `b2cefa913209f9685c989ef669845d49f89d81991d8c1fe376f1c31c2ad9ec76`)
- **Render Inputs Signature**: `d934f5527befd3c678a3aec8d11e3b419722105fa1450498dda3e1e97a878df2`
- **Runtime**: 148.2 seconds (runtime cap: $\le 150.0$s; passed with 1.8s margin)
- **Video Stream**: 3840×2160 (4K UHD), 30 fps, H.264, 4,446 decoded frames
- **Audio Stream**: AAC stereo, 48 kHz, -18.6 LUFS integrated loudness, -1.4 dBFS true peak headroom
- **Narrator**: Canonical Sohee voice (Qwen3-TTS 24kHz original source WAVs, pitch-preserving tempo 1.12–1.14×)
- **Cast**: Nemi (lead/narrator), ADB (co-star in living room), and 4 college friends (side characters in Beats 2 & 3)

## Quality Assurance & Verification
- [Final 4K QA](final_4k_qa.json): Complete ffprobe stream report, frame count, audio metrics, and visual review notes.
- [4K Review Stills](4k_stills/): 7 representative native 4K PNG frames verifying layout, props, linework, and character staging across all narrative beats.
- [Approval Receipt](1080P_APPROVAL.json): User approval receipt binding preview hash, spec hash, input signature, and final 4K SHA-256.

## Retention & Cleanup Record
Per the user's explicit instructions (*"delete all others renders, do not change anything at all except the quality to 4k"* and *"i hope u deleted other renders, only 4k one is there and renmaed it as well"*) and the repository `AGENTS.md` retention policy:
- The episode `renders/` directory contains **strictly only** the verified final 4K video: `NEMI_EP12_I_Got_So_Drunk_r5_4K_FINAL.mp4`.
- All superseded intermediate movies (`r1`, `r2`, `r3`, `r4`, `r5_1080p`, `proof_10s`, `proof_10s_r2`) have been removed.
- Capture logs, render stamps, and audio measurement reports are safely archived in [render_records/](render_records/).
- Full retention and file hash logs are tracked in [retention.json](retention.json).
