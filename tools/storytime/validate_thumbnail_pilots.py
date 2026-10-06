#!/usr/bin/env python3
"""Validate static pilot sources before real GPU export; not animation preflight."""
from pathlib import Path
import argparse
import json
import math
import re

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / 'tools/storytime/thumbnail_promotional_2026-10-06.json'


def resource(value):
    assert value.startswith('res://'), value
    path = ROOT / value[6:]
    assert path.is_file(), value
    return path


def pair(value):
    assert isinstance(value, list) and len(value) == 2, value
    assert all(isinstance(x, (int, float)) and math.isfinite(x) for x in value), value


def validate(path):
    layout = json.loads(path.read_text())
    assert layout['format'] in ('storytime-static-pilot-v1', 'storytime-static-promotional-v1'), path
    assert layout['author'] in ('adb', 'nemi'), path
    for name in ('episode', 'variant', 'title', 'thumbnail_phrase', 'story_evidence', 'application', 'revision'):
        assert isinstance(layout[name], str) and layout[name].strip(), (path, name)
    assert layout['variant'] in ('a', 'b')
    # Several lines may typeset one phrase; they are not secondary captions.
    assert ' '.join(line['text'] for line in layout['headline']).split() == layout['thumbnail_phrase'].split(), path
    for line in layout['headline']:
        pair(line['position'])
        assert 120 <= line['size'] <= 400 and 200 <= line['max_width'] <= 1850, line
        resource(line.get('font', 'res://assets/fonts/Impact.ttf'))
    ids = set()
    recipes = json.loads((ROOT / 'common/storytime/performances/recipes.json').read_text())
    for layer in layout['layers']:
        assert layer['type'] in ('character', 'prop', 'scenery', 'mark'), layer
        if layer['type'] == 'scenery':
            factory = resource(layer['source']).read_text()
            declared = set(re.findall(r'"([a-z_]+)"\s*:', factory)) | set(re.findall(r'part\s*==\s*"([a-z_]+)"', factory))
            assert layer['variant'] in ('a', 'b') and layer['part'] in declared, layer
            continue
        pair(layer['position'])
        scale = layer.get('scale', 1)
        if isinstance(scale, list):
            pair(scale)
            assert all(x != 0 for x in scale)
        else:
            assert isinstance(scale, (float, int)) and 0 < scale <= 10, scale
        if layer['type'] == 'character':
            assert layer['id'] not in ids, layer['id']
            ids.add(layer['id'])
            assert layer['author'] in ('adb', 'nemi'), layer
            rig = resource(layer['rig'])
            expected = 'adb/characters/adb/ADB.tscn' if layer['author'] == 'adb' else 'nemi/characters/nemi/nemi.tscn'
            assert rig == ROOT / expected, rig
            if layer['author'] == 'adb':
                assert layer['recipe'] in recipes['adb'], layer['recipe']
            for target in layer.get('hand_targets', []):
                assert target['side'] in ('left', 'right')
                pair(target.get('head_offset', target.get('position')))
        if layer['type'] == 'prop':
            assert layer['kind'] in ('scene', 'script', 'heart', 'paper', 'paddle', 'controller', 'youtube', 'cat', 'crowd'), layer
            if layer['kind'] == 'script': resource(layer['source'])
            if 'attachment' in layer:
                binding = layer['attachment']
                assert binding['actor'] in ids, 'Actor must precede its attached prop'
                assert binding['hand'] in ('left', 'right')
                pair(binding['grip_local'])
    assert ids and layout['layers'], path
    return layout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--layout', type=Path)
    parser.add_argument('--manifest', type=Path, default=MANIFEST)
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text())
    paths = [ROOT / args.layout] if args.layout else [ROOT / item['layout'] for item in manifest['variants']]
    for path in paths: validate(path)
    print(f'Static pilot validation passed: {len(paths)} layouts. Visual QA and audience tests remain separate.')


if __name__ == '__main__':
    main()
