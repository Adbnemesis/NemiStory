"""Record actual decoding, audio metrics and selected video stills for an EP13 review cut."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from PIL import Image, ImageDraw

EP = Path(__file__).resolve().parent.parent
ROOT = EP.parents[2]
sys.path.insert(0, str(ROOT / 'tools/storytime'))

from audio_mix import measure_audio
from sfx_assets import validate_asset

path = Path(sys.argv[1]).resolve()
out = EP / 'review' / path.stem
out.mkdir(parents=True, exist_ok=True)
spec = json.loads((EP / 'scene.json').read_text())

probe = json.loads(subprocess.check_output([
    'ffprobe', '-v', 'error', '-count_frames', '-select_streams', 'v:0',
    '-show_entries', 'stream=width,height,r_frame_rate,nb_read_frames,duration:format=duration',
    '-of', 'json', str(path)
]))

v = probe['streams'][0]
assert (v['width'], v['height']) == (1920, 1080), f"Expected 1920x1080, got {v['width']}x{v['height']}"
dur_diff = abs(float(probe['format']['duration']) - spec['duration'])
assert dur_diff < 0.2, f"Duration difference {dur_diff:.3f}s exceeds threshold"
assert int(v['nb_read_frames']) == round(spec['duration'] * 30), f"Frames {v['nb_read_frames']} != {round(spec['duration']*30)}"

# Decode verification
subprocess.run(['ffmpeg', '-v', 'error', '-i', str(path), '-f', 'null', '-'], check=True, capture_output=True)

# Timestamps across the 9 beats
step = max(2.5, round(spec['duration'] / 20.0, 1))
ts = sorted(set([round(i * step, 1) for i in range(1, int(spec['duration'] / step) + 1)] + [round(spec['duration'] - 0.5, 1)]))

thumbs = []
for t in ts:
    f = out / f'frame_{t:06.2f}.png'
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-ss', str(t), '-i', str(path), '-frames:v', '1', str(f)], check=True)
    thumbs.append(Image.open(f).resize((640, 360)))

for page in range(0, len(ts), 8):
    subset = thumbs[page:page+8]
    sheet = Image.new('RGB', (1280, ((len(subset) + 1) // 2) * 385), 'white')
    d = ImageDraw.Draw(sheet)
    for j, im in enumerate(subset):
        sheet.paste(im, ((j % 2) * 640, (j // 2) * 385))
        d.text(((j % 2) * 640 + 7, (j // 2) * 385 + 364), f'{ts[page+j]}s', fill='black')
    sheet.save(out / f'contact_{page//8+1}.jpg', quality=94)

assets = json.loads((ROOT / 'common/audio/sfx/sfx_catalog.json').read_text())['assets']
by_path = {x['relative_path']: x for x in assets}
for cue in spec['sfx']:
    validate_asset(by_path[cue['file'][6:]], ROOT)

audio_report = measure_audio(path)
qa = dict(
    status='1080p review; user acceptance pending',
    movie='res://' + str(path.relative_to(ROOT)),
    sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
    spec_sha256=hashlib.sha256((EP / 'scene.json').read_bytes()).hexdigest(),
    duration_seconds=spec['duration'],
    hard_cap_seconds=100.0,
    probe=probe,
    full_decode_passed=True,
    audio=audio_report,
    stills=ts,
    caption_count=len(spec['captions']),
    all_caption_cards_at_most_five_words=all(len(c['text'].split()) <= 5 for c in spec['captions']),
    voice_identity='Canonical Sohee CustomVoice; unchanged identity prompt, original Sohee recordings with selected pitch-preserving tempo 1.08–1.12 and explicit phrase-pause edits; retained originals',
    alignment='Measured Whisper word times plus authored existing mouth shapes and consonant closures',
    sfx_provenance_checked=True,
    rigs_edited=False,
    user_4k_approval=False
)
(out / 'QA.json').write_text(json.dumps(qa, indent=2) + '\n')
print(f"Review artifacts written to: {out}")
print("Audio loudness metrics:", json.dumps(audio_report, indent=2))
