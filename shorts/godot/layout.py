"""Canonical locations for current ink Shorts; historical v1/v2 stays separate."""
from pathlib import Path
import json
import re

CASTS = {'adb': {'adb'}, 'nemi': {'nemi'}, 'duo': {'adb', 'nemi'}}


def cast_for(config):
    authors = {actor.get('author') for actor in config.get('actors', [])}
    for cast, scope in CASTS.items():
        if authors == scope:
            return cast
    raise ValueError('Expected ADB, Nemi or both authors.')


def production_path(root, cast, slug):
    if cast not in CASTS or not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', slug):
        raise ValueError('Use adb/nemi/duo and a lowercase hyphenated short slug.')
    return Path(root) / 'shorts' / cast / slug


def checked_specs(root, preferred=()):
    specs = []
    for cast in CASTS:
        for spec in (Path(root) / 'shorts' / cast).glob('*/short.json'):
            if not (spec.parent / 'review/current.json').is_file():
                continue
            config = json.loads(spec.read_text())
            if config.get('version') != 3 or spec.parent != production_path(root, cast_for(config), config['id']):
                raise ValueError(f'Noncanonical current production: {spec}')
            specs.append(spec)
    positions = {slug: index for index, slug in enumerate(preferred)}
    return sorted(specs, key=lambda p: (positions.get(p.parent.name, len(positions)), str(p)))
