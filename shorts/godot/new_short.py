"""Create editable, unreviewed starter source from a matching approved ink Short."""
from pathlib import Path
import argparse
import json
import re
from layout import cast_for, production_path
ROOT = Path(__file__).resolve().parents[2]
TEMPLATES = {'adb': 'wrong-class', 'nemi': 'my-song', 'duo': 'different-energy'}


def create(cast, slug, template=None):
    target = production_path(ROOT, cast, slug)
    if target.exists():
        raise ValueError(f'Production already exists; nothing overwritten: {target}')
    source = Path(template).resolve() if template else production_path(ROOT, cast, TEMPLATES[cast]) / 'short.json'
    config = json.loads(source.read_text())
    if config.get('version') != 3 or cast_for(config) != cast:
        raise ValueError('Template must be a version-3 Short with the requested cast.')
    scene = (source.parent / 'Edit.tscn').read_text()
    config['id'] = slug
    config['title'] = slug.replace('-', ' ').capitalize()
    scene = re.sub(r'config_path = "[^"]+"', f'config_path = "res://shorts/{cast}/{slug}/short.json"', scene)
    scene = re.sub(r'\[node name="[^"]+"', f'[node name="{slug.replace("-", "_")}"', scene, count=1)
    target.mkdir(parents=True)
    (target / 'short.json').write_text(json.dumps(config, indent=2) + '\n')
    (target / 'Edit.tscn').write_text(scene)
    (target / 'DIRECTION.md').write_text(f'# {config["title"]} — unreviewed starter\n\nTemplate: {source.relative_to(ROOT)}. This copies its music and choreography as a starting point. Adapt them for a distinct idea before delivery.\n\n- Promise:\n- Want:\n- Visible choice:\n- Consequence:\n- Cute payoff:\n- Distinct visual device and palette:\n- Thought beats / audience focus:\n- Music section / verified accent choices:\n\nFollow shorts/godot/V3_WORKFLOW.md; validate, inspect stills, build, and review actual playback with audio.\n')
    (target / 'CUE_MAP.json').write_text(json.dumps({'status': 'unreviewed-template', 'template': str(source.relative_to(ROOT)), 'music': config['music'], 'cues': [], 'next': 'Author scene/source times, accent evidence and event purpose for the new idea.'}, indent=2) + '\n')
    (target / 'render').mkdir()
    (target / 'review').mkdir()
    return target


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('cast', choices=TEMPLATES)
    parser.add_argument('slug')
    parser.add_argument('--template', type=Path)
    args = parser.parse_args()
    try:
        print(create(args.cast, args.slug, args.template))
    except ValueError as error:
        parser.exit(2, f'{error}\n')
