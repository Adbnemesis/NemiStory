"""Decoded frame/audio evidence for this promo; no perceptual listening claim."""
import hashlib
import json
import math
import subprocess
import sys
from pathlib import Path
import numpy as np

HERE = Path(__file__).resolve().parent.parent
ROOT = HERE.parents[2]
spec = json.loads((HERE/'scene_r4_1080p.json').read_text())
movie = HERE/'renders/ADB_Message_R4_1080p.mp4'
probe = json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_entries','stream=codec_type,width,height,avg_frame_rate,nb_read_frames,duration:format=duration','-of','json',str(movie)]))
video = next(s for s in probe['streams'] if s['codec_type']=='video')
assert (video['width'],video['height'],video['avg_frame_rate'],int(video['nb_read_frames']))==(1920,1080,'30/1',750)
assert abs(float(video['duration'])-25)<.00001
tail = subprocess.check_output(['ffmpeg','-v','error','-i',str(movie),'-vf','select=gte(n\\,663),scale=8:8','-vsync','0','-pix_fmt','rgb24','-f','rawvideo','-'])
tail_array=np.frombuffer(tail,dtype=np.uint8)
assert len(tail_array)==87*8*8*3 and int(tail_array.max())==0

def audio(path,start,duration,gain):
    raw=subprocess.check_output(['ffmpeg','-v','error','-ss',str(start),'-t',str(duration),'-i',str(path),'-ac','1','-ar','48000','-f','f32le','-'])
    return np.frombuffer(raw,dtype='<f4').astype(np.float64)*10**(gain/20)

def levels(data):
    return dict(rms_dbfs=round(20*math.log10(max(float(np.sqrt(np.mean(data**2))),1e-12)),2),peak_dbfs=round(20*math.log10(max(float(np.max(np.abs(data))),1e-12)),2))

report=[]
master=spec['mix']['master_gain_db']
voice=ROOT/spec['audio'][6:]
catalog=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())
assets=catalog.get('assets',[]) if isinstance(catalog,dict) else catalog
sys.path.insert(0,str(ROOT))
from tools.storytime.sfx_assets import validate_asset
for cue in spec['sfx']:
    relative=cue['file'][6:]
    asset=next(a for a in assets if a['relative_path']==relative)
    path=validate_asset(asset,ROOT)
    sound=audio(path,0,cue['duration'],cue['gain_db']+master)
    # Nearby spoken reference, rather than measuring silence at the cue.
    before=[w for w in json.loads((HERE/'voice/prepared_r2/timeline.json').read_text())['words'] if w['end']<=cue['at']]
    nearest=before[-1]['end'] if before else cue['at']
    nearby=audio(voice,max(0,nearest-.5),.5,-2+master)
    report.append(dict(event=cue['event'],at=cue['at'],file=relative,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),provenance=asset.get('source'),license=asset.get('license'),source_gain_db=cue['gain_db'],rendered_sfx_estimate=levels(sound),nearby_voice_reference=levels(nearby)))
result=dict(movie=str(movie.relative_to(ROOT)),sha256=hashlib.sha256(movie.read_bytes()).hexdigest(),video=video,black_tail=dict(first_frame=663,start=22.1,frames=87,max_rgb=0),sfx_measurements=report,perceptual_listening='Pending human listening; these numerical/ASR checks do not establish perceptual balance or phoneme accuracy.')
(HERE/'review/render_records/decoded_r4_checks.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
