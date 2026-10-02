#!/usr/bin/env python3
"""Validated sound-only re-export of explicitly authorized EP08 or EP09 revisions."""
import argparse,hashlib,importlib.util,json,subprocess,tempfile
from pathlib import Path
from validate_scene import ROOT,validate
from audio_mix import calibrate_mix,mix_audio,measure_audio
from sfx_assets import validate_asset

def video_hash(path):
    return subprocess.check_output(['ffmpeg','-v','error','-i',str(path),'-map','0:v:0','-c','copy','-f','hash','-hash','sha256','-'],text=True).strip()
def probe(path):
    return json.loads(subprocess.check_output(['ffprobe','-v','error','-select_streams','v:0','-count_frames','-show_entries','stream=width,height,nb_read_frames,r_frame_rate:format=duration','-of','json',str(path)]))
def export(episode,picture,output):
    ep=ROOT/'nemi/episodes'/('ep08_forced_bf_channel' if episode==8 else 'ep09_sf_accident')
    picture,output=picture.resolve(),output.resolve()
    if not picture.is_relative_to(ep/'renders') or not picture.is_file():raise ValueError('Use the approved picture master in this episode renders folder')
    if not output.is_relative_to(ep/'renders') or output.suffix!='.mp4' or output.exists():raise ValueError('Use a new MP4 filename in this episode renders folder')
    if episode==8:
        file=ep/'tools/render_ep08_master.py';loader=importlib.util.spec_from_file_location('ep08_master',file);module=importlib.util.module_from_spec(loader);loader.loader.exec_module(module)
        plan,timing=module.validate_plan();spec={'duration':plan['duration'],'audio':'res://nemi/episodes/ep08_forced_bf_channel/audio/EP08_voice.wav','sfx':[{k:c[k] for k in ['at','duration','gain_db','file']} for c in plan['events']]}
    else:
        spec=validate(ep/'scene.json');plan=json.loads((ep/'sound_plan.json').read_text())
        assert hashlib.sha256((ROOT/spec['audio'].removeprefix('res://')).read_bytes()).hexdigest()==plan['voice_sha256']
    catalog={a['id']:a for a in json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']}
    expected=[]
    for cue in plan['events']:
        asset=catalog[cue['sfx_id']];validate_asset(asset,ROOT)
        expected.append({'file':'res://'+asset['relative_path'],**{k:cue[k] for k in ['at','duration','gain_db']}})
    assert expected==[{k:c[k] for k in ['file','at','duration','gain_db']} for c in spec['sfx']], 'Scene and sound plan differ'
    spec['mix']=calibrate_mix(spec,ROOT)
    source_hash=video_hash(picture);info=probe(picture);stream=info['streams'][0]
    expected=round(spec['duration']*30)
    assert int(stream['nb_read_frames'])==expected and stream['r_frame_rate']=='30/1'
    assert abs(float(info['format']['duration'])-spec['duration'])<.07
    with tempfile.TemporaryDirectory(prefix='story-sound-') as tmp:
        mix=mix_audio(spec,ROOT,Path(tmp)/'new_mix.wav');new=Path(tmp)/'new.mp4'
        subprocess.run(['ffmpeg','-v','error','-i',str(picture),'-i',str(mix),'-map','0:v:0','-map','1:a:0','-c:v','copy','-c:a','aac','-b:a','256k','-t',str(spec['duration']),'-movflags','+faststart',str(new)],check=True)
        levels=measure_audio(new);assert levels['true_peak_dbfs']<=-1
        assert video_hash(new)==source_hash,'Picture stream changed'
        result=probe(new);assert result['streams'][0]==stream
        # Promotion happens only after encoded audio, picture integrity and duration pass.
        import shutil
        shutil.copyfile(new,output)
    qa={'master':output.name,'source_picture':picture.name,'picture_stream_sha256':source_hash,'picture_unchanged':True,'voice_sha256':hashlib.sha256((ROOT/spec['audio'].removeprefix('res://')).read_bytes()).hexdigest(),'voice_processing':'Original identity, recording, pitch, tempo and timing. Mixer applies constant level gain only.','sfx_cues':len(spec['sfx']),'mix':spec['mix'],'encoded_audio':levels,'media':result,'listening':'Numeric audibility/timing checks only; no claim of a complete human listening review.'}
    report=ep/'review'/('sound_4k_qa.json' if stream['width']==3840 else 'sound_1080p_qa.json');report.write_text(json.dumps(qa,indent=2)+'\n')
    print(json.dumps({'output':str(output),'sfx':qa['sfx_cues'],'audio':levels,'picture_unchanged':True},indent=2))
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--episode',required=True,type=int,choices=[8,9]);p.add_argument('--picture',required=True,type=Path);p.add_argument('--output',required=True,type=Path);a=p.parse_args();export(a.episode,a.picture,a.output)
