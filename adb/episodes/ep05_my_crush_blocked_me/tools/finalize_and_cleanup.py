#!/usr/bin/env python3
"""Finalize 4K master, extract 4K contact sheet, archive records, and clean superseded renders per user request."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
from PIL import Image

ROOT = Path(__file__).resolve().parents[4]
EP = Path(__file__).resolve().parents[1]
RENDERS = EP / 'renders'
REVIEW = EP / 'review'
RECORDS = REVIEW / 'render_records'
RECORDS.mkdir(parents=True, exist_ok=True)

FINAL_4K = RENDERS / 'ADB_EP05_My_Crush_Blocked_Me_4K.mp4'
OLD_1080P = RENDERS / 'ADB_EP05_My_Crush_Blocked_Me_r1_1080p.mp4'

def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def finalize():
    if not FINAL_4K.is_file():
        raise FileNotFoundError(f"Final 4K master not found at {FINAL_4K}")

    # 1. Verify 4K video properties
    cmd = ['ffprobe', '-v', 'error', '-show_entries', 'format=duration,size,bit_rate:stream=codec_name,width,height,r_frame_rate,nb_frames', '-of', 'json', str(FINAL_4K)]
    data = json.loads(subprocess.check_output(cmd))
    video = next(s for s in data['streams'] if s['codec_name'] == 'h264')
    width, height = int(video['width']), int(video['height'])
    frames = int(video['nb_frames'])
    duration = float(data['format']['duration'])
    size_bytes = int(data['format']['size'])

    assert (width, height) == (3840, 2160), f"Expected 3840x2160, got {width}x{height}"
    assert frames == 3571, f"Expected 3571 frames, got {frames}"
    assert abs(duration - 119.033) < 0.08, f"Expected ~119.033s duration, got {duration}"

    # 2. Extract 16 stills from 4K and build 4K contact sheet
    stills_4k_dir = RECORDS / 'stills_4k'
    stills_4k_dir.mkdir(parents=True, exist_ok=True)
    timestamps = [
        (1.0, '01_studio_intro'), (8.5, '02_corridor_reshuffle'), (15.0, '03_japanese_classroom'),
        (24.5, '04_classroom_strangers'), (30.0, '05_still_friends_desk'), (34.5, '06_chat_outgoing_1'),
        (40.5, '07_waiting_no_reply'), (44.0, '08_chat_outgoing_2'), (48.0, '09_profile_vanished'),
        (55.5, '10_deactivated_delusion'), (63.5, '11_peaceful_delusion_badge'), (72.5, '12_japanese_eavesdrop'),
        (76.5, '13_boyfriend_revealed'), (82.0, '14_rival_boyfriend_diagram'), (95.0, '15_she_blocked_me_stamp'),
        (112.0, '16_broken_soul_studio')
    ]
    imgs = []
    for t, name in timestamps:
        out = stills_4k_dir / f'{name}.jpg'
        subprocess.run(['ffmpeg', '-y', '-ss', str(t), '-i', str(FINAL_4K), '-vframes', '1', '-q:v', '2', str(out)],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        imgs.append(Image.open(out))

    sheet = Image.new('RGB', (1920, 1080), (20, 20, 20))
    for idx, img in enumerate(imgs):
        thumb = img.resize((480, 270), Image.Resampling.LANCZOS)
        col, row = idx % 4, idx // 4
        sheet.paste(thumb, (col * 480, row * 270))

    contact_path = REVIEW / '4k_contact_sheet_16shots.jpg'
    sheet.save(contact_path, quality=92)
    brain_copy = Path('/Users/talus/.gemini/antigravity-ide/brain/e8bc3dc4-a3c0-483e-bcbc-0259deeeea63/4k_contact_sheet_16shots.jpg')
    sheet.save(brain_copy, quality=92)

    # 3. Archive review stamp, audio report, and logs from renders/ to review/render_records/
    for p in list(RENDERS.glob('*.json')) + list(RENDERS.glob('*.log')):
        shutil.move(str(p), str(RECORDS / p.name))

    # 4. Record retention of deleted 1080p render
    retention_data = {
        "policy": "single-master-retained; superseded renders removed upon user request",
        "user_request": "awesome, now render this in 4k and delete other renders, also give the thumbnails as well",
        "deleted_renders": [],
        "retained_master": {
            "path": str(FINAL_4K.relative_to(ROOT)),
            "resolution": [3840, 2160],
            "fps": 30.0,
            "frames": frames,
            "duration": duration,
            "size_bytes": size_bytes,
            "sha256": sha(FINAL_4K)
        }
    }
    if OLD_1080P.is_file():
        retention_data["deleted_renders"].append({
            "path": str(OLD_1080P.relative_to(ROOT)),
            "resolution": [1920, 1080],
            "size_bytes": OLD_1080P.stat().st_size,
            "sha256": sha(OLD_1080P),
            "reason": "superseded by approved native 4K UHD master per explicit user instruction"
        })
        OLD_1080P.unlink()

    (REVIEW / 'retention.json').write_text(json.dumps(retention_data, indent=2) + '\n')
    print("Finalize and cleanup completed successfully!")

if __name__ == '__main__':
    finalize()
