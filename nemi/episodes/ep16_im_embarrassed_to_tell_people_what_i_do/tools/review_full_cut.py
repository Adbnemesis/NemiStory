"""Decode current full movie and collect exact per-shot still evidence."""
from pathlib import Path
import hashlib,json,subprocess,shutil
from PIL import Image,ImageDraw
EP=Path(__file__).resolve().parent.parent
spec_path=EP/'scene_r5_1080p.json';movie=EP/'renders/NEMI_EP16_Embarrassed_r5_1080p_REVIEW.mp4'
s=json.loads(spec_path.read_text());d=EP/'review/full_r5';d.mkdir(exist_ok=True)
def sha(f):return hashlib.sha256(f.read_bytes()).hexdigest()
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_entries','stream=codec_type,width,height,duration,nb_frames,nb_read_frames,r_frame_rate:format=duration','-of','json',str(movie)]))
v=next(x for x in probe['streams'] if x['codec_type']=='video');a=next(x for x in probe['streams'] if x['codec_type']=='audio')
assert (v['width'],v['height'])==(1920,1080)
assert int(v['nb_read_frames'])==round(s['duration']*s['fps'])
assert abs(float(v['duration'])-s['duration'])<.002 and abs(float(a['duration'])-s['duration'])<.03
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-i',str(movie),'-f','null','-'],check=True)
times=json.loads((EP/'review/final_still_plan.json').read_text())['times'];frames=[]
for t in times:
 f=d/f'{t:07.3f}s.png'
 if not f.exists():subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-ss',str(t),'-i',str(movie),'-frames:v','1',str(f)],check=True)
 im=Image.open(f).convert('RGB');im.thumbnail((480,270));frames.append((im,t))
rows=(len(frames)+3)//4;sheet=Image.new('RGB',(1920,rows*294),'#ece8e1');pen=ImageDraw.Draw(sheet)
for i,(im,t) in enumerate(frames):
 x=(i%4)*480;y=(i//4)*294;sheet.paste(im,(x,y));pen.text((x+8,y+274),f'EP16 R5 {t:.3f}s',fill='#30252b')
sheet.save(d/'contact_sheet.jpg',quality=95)
# Preserve stamp before moving the renderer-owned sidecars to the review folder.
stamp_path=movie.with_suffix('.review_stamp.json');stamp=json.loads(stamp_path.read_text())
assert stamp['spec_sha256']==sha(spec_path) and stamp['preview_sha256']==sha(movie)
for f in list((EP/'renders').iterdir()):
 if f.suffix!='.mp4':shutil.move(str(f),str(EP/'review/render_records'/f.name))
audio_path=EP/'review/render_records'/movie.with_suffix('.audio_qa.json').name
audio=json.loads(audio_path.read_text());assert audio['true_peak_dbfs']<=-1.0
result={'movie':str(movie.relative_to(EP)),'movie_sha256':sha(movie),'spec':'scene_r5_1080p.json','spec_sha256':sha(spec_path),'duration_seconds':s['duration'],'resolution':[1920,1080],'fps':s['fps'],'decoded_video_frames':int(v['nb_read_frames']),'full_av_decode':'passed','streams':probe['streams'],'encoded_audio':audio,'current_stamp':str((EP/'review/render_records'/stamp_path.name).relative_to(EP)),'render_input_signature':stamp['render_inputs_sha256'],'still_times':times,'contact_sheet':'review/full_r5/contact_sheet.jpg','still_inspection':'pending agent and parent review','actual_playback':'unperformed; current tools could not provide native/browser playback access','perceptual_listening':'unperformed; audio input unsupported','phoneme_perfect_lipsync':'not claimed; measured-word vowel and closure approximations','user_full1080p_satisfaction':'pending','4k_export':'not rendered'}
(EP/'review/QA_CURRENT.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k] for k in ['movie','duration_seconds','resolution','decoded_video_frames','encoded_audio','contact_sheet']},indent=2))
