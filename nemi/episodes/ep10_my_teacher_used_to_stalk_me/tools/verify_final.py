"""Verify the full encoded native 4K delivery and produce compact visual evidence."""
import hashlib,json,shutil,subprocess
from pathlib import Path
from PIL import Image,ImageDraw
EP=Path(__file__).resolve().parent.parent
movie=EP/'renders/NEMI_EP10_Teacher_Stalker_r3_4K.mp4'
spec=json.loads((EP/'scene.json').read_text())
assert spec['duration']<=150, 'User hard maximum is 2.5 minutes'
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_entries','stream=codec_type,width,height,duration,nb_read_frames,r_frame_rate:format=duration','-of','json',str(movie)]))
video=next(s for s in probe['streams'] if s['codec_type']=='video');audio=next(s for s in probe['streams'] if s['codec_type']=='audio')
assert (video['width'],video['height'])==(3840,2160)
assert video['r_frame_rate']=='30/1' and int(video['nb_read_frames'])==int(spec['duration']*30)
assert abs(float(video['duration'])-spec['duration'])<.01 and abs(float(audio['duration'])-spec['duration'])<.04
records=EP/'review/render_records';records.mkdir(exist_ok=True)
for suffix in ['.capture.log','.audio_qa.json']:
    p=movie.with_suffix(suffix)
    if p.exists():shutil.move(p,records/p.name)
audio_qa=json.loads((records/(movie.stem+'.audio_qa.json')).read_text())
assert audio_qa['true_peak_dbfs']<=-1
capture_log=(records/(movie.stem+'.capture.log')).read_text()
assert 'STORYTIME COMPLETE: 4110 authored frames' in capture_log
assert not any(x in capture_log for x in ['SCRIPT ERROR:','Parse Error:','ERROR:'])
review=EP/'review';stills=review/'final_movie_stills';stills.mkdir(exist_ok=True)
samples=[((s['start']+s['end'])/2,s['id']) for s in spec['shots']]
samples += [(spec['duration']-.3,'final_hold')]
for boundary in spec['actors'][0]['hand_path_window']:
    samples.extend([(boundary-.04,'contact_before'),(boundary+.04,'contact_after')])
files=[]
for i,(t,label) in enumerate(samples):
    f=stills/f'{i:02d}_{label}.jpg'
    subprocess.run(['ffmpeg','-v','error','-ss',str(t),'-i',str(movie),'-frames:v','1','-vf','scale=960:540','-y',str(f)],check=True)
    files.append((f,t,label))
for page,start in enumerate(range(0,len(files),12),1):
    part=files[start:start+12];out=Image.new('RGB',(1280,((len(part)+3)//4)*204),'#eee7df');draw=ImageDraw.Draw(out)
    for i,(f,t,label) in enumerate(part):
        with Image.open(f) as im:thumb=im.resize((320,180),Image.Resampling.LANCZOS)
        x=i%4*320;y=i//4*204;out.paste(thumb,(x,y));draw.text((x+4,y+181),f'{t:.2f}s {label}',fill='#342d30')
    out.save(review/f'final_master_contact{page:02d}.jpg',quality=90)
result=dict(duration_seconds=spec['duration'],hard_limit_seconds=150,resolution=[3840,2160],fps=30,decoded_video_frames=int(video['nb_read_frames']),audio_duration_seconds=float(audio['duration']),audio_qa=audio_qa,sha256=hashlib.sha256(movie.read_bytes()).hexdigest(),bytes=movie.stat().st_size,native_capture='Shared Godot renderer at 3840×2160, no upscale',scene_sha256=hashlib.sha256((EP/'scene.json').read_bytes()).hexdigest(),visual_samples=[dict(at=t,label=label) for _,t,label in files],continuous_playback_review='pending; computer-use player connection timed out',auditory_review='pending; audio ingestion unsupported')
(review/'final_movie_qa.json').write_text(json.dumps(result,indent=2)+'\n')
assert [f.name for f in (EP/'renders').iterdir()]==[movie.name], 'Movie folder must contain only the final 4K video'
print(json.dumps({k:result[k] for k in ['duration_seconds','resolution','decoded_video_frames','audio_qa','bytes']},indent=2))
