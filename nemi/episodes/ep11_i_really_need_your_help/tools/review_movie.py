"""Record actual decoding, audio metrics and selected video stills for a review cut."""
import json,hashlib,sys,subprocess
from pathlib import Path
from PIL import Image,ImageDraw
EP=Path(__file__).resolve().parent.parent;ROOT=EP.parents[2];sys.path.insert(0,str(ROOT/'tools/storytime'))
from audio_mix import measure_audio
from sfx_assets import validate_asset
path=Path(sys.argv[1]).resolve();out=EP/'review'/path.stem;out.mkdir(exist_ok=True)
spec=json.loads((EP/'scene.json').read_text())
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=width,height,r_frame_rate,nb_read_frames,duration:format=duration','-of','json',str(path)]))
v=probe['streams'][0];assert (v['width'],v['height'])==(1920,1080);assert abs(float(probe['format']['duration'])-spec['duration'])<.08;assert int(v['nb_read_frames'])==round(spec['duration']*30)
subprocess.run(['ffmpeg','-v','error','-i',str(path),'-f','null','-'],check=True,capture_output=True)
ts=sorted(set([.5,3.5,7.7,11,15.3,19,24.8,25.4,26.5,30,35.5,39,42,44,44.8,47,51,54,59,62,65,68,70,74,77,80,82,85,89,93,96,101,105,109,114,115.1,118,121,124,126,128]))
thumbs=[]
for t in ts:
 f=out/f'frame_{t:06.2f}.png';subprocess.run(['ffmpeg','-v','error','-y','-ss',str(t),'-i',str(path),'-frames:v','1',str(f)],check=True)
 thumbs.append(Image.open(f).resize((640,360)))
for page in range(0,len(ts),8):
 subset=thumbs[page:page+8];sheet=Image.new('RGB',(1280,((len(subset)+1)//2)*385),'white');d=ImageDraw.Draw(sheet)
 for j,im in enumerate(subset):sheet.paste(im,((j%2)*640,(j//2)*385));d.text(((j%2)*640+7,(j//2)*385+364),f'{ts[page+j]}s',fill='black')
 sheet.save(out/f'contact_{page//8+1}.jpg',quality=94)
Image.open(out/'frame_000.50.png').resize((320,180)).save(out/'phone_opening.png')
Image.open(out/'frame_126.00.png').resize((320,180)).save(out/'phone_ending.png')
# Compare actual EP06 frame to this actual cut without claiming shared render identity.
ref=Path('/tmp/nemi_ep06_colour_reference.png')
if ref.exists():
 sheet=Image.new('RGB',(1280,385),'white');sheet.paste(Image.open(ref).resize((640,360)),(0,0));sheet.paste(Image.open(out/'frame_042.00.png').resize((640,360)),(640,0));d=ImageDraw.Draw(sheet);d.text((8,363),'EP06 actual 1080p reference',fill='black');d.text((648,363),'EP11 actual 1080p review',fill='black');sheet.save(out/'colour_comparison.jpg',quality=94)
assets=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets'];by_path={x['relative_path']:x for x in assets}
for cue in spec['sfx']:validate_asset(by_path[cue['file'][6:]],ROOT)
qa=dict(status='1080p review; user acceptance pending',movie='res://'+str(path.relative_to(ROOT)),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),spec_sha256=hashlib.sha256((EP/'scene.json').read_bytes()).hexdigest(),duration_seconds=spec['duration'],hard_cap_seconds=150,probe=probe,full_decode_passed=True,audio=measure_audio(path),stills=ts,caption_count=len(spec['captions']),all_caption_cards_at_most_five_words=all(len(c['text'].split())<=5 for c in spec['captions']),voice_identity='Canonical Sohee CustomVoice; unchanged identity prompt, original Sohee recordings with selected pitch-preserving tempo 1.00–1.12 and explicit phrase-pause edits; retained originals',alignment='Measured Whisper word times plus authored existing mouth shapes and consonant closures; not measured phoneme alignment',sfx_provenance_checked=True,continuous_playback_review=False,perceptual_audio_listening=False,playback_limitation='Native computer-use player access timed out twice; do not claim continuous watch/listening. Stills, sequence samples, ASR transcript, duration, complete decode and encoded metrics reviewed.',rigs_edited=False,user_4k_approval=False,workflow_updates='User asked to finalize both storytime skill/docs balance after agreement on the episode; pending acceptance.')
(out/'QA.json').write_text(json.dumps(qa,indent=2)+'\n');print(out);print(json.dumps(qa['audio']))
