"""Independent decoded-mux checks; no regeneration or perceptual claim.

The AAC elementary-stream hash allows reuse of audio QA for a picture-only R9.
"""
from pathlib import Path
import sys
import os
os.environ['HF_HUB_OFFLINE']='1'
import json
import hashlib
import argparse
import subprocess
import re
import math
from difflib import SequenceMatcher
import numpy as np
import soundfile as sf
from scipy import signal
ROOT=Path(__file__).resolve().parents[6]

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(args):return subprocess.run(args,capture_output=True,text=True,check=True)
def norm_words(words):
    out=[]
    for w in words:
        norm=re.sub('[^a-z0-9]','',w['word'].lower().replace('’',"'"))
        if norm:out.append(dict(w,normalized=norm))
    i=0;combined=[]
    while i<len(out):
        if [w['normalized'] for w in out[i:i+3]]==['a','d','b']:
            combined.append(dict(out[i],word='A D B',normalized='adb',end=out[i+2]['end']));i+=3
        else:combined.append(out[i]);i+=1
    return combined

parser=argparse.ArgumentParser();parser.add_argument('--revision',default='R8');parser.add_argument('--asr',action='store_true');args=parser.parse_args()
JOBS=[('nemi',ROOT/'nemi/episodes/ep17_message_to_storytime_animators','Nemi','audio/edit_r8'),('adb',ROOT/'adb/episodes/ep08_message_to_storytime_animators','ADB','voice/edit_r8')]
for author,episode,title,voice_rel in JOBS:
    video=episode/'renders'/f'{title}_Message_EDIT_{args.revision}_1080p.mp4'
    folder=episode/'review/edit_r8/audio';folder.mkdir(parents=True,exist_ok=True)
    tag=args.revision.lower();mix=episode/voice_rel/'mix_r8.wav';words_file=episode/voice_rel/'final_words.json';receipt=json.loads((episode/voice_rel/'FINAL_MIX_PROVENANCE.json').read_text())
    assert sha(mix)==receipt['output']['sha256']
    assert sha(words_file)==receipt['semantic_words']['sha256']
    probe=json.loads(run(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(video)]).stdout)
    (folder/f'{tag}_ffprobe.json').write_text(json.dumps(probe,indent=2)+'\n')
    decoded=folder/f'{tag}_mux_decoded.wav'
    run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(video),'-map','0:a:0','-c:a','pcm_s24le',str(decoded)])
    aac=folder/f'{tag}_audio_stream.aac'
    run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(video),'-map','0:a:0','-c:a','copy','-f','adts',str(aac)])
    p=run(['ffmpeg','-hide_banner','-nostdin','-i',str(decoded),'-af','loudnorm=I=-18:TP=-1.5:LRA=11:print_format=json','-f','null','-'])
    measured=json.loads(re.findall(r'\{\s*"input_i".*?\}',p.stderr,re.S)[-1])
    levels={'integrated_lufs':float(measured['input_i']),'true_peak_dbtp':float(measured['input_tp']),'loudness_range_lu':float(measured['input_lra']),'threshold_lufs':float(measured['input_thresh'])}
    x,sr=sf.read(mix);y,ysr=sf.read(decoded);assert sr==ysr==48000
    n=min(len(x),len(y));xx=x[:n];yy=y[:n];error=yy-xx
    corr=float(np.corrcoef(xx.ravel(),yy.ravel())[0,1])
    snr=10*np.log10(np.sum(xx*xx)/max(np.sum(error*error),1e-20))
    mx=xx.mean(axis=1)[::6];my=yy.mean(axis=1)[::6]
    cc=signal.correlate(my,mx,mode='full',method='fft');lags=signal.correlation_lags(len(my),len(mx),'full');mask=np.abs(lags)<=400
    lag=int(lags[mask][np.argmax(cc[mask])])
    audio_stream=next(s for s in probe['streams'] if s['codec_type']=='audio');video_stream=next(s for s in probe['streams'] if s['codec_type']=='video')
    expected=json.loads(words_file.read_text())['words']
    result={
        'author':author,'video':str(video.relative_to(ROOT)),'video_sha256':sha(video),'revision':args.revision,
        'source_mix':{'path':str(mix.relative_to(ROOT)),'sha256':sha(mix),'expected_receipt_sha256':receipt['output']['sha256'],'receipt_match':True},
        'source_words':{'path':str(words_file.relative_to(ROOT)),'sha256':sha(words_file),'expected_receipt_sha256':receipt['semantic_words']['sha256'],'receipt_match':True,'final_spoken_word_expected_end_s':expected[-1]['end']},
        'mux_audio':{'codec':audio_stream['codec_name'],'sample_rate':audio_stream['sample_rate'],'channels':audio_stream['channels'],'stream_start_time':audio_stream.get('start_time'),'container_stream_duration_s':float(audio_stream.get('duration',0)),'decoded_frames':len(y),'decoded_duration_s':len(y)/ysr,'decoded_pcm_sha256':sha(decoded),'elementary_aac_sha256':sha(aac),'aac_reuse_note':'If R9 has exactly this ADTS elementary-stream hash and identical stream start/duration, decoded audio/ASR/level results can be reused for that picture-only revision.'},
        'picture_timing':{'duration_s':float(video_stream.get('duration',0)),'fps':video_stream.get('avg_frame_rate'),'frames':video_stream.get('nb_frames'),'size':[video_stream['width'],video_stream['height']]},
        'decoded_levels':levels,
        'source_waveform_comparison':{'comparison_frames':n,'correlation':corr,'signal_to_codec_error_db':float(snr),'max_absolute_pcm_error':float(np.max(np.abs(error))),'timing_offset_at_8khz_samples':lag,'timing_offset_s':lag/8000,'decoded_padding_frames_after_25s':max(0,len(y)-1200000),'method':'Zero-lag waveform comparison plus independent +/-50ms cross-correlation search at 8 kHz. AAC is lossy; byte identity to the PCM mix is not expected.'},
        'verification_limits':'Decoded waveform/codec, ASR, timing and loudness checks are technical evidence only. No audible emotional/naturalness/listening approval is claimed.'
    }
    assert corr>.98 and abs(lag)<=1
    assert levels['true_peak_dbtp']<=-1.49
    assert abs(float(video_stream['duration'])-25)<.001
    assert abs(float(audio_stream['duration'])-25)<.03
    if args.asr:
        import mlx_whisper
        asr=mlx_whisper.transcribe(str(decoded),path_or_hf_repo='mlx-community/whisper-large-v3-turbo',language='en',word_timestamps=True,verbose=False,initial_prompt='Nemi. A D B. Storytime animators.')
        (folder/f'{tag}_mux_asr.json').write_text(json.dumps(asr,indent=2)+'\n')
        actual=[w for s in asr['segments'] for w in s.get('words',[])]
        e=norm_words(expected);a=norm_words(actual)
        em=[w['normalized'] for w in e];am=[w['normalized'] for w in a]
        matcher=SequenceMatcher(a=em,b=am,autojunk=False)
        matches=[];diffs=[]
        for op,i,j,k,l in matcher.get_opcodes():
            if op=='equal':
                for u,v in zip(e[i:j],a[k:l]):matches.append({'word':u['word'],'expected_start':u['start'],'actual_start':v['start'],'start_delta_s':round(v['start']-u['start'],6),'expected_end':u['end'],'actual_end':v['end'],'end_delta_s':round(v['end']-u['end'],6)})
            else:diffs.append({'operation':op,'expected':e[i:j],'recognized':a[k:l]})
        deltas=np.array([m['start_delta_s'] for m in matches])
        result['asr']={'recognized_text':asr['text'],'expected_word_count_after_name_normalization':len(e),'recognized_word_count_after_name_normalization':len(a),'matched_words':len(matches),'differences':diffs,'exact_normalized_sequence_match':em==am,'timing_matches':matches,'median_absolute_word_start_error_s':float(np.median(np.abs(deltas))) if len(deltas) else None,'p95_absolute_word_start_error_s':float(np.percentile(np.abs(deltas),95)) if len(deltas) else None,'maximum_absolute_word_start_error_s':float(np.max(np.abs(deltas))) if len(deltas) else None,'asr_limit':'Approximate ASR boundaries can shift through pauses. Independent waveform zero-lag agreement is stronger evidence of mux synchronization. Proper-name prompt only; no full expected-script prompt was supplied.'}
    (folder/f'{tag}_FINAL_MUX_AUDIO_QA.json').write_text(json.dumps(result,indent=2)+'\n')
    print(author,json.dumps({'levels':levels,'correlation':corr,'snr_db':float(snr),'offset_s':lag/8000,'aac_sha256':sha(aac),'asr':result.get('asr',{}).get('recognized_text'),'exact_asr':result.get('asr',{}).get('exact_normalized_sequence_match')}),flush=True)
