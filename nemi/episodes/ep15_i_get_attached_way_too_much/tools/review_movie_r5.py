"""Decode EP15, measure exported audio, and save picture review evidence."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from PIL import Image, ImageDraw

EP = Path(__file__).resolve().parent.parent
ROOT = EP.parents[2]
sys.path.insert(0, str(ROOT/'tools/storytime'))
from audio_mix import measure_audio
from sfx_assets import validate_asset

movie=Path(sys.argv[1]).resolve()
start=float(sys.argv[2]) if len(sys.argv)>2 else 0
spec_path=EP/'scene_r5.json'
spec=json.loads(spec_path.read_text())
stamp_path=movie.with_suffix('.review_stamp.json')
if not stamp_path.exists():stamp_path=EP/'review/render_records'/stamp_path.name
out=EP/'review'/movie.stem
out.mkdir(parents=True,exist_ok=True)
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-select_streams','v:0',
    '-show_entries','stream=width,height,r_frame_rate,nb_read_frames,duration:format=duration','-of','json',str(movie)]))
v=probe['streams'][0]
duration=float(probe['format']['duration'])
assert(v['width'],v['height'])==(1920,1080)
assert int(v['nb_read_frames'])==round(duration*30)
assert duration<=180
subprocess.run(['ffmpeg','-v','error','-i',str(movie),'-f','null','-'],check=True,capture_output=True)
times=[.3,duration-.2]
for shot in spec['shots']:
    for t in [shot['start']+.2,(shot['start']+shot['end'])/2,shot['end']-.1]:
        if start<=t<start+duration:times.append(round(t-start,3))
for item in spec['drawings']+spec.get('props',[]):
    for t in [item['at']+.05,item['at']+min(item.get('duration',.5),.5)]:
        if start<=t<start+duration:times.append(round(t-start,3))
for boundary in [x for a in spec['actors'] for x in a.get('hand_path_window',[])]+ [next(p['attach_end'] for p in spec['props'] if 'attach_end' in p)]:
    for t in [boundary-.05,boundary+.05]:
        if start<=t<start+duration:times.append(round(t-start,3))
times=sorted(set(times))
thumbs=[]
for i,t in enumerate(times):
    frame=out/f'frame_{i:03d}_{t+start:07.3f}s.jpg'
    subprocess.run(['ffmpeg','-v','error','-y','-ss',str(t),'-i',str(movie),'-frames:v','1','-q:v','2',str(frame)],check=True)
    thumbs.append(Image.open(frame).resize((640,360)))
for page in range(0,len(times),8):
    ims=thumbs[page:page+8]
    sheet=Image.new('RGB',(1280,385*((len(ims)+1)//2)),'white')
    draw=ImageDraw.Draw(sheet)
    for j,im in enumerate(ims):
        x=(j%2)*640;y=(j//2)*385
        sheet.paste(im,(x,y))
        draw.text((x+7,y+364),f'{times[page+j]+start:.3f}s',fill='black')
    sheet.save(out/f'contact_{page//8+1:02d}.jpg',quality=94)
catalog=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']
by_path={a['relative_path']:a for a in catalog}
for cue in spec['sfx']:validate_asset(by_path[cue['file'][6:]],ROOT)
audio=measure_audio(movie)
assert audio['true_peak_dbfs']<=-1
qa=dict(movie='res://'+str(movie.relative_to(ROOT)),sha256=hashlib.sha256(movie.read_bytes()).hexdigest(),
    spec_sha256=json.loads(stamp_path.read_text())['spec_sha256'],review_context_spec_sha256=hashlib.sha256(spec_path.read_bytes()).hexdigest(),probe=probe,
    duration_seconds=duration,window_start=start,hard_cap_seconds=180,full_decode_passed=True,
    audio=audio,caption_cards=len(spec['captions']),all_cards_at_most_five_words=all(len(c['text'].split())<=5 for c in spec['captions']),
    sfx_assets_validated=True,stills_scene_seconds=[r+start for r in times],
    subjective_visual_review='pending inspection of resulting stills and playback',
    acoustic_listening='not performed: this tool session cannot perceive audio; measured levels and independent ASR are recorded separately',
    lipsync='Measured word intervals with authored existing vowel/closure vocabulary; no phoneme-perfect claim',
    user_satisfaction='pending current complete 1080p review',four_k_rendered=False)
(out/'QA.json').write_text(json.dumps(qa,indent=2)+'\n')
print(json.dumps(dict(output=str(out),duration=duration,frames=v['nb_read_frames'],audio=audio,stills=len(times)),indent=2))
