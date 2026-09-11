#!/usr/bin/env python3
"""
Nemi Voiceover Generation CLI — Qwen3-TTS VoiceDesign Edition
Generates individual dialogue WAV segments, master track, and precise timing manifests
using the local Qwen3-TTS 1.7B VoiceDesign pipeline on Apple Silicon (M-series Mac).
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

from tools.tts.config import NemiVoiceConfig
from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.segmenter import ScriptSegmenter
from tools.tts.concatenator import AudioConcatenator
from tools.audition_voices import CANDIDATE_VOICE_DESIGNS

def generate_voiceover(
    script_path: str,
    output_base_dir: str,
    speaker: str = "sohee",
    custom_prompt: str = None,
    candidate_key: str = None,
    project_id: str = "ep00_introduction",
    title: str = "Wait, Listen to Me",
    animation_voiceover_dir: str = None
):
    # Determine voice instruction prompt
    if custom_prompt:
        voice_prompt = custom_prompt
    else:
        voice_prompt = (
            "Warm, natural young adult woman around 24, relaxed conversational speech, "
            "friendly, casual, intelligent, slightly playful."
        )

    # Setup config
    config = NemiVoiceConfig(
        speaker=speaker,
        voice_identifier=speaker,
        voice_design_prompt=voice_prompt
    )

    print("============================================================")
    print(f"NEMI VOICEOVER GENERATION (QWEN3-TTS CUSTOMVOICE): [{project_id}]")
    print(f"Source Script: {script_path}")
    print(f"Voice Actor: {config.speaker.upper()} (Fixed Embedding)")
    print(f"Output Directory: {output_base_dir}")
    print("============================================================")
    
    # 1. Parse script segments (Strictly preserving script text)
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
    
    # 3. Initialize Qwen Voice Engine
    engine = QwenVoiceDesignEngine(config)
    
    # 4. Generate individual segment WAV files
    print(f"\nSynthesizing individual dialogue segments with actor: {config.speaker.upper()}...")
    for seg in segments:
        seg_out_path = os.path.join(segments_dir, seg.file_name)
        
        # Build contextual instruction modulating emotion within Sohee's identity
        seg_instruct = voice_prompt
        if seg.acting_note:
            seg_instruct = f"{voice_prompt} Tone directive: {seg.acting_note}"
            
        duration = engine.synthesize_to_file(
            text=seg.tts_text,
            output_path=seg_out_path,
            speaker=config.speaker,
            instruct=seg_instruct,
            speed=seg.speed
        )
        seg.duration = duration
        print(f"  [{seg.id}] Beat {seg.beat} ({duration:.2f}s, pause={seg.pause_after:.2f}s): \"{seg.text[:45]}...\"")
        
    print(f"\n✓ Generated {len(segments)} segment audio files.")
    
    # 5. Assemble Master Audio & Timing Manifests
    master_file = "nemi_intro_voice_master.wav"
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
        voice=config.speaker
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
    print(f"Voice Actor: {config.speaker.upper()}")
    print(f"Master Track: {master_out_path}")
    print(f"Duration: {timing_data['master_duration']:.2f} seconds ({int(timing_data['master_duration']//60)}:{int(timing_data['master_duration']%60):02d})")
    print(f"Total Segments: {len(segments)}")
    print("============================================================")

def main():
    parser = argparse.ArgumentParser(description="Generate Nemi Voiceover using Qwen3-TTS CustomVoice")
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
        "--speaker",
        default="sohee",
        choices=["sohee", "serena", "vivian", "ono_anna", "uncle_fu", "ryan", "aiden", "eric", "dylan"],
        help="Predefined Qwen voice actor name (default: sohee)"
    )
    parser.add_argument(
        "--prompt",
        default=None,
        help="Custom emotion / style directive for voice actor"
    )
    args = parser.parse_args()
    
    generate_voiceover(
        script_path=args.script,
        output_base_dir=args.output,
        speaker=args.speaker,
        custom_prompt=args.prompt,
        animation_voiceover_dir=args.anim_voiceover_dir
    )

if __name__ == "__main__":
    main()
