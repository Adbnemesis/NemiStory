"""Validated audio-only promotion of this episode's completed picture render."""
import json,sys,subprocess,tempfile,shutil,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];sys.path.insert(0,str(ROOT/'tools/storytime'))
from validate_scene import validate
from audio_mix import mix_audio,measure_audio
EP=Path(__file__).resolve().parents[1]
picture=EP/'renders/ADB_EP01_full_r2_1080p.mp4';output=EP/'renders/ADB_EP01_full_r3_1080p.mp4'
if output.exists():raise ValueError('Preserve existing output; choose a new revision')
spec=validate(EP/'scene.json')
def video_hash(p):return subprocess.check_output(['ffmpeg','-v','error','-i',str(p),'-map','0:v:0','-c','copy','-f','hash','-hash','sha256','-'],text=True).strip()
def probe(p):return json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=width,height,nb_read_frames,r_frame_rate,duration:format=duration','-of','json',str(p)]))
info=probe(picture);v=info['streams'][0]
assert int(v['nb_read_frames'])==round(spec['duration']*spec['fps']) and v['width']==1920 and v['height']==1080
assert abs(float(info['format']['duration'])-spec['duration'])<.02
before=video_hash(picture)
with tempfile.TemporaryDirectory(prefix='adb-sound-') as tmp:
    mix=mix_audio(spec,ROOT,Path(tmp)/'mix.wav');new=Path(tmp)/'master.mp4'
    subprocess.run(['ffmpeg','-v','error','-i',str(picture),'-i',str(mix),'-map','0:v:0','-map','1:a:0','-c:v','copy','-c:a','aac','-b:a','256k','-t',str(spec['duration']),'-movflags','+faststart',str(new)],check=True)
    measured=measure_audio(new);after=video_hash(new);result=probe(new)
    assert before==after and result['streams'][0]==v
    assert measured['true_peak_dbfs']<=-1
    shutil.copyfile(new,output)
qa={'master':output.name,'source_picture':picture.name,'picture_unchanged':True,'picture_stream_sha256':after,'voice_sha256':hashlib.sha256((ROOT/spec['audio'][6:]).read_bytes()).hexdigest(),'encoded_audio':measured,'media':result,'sfx':len(spec['sfx']),'listening':'Not available to the agent: acoustic levels/transcription checked; perceptual listening remains unverified.'}
(EP/'review/final_1080p_qa.json').write_text(json.dumps(qa,indent=2)+'\n')
output.with_suffix('.audio_qa.json').write_text(json.dumps(measured,indent=2)+'\n')
print(json.dumps(qa,indent=2))
