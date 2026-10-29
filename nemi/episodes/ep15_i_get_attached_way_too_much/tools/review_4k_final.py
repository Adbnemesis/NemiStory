"""Verify the approved native4K master before episode-scoped media cleanup."""
import hashlib,json,subprocess,sys
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np
EP=Path(__file__).resolve().parent.parent
ROOT=EP.parents[2]
sys.path.insert(0,str(ROOT/'tools/storytime'))
from audio_mix import measure_audio
from render_approval import render_inputs_sha256
movie=EP/'renders/NEMI_EP15_I_Get_Attached_Way_Too_Much_r5_4K_FINAL.mp4'
preview=EP/'renders/NEMI_EP15_I_Get_Attached_Way_Too_Much_r5_1080p_REVIEW.mp4'
spec=EP/'scene_r5.json'
out=EP/'review/final_4k';out.mkdir(parents=True,exist_ok=True)
stamp_path=movie.with_suffix('.review_stamp.json')
if not stamp_path.exists():stamp_path=EP/'review/render_records'/stamp_path.name
stamp=json.loads(stamp_path.read_text())
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=width,height,r_frame_rate,nb_read_frames:format=duration','-of','json',str(movie)]))
v=probe['streams'][0]
assert (v['width'],v['height'],v['r_frame_rate'],int(v['nb_read_frames']))==(3840,2160,'30/1',4506)
assert abs(float(probe['format']['duration'])-150.2)<.001
result=subprocess.run(['ffmpeg','-v','error','-i',str(movie),'-f','null','-'],capture_output=True,text=True,check=True)
assert not result.stderr.strip(),result.stderr
assert stamp['spec_sha256']==hashlib.sha256(spec.read_bytes()).hexdigest()
assert stamp['preview_sha256']==hashlib.sha256(movie.read_bytes()).hexdigest()
assert stamp['render_inputs_sha256']==render_inputs_sha256(spec,ROOT)
audio=measure_audio(movie);assert audio['true_peak_dbfs']<=-1
# Compare exact compressed audio packets from the approved preview and master.
def audio_hash(path):
    data=subprocess.check_output(['ffmpeg','-v','error','-i',str(path),'-map','0:a:0','-c','copy','-f','data','-'])
    return hashlib.sha256(data).hexdigest()
ah=audio_hash(movie);ph=audio_hash(preview);assert ah==ph
samples=[];thumbs=[]
for t in [7.9,30.95,37.1,81.8,100.3,121.8,135.58,137.82,149.8]:
    p=out/f'frame_{t:07.2f}s.png'
    subprocess.run(['ffmpeg','-v','error','-y','-ss',str(t),'-i',str(movie),'-frames:v','1',str(p)],check=True)
    im=Image.open(p).convert('RGB');assert im.size==(3840,2160)
    # Native rasterization and independent H264 encoding yield slight edge differences.
    old=subprocess.check_output(['ffmpeg','-v','error','-ss',str(t),'-i',str(preview),'-frames:v','1','-pix_fmt','rgb24','-f','rawvideo','-'])
    a=np.asarray(im.resize((1920,1080),Image.Resampling.LANCZOS)).astype(float)
    b=np.frombuffer(old,dtype=np.uint8).reshape((1080,1920,3)).astype(float)
    delta=np.abs(a-b)
    samples.append(dict(seconds=t,file=str(p.relative_to(EP)),native_dimensions=list(im.size),downsample_vs_approved_mean_absolute_rgb_difference=round(float(delta.mean()),4),p99_absolute_difference=round(float(np.percentile(delta,99)),4)))
    thumbs.append(im.resize((640,360),Image.Resampling.LANCZOS))
canvas=Image.new('RGB',(1920,1155),'white');d=ImageDraw.Draw(canvas)
for i,im in enumerate(thumbs):
    x=i%3*640;y=i//3*385;canvas.paste(im,(x,y));d.text((x+8,y+364),f'{samples[i]["seconds"]:.2f}s',fill='black')
canvas.save(out/'contact.jpg',quality=94)
qa=dict(movie=str(movie.relative_to(ROOT)),movie_sha256=stamp['preview_sha256'],scene_sha256=stamp['spec_sha256'],render_inputs_sha256=stamp['render_inputs_sha256'],probe=probe,full_decode_passed=True,encoded_audio=audio,compressed_audio_packets_identical_to_user_approved_preview=True,audio_packet_sha256=ah,native_4k_render='Fresh Godot3840x2160 rasterization through normalrender_scene.py --4k; not an upscale.',user_approval_receipt='review/1080P_APPROVAL.json',samples=samples,visual_review='Pending actual inspection of nativeframes and contact sheet.',playback='Pending',acoustic_review='User approved exact1080p mix;4K AAC packets identical. No new perceptual listening claimed.',cleanup_permitted_after_visual_checks=True)
(out/'QA.json').write_text(json.dumps(qa,indent=2)+'\n')
print(json.dumps({k:qa[k] for k in ['movie_sha256','full_decode_passed','encoded_audio','compressed_audio_packets_identical_to_user_approved_preview']},indent=2))
