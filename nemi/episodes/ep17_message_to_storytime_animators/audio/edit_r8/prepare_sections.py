"""Cut only thought-boundary silences from coherent takes; no voice processing."""
from pathlib import Path
import json
import hashlib
import sys
import numpy as np
import soundfile as sf
ROOT = Path(__file__).resolve().parents[5]
JOBS = {
    'nemi': {
        'folder':ROOT/'nemi/episodes/ep17_message_to_storytime_animators/audio/edit_r8',
        'take':'take_b_full',
        'bounds': [('hook',0.00,2.68,0.00),('name',2.74,4.19,3.20),('identity',4.25,6.32,5.80),('challenge',6.37,12.64,8.85),('payoff',12.70,17.28,17.70)],
    },
    'adb': {
        'folder':ROOT/'adb/episodes/ep08_message_to_storytime_animators/voice/edit_r8',
        'take':'take_b_full',
        'bounds':[('hook',0.00,2.34,0.00),('name',2.38,4.19,3.10),('identity',4.34,6.53,5.65),('challenge',6.54,11.85,8.90),('payoff',11.88,15.76,18.00)],
    },
}
PREFIX = ''
if '--take-d' in sys.argv:
    PREFIX = 'd_'
    JOBS['nemi']['take'] = 'take_d_full'
    JOBS['nemi']['bounds'] = [('hook',0.00,2.62,0.00),('name',2.74,4.22,3.20),('identity',4.36,6.64,5.80),('challenge',6.80,11.97,9.14),('payoff',12.20,16.48,18.10)]
    JOBS['adb']['take'] = 'take_d_full'
    JOBS['adb']['bounds'] = [('hook',0.00,2.58,0.00),('name',2.62,4.40,3.10),('identity',4.54,6.72,5.80),('challenge',6.72,11.55,9.50),('payoff',11.60,16.08,18.00)]
for author, job in JOBS.items():
    folder=job['folder']; src=folder/(job['take']+'.wav')
    x,sr=sf.read(src)
    words=json.loads(src.with_name(src.stem+'_analysis.json').read_text())['words']
    out=np.zeros(int(sr*25),dtype=x.dtype)
    sections=[]
    for key,start,end,target in job['bounds']:
        y=x[round(start*sr):round(end*sr)].copy()
        # Only a 3ms boundary ramp; all natural within-thought pauses remain.
        n=round(sr*.003);y[:n]*=np.linspace(0,1,n);y[-n:]*=np.linspace(1,0,n)
        path=folder/f'{PREFIX}{key}.wav';sf.write(path,y,sr,subtype='PCM_16')
        section_words=[dict(w, start=round(w['start']-start,4),end=round(w['end']-start,4),timeline_start=round(target+w['start']-start,4),timeline_end=round(target+w['end']-start,4)) for w in words if w['start']>=start-.03 and w['end']<=end+.03]
        at=round(target*sr);out[at:at+len(y)]+=y
        sections.append({'id':key,'source':str(src.relative_to(ROOT)),'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'source_bounds_s':[start,end],'file':str(path.relative_to(ROOT)),'file_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'duration_s':len(y)/sr,'timeline_start':target,'timeline_end':target+len(y)/sr,'tempo':1.0,'words':section_words})
    timeline=folder/f'{PREFIX}narration_25s.wav';sf.write(timeline,out,sr,subtype='PCM_16')
    plan={'author':author,'take':job['take'],'sections':sections,'narration_path':str(timeline.relative_to(ROOT)),'duration_s':25,'sha256':hashlib.sha256(timeline.read_bytes()).hexdigest(),'scope':'Suggested edit timing only; source takes retained; can move thought sections without changing voice. No pitch/formant/EQ changes. 3ms section-edge ramps only.','review':'ASR checked exact script. Emotional listening judgement remains for actual playback; not certified by measurements.'}
    (folder/f'{PREFIX}edit_timeline.json').write_text(json.dumps(plan,indent=2)+'\n')
    print(author, 'suggested phrase slots',[(s['id'],s['timeline_start'],round(s['timeline_end'],3)) for s in sections])
