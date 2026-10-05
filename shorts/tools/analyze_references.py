"""Read-only reference measurements. Candidates are evidence, not editorial facts."""
from pathlib import Path
import hashlib, json, subprocess, math
import cv2
import numpy as np
from scipy.signal import stft, find_peaks
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'shorts/review/references'

def probe(path):
    return json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(path)]))

def audio_measure(path, folder):
    raw = subprocess.check_output(['ffmpeg','-v','error','-i',str(path),'-vn','-ac','1','-ar','22050','-f','f32le','pipe:1'])
    a = np.frombuffer(raw, dtype='<f4')
    _, ts, z = stft(a, fs=22050, nperseg=1024, noverlap=768, boundary=None)
    mag = np.abs(z)
    flux = np.maximum(np.diff(mag, axis=1),0).sum(axis=0)
    flux = np.r_[0,flux]
    flux /= max(float(flux.max()),1e-8)
    peaks, _ = find_peaks(flux, distance=10, prominence=.055)
    onset = [round(float(ts[i]),4) for i in peaks]
    corr = np.correlate(flux-flux.mean(), flux-flux.mean(), 'full')[len(flux)-1:]
    candidates=[]
    cp, _ = find_peaks(corr)
    for lag in cp:
        bpm=60/(lag*256/22050) if lag else 0
        if 65 <= bpm <= 190:
            candidates.append({'bpm':round(bpm,2),'score':round(float(corr[lag]/max(corr[0],1e-8)),3)})
    candidates=sorted(candidates,key=lambda x:x['score'],reverse=True)[:6]
    envelope=[{'time':round(i/10,2),'rms_db':round(20*math.log10(max(float(np.sqrt(np.mean(a[int(i*2205):int((i+1)*2205)]**2))),1e-8)),2)} for i in range(len(a)//2205)]
    im=Image.new('RGB',(1500,280),'#101820'); d=ImageDraw.Draw(im)
    for i in range(1500):
        s=a[int(i*len(a)/1500):max(int((i+1)*len(a)/1500),int(i*len(a)/1500)+1)]
        p=min(120,float(np.max(np.abs(s)))*130)
        d.line((i,140-p,i,140+p),fill='#7befb7')
    for s in onset:
        x=s/(len(a)/22050)*1500; d.line((x,10,x,270),fill='#d18345')
    for t in range(math.ceil(len(a)/22050)):
        x=t/(len(a)/22050)*1500; d.text((x,0),str(t),fill='white')
    im.save(folder/'waveform.jpg')
    subprocess.run(['ffmpeg','-v','error','-y','-i',str(path),'-vn','-ac','2',str(folder/'audio.wav')],check=True)
    return {'bpm_candidates':candidates,'onsets':onset,'rms_100ms':envelope,'peak_dbfs':round(20*math.log10(max(float(np.max(np.abs(a))),1e-8)),2),'method':'STFT positive spectral flux, 11.61ms hop; autocorrelation candidates; mixed audio, not separated stems'}

def analyze(path,index):
    folder=OUT/f'ref{index:02}'; folder.mkdir(parents=True,exist_ok=True)
    pr=probe(path); v=next(s for s in pr['streams'] if s['codec_type']=='video')
    fps=eval(v['avg_frame_rate'],{'__builtins__':{}},{})
    cap=cv2.VideoCapture(str(path)); frames=[]; prev=None; diffs=[]
    frame=0
    while True:
        ok,bgr=cap.read()
        if not ok: break
        small=cv2.resize(bgr,(144,256)); gray=cv2.cvtColor(small,cv2.COLOR_BGR2GRAY)
        diff=float(np.mean(cv2.absdiff(gray,prev))) if prev is not None else 0
        diffs.append(diff); prev=gray
        if frame%max(1,round(fps/2))==0:
            frames.append((frame/fps,Image.fromarray(cv2.cvtColor(bgr,cv2.COLOR_BGR2RGB)).resize((216,384))))
        frame+=1
    cap.release()
    for part in range(math.ceil(len(frames)/24)):
        batch=frames[part*24:(part+1)*24]; im=Image.new('RGB',(6*216,math.ceil(len(batch)/6)*412),'#18202a'); d=ImageDraw.Draw(im)
        for j,(t,pic) in enumerate(batch):
            x=j%6*216;y=j//6*412;im.paste(pic,(x,y+28));d.text((x+6,y+6),f'{t:.3f}s',fill='white')
        im.save(folder/f'contact_{part+1}.jpg')
    peaks,_=find_peaks(np.array(diffs),height=10,prominence=6,distance=max(1,int(fps*.08)))
    repeated=[i for i,x in enumerate(diffs) if i and x<.05]
    data={'id':f'ref{index:02}','file':str(path.relative_to(ROOT)),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'duration':float(pr['format']['duration']),'width':v['width'],'height':v['height'],'fps':fps,'decoded_frames':frame,'candidate_changes':[{'frame':int(i),'time':round(i/fps,4),'mean_luma_diff':round(diffs[i],2)} for i in peaks],'duplicate_frame_fraction':round(len(repeated)/max(frame-1,1),4),'audio':audio_measure(path,folder)}
    (folder/'measurements.json').write_text(json.dumps(data,indent=2))
    np.savetxt(folder/'frame_differences.csv',np.c_[np.arange(frame),np.arange(frame)/fps,diffs],delimiter=',',header='frame,time,mean_luma_diff',comments='')
    print(json.dumps({k:data[k] for k in ['id','file','duration','width','height','fps','decoded_frames','duplicate_frame_fraction','candidate_changes']}))
    print('audio',data['audio']['bpm_candidates'],'onsets',data['audio']['onsets'])
    return data

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    items=[analyze(p,i+1) for i,p in enumerate(sorted((ROOT/'references/shorts_ref').glob('*.mp4')))]
    (OUT/'manifest.json').write_text(json.dumps([{k:x[k] for k in ['id','file','sha256','duration','width','height','fps']} for x in items],indent=2))
