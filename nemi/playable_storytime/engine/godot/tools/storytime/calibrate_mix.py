#!/usr/bin/env python3
"""Save a new spec with measured, constant mix gain; refuses overwrites."""
import argparse
import json
from pathlib import Path
from audio_mix import calibrate_mix
from validate_scene import ROOT,validate,validate_data
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--spec',type=Path,required=True)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args()
destination=args.output.resolve()
if not destination.is_relative_to(ROOT) or any(destination.is_relative_to(ROOT/p) for p in ('nemi/episodes','adb/episodes')) or destination.exists():
    parser.error('Choose a new spec outside existing episode folders')
spec=validate(args.spec)
if spec['version']!=2: parser.error('Mix calibration requires version 2')
spec['mix']=calibrate_mix(spec,ROOT)
validate_data(spec)
destination.parent.mkdir(parents=True,exist_ok=True)
destination.write_text(json.dumps(spec,indent=2)+'\n')
print(json.dumps(spec['mix']))
