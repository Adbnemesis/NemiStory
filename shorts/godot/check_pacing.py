"""Decode the delivered movie; reject a visible still hold longer than 1.5 seconds."""
import json,sys
from pathlib import Path
import cv2,numpy as np
from validate_ink import validate

def measure(movie,fps,threshold=.10):
 cap=cv2.VideoCapture(str(movie));previous=None;diffs=[]
 while True:
  ok,frame=cap.read()
  if not ok:break
  frame=cv2.resize(frame,(216,384),interpolation=cv2.INTER_AREA).astype(np.float32)
  if previous is not None:diffs.append(float(np.abs(frame-previous).mean()))
  previous=frame
 cap.release()
 # 0.10/255 mean change ignores minor codec flicker. Every low-change frame extends a hold.
 runs=[];start=None
 for i,d in enumerate(diffs,1):
  if d<threshold and start is None:start=i-1
  elif d>=threshold and start is not None:
   runs.append({'startFrame':start,'endFrame':i-1,'seconds':(i-start)/fps});start=None
 if start is not None:runs.append({'startFrame':start,'endFrame':len(diffs),'seconds':(len(diffs)+1-start)/fps})
 return {'frames':len(diffs)+1,'threshold':threshold,'maxStaticSeconds':max((r['seconds'] for r in runs),default=0),'runs':sorted(runs,key=lambda r:r['seconds'],reverse=True),'meanFrameChange':float(np.mean(diffs)) if diffs else 0}

def main():
 c=validate(sys.argv[1]);report=measure(sys.argv[2],c['fps'])
 report.update({'spec':sys.argv[1],'movie':sys.argv[2],'limitSeconds':1.5,'method':'Decoded 216x384 RGB mean absolute frame difference, threshold in 8-bit pixel units. Creative/action review remains necessary.'})
 report['passed']=report['frames']==c['frames'] and report['maxStaticSeconds']<=1.5
 out=Path(sys.argv[3]);out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps({k:report[k] for k in ['passed','frames','maxStaticSeconds','meanFrameChange']}))
 if not report['passed']:raise SystemExit(1)
if __name__=='__main__':main()
