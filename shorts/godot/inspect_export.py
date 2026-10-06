"""Inspect actual encoded movie frames, not just render success."""
import json,sys,subprocess,hashlib
from pathlib import Path
import cv2,numpy as np
from PIL import Image,ImageDraw
from validate_ink import validate
from proof_frames import pose_frames,transition_frames,motion_frames
spec=Path(sys.argv[1]).resolve();movie=Path(sys.argv[2]).resolve();c=validate(spec)
review=spec.parent/'review';review.mkdir(exist_ok=True)
meta=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(movie)]))
v=next(s for s in meta['streams'] if s['codec_type']=='video');a=next(s for s in meta['streams'] if s['codec_type']=='audio')
assert (v['width'],v['height'],v['r_frame_rate'],int(v['nb_read_frames']))==(1080,1920,'30/1',c['frames'])
assert abs(float(meta['format']['duration'])-c['frames']/30)<.05
wanted=pose_frames(c) if c['version']==3 else sorted(set([0,c['frames']-1]+[min(c['frames']-1,s['frame']+7) for s in c['shots']]))
transition_wanted=transition_frames(c) if c['version']==3 else []
motion_wanted=motion_frames(c) if c['version']==3 else []
all_wanted=sorted(set(wanted+transition_wanted+motion_wanted))
cap=cv2.VideoCapture(str(movie));small=[];stills={};i=0
while True:
 ok,f=cap.read()
 if not ok:break
 small.append(cv2.resize(f,(108,192),interpolation=cv2.INTER_AREA).astype(np.float32))
 if i in all_wanted:stills[i]=Image.fromarray(cv2.cvtColor(f,cv2.COLOR_BGR2RGB))
 i+=1
cap.release();assert i==c['frames']
cutrows=[]
for s in c['shots'][1:]:
 f=s['frame'];diff=float(np.abs(small[f]-small[f-1]).mean())
 near=[]
 for x in range(max(1,f-2),min(i,f+3)):near.append({'frame':x,'meanDifference':round(float(np.abs(small[x]-small[x-1]).mean()),4)})
 transition=s.get('transition')
 if transition:
  end=f+transition['duration']
  changes=[float(np.abs(small[x]-small[x-1]).mean()) for x in range(max(1,f),min(i,end+1))]
  landing=float(np.abs(small[min(i-1,end)]-small[max(0,f-1)]).mean())
  assert max(changes)>.06 and landing>.06,f'No visible finite pose transition at frame {f}'
  evidence={'transition':transition['kind'],'transitionEndFrame':end,'maximumEncodedTransitionChange':round(max(changes),4),'landingDifferenceFromDepartingPose':round(landing,4)}
 else:
  assert diff>.06,f'No visible authored picture change at frame {f}'
  evidence={}
 cutrows.append({'frame':f,'sceneTime':f/30,'encodedChangeAtCue':round(diff,4),'nearbyChanges':near,**evidence})
cellw,cellh=270,480;cols=4;rows=(len(wanted)+cols-1)//cols
sheet=Image.new('RGB',(cols*cellw,rows*(cellh+30)),(235,231,226));draw=ImageDraw.Draw(sheet)
for n,f in enumerate(wanted):
 im=stills[f].resize((cellw,cellh));x=(n%cols)*cellw;y=(n//cols)*(cellh+30);sheet.paste(im,(x,y));draw.text((x+8,y+cellh+8),f'{f/30:.2f}s  / f{f}',fill=(30,30,30))
sheet.save(review/'contact.jpg',quality=93)
if transition_wanted:
 transition_sheet=Image.new('RGB',(cols*cellw,((len(transition_wanted)+cols-1)//cols)*(cellh+30)),(235,231,226));tdraw=ImageDraw.Draw(transition_sheet)
 for n,f in enumerate(transition_wanted):
  x=(n%cols)*cellw;y=(n//cols)*(cellh+30);transition_sheet.paste(stills[f].resize((cellw,cellh)),(x,y));tdraw.text((x+8,y+cellh+8),f'{f/30:.2f}s / f{f}',fill=(30,30,30))
 transition_sheet.save(review/'transitions.jpg',quality=93)
hero=wanted[min(3,len(wanted)-1)]
if motion_wanted:
 motion_sheet=Image.new('RGB',(cols*cellw,((len(motion_wanted)+cols-1)//cols)*(cellh+30)),(235,231,226));mdraw=ImageDraw.Draw(motion_sheet)
 for n,f in enumerate(motion_wanted):
  x=(n%cols)*cellw;y=(n//cols)*(cellh+30);motion_sheet.paste(stills[f].resize((cellw,cellh)),(x,y));mdraw.text((x+8,y+cellh+8),f'{f/30:.2f}s / f{f}',fill=(30,30,30))
 motion_sheet.save(review/'motion.jpg',quality=93)
stills[hero].resize((432,768)).save(review/'poster.jpg',quality=93)
report={'movie':str(movie),'sha256':hashlib.sha256(movie.read_bytes()).hexdigest(),'specSha256':hashlib.sha256(spec.read_bytes()).hexdigest(),'video':{'width':v['width'],'height':v['height'],'frames':i,'fps':30,'duration':float(meta['format']['duration']),'codec':v['codec_name']},'audio':{'codec':a['codec_name'],'sampleRate':a['sample_rate'],'channels':a['channels']},'cuts':cutrows,'inspectedFrameCandidates':wanted,'transitionFrameCandidates':transition_wanted,'motionFrameCandidates':motion_wanted,'motionSheet':'motion.jpg' if motion_wanted else None,'contactSheet':'contact.jpg','transitionSheet':'transitions.jpg' if transition_wanted else None,'note':'Numeric export checks plus encoded-frame evidence. Contact sheets and actual playback require visual review; this report does not assert creative acceptance.'}
(review/'export.json').write_text(json.dumps(report,indent=2));print(json.dumps({'title':c['title'],'frames':i,'cutsVerified':len(cutrows),'contactSheet':str(review/'contact.jpg')}))
