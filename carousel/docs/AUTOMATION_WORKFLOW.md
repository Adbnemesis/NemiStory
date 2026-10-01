# AUTOMATION WORKFLOW & CLI USER GUIDE

## 1. Creating a New Carousel

Execute the master orchestrator CLI from the project root:

```bash
python3 carousel/common/engine/carousel_generator.py \
  --brand nemi \
  --topic "animation burnout" \
  --tone "funny but wholesome" \
  --slides 7 \
  --instructions "focus on 6 hours for 12 views"
```

### What Happens Automatically:
1. **Brief Ingestion**: Writes `INPUT.md` containing the exact user parameters.
2. **Strategy Engine**: Generates narrative arc, per-slide archetypes, poses, props, and callbacks.
3. **Manifest & Strategy Docs**: Emits `manifest.json` and `CAROUSEL.md`.
4. **Rendering**: Executes Godot 4.7 SceneTree with Metal acceleration to produce `01.png`–`07.png`.
5. **Contact Sheet**: Generates `contact_sheet.png` for rapid sequential review.
6. **Audits**: Runs `validator.py` and `ai_dependency_audit.py`.
7. **Registry Update**: Updates `carousel/docs/CAROUSEL_REGISTRY.json`.
8. **Human Gate**: Sets status to `review`.

---

## 2. Regenerating / Revising an Existing Carousel

To create a revision without overwriting previous versions:

```bash
python3 carousel/common/engine/carousel_generator.py \
  --revise "carousel/output/nemi/nemi_6hrs_12views/v01" \
  --notes "make slide 1 hook shorter and change Nemi pose to panic"
```
This automatically branches into `v02/`, leaving `v01/` completely intact, and records the revision rationale in `CAROUSEL.md`.

---

## 3. Approval Workflow
Open `carousel/output/<brand>/<id>/<version>/contact_sheet.png`.
When visually approved, update `status: "approved"` in `manifest.json` and `CAROUSEL.md`.
