# QUALITY ASSURANCE & VALIDATION RULES

Every carousel must pass all 6 automated validation gates in `validator.py`:

## 1. Resolution & Format Gate
* Resolution: Exactly `1080 × 1350` px.
* Format: Lossless PNG, 8-bit RGBA.
* Aspect Ratio: Exactly 4:5.

## 2. Safe Margins Gate
* Top Safe Margin: 100px. Headline text bounding box `top >= 100`.
* Bottom Safe Margin: 120px. Body & CTA text bounding box `bottom <= 1230`.
* Side Margins: 80px. Text bounding box `left >= 80` and `right <= 1000`.

## 3. Text Collision & Clipping Gate
* Primary headlines and body copy must not overlap character faces or primary torso silhouettes.
* Text wrapping must not exceed canvas bounds or overflow below the safe margin.

## 4. Brand Isolation Gate
* Zero Nemi-specific colors (`#76987f`, `#d64937`, `#38101e`) in ADB carousels.
* Zero ADB-specific colors (`#e8dfd5`, `#1e222d`, `#2b2623`) in Nemi carousels.
* Brand-specific props must not cross boundaries (no drawing tablet in ADB; no gaming controller in Nemi).

## 5. Completeness Gate
* Every slide entry in `manifest.json` must produce an existing `XX.png` file.
* `contact_sheet.png`, `manifest.json`, `INPUT.md`, and `CAROUSEL.md` must all exist in the version directory.

## 6. Mechanical Zero-AI Gate
* `ai_dependency_audit.py` must return exit code `0` (PASS).
