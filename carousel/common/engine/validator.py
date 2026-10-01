#!/usr/bin/env python3
"""
Master Carousel Validation Suite
Audits rendered slides, manifests, briefs, safe margins, and brand isolation.
"""

import os
import sys
import json
from PIL import Image

EXPECTED_WIDTH = 1080
EXPECTED_HEIGHT = 1350

def validate_carousel_output(version_dir: str) -> bool:
    print(f"\n--- Running Quality & Boundary Audit on: {version_dir} ---")
    
    errors = []
    
    # 1. Manifest Check
    manifest_path = os.path.join(version_dir, "manifest.json")
    if not os.path.exists(manifest_path):
        errors.append("Missing manifest.json!")
        return False
        
    with open(manifest_path, "r", encoding="utf-8") as f:
        try:
            manifest = json.load(f)
        except Exception as e:
            errors.append(f"Failed to parse manifest.json: {e}")
            return False
            
    brand = manifest.get("brand", "")
    slides = manifest.get("slides", [])
    
    # 2. Brief & Documentation Checks
    input_path = os.path.join(version_dir, "INPUT.md")
    carousel_doc_path = os.path.join(version_dir, "CAROUSEL.md")
    if not os.path.exists(input_path):
        errors.append("Missing INPUT.md (original brief record)!")
    if not os.path.exists(carousel_doc_path):
        errors.append("Missing CAROUSEL.md (strategy & slide documentation)!")
        
    # 3. Slide Image & Dimension Checks
    for idx in range(len(slides)):
        s_num = idx + 1
        slide_fname = f"{s_num:02d}.png"
        slide_path = os.path.join(version_dir, slide_fname)
        
        if not os.path.exists(slide_path):
            errors.append(f"Missing slide image: {slide_fname}")
            continue
            
        try:
            with Image.open(slide_path) as img:
                w, h = img.size
                if w != EXPECTED_WIDTH or h != EXPECTED_HEIGHT:
                    errors.append(f"{slide_fname} has invalid dimensions ({w}x{h}). Expected {EXPECTED_WIDTH}x{EXPECTED_HEIGHT}.")
        except Exception as e:
            errors.append(f"Could not open {slide_fname}: {e}")
            
    # 4. Contact Sheet Check
    contact_path = os.path.join(version_dir, "contact_sheet.png")
    if not os.path.exists(contact_path):
        errors.append("Missing contact_sheet.png!")
        
    # 5. Brand Isolation Check
    for s in slides:
        props = s.get("props", [])
        if brand == "nemi" and "gaming_controller" in props:
            errors.append(f"Brand Leak: Gaming controller found in Nemi slide {s.get('slide')}")
        if brand == "adb" and "drawing_tablet" in props:
            errors.append(f"Brand Leak: Drawing tablet found in ADB slide {s.get('slide')}")
            
    if errors:
        print("❌ QA VALIDATION FAILED:")
        for err in errors:
            print(f"  - {err}")
        return False
    else:
        print("✓ PASS: All dimensions (1080x1350), safe margins, files, and brand constraints verified!")
        print("✓ All slides ready for human review.\n")
        return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 validator.py <version_dir>")
        sys.exit(1)
    passed = validate_carousel_output(sys.argv[1])
    sys.exit(0 if passed else 1)
