#!/usr/bin/env python3
"""Check a new storytime spec before rendering. No episode/rig writes."""
import json
import math
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]

def validate(path, structure_only=False):
    spec = json.loads(Path(path).read_text())
    from preflight import enforce
    enforce(path,spec)
    if structure_only and isinstance(spec,dict) and spec.get("version")==2:
        from validate_production import validate_production
        return validate_production(spec,ROOT,validate_data,check_assets=False)
    return validate_data(spec)

def validate_data(spec):
    if isinstance(spec,dict) and spec.get("version")==2:
        from validate_production import validate_production
        return validate_production(spec,ROOT,validate_data)
    def require(condition, message):
        if not condition: raise ValueError(message)
    def keys(value, allowed, location):
        require(isinstance(value, dict), f'{location}: expected an object')
        require(not (set(value)-set(allowed.split())), f'{location}: unknown fields {sorted(set(value)-set(allowed.split()))}')
    keys(spec, 'version title duration fps audio actors drawings captions', 'scene')
    def number(value):
        return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value)
    def point(value):
        return isinstance(value, list) and len(value) == 2 and all(number(v) for v in value)
    require(spec.get('version') == 1, 'version must be 1')
    require(number(spec.get('duration')) and 0 < spec['duration'] <= 600, 'duration: 0..600 seconds')
    require(spec.get('fps') in (24, 30, 60), 'fps must be 24, 30, or 60')
    require(isinstance(spec.get('title'), str), 'title is required')
    require(isinstance(spec.get('actors'), list) and spec['actors'], 'actors are required')
    recipes = json.loads((ROOT/'common/storytime/performances/recipes.json').read_text())
    profiles = {a: json.loads((ROOT/f'common/storytime/profiles/{a}.json').read_text()) for a in recipes}
    authors = set()
    for i, actor in enumerate(spec['actors']):
        keys(actor, 'author position scale performances mouths', f'actor {i}')
        author = actor.get('author'); require(author in recipes, f'actor {i}: choose nemi or adb')
        authors.add(author)
        require(point(actor.get('position')), f'actor {i}: position needs [x,y]')
        require(number(actor.get('scale')) and actor['scale'] > 0, f'actor {i}: scale must be positive')
        cues = actor.get('performances', [])
        require(cues and cues[0].get('at') == 0, f'actor {i}: first cue must be at 0')
        previous = -1
        for j, cue in enumerate(cues):
            keys(cue, 'at recipe duration blinks', f'actor {i} cue {j}')
            at = cue.get('at'); require(number(at) and previous < at < spec['duration'], f'actor {i} cue {j}: times must increase within scene')
            previous = at
            require(cue.get('recipe') in recipes[author], f'actor {i} cue {j}: unknown recipe')
            duration = cue.get('duration', recipes[author][cue['recipe']]['duration'])
            require(number(duration) and duration >= 0, f'actor {i} cue {j}: invalid duration')
            next_at = cues[j+1]['at'] if j+1 < len(cues) else spec['duration']
            require(at+duration <= next_at, f'actor {i} cue {j}: transition overlaps next cue')
            for blink in cue.get('blinks', []):
                require(number(blink) and at <= blink and blink+.14 <= next_at, f'actor {i} cue {j}: blink falls outside cue')
        mouth_shapes = {
            'nemi': {'smile','rest','neutral','closed','smile_wide','wide','open_excited','ae','small_open','o_u','laugh','open_shocked','shock','smirk','wavy','frown','surprised','pout'},
            'adb': {'neutral','smile','smirk','deadpan','small_o','talk_open','talk_wide','talk_round','quiver','wobbly','grimace','clenched','pout','nervous_grin','cat_smirk'}}
        end = 0
        for j, mouth in enumerate(actor.get('mouths', [])):
            keys(mouth, 'start end shape', f'actor {i} mouth {j}')
            require(number(mouth.get('start')) and number(mouth.get('end')) and end <= mouth['start'] < mouth['end'] <= spec['duration'], f'actor {i} mouth {j}: invalid or overlapping interval')
            require(mouth.get('shape') in mouth_shapes[author], f'actor {i} mouth {j}: unsupported mouth shape')
            end = mouth['end']
    require(isinstance(spec.get('drawings'), list), 'drawings must be a list')
    replacements = str.maketrans({'’':"'", '‘':"'", '“':'"', '”':'"', '—':'-', '–':'-', '…':'...'})
    for i, drawing in enumerate(spec['drawings']):
        keys(drawing, 'author kind position at duration end scale tilt accent text size variant', f'drawing {i}')
        require(isinstance(drawing.get('accent',False),bool), f'drawing {i}: accent must be true or false')
        author = drawing.get('author'); require(author in authors, f'drawing {i}: author needs an actor')
        kind = drawing.get('kind'); require(kind == 'text' or kind in profiles[author]['marks'], f'drawing {i}: unknown mark')
        require(point(drawing.get('position')), f'drawing {i}: position needs [x,y]')
        require(point(drawing.get('scale', [1,1])) and min(drawing.get('scale', [1,1])) > 0, f'drawing {i}: positive scale required')
        require(number(drawing.get('tilt',0)), f'drawing {i}: tilt must be a number')
        at, duration, end = (drawing.get(k) for k in ('at','duration','end'))
        require(all(number(v) for v in (at,duration,end)) and 0 <= at < end <= spec['duration'] and 0 < duration <= end-at, f'drawing {i}: invalid at/duration/end')
        if kind == 'text':
            require(number(drawing.get('size')) and drawing['size'] > 0, f'drawing {i}: positive text size required')
            require(isinstance(drawing.get('text'),str) and drawing['text'], f'drawing {i}: text required')
            alphabet = json.loads((ROOT/profiles[author]['lettering'].removeprefix('res://')).read_text())['glyphs']
            missing = set(drawing['text'].translate(replacements))-set(alphabet)-{' ','\n'}
            require(not missing, f'drawing {i}: unsupported glyphs {sorted(missing)}; author them or rewrite')
            require(isinstance(drawing.get('variant',0),int), f'drawing {i}: variant must be an integer')
    previous = 0
    for i, card in enumerate(spec.get('captions',[])):
        keys(card, 'start end text', f'caption {i}')
        require(number(card.get('start')) and number(card.get('end')) and previous <= card['start'] < card['end'] <= spec['duration'], f'caption {i}: invalid/overlapping time')
        require(isinstance(card.get('text'),str) and len(card['text'].split()) <= 5, f'caption {i}: maximum five words')
        previous = card['end']
    audio = spec.get('audio')
    if audio:
        require(isinstance(audio,str), 'audio must be a res:// path or null')
        audio_path = (ROOT/audio.removeprefix('res://')).resolve()
        require(audio_path.is_relative_to(ROOT) and audio_path.is_file(), 'audio must exist inside the workspace')
    return spec

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('spec', type=Path)
    parser.add_argument('--structure-only', action='store_true', help='Check version-2 source without requiring local media')
    args = parser.parse_args()
    try:
        scene = validate(args.spec, args.structure_only)
    except (ValueError, KeyError, TypeError) as error:
        parser.exit(1, f'Invalid scene: {error}\n')
    print(f"Valid: {scene['title']} ({scene['duration']} seconds)")
