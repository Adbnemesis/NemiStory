#!/usr/bin/env python3
"""
generate_brawler.py - Universal Brawler Dialogue Engine (Cutenemi / Brawl Stars)
Powered by Qwen3-TTS 12Hz 1.7B Base on Apple Silicon GPU.

Features:
- Dual Base Archetypes: Leon (Manic / Fast-Talker) & Edgar (Deadpan / Cynical Gamer)
- Lossless Pitch Shifting via FFmpeg (--pitch <semitones>)
- Pre-configured Brawler Profiles (Leon, Edgar, Crow, Colt, Fang, Bull)
- Dynamic custom brawler creation via --base and --pitch flags
"""

import os
import sys
import json
import argparse
import subprocess
import numpy as np
import soundfile as sf

WORKSPACE = "/Users/talus/Documents/adb"

BRAWLER_REGISTRY = {
    "leon": {
        "base": "leon",
        "default_pitch": 0.0,
        "ref_audio": "brawl_stars/voices/leon/selected/leon_anchor_master.wav",
        "ref_text": "brawl_stars/voices/leon/selected/leon_anchor_master.txt",
        "base_desc": "Fast-talking, animated, persuasive young comedic voice actor with dynamic pitch contours and sudden explosive comedic edge."
    },
    "edgar": {
        "base": "edgar",
        "default_pitch": 0.0,
        "ref_audio": "brawl_stars/voices/edgar/selected/edgar_anchor_master.wav",
        "ref_text": "brawl_stars/voices/edgar/selected/edgar_anchor_master.txt",
        "base_desc": "Young adult male gamer voice, low-mid register, relaxed demeanor, flat matter-of-fact delivery, subtle dry sarcasm, completely unbothered."
    },
    "colt": {
        "base": "edgar",
        "default_pitch": 2.0,
        "ref_audio": "brawl_stars/voices/edgar/selected/edgar_anchor_master.wav",
        "ref_text": "brawl_stars/voices/edgar/selected/edgar_anchor_master.txt",
        "base_desc": "Confident, slightly flashy show-off gamer, brighter tone, cheerful comedic vanity, anime protagonist complex."
    },
    "crow": {
        "base": "leon",
        "default_pitch": -2.0,
        "ref_audio": "brawl_stars/voices/leon/selected/leon_anchor_master.wav",
        "ref_text": "brawl_stars/voices/leon/selected/leon_anchor_master.txt",
        "base_desc": "Slightly raspy vocal fry, cynical rogue assassin, snappy aggressive rhythm, sharp comedic bite, impatient."
    },
    "fang": {
        "base": "leon",
        "default_pitch": 1.0,
        "ref_audio": "brawl_stars/voices/leon/selected/leon_anchor_master.wav",
        "ref_text": "brawl_stars/voices/leon/selected/leon_anchor_master.txt",
        "base_desc": "High energy martial arts movie fanboy, rapid-fire cadence, loud and excited, shouting comedic sound effects."
    },
    "mortis": {
        "base": "leon",
        "default_pitch": -1.5,
        "ref_audio": "brawl_stars/voices/leon/selected/leon_anchor_master.wav",
        "ref_text": "brawl_stars/voices/leon/selected/leon_anchor_master.txt",
        "base_desc": "Theatrical flamboyant Victorian vampire aristocrat, melodramatic cadence, pompous aristocratic ego, dramatic pauses."
    },
    "kenji": {
        "base": "edgar",
        "default_pitch": -1.5,
        "ref_audio": "brawl_stars/voices/edgar/selected/edgar_anchor_master.wav",
        "ref_text": "brawl_stars/voices/edgar/selected/edgar_anchor_master.txt",
        "base_desc": "Disciplined stoic sushi chef samurai, deadpan anime swordsman, low serious register, sharp honorable focus."
    },
    "cosmo": {
        "base": "leon",
        "default_pitch": -0.5,
        "ref_audio": "brawl_stars/voices/leon/selected/leon_anchor_master.wav",
        "ref_text": "brawl_stars/voices/leon/selected/leon_anchor_master.txt",
        "base_desc": "Quirky eccentric Starr Park astronomer, fast-talking scientific rambler, cosmic theories, erratic nerdy comedic energy."
    },
    "shelly": {
        "base": "leon",
        "default_pitch": 2.5,
        "ref_audio": "brawl_stars/voices/leon/selected/leon_anchor_master.wav",
        "ref_text": "brawl_stars/voices/leon/selected/leon_anchor_master.txt",
        "base_desc": "Tough, aggressive, confident female brawler, sharp authoritative delivery, shotgun combat veteran, no-nonsense attitude."
    },
    "piper": {
        "base": "leon",
        "default_pitch": 4.0,
        "ref_audio": "brawl_stars/voices/leon/selected/leon_anchor_master.wav",
        "ref_text": "brawl_stars/voices/leon/selected/leon_anchor_master.txt",
        "base_desc": "High-pitched feminine Southern belle sniper, sugary sweet polite tone hiding cold passive-aggressive condescension."
    },
    "melodie": {
        "base": "leon",
        "default_pitch": 3.5,
        "ref_audio": "brawl_stars/voices/leon/selected/leon_anchor_master.wav",
        "ref_text": "brawl_stars/voices/leon/selected/leon_anchor_master.txt",
        "base_desc": "Energetic, sassy feminine K-pop idol popstar, snappy rhythmic speech, hyper-expressive teen diva attitude."
    }
}

_CACHED_MODEL = None


def get_model():
    global _CACHED_MODEL
    if _CACHED_MODEL is None:
        from mlx_audio.tts.utils import load_model
        model_repo = "mlx-community/Qwen3-TTS-12Hz-1.7B-Base-bf16"
        print(f"[Brawler TTS] Loading model '{model_repo}' on Apple Silicon GPU...")
        _CACHED_MODEL = load_model(model_repo)
        print("[Brawler TTS] Model loaded.")
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


def synthesize_brawler_line(
    brawler: str,
    text: str,
    output_path: str,
    base: str = None,
    pitch: float = None,
    emotion: str = "casual",
    custom_instruct: str = "",
    seed: int = 42
) -> float:
    import mlx.core as mx

    mx.random.seed(seed)
    np.random.seed(seed)

    brawler_key = brawler.lower()
    profile = BRAWLER_REGISTRY.get(brawler_key)

    if profile is None:
        # Fallback to chosen base or leon
        chosen_base = base if base in ("leon", "edgar") else "leon"
        profile = {
            "base": chosen_base,
            "default_pitch": 0.0,
            "ref_audio": BRAWLER_REGISTRY[chosen_base]["ref_audio"],
            "ref_text": BRAWLER_REGISTRY[chosen_base]["ref_text"],
            "base_desc": BRAWLER_REGISTRY[chosen_base]["base_desc"]
        }

    # Override base if user specified explicitly
    if base and base in ("leon", "edgar"):
        profile["base"] = base
        profile["ref_audio"] = BRAWLER_REGISTRY[base]["ref_audio"]
        profile["ref_text"] = BRAWLER_REGISTRY[base]["ref_text"]

    pitch_to_apply = pitch if pitch is not None else profile["default_pitch"]

    ref_audio = os.path.join(WORKSPACE, profile["ref_audio"])
    ref_text_path = os.path.join(WORKSPACE, profile["ref_text"])
    with open(ref_text_path, "r") as f:
        ref_text = f.read().strip()

    model = get_model()

    acting_instruct = custom_instruct if custom_instruct else f"Tone: {emotion}. Natural conversational comedic delivery."
    full_instruct = f"{profile['base_desc']} {acting_instruct}"

    print(f"[Brawler TTS] Generating '{brawler}' (Base: {profile['base']}, Pitch: {pitch_to_apply:+.1f} st)")
    print(f"[Brawler TTS] Line: \"{text}\"")

    res = list(model.generate(
        text=text,
        ref_audio=ref_audio,
        ref_text=ref_text,
        instruct=full_instruct,
        temperature=0.85,
        top_p=0.95
    ))

    raw_audio = res[0].audio
    audio_np = np.array(raw_audio, dtype=np.float32)
    audio_np = strip_boundary_bleed(audio_np, 24000)
    norm_audio = normalize_audio(audio_np, 0.92)

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    sf.write(output_path, norm_audio, 24000, subtype="PCM_16")

    if abs(pitch_to_apply) >= 0.01:
        apply_pitch_shift(output_path, pitch_to_apply)

    dur = len(norm_audio) / 24000.0
    print(f"✓ Saved: {output_path} ({dur:.2f}s)")
    return dur


def main():
    parser = argparse.ArgumentParser(description="Universal Brawler Voice Generator")
    parser.add_argument("--brawler", "-b", type=str, default="leon", help="Brawler profile name (leon, edgar, crow, colt, fang, bull, etc.)")
    parser.add_argument("--base", type=str, choices=["leon", "edgar"], help="Force base archetype (leon: manic, edgar: deadpan)")
    parser.add_argument("--pitch", "-p", type=float, help="Pitch shift in semitones (e.g. +2.0 or -3.0)")
    parser.add_argument("--text", "-t", type=str, help="Dialogue text to speak")
    parser.add_argument("--emotion", "-e", type=str, default="casual", help="Emotional style")
    parser.add_argument("--instruct", "-i", type=str, default="", help="Custom acting instruction")
    parser.add_argument("--output", "-o", type=str, default="brawler_line.wav", help="Output WAV path")
    parser.add_argument("--seed", "-s", type=int, default=42, help="Seed")
    parser.add_argument("--script", type=str, help="JSON script file")

    args = parser.parse_args()

    if args.script:
        with open(args.script, "r") as f:
            script_data = json.load(f)
        for i, item in enumerate(script_data):
            out_p = item.get("output", f"line_{i+1:02d}.wav")
            synthesize_brawler_line(
                brawler=item.get("brawler", args.brawler),
                text=item["text"],
                output_path=out_p,
                base=item.get("base", args.base),
                pitch=item.get("pitch", args.pitch),
                emotion=item.get("emotion", "casual"),
                custom_instruct=item.get("instruct", ""),
                seed=args.seed + i
            )
        return

    if not args.text:
        parser.error("Must provide --text or --script")

    synthesize_brawler_line(
        brawler=args.brawler,
        text=args.text,
        output_path=args.output,
        base=args.base,
        pitch=args.pitch,
        emotion=args.emotion,
        custom_instruct=args.instruct,
        seed=args.seed
    )


if __name__ == "__main__":
    main()
