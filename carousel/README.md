# Antigravity Automated Instagram Carousel Production System

A fully automated, high-retention Instagram Carousel production engine for two creator brands:
1. **NEMI** (warm, expressive, hand-drawn paper aesthetic, relatable animator struggles, cute/chaotic energy)
2. **ADB** (cool, relaxed, dry-witted, deadpan observation, gaming/tech adjacent, clean editorial lines)

---

## 🔒 Core Architectural Principles

1. **Absolute Zero AI Image Generation**:
   - Zero generative models, diffusion networks, external image APIs, or generative image services are used anywhere in this pipeline.
   - All character artwork, poses, expressions, props, doodles, and backgrounds are rendered as **100% native Godot vector geometry** using `_draw()`, `Line2D`, `Polygon2D`, math curves, and bundled fonts.
   - Verified mechanically via `carousel/common/engine/ai_dependency_audit.py`.

2. **Absolute Episode System Isolation**:
   - The carousel engine is strictly decoupled from the runtime episode rigs (`nemi/episodes/`, `adb/episodes/`).
   - Episode folders are treated as strictly read-only references.
   - Character scenes (`carousel/nemi/character/` and `carousel/adb/character/`) are completely self-contained and independently maintained.

3. **Faithful Canonical Character Art**:
   - Characters faithfully reconstruct the canonical model sheets (`references/main_character/nemi_sheet.png` and `references/adb_model_sheet.jpg`).
   - Nemi's oversized rust-orange knit sweater, charcoal hair with teal tint, soft facial features, and warm blush are exact.
   - ADB's teal hoodie with orange cord accents, dark hair silhouette, relaxed eyes, and cool posture are exact.

4. **12-Stage Strategic Content Engine**:
   - Slides are not static text blocks. The engine algorithmically plans:
     `Idea ➔ Audience/Angle ➔ Hook ➔ Narrative Arc ➔ Slide Purposes ➔ Visual Treatment ➔ Dynamic Archetypes ➔ Poses & Expressions ➔ Props & Callbacks ➔ Typography ➔ Godot Render ➔ QA`.

5. **Dynamic Per-Slide Composition Archetypes**:
   - The system never locks a carousel into a single repetitive template. Slides choose from 6 dynamic archetypes:
     - `edge_peek`: Character peeks dramatically from screen margins to spotlight the hook headline.
     - `split_stage`: Classical editorial layout with character occupying one flank and copy on the other.
     - `card_perch`: Character sits or lounges on top of a framed content card.
     - `hero_closeup`: Large character close-up for emotional peaks, shocks, and comedic climaxes.
     - `quote_card`: High-contrast framed card for bookmarkable takeaways and golden rules.
     - `sign_cta`: Character holds up an interactive whiteboard or terminal prompting audience comments.

6. **Complete Traceability & Non-Destructive Versioning**:
   - Every generated carousel version preserves:
     - `INPUT.md`: The original brief, seed, and instructions.
     - `CAROUSEL.md`: Strategy rationale, audience breakdown, and slide-by-slide copy.
     - `manifest.json`: Full machine-readable render specification.
     - `contact_sheet.png`: Auto-stitched overview sheet.
     - `01.png` – `07.png`: Native 1080 × 1350 px (Instagram 4:5 Portrait) slides.
   - Revisions (`--revise <carousel_id>`) create `v02`, `v03` without deleting or overwriting past versions.
   - Master registry: `carousel/docs/CAROUSEL_REGISTRY.json` tracks all carousels, status, and paths.
   - Status defaults to `draft` (Human Approval Gate).

---

## ⚡ Quickstart CLI Guide

All commands run through the Python virtual environment:

### 1. Generate a NEMI Carousel
```bash
./.venv/bin/python3 carousel/common/engine/carousel_generator.py \
  --brand nemi \
  --topic "when your animation takes 6 hours and gets 12 views" \
  --tone funny \
  --content-type relatable \
  --slides 7
```

### 2. Generate an ADB Carousel
```bash
./.venv/bin/python3 carousel/common/engine/carousel_generator.py \
  --brand adb \
  --topic "opening a game instead of finishing work" \
  --tone deadpan \
  --content-type relatable \
  --slides 6
```

### 3. Revise an Existing Carousel (Non-Destructive)
```bash
./.venv/bin/python3 carousel/common/engine/carousel_generator.py \
  --brand nemi \
  --topic "when your animation takes 6 hours and gets 12 views" \
  --revise nemi_when_your_animation_takes_6_hour \
  --instructions "Emphasize coffee cooling down on desk" \
  --slides 7
```
*(Creates `v02/` preserving `v01/` intact, and updates `CAROUSEL_REGISTRY.json`)*.

### 4. Run the Mechanical Zero-AI Audit
```bash
./.venv/bin/python3 carousel/common/engine/ai_dependency_audit.py
```

### 5. Validate Any Output Directory
```bash
./.venv/bin/python3 carousel/common/engine/validator.py carousel/output/nemi/nemi_when_your_animation_takes_6_hour/v01
```

---

## 📂 System Directory Structure

```text
carousel/
├── config.json                     # Canvas resolution (1080x1350), safe margins, fonts, drivers
├── README.md                       # Master system guide & CLI reference
├── docs/
│   ├── CAROUSEL_REGISTRY.json      # Master registry of all generated carousels & versions
│   ├── CAROUSEL_SYSTEM_BIBLE.md    # Master architecture blueprint
│   ├── CONTENT_STRATEGY.md         # 12-stage strategy, retention triggers, hook formulas
│   ├── STORYTELLING_RULES.md       # Narrative arcs, tension pacing, swipe incentives
│   ├── VISUAL_DESIGN_SYSTEM.md     # Typography scales, color palettes, safe margins
│   ├── ART_PROVENANCE.md           # Mechanical non-AI guarantee & asset verification
│   ├── RENDERING_SYSTEM.gd.md      # Headless Metal 4.0 rendering workflow
│   ├── AUTOMATION_WORKFLOW.md      # CLI execution, parameter schemas, batch rendering
│   ├── QA_RULES.md                 # Boundary audits, margin checks, contrast verification
│   ├── BRAND_SEPARATION.md         # Isolation rules preventing cross-brand asset bleed
│   ├── CHANGELOG.md                # System revisions & version history
│   ├── nemi/                       # NEMI Brand Bible & sub-specifications
│   └── adb/                        # ADB Brand Bible & sub-specifications
├── nemi/
│   ├── brand_spec.json             # Nemi color tokens, fonts, voice rules
│   ├── character/                  # Nemi native vector character & catalogs
│   ├── props/                      # Nemi procedural props (drawing tablet, coffee, sketchbook)
│   └── doodles/                    # Nemi procedural doodles (stars, hearts, cat paws)
├── adb/
│   ├── brand_spec.json             # ADB color tokens, fonts, voice rules
│   ├── character/                  # ADB native vector character & catalogs
│   ├── props/                      # ADB procedural props (gamepad, keyboard, smartphone)
│   └── doodles/                    # ADB procedural accents (pixel stars, terminal brackets)
├── common/
│   ├── archetypes/                 # 6 Composition Archetypes (edge_peek, split_stage, etc.)
│   ├── engine/                     # Python CLI, strategy engine, audits, validators
│   └── scripts/                    # GDScript compositors, render runners, typography
├── scenes/
│   └── CarouselSlideStage.tscn     # Master 1080x1350 slide compositor scene
└── output/
    ├── nemi/                       # Rendered Nemi carousels (v01, v02...)
    └── adb/                        # Rendered ADB carousels (v01, v02...)
```

---

## 🎨 Specifications & Dimensions
- **Slide Resolution**: `1080 × 1350` px (4:5 Aspect Ratio).
- **Safe Zones**:
  - Top: `100 px` (Instagram UI header overlay safe).
  - Bottom: `120 px` (Instagram UI action buttons & caption safe).
  - Left & Right: `80 px` (Touch swiping margins).
- **Color Palettes**:
  - **Nemi**: Cream paper (`#FAF7F5`), Deep Eggplant ink (`#38101E`), Rust sweater (`#C25B3A`), Apricot blush (`#F8B4A0`), Mint highlight (`#A8E6CF`).
  - **ADB**: Bone paper (`#FAF6EE`), Espresso ink (`#2B2623`), Teal hoodie (`#28424B`), Steel Slate (`#4A5770`), Ember accent (`#E07A5F`).
- **Typography**:
  - Headlines: `PatrickHand-Regular.ttf` (Hand-lettered editorial presence).
  - Annotations: `Caveat-Bold.ttf` (Quick author notes, aside comments).
  - Doodles: `GochiHand-Regular.ttf` (Casual background annotations).
