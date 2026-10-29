#!/usr/bin/env python3
"""Freeze read-only project dependencies into the isolated Godot workspace."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil

PROJECT = Path(__file__).resolve().parents[1]
REPO = PROJECT.parents[1]
GODOT = PROJECT / 'engine/godot'
TEXT = {'.gd','.tscn','.tres','.json','.py','.md','.gdshader','.cfg'}

def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as source:
        for block in iter(lambda: source.read(1024*1024),b''): h.update(block)
    return h.hexdigest()

def bootstrap():
    GODOT.mkdir(parents=True,exist_ok=True)
    existing=GODOT/'dependency_provenance.json'
    if existing.is_file():
        record=json.loads(existing.read_text())
        for entry in record['copied_files']:
            frozen=GODOT/entry['path']
            if not frozen.is_file() or sha(frozen)!=entry['sha256']:
                raise RuntimeError('Frozen dependency is missing or changed: '+entry['path'])
        # Rendering depends on the frozen snapshot, not the current normal
        # storytime pipeline. Do not silently replace it when that code evolves.
        return record
    files=set()
    for folder in ['common/storytime','common/engine','nemi/characters/nemi','adb/characters/adb','adb/poses','tools/storytime']:
        for source in (REPO/folder).rglob('*'):
            if source.is_file() and source.suffix in TEXT and 'examples' not in source.parts:
                files.add(source.relative_to(REPO).as_posix())
    manifest=json.loads((REPO/'docs/animation/preflight/reading_manifest.json').read_text())
    files.update(manifest['common'])
    for items in manifest['characters'].values(): files.update(items)
    for items in manifest['features'].values(): files.update(items)
    files.update(['docs/animation/preflight/reading_manifest.json','docs/animation/preflight/historical_specs.json'])
    # res:// closure includes imported source assets; generated .import caches are
    # deliberately rebuilt inside this isolated workspace.
    pending=list(files); missing=set()
    while pending:
        relative=pending.pop()
        source=REPO/relative
        if not source.is_file(): missing.add(relative); continue
        if source.suffix not in {'.gd','.tscn','.tres'}: continue
        for dependency in re.findall(r'res://([^"\'\s\)]+)',source.read_text()):
            if dependency.startswith('.godot/') or '*' in dependency: continue
            if (REPO/dependency).is_file() and dependency not in files:
                files.add(dependency); pending.append(dependency)
            elif not (REPO/dependency).exists(): missing.add(dependency)
    copied=[]
    for relative in sorted(files):
        source=REPO/relative
        if not source.is_file(): continue
        destination=GODOT/relative
        destination.parent.mkdir(parents=True,exist_ok=True)
        checksum=sha(source)
        if destination.exists() and sha(destination)!=checksum:
            raise RuntimeError('Isolated dependency changed; refusing overwrite: '+relative)
        if not destination.exists(): shutil.copy2(source,destination)
        copied.append({'path':relative,'sha256':checksum,'bytes':source.stat().st_size})
    record={'source_repository':str(REPO),'copied_files':copied,
            'missing_references':sorted(missing),
            'notes':['Original dependencies are read-only. Copied rig, drawing and acting files are byte-identical.',
                     'Missing references can occur in unused historical examples/runtime optional resources; compile and full validation determine used dependency readiness.']}
    (GODOT/'dependency_provenance.json').write_text(json.dumps(record,indent=2)+'\n')
    return record

def sync_episode(scene_path):
    scene_path=Path(scene_path).resolve()
    if not scene_path.is_relative_to(PROJECT): raise ValueError('Episode source must be inside playable_storytime.')
    spec=json.loads(scene_path.read_text())
    folder=scene_path.parent
    resources=[scene_path,folder/'preflight.json',folder/'storyboard/timeline.json']
    resources.extend(path for path in [folder/'scripts/story.json',folder/'assets/locations.json',folder/'gameplay/manifest.json'] if path.is_file())
    if spec.get('audio'): resources.append(REPO/spec['audio'].removeprefix('res://'))
    if spec.get('audio_metadata'): resources.append(REPO/spec['audio_metadata'].removeprefix('res://'))
    for sound in spec.get('sfx',[])+spec.get('music',[]): resources.append(REPO/sound['file'].removeprefix('res://'))
    metadata_path=REPO/spec['audio_metadata'][6:] if spec.get('audio_metadata') else None
    if metadata_path and metadata_path.is_file():
        # Referenced timing metadata can mention source recordings; keep all
        # production audio together for provenance and independent rebuilds.
        resources.extend(p for p in (folder/'audio').rglob('*') if p.is_file())
    copied=[]
    for source in dict.fromkeys(resources):
        if not source.is_file(): raise FileNotFoundError(str(source))
        relative=source.relative_to(REPO)
        destination=GODOT/relative
        destination.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(source,destination)
        copied.append({'path':relative.as_posix(),'sha256':sha(source),'bytes':source.stat().st_size})
    (GODOT/'episode_snapshot.json').write_text(json.dumps({'same_production_relative_path':str(folder.relative_to(REPO)),
        'receipt_policy':'Exact preflight bytes and identical relative production path; no fabricated readiness or changed exemptions.',
        'files':copied},indent=2)+'\n')
    return GODOT/scene_path.relative_to(REPO)

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--scene',type=Path)
    args=parser.parse_args()
    record=bootstrap()
    print(json.dumps({'copied_dependencies':len(record['copied_files']),'missing_references':record['missing_references']},indent=2))
    if args.scene: print(sync_episode(args.scene))
