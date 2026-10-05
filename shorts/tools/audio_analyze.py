"""Offline onset/tempo/energy analysis. Output is draft until editorial review."""
from pathlib import Path
import sys,argparse,json,hashlib,subprocess
import numpy as np
from scipy.signal import stft,find_peaks

def analyze(path,start=0,duration=None,bpm=None,offset=None):
 if start<0 or (duration is not None and duration<=0) or (bpm is not None and bpm<=0):raise ValueError('Invalid segment/tempo')
 args=['ffmpeg','-v','error','-ss',str(start),'-i',str(path)]
 if duration is not None: args+=['-t',str(duration)]
 raw=subprocess.check_output(args+['-vn','-ac','1','-ar','22050','-f','f32le','pipe:1'])
 a=np.frombuffer(raw,dtype='<f4')
 if len(a)<22050: raise ValueError('Need at least one second of audio')
 _,t,z=stft(a,fs=22050,nperseg=1024,noverlap=768,boundary=None)
 flux=np.r_[0,np.maximum(np.diff(np.abs(z),axis=1),0).sum(axis=0)];flux/=max(flux.max(),1e-9)
 p,_=find_peaks(flux,distance=8,prominence=.065)
 onset=t[p];corr=np.correlate(flux-flux.mean(),flux-flux.mean(),'full')[len(flux)-1:]
 lags,_=find_peaks(corr);candidates=[]
 for lag in lags:
  v=60/(lag*256/22050) if lag else 0
  if 65<=v<=190: candidates.append({'bpm':round(v,2),'score':round(float(corr[lag]/max(corr[0],1e-9)),4)})
 candidates.sort(key=lambda v:v['score'],reverse=True)
 if not candidates and bpm is None:raise ValueError('No reliable pulse candidate; supply an editorial --bpm or choose another source')
 pulse=bpm or candidates[0]['bpm'];interval=60/pulse
 if offset is None:
  choices=np.linspace(0,interval,300,endpoint=False)
  scores=[np.interp(np.arange(x,len(a)/22050,interval),t,flux).mean() for x in choices]
  offset=float(choices[int(np.argmax(scores))])
 beats=np.arange(offset,len(a)/22050,interval)
 result={'version':1,'sourceHash':hashlib.sha256(Path(path).read_bytes()).hexdigest(),'sourceFile':str(path),'sourceStart':start,'duration':len(a)/22050,'rate':1,'bpm':pulse,'offset':offset,'status':'draft','confidence':'pulse candidate; metrical phase needs review','tempoCandidates':candidates[:5],'beats':np.round(beats,4).tolist(),'strongBeats':[],'drops':[],'phrases':[],'choruses':[],'accents':[],'onsets':np.round(onset,4).tolist(),'peaks':np.round(t[p[flux[p]>.6]],4).tolist(),'energy':[{'time':round(i/10,2),'rms':round(float(np.sqrt(np.mean(a[i*2205:(i+1)*2205]**2))),5)} for i in range(len(a)//2205)],'method':'Scipy STFT spectral flux + pulse autocorrelation, 11.61ms hop; no automatic downbeat/drop inference'}
 return result
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('file');p.add_argument('output');p.add_argument('--start',type=float,default=0);p.add_argument('--duration',type=float);p.add_argument('--bpm',type=float);p.add_argument('--offset',type=float);a=p.parse_args()
 output=Path(a.output);output.parent.mkdir(parents=True,exist_ok=True);output.write_text(json.dumps(analyze(a.file,a.start,a.duration,a.bpm,a.offset),indent=2));print(output)
