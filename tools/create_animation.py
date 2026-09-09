#!/usr/bin/env python3
"""
Nemi Story Animation Scaffolder
Creates a dedicated production directory for a new animation/episode.
"""

import sys
import os
import shutil
import argparse
import re

def create_animation(animation_id: str, title: str):
    # Validate id
    if not re.match(r'^[a-z0-9_]+$', animation_id):
        print(f"Error: animation_id '{animation_id}' must only contain lowercase letters, numbers, and underscores.")
        sys.exit(1)

    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    animations_dir = os.path.join(project_root, "animations")
    template_dir = os.path.join(animations_dir, "_template")
    target_dir = os.path.join(animations_dir, animation_id)

    if not os.path.exists(template_dir):
        print(f"Error: Template directory '{template_dir}' not found.")
        sys.exit(1)

    if os.path.exists(target_dir):
        print(f"Error: Target animation directory '{target_dir}' already exists.")
        sys.exit(1)

    print(f"Scaffolding new animation '{animation_id}' ({title})...")
    shutil.copytree(template_dir, target_dir)

    # File renames
    old_scene = os.path.join(target_dir, "template_scene.tscn")
    new_scene = os.path.join(target_dir, f"{animation_id}_scene.tscn")
    old_director = os.path.join(target_dir, "template_director.gd")
    new_director = os.path.join(target_dir, f"{animation_id}_director.gd")
    old_render = os.path.join(target_dir, "render_template.gd")
    new_render = os.path.join(target_dir, f"render_{animation_id}.gd")

    if os.path.exists(old_scene):
        os.rename(old_scene, new_scene)
    if os.path.exists(old_director):
        os.rename(old_director, new_director)
    if os.path.exists(old_render):
        os.rename(old_render, new_render)

    # Replace placeholders across files
    director_class_name = "".join([part.capitalize() for part in animation_id.split("_")]) + "Director"
    replacements = {
        "[ANIMATION_ID]": animation_id,
        "[ANIMATION_TITLE]": title,
        "template_episode": animation_id,
        "template_director.gd": f"{animation_id}_director.gd",
        "template_scene.tscn": f"{animation_id}_scene.tscn",
        "AnimationDirectorTemplate": director_class_name
    }

    for root_path, _, file_names in os.walk(target_dir):
        for fn in file_names:
            fp = os.path.join(root_path, fn)
            try:
                with open(fp, "r", encoding="utf-8") as f:
                    content = f.read()
                modified = False
                for k, v in replacements.items():
                    if k in content:
                        content = content.replace(k, v)
                        modified = True
                if modified:
                    with open(fp, "w", encoding="utf-8") as f:
                        f.write(content)
            except Exception:
                pass

    print(f"✓ Dedicated animation directory created at: animations/{animation_id}/")
    print(f"  ├── script/ ({animation_id} script and subtitles)")
    print(f"  ├── voiceover/ (voice track, sfx, music)")
    print(f"  ├── renders/ (mp4 output and thumbnail)")
    print(f"  ├── {animation_id}_scene.tscn (Godot 2D scene)")
    print(f"  ├── {animation_id}_director.gd (choreography timeline)")
    print(f"  └── render_{animation_id}.gd (CLI render runner)")

def main():
    parser = argparse.ArgumentParser(description="Create dedicated animation directory for Nemi")
    parser.add_argument("animation_id", help="Folder ID (e.g. ep01_gym_disaster)")
    parser.add_argument("--title", default="Untitled Animation", help="Human-readable title")
    args = parser.parse_args()

    create_animation(args.animation_id, args.title)

if __name__ == "__main__":
    main()
