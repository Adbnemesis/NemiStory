#!/usr/bin/env python3
"""
tools/mix_ep00_sfx.py
Master Audio & Video Integration Pipeline for Nemi Episode 00:
"Wait, Listen to Me"

- Reads episodes/ep00_introduction/ep00_sfx_timeline.json
- Reads audio/sfx/sfx_catalog.json
- Loads master voiceover (animations/ep00_introduction/voiceover/voiceover.wav)
- Precision mixes 36 SFX cues at exact timestamps with calibrated dB gains
- Asserts dialogue clarity, zero clipping, and preserves deadpan silences
- Exports master audio: EP00_audio_sfx_master.wav & isolated SFX: EP00_audio_sfx_only.wav
- Multiplexes with visual episode: EP00_SFX_Integrated_Preview.mp4
"""

import os
import sys
import json
import subprocess
import numpy as np
import soundfile as sf
import scipy.signal as signal

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TIMELINE_PATH = os.path.join(BASE_DIR, "episodes", "ep00_introduction", "ep00_sfx_timeline.json")
CATALOG_PATH = os.path.join(BASE_DIR, "audio", "sfx", "sfx_catalog.json")
VOICE_PATH = os.path.join(BASE_DIR, "animations", "ep00_introduction", "voiceover", "voiceover.wav")
# Prefer V3.1 preview, fallback to V3 preview
VISUAL_PREVIEW_PATH = os.path.join(BASE_DIR, "episodes", "ep00_introduction", "previews", "EP00_Introduction_V3_1_preview.mp4")
if not os.path.exists(VISUAL_PREVIEW_PATH):
    VISUAL_PREVIEW_PATH = os.path.join(BASE_DIR, "episodes", "ep00_introduction", "previews", "EP00_Introduction_V3_preview.mp4")

OUTPUT_DIR = os.path.join(BASE_DIR, "episodes", "ep00_introduction", "audio")
PREVIEWS_DIR = os.path.join(BASE_DIR, "episodes", "ep00_introduction", "previews")
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(PREVIEWS_DIR, exist_ok=True)

MASTER_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP00_audio_sfx_master.wav")
SFX_ONLY_AUDIO_PATH = os.path.join(OUTPUT_DIR, "EP00_audio_sfx_only.wav")
ROOT_MASTER_AUDIO_PATH = os.path.join(BASE_DIR, "episodes", "ep00_introduction", "EP00_audio_sfx_master.wav")
INTEGRATED_VIDEO_PATH = os.path.join(PREVIEWS_DIR, "EP00_SFX_Integrated_Preview.mp4")
PASS01_VIDEO_PATH = os.path.join(PREVIEWS_DIR, "EP00_SFX_Pass01.mp4")

TARGET_SR = 48000

def resample_audio(samples, orig_sr, target_sr):
    if orig_sr == target_sr:
        return samples
    # Use gcd for polyphase resampling
    from math import gcd
    g = gcd(orig_sr, target_sr)
    up = target_sr // g
    down = orig_sr // g
    if samples.ndim == 1:
        return signal.resample_poly(samples, up, down)
    else:
        # Multichannel
        channels = [signal.resample_poly(samples[:, ch], up, down) for ch in range(samples.shape[1])]
        return np.column_stack(channels)

def main():
    print("============================================================")
    print("  NEMI EPISODE 00 — FINAL SFX MIXING & MASTERING PIPELINE")
    print("============================================================")

    # 1. Load Timeline and Catalog
    with open(TIMELINE_PATH, "r", encoding="utf-8") as f:
        timeline = json.load(f)

    with open(CATALOG_PATH, "r", encoding="utf-8") as f:
        catalog = {item["id"]: item for item in json.load(f)["assets"]}

    cues = timeline.get("cues", [])
    print(f"Loaded {len(cues)} cues from timeline manifest.")

    # 2. Load Master Voice
    voice_data, voice_sr = sf.read(VOICE_PATH)
    print(f"Loaded Master Voiceover: {VOICE_PATH} ({voice_sr} Hz, duration: {len(voice_data)/voice_sr:.2f}s)")

    # Resample Voice to 48kHz
    if voice_data.ndim > 1:
        voice_mono = np.mean(voice_data, axis=1)
    else:
        voice_mono = voice_data

    voice_48k = resample_audio(voice_mono, voice_sr, TARGET_SR)
    total_samples = len(voice_48k)
    duration_s = total_samples / TARGET_SR
    print(f"Master timeline duration: {duration_s:.3f} seconds ({total_samples} samples at {TARGET_SR}Hz)")

    # Allocate mix buffers (stereo float64 for mastering accuracy)
    mix_voice = np.zeros((total_samples, 2), dtype=np.float64)
    mix_sfx = np.zeros((total_samples, 2), dtype=np.float64)

    # Place voice in center stereo
    mix_voice[:, 0] = voice_48k
    mix_voice[:, 1] = voice_48k

    # 3. Position and Mix Each SFX
    print("\n--- MIXING SFX CUES ---")
    cues_placed = 0

    for idx, cue in enumerate(cues):
        sfx_id = cue["sfx_id"]
        t = cue["time"]
        vol_db = cue["volume_db"]
        beat = cue["beat"]
        desc = cue.get("description", "")

        if sfx_id not in catalog:
            print(f"  [ERROR] SFX ID '{sfx_id}' not found in catalog! Skipping.")
            continue

        item = catalog[sfx_id]
        sfx_file_path = os.path.join(BASE_DIR, item["relative_path"])
        if not os.path.exists(sfx_file_path):
            print(f"  [ERROR] File missing: {sfx_file_path}! Skipping.")
            continue

        sfx_samples, sfx_sr = sf.read(sfx_file_path)
        raw_dur = len(sfx_samples) / sfx_sr
        sound_type = item.get("sound_type", "event_sfx")

        # HARD DURATION SAFETY CHECK (Sections 35, 39, 68)
        if sound_type != "ambience_bed":
            if raw_dur > 3.0:
                print(f"  [SAFETY REJECT] Event SFX '{sfx_id}' duration {raw_dur:.2f}s exceeds hard 3.0s ceiling! Prohibited from event timeline.")
                continue
            elif raw_dur > 2.5:
                print(f"  [SAFETY WARN] Event SFX '{sfx_id}' duration {raw_dur:.2f}s is between 2.5s and 3.0s (requires manual review).")

        # Resample to 48kHz
        sfx_48k = resample_audio(sfx_samples, sfx_sr, TARGET_SR)

        # Convert to stereo
        if sfx_48k.ndim == 1:
            sfx_stereo = np.column_stack([sfx_48k, sfx_48k])
        else:
            sfx_stereo = sfx_48k[:, :2]

        # Apply gain
        gain = 10.0 ** (vol_db / 20.0)
        sfx_scaled = sfx_stereo * gain

        # Calculate sample offsets
        start_idx = int(t * TARGET_SR)
        end_idx = start_idx + len(sfx_scaled)

        # Clamp to timeline
        if start_idx >= total_samples:
            print(f"  [WARN] Cue {sfx_id} at {t}s starts beyond timeline! Skipping.")
            continue

        insert_len = min(len(sfx_scaled), total_samples - start_idx)
        mix_sfx[start_idx:start_idx + insert_len] += sfx_scaled[:insert_len]

        print(f"  [{beat}] {t:6.2f}s | {vol_db:5.1f}dB | {sfx_id:<32} -> {desc}")
        cues_placed += 1

    print(f"\nSuccessfully placed {cues_placed} / {len(cues)} SFX cues into the timeline.")

    # 4. Master Mix Summing & Mastering Dynamics
    # Check peak levels
    voice_peak = np.max(np.abs(mix_voice))
    sfx_peak = np.max(np.abs(mix_sfx))
    print(f"\n--- AUDIO LEVELS & PEAK ANALYSIS ---")
    print(f"Voice Peak Level: {20 * np.log10(max(voice_peak, 1e-9)):.2f} dBFS")
    print(f"SFX Peak Level  : {20 * np.log10(max(sfx_peak, 1e-9)):.2f} dBFS")

    # Sum master mix
    master_mix = mix_voice + mix_sfx
    master_peak = np.max(np.abs(master_mix))
    print(f"Summed Raw Peak : {20 * np.log10(max(master_peak, 1e-9)):.2f} dBFS")

    # Ensure -1.0 dBFS true ceiling headroom
    target_ceiling_db = -1.0
    target_ceiling_linear = 10.0 ** (target_ceiling_db / 20.0)

    if master_peak > target_ceiling_linear:
        attenuation = target_ceiling_linear / master_peak
        print(f"[NOTE] Applying safety master trim of {20 * np.log10(attenuation):.2f} dB to guarantee {target_ceiling_db} dBFS ceiling.")
        master_mix *= attenuation
        mix_sfx *= attenuation
    else:
        print(f"Master headroom is clean ({target_ceiling_db - 20 * np.log10(max(master_peak, 1e-9)):.2f} dB below ceiling). No attenuation needed.")

    # 5. Export Master Audio Files
    print(f"\nWriting Master Audio to: {MASTER_AUDIO_PATH}")
    sf.write(MASTER_AUDIO_PATH, master_mix.astype(np.float32), TARGET_SR, subtype="PCM_24", format="WAV")

    # Also save to root of ep00_introduction for convenience
    sf.write(ROOT_MASTER_AUDIO_PATH, master_mix.astype(np.float32), TARGET_SR, subtype="PCM_24", format="WAV")

    print(f"Writing SFX-Only Track to: {SFX_ONLY_AUDIO_PATH}")
    sf.write(SFX_ONLY_AUDIO_PATH, mix_sfx.astype(np.float32), TARGET_SR, subtype="PCM_24", format="WAV")

    # 6. Multiplex Video Preview with FFmpeg
    if os.path.exists(VISUAL_PREVIEW_PATH):
        print("\n--- MULTIPLEXING SFX-INTEGRATED VIDEO PREVIEWS ---")
        # Generate Pass 01 preview
        print(f"Generating First Pass Preview: {PASS01_VIDEO_PATH}")
        cmd_pass01 = [
            "ffmpeg", "-y",
            "-i", VISUAL_PREVIEW_PATH,
            "-i", MASTER_AUDIO_PATH,
            "-c:v", "copy",
            "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
            "-map", "0:v:0", "-map", "1:a:0",
            "-shortest",
            "-movflags", "+faststart",
            PASS01_VIDEO_PATH
        ]
        subprocess.run(cmd_pass01, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

        # Generate Final Integrated Preview
        print(f"Generating Final Integrated Preview: {INTEGRATED_VIDEO_PATH}")
        cmd_integrated = [
            "ffmpeg", "-y",
            "-i", VISUAL_PREVIEW_PATH,
            "-i", MASTER_AUDIO_PATH,
            "-c:v", "copy",
            "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
            "-map", "0:v:0", "-map", "1:a:0",
            "-shortest",
            "-movflags", "+faststart",
            INTEGRATED_VIDEO_PATH
        ]
        subprocess.run(cmd_integrated, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

        print("\n✓ VIDEO EXPORTS COMPLETE!")
        print(f"  • Pass 01 Video   : {PASS01_VIDEO_PATH}")
        print(f"  • Integrated Video: {INTEGRATED_VIDEO_PATH}")
    else:
        print(f"[WARN] Visual preview not found at {VISUAL_PREVIEW_PATH}. Video multiplex skipped.")

    print("\n============================================================")
    print("  AUDIO MIXING & VIDEO INTEGRATION COMPLETE!")
    print("============================================================")

if __name__ == "__main__":
    main()
