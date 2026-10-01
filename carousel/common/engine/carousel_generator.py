#!/usr/bin/env python3
"""
Master Carousel Production CLI
Connects the Content Strategy Engine, Godot Headless Vector Renderer,
Contact Sheet Generator, QA Validator, and Master Registry into a unified pipeline.
"""

import os
import sys
import json
import glob
import re
import argparse
import subprocess
from datetime import datetime, timezone

from content_strategy_engine import ContentStrategyEngine
from contact_sheet import generate_contact_sheet
from validator import validate_carousel_output
from registry_manager import update_registry
from ai_dependency_audit import run_audit

DEFAULT_GODOT_BIN = "/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot"

def parse_args():
    parser = argparse.ArgumentParser(description="Antigravity Automated Instagram Carousel Generator")
    parser.add_argument("--brand", type=str, choices=["nemi", "adb"], default="nemi", help="Target creator brand")
    parser.add_argument("--topic", type=str, required=True, help="Carousel topic, brief, or core creative struggle")
    parser.add_argument("--content-type", type=str, default="relatable", help="Content category: relatable, educational, story, motivational, bts")
    parser.add_argument("--tone", type=str, default=None, help="Tone: funny, wholesome, deadpan, sarcastic, vulnerable")
    parser.add_argument("--slides", type=int, default=None, help="Slide count: 5-8 (default 7 for Nemi, 6 for ADB)")
    parser.add_argument("--instructions", type=str, default="", help="Custom creative instructions or constraints")
    parser.add_argument("--custom-hook", type=str, default="", help="Override opening slide hook copy")
    parser.add_argument("--revise", type=str, default=None, help="Carousel ID to revise (creates v02, v03, preserving history)")
    parser.add_argument("--seed", type=int, default=42, help="RNG seed for deterministic layout choices")
    parser.add_argument("--skip-render", action="store_true", help="Skip Godot rendering (manifest/docs generation only)")
    parser.add_argument("--godot-bin", type=str, default=DEFAULT_GODOT_BIN, help="Path to Godot executable")
    return parser.parse_args()

def determine_version(brand: str, carousel_id: str, is_revision: bool, base_output_dir: str) -> (str, str):
    carousel_dir = os.path.join(base_output_dir, brand, carousel_id)
    os.makedirs(carousel_dir, exist_ok=True)
    
    existing_versions = glob.glob(os.path.join(carousel_dir, "v[0-9][0-9]"))
    if not existing_versions or not is_revision:
        if not is_revision and os.path.exists(os.path.join(carousel_dir, "v01")):
            # If creating a fresh run with same name, increment version safely to avoid destroying past work
            max_v = 1
            for v_path in existing_versions:
                m = re.search(r'v(\d+)$', v_path)
                if m:
                    max_v = max(max_v, int(m.group(1)))
            new_v = f"v{max_v + 1:02d}"
            target_dir = os.path.join(carousel_dir, new_v)
            os.makedirs(target_dir, exist_ok=True)
            return new_v, target_dir
        else:
            target_dir = os.path.join(carousel_dir, "v01")
            os.makedirs(target_dir, exist_ok=True)
            return "v01", target_dir
            
    # Revision requested: find highest vXX and increment
    max_v = 1
    for v_path in existing_versions:
        m = re.search(r'v(\d+)$', v_path)
        if m:
            max_v = max(max_v, int(m.group(1)))
            
    next_v = f"v{max_v + 1:02d}"
    target_dir = os.path.join(carousel_dir, next_v)
    os.makedirs(target_dir, exist_ok=True)
    return next_v, target_dir

def main():
    args = parse_args()
    
    # 0. Setup Paths & Defaults
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "../../.."))
    base_output_dir = os.path.join(project_root, "carousel/output")
    registry_file = os.path.join(project_root, "carousel/docs/CAROUSEL_REGISTRY.json")
    
    brand = args.brand.lower()
    default_tone = "funny" if brand == "nemi" else "deadpan"
    tone = args.tone if args.tone else default_tone
    
    default_slides = 7 if brand == "nemi" else 6
    slides_count = args.slides if args.slides else default_slides
    
    print("\n" + "="*65)
    print(f"🚀 ANTIGRAVITY CAROUSEL PRODUCTION ENGINE")
    print(f"   Brand: {brand.upper()} | Topic: '{args.topic}'")
    print(f"   Slides: {slides_count} | Tone: {tone} | Content Type: {args.content_type}")
    print("="*65 + "\n")
    
    # 1. Initialize Content Strategy Engine
    engine = ContentStrategyEngine(project_root)
    
    # Determine Carousel ID
    if args.revise:
        carousel_id = args.revise
        is_revision = True
    else:
        carousel_id = f"{brand}_{engine._slugify(args.topic)}"
        is_revision = False
        
    version, version_dir = determine_version(brand, carousel_id, is_revision, base_output_dir)
    print(f"📁 Target Output Directory: {version_dir} ({version})")
    
    # 2. Plan Strategic Content, Hook, and Archetypes
    print("🧠 [Phase 1/5] Running 12-Stage Content Strategy Engine...")
    plan_result = engine.plan_carousel(
        brand=brand,
        topic=args.topic,
        content_type=args.content_type,
        tone=tone,
        slide_count=slides_count,
        instructions=args.instructions,
        custom_hook=args.custom_hook,
        seed=args.seed
    )
    
    manifest = plan_result["manifest"]
    manifest["version"] = version
    manifest["carousel_id"] = carousel_id
    input_brief = plan_result["input_brief"]
    
    # 3. Preserve Brief and Documentation
    print("📝 [Phase 2/5] Preserving INPUT.md and generating CAROUSEL.md...")
    input_md_path = os.path.join(version_dir, "INPUT.md")
    with open(input_md_path, "w", encoding="utf-8") as f:
        f.write(engine.generate_input_markdown(input_brief))
        
    carousel_md_path = os.path.join(version_dir, "CAROUSEL.md")
    with open(carousel_md_path, "w", encoding="utf-8") as f:
        f.write(engine.generate_carousel_markdown(manifest))
        
    manifest_path = os.path.join(version_dir, "manifest.json")
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)
        
    print(f"   ✓ Wrote: {input_md_path}")
    print(f"   ✓ Wrote: {carousel_md_path}")
    print(f"   ✓ Wrote: {manifest_path}")
    
    # 4. Headless Godot Vector Rendering
    if not args.skip_render:
        print("\n🎨 [Phase 3/5] Invoking Godot 4.7.2 Headless Metal Vector Renderer...")
        godot_bin = args.godot_bin
        if not os.path.exists(godot_bin):
            print(f"❌ Error: Godot binary not found at '{godot_bin}'!")
            sys.exit(1)
            
        render_cmd = [
            godot_bin,
            "--rendering-driver", "metal",
            "-s", "res://carousel/common/scripts/CarouselRenderRunner.gd",
            "--manifest", manifest_path
        ]
        
        try:
            res = subprocess.run(render_cmd, cwd=project_root, capture_output=True, text=True, check=True)
            print(res.stdout)
        except subprocess.CalledProcessError as e:
            print(f"❌ Godot Render Error:\n{e.stderr}\n{e.stdout}")
            sys.exit(1)
            
        # 5. Stitched Contact Sheet Generation
        print("🖼️  [Phase 4/5] Generating stitched contact sheet...")
        contact_sheet_path = generate_contact_sheet(version_dir, brand, manifest.get("hook", "Carousel Overview"))
        
        # 6. QA Validation & Mechanical Zero-AI Audit
        print("🔍 [Phase 5/5] Executing QA Boundary Audit & Mechanical Zero-AI Verification...")
        valid = validate_carousel_output(version_dir)
        if not valid:
            print("⚠️  Warning: Carousel output failed validation checks!")
            
        ai_clean = run_audit()
        if not ai_clean:
            print("❌ CRITICAL: AI Dependency Audit Failed!")
            sys.exit(1)
    else:
        print("⏩ Skipping Godot render and contact sheet as requested (--skip-render).")
        
    # 7. Update Master Registry
    update_registry(
        registry_file=registry_file,
        carousel_id=carousel_id,
        brand=brand,
        title=manifest.get("hook", args.topic),
        topic=args.topic,
        content_type=args.content_type,
        tone=tone,
        version=version,
        status="draft", # Human approval gate maintained
        output_path=os.path.relpath(version_dir, project_root)
    )
    
    print("\n" + "="*65)
    print("✨ CAROUSEL GENERATION COMPLETE & READY FOR REVIEW")
    print(f"   Carousel ID : {carousel_id}")
    print(f"   Version     : {version}")
    print(f"   Status      : draft (Review required)")
    print(f"   Directory   : file://{version_dir}")
    print(f"   Contact     : file://{os.path.join(version_dir, 'contact_sheet.png')}")
    print(f"   Document    : file://{carousel_md_path}")
    print("="*65 + "\n")

if __name__ == "__main__":
    main()
