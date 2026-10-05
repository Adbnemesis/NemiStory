"""Independent scheduled-source reconstruction and encoded latency measurement."""
from pathlib import Path
import subprocess,numpy as np
from scipy.signal import correlate,correlation_lags
SR=48000
ROOT=Path(__file__).resolve().parents[1]
def decode(p,start=0,duration=None):
 cmd=['ffmpeg','-v','error','-ss',str(start),'-i',str(p)]
 if duration is not None:cmd+=['-t',str(duration)]
 cmd+=['-vn','-ac','2','-ar',str(SR),'-f','f32le','pipe:1']
 return np.frombuffer(subprocess.check_output(cmd),dtype='<f4').reshape(-1,2).mean(axis=1)
def prepare(c,movie):
 actual=decode(movie);n=min(len(actual),round(c['duration']*SR));actual=actual[:n];stems=[];labels=[]
 for s in ([c['music']] if c.get('music') else [])+c['dialogue']+c['sfx']:
  music='cues' in s;at=0 if music else s['at'];begin=round(round(at,3)*SR)
  if begin>=n:continue
  clip=decode(ROOT/'public'/s['file'],round(s.get('sourceStart',0),3),s['duration']);vec=np.zeros(n);begin=round(round(at,3)*SR);length=min(len(clip),n-begin);vec[begin:begin+length]=clip[:length]*10**(s['gainDb']/20)
  if music:
   times=np.floor(np.arange(n)/SR*c['fps'])/c['fps'];duck=np.zeros(n)
   for w in s['duck']:
    attack=np.clip((times-(w['start']-.1))/.1,0,1);release=np.clip((w['end']+.2-times)/.2,0,1);duck=np.minimum(duck,w['gainDb']*np.minimum(attack,release))
   vec*=10**(duck/20)
  stems.append(vec);labels.append({'id':'music' if music else s['id'],'kind':'music' if music else 'dialogue' if 'text' in s else 'sfx','at':at,'duration':s['duration'],'gainDb':s['gainDb'],'encoderScheduledAt':round(at,3),'encoderSourceStart':round(s.get('sourceStart',0),3),'scheduleRoundingMs':round((round(at,3)-at)*1000,4)})
 return actual,stems,labels

def measure(c,movie):
 actual,stems,labels=prepare(c,movie);expected=np.sum(stems,axis=0);cross=correlate(actual,expected,method='fft');lags=correlation_lags(len(actual),len(expected));mask=np.abs(lags)<=SR*.1;lag=int(lags[mask][np.argmax(cross[mask])]);
 # Sub-sample parabolic interpolation; retained as a measured estimate rather than codec assumption.
 index=int(np.flatnonzero(lags==lag)[0]);left,center,right=cross[index-1:index+2];fraction=float(.5*(left-right)/(left-2*center+right)) if left-2*center+right else 0;seconds=(lag+fraction)/SR
 if lag>=0:target=actual[lag:];matrix=np.stack([s[:len(target)] for s in stems],axis=1)
 else:target=actual[:lag];matrix=np.stack([s[-lag:] for s in stems],axis=1)
 coeff,*_=np.linalg.lstsq(matrix,target,rcond=None);reconstruction=matrix@coeff;corr=float(np.corrcoef(target,reconstruction)[0,1]);residual=float(np.sqrt(np.mean((target-reconstruction)**2)))
 for label,v,stem in zip(labels,coeff,stems):label.update({'rawMixCoefficient':round(float(v),4),'sourceAtExpectedTimeDetected':bool(v>.1),'stemRmsDbFS':round(float(20*np.log10(max(np.sqrt(np.mean(stem**2)),1e-12))),2)})
 return {'delaySeconds':seconds,'sampleRate':SR,'delaySamples':lag+fraction,'reconstructionCorrelation':corr,'residualRms':residual,'stems':labels}
