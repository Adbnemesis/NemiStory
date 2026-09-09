# RENDERS & EXPORT SPECIFICATIONS
## Directory Guidelines

This folder contains final exported video renders and thumbnails:

* **`<animation_id>.mp4`**: Final production export.
  * Resolution: 1920×1080 (16:9 widescreen) or 1280×720.
  * Framerate: 30 fps (or 60 fps).
  * Video Codec: H.264 (libx264, profile high, crf 18–22).
  * Audio Codec: AAC (192 kbps, stereo).
* **`thumbnail.png`**: YouTube thumbnail (1280×720 or 1920×1080 PNG).
* **`raw/`**: Temporary directory for Movie Maker raw uncompressed captures (git-ignored).
