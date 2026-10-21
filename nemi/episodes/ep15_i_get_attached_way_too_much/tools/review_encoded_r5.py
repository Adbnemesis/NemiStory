"""Read-only encoded R5 media QA with voice/mix waveform evidence; no acoustic claims."""
import hashlib,json,re,subprocess,sys,tempfile
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[4]
EP=ROOT/'nemi/episodes/ep15_i_get_attached_way_too_much'
sys.path.insert(0,str(ROOT/'tools/storytime'))
from audio_mix import mix_audio
S=EP/'scene_r5.json';s=json.loads(S.read_text());M=EP/'renders/NEMI_EP15_I_Get_Attached_Way_Too_Much_r5_1080p_REVIEW.mp4'
if not M.is_file():raise SystemExit('Full R5 export is not present; run after normal renderer completes.')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(M)]))
full=subprocess.run(['ffmpeg','-hide_banner','-i',str(M),'-af','ebur128=peak=true','-f','null','-'],capture_output=True,text=True)
summary=full.stderr.rsplit('Summary:',1)[-1]
lufs=float(re.search(r'I:\s*([-\d.]+) LUFS',summary)[1]);tp=float(re.search(r'Peak:\s*([-\d.]+) dBFS',summary)[1])
errors=[l for l in full.stderr.splitlines() if re.search(r'error|invalid|corrupt|non.monoton',l,re.I)]
def decode(path):return np.frombuffer(subprocess.check_output(['ffmpeg','-v','error','-i',str(path),'-f','f32le','-ac','1','-ar','48000','-']),dtype=np.float32).astype(float)
a=decode(M)
with tempfile.TemporaryDirectory(prefix='ep15-encoded-r5-') as tmp:
 reference=mix_audio(s,ROOT,Path(tmp)/'mix.wav',floating=True);b=decode(reference)
 n=min(len(a),len(b));a=a[:n];b=b[:n]
 corr=float(np.corrcoef(a,b)[0,1]);err=float(np.sqrt(np.mean((a-b)**2))/np.sqrt(np.mean(b*b)))
 vp=ROOT/s['audio'].removeprefix('res://');v=decode(vp)[:n]
 n=min(n,len(v));a=a[:n];b=b[:n];v=v[:n]
 mask=np.ones(n,dtype=bool)
 for cue in s['sfx']:
  mask[max(0,round((cue['at']-.15)*48000)):min(n,round((cue['at']+cue['duration']+.2)*48000))]=False
 mask &= np.abs(v)>.001
 av=a[mask];vv=v[mask];gain=float(np.dot(av,vv)/np.dot(vv,vv));vcorr=float(np.corrcoef(av,vv)[0,1]);vnr=float(np.sqrt(np.mean((av-vv*gain)**2))/np.sqrt(np.mean((vv*gain)**2)))
metadata=json.loads((ROOT/s['audio_metadata'].removeprefix('res://')).read_text())
actualsha=sha(vp);assert actualsha==metadata['audio_sha256']
video=next(x for x in probe['streams'] if x['codec_type']=='video');audio=next(x for x in probe['streams'] if x['codec_type']=='audio')
assert full.returncode==0 and not errors,errors
assert int(video['nb_read_frames'])==round(s['duration']*s['fps'])
assert (video['width'],video['height'])==(1920,1080)
assert tp<=-1
assert corr>.98 and vcorr>.98,(corr,vcorr)
out=dict(movie=str(M.relative_to(ROOT)),movie_sha256=sha(M),scene_sha256=sha(S),duration_seconds=float(probe['format']['duration']),video=dict(codec=video['codec_name'],width=video['width'],height=video['height'],fps=video['avg_frame_rate'],frames=int(video['nb_read_frames'])),audio=dict(codec=audio['codec_name'],sample_rate=audio['sample_rate'],channels=audio['channels'],integrated_lufs=lufs,true_peak_dbfs=tp),full_decode=dict(returncode=full.returncode,errors=errors),waveform=dict(encoded_vs_fresh_shared_float_mix_correlation=corr,normalized_rms_error=err,voice_only_mask_samples=int(mask.sum()),encoded_vs_r5_voice_correlation=vcorr,fitted_source_to_export_gain_db=float(20*np.log10(abs(gain))),voice_only_normalized_rms_error=vnr,voice_sha256=actualsha,timing_metadata_audio_sha256=metadata['audio_sha256'],source_hash_matches=True),review_status='Numeric encoded QA passed; no perceptual listening claimed.',method='FFprobe full frame count; FFmpeg full video/audio decode and EBU R128 truepeak. Mono48k float decode compared with fresh unchanged shared mix; voice-only comparison excludes everySFX interval±padding and uses abs(source)>0.001. AAC lossy waveform differences expected. Hash pins exact R5 narration; no media rewritten.')
P=EP/'review/audio/encoded_r5.json';P.write_text(json.dumps(out,indent=2)+'\n')
q=EP/'review/audio/sfx_prominence_r5.json';prior=json.loads(q.read_text());prior['encoded_movie_audio']=out['audio'];prior['encoded_movie_sha256']=out['movie_sha256'];prior['encoded_review_record']='review/audio/encoded_r5.json';q.write_text(json.dumps(prior,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k not in ['method','waveform']},indent=2));print(json.dumps(out['waveform'],indent=2))
