"""External edit audio: coherent retakes, source-matched rests and measured mix.

No synthesis, pitch/formant/EQ changes or generated SFX. All master processing
is one constant gain. Every source bound and hash is retained in the receipt.
"""
from pathlib import Path
import json
import hashlib
import math
import re
import subprocess
import numpy as np
import soundfile as sf
from scipy import signal
ROOT=Path(__file__).resolve().parents[5]
SR=48000
CAP=25.0
MUSIC=ROOT/'renders/message_to_storytime_reference/audio/reference_music_bed_hybrid.wav'
JOBS={
    'nemi': {
        'episode':ROOT/'nemi/episodes/ep17_message_to_storytime_animators',
        'folder':ROOT/'nemi/episodes/ep17_message_to_storytime_animators/audio/edit_r8',
        'sections':[
            ('hook','b',0.00,2.533333,0.00),
            ('name','b',2.74,4.19,3.30),
            ('identity','b',4.25,6.21,5.64),
            ('challenge','d',6.80,11.97,9.14),
            ('payoff','b',12.70,17.10,17.70),
        ],
    },
    'adb': {
        'episode':ROOT/'adb/episodes/ep08_message_to_storytime_animators',
        'folder':ROOT/'adb/episodes/ep08_message_to_storytime_animators/voice/edit_r8',
        'sections':[
            ('hook','b',0.00,2.34,0.00),
            ('name','b',2.38,4.19,3.10),
            ('identity','b',4.34,6.49,5.45),
            ('challenge','d',6.72,11.55,9.45),
            ('payoff','b',11.88,15.58,18.40),
        ],
    },
}

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def dbfs_peak(x):return 20*math.log10(max(float(np.max(np.abs(x))),1e-12))
def read_resampled(path):
    x,sr=sf.read(path,dtype='float64')
    if sr!=SR:
        g=math.gcd(sr,SR);x=signal.resample_poly(x,SR//g,sr//g,axis=0)
    return x
def loudness(path):
    args=['ffmpeg','-hide_banner','-nostdin','-i',str(path),'-af','loudnorm=I=-18:TP=-1.5:LRA=11:print_format=json','-f','null','-']
    p=subprocess.run(args,capture_output=True,text=True,check=True)
    matches=re.findall(r'\{\s*"input_i".*?\}',p.stderr,flags=re.S)
    if not matches:raise RuntimeError(p.stderr[-2500:])
    return json.loads(matches[-1])

music=read_resampled(MUSIC)
assert music.ndim==2 and music.shape[1]==2
music=music[:round(CAP*SR)]
assert len(music)==round(CAP*SR)

for author,job in JOBS.items():
    folder=job['folder'];narr=np.zeros(round(CAP*SR),dtype=np.float64)
    sections=[];final_words=[];windows=[]
    for key,take,start,end,target in job['sections']:
        src=folder/f'take_{take}_full.wav'
        original,original_sr=sf.read(src,dtype='float64')
        y=original[round(start*original_sr):round(end*original_sr)].copy()
        edge_n=round(.003*original_sr)
        y[:edge_n]*=np.linspace(0,1,edge_n)
        y[-edge_n:]*=np.linspace(1,0,edge_n)
        if original_sr!=SR:
            g=math.gcd(original_sr,SR);y=signal.resample_poly(y,SR//g,original_sr//g)
        at=round(target*SR);assert at+len(y)<=len(narr)
        narr[at:at+len(y)]+=y
        alignment=json.loads(src.with_name(src.stem+'_analysis.json').read_text())
        words=[w for w in alignment['words'] if w['start']>=start-.03 and w['end']<=end+.03]
        timeline_words=[]
        for w in words:
            item={'word':w['word'].strip(),'start':round(target+w['start']-start,6),'end':round(target+w['end']-start,6),'source_start':w['start'],'source_end':w['end'],'source_take':take,'section':key,'probability':w.get('probability')}
            assert item['start']>=-.001 and item['end']<=CAP
            timeline_words.append(item);final_words.append(item)
        window=[timeline_words[0]['start'],timeline_words[-1]['end']]
        windows.append(window)
        sections.append({'id':key,'take':take,'source':str(src.relative_to(ROOT)),'source_sha256':sha(src),'source_bounds_s':[start,end],'timeline_start':target,'timeline_end':round(target+len(y)/SR,6),'spoken_window_s':window,'words':timeline_words,'tempo':1.0,'processing':'3 ms boundary ramps, 24-to-48 kHz polyphase resampling; no pitch/formant/EQ changes.'})
    # Voice balance is one constant gain for the entire assembled narration.
    voice_gain_db=-6-dbfs_peak(narr)
    narr*=10**(voice_gain_db/20)
    t=np.arange(len(music))/SR
    duck_db=np.zeros(len(music),dtype=np.float64)
    for start,end in windows:
        attack=np.clip((t-(start-.05))/.05,0,1)
        release=np.clip(((end+.08)-t)/.08,0,1)
        strength=np.minimum(attack,release)
        duck_db=np.minimum(duck_db,-24*strength)
    ducked=music*10**(duck_db[:,None]/20)
    premaster=ducked+narr[:,None]
    pre=folder/'mix_r8_premaster.wav';sf.write(pre,premaster,SR,subtype='PCM_24')
    measurement=loudness(pre)
    target_gain=-18-float(measurement['input_i'])
    tp_limit_gain=-1.5-float(measurement['input_tp'])
    master_gain_db=min(target_gain,tp_limit_gain)
    master=10**(master_gain_db/20)
    mix=premaster*master
    mix_path=folder/'mix_r8.wav';sf.write(mix_path,mix,SR,subtype='PCM_24')
    narration_path=folder/'final_narration_edited.wav';sf.write(narration_path,narr*master,SR,subtype='PCM_24')
    measured_final=loudness(mix_path)
    assert float(measured_final['input_tp'])<=-1.49
    assert sf.info(mix_path).frames==round(CAP*SR)
    words_path=folder/'final_words.json'
    words_path.write_text(json.dumps({'author':author,'scene_clock':'seconds','duration_s':CAP,'words':final_words,'alignment':'Large-v3-turbo word times mapped from selected final sources; source words retained. Boundaries approximate, not phoneme timings.'},indent=2)+'\n')
    record={
        'author':author,'duration_s':CAP,'sample_rate':SR,'channels':2,
        'sections':sections,'narration':{'path':str(narration_path.relative_to(ROOT)),'sha256':sha(narration_path),'channels':1,'pre_master_peak_target_dbfs':-6,'constant_balance_gain_db':voice_gain_db},
        'music':{'path':str(MUSIC.relative_to(ROOT)),'sha256':sha(MUSIC),'source_gain_db':0,'source_peak_dbfs':dbfs_peak(music),'provenance':'Existing model-separated supplied reference soundtrack with original narrator-free musical windows restored; exact 25 s source clock retained. No original narration used as new dialogue.','ducking':{'reduction_db':-24,'attack_s':.05,'release_s':.08,'windows_s':windows,'envelope':'linear dB ramps, minimum of overlapping windows, held throughout each actual spoken thought interval'}},
        'sfx':{'additional_cues':[],'note':'No extra synthesized or library effects added. The supplied soundtrack accents remain. Additional paper/prop cues require matching visible contact events from the final editor.'},
        'master':{'method':'One constant gain; no limiter, compressor, EQ, pitch or formant changes. Gain is limited by true-peak headroom when needed.','target_integrated_lufs':-18,'true_peak_limit_dbtp':-1.5,'premaster_ffmpeg_measurement':measurement,'constant_gain_db':master_gain_db,'headroom_limited':tp_limit_gain<target_gain,'final_ffmpeg_measurement':measured_final},
        'output':{'path':str(mix_path.relative_to(ROOT)),'sha256':sha(mix_path),'frames':len(mix),'duration_s':len(mix)/SR},
        'semantic_words':{'path':str(words_path.relative_to(ROOT)),'sha256':sha(words_path)},
        'perceptual_review':'No listening claim. ASR, hashes, durations, silence arrangement, level and true-peak measurements are technical evidence only; they do not certify audible emotional quality.'
    }
    (folder/'FINAL_MIX_PROVENANCE.json').write_text(json.dumps(record,indent=2)+'\n')
    edit_folder=job['episode']/'edit_rebuild';edit_folder.mkdir(exist_ok=True)
    (edit_folder/'sound_timeline.json').write_text(json.dumps(record,indent=2)+'\n')
    print(author,{'mix':str(mix_path),'integrated_lufs':measured_final['input_i'],'true_peak_dbtp':measured_final['input_tp'],'master_gain_db':master_gain_db,'headroom_limited':tp_limit_gain<target_gain,'words':len(final_words)},flush=True)
