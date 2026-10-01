"""Verify exact sound offsets, trimming and narration/SFX gain with known signals."""
import array
import math
import tempfile
from pathlib import Path
import wave
from audio_mix import mix_audio,calibrate_mix,measure_audio

def write(path,duration,start,end):
 rate=48000
 values=array.array('h',(round(.3*32767*math.sin(2*math.pi*500*i/rate)) if start<=i/rate<end else 0 for i in range(round(rate*duration))))
 with wave.open(str(path),'wb') as out:
  out.setparams((1,2,rate,0,'NONE','not compressed'));out.writeframes(values.tobytes())
def rms(values,rate,start,end):
 chunk=values[round(start*rate)*2:round(end*rate)*2]
 return math.sqrt(sum(v*v for v in chunk)/max(1,len(chunk)))/32767
with tempfile.TemporaryDirectory() as folder:
 root=Path(folder);write(root/'voice.wav',1,.1,.18);write(root/'effect.wav',.2,0,.1)
 spec={'duration':1,'audio':'res://voice.wav','sfx':[{'file':'res://effect.wav','at':.5,'duration':.04,'gain_db':-12}]}
 output=mix_audio(spec,root,root/'mixed.wav')
 with wave.open(str(output),'rb') as stream:
  rate=stream.getframerate();duration=stream.getnframes()/rate
  values=array.array('h',stream.readframes(stream.getnframes()))
 assert duration==1
 assert rms(values,rate,0,.08)<.0001
 assert abs(rms(values,rate,.11,.17)-.3/2*10**(-2/20))<.002
 assert rms(values,rate,.45,.49)<.0001
 assert abs(rms(values,rate,.505,.535)-.3/2*10**(-12/20))<.002
 assert rms(values,rate,.56,.7)<.0001
 # An intentionally hot voice and coincident effect must remain below the
 # requested true peak after a constant master gain. No clipping limiter.
 write(root/'hot.wav',1,0,1)
 hot={'duration':1,'audio':'res://hot.wav','sfx':[{'file':'res://hot.wav','at':0,'duration':1,'gain_db':6}]}
 hot['mix']=calibrate_mix(hot,root,target_lufs=-14,peak_dbfs=-6)
 mix_audio(hot,root,root/'safe.wav')
 measured=measure_audio(root/'safe.wav')
 assert measured['true_peak_dbfs']<=-5.85
 # Changing a calibrated mix must be detected instead of silently clipping.
 hot['mix']['master_gain_db']+=8
 try:mix_audio(hot,root,root/'unsafe.wav')
 except ValueError:pass
 else:raise AssertionError('Stale hot master gain accepted')
print('PASS: audio offsets, trim, voice headroom, effect gain and exact duration')
