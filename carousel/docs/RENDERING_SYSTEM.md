# RENDERING SYSTEM & GODOT METAL PIPELINE

## 1. Headless GPU-Accelerated Architecture
The carousel renderer runs headlessly via Godot 4.7.2 using Apple Silicon Metal 4.0 Forward+ rendering:

```bash
/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot \
  --rendering-driver metal \
  -s res://carousel/common/scripts/CarouselRenderRunner.gd \
  --manifest "res://carousel/output/nemi/nemi_6hrs_12views/v01/manifest.json"
```

---

## 2. Rendering Lifecycle
1. **Scene Initialization**: Instantiates `CarouselSlideStage.tscn` at `1080 × 1350` viewport resolution.
2. **Slide Staging**: Iterates over each slide entry in `manifest.json`:
   * Applies the background paper color and texture layer.
   * Renders the dynamic composition archetype (`edge_peek`, `split_stage`, `card_perch`, etc.).
   * Assembles typography with word-wrapped headlines and highlighter overlays.
   * Solves and places the character in the requested composition pose and facial expression.
   * Draws contextual vector props and decorative doodles.
3. **Frame Flush**: Awaits 6 visual engine frames (`await process_frame`) to ensure all polygon tessellations, font textures, and vector buffers are flushed to the GPU.
4. **Viewport Texture Capture**: Captures `root_viewport.get_texture().get_image()` and executes `save_png()`.
5. **Contact Sheet Stitching**: Calls Python Pillow module to assemble `contact_sheet.png`.
