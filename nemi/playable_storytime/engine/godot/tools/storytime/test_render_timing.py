"""Check actual encoded frame boundaries in the refinement proof, not just duration."""
import argparse
import json
import math
from pathlib import Path
import subprocess
from validate_scene import ROOT
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--spec',type=Path,default=ROOT/'common/storytime/examples/refinement_10s/scene.json')
parser.add_argument('--video',type=Path,default=ROOT/'renders/storytime_refinement/One_Tiny_Plan_10s.mp4')
args=parser.parse_args()
spec=json.loads(args.spec.read_text())
video=args.video
if not video.exists():raise SystemExit('Render the refinement proof first; this check requires the local movie.')
# Each shot has a different flat color in the top-left corner. The small
# tolerance ignores codec rounding while detecting the three authored cuts.
pixels=subprocess.check_output(['ffmpeg','-v','error','-i',str(video),'-vf','crop=2:2:0:0','-pix_fmt','rgb24','-f','rawvideo','-'])
assert len(pixels)//12==round(spec['duration']*spec['fps']), 'Wrong encoded frame count'
last=tuple(pixels[:3]);cuts=[]
for frame in range(1,len(pixels)//12):
 color=tuple(pixels[frame*12:frame*12+3])
 if sum(abs(color[i]-last[i]) for i in range(3))>20:
  cuts.append(frame);last=color
expected=[math.ceil(shot['start']*spec['fps']-1e-8) for shot in spec['shots'][1:]]
assert cuts==expected,f'Encoded cuts {cuts} differ from authored frames {expected}'
print(f'PASS: {len(pixels)//12} encoded frames; scene cuts match authored frames {cuts}')
