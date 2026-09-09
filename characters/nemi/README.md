# NEMI — Production Character Artwork & Rig

**Nemi** is the protagonist of the project, built **100% natively inside Godot 4.3+**.
She is constructed purely from Godot 2D vector geometry (`Curve2D`, `Polygon2D`, `draw_colored_polygon`), custom calligraphic inking (`InkStroke`), and a working `Skeleton2D` / `Bone2D` hierarchical rig.

> **Zero Raster Sprites or Image Textures**: No sprite sheet crops, no raster textures, no AI image artifacts. Every curve, cel fill, contour line, and facial feature is generated procedurally from mathematical vectors.

---

## 1. Character Art Direction & References

Nemi is designed to capture the expressive, hand-drawn YouTube storytime creator aesthetic:
- **Reference A (`references/main_character/nemi_sheet.png`)**: Copper red hair, emerald green anime bean eyes, oversized sage green cowl-neck hoodie, dark forest green pleated tennis skirt, white crew socks, chunky platform dad sneakers with emerald trim, and cross-body black messenger bag.
- **Reference B (`references/WHAT IS HAPPENING ON YOUTUBE___.mp4` & `references/Come Watch My First Video! ♡.mp4`)**: Dynamic conversational framing, warm cream background, storytime micro-accents (45° diagonal blush scratches, sweat drops, sparkles), and sharp calligraphic contour inking.

---

## 2. Anatomical Proportions & Canon

| Metric | Measurement / Formula | Aesthetic Purpose |
| :--- | :--- | :--- |
| **Total Height** | 5.2 Heads (~575px) | Youthful, approachable storytime creator silhouette |
| **Head Dimensions** | 94px width × 112px height | Gentle roundness with soft tapered chin (no needle jaw) |
| **Cheek Fullness** | 92px width at mid-cheek | Cute, youthful anime fullness |
| **Hair Silhouette** | 118px max width | Balanced framing that frames without overwhelming torso |
| **Eye Proportions** | 22px × 26px almond sclera | Big expressive emerald bean iris, dual non-mirrored speculars |
| **Waist / Skirt** | 62px waistband, 86px hem | Flared knife-pleated A-line silhouette with stepped pleat hem |
| **Footwear** | Platform dad sneakers | Chunky cream sole (`#ede9e1`), dark tread, emerald accent |

---

## 3. System Architecture

```
characters/nemi/
├── nemi.tscn                   # Master Godot scene with Skeleton2D hierarchy
├── nemi.gd                     # Master character controller and pose tweening
├── NemiGeometry.gd             # Mathematical curve definitions & polygon tessellations
├── NemiProportions.gd          # Canon anatomical dimension constants
├── NemiStyle.gd                # Master dual-palette manager (Color & Monochrome)
├── NemiPose.gd                 # Rig pose angle solver (idle, pointing, thinking, excited, recoiling, novel)
├── drawing/
│   ├── InkStroke.gd            # Variable-width calligraphic ribbon stroke generator
│   ├── IllustrationCanvas2D.gd # High-level drawing layer for cel fills & contours
│   └── NemiDoodles.gd          # Storytime micro-accents (sparkles, blush hatching, sweat drops)
├── parts/
│   ├── NemiHeadPart.gd         # Symmetrical head base & ears
│   ├── NemiFace.gd             # Eyes, lashes, pupils, nose, mouth shapes, blush
│   ├── NemiHairPart.gd         # Back mane, crown dome, bangs fringe, side tresses, ahoge
│   ├── NemiTorsoPart.gd        # Dropped-shoulder hoodie, cowl hood collar, drawstrings
│   ├── NemiSkirtPart.gd        # Pleated skirt with stepped hem & alternating shadow facets
│   ├── NemiLimbPart.gd         # Upper/lower sleeves, anime hands (relaxed, pointing, fist)
│   ├── NemiLegPart.gd          # Slender anime legs, white crew socks, platform dad sneakers
│   ├── NemiBagPart.gd          # Cross-body messenger bag with gold clasp
│   └── NemiNeckPart.gd         # Slender neck connection
└── renders/                    # 13 high-resolution showcase renders + 12-shot contact sheet
```

---

## 4. Calligraphic Inking System (`InkStroke.gd`)

Unlike uniform `draw_polyline()` lines that look like wireframes, all outlines use `InkStroke`, which generates smooth 2D polygonal ribbons with varying pen pressure profiles:
- **`CALLIGRAPHIC_LASH`**: Heavy upper weight tapering sharply into delicate cat-eye outer wing flicks.
- **`TAPER_BOTH`**: Thick center with delicate tapered terminals for open fabric contours.
- **`TAPER_START` / `TAPER_END`**: Directional brush strokes for hair locks and pleat creases.
- **`DELICATE_CREASE`**: Fine hairline creases for fabric folds and waistband seams.

---

## 5. Dual Palette Modes (`NemiStyle.gd`)

Switchable instantaneously at runtime via `nemi.set_art_mode(mode)`:
1. **Color Mode (`ArtMode.COLOR`)**:
   - Hair: Warm copper red (`#d64937`) with soft highlight halo (`#e86e58`)
   - Hoodie: Cozy sage green (`#76987f`) with deep forest crease shading (`#5a7b63`)
   - Skirt: Deep forest green (`#1d3d2c`) with shadow facets (`#142b1f`)
   - Eyes: Vibrant emerald iris (`#1fa363`) with mint bounce light (`#5cd998`)
   - Outline Ink: Deep warm blackberry (`#38101e`)
2. **Finished Monochrome Mode (`ArtMode.MONOCHROME`)**:
   - Paper: Warm cream background (`#faf7f5`)
   - Inking: Rich deep blackberry ink (`#38101e`)
   - Fills: Paper cream with dark ink accents on skirt, bag, and pupils
   - Accents: 45° diagonal anime blush scratches (`///`)

---

## 6. Rendering & Visual Verification

To generate the complete 13-shot showcase and contact sheet:
```bash
/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot --rendering-driver metal -s tools/render_nemi_showcase.gd
```
Output is saved to `characters/nemi/renders/`:
- `00_nemi_showcase_overview.png`: 12-shot master contact sheet.
- `01` - `06`: Full-body, medium bust, and facial close-up in Color & Monochrome.
- `07` - `10`: Pointing, thinking, excited cheering, and comedic shock recoil poses.
- `11` - `12`: Novel rig-generated pose (Color & Monochrome).
- `13`: Mathematical proportion debug overlay.
