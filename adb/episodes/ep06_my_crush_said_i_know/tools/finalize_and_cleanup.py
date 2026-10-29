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

FINAL_4K = RENDERS / 'ADB_EP06_My_Crush_Said_I_Know_4K.mp4'
OLD_1080P = RENDERS / 'ADB_EP06_My_Crush_Said_I_Know_1080p_r1.mp4'

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
    assert frames == 2795, f"Expected 2795 frames, got {frames}"
    assert abs(duration - 93.167) < 0.08, f"Expected ~93.167s duration, got {duration}"

    # 2. Extract 16 stills from 4K and build 4K contact sheet
    stills_4k_dir = RECORDS / 'stills_4k'
    stills_4k_dir.mkdir(parents=True, exist_ok=True)
    timestamps = [
        (2.0, '01_studio_intro'), (7.5, '02_corridor_reshuffle'), (14.5, '03_trio_classroom'),
        (18.0, '04_seating_diagram'), (22.5, '05_feelings_return'), (31.0, '06_quiet_corner_desk'),
        (35.5, '07_year2_turnaround'), (38.0, '08_friend_squad_badge'), (46.0, '09_why_did_you_block_me'),
        (53.0, '10_she_forgot_doodle'), (58.0, '11_bro_shambles'), (68.0, '12_math_exam_plan'),
        (76.0, '13_sweaty_hands_sending'), (83.0, '14_waiting_for_reply'), (88.5, '15_she_replied_i_know'),
        (92.0, '16_final_deadpan_brutal')
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
        col = idx % 4
        row = idx // 4
        sheet.paste(thumb, (col * 480, row * 270))
    sheet.save(REVIEW / '4k_contact_sheet_16shots.jpg', quality=95)
    print("4K contact sheet saved.")

    # 3. Archive logs and review metadata to review/render_records/
    for ext in ['.audio_qa.json', '.capture.log', '.review_stamp.json']:
        p_1080 = RENDERS / f'ADB_EP06_My_Crush_Said_I_Know_1080p_r1{ext}'
        if p_1080.exists():
            shutil.move(str(p_1080), str(RECORDS / p_1080.name))
        p_4k = RENDERS / f'ADB_EP06_My_Crush_Said_I_Know_4K{ext}'
        if p_4k.exists():
            shutil.move(str(p_4k), str(RECORDS / p_4k.name))

    # 4. Record retention and remove superseded 1080p render
    deleted = []
    if OLD_1080P.exists():
        deleted.append({
            'file': str(OLD_1080P.relative_to(EP)),
            'sha256': sha(OLD_1080P),
            'size_bytes': OLD_1080P.stat().st_size,
            'reason': 'superseded by final approved 4K master per user request'
        })
        OLD_1080P.unlink()
        print(f"Deleted superseded 1080p cut: {OLD_1080P.name}")

    retention_record = {
        'episode': 'ep06_my_crush_said_i_know',
        'policy': 'single_final_4k_master_in_renders',
        'user_instruction': 'great now render it in 4k and delete other renders',
        'final_master': {
            'file': str(FINAL_4K.relative_to(EP)),
            'resolution': [width, height],
            'frames': frames,
            'duration': duration,
            'size_bytes': size_bytes,
            'sha256': sha(FINAL_4K)
        },
        'superseded_deleted': deleted
    }
    (REVIEW / 'retention.json').write_text(json.dumps(retention_record, indent=2) + '\n')
    print("Retention record saved to review/retention.json")

    # Verify renders/ contains exclusively the 4K video
    remaining = list(RENDERS.iterdir())
    assert remaining == [FINAL_4K], f"renders/ must contain ONLY final 4K video, found: {remaining}"
    print("Verification PASSED: renders/ contains exclusively the final 4K master video!")

if __name__ == '__main__':
    finalize()
