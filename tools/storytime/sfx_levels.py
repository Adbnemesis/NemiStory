"""Measure cue audibility against nearby approved narration; no voice processing."""
import math,subprocess
import numpy as np

def pcm(path,start=0,duration=None):
    cmd=['ffmpeg','-v','error','-ss',str(start),'-i',str(path)]
    if duration is not None:cmd+=['-t',str(duration)]
    return np.frombuffer(subprocess.check_output(cmd+['-ar','16000','-ac','1','-f','f32le','-']),dtype='<f4')
def db(x):return 20*math.log10(max(float(x),1e-9))
def levels(x):return db(np.sqrt(np.mean(x*x))),db(np.max(np.abs(x)))
def choose_gain(asset,voice,at,duration,prominence='accent'):
    clip=pcm(asset,duration=duration);v=voice[max(0,int((at-.25)*16000)):int((at+max(duration,1))*16000)]
    rms,peak=levels(clip);vrms,vpeak=levels(v)
    vrms=max(vrms-2,-30)
    distance={'hero':-4,'accent':-7,'surface':-11}[prominence]
    gain=round(min(-6,max(-20,vrms+distance-rms)),1)
    return gain,{'sfx_rms_dbfs':round(rms+gain,1),'sfx_peak_dbfs':round(peak+gain,1),'nearby_voice_rms_dbfs':round(vrms,1),'relative_rms_db':round(rms+gain-vrms,1),'prominence':prominence}
