# Current EP08 masters

- `EP08_Forced_BF_Channel_Refined_1080p.mp4`: approved scale/staging revision, 1920×1080, 30 FPS, 95.4 seconds.
- `EP08_Forced_BF_Channel_Refined_4K.mp4`: same approved cut, native vector render at 3840×2160, 30 FPS, 95.4 seconds.
- `EP08_Forced_BF_Channel_1080p.mp4`: preserved earlier episode export; not the current refined cut.

Voice and script are unchanged. Large media stays local. Reproduce 4K with `python3 nemi/episodes/ep08_forced_bf_channel/tools/render_ep08_master.py --resolution 4k --output nemi/episodes/ep08_forced_bf_channel/renders/<new_name>.mp4`. The renderer uses a private project configuration for 4K and does not change shared `project.godot`.
