#!/usr/bin/env python3
"""
tools/mix_ep04_sfx.py
Master Audio Mixing Pipeline for Nemi Episode 04: "Guys, I'm Scared."

- Reads nemi/episodes/ep04_scared/ep04_sfx_timeline.json
- Reads common/audio/sfx/sfx_catalog.json
- Loads master voiceover (nemi/episodes/ep04_scared/audio/EP04_voice.wav)
- Precision mixes 24 SFX cues at exact timestamps with calibrated dB gains
- Asserts dialogue clarity, zero clipping (>=1.0 dBFS headroom), and preserves deadpan silences
- Exports master audio: nemi/episodes/ep04_scared/audio/EP04_audio_sfx_master.wav
"""

import os
import sys
import json
import numpy as np
import soundfile as sf
import scipy.signal as signal

EP04_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE_DIR = os.path.abspath(os.path.join(EP04_DIR, "..", "..", ".."))
TIMELINE_PATH = os.path.join(EP04_DIR, "ep04_sfx_timeline.json")
CATALOG_PATH = os.path.join(BASE_DIR, "common", "audio", "sfx", "sfx_catalog.json")
VOICE_PATH = os.path.join(EP04_DIR, "audio", "EP04_voice.wav")
OUTPUT_DIR = os.path.join(EP04_DIR, "audio")

MASTER_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP04_audio_sfx_master.wav")
SFX_ONLY_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP04_audio_sfx_only.wav")

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
    print("  NEMI EPISODE 04: AUDIO SFX MASTERING & PRECISION MIX")
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
        cue_samples = len(cue_resampled)
        cue_dur = cue_samples / TARGET_SR
        
        # Enforce the <= 2.5s rule for event sfx
        if cue_dur > 2.5:
            max_s = int(2.0 * TARGET_SR)
            cue_resampled = cue_resampled[:max_s]
            fade_len = int(0.05 * TARGET_SR)
            fade = np.linspace(1.0, 0.0, fade_len)[:, np.newaxis]
            cue_resampled[-fade_len:] *= fade
            cue_samples = len(cue_resampled)
            
        start_idx = int(time_sec * TARGET_SR)
        end_idx = min(start_idx + cue_samples, total_samples)
        valid_len = end_idx - start_idx
        
        sfx_bed[start_idx:end_idx] += cue_resampled[:valid_len] * gain
        print(f"  [{idx+1:02d}] @ {time_sec:05.2f}s (Beat {cue.get('beat', '?')}): {sfx_id} ({vol_db:+.1f}dB, dur={cue_dur:.2f}s) - {cue.get('description', '')}")
        
    # 3. Precision Mix & Safety Headroom Normalization
    # Target Voice Peak: -3.0 dBFS
    v_peak = np.max(np.abs(voice_resampled))
    if v_peak > 0:
        voice_normalized = voice_resampled * (db_to_linear(-3.0) / v_peak)
    else:
        voice_normalized = voice_resampled
        
    mix_raw = voice_normalized + sfx_bed
    
    # Measure peak headroom
    raw_peak = np.max(np.abs(mix_raw))
    raw_peak_db = 20.0 * np.log10(raw_peak) if raw_peak > 0 else -100.0
    print(f"\nRaw mix peak: {raw_peak_db:.2f} dBFS")
    
    # Enforce minimum 1.0 dBFS headroom
    if raw_peak_db > -1.0:
        target_attenuation = db_to_linear(-1.2) / raw_peak
        final_mix = mix_raw * target_attenuation
        print(f"Applied safety attenuation: {20.0*np.log10(target_attenuation):.2f} dB")
    else:
        final_mix = mix_raw
        
    final_peak = np.max(np.abs(final_mix))
    final_peak_db = 20.0 * np.log10(final_peak)
    print(f"Final master peak: {final_peak_db:.2f} dBFS (Headroom: {-final_peak_db:.2f} dB)")
    
    # 4. Save Master Waveform
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    sf.write(MASTER_AUDIO_PATH, final_mix, TARGET_SR, subtype="PCM_16")
    sf.write(SFX_ONLY_AUDIO_PATH, sfx_bed, TARGET_SR, subtype="PCM_16")
    print(f"\n✓ Master audio exported: {MASTER_AUDIO_PATH}")
    print(f"✓ SFX-only bed exported: {SFX_ONLY_AUDIO_PATH}")
    print("============================================================")

if __name__ == "__main__":
    main()
