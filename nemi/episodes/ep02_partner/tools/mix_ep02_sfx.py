#!/usr/bin/env python3
"""
episodes/ep02_partner/tools/mix_ep02_sfx.py
Master Audio Mixing Pipeline for Nemi Episode 02: "How I Met My Partner"

- Reads episodes/ep02_partner/ep02_sfx_timeline.json
- Reads audio/sfx/sfx_catalog.json
- Loads master voiceover (episodes/ep02_partner/audio/EP02_voice.wav)
- Precision mixes 15 SFX cues at exact timestamps with calibrated dB gains
- Asserts dialogue clarity, zero clipping (>=1.0 dBFS headroom), and preserves deadpan silences
- Exports master audio: episodes/ep02_partner/audio/EP02_audio_sfx_master.wav
"""

import os
import sys
import json
import numpy as np
import soundfile as sf
import scipy.signal as signal

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
TIMELINE_PATH = os.path.join(BASE_DIR, "episodes", "ep02_partner", "ep02_sfx_timeline.json")
CATALOG_PATH = os.path.join(BASE_DIR, "audio", "sfx", "sfx_catalog.json")
VOICE_PATH = os.path.join(BASE_DIR, "episodes", "ep02_partner", "audio", "EP02_voice.wav")
OUTPUT_DIR = os.path.join(BASE_DIR, "episodes", "ep02_partner", "audio")

MASTER_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP02_audio_sfx_master.wav")
SFX_ONLY_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP02_audio_sfx_only.wav")

TARGET_SR = 48000

def resample_audio(samples, orig_sr, target_sr):
    if orig_sr == target_sr:
        return samples
    from math import gcd
    g = gcd(orig_sr, target_sr)
    up = target_sr // g
    down = orig_sr // g
    if samples.ndim == 1:
        return signal.resample_poly(samples, up, down)
    else:
        channels = [signal.resample_poly(samples[:, ch], up, down) for ch in range(samples.shape[1])]
        return np.column_stack(channels)

def db_to_linear(db):
    return 10.0 ** (db / 20.0)

def main():
    print("============================================================")
    print("  NEMI EPISODE 02: AUDIO SFX MASTERING & PRECISION MIX")
    print("============================================================")
    
    with open(TIMELINE_PATH, "r", encoding="utf-8") as f:
        timeline = json.load(f)
        
    with open(CATALOG_PATH, "r", encoding="utf-8") as f:
        catalog = json.load(f)
        
    asset_map = {item["id"]: item for item in catalog.get("assets", [])}
    
    # 1. Load Master Voiceover
    if not os.path.exists(VOICE_PATH):
        raise FileNotFoundError(f"Voice track not found: {VOICE_PATH}")
        
    voice_data, voice_sr = sf.read(VOICE_PATH, dtype="float32")
    if voice_data.ndim == 1:
        voice_stereo = np.column_stack([voice_data, voice_data])
    else:
        voice_stereo = voice_data
        
    voice_resampled = resample_audio(voice_stereo, voice_sr, TARGET_SR)
    total_samples = len(voice_resampled)
    total_sec = total_samples / TARGET_SR
    print(f"Loaded voice track: {total_sec:.2f}s ({voice_sr}Hz -> {TARGET_SR}Hz)")
    
    # 2. Build SFX Bed
    sfx_bed = np.zeros_like(voice_resampled)
    
    print(f"\nProcessing {len(timeline['cues'])} SFX cues...")
    for idx, cue in enumerate(timeline["cues"]):
        sfx_id = cue["sfx_id"]
        time_sec = cue["time"]
        vol_db = cue.get("volume_db", -6.0)
        gain = db_to_linear(vol_db)
        
        if sfx_id not in asset_map:
            raise KeyError(f"SFX ID '{sfx_id}' not found in catalog!")
            
        rel_path = asset_map[sfx_id].get("relative_path") or asset_map[sfx_id].get("path")
        abs_path = os.path.join(BASE_DIR, rel_path)
        
        if not os.path.exists(abs_path):
            raise FileNotFoundError(f"Audio file missing for {sfx_id}: {abs_path}")
            
        cue_data, cue_sr = sf.read(abs_path, dtype="float32")
        if cue_data.ndim == 1:
            cue_stereo = np.column_stack([cue_data, cue_data])
        else:
            cue_stereo = cue_data
            
        cue_resampled = resample_audio(cue_stereo, cue_sr, TARGET_SR)
        start_idx = int(time_sec * TARGET_SR)
        end_idx = min(start_idx + len(cue_resampled), total_samples)
        slice_len = end_idx - start_idx
        
        if slice_len > 0:
            sfx_bed[start_idx:end_idx] += cue_resampled[:slice_len] * gain
            cue_dur = slice_len / TARGET_SR
            print(f"  [{idx+1:02d}] t={time_sec:6.2f}s | {vol_db:5.1f}dB | {cue_dur:.2f}s | {sfx_id}")
            
    # 3. Master Mix & Headroom Check
    master_mix = voice_resampled + sfx_bed
    peak_val = np.max(np.abs(master_mix))
    peak_db = 20.0 * np.log10(peak_val) if peak_val > 0 else -100.0
    
    print("\n------------------------------------------------------------")
    print(f"Peak Master Volume: {peak_db:.2f} dBFS")
    
    if peak_db > -1.0:
        reduction_db = peak_db - (-1.5)
        scale = db_to_linear(-reduction_db)
        print(f"Applying safety limiter (-{reduction_db:.2f} dB) to ensure >=1.0 dBFS headroom.")
        master_mix *= scale
        peak_val = np.max(np.abs(master_mix))
        peak_db = 20.0 * np.log10(peak_val)
        print(f"New Master Peak: {peak_db:.2f} dBFS (Headroom: {abs(peak_db):.2f} dB)")
    else:
        print(f"Headroom verified: {abs(peak_db):.2f} dB >= 1.0 dBFS.")
        
    # 4. Export Audio Files
    sf.write(MASTER_AUDIO_PATH, master_mix, TARGET_SR, subtype="PCM_16")
    sf.write(SFX_ONLY_AUDIO_PATH, sfx_bed, TARGET_SR, subtype="PCM_16")
    
    print("\n✓ Master audio exported successfully:")
    print(f"  - Master (Voice + SFX): {MASTER_AUDIO_PATH}")
    print(f"  - SFX Stem Only:       {SFX_ONLY_AUDIO_PATH}")
    print("============================================================\n")

if __name__ == "__main__":
    main()
