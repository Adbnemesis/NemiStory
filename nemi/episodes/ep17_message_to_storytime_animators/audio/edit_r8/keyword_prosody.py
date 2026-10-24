"""Compare keyword articulation evidence, without claiming perceived emotion."""
from pathlib import Path
import json
import re
import numpy as np
import soundfile as sf
from scipy import signal
ROOT=Path(__file__).resolve().parents[5]

def word_features(x,sr,start,end,fmin,fmax):
    clip=x[max(0,round(start*sr)):min(len(x),round(end*sr))]
    if clip.ndim>1:clip=clip.mean(axis=1)
    clip=signal.resample_poly(clip,8000,sr)
    rms=float(np.sqrt(np.mean(clip*clip))) if len(clip) else 0
    pitches=[]
    if len(clip)>=320:
        frames=np.lib.stride_tricks.sliding_window_view(clip,320)[::40]
        for frame in frames:
            if np.sqrt(np.mean(frame*frame))<max(.003,rms*.2):continue
            y=frame-frame.mean();ac=signal.correlate(y,y,mode='full',method='fft')[319:];ac/=max(ac[0],1e-10)
            lo,hi=int(8000/fmax),min(160,int(8000/fmin))
            peaks,props=signal.find_peaks(ac[lo:hi],height=.5)
            if not len(peaks):continue
            lags=peaks+lo;vals=ac[lags];c=lags[vals>=max(.55,vals.max()*.9)]
            if len(c):pitches.append(8000/float(c[0]))
    result={'duration_s':end-start,'rms_dbfs':round(20*np.log10(rms+1e-10),2),'f0_median_hz':round(float(np.median(pitches)),1) if pitches else None}
    if len(pitches)>=6:
        result['f0_first_third_hz']=round(float(np.median(pitches[:len(pitches)//3])),1)
        result['f0_final_third_hz']=round(float(np.median(pitches[-len(pitches)//3:])),1)
    return result

def record(path, words, author):
    x,sr=sf.read(path)
    out=[]
    for i,w in enumerate(words):
        clean=re.sub('[^a-z]','',w['word'].lower())
        if clean in ['steal','stealing','jobs','biggest','world','now','dramatic','stories']:
            fmin,fmax=(110,450) if author=='nemi' else (65,350)
            out.append(dict(word=w['word'].strip(),start=w['start'],end=w['end'],**word_features(x,sr,w['start'],w['end'],fmin,fmax)))
    return out

if __name__=='__main__':
    summary={'method':'40ms strong-autocorrelation voiced frames, 5ms hop; speaker-specific ranges. Octave ambiguity remains. RMS is unweighted. These are pitch/energy/duration observations, not a judgement of emotion, naturalness, shouting or source equivalence. Source isolated stem contains separation artifacts.', 'takes':{}}
    for author,folder in [('nemi',ROOT/'nemi/episodes/ep17_message_to_storytime_animators/audio/edit_r8'),('adb',ROOT/'adb/episodes/ep08_message_to_storytime_animators/voice/edit_r8')]:
        for p in sorted(folder.glob('take_*_full_analysis.json')):
            d=json.loads(p.read_text());wav=p.with_name(p.name.replace('_analysis.json','.wav'))
            summary['takes'][author+'_'+wav.stem]=record(wav,d['words'],author)
    ref=ROOT/'renders/message_to_storytime_reference/audio'
    d=json.loads((ref/'reference_whisper_large.json').read_text())
    words=d.get('words') or [w for s in d.get('segments',[]) for w in s.get('words',[])]
    summary['source_reference']=record(ref/'reference_vocals.wav',words,'reference')
    out=ROOT/'nemi/episodes/ep17_message_to_storytime_animators/audio/edit_r8/KEYWORD_PROSODY.json'
    out.write_text(json.dumps(summary,indent=2)+'\n')
    for key,values in summary['takes'].items():
        print(key, json.dumps(values))
    print('reference',json.dumps(summary['source_reference']))
