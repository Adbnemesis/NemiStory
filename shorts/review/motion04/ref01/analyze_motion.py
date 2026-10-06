"""Read-only decoded-video camera/internal motion study; no production source edits."""
from pathlib import Path
import hashlib,json,math,csv,subprocess
import cv2,numpy as np
from scipy.signal import stft,find_peaks
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).resolve().parent
manifest=json.loads((ROOT/'shorts/review/references/manifest.json').read_text())
record=next(x for x in manifest if x['id']=='ref01')
SOURCE=ROOT/record['file']
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==record['sha256']
cap=cv2.VideoCapture(str(SOURCE));frames=[]
while True:
 ok,bgr=cap.read()
 if not ok:break
 frames.append(bgr)
cap.release()
grays=[cv2.cvtColor(f,cv2.COLOR_BGR2GRAY) for f in frames]
FONTPATH='/System/Library/Fonts/Supplemental/Arial.ttf'
font=ImageFont.truetype(FONTPATH,20)
LAYOUTS=[(0,35,'walking setup'),(35,78,'reaction face + shake'),(78,99,'backpack reverse warning'),(99,129,'duck recoil + passer'),(129,151,'hoverboard reveal'),(151,179,'rider warning face'),(179,206,'skateboard reveal'),(206,235,'skater face'),(235,261,'scooter reveal'),(261,290,'scooter face'),(290,314,'bicycle reveal'),(314,344,'cyclist face'),(344,412,'miniature stress payoff')]

def mask_for(gray):
 mask=np.zeros_like(gray)
 # Central drawing area; fixed caption and vignette outside are excluded.
 mask[50:742,25:455]=255
 mask[552:704,:]=0
 return mask

def estimate(anchor,target):
 a,b=grays[anchor],grays[target]
 pts=cv2.goodFeaturesToTrack(a,maxCorners=700,qualityLevel=.012,minDistance=5,blockSize=5,mask=mask_for(a))
 if pts is None:return None
 new,ok,_=cv2.calcOpticalFlowPyrLK(a,b,pts,None,winSize=(41,41),maxLevel=4,criteria=(cv2.TERM_CRITERIA_EPS|cv2.TERM_CRITERIA_COUNT,60,.005))
 back,ok2,_=cv2.calcOpticalFlowPyrLK(b,a,new,None,winSize=(41,41),maxLevel=4,criteria=(cv2.TERM_CRITERIA_EPS|cv2.TERM_CRITERIA_COUNT,60,.005))
 fb=np.linalg.norm(back-pts,axis=2).ravel()
 keep=(ok.ravel()==1)&(ok2.ravel()==1)&(fb<1.4)
 p,q=pts.reshape(-1,2)[keep],new.reshape(-1,2)[keep]
 if len(p)<6:return None
 matrix,valid=cv2.estimateAffinePartial2D(p,q,method=cv2.RANSAC,ransacReprojThreshold=1.5,maxIters=10000,confidence=.999,refineIters=25)
 if matrix is None:return None
 idx=valid.ravel().astype(bool);p,q=p[idx],q[idx]
 if len(p)<6:return None
 pred=p@matrix[:,:2].T+matrix[:,2]
 residual=np.linalg.norm(q-pred,axis=1)
 scale=float(math.hypot(matrix[0,0],matrix[1,0]));rotation=math.degrees(math.atan2(matrix[1,0],matrix[0,0]))
 center=np.array([240.,427.]);displacement=matrix[:,:2]@center+matrix[:,2]-center
 centroid=p.mean(axis=0);centroid_move=matrix[:,:2]@centroid+matrix[:,2]-centroid
 aligned=cv2.warpAffine(a,matrix,(480,854));difference=cv2.absdiff(aligned,b)
 targetmask=mask_for(b)>0
 targetmask &= (b<155)|(aligned<155)
 return {'matrix':matrix.tolist(),'scale':scale,'rotationDegrees':rotation,'centerShiftPixels':displacement.tolist(),'trackedCentroidShiftPixels':centroid_move.tolist(),'inliers':len(p),'trackedFeatures':int(keep.sum()),'inlierFraction':float(len(p)/max(1,keep.sum())),'medianReprojectionPixels':float(np.median(residual)),'foregroundAlignedMae':float(difference[targetmask].mean()) if targetmask.any() else 0,'anchorFeatureCentroid':centroid.tolist(),'_pairs':(p,q),'_aligned':aligned,'_difference':difference}

def save_image(bgr,path):Image.fromarray(cv2.cvtColor(bgr,cv2.COLOR_BGR2RGB)).save(path)

def panel(indices,path,width=480):
 h=round(854*width/480);im=Image.new('RGB',(width*len(indices),h+36),'#e8e8e5');draw=ImageDraw.Draw(im)
 for j,f in enumerate(indices):
  pic=Image.fromarray(cv2.cvtColor(frames[f],cv2.COLOR_BGR2RGB)).resize((width,h))
  im.paste(pic,(j*width,36));draw.text((j*width+8,6),f'f{f} / {f/30:.3f}s',font=font,fill='#28272c')
 im.save(path,quality=96)
rows=[];all_tracking=[]
for n,(start,end,name) in enumerate(LAYOUTS,1):
 folder=OUT/f'layout_{n:02}';folder.mkdir(exist_ok=True)
 anchor=start+2;last=end-3;middle=(anchor+last)//2
 panel([anchor,middle,last],folder/'before-mid-end.jpg')
 for f in [anchor,middle,last]:save_image(frames[f],folder/f'frame_{f:03}.png')
 trajectory=[]
 for f in range(anchor,last+1):
  result=estimate(anchor,f)
  if result is None:continue
  serial={k:v for k,v in result.items() if not k.startswith('_')}
  trajectory.append({'frame':f,**serial})
  all_tracking.append({'layout':n,'frame':f,'time':f/30,'scale':result['scale'],'rotationDegrees':result['rotationDegrees'],'centerDx':result['centerShiftPixels'][0],'centerDy':result['centerShiftPixels'][1],'centroidDx':result['trackedCentroidShiftPixels'][0],'centroidDy':result['trackedCentroidShiftPixels'][1],'inliers':result['inliers'],'inlierFraction':result['inlierFraction'],'medianResidual':result['medianReprojectionPixels'],'foregroundAlignedMae':result['foregroundAlignedMae']})
 result=estimate(anchor,last)
 if result:
  # Registered start vs end plus amplified residuals, and matched inlier landmarks.
  rendered=np.repeat(result['_aligned'][:,:,None],3,axis=2)
  tracked=frames[last].copy()
  for p,q in zip(*result['_pairs']):
   cv2.circle(tracked,tuple(np.rint(q).astype(int)),2,(50,180,30),1)
  diff=np.clip(result['_difference'].astype(float)*3,0,255).astype(np.uint8)
  reg=Image.new('RGB',(1440,890),'#e8e8e5');d=ImageDraw.Draw(reg)
  for j,(image,label) in enumerate([(rendered,'start similarity-aligned to end'),(tracked,'end, tracked landmarks'),(np.repeat(diff[:,:,None],3,axis=2),'residual x3, incl fixed caption')]):
   reg.paste(Image.fromarray(cv2.cvtColor(image,cv2.COLOR_BGR2RGB)),(j*480,36));d.text((j*480+8,6),label,font=font,fill='#28272c')
  reg.save(folder/'registration.jpg',quality=96)
 row={'layout':n,'name':name,'start':start,'endExclusive':end,'anchor':anchor,'last':last,'duration':(end-start)/30,'trajectory':trajectory}
 if result:row['anchorToEnd']={k:v for k,v in result.items() if not k.startswith('_')}
 rows.append(row)
 if n>1:panel([start-2,start-1,start,start+1,start+3,start+6],folder/'arrival-boundary.jpg',width=240)
# Inspect the deliberate reaction shake and hazard pass at denser cadence.
panel([55,57,58,59,60,62],OUT/'shake_55_62.jpg',240)
panel([96,98,99,100,101,103],OUT/'recoil_96_103.jpg',240)
panel([103,108,112,117,123,127],OUT/'passer_103_127.jpg',240)
raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(SOURCE),'-vn','-ac','1','-ar','22050','-f','f32le','pipe:1'])
a=np.frombuffer(raw,dtype='<f4');_,times,spectrum=stft(a,fs=22050,nperseg=1024,noverlap=768,boundary=None)
flux=np.r_[0,np.maximum(np.diff(np.abs(spectrum),axis=1),0).sum(axis=0)];flux/=max(float(flux.max()),1e-8)
peaks,_=find_peaks(flux,distance=8,prominence=.055)
onsets=[{'time':float(times[i]),'strength':float(flux[i])} for i in peaks]
for row in rows:
 start=row['start'];time=start/30
 nearest=min(onsets,key=lambda x:abs(x['time']-time))
 row['nearestOnset']={**nearest,'cutMinusOnsetMs':(time-nearest['time'])*1000}
report={'source':record,'decodedFrames':len(frames),'fps':30,'coordinateUnits':'480x854 decoded source pixels; displacement is similarity motion of held drawing, not recovered original camera settings','method':'Masked central drawing Shi-Tomasi features; pyramidal Lucas-Kanade forward/backward consistency <1.4px; RANSAC similarity <1.5px reprojection; directly fit from layout anchor to each decoded target. Fixed lower captions excluded from fitting. Low inlier support, large residuals and mixed moving layers are limitations. Inspect images before calling any fit a camera move.','layouts':rows,'audioOnsets':onsets,'audioMethod':'Fresh STFT positive spectral flux from exact source mixed audio, 11.61ms hop, candidate attacks only. No isolated stems or confirmed downbeat phase.'}
(OUT/'measured_motion.json').write_text(json.dumps(report,indent=2)+'\n')
with (OUT/'camera_trajectory.csv').open('w') as f:
 writer=csv.DictWriter(f,fieldnames=list(all_tracking[0]));writer.writeheader();writer.writerows(all_tracking)
print('decoded',len(frames),'source hash verified',record['sha256'])
for r in rows:
 v=r.get('anchorToEnd',{})
 print(r['layout'],r['name'],f'f{r["anchor"]}→{r["last"]}', 'scale',round(v.get('scale',0),4),'rot',round(v.get('rotationDegrees',0),3),'center',np.round(v.get('centerShiftPixels',[]),2),'n',v.get('inliers'),'mae',round(v.get('foregroundAlignedMae',0),2))
