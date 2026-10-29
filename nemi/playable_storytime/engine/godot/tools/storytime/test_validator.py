"""Scene-contract regressions: reject errors a model might accidentally author."""
import copy
import json
import tempfile
from pathlib import Path
from validate_scene import ROOT, validate

base = json.loads((ROOT/'common/storytime/examples/two_authors_10s.json').read_text())
with tempfile.TemporaryDirectory() as folder:
    path = Path(folder)/'spec.json'
    path.write_text(json.dumps(base)); validate(path)
    cases = []
    def case(edit):
        spec = copy.deepcopy(base); edit(spec); cases.append(spec)
    case(lambda s: s['drawings'][0].update(author='unknown'))
    case(lambda s: s['drawings'][0].update(text='not supported 🐸'))
    case(lambda s: s['drawings'][0].update(duration=20))
    case(lambda s: s['actors'][0]['performances'][1].update(recipe='invented_api'))
    case(lambda s: s['actors'][0]['performances'][1].update(duration=9))
    case(lambda s: s['actors'][0]['performances'][1].update(blinks=[8.0]))
    case(lambda s: s['actors'][0].update(mouths=[{'start':1,'end':2,'shape':'talk_open'}]))
    case(lambda s: s['captions'][0].update(text='This subtitle contains far too many words'))
    case(lambda s: s['drawings'][0].update(duraton=.5))
    for spec in cases:
        path.write_text(json.dumps(spec))
        try: validate(path)
        except ValueError: continue
        raise AssertionError('Invalid scene was accepted')
print('PASS: valid example and nine invalid-authoring cases')
