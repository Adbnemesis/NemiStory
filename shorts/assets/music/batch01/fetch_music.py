"""Fetch the exact public Apple/iTunes preview assets selected for batch 01.

No audio effects, tempo changes, or replacement recordings are made here.
The raw AAC assets and decoded PCM files retain separate SHA-256 records.
"""
from pathlib import Path
import concurrent.futures
import datetime
import hashlib
import json
import subprocess
import urllib.parse
import urllib.request

OUT = Path(__file__).resolve().parent
SELECTED = [
    ('cheri-cheri-lady', 348891989, 'US', 'romantic confidence; crisp disco backbeat', 115),
    ('dancin-krono', 1882003938, 'US', 'playful groove; relaxed confident pose switches', 120),
    ('fashion', 1764031281, 'US', 'runway swagger; hard fashion punches and freeze poses', 125),
    ('makeba', 1046165672, 'US', 'percussive creative play; handoff and doodle rhythm', 116),
    ('memory-reboot', 1663317235, 'US', 'dramatic drawing reveal; synth pulse and long silhouette holds', 128),
]

def fetch(item):
    slug, track_id, country, fit, bpm_hint = item
    if any((OUT / f'{slug}{suffix}').exists() for suffix in ('.m4a', '.wav', '.apple-response.json')):
        raise FileExistsError(f'{slug}: preserve the existing downloaded source; use a new asset folder for a fresh fetch')
    api = 'https://itunes.apple.com/lookup?' + urllib.parse.urlencode({'id': track_id, 'country': country})
    with urllib.request.urlopen(api, timeout=60) as response:
        raw = response.read()
    (OUT / f'{slug}.apple-response.json').write_bytes(raw)
    result = json.loads(raw)['results'][0]
    preview_url = result['previewUrl']
    asset = OUT / f'{slug}.m4a'
    with urllib.request.urlopen(preview_url, timeout=60) as response:
        asset.write_bytes(response.read())
    wav = OUT / f'{slug}.wav'
    subprocess.run(['/opt/homebrew/bin/ffmpeg', '-v', 'error', '-i', str(asset), '-ar', '48000', '-ac', '2', '-c:a', 'pcm_s16le', '-y', str(wav)], check=True)
    probe = json.loads(subprocess.check_output(['/opt/homebrew/bin/ffprobe', '-v', 'error', '-show_streams', '-show_format', '-of', 'json', str(wav)]))
    metadata = {
        'id': slug,
        'title': result['trackName'],
        'artist': result['artistName'],
        'album': result.get('collectionName'),
        'version': 'Clean Version' if slug == 'fashion' else ('Krono Remix' if slug == 'dancin-krono' else 'catalog original version'),
        'trackId': track_id,
        'accessedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'catalogReleaseDate': result.get('releaseDate'),
        'sourceKind': 'official public Apple/iTunes AAC preview',
        'catalogUrl': result['trackViewUrl'],
        'lookupUrl': api,
        'downloadUrl': preview_url,
        'rawFile': str(asset.relative_to(OUT.parents[3])),
        'rawSha256': hashlib.sha256(asset.read_bytes()).hexdigest(),
        'file': str(wav.relative_to(OUT.parents[3])),
        'sha256': hashlib.sha256(wav.read_bytes()).hexdigest(),
        'duration': float(probe['format']['duration']),
        'sampleRate': int(probe['streams'][0]['sample_rate']),
        'channels': int(probe['streams'][0]['channels']),
        'transformation': 'AAC decoded to PCM, 48 kHz stereo; no tempo, pitch, EQ, or synthesis changes',
        'fit': fit,
        'bpmHint': bpm_hint,
        'bpmStatus': 'hypothesis; verify against measured preview accents',
        'trendStatus': 'current platform trend rank unverified; chosen as recognizable reference-fit music',
        'previewTimelineNote': 'Preview starts partway through the full song; full-song offset is not provided by the API. Scene-clock sourceStart refers to this downloaded preview.',
    }
    (OUT / f'{slug}.json').write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + '\n')
    return metadata

if __name__ == '__main__':
    with concurrent.futures.ThreadPoolExecutor(5) as pool:
        records = list(pool.map(fetch, SELECTED))
    (OUT / 'catalog.json').write_text(json.dumps(records, ensure_ascii=False, indent=2) + '\n')
    for record in records:
        print(record['id'], record['title'], record['artist'], record['duration'], record['file'])
