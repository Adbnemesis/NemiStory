from pathlib import Path
import json,cv2,math
from PIL import Image,ImageDraw
root=Path(__file__).resolve().parents[2]
for ref in ['ref01','ref02','ref03','ref04']:
 folder=root/'shorts/review/references'/ref
 m=json.loads((folder/'measurements.json').read_text())
 pts=[x['frame'] for x in m['candidate_changes'] if ref!='ref02' or x['mean_luma_diff']>45]
 if ref=='ref03': pts+= [363,397,469]
 cap=cv2.VideoCapture(str(root/m['file']))
 for page in range(math.ceil(len(pts)/12)):
  batch=sorted(set(pts))[page*12:(page+1)*12]; im=Image.new('RGB',(1200,math.ceil(len(batch)/4)*285),'#17202a');d=ImageDraw.Draw(im)
  for j,n in enumerate(batch):
   x=j%4*300;y=j//4*285;d.text((x+5,y+5),f'frame {n} / {n/m["fps"]:.4f}s',fill='white')
   for k,f in enumerate([n-1,n]):
    cap.set(cv2.CAP_PROP_POS_FRAMES,f);ok,bgr=cap.read()
    if ok: im.paste(Image.fromarray(cv2.cvtColor(bgr,cv2.COLOR_BGR2RGB)).resize((150,256)),(x+k*150,y+25))
  im.save(folder/f'boundaries_{page+1}.jpg')
 cap.release()
