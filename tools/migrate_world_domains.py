#!/usr/bin/env python3
"""
tools/migrate_world_domains.py
Executes domain restructuring for:
1. nemi/ (all Nemi animation universe assets, rigs, episodes, and world systems)
2. pokemon/ (self-contained Pokémon rigs, showcase, props, and docs)
3. common/ (shared audio/sfx, engine libraries, tooling)
"""

import os
import shutil
import re

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def ensure_dir(d):
    os.makedirs(d, exist_ok=True)

def safe_move(src, dst):
    if not os.path.exists(src):
        return
    print(f"Moving {os.path.relpath(src, BASE_DIR)} -> {os.path.relpath(dst, BASE_DIR)}")
    ensure_dir(os.path.dirname(dst))
    if os.path.isdir(src):
        if os.path.exists(dst):
            # merge directory contents
            for item in os.listdir(src):
                s_item = os.path.join(src, item)
                d_item = os.path.join(dst, item)
                if os.path.exists(d_item):
                    if os.path.isdir(d_item):
                        safe_move(s_item, d_item)
                    else:
                        os.remove(d_item)
                        shutil.move(s_item, d_item)
                else:
                    shutil.move(s_item, d_item)
            os.rmdir(src)
        else:
            shutil.move(src, dst)
    else:
        if os.path.exists(dst):
            os.remove(dst)
        shutil.move(src, dst)

def main():
    print("============================================================")
    print("  EXECUTING REPOSITORY DOMAIN RESTRUCTURING")
    print("============================================================")

    # 1. Setup target directory roots
    NEMI_DIR = os.path.join(BASE_DIR, "nemi")
    POKEMON_DIR = os.path.join(BASE_DIR, "pokemon")
    COMMON_DIR = os.path.join(BASE_DIR, "common")

    ensure_dir(NEMI_DIR)
    ensure_dir(POKEMON_DIR)
    ensure_dir(COMMON_DIR)

    # 2. Relocate COMMON components
    print("\n[Phase 1/4] Moving COMMON shared libraries & SFX...")
    safe_move(os.path.join(BASE_DIR, "audio", "sfx"), os.path.join(COMMON_DIR, "audio", "sfx"))
    safe_move(os.path.join(BASE_DIR, "engine"), os.path.join(COMMON_DIR, "engine"))

    # 3. Relocate NEMI components
    print("\n[Phase 2/4] Moving NEMI universe assets, characters, episodes...")
    # Characters (nemi, neeko, adb)
    old_chars = os.path.join(BASE_DIR, "characters")
    if os.path.exists(old_chars):
        for char_name in ["nemi", "neeko", "adb"]:
            src_char = os.path.join(old_chars, char_name)
            dst_char = os.path.join(NEMI_DIR, "characters", char_name)
            if os.path.exists(src_char):
                safe_move(src_char, dst_char)
        # Any remaining characters
        if os.path.exists(old_chars):
            for remaining in os.listdir(old_chars):
                safe_move(os.path.join(old_chars, remaining), os.path.join(NEMI_DIR, "characters", remaining))
            try:
                os.rmdir(old_chars)
            except Exception:
                pass

    safe_move(os.path.join(BASE_DIR, "episodes"), os.path.join(NEMI_DIR, "episodes"))
    safe_move(os.path.join(BASE_DIR, "world"), os.path.join(NEMI_DIR, "world"))
    safe_move(os.path.join(BASE_DIR, "animations"), os.path.join(NEMI_DIR, "animations"))
    safe_move(os.path.join(BASE_DIR, "audio", "nemi"), os.path.join(NEMI_DIR, "audio", "nemi"))
    safe_move(os.path.join(BASE_DIR, "scenes"), os.path.join(NEMI_DIR, "scenes"))
    safe_move(os.path.join(BASE_DIR, "assets"), os.path.join(NEMI_DIR, "assets"))

    # Nemi docs
    nemi_docs_dir = os.path.join(NEMI_DIR, "docs")
    ensure_dir(nemi_docs_dir)
    for f in os.listdir(BASE_DIR):
        if f.startswith("Nemi_") and (f.endswith(".md") or f.endswith(".yaml")):
            safe_move(os.path.join(BASE_DIR, f), os.path.join(nemi_docs_dir, f))

    # Clean up empty audio directory if left
    audio_dir = os.path.join(BASE_DIR, "audio")
    if os.path.exists(audio_dir) and not os.listdir(audio_dir):
        os.rmdir(audio_dir)

    # 4. Search and replace res:// paths across the codebase
    print("\n[Phase 3/4] Updating res:// resource paths across files...")
    REPLACEMENTS = [
        # Order matters! More specific first
        ("res://audio/sfx/", "res://common/audio/sfx/"),
        ("res://audio/nemi/", "res://nemi/audio/nemi/"),
        ("res://engine/", "res://common/engine/"),
        ("res://characters/nemi/", "res://nemi/characters/nemi/"),
        ("res://characters/neeko/", "res://nemi/characters/neeko/"),
        ("res://characters/adb/", "res://nemi/characters/adb/"),
        ("res://characters/", "res://nemi/characters/"),
        ("res://episodes/", "res://nemi/episodes/"),
        ("res://world/", "res://nemi/world/"),
        ("res://animations/", "res://nemi/animations/"),
        ("res://scenes/", "res://nemi/scenes/"),
        ("res://assets/", "res://nemi/assets/"),
    ]

    EXTENSIONS = [".gd", ".tscn", ".tres", ".import", ".json", ".md", ".yaml", ".yml"]
    modified_count = 0

    for root, dirs, files in os.walk(BASE_DIR):
        # Skip .git, .godot, .venv
        if any(part in root.split(os.sep) for part in [".git", ".godot", ".venv", "renders"]):
            continue

        for filename in files:
            ext = os.path.splitext(filename)[1].lower()
            if ext in EXTENSIONS or filename == "project.godot":
                file_path = os.path.join(root, filename)
                try:
                    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()

                    new_content = content
                    for old_p, new_p in REPLACEMENTS:
                        new_content = new_content.replace(old_p, new_p)

                    if new_content != content:
                        with open(file_path, "w", encoding="utf-8") as f:
                            f.write(new_content)
                        modified_count += 1
                except Exception as e:
                    print(f"  Warning: could not process {file_path}: {e}")

    print(f"  Updated paths in {modified_count} files.")

    # 5. Update project.godot main_scene if needed
    project_godot = os.path.join(BASE_DIR, "project.godot")
    if os.path.exists(project_godot):
        with open(project_godot, "r", encoding="utf-8") as f:
            pg_content = f.read()
        pg_content = pg_content.replace("res://scenes/demo/poc_demo.tscn", "res://nemi/scenes/demo/poc_demo.tscn")
        with open(project_godot, "w", encoding="utf-8") as f:
            f.write(pg_content)
        print("  Updated project.godot main scene reference.")

    print("\n============================================================")
    print("  DOMAIN RESTRUCTURING COMPLETED SUCCESSFULLY")
    print("============================================================")

if __name__ == "__main__":
    main()
