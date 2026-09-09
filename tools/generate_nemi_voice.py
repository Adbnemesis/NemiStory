#!/usr/bin/env python3
"""
Nemi Voiceover Generation CLI
Generates individual dialogue WAV segments, master track, and precise timing manifests
using local Kokoro TTS pipeline.
"""

import os
import sys
import argparse
import json
import shutil

# Ensure workspace root is on sys.path
WORKSPACE_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if WORKSPACE_ROOT not in sys.path:
    sys.path.insert(0, WORKSPACE_ROOT)

from tools.tts.config import NemiTTSConfig
from tools.tts.engine import KokoroTTSEngine
from tools.tts.segmenter import ScriptSegmenter
from tools.tts.concatenator import AudioConcatenator

def generate_voiceover(
    script_path: str,
    output_base_dir: str,
    voice: str = "af_heart",
    project_id: str = "ep00_introduction",
    title: str = "Wait, Listen to Me",
    animation_voiceover_dir: str = None
):
    print("============================================================")
    print(f"NEMI VOICEOVER GENERATION: [{project_id}]")
    print(f"Source Script: {script_path}")
    print(f"Voice Candidate: {voice}")
    print(f"Output Directory: {output_base_dir}")
    print("============================================================")
    
    # 1. Parse script segments
    if not os.path.exists(script_path):
        raise FileNotFoundError(f"Script file not found: {script_path}")
        
    segments = ScriptSegmenter.parse_intro_script(script_path)
    print(f"✓ Parsed {len(segments)} spoken dialogue segments from script.")
    
    # 2. Setup directory hierarchy
    segments_dir = os.path.join(output_base_dir, "segments")
    master_dir = os.path.join(output_base_dir, "master")
    timing_dir = os.path.join(output_base_dir, "timing")
    metadata_dir = os.path.join(output_base_dir, "metadata")
    source_dir = os.path.join(output_base_dir, "source")
    
    for d in [segments_dir, master_dir, timing_dir, metadata_dir, source_dir]:
        os.makedirs(d, exist_ok=True)
        
    # Copy source script reference
    shutil.copyfile(script_path, os.path.join(source_dir, os.path.basename(script_path)))
    
    # 3. Initialize Kokoro Engine
    config = NemiTTSConfig(voice=voice)
    engine = KokoroTTSEngine(config)
    
    # 4. Generate individual segment WAV files
    print("\nSynthesizing individual dialogue segments...")
    for seg in segments:
        seg_out_path = os.path.join(segments_dir, seg.file_name)
        duration = engine.synthesize_to_file(
            text=seg.tts_text,
            output_path=seg_out_path,
            voice=voice,
            speed=seg.speed
        )
        seg.duration = duration
        print(f"  [{seg.id}] Beat {seg.beat} ({duration:.2f}s, pause={seg.pause_after:.2f}s): \"{seg.text[:45]}...\"")
        
    print(f"\n✓ Generated {len(segments)} segment audio files.")
    
    # 5. Assemble Master Audio & Timing Manifests
    master_file = f"nemi_intro_voice_master.wav"
    master_out_path = os.path.join(master_dir, master_file)
    timing_json_path = os.path.join(timing_dir, "nemi_intro_timing.json")
    timing_md_path = os.path.join(timing_dir, "Nemi_Intro_Voice_Timing.md")
    metadata_json_path = os.path.join(metadata_dir, "voice_metadata.json")
    
    concatenator = AudioConcatenator(config)
    timing_data = concatenator.assemble_master(
        segments=segments,
        segments_dir=segments_dir,
        master_output_path=master_out_path,
        timing_json_path=timing_json_path,
        timing_md_path=timing_md_path,
        metadata_json_path=metadata_json_path,
        project_name=project_id,
        title=title,
        voice=voice
    )
    
    # 6. Copy / Sync to Animation Production Folder if specified
    if animation_voiceover_dir:
        os.makedirs(animation_voiceover_dir, exist_ok=True)
        anim_voice_master = os.path.join(animation_voiceover_dir, "voiceover.wav")
        shutil.copyfile(master_out_path, anim_voice_master)
        
        anim_segments_dir = os.path.join(animation_voiceover_dir, "segments")
        if os.path.exists(anim_segments_dir):
            shutil.rmtree(anim_segments_dir)
        shutil.copytree(segments_dir, anim_segments_dir)
        
        anim_timing_dir = os.path.join(animation_voiceover_dir, "timing")
        os.makedirs(anim_timing_dir, exist_ok=True)
        shutil.copyfile(timing_json_path, os.path.join(anim_timing_dir, "nemi_intro_timing.json"))
        shutil.copyfile(timing_md_path, os.path.join(anim_timing_dir, "Nemi_Intro_Voice_Timing.md"))
        print(f"[Sync] Master voiceover copied to: {anim_voice_master}")
        print(f"[Sync] Segments copied to: {anim_segments_dir}")
        print(f"[Sync] Timing manifests copied to: {anim_timing_dir}")

    print("\n============================================================")
    print("VOICEOVER GENERATION COMPLETE")
    print(f"Master Track: {master_out_path}")
    print(f"Duration: {timing_data['master_duration']:.2f} seconds ({int(timing_data['master_duration']//60)}:{int(timing_data['master_duration']%60):02d})")
    print(f"Total Segments: {len(segments)}")
    print("============================================================")

def main():
    parser = argparse.ArgumentParser(description="Generate Nemi Voiceover from Script")
    parser.add_argument(
        "--script",
        default=os.path.join(WORKSPACE_ROOT, "animations", "ep00_introduction", "script", "script.md"),
        help="Path to markdown script"
    )
    parser.add_argument(
        "--output",
        default=os.path.join(WORKSPACE_ROOT, "audio", "nemi", "intro"),
        help="Base output directory for audio assets"
    )
    parser.add_argument(
        "--anim-voiceover-dir",
        default=os.path.join(WORKSPACE_ROOT, "animations", "ep00_introduction", "voiceover"),
        help="Animation directory to sync voiceover.wav and timing"
    )
    parser.add_argument(
        "--voice",
        default="af_heart",
        help="Kokoro voice candidate name (default: af_heart)"
    )
    args = parser.parse_args()
    
    generate_voiceover(
        script_path=args.script,
        output_base_dir=args.output,
        voice=args.voice,
        animation_voiceover_dir=args.anim_voiceover_dir
    )

if __name__ == "__main__":
    main()
