"""Assemble native Godot pose/transition proof frames for visual review."""
from pathlib import Path
import argparse,json
from PIL import Image,ImageDraw
from proof_frames import pose_frames,transition_frames,motion_frames
ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--revision',required=True);args=parser.parse_args()
for cast in ('adb','nemi','duo'):
 for spec in (ROOT/'shorts'/cast).glob('*/short.json'):
  c=json.loads(spec.read_text());r=spec.parent/'review';stills=r/'stills'/args.revision
  if not stills.exists() or not (r/f'{args.revision}.capture.log').exists():continue
  for label,frames in [('proof',pose_frames(c)),('transition-proof',transition_frames(c)),('motion-proof',motion_frames(c))]:
   if not frames:continue
   cols,w,h=4,270,480;out=Image.new('RGB',(cols*w,((len(frames)+cols-1)//cols)*(h+26)),(237,233,229));d=ImageDraw.Draw(out)
   for n,frame in enumerate(frames):
    source=stills/f'frame_{frame:03d}.png';x=n%cols*w;y=n//cols*(h+26)
    out.paste(Image.open(source).resize((w,h)),(x,y));d.text((x+5,y+h+5),f'{frame/30:.2f}s / f{frame}',fill=(35,35,35))
   out.save(r/f'{label}-{args.revision}.jpg',quality=93)
  print(f'{cast}/{c["id"]}: native proof sheets')
