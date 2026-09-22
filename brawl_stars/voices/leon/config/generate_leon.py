#!/usr/bin/env python3
"""
generate_leon.py - Production Dialogue Generator for Leon (Cutenemi / Brawl Stars)
Model: mlx-community/Qwen3-TTS-12Hz-1.7B-Base-bf16
Voice: Fast-talking, animated, manic pitch shifts, comedic persuader
Supports: Lossless pitch modulation (--pitch <semitones>), emotional presets, batch scripts.
"""

import os
import sys
import json
import argparse
import subprocess
import numpy as np
import soundfile as sf

WORKSPACE = "/Users/talus/Documents/adb"
CONFIG_PATH = os.path.join(WORKSPACE, "brawl_stars/voices/leon/config/leon_config.json")
PRESETS_PATH = os.path.join(WORKSPACE, "brawl_stars/voices/leon/config/leon_presets.json")

with open(CONFIG_PATH, "r") as f:
    CONFIG = json.load(f)

with open(PRESETS_PATH, "r") as f:
    PRESETS = json.load(f)

_CACHED_MODEL = None


def get_model():
    global _CACHED_MODEL
    if _CACHED_MODEL is None:
        from mlx_audio.tts.utils import load_model
        model_repo = CONFIG["model_repo"]
        print(f"[Leon TTS] Loading model '{model_repo}' on Apple Silicon GPU...")
        _CACHED_MODEL = load_model(model_repo)
        print("[Leon TTS] Model loaded.")
    return _CACHED_MODEL


def strip_boundary_bleed(audio: np.ndarray, sr: int = 24000) -> np.ndarray:
    frame_len = int(sr * 0.01)  # 10ms frames
    max_search_frames = int(0.45 * 100)  # 450ms search window
    if len(audio) < frame_len * max_search_frames:
        return audio
    rms_values = [np.sqrt(np.mean(audio[i*frame_len : (i+1)*frame_len]**2)) for i in range(max_search_frames)]
    rms_arr = np.array(rms_values)
    if np.max(rms_arr[:20]) > 0.015:
        search_region = rms_arr[15:42]
        valley_idx = 15 + int(np.argmin(search_region))
        cut_sample = valley_idx * frame_len
        return audio[cut_sample:]
    return audio


def normalize_audio(audio: np.ndarray, target_peak: float = 0.92) -> np.ndarray:
    max_peak = np.max(np.abs(audio))
    if max_peak > 1e-6:
        return audio * (target_peak / max_peak)
    return audio


def apply_pitch_shift(wav_path: str, semitones: float):
    if abs(semitones) < 0.01:
        return
    rate_factor = 2.0 ** (semitones / 12.0)
    tempo_factor = 1.0 / rate_factor
    temp_out = wav_path + ".pitch.wav"
    cmd = [
        "/opt/homebrew/bin/ffmpeg", "-y", "-i", wav_path,
        "-af", f"asetrate=24000*{rate_factor:.6f},atempo={tempo_factor:.6f},aresample=24000",
        temp_out
    ]
    res = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if res.returncode == 0 and os.path.exists(temp_out):
        os.replace(temp_out, wav_path)


def generate_line(
    text: str,
    output_path: str,
    emotion: str = "casual",
    pitch_semitones: float = 0.0,
    custom_instruct: str = "",
    seed: int = 42,
    temperature: float = 0.85,
    top_p: float = 0.95
) -> float:
    import mlx.core as mx

    mx.random.seed(seed)
    np.random.seed(seed)

    model = get_model()

    anchor = CONFIG["voice_anchor"]
    ref_audio = os.path.join(WORKSPACE, anchor["ref_audio"])
    ref_text_path = os.path.join(WORKSPACE, anchor["ref_text"])
    with open(ref_text_path, "r") as f:
        ref_text = f.read().strip()

    preset_data = PRESETS.get(emotion, PRESETS["casual"])
    instruct_body = custom_instruct if custom_instruct else preset_data["instruct"]
    base_desc = anchor["base_description"]
    full_instruct = f"{base_desc} {instruct_body}"

    print(f"[Leon TTS] Synthesizing: \"{text}\" (Emotion: {emotion}, Pitch: {pitch_semitones:+.1f} st)")

    res = list(model.generate(
        text=text,
        ref_audio=ref_audio,
        ref_text=ref_text,
        instruct=full_instruct,
        temperature=temperature,
        top_p=top_p
    ))

    raw_audio = res[0].audio
    audio_np = np.array(raw_audio, dtype=np.float32)
    audio_np = strip_boundary_bleed(audio_np, CONFIG["generation_defaults"]["sample_rate"])
    norm_audio = normalize_audio(audio_np, CONFIG["generation_defaults"]["target_peak_normalization"])

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    sf.write(output_path, norm_audio, CONFIG["generation_defaults"]["sample_rate"], subtype="PCM_16")

    if abs(pitch_semitones) >= 0.01:
        apply_pitch_shift(output_path, pitch_semitones)

    dur = len(norm_audio) / float(CONFIG["generation_defaults"]["sample_rate"])
    print(f"✓ Audio generated: {output_path} ({dur:.2f}s)")
    return dur


def main():
    parser = argparse.ArgumentParser(description="Generate dialogue for Leon (Brawl Stars)")
    parser.add_argument("--text", type=str, help="Dialogue line text to speak")
    parser.add_argument("--output", "-o", type=str, default="leon_output.wav", help="Path to output WAV file")
    parser.add_argument("--emotion", type=str, default="casual", choices=list(PRESETS.keys()), help="Emotional acting preset")
    parser.add_argument("--pitch", type=float, default=0.0, help="Pitch shift in semitones (e.g. +2.0 or -1.5)")
    parser.add_argument("--instruct", type=str, default="", help="Custom instruction override")
    parser.add_argument("--seed", type=int, default=42, help="RNG seed")
    parser.add_argument("--temperature", type=float, default=0.85, help="Sampling temperature")
    parser.add_argument("--script", type=str, help="JSON script file for batch generation")

    args = parser.parse_args()

    if args.script:
        with open(args.script, "r") as f:
            script_data = json.load(f)
        for i, item in enumerate(script_data):
            out_p = item.get("output", f"leon_line_{i+1:02d}.wav")
            generate_line(
                text=item["text"],
                output_path=out_p,
                emotion=item.get("emotion", "casual"),
                pitch_semitones=item.get("pitch", args.pitch),
                custom_instruct=item.get("instruct", ""),
                seed=args.seed + i
            )
        return

    if not args.text:
        parser.error("Must provide --text or --script")

    generate_line(
        text=args.text,
        output_path=args.output,
        emotion=args.emotion,
        pitch_semitones=args.pitch,
        custom_instruct=args.instruct,
        seed=args.seed,
        temperature=args.temperature
    )


if __name__ == "__main__":
    main()
