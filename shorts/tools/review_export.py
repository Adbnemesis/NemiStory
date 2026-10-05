"""Measure an actual export; save chronological contacts, seams and exported audio QA."""
import argparse,subprocess,json,hashlib
from pathlib import Path
import cv2,numpy as np
from PIL import Image,ImageDraw
P=argparse.ArgumentParser();P.add_argument('movie',type=Path);a=P.parse_args();movie=a.movie.resolve();out=movie.parent.parent/'review'/movie.stem;out.mkdir(parents=True,exist_ok=True)
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(movie)]));v=next(x for x in probe['streams'] if x['codec_type']=='video');dur=float(v['duration']);fps=eval(v['avg_frame_rate'],{'__builtins__':{}});frames=int(v['nb_frames'])
cap=cv2.VideoCapture(str(movie));times=list(np.arange(0,dur,.75))+[dur-1/fps];thumbs=[]
for t in times:
 cap.set(cv2.CAP_PROP_POS_FRAMES,min(frames-1,round(t*fps)));ok,b=cap.read()
 if not ok:raise ValueError('Frame could not decode '+str(t))
 im=Image.fromarray(cv2.cvtColor(b,cv2.COLOR_BGR2RGB));im.thumbnail((216,384));tile=Image.new('RGB',(236,422),'#142129');tile.paste(im,(10,24));ImageDraw.Draw(tile).text((10,6),f'{t:.3f}s',fill='white');thumbs.append(tile)
 if t==times[0] or t==times[-1]:im.save(out/('first.jpg' if t==0 else 'last.jpg'))
for i in range(0,len(thumbs),12):
 batch=thumbs[i:i+12];sheet=Image.new('RGB',(236*6,422*((len(batch)+5)//6)),'#142129')
 for j,im in enumerate(batch):sheet.paste(im,((j%6)*236,(j//6)*422))
 sheet.save(out/f'contact_{i//12+1}.jpg',quality=92)
cap.release()
raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(movie),'-vn','-ac','2','-ar','48000','-f','f32le','pipe:1']);x=np.frombuffer(raw,dtype='<f4').reshape(-1,2);db=lambda x:float(20*np.log10(max(float(x),1e-12)))
window=[]
for t in np.arange(0,dur,.25):
 seg=x[int(t*48000):int((t+.25)*48000)];window.append({'start':round(float(t),3),'rmsDbFS':db(np.sqrt(np.mean(seg**2))),'peakDbFS':db(np.max(np.abs(seg)))})
loudness=subprocess.run(['ffmpeg','-hide_banner','-i',str(movie),'-af','ebur128=peak=true','-f','null','-'],capture_output=True,text=True).stderr.split('Summary:')[-1].strip()
report={'movie':str(movie),'sha256':hashlib.sha256(movie.read_bytes()).hexdigest(),'width':v['width'],'height':v['height'],'fps':fps,'frames':frames,'videoDuration':dur,'containerDuration':float(probe['format']['duration']),'audioSamples':len(x),'samplePeakDbFS':db(np.max(np.abs(x))),'clippedSamples':int(np.sum(np.abs(x)>=1)),'loudness':loudness,'audioWindows':window,'stills':'Contacts every .75s plus final frame; review actual movie separately.'}
(out/'export.json').write_text(json.dumps(report,indent=2));print(json.dumps({k:report[k] for k in ['width','height','fps','frames','videoDuration','samplePeakDbFS','clippedSamples','loudness']},indent=2))
