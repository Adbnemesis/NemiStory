#!/usr/bin/env python3
"""
tools/reclassify_sfx_library.py
Reclassifies and cleans the Nemi SFX Vault:
- Separates event-based SFX (<3s) from long-form AMBIENCE / BEDS / LOOPS (>10s)
- Moves continuous 20-40s recordings from event categories to audio/sfx/ambience/
- Creates clean, punchy event versions (<2.5s) for typing, car ignition, and Foley
- Updates audio/sfx/sfx_catalog.json with explicit sound_type ("event_sfx" vs "ambience_bed")
- Synchronizes documentation (docs/audio/SFX_License_Registry.md and SFX_System_Guide.md)
"""

import os
import json
import soundfile as sf
import numpy as np

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SFX_DIR = os.path.join(BASE_DIR, "audio", "sfx")
CATALOG_PATH = os.path.join(SFX_DIR, "sfx_catalog.json")
AMBIENCE_DIR = os.path.join(SFX_DIR, "ambience")
os.makedirs(AMBIENCE_DIR, exist_ok=True)

def fade_out(samples, fade_len):
    if len(samples) <= fade_len:
        return samples
    ramp = np.linspace(1.0, 0.0, fade_len)
    if samples.ndim == 1:
        samples[-fade_len:] *= ramp
    else:
        samples[-fade_len:, :] *= ramp[:, np.newaxis]
    return samples

def main():
    print("============================================================")
    print("  NEMI SFX VAULT — RECLASSIFICATION & CLEANUP")
    print("============================================================")

    with open(CATALOG_PATH, "r", encoding="utf-8") as f:
        catalog_data = json.load(f)

    assets = catalog_data.get("assets", [])
    print(f"Initial catalog size: {len(assets)} assets")

    asset_map = {item["id"]: item for item in assets}
    new_assets = []

    # 1. Reclassify long suspense sounds into ambience
    if "suspense_waiting_drone_01" in asset_map:
        item = asset_map["suspense_waiting_drone_01"]
        old_path = os.path.join(BASE_DIR, item["relative_path"])
        new_filename = "ambience_suspense_drone_01.wav"
        new_path = os.path.join(AMBIENCE_DIR, new_filename)
        if os.path.exists(old_path):
            os.rename(old_path, new_path)
            item["id"] = "ambience_suspense_drone_01"
            item["filename"] = new_filename
            item["category"] = "ambience"
            item["sub_category"] = "drone_bed"
            item["relative_path"] = f"audio/sfx/ambience/{new_filename}"
            item["sound_type"] = "ambience_bed"
            item["description"] = "Long-form suspense waiting drone bed (41.8s)"
            print(f"  ✓ Moved {item['id']} to ambience/")

    if "suspense_ticking_clock_01" in asset_map:
        item = asset_map["suspense_ticking_clock_01"]
        old_path = os.path.join(BASE_DIR, item["relative_path"])
        new_filename = "ambience_clock_ticking_bed_01.wav"
        new_path = os.path.join(AMBIENCE_DIR, new_filename)
        if os.path.exists(old_path):
            os.rename(old_path, new_path)
            item["id"] = "ambience_clock_ticking_bed_01"
            item["filename"] = new_filename
            item["category"] = "ambience"
            item["sub_category"] = "clock_bed"
            item["relative_path"] = f"audio/sfx/ambience/{new_filename}"
            item["sound_type"] = "ambience_bed"
            item["description"] = "Continuous ticking clock tension bed (11.7s)"
            print(f"  ✓ Moved {item['id']} to ambience/")

    if "phone_hold_tone_01" in asset_map:
        item = asset_map["phone_hold_tone_01"]
        old_path = os.path.join(BASE_DIR, item["relative_path"])
        new_filename = "ambience_phone_hold_loop_01.wav"
        new_path = os.path.join(AMBIENCE_DIR, new_filename)
        if os.path.exists(old_path):
            os.rename(old_path, new_path)
            item["id"] = "ambience_phone_hold_loop_01"
            item["filename"] = new_filename
            item["category"] = "ambience"
            item["sub_category"] = "telephony_bed"
            item["relative_path"] = f"audio/sfx/ambience/{new_filename}"
            item["sound_type"] = "ambience_bed"
            item["description"] = "Electronic phone on-hold melody background loop (11.8s)"
            print(f"  ✓ Moved {item['id']} to ambience/")

    # 2. Reclassify & split long car engine start (14.3s)
    if "car_engine_start_01" in asset_map:
        item = asset_map["car_engine_start_01"]
        car_path = os.path.join(BASE_DIR, item["relative_path"])
        if os.path.exists(car_path):
            data, sr = sf.read(car_path)
            # Create idle bed for ambience
            idle_filename = "ambience_car_engine_idle_01.wav"
            idle_path = os.path.join(AMBIENCE_DIR, idle_filename)
            idle_data = data[int(sr * 2.5):]
            sf.write(idle_path, idle_data, sr, subtype="PCM_16", format="WAV")

            # Trim car_engine_start_01 to clean 2.2s event
            event_data = data[:int(sr * 2.2)]
            event_data = fade_out(event_data, int(sr * 0.15))
            sf.write(car_path, event_data, sr, subtype="PCM_16", format="WAV")

            item["description"] = "Sharp car ignition engine start event (2.2s)"
            item["sound_type"] = "event_sfx"

            # Register the idle bed
            new_assets.append({
                "id": "ambience_car_engine_idle_01",
                "filename": idle_filename,
                "category": "ambience",
                "sub_category": "vehicle_bed",
                "description": "Continuous car engine idle room/cabin bed (11.8s)",
                "source": item["source"],
                "source_url": item.get("source_url", ""),
                "license": item["license"],
                "attribution_required": False,
                "commercial_use": True,
                "tags": ["ambience", "car", "engine", "idle", "bed"],
                "mix_guidance": "bed (-18dB)",
                "sound_type": "ambience_bed",
                "relative_path": f"audio/sfx/ambience/{idle_filename}"
            })
            print("  ✓ Split car_engine_start_01 into 2.2s event + ambience_car_engine_idle_01")

    # 3. Handle long typing files (19s–26s): Keep beds in ambience, provide crisp events in computer
    typing_keys = [
        ("computer_laptop_typing_fast_01", "ambience_typing_laptop_bed_01", 1.25, "Rapid laptop keyboard typing burst (1.2s)"),
        ("computer_keyboard_typing_01", "ambience_typing_mechanical_bed_01", 1.40, "Mechanical keyboard typing burst (1.4s)"),
        ("computer_plastic_typing_01", "ambience_typing_plastic_bed_01", 1.10, "Plastic keyboard typing clatter burst (1.1s)")
    ]

    for orig_id, bed_id, trim_dur, event_desc in typing_keys:
        if orig_id in asset_map:
            item = asset_map[orig_id]
            file_path = os.path.join(BASE_DIR, item["relative_path"])
            if os.path.exists(file_path):
                data, sr = sf.read(file_path)
                bed_filename = f"{bed_id}.wav"
                bed_path = os.path.join(AMBIENCE_DIR, bed_filename)
                sf.write(bed_path, data, sr, subtype="PCM_16", format="WAV")

                # Trim original file to clean event burst
                event_data = data[:int(sr * trim_dur)]
                event_data = fade_out(event_data, int(sr * 0.12))
                sf.write(file_path, event_data, sr, subtype="PCM_16", format="WAV")

                item["description"] = event_desc
                item["sound_type"] = "event_sfx"

                new_assets.append({
                    "id": bed_id,
                    "filename": bed_filename,
                    "category": "ambience",
                    "sub_category": "office_bed",
                    "description": f"Extended typing ambience bed ({len(data)/sr:.1f}s)",
                    "source": item["source"],
                    "source_url": item.get("source_url", ""),
                    "license": item["license"],
                    "attribution_required": False,
                    "commercial_use": True,
                    "tags": ["ambience", "computer", "typing", "office", "bed"],
                    "mix_guidance": "bed (-20dB)",
                    "sound_type": "ambience_bed",
                    "relative_path": f"audio/sfx/ambience/{bed_filename}"
                })
                print(f"  ✓ Processed {orig_id}: trimmed event to {trim_dur}s and saved {bed_id}")

    # 4. Process medium sounds (comedic record slowdown, pours, whoosh rocket, phone ring)
    if "comedic_record_slowdown_01" in asset_map:
        item = asset_map["comedic_record_slowdown_01"]
        p = os.path.join(BASE_DIR, item["relative_path"])
        if os.path.exists(p):
            data, sr = sf.read(p)
            trimmed = data[:int(sr * 3.4)]
            trimmed = fade_out(trimmed, int(sr * 0.2))
            sf.write(p, trimmed, sr, subtype="PCM_16", format="WAV")
            item["description"] = "Vinyl turntable slow down stop event (3.4s)"
            item["sound_type"] = "event_sfx"

    if "whoosh_rocket_fast_01" in asset_map:
        item = asset_map["whoosh_rocket_fast_01"]
        p = os.path.join(BASE_DIR, item["relative_path"])
        if os.path.exists(p):
            data, sr = sf.read(p)
            trimmed = data[:int(sr * 1.8)]
            trimmed = fade_out(trimmed, int(sr * 0.15))
            sf.write(p, trimmed, sr, subtype="PCM_16", format="WAV")
            item["description"] = "Fast high-energy whoosh whip event (1.8s)"
            item["sound_type"] = "event_sfx"

    if "phone_vintage_ring_01" in asset_map:
        item = asset_map["phone_vintage_ring_01"]
        p = os.path.join(BASE_DIR, item["relative_path"])
        if os.path.exists(p):
            data, sr = sf.read(p)
            # Save double ring as bed
            ring_bed_filename = "ambience_phone_vintage_double_ring_01.wav"
            ring_bed_path = os.path.join(AMBIENCE_DIR, ring_bed_filename)
            sf.write(ring_bed_path, data, sr, subtype="PCM_16", format="WAV")

            # Trim to single ring event (2.5s)
            trimmed = data[:int(sr * 2.5)]
            trimmed = fade_out(trimmed, int(sr * 0.15))
            sf.write(p, trimmed, sr, subtype="PCM_16", format="WAV")
            item["description"] = "Vintage telephone single bell ring event (2.5s)"
            item["sound_type"] = "event_sfx"

            new_assets.append({
                "id": "ambience_phone_vintage_double_ring_01",
                "filename": ring_bed_filename,
                "category": "ambience",
                "sub_category": "telephony_bed",
                "description": "Vintage telephone double ring sequence (7.4s)",
                "source": item["source"],
                "source_url": item.get("source_url", ""),
                "license": item["license"],
                "attribution_required": False,
                "commercial_use": True,
                "tags": ["ambience", "phone", "vintage", "ring", "bed"],
                "mix_guidance": "normal (-6dB)",
                "sound_type": "ambience_bed",
                "relative_path": f"audio/sfx/ambience/{ring_bed_filename}"
            })

    if "food_water_pour_01" in asset_map:
        item = asset_map["food_water_pour_01"]
        p = os.path.join(BASE_DIR, item["relative_path"])
        if os.path.exists(p):
            data, sr = sf.read(p)
            # Save long pour as ambience bed
            pour_bed_filename = "ambience_liquid_water_pour_bed_01.wav"
            pour_bed_path = os.path.join(AMBIENCE_DIR, pour_bed_filename)
            sf.write(pour_bed_path, data, sr, subtype="PCM_16", format="WAV")

            # Trim to clean 2.2s pour event
            trimmed = data[:int(sr * 2.2)]
            trimmed = fade_out(trimmed, int(sr * 0.15))
            sf.write(p, trimmed, sr, subtype="PCM_16", format="WAV")
            item["description"] = "Pouring liquid into cup event (2.2s)"
            item["sound_type"] = "event_sfx"

            new_assets.append({
                "id": "ambience_liquid_water_pour_bed_01",
                "filename": pour_bed_filename,
                "category": "ambience",
                "sub_category": "liquid_bed",
                "description": "Continuous water pour into cup bed (8.0s)",
                "source": item["source"],
                "source_url": item.get("source_url", ""),
                "license": item["license"],
                "attribution_required": False,
                "commercial_use": True,
                "tags": ["ambience", "food", "water", "pour", "bed"],
                "mix_guidance": "bed (-16dB)",
                "sound_type": "ambience_bed",
                "relative_path": f"audio/sfx/ambience/{pour_bed_filename}"
            })

    # Mark sound_type for all existing assets
    for item in assets:
        if "sound_type" not in item:
            dur = 0.0
            p = os.path.join(BASE_DIR, item["relative_path"])
            if os.path.exists(p):
                info = sf.info(p)
                dur = info.duration
            if item["category"] == "ambience" or dur > 8.0:
                item["sound_type"] = "ambience_bed"
            else:
                item["sound_type"] = "event_sfx"

    # Merge new assets
    all_assets = assets + new_assets
    # Sort by category then id
    all_assets.sort(key=lambda x: (x["category"], x["id"]))

    # Update category summary counts
    cat_counts = {}
    for item in all_assets:
        c = item["category"]
        cat_counts[c] = cat_counts.get(c, 0) + 1

    catalog_data["assets"] = all_assets
    catalog_data["total_assets"] = len(all_assets)
    catalog_data["categories"] = cat_counts
    catalog_data["version"] = "1.1.0"
    catalog_data["date_updated"] = "2026-09-10"

    with open(CATALOG_PATH, "w", encoding="utf-8") as f:
        json.dump(catalog_data, f, indent=2)

    print(f"\nSaved updated catalog to {CATALOG_PATH}")
    print(f"Total assets: {len(all_assets)} ({len([a for a in all_assets if a.get('sound_type') == 'event_sfx'])} event SFX, {len([a for a in all_assets if a.get('sound_type') == 'ambience_bed'])} ambience beds)")
    print("Categories:")
    for c, cnt in sorted(cat_counts.items()):
        print(f"  • {c:14}: {cnt} sounds")

if __name__ == "__main__":
    main()
