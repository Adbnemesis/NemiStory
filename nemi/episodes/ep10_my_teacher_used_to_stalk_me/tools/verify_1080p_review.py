"""Full 1080p review verification; does not create human approval or authorize 4K."""
import hashlib,json,shutil,subprocess
from pathlib import Path
from PIL import Image,ImageDraw
EP=Path(__file__).resolve().parent.parent
movie=EP/'renders/NEMI_EP10_Teacher_Stalker_r5_1080p_REVIEW.mp4'
spec_path=EP/'scene_r5_1080p.json';spec=json.loads(spec_path.read_text())
assert spec['duration']<=150
data=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_entries','stream=codec_type,width,height,duration,nb_read_frames,r_frame_rate:format=duration','-of','json',str(movie)]))
video=next(s for s in data['streams'] if s['codec_type']=='video');audio=next(s for s in data['streams'] if s['codec_type']=='audio')
assert (video['width'],video['height'])==(1920,1080)
assert video['r_frame_rate']=='30/1' and int(video['nb_read_frames'])==4110
assert abs(float(video['duration'])-137)<.01 and abs(float(audio['duration'])-137)<.05
review=EP/'review/r5';review.mkdir(exist_ok=True);records=EP/'review/render_records';records.mkdir(exist_ok=True)
for ext in ['.capture.log','.audio_qa.json','.review_stamp.json']:
    p=movie.with_suffix(ext)
    if p.exists():shutil.move(p,records/p.name)
qa=json.loads((records/(movie.stem+'.audio_qa.json')).read_text());assert qa['true_peak_dbfs']<=-1
stamp=json.loads((records/(movie.stem+'.review_stamp.json')).read_text());assert stamp['resolution']==[1920,1080] and stamp['duration']==137
samples=[((s['start']+s['end'])*.5,s['id']) for s in spec['shots']]
samples += [(43.51,'hand_before'),(43.59,'hand_after'),(85.5,'late_hand'),(113.5,'late_hand'),(136.7,'ending')]
stills=review/'movie_stills';stills.mkdir(exist_ok=True)
files=[]
for i,(t,label) in enumerate(samples):
    p=stills/f'{i:02d}.jpg'
    subprocess.run(['ffmpeg','-v','error','-ss',str(t),'-i',str(movie),'-frames:v','1','-vf','scale=960:540','-y',str(p)],check=True)
    files.append((p,t,label))
for page,start in enumerate(range(0,len(files),12),1):
    items=files[start:start+12];out=Image.new('RGB',(1280,((len(items)+3)//4)*204),'#faf7f2');d=ImageDraw.Draw(out)
    for i,(f,t,label) in enumerate(items):
        with Image.open(f) as im:im=im.resize((320,180),Image.Resampling.LANCZOS);x=i%4*320;y=i//4*204;out.paste(im,(x,y))
        d.text((x+4,y+182),f'{t:.2f}s {label}',fill='#2e1822')
    out.save(review/f'movie_contact_{page:02d}.jpg',quality=92)
# Reference side-by-side uses actual movie frames, not recoloured production images.
reference=EP/'review/ep06_reference';out=Image.new('RGB',(960,432),'#faf7f2');d=ImageDraw.Draw(out)
for i,(ref_t,new_t) in enumerate([(12,9.8),(27,42.5),(115,133.8)]):
    ref=reference/f'frame_{ref_t:03d}.jpg';new=stills/f'reference_pair_{i}.jpg'
    subprocess.run(['ffmpeg','-v','error','-ss',str(new_t),'-i',str(movie),'-frames:v','1','-y',str(new)],check=True)
    for row,f in enumerate([ref,new]):
        with Image.open(f) as im:im=im.resize((320,180),Image.Resampling.LANCZOS);out.paste(im,(i*320,row*216+24))
        d.text((i*320+4,row*216+5),'EP06 reference' if row==0 else 'EP10 R5 actual 1080p',fill='#2e1822')
out.save(review/'EP06_comparison.jpg',quality=93)
result=dict(duration=137,resolution=[1920,1080],fps=30,decoded_frames=4110,audio_qa=qa,bytes=movie.stat().st_size,sha256=hashlib.sha256(movie.read_bytes()).hexdigest(),render_stamp='res://'+str((records/(movie.stem+'.review_stamp.json')).relative_to(EP.parents[2])),render_inputs_sha256=stamp['render_inputs_sha256'],status='Full 1080p review candidate; user satisfaction pending',continuous_playback='not claimed',auditory_review='not claimed; listening via available audio tool unsupported')
(review/'movie_qa.json').write_text(json.dumps(result,indent=2)+'\n')
assert not (EP/'review/1080P_APPROVAL.json').exists(),'Do not fabricate a user approval receipt'
print(json.dumps({k:result[k] for k in ['duration','resolution','decoded_frames','audio_qa','bytes','status']},indent=2))
