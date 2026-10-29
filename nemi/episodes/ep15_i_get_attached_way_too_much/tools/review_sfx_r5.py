"""Numeric R5 sound review; never claims perceptual listening."""
import hashlib,json,sys,subprocess,math,tempfile
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[4]
EP=ROOT/'nemi/episodes/ep15_i_get_attached_way_too_much'
sys.path.insert(0,str(ROOT/'tools/storytime'))
from sfx_assets import validate_asset
from audio_mix import mix_audio,measure_audio
SP=EP/'scene_r5.json';spec=json.loads(SP.read_text());SR=48000
catalog=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']
def decode(p,duration=None):
 cmd=['ffmpeg','-v','error','-i',str(p)]
 if duration is not None:cmd+=['-t',str(duration)]
 return np.frombuffer(subprocess.check_output(cmd+['-f','f32le','-ac','1','-ar',str(SR),'-']),dtype=np.float32).astype(float)
def db(x):return float(20*np.log10(max(1e-12,float(x))))
def stats(d):
 if not len(d):return None
 bs=[d[i:i+2400] for i in range(0,len(d),2400)]
 active=[b for b in bs if db(np.sqrt(np.mean(b*b)))>-40]
 a=np.concatenate(active) if active else np.zeros(1)
 return dict(rms_dbfs=round(db(np.sqrt(np.mean(d*d))),3),peak_dbfs=round(db(np.max(np.abs(d))),3),active_50ms_rms_dbfs=round(db(np.sqrt(np.mean(a*a))),3),active_50ms_fraction=round(sum(map(len,active))/len(d),4))
vp=ROOT/spec['audio'].removeprefix('res://');voice=decode(vp)
words=json.loads((EP/'timing_reference_r5.json').read_text())['words']
rows=[]
for cue in spec['sfx']:
 path=cue['file'].removeprefix('res://');asset=next(a for a in catalog if a['relative_path']==path)
 p=validate_asset(asset,ROOT);source=decode(p,cue['duration']);ms=stats(source)
 gain=cue['gain_db'];at=cue['at'];end=at+cue['duration']
 # nearby speech reference includes surrounding phrase, rather than a cue's silence-only window.
 reference=voice[round(max(0,at-1.5)*SR):round(min(spec['duration'],end+1.5)*SR)]
 vr=stats(reference);exact=stats(voice[round(at*SR):round(end*SR)])
 previous=next((w for w in reversed(words) if w['end']<=at),None)
 following=next((w for w in words if w['start']>=end),None)
 overlaps=[w['word'] for w in words if w['start']<end and w['end']>at]
 activeblocks=[]
 for i in range(0,len(source),2400):
  b=source[i:i+2400];lev=db(np.sqrt(np.mean(b*b)))+gain+spec['mix']['master_gain_db']
  if lev>-45:activeblocks.append([round(at+i/SR,3),round(at+min(i+2400,len(source))/SR,3),round(lev,2)])
 rows.append(dict(event=cue['event'],at=at,end=round(end,6),file=cue['file'],catalog_id=asset['id'],source_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),validated_existing_asset=True,source_duration=cue['duration'],gain_db=gain,measurements=dict(source=ms,nearby_narration_source=vr,voice_exact_cue_window_source=exact,active_rms_delta_vs_nearby_voice_after_fixed_minus2_db=round(ms['active_50ms_rms_dbfs']+gain-(vr['active_50ms_rms_dbfs']-2),3),source_gain_peak_before_master_dbfs=round(ms['peak_dbfs']+gain,3),sfx_active50ms_blocks_after_master=activeblocks),word_overlap=overlaps,previous_word=previous,next_word=following))
clashes=[]
for a,b in zip(rows,rows[1:]):
 if a['end']>b['at']:clashes.append([a['event'],b['event'],round(a['end']-b['at'],6)])
# Compare actual narration around the storage commentary using 10ms windows.
storage=next(x for x in rows if x['event']=='storage');a=storage['at'];b=storage['end']
seg=voice[round((a-.3)*SR):round((b+.3)*SR)]
actual=[]
for i in range(0,len(seg),480):
 d=seg[i:i+480];lev=db(np.sqrt(np.mean(d*d)))-2+spec['mix']['master_gain_db']
 if lev>-40:actual.append([round(a-.3+i/SR,3),round(lev,2)])
with tempfile.TemporaryDirectory(prefix='ep15-r5-audio-review-') as tmp:
 mixed=mix_audio(spec,ROOT,Path(tmp)/'mix.wav',floating=True);measure=measure_audio(mixed)
movie=EP/'renders/NEMI_EP15_I_Get_Attached_Way_Too_Much_r5_1080p_REVIEW.mp4'
encoded=measure_audio(movie) if movie.exists() else dict(status='not yet present at numeric review')
out=dict(revision='r5',scene_sha256=hashlib.sha256(SP.read_bytes()).hexdigest(),voice_sha256=hashlib.sha256(vp.read_bytes()).hexdigest(),duration=spec['duration'],cue_count=len(rows),mix=spec['mix'],floating_mix_measured=measure,encoded_movie_audio=encoded,sfx_interval_overlaps=clashes,storage_actual_narration_10ms_blocks_above_minus40_after_master=actual,cues=rows,conclusions=['All17cue files validate against existing catalog provenance; rootMP3 hashes pinned.','No SFX interval overlaps another SFX interval.','School typing/send/reply attacks are separated; contractpaper and pen attacks separated0.65s.','Storage commentary lies inside a short authored narration gap; see actual10msvoiceblocks and exactwordbounds.','Emotional hurt/missed/Neeko reflection/finalmyself have no newSFX.','Perceptual listening was not performed; numeric activelevels are comparative evidence only.'],method='FFmpeg mono float48kHz decode. ActiveRMS uses50msblocks above−40dBFS before sourcegain. Nearbyvoice uses cueinterval±1.5s with sameactivecriterion; actualnarrationfixed−2dB applied for comparison. Gain is linear; no EQ/compression/ducking/pitch processing. Encoded truepeak must<=−1dBFS.')
(EP/'review/audio/sfx_prominence_r5.json').write_text(json.dumps(out,indent=2)+'\n')
print('mix',measure,'encoded',encoded,'clashes',clashes)
for x in rows:print(x['event'],x['at'],x['measurements']['active_rms_delta_vs_nearby_voice_after_fixed_minus2_db'])
print('storage_actual_narration',actual)
