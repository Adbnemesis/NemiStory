# CAROUSEL SYSTEM BIBLE

## 1. System Overview & Purpose
The **NemiStory Automated Carousel Production System** is an independent, deterministic graphic storytelling engine built to generate high-retention, multi-slide Instagram carousels (1080×1350 px, 4:5 aspect ratio) for two distinct creator universes:
1. **NEMI**: Warm, expressive, hand-drawn, cute, relatable animator/creator humor.
2. **ADB**: Cool, relaxed, dry-witted, deadpan, anime/gaming adjacent creator perspective.

The system turns an idea or topic brief into a fully staged, rendered, and documented multi-slide carousel.

---

## 2. Absolute Architectural Constraints

### A. Zero AI Image Generation Rule
> **NO AI IMAGE GENERATION IS USED ANYWHERE IN THE CAROUSEL PIPELINE.**
>
> The system must never call, invoke, download from, or rely upon any generative image model (diffusion models, AI image APIs, Midjourney, DALL-E, Stability, or image-to-image pipelines).
>
> Every visual asset—character anatomy, clothing, hair, facial features, props, doodles, speech bubbles, backgrounds, textures, and typography—is **100% constructed natively** using mathematical vector operations inside Godot Engine (`_draw()`, `draw_polygon()`, `draw_polyline()`, `draw_colored_polygon()`, `draw_arc()`, `Line2D`, `Polygon2D`, `CanvasItem`, and bundled TTF fonts).

### B. Absolute Episode System Isolation (Zero-Touch Rule)
> Existing storytime episode production systems in `nemi/episodes/`, `adb/episodes/`, `nemi/characters/`, and `adb/characters/` are **strictly read-only references**.
>
> The carousel system does **NOT** instantiate or depend on episode rigs at runtime. It maintains independent canonical character vector scenes inside `carousel/nemi/character/` and `carousel/adb/character/`. Deleting `carousel/` leaves the episode systems intact; deleting episodes leaves `carousel/` 100% operational.

### C. Mechanical Audit Verification
The system includes `carousel/common/engine/ai_dependency_audit.py`, which mechanically inspects dependencies, code imports, and network endpoints to ensure zero AI image generation tooling is present. Any violation halts the build immediately.

---

## 3. Architecture & Pipeline

```
ORIGINAL BRIEF (INPUT.md)
       │
       ▼
CONTENT STRATEGY ENGINE (Python 3.11)
  ├── 12-Stage Planning Pipeline
  ├── Hook Formulation & Curiosity Loops
  ├── Pacing & Micro-Escalations
  ├── Dynamic Per-Slide Archetype Selection
  └── Output: manifest.json + draft CAROUSEL.md
       │
       ▼
NATIVE VECTOR STAGE & RENDERER (Godot 4.7.2 Forward+ Metal)
  ├── CarouselSlideStage (1080x1350 Canvas, Paper Grain, Safe Margins)
  ├── Native Canonical Characters (Nemi / ADB Vector Assemblies)
  ├── Composition Poses (Peeking, Perching, Leaning, Closeup)
  ├── Procedural Vector Props & Doodles
  └── Typography Engine (PatrickHand, Caveat, GochiHand, Highlighter)
       │
       ▼
EXPORT & VALIDATION
  ├── 01.png ... 07.png (Native PNG Slides)
  ├── contact_sheet.png (Review Grid)
  ├── validator.py (Automated Bounds, Margin, Readability QA)
  ├── CAROUSEL_REGISTRY.json (Global Catalog Updated)
  └── Human Approval Gate (Status: 'draft' / 'review')
```

---

## 4. Directory Structure Conventions

* `carousel/config.json`: Master configuration (dimensions, safe zones, font paths).
* `carousel/docs/`: Master documentation, bibles, changelogs, registry.
* `carousel/common/engine/`: Python orchestrators, strategy engines, auditors, QA validators.
* `carousel/common/archetypes/`: JSON schemas for the 6 dynamic layout archetypes.
* `carousel/common/scripts/`: Shared Godot rendering scripts and canvas stage.
* `carousel/nemi/`: Nemi brand specification, vector character scene, props, doodles, catalogs.
* `carousel/adb/`: ADB brand specification, vector character scene, props, doodles, catalogs.
* `carousel/output/<brand>/<carousel_id>/<version>/`: All generated outputs (`INPUT.md`, `CAROUSEL.md`, `manifest.json`, `contact_sheet.png`, `01.png`, etc.).

---

## 5. Composition Archetypes

Individual slides dynamically select an archetype based on their storytelling role:
1. `edge_peek`: Character peeks from bottom or side edge, looking toward hook text.
2. `split_stage`: Two-column layout with text on one side and full-posture character on the other.
3. `card_perch`: Character physically sits on or leans against a bordered text card.
4. `hero_closeup`: Dramatic bust or facial close-up for comedic climax, panic, shock, or deadpan freeze.
5. `quote_card`: High-contrast, minimalist bookmarkable takeaway card with grounded character accent.
6. `sign_cta`: Character holding up an illustrated card, prompt board, or pointing directly at comments.

---

## 6. How to Create a New Carousel

From the repository root:
```bash
python3 carousel/common/engine/carousel_generator.py \
  --brand nemi \
  --topic "animation burnout" \
  --tone "funny but wholesome" \
  --slides 7 \
  --instructions "focus on 6 hours for 12 views"
```
The command will:
1. Preserve the user brief in `INPUT.md`.
2. Generate the 12-stage content strategy and narrative arc.
3. Formulate `manifest.json` and `CAROUSEL.md`.
4. Invoke Godot headlessly via Metal to render 1080×1350 PNG slides.
5. Stitch `contact_sheet.png`.
6. Run `validator.py` and `ai_dependency_audit.py`.
7. Update `carousel/docs/CAROUSEL_REGISTRY.json`.
8. Output all artifacts in `carousel/output/<brand>/<id>/v01/`.

---

## 7. Versioning & Human Approval Gate

* Re-running or revising an existing carousel creates `v02/`, `v03/` under the carousel directory. Old approved work is **never overwritten**.
* Status begins at `draft` or `review`. Automated pipelines never auto-approve output. A human must inspect `contact_sheet.png` and update status to `approved` in `manifest.json` and `CAROUSEL.md`.

---

## 8. Troubleshooting & Safe Operations

* **Texture Error in Headless Mode**: If Godot is run in headless mode without a rendering driver, dummy rendering cannot capture viewport textures. Always invoke Godot with `--rendering-driver metal` (macOS Apple Silicon) as defined in `carousel/config.json`.
* **Safe Zone Violations**: If `validator.py` reports text outside bounds, adjust headline length or reduce font size.
* **Prohibited Files**: Never edit files in `nemi/episodes/`, `adb/episodes/`, or `tools/render_ep*.py`. All carousel logic must stay confined within `carousel/`.
