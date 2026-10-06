from pathlib import Path
import json,cv2,numpy as np,hashlib,subprocess,math,csv
from PIL import Image,ImageDraw
from scipy.signal import stft,find_peaks
ROOT=Path(__file__).resolve().parents[4];OUT=ROOT/'shorts/review/motion04/ref03';OUT.mkdir(parents=True,exist_ok=True)
m=json.loads((ROOT/'shorts/review/references/manifest.json').read_text())[2]
SOURCE=ROOT/m['file'];assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==m['sha256']
cap=cv2.VideoCapture(str(SOURCE));frames=[]
while True:
 ok,f=cap.read()
 if not ok:break
 frames.append(f)
cap.release();assert len(frames)==627
fps=30; bounds=[0,49,80,124,156,202,238,281,334,361,395,435,471,516,551,592,627]
gray=[cv2.cvtColor(f,cv2.COLOR_BGR2GRAY) for f in frames]
def sheet(samples,path,labels=None,cols=None,width=180):
 cols=cols or len(samples);height=320;rows=math.ceil(len(samples)/cols)
 im=Image.new('RGB',(width*cols,rows*(height+30)),(24,32,40));d=ImageDraw.Draw(im)
 for i,f in enumerate(samples):
  x=(i%cols)*width;y=(i//cols)*(height+30)
  pic=Image.fromarray(cv2.cvtColor(frames[f],cv2.COLOR_BGR2RGB)).resize((width,height))
  im.paste(pic,(x,y+30));d.text((x+3,y+4),(labels[i] if labels else f'f{f} {f/30:.3f}s'),fill='white')
 im.save(path,quality=94)
for idx,(start,end) in enumerate(zip(bounds,bounds[1:]),1):
 samples=sorted(set([start,start+1,start+3,*[round(start+(end-1-start)*p) for p in [.2,.4,.6,.8]],end-4,end-1]))
 sheet(samples,OUT/f'layout_{idx:02}.jpg',cols=5)
for idx,b in enumerate(bounds[1:-1],1):
 samples=[max(0,b+x) for x in [-8,-5,-3,-1,0,1,3,5,8]]
 sheet(samples,OUT/f'join_{idx:02}_f{b:03}.jpg',cols=3,width=240)
# Read sampled endpoints using same start anchor, ignoring the fixed caption.
def track(anchor,target):
 a=gray[anchor];b=gray[target]
 mask=np.zeros_like(a);mask[30:605,18:343]=255;mask[420:545,:]=0
 # Exclude smooth paper/vignette from corners: retain actual dark contour neighborhoods.
 highpass=cv2.absdiff(a,cv2.GaussianBlur(a,(0,0),5));mask[highpass<5]=0
 p0=cv2.goodFeaturesToTrack(a,300,.006,5,mask=mask,blockSize=5)
 if p0 is None or len(p0)<8:return {'reliable':False,'reason':'insufficient anchor artwork corners'}
 p1,status,error=cv2.calcOpticalFlowPyrLK(a,b,p0,None,winSize=(31,31),maxLevel=4,criteria=(cv2.TERM_CRITERIA_EPS|cv2.TERM_CRITERIA_COUNT,50,.01))
 back,bs,be=cv2.calcOpticalFlowPyrLK(b,a,p1,None,winSize=(31,31),maxLevel=4,criteria=(cv2.TERM_CRITERIA_EPS|cv2.TERM_CRITERIA_COUNT,50,.01))
 fb=np.linalg.norm(back[:,0]-p0[:,0],axis=1);valid=(status[:,0]>0)&(bs[:,0]>0)&(fb<1.5)&(error[:,0]<35)
 src=p0[:,0][valid];dst=p1[:,0][valid]
 if len(src)<8:return {'reliable':False,'reason':'fewer than8 forward/back-consistent corners','tracked':len(src)}
 matrix,inliers=cv2.estimateAffinePartial2D(src,dst,method=cv2.RANSAC,ransacReprojThreshold=1.5,maxIters=2000,confidence=.99,refineIters=15)
 if matrix is None:return {'reliable':False,'reason':'affine fit absent','tracked':len(src)}
 inside=inliers[:,0].astype(bool);pred=cv2.transform(src[None,:,:],matrix)[0];res=np.linalg.norm(pred-dst,axis=1)
 scale=math.hypot(matrix[0,0],matrix[1,0]);angle=math.degrees(math.atan2(matrix[1,0],matrix[0,0]));center=matrix@np.array([180,320,1]);shift=center-np.array([180,320])
 reliable=int(inside.sum())>=10 and inside.mean()>=.55 and np.median(res[inside])<1
 return {'reliable':bool(reliable),'anchor':anchor,'target':target,'tracked':len(src),'inliers':int(inside.sum()),'inlierRatio':round(float(inside.mean()),4),'relativeScale':round(scale,5),'rotationDegrees':round(angle,4),'centerTranslationPixels':[round(float(n),3) for n in shift],'matrix':matrix.round(6).tolist(),'medianInlierResidualPixels':round(float(np.median(res[inside])),4),'medianAllResidualPixels':round(float(np.median(res)),4),'nonrigidOrMismatchedCorners':int((res>2).sum())}
# Track post-entry artwork+6 through pre-departure end-7 to avoid measuring joins as holds.
rows=[]
for idx,(start,end) in enumerate(zip(bounds,bounds[1:]),1):
 anchor=start+6;last=end-7
 targets=list(range(anchor,last+1,3));targets.append(last);targets=sorted(set(targets))
 row={'layout':idx,'start':start,'endExclusive':end,'durationSeconds':(end-start)/30,'anchor':anchor,'lastHeldFrame':last,'withinSamples':[start,start+3,round((start+end-1)/2),end-4,end-1],'tracks':[track(anchor,x) for x in targets]}
 rows.append(row)
raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(SOURCE),'-vn','-ac','1','-ar','22050','-f','f32le','pipe:1']);a=np.frombuffer(raw,dtype='<f4')
_,times,z=stft(a,fs=22050,nperseg=1024,noverlap=768,boundary=None);mag=np.abs(z);flux=np.r_[0,np.maximum(np.diff(mag,axis=1),0).sum(axis=0)];flux/=max(float(flux.max()),1e-8)
peaks,_=find_peaks(flux,distance=8,prominence=.055);onsets=[{'seconds':float(times[p]),'normalizedFlux':float(flux[p])} for p in peaks]
relations=[]
for b in bounds[1:-1]:
 t=b/30;near=min(onsets,key=lambda p:abs(p['seconds']-t));relations.append({'frame':b,'seconds':t,'nearestCandidateOnset':round(near['seconds'],4),'signedCutMinusOnsetMs':round((t-near['seconds'])*1000,1),'onsetNormalizedFlux':round(near['normalizedFlux'],4)})
data={'source':m,'decodedFrames':627,'decodedVideoSeconds':20.9,'method':'LK forward/back checked contours; RANSAC partial affine; fixed caption excluded; post-entry6 to pre-departure7 frames. This measures net held-art transform, not physical camera ownership or original drawing cadence.','limits':['Sparse paper/vignette may leave too few corners','Face/hair/hand edits and dissolves break rigid correspondence','A transformed single artwork layer is indistinguishable from camera motion in a mixed export','Caption remains fixed and is intentionally excluded','Partial affine assumes uniform scale+translation+rotation; perspective, masks and blur need direct frame inspection'], 'layouts':rows,'joins':relations,'onsets':onsets}
(OUT/'tracking.json').write_text(json.dumps(data,indent=2))
with (OUT/'held_motion.csv').open('w') as fh:
 w=csv.DictWriter(fh,fieldnames=['layout','anchor','lastHeldFrame','reliable','tracked','inliers','relativeScale','rotationDegrees','centerTranslationPixels','medianInlierResidualPixels']);w.writeheader()
 for row in rows:
  last=row['tracks'][-1];w.writerow({'layout':row['layout'],'anchor':row['anchor'],'lastHeldFrame':row['lastHeldFrame'],**{k:last.get(k,'') for k in ['reliable','tracked','inliers','relativeScale','rotationDegrees','centerTranslationPixels','medianInlierResidualPixels']}})
(OUT/'join_audio_relations.json').write_text(json.dumps(relations,indent=2))
print((OUT/'held_motion.csv').read_text())
