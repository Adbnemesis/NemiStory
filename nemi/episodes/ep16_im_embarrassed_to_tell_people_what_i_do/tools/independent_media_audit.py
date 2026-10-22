#!/usr/bin/env python3
"""Independent exact-file storytime audit. Numeric evidence is not listening.

Run from the repository root.
Usage: python3 <episode>/tools/independent_media_audit.py --spec <scene.json> --movie <mp4>
       --out <episode/review/independent_r1> [--start 0] [--cap 180] [--stills]
"""
import argparse, hashlib, json, math, subprocess, sys, tempfile
from pathlib import Path
import numpy as np
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--spec',type=Path,required=True);p.add_argument('--movie',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);p.add_argument('--start',type=float,default=0)
p.add_argument('--root',type=Path,default=Path.cwd(),help='Repository root; defaults to current directory')
p.add_argument('--cap',type=float,default=180);p.add_argument('--stills',action='store_true')
a=p.parse_args();root=a.root.resolve();sys.path.insert(0,str(root/'tools/storytime'))
from audio_mix import measure_audio,mix_audio
from render_approval import render_inputs_sha256
from sfx_assets import validate_asset
scene_bytes=a.spec.read_bytes();s=json.loads(scene_bytes);movie=a.movie.resolve();out=a.out.resolve()
if out.exists() and (out/'INDEPENDENT_QA.json').exists():raise SystemExit('QA already exists; use a new revision folder.')
out.mkdir(parents=True,exist_ok=True)
sha=lambda q:hashlib.sha256(Path(q).read_bytes()).hexdigest()
def run(cmd):return subprocess.check_output(cmd)
def decode(path,start=None,duration=None):
 cmd=['ffmpeg','-v','error']
 if start is not None:cmd+=['-ss',str(start)]
 cmd+=['-i',str(path)]
 if duration is not None:cmd+=['-t',str(duration)]
 return np.frombuffer(run(cmd+['-f','f32le','-ac','1','-ar','48000','-']),dtype=np.float32).astype(float)
def db(x):return round(float(20*np.log10(max(1e-12,float(x)))),4)
def stats(x):
 if not len(x):return None
 blocks=[x[i:i+2400] for i in range(0,len(x),2400)]
 active=[b for b in blocks if np.sqrt(np.mean(b*b))>0.01]
 y=np.concatenate(active) if active else np.zeros(1)
 return dict(rms_dbfs=db(np.sqrt(np.mean(x*x))),peak_dbfs=db(np.max(np.abs(x))),active_50ms_rms_dbfs=db(np.sqrt(np.mean(y*y))),active_50ms_fraction=round(sum(map(len,active))/len(x),5))
probe=json.loads(run(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(movie)]))
v=next(x for x in probe['streams'] if x['codec_type']=='video');au=next(x for x in probe['streams'] if x['codec_type']=='audio')
duration=float(probe['format']['duration']);expected=round(duration*s['fps'])
assert (v['width'],v['height'])==(1920,1080),(v['width'],v['height'])
assert duration<=a.cap+1e-6,duration
assert int(v['nb_read_frames'])==expected,(v['nb_read_frames'],expected)
assert abs(float(v['avg_frame_rate'].split('/')[0])/float(v['avg_frame_rate'].split('/')[1])-s['fps'])<1e-6
if a.start==0 and abs(duration-s['duration'])<1/s['fps']:full=True
else:full=False
result=subprocess.run(['ffmpeg','-v','error','-i',str(movie),'-f','null','-'],capture_output=True,text=True)
assert result.returncode==0 and not result.stderr.strip(),result.stderr
stamp_path=movie.with_suffix('.review_stamp.json')
if not stamp_path.exists():stamp_path=a.spec.parent/'review/render_records'/stamp_path.name
stamp=json.loads(stamp_path.read_text());assert stamp['preview_sha256']==sha(movie)
assert stamp['spec_sha256']==sha(a.spec)
assert stamp['render_inputs_sha256']==render_inputs_sha256(a.spec.resolve(),root)
assert abs(stamp['start']-a.start)<1e-6
assert abs(stamp['duration']-duration)<1/s['fps']
assert stamp['resolution']==[1920,1080]
measure=measure_audio(movie);assert measure['true_peak_dbfs']<=-1,measure
voice_path=root/s['audio'].removeprefix('res://');voice=decode(voice_path)
metadata=json.loads((root/s['audio_metadata'].removeprefix('res://')).read_text())
assert metadata['audio_sha256']==sha(voice_path)
encoded=decode(movie)
with tempfile.TemporaryDirectory(prefix='nemi-independent-mix-') as tmp:
 reference=mix_audio(s,root,Path(tmp)/'mix.wav',floating=True)
 fresh=decode(reference,start=a.start,duration=duration)
 n=min(len(encoded),len(fresh));x=encoded[:n];y=fresh[:n]
 correlation=float(np.corrcoef(x,y)[0,1]);relative_error=float(np.sqrt(np.mean((x-y)**2))/max(1e-12,np.sqrt(np.mean(y*y))))
 assert correlation>.98,correlation
 voice_window=voice[round(a.start*48000):round((a.start+duration)*48000)]
 n=min(len(x),len(voice_window));x=x[:n];voice_window=voice_window[:n]
 mask=np.abs(voice_window)>.001
 for cue in s.get('sfx',[]):
  lo=max(0,round((cue['at']-a.start-.15)*48000));hi=min(n,round((cue['at']-a.start+cue['duration']+.2)*48000))
  if hi>lo:mask[lo:hi]=False
 if mask.any():
  actual=x[mask];expected_voice=voice_window[mask];gain=float(np.dot(actual,expected_voice)/np.dot(expected_voice,expected_voice));voice_corr=float(np.corrcoef(actual,expected_voice)[0,1]);assert voice_corr>.98,voice_corr
 else:gain=voice_corr=None
catalog=json.loads((root/'common/audio/sfx/sfx_catalog.json').read_text())['assets'];by_path={r['relative_path']:r for r in catalog};cues=[]
for cue in s.get('sfx',[]):
 source_path=cue['file'].removeprefix('res://');asset=by_path[source_path];path=validate_asset(asset,root)
 source=decode(path,duration=cue['duration']);source_stats=stats(source)
 lo=max(0,round((cue['at']-1.5)*48000));hi=min(len(voice),round((cue['at']+cue['duration']+1.5)*48000));vs=stats(voice[lo:hi]);delta=round(source_stats['active_50ms_rms_dbfs']+cue['gain_db']-(vs['active_50ms_rms_dbfs']-2),3)
 cues.append(dict(event=cue['event'],at=cue['at'],end=cue['at']+cue['duration'],file=cue['file'],catalog_id=asset['id'],sha256=sha(path),gain_db=cue['gain_db'],source=source_stats,nearby_voice=vs,active_rms_db_relative_to_nearby_voice=delta))
overlaps=[]
for i,first in enumerate(cues):
 for second in cues[i+1:]:
  overlap=min(first['end'],second['end'])-max(first['at'],second['at'])
  if overlap>0:overlaps.append([first['event'],second['event'],round(overlap,6)])
times=set([.2,max(.2,duration-.2)])
for shot in s.get('shots',[]):
 for t in [shot['start']+.2,(shot['start']+shot['end'])/2,shot['end']-.1]:
  if a.start<=t<a.start+duration:times.add(round(t-a.start,3))
for actor in s.get('actors',[]):
 for boundary in actor.get('hand_path_window',[]):
  for t in [boundary-.05,boundary+.05]:
   if a.start<=t<a.start+duration:times.add(round(t-a.start,3))
for prop in s.get('props',[]):
 if prop.get('attach'):
  for boundary in [prop.get('attach_start',prop['at']),prop.get('attach_end',prop['end'])]:
   for t in [boundary-.05,boundary+.05]:
    if a.start<=t<a.start+duration:times.add(round(t-a.start,3))
stills=[]
if a.stills:
 from PIL import Image,ImageDraw
 thumbs=[]
 for i,t in enumerate(sorted(times)):
  target=out/f'frame_{i:03d}_{t+a.start:07.3f}s.jpg';subprocess.run(['ffmpeg','-v','error','-y','-ss',str(t),'-i',str(movie),'-frames:v','1','-q:v','2',str(target)],check=True)
  stills.append(dict(file=target.name,scene_time=t+a.start));thumbs.append(Image.open(target).resize((640,360)))
 for offset in range(0,len(thumbs),8):
  ims=thumbs[offset:offset+8];sheet=Image.new('RGB',(1280,385*math.ceil(len(ims)/2)),'white');draw=ImageDraw.Draw(sheet)
  for i,im in enumerate(ims):
   x=(i%2)*640;y=(i//2)*385;sheet.paste(im,(x,y));draw.text((x+8,y+364),f"{stills[offset+i]['scene_time']:.3f}s",fill='black')
  sheet.save(out/f'contact_{offset//8+1:02d}.jpg',quality=94)
qa=dict(voice_generation_runtime_sha256={p:sha(root/p) for p in ['tools/tts/config.py','tools/tts/engine.py']},voice_runtime_provenance_record='../audio/GENERATION_RUNTIME.json',movie=str(movie),movie_sha256=sha(movie),scene=str(a.spec.resolve()),scene_sha256=sha(a.spec),full_episode=full,window_start=a.start,duration_seconds=duration,video=dict(width=v['width'],height=v['height'],fps=v['avg_frame_rate'],decoded_frames=int(v['nb_read_frames'])),audio=dict(codec=au['codec_name'],sample_rate=au['sample_rate'],channels=au['channels'],**measure),full_decode='passed without decoder diagnostics',exact_current_render_stamp='matches scene, picture/voice inputs, movie and window',voice_sha256=sha(voice_path),waveform=dict(encoded_vs_fresh_mix_correlation=correlation,normalized_rms_error=relative_error,voice_only_correlation=voice_corr,fitted_voice_gain_db=db(abs(gain)) if gain is not None else None),scene_sfx_cue_count=len(cues),window_sfx_cue_count=sum(c['at']<a.start+duration and c['end']>a.start for c in cues),sfx_overlaps=overlaps,sfx_prominence=cues,stills=stills,subjective_visual_review='pending actual inspection of stills and playback',perceptual_audio_listening='unperformed; numeric correlation, truepeak and SFX prominence are evidence only',user_full_1080p_satisfaction='pending',four_k_rendered=False)
assert a.spec.read_bytes()==scene_bytes, 'Scene changed during audit; no QA receipt saved'
assert stamp['render_inputs_sha256']==render_inputs_sha256(a.spec.resolve(),root), 'Inputs changed during audit; no QA receipt saved'
(out/'scene_at_audit.json').write_bytes(scene_bytes)
qa['scene_snapshot']='scene_at_audit.json'
(out/'INDEPENDENT_QA.json').write_text(json.dumps(qa,indent=2)+'\n')
print(json.dumps({k:qa[k] for k in ['full_episode','duration_seconds','video','audio','waveform','scene_sfx_cue_count','window_sfx_cue_count','sfx_overlaps']},indent=2))
print('Saved',out/'INDEPENDENT_QA.json')
