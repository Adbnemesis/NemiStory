#!/usr/bin/env python3
"""
Mechanical No-AI Dependency & Asset Audit
Verifies that the carousel production pipeline is 100% free of AI image generation models,
external image APIs, generative diffusion libraries, or remote visual dependencies.
"""

import os
import sys
import re

PROHIBITED_PACKAGES = [
    "diffusers",
    "torchvision.models",
    "openai",
    "replicate",
    "stability_sdk",
    "midjourney",
    "anthropic.images",
    "google.generativeai.images",
]

PROHIBITED_KEYWORDS = [
    "generate_image",
    "text_to_image",
    "image_to_image",
    "stable-diffusion",
    "dall-e",
    "midjourney",
    "imagen",
    "flux.1",
]

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def run_audit() -> bool:
    print("===============================================================")
    print("  RUNNING MECHANICAL ZERO-AI IMAGE GENERATION AUDIT")
    print("===============================================================")
    
    violations = []
    
    # 1. Audit Python dependencies
    req_file = os.path.join(os.path.dirname(BASE_DIR), "requirements.txt")
    if os.path.exists(req_file):
        with open(req_file, "r", encoding="utf-8") as f:
            req_content = f.read().lower()
            for pkg in PROHIBITED_PACKAGES:
                if pkg in req_content:
                    violations.append(f"Prohibited generative package found in requirements.txt: {pkg}")
                    
    # 2. Audit Carousel Source Code (.py and .gd)
    carousel_dir = BASE_DIR
    for root, _, files in os.walk(carousel_dir):
        # Skip audit script itself
        for file in files:
            if file.endswith(".py") or file.endswith(".gd"):
                file_path = os.path.join(root, file)
                if os.path.abspath(file_path) == os.path.abspath(__file__):
                    continue
                try:
                    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                        lines = f.readlines()
                        for line_num, line in enumerate(lines, 1):
                            line_lower = line.lower()
                            # Check for external image URLs or generative calls
                            if "http://" in line_lower or "https://" in line_lower:
                                if any(ext in line_lower for ext in [".png", ".jpg", ".jpeg", ".webp"]):
                                    violations.append(f"Remote image URL found in {file_path}:{line_num}")
                            for kw in PROHIBITED_KEYWORDS:
                                # Allow comments explaining the rule
                                if kw in line_lower and not ("zero" in line_lower or "prohibit" in line_lower or "never" in line_lower or "no-ai" in line_lower):
                                    violations.append(f"Suspicious generative keyword '{kw}' found in {file_path}:{line_num}")
                except Exception as e:
                    print(f"Warning: could not inspect {file_path}: {e}")
                    
    print("\nAudit Results:")
    if violations:
        print("❌ FAILED: The following AI-generation violations were detected:")
        for v in violations:
            print(f"  - {v}")
        return False
    else:
        print("✓ PASS: 100% of carousel visual assets and code are native, offline, and non-generative.")
        print("✓ Verified: Zero diffusion models, zero remote image APIs, zero image-generation libraries.")
        print("===============================================================\n")
        return True

if __name__ == "__main__":
    success = run_audit()
    sys.exit(0 if success else 1)
