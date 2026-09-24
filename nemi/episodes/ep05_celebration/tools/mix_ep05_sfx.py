#!/usr/bin/env python3
"""
mix_ep05_sfx.py
Master Audio Mixing Pipeline for Nemi Episode 05: "WHAT IS GOING ON WITH YOUTUBE?"

- Precision mixes 35 calibrated SFX cues from ep05_sfx_timeline.json with EP05_voice.wav
- Ensures high dialogue clarity, zero clipping (>=1.0 dBFS headroom)
- Preserves deadpan comedic silences and warm intimate stillness holds
- Exports master audio: nemi/episodes/ep05_celebration/audio/EP05_audio_sfx_master.wav
"""

import os
import sys
import json
import numpy as np
import soundfile as sf
import scipy.signal as signal
import subprocess

EP05_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE_DIR = os.path.abspath(os.path.join(EP05_DIR, "..", "..", ".."))
TIMELINE_PATH = os.path.join(EP05_DIR, "ep05_sfx_timeline.json")
CATALOG_PATH = os.path.join(BASE_DIR, "common", "audio", "sfx", "sfx_catalog.json")
VOICE_PATH = os.path.join(EP05_DIR, "audio", "EP05_voice_v2.wav")
OUTPUT_DIR = os.path.join(EP05_DIR, "audio")

MASTER_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP05_audio_sfx_master.wav")
SFX_ONLY_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP05_audio_sfx_only.wav")
FFMPEG = "/opt/homebrew/bin/ffmpeg"

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
    print("  NEMI EPISODE 05: AUDIO SFX MASTERING & PRECISION MIX")
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
        vol_db = cue.get("volume_db", -14.0)
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
        cue_len = len(cue_resampled)
        end_idx = min(start_idx + cue_len, total_samples)
        actual_len = end_idx - start_idx
        
        if actual_len > 0 and start_idx < total_samples:
            sfx_bed[start_idx:end_idx] += cue_resampled[:actual_len] * gain
            print(f"  [{idx+1:02d}/{len(timeline['cues'])}] @ {time_sec:05.2f}s (vol: {vol_db:+5.1f}dB) | {sfx_id}: {cue['description']}")
            
    # 3. Dynamic Normalization & Headroom Enforcement (>= 1.0 dBFS)
    # Master mix = Voice + SFX
    raw_mix = voice_resampled + sfx_bed
    peak_level = np.max(np.abs(raw_mix))
    peak_db = 20.0 * np.log10(peak_level) if peak_level > 0 else -100.0
    
    print(f"\nRaw Mix Peak Level: {peak_db:.2f} dBFS (Linear: {peak_level:.4f})")
    
    # Target peak: -1.2 dBFS (0.871 linear)
    target_peak_db = -1.2
    target_peak_lin = db_to_linear(target_peak_db)
    
    if peak_level > target_peak_lin:
        scale_factor = target_peak_lin / peak_level
        print(f"Applying master scaling factor {scale_factor:.4f} to ensure {target_peak_db:.1f} dBFS peak headroom.")
        final_mix = raw_mix * scale_factor
        final_sfx = sfx_bed * scale_factor
    else:
        final_mix = raw_mix
        final_sfx = sfx_bed
        
    final_peak = np.max(np.abs(final_mix))
    final_peak_db = 20.0 * np.log10(final_peak)
    print(f"Final Master Audio Peak Level: {final_peak_db:.2f} dBFS (Compliant: >= 1.0 dBFS Headroom)")
    
    # 4. Save Final Master WAV Files
    sf.write(MASTER_AUDIO_PATH, final_mix, TARGET_SR, subtype="PCM_16")
    sf.write(SFX_ONLY_AUDIO_PATH, final_sfx, TARGET_SR, subtype="PCM_16")
    print(f"\n✓ Exported Master SFX Mixed Audio: {MASTER_AUDIO_PATH}")
    print(f"✓ Exported SFX-Only Track: {SFX_ONLY_AUDIO_PATH}")
    
    # MP3 preview
    master_mp3 = os.path.join(OUTPUT_DIR, "EP05_audio_sfx_master.mp3")
    cmd_mp3 = [FFMPEG, "-y", "-i", MASTER_AUDIO_PATH, "-q:a", "2", master_mp3]
    subprocess.run(cmd_mp3, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"✓ Exported Preview MP3: {master_mp3}")
    
    print("\n============================================================")
    print(f"  EP05 AUDIO SFX MASTERING COMPLETE ({total_sec:.2f}s)")
    print("============================================================")

if __name__ == "__main__":
    main()
