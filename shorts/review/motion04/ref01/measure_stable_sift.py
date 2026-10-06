"""Stable-span similarity fits for ref01; does not touch any production source."""
from pathlib import Path
import cv2,json,math,numpy as np,hashlib
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[4];OUT=Path(__file__).resolve().parent
record=next(x for x in json.loads((ROOT/'shorts/review/references/manifest.json').read_text()) if x['id']=='ref01')
source=ROOT/record['file'];assert hashlib.sha256(source.read_bytes()).hexdigest()==record['sha256']
cap=cv2.VideoCapture(str(source));frames=[]
while True:
 ok,f=cap.read()
 if not ok:break
 frames.append(f)
cap.release();gray=[cv2.cvtColor(f,cv2.COLOR_BGR2GRAY) for f in frames]
mask=np.zeros((854,480),np.uint8);mask[50:742,25:455]=255;mask[552:704]=0
sift=cv2.SIFT_create(nfeatures=1200,contrastThreshold=.015,edgeThreshold=16)
spans=[(1,2,32),(2,37,56),(3,80,96),(5,131,145),(6,153,176),(7,181,203),(8,208,232),(9,237,258),(10,263,287),(11,296,307),(12,316,341),(13,346,409)]
rows=[]
for layout,start,end in spans:
 k1,d1=sift.detectAndCompute(gray[start],mask);k2,d2=sift.detectAndCompute(gray[end],mask)
 matches=cv2.BFMatcher().knnMatch(d1,d2,k=2);good=[a for a,b in matches if a.distance<.75*b.distance]
 p=np.array([k1[m.queryIdx].pt for m in good]);q=np.array([k2[m.trainIdx].pt for m in good])
 m,inliers=cv2.estimateAffinePartial2D(p,q,method=cv2.RANSAC,ransacReprojThreshold=1.5,maxIters=10000,confidence=.999)
 assert m is not None and int(inliers.sum())>=20
 keep=inliers.ravel().astype(bool);p,q=p[keep],q[keep]
 affine,affine_inliers=cv2.estimateAffine2D(p,q,method=cv2.RANSAC,ransacReprojThreshold=1.5,maxIters=10000,confidence=.999)
 center=np.array([240.,427.]);shift=m[:,:2]@center+m[:,2]-center
 centroid=p.mean(axis=0);travel=m[:,:2]@centroid+m[:,2]-centroid
 residual=np.linalg.norm(q-(p@m[:,:2].T+m[:,2]),axis=1)
 row={'layout':layout,'anchor':start,'end':end,'seconds':(end-start)/30,'method':'SIFT .75ratio + RANSAC similarity, <1.5px','matches':len(good),'inliers':int(keep.sum()),'matrix':m.tolist(),'scale':math.hypot(m[0,0],m[1,0]),'rotationDegrees':math.degrees(math.atan2(m[1,0],m[0,0])),'centerDisplacementPixels':shift.tolist(),'trackedCentroidDisplacementPixels':travel.tolist(),'medianInlierResidualPixels':float(np.median(residual)),'fullAffineCheck':{'scaleX':float(np.linalg.norm(affine[:2,0])),'scaleY':float(np.linalg.norm(affine[:2,1]))}}
 rows.append(row)
 # Stable actual before/mid/end and registered pairs keep the selected span visible.
 folder=OUT/f'layout_{layout:02}'
 beforemidend=Image.new('RGB',(1440,886),'#e8e8e5');draw=ImageDraw.Draw(beforemidend)
 for j,f in enumerate([start,(start+end)//2,end]):
  beforemidend.paste(Image.fromarray(cv2.cvtColor(frames[f],cv2.COLOR_BGR2RGB)),(j*480,32));draw.text((j*480+10,10),f'f{f} / {f/30:.3f}s',fill='#28272c')
 beforemidend.save(folder/'stable-before-mid-end.jpg',quality=96)
 aligned=cv2.warpAffine(frames[start],m,(480,854));diff=cv2.absdiff(aligned,frames[end]);proof=np.hstack([aligned,frames[end],diff]);cv2.imwrite(str(folder/'sift-registration.jpg'),proof,[cv2.IMWRITE_JPEG_QUALITY,96])
payload={'source':record,'coordinateUnits':'decoded480x854sourcepixels','scope':'Stable camera/drawing spans only; not internal rig measurement; no globalfit for independently moving duck/passerlayers','rows':rows}
(OUT/'stable_sift.json').write_text(json.dumps(payload,indent=2)+'\n')
rawpath=OUT/'measured_motion.json';raw=json.loads(rawpath.read_text());raw['stableSift']=payload;rawpath.write_text(json.dumps(raw,indent=2)+'\n')
for r in rows:print(r['layout'],round((r['scale']-1)*100,1),[round(x,1) for x in r['centerDisplacementPixels']],round(r['rotationDegrees'],2),r['inliers'])
