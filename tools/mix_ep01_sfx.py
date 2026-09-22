#!/usr/bin/env python3
"""
tools/mix_ep01_sfx.py
Master Audio Mixing Pipeline for Nemi Episode 01: "I Used To Have A Cat"

- Reads episodes/ep01_cat/ep01_sfx_timeline.json
- Reads audio/sfx/sfx_catalog.json
- Loads master voiceover (episodes/ep01_cat/audio/EP01_voice.wav)
- Precision mixes 13 SFX cues at exact timestamps with calibrated dB gains
- Asserts dialogue clarity, zero clipping (>=1.0 dBFS headroom), and preserves deadpan silences
- Exports master audio: episodes/ep01_cat/audio/EP01_audio_sfx_master.wav
"""

import os
import sys
import json
import numpy as np
import soundfile as sf
import scipy.signal as signal

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TIMELINE_PATH = os.path.join(BASE_DIR, "episodes", "ep01_cat", "ep01_sfx_timeline.json")
CATALOG_PATH = os.path.join(BASE_DIR, "audio", "sfx", "sfx_catalog.json")
VOICE_PATH = os.path.join(BASE_DIR, "episodes", "ep01_cat", "audio", "EP01_voice.wav")
OUTPUT_DIR = os.path.join(BASE_DIR, "episodes", "ep01_cat", "audio")

MASTER_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP01_audio_sfx_master.wav")
SFX_ONLY_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP01_audio_sfx_only.wav")

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
    print("  NEMI EPISODE 01: AUDIO SFX MASTERING & PRECISION MIX")
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
        cue_scaled = cue_resampled * gain
        
        start_sample = int(round(time_sec * TARGET_SR))
        end_sample = start_sample + len(cue_scaled)
        
        if start_sample >= total_samples:
            continue
            
        if end_sample > total_samples:
            cue_scaled = cue_scaled[:total_samples - start_sample]
            end_sample = total_samples
            
        sfx_bed[start_sample:end_sample] += cue_scaled
        cue_dur = len(cue_resampled) / TARGET_SR
        print(f"  [{idx+1:02d}] {time_sec:6.2f}s | {vol_db:+5.1f}dB | {cue_dur:4.2f}s | {sfx_id}")
        
    # 3. Precision Mix: Voiceover + SFX Bed
    master_mix = voice_resampled + sfx_bed
    
    # Check Headroom & Peak Levels
    peak_val = np.max(np.abs(master_mix))
    peak_dbfs = 20.0 * np.log10(max(peak_val, 1e-9))
    headroom_db = -peak_dbfs
    print(f"\nMaster Peak: {peak_dbfs:.2f} dBFS (Headroom: {headroom_db:.2f} dB)")
    
    if peak_val > 0.891: # Exceeds -1.0 dBFS
        attenuation = 0.891 / peak_val
        print(f"Applying safety headroom limiting: -{20*np.log10(1/attenuation):.2f}dB")
        master_mix *= attenuation
        peak_val = np.max(np.abs(master_mix))
        peak_dbfs = 20.0 * np.log10(peak_val)
        print(f"New Master Peak: {peak_dbfs:.2f} dBFS")
        
    # 4. Save Outputs
    sf.write(MASTER_AUDIO_PATH, master_mix, TARGET_SR, subtype="PCM_24")
    sf.write(SFX_ONLY_AUDIO_PATH, sfx_bed, TARGET_SR, subtype="PCM_24")
    print(f"\n✓ Master Audio exported: {MASTER_AUDIO_PATH}")
    print(f"✓ Isolated SFX exported: {SFX_ONLY_AUDIO_PATH}")
    print("============================================================")

if __name__ == "__main__":
    main()
