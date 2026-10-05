"""Godot draws every visual frame; FFmpeg packages exact music and event-linked recorded SFX."""
from pathlib import Path
import sys,json,subprocess,tempfile,shutil
from validate_ink import validate,ROOT
spec=Path(sys.argv[1]).resolve();c=validate(spec)
revision=sys.argv[2] if len(sys.argv)>2 else 'r1'
assert revision.isalnum()
stills='--stills' in sys.argv
batch=c['version']==2
stem=c['id'] if batch else 'InkEdit'
out=spec.parent/'renders'/f'{stem}_{revision}_1080x1920.mp4'
if out.exists() and not stills:raise SystemExit('Choose a new revision; earlier movies are preserved')
review=spec.parent/'review';review.mkdir(exist_ok=True)
stilldir=review/'stills'/revision;stilldir.mkdir(parents=True,exist_ok=True)
godot='/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot'
with tempfile.TemporaryDirectory(prefix='godot-ink-') as t:
 t=Path(t);raw=t/'capture.avi';log=t/'capture.log'
 project=t/'project';project.mkdir()
 shutil.copy(ROOT/'shorts/godot/project.godot',project/'project.godot')
 # Read-through asset links preserve originals. Portrait size is set before MovieWriter starts.
 for folder in ['common','adb','nemi','shorts']:(project/folder).symlink_to(ROOT/folder,target_is_directory=True)
 cache=project/'.godot';cache.mkdir()
 shutil.copy(ROOT/'.godot/global_script_class_cache.cfg',cache/'global_script_class_cache.cfg')
 (cache/'imported').symlink_to(ROOT/'.godot/imported',target_is_directory=True)
 args=[godot,'--path',str(project),'--log-file',str(log),'--fixed-fps',str(c['fps'])]
 if not stills:args+=['--write-movie',str(raw)]
 script='render_batch.gd' if batch else 'render_ink.gd'
 args+=['--script',f'shorts/godot/{script}','--',f'--spec=res://{spec.relative_to(ROOT)}',f'--review=res://{stilldir.relative_to(ROOT)}']
 if stills:args+=['--stills']
 subprocess.run(args,check=True)
 logs=log.read_text();assert not any(x in logs for x in ['SCRIPT ERROR:','Parse Error:','ERROR:']),logs[-3000:]
 assert 'INK EDIT COMPLETE:' in logs
 shutil.copy(log,review/f'{revision}.capture.log')
 if not stills:
  probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=width,height,nb_read_frames','-of','json',str(raw)]))['streams'][0]
  assert (probe['width'],probe['height'])==(1080,1920) and c['frames']<=int(probe['nb_read_frames'])<=c['frames']+2,probe
  out.parent.mkdir(exist_ok=True)
  duration=c['frames']/c['fps']
  args=['ffmpeg','-v','error','-i',str(raw),'-ss',str(c['music']['sourceStart']),'-i',str(ROOT/c['music']['file'])]
  for s in c['sfx']:args+=['-ss',str(s['sourceStart']),'-t',str(s['duration']),'-i',str(ROOT/s['file'])]
  filters=[f'[1:a]volume={c["music"]["gainDb"]}dB,apad,atrim=duration={duration}[music]']
  labels=['[music]'];events={e['id']:e for e in c.get('events',[])}
  for i,s in enumerate(c['sfx']):
   delay=round((events[s['event']]['at']+s.get('offsetFrames',0))*1000/c['fps'])
   filters.append(f'[{i+2}:a]volume={s["gainDb"]}dB,adelay={delay}|{delay}[s{i}]');labels.append(f'[s{i}]')
  if len(labels)>1:filters.append(''.join(labels)+f'amix=inputs={len(labels)}:normalize=0,atrim=duration={duration}[mix]')
  else:filters.append('[music]anull[mix]')
  args+=['-filter_complex',';'.join(filters),'-map','0:v:0','-map','[mix]','-vf',f'trim=end_frame={c["frames"]},setpts=PTS-STARTPTS','-t',str(duration),'-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-c:a','aac','-b:a','192k','-movflags','+faststart',str(out)]
  subprocess.run(args,check=True)
  record={'file':str(out),'frames':c['frames'],'fps':c['fps'],'capture':probe,'visualEngine':'Godot only; separately authored vector pose illustrations, stage drawings, event doodles and finite camera moves. Existing hidden rig instances sample original controls without modifying source.','audio':{'music':c['music'],'sfx':c['sfx'],'synthesis':False},'artwork':'Editable manually authored Bezier/line/polygon Godot source; no image generation or reference-video sprites.'}
  (review/f'{revision}.render.json').write_text(json.dumps(record,indent=2))
  print(out)
