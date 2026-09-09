# ANIMATION TEMPLATE BLUEPRINT
## Reusable Starter Package for New Nemi Storytelling Episodes

This folder serves as the blueprint for creating any new animation. When creating a new episode, copy this entire directory to `animations/<episode_id>/` or run:

```bash
python3 tools/create_animation.py <episode_id> --title "Your Title"
```

---

## Directory Inventory

* **`script/script.md`**: Template script structure with beats, dialogue, acting cues, and subtitle markers.
* **`script/subtitles.json`**: Structured subtitle format with timing and emphasis metadata.
* **`voiceover/`**: Folder for `voiceover.wav`, background music (`music/`), and sound effects (`sfx/`).
* **`renders/`**: Folder where the final `.mp4` video and thumbnail are exported.
* **`template_scene.tscn`**: Ready-to-use Godot 2D scene with Nemi, camera, background, props, doodles, and subtitle canvas.
* **`template_director.gd`**: Choreography director template with standard storytelling beat methods.
* **`render_template.gd`**: Standalone SceneTree script for headless rendering.
