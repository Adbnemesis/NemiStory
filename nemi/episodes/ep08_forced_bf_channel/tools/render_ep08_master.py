#!/usr/bin/env python3
"""EP08-only revision: original narration, deterministic beats and shared SFX mixer.
Outputs a new review movie under renders/ep08_refinement; never overwrites the original.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[4]
EP = ROOT/'nemi/episodes/ep08_forced_bf_channel'
sys.path.insert(0,str(ROOT/'tools/storytime'))
from audio_mix import calibrate_mix, mix_audio, measure_audio

NAMES = ['Hook','OldADBCallback','HatedDesign','NewADBReveal','TerribleIdea','AskingADB','TwoChannels','ADBIntro','OutroTakeover']
FPS = 30

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def run(command):
    result=subprocess.run(command,cwd=ROOT,capture_output=True,text=True,timeout=900)
    if result.returncode:raise RuntimeError(result.stderr[-5000:]+'\n'+result.stdout[-2000:])
    return result

def validate_plan():
    plan=json.loads((EP/'sfx_cues.json').read_text())
    timing=json.loads((EP/'timing/ep08_timing.json').read_text())
    assert sha(EP/'audio/EP08_voice.wav') == plan['voice_sha256'], 'Approved narration has changed'
    assert sha(EP/'timing/ep08_timing.json') == plan['timing_sha256'], 'Approved text/timing has changed'
    assert plan['duration'] == timing['total_duration'] and plan['fps']==FPS
    # GDScript caption content must match the unchanged timing JSON exactly.
    matches=re.findall(r'\{"beat": (\d+), "speaker": "([^"]+)", "start": ([\d.]+), "end": ([\d.]+), "text": "([^"]+)"', (EP/'Episode08Subtitles.gd').read_text())
    assert len(matches)==len(timing['cards'])==69
    for (beat,actor,start,end,text),card in zip(matches,timing['cards']):
        assert (int(beat),actor,float(start),float(end),text)==(card['beat'],card['character'],card['start'],card['end'],card['text'])
        assert len(text.split())<=5
    catalog={a['id']:a for a in json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']}
    ids=set()
    for cue in plan['events']:
        assert cue['event'] not in ids;ids.add(cue['event'])
        card=timing['cards'][cue['card']];asset=catalog[cue['sfx_id']]
        assert cue['text']==card['text'] and cue['beat']==card['beat']
        assert abs(cue['at']-card['start']-cue['offset'])<1e-6
        assert cue['file']=='res://'+asset['relative_path'] and (ROOT/asset['relative_path']).is_file()
        assert cue['license']==asset['license'] and asset.get('commercial_use')
        assert 0<cue['duration']<=2.5 and -60<=cue['gain_db']<=-6
        assert cue['at']+cue['duration']<=plan['duration']
    # Old unknown pose names silently fell back to a generic stand. Reject them.
    libraries={'nemi':ROOT/'nemi/characters/nemi/NemiPose.gd','new_adb':ROOT/'adb/poses/ADBPoseLibrary.gd'}
    for actor,library in libraries.items():
        names=set()
        for line in library.read_text().splitlines():
            if line.startswith('\t\t"'): names.update(re.findall(r'"([a-z_]+)"',line))
        for beat in (EP/'beats').glob('*.gd'):
            assert not set(re.findall(actor+r'.set_pose\("([^\"]+)"',beat.read_text()))-names, 'Unsupported pose in '+str(beat)
    # Reject unsupported illustration characters before launching a long capture.
    art_texts=re.findall(r'"txt":\s*"([^\"]+)"',(EP/'Ep08Doodles.gd').read_text())
    for author in ['nemi','adb']:
        profile=json.loads((ROOT/f'common/storytime/profiles/{author}.json').read_text())
        glyphs=json.loads((ROOT/profile['lettering'].removeprefix('res://')).read_text())['glyphs']
        assert all(c in glyphs or c in ' \n' for text in art_texts for c in text), 'Unsupported illustration glyph'
    return plan,timing

def render_beat(index,start,end,godot,folder,resolution,capture_root):
    count=round(end*FPS)-round(start*FPS)
    raw=folder/f'beat{index:02d}.avi';video=folder/f'beat{index:02d}.mp4'
    scene=f'res://nemi/episodes/ep08_forced_bf_channel/beats/Beat{index:02d}_{NAMES[index-1]}.tscn'
    print(f'Rendering beat {index}: {NAMES[index-1]} ({count} frames)',flush=True)
    result=run([godot,'--resolution',f'{resolution[0]}x{resolution[1]}','--path',str(capture_root),'--log-file',str(folder/f'beat{index:02d}.log'),'--write-movie',str(raw),'--fixed-fps',str(FPS),scene,'--','--ep08-export',*(['--ep08-4k'] if resolution[0]==3840 else [])])
    (ROOT/'renders/ep08_refinement'/f'capture_beat{index:02d}.log').write_text(result.stdout+'\n'+result.stderr)
    if any(marker in result.stderr+result.stdout for marker in ['SCRIPT ERROR:','Parse Error:','Assertion failed','Unknown pose','Unknown expression','Unsupported drawn glyph']):
        raise RuntimeError(result.stderr+'\n'+result.stdout)
    timing=json.loads((EP/'timing/ep08_timing.json').read_text())
    expected_cards=[c for c in timing['cards'] if c['beat']==index]
    actual_cards=re.findall(r"\[CARD\] \(frame (\d+)\) Playing card '(.*?)' \[",result.stdout)
    assert len(actual_cards)==len(expected_cards), 'Capture skipped a caption'
    for (frame,text),card in zip(actual_cards,expected_cards):
        assert text==card['text'] and abs(int(frame)/FPS-(card['start']-start))<=1/FPS, 'Caption/action cue drifted from original narration clock'
    raw_probe=json.loads(run(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=nb_read_frames','-of','json',str(raw)]).stdout)
    assert int(raw_probe['streams'][0]['nb_read_frames'])>=count, 'Raw capture ended early; do not pad missing choreography'
    run(['ffmpeg','-v','error','-nostdin','-i',str(raw),'-frames:v',str(count),'-an','-c:v','libx264','-crf','17','-preset','fast','-pix_fmt','yuv420p',str(video)])
    probe=json.loads(run(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=nb_read_frames','-of','json',str(video)]).stdout)
    assert int(probe['streams'][0]['nb_read_frames'])==count, 'Beat is shorter than its authored clock'
    raw.unlink()
    wav=raw.with_suffix('.wav')
    if wav.exists():wav.unlink()
    return video

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--resolution',choices=['1080p','4k'],default='1080p',help='Native vector capture size; no upscale')
    parser.add_argument('--proof',action='store_true',help='Fresh ten-second reveal proof')
    parser.add_argument('--validate-only',action='store_true')
    parser.add_argument('--godot',default='/Users/talus/Downloads/Godot.app/Contents/MacOS/Godot')
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    plan,timing=validate_plan()
    if args.validate_only:
        print('PASS: original voice hash, original 69 caption cards, 18 licensed named SFX events');return
    output=(args.output or ROOT/'renders/ep08_refinement'/('EP08_reveal_proof_10s.mp4' if args.proof else 'EP08_Forced_BF_Channel_Refined.mp4')).resolve()
    assert output.is_relative_to(ROOT/'renders/ep08_refinement') or output.is_relative_to(EP/'renders'), 'Use the EP08 episode renders folder or the isolated review folder'
    if output.exists():raise ValueError('Output already exists. Choose a new filename.')
    output.parent.mkdir(parents=True,exist_ok=True)
    # Private temporary output namespace avoids cache collisions with Antigravity/EP09.
    with tempfile.TemporaryDirectory(prefix='ep08-revision-') as tmp:
        folder=Path(tmp);videos=[]
        capture_root=ROOT
        if args.resolution=='4k':
            capture_root=folder/'project';capture_root.mkdir()
            for child in ROOT.iterdir():
                if child.name not in ['project.godot','.git']:
                    (capture_root/child.name).symlink_to(child,target_is_directory=child.is_dir())
            config=(ROOT/'project.godot').read_text()
            for key in ['viewport_width','window_width_override']:
                config=re.sub(r'(window/size/'+key+r'=)\d+',r'\g<1>3840',config)
            for key in ['viewport_height','window_height_override']:
                config=re.sub(r'(window/size/'+key+r'=)\d+',r'\g<1>2160',config)
            (capture_root/'project.godot').write_text(config)
        boundaries=[timing['beat_ranges'][str(i)]['start'] for i in range(1,10)]+[plan['duration']]
        indices=[4] if args.proof else range(1,10)
        for i in indices:videos.append(render_beat(i,boundaries[i-1],boundaries[i],args.godot,folder,(3840,2160) if args.resolution=='4k' else (1920,1080),capture_root))
        listing=folder/'concat.txt';listing.write_text(''.join("file '"+str(v)+"'\n" for v in videos))
        joined=folder/'video.mp4'
        run(['ffmpeg','-v','error','-nostdin','-f','concat','-safe','0','-i',str(listing),'-an','-c:v','copy',str(joined)])
        spec={'duration':plan['duration'],'audio':'res://nemi/episodes/ep08_forced_bf_channel/audio/EP08_voice.wav','sfx':[{k:cue[k] for k in ['file','at','duration','gain_db']} for cue in plan['events']]}
        spec['mix']=calibrate_mix(spec,ROOT)
        audio=mix_audio(spec,ROOT,folder/'mixed.wav')
        duration=10 if args.proof else round(plan['duration']*FPS)/FPS
        audio_args=['-ss',str(boundaries[3])] if args.proof else []
        run(['ffmpeg','-v','error','-nostdin','-i',str(joined),*audio_args,'-i',str(audio),'-map','0:v','-map','1:a','-t',str(duration),'-frames:v',str(round(duration*FPS)),'-c:v','copy','-c:a','aac','-b:a','256k','-movflags','+faststart',str(output)])
    levels=measure_audio(output)
    assert levels['true_peak_dbfs']<=-1.0, 'Encoded audio peak exceeds headroom'
    expected=round(duration*FPS)
    probe=json.loads(run(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=nb_read_frames,width,height','-of','json',str(output)]).stdout)
    assert int(probe['streams'][0]['nb_read_frames'])==expected
    assert (probe['streams'][0]['width'],probe['streams'][0]['height'])==((3840,2160) if args.resolution=='4k' else (1920,1080)), 'Wrong native capture resolution'
    (output.with_suffix('.qa.json')).write_text(json.dumps({'voice_sha256':plan['voice_sha256'],'timing_sha256':plan['timing_sha256'],'voice_processing':'Original recording, original timing/speed/pitch; constant level gain only. No EQ, limiter, compression or generation.','sfx_events':len(plan['events']),'mix':spec['mix'],'encoded_audio':levels,'frames':expected,'duration':duration,'render':'Fresh capture; no reused legacy beat cache.','playback_review':'Pending human listening; see the episode REFINEMENT_REVIEW.md for visual checks.'},indent=2)+'\n')
    print(output,flush=True)

if __name__=='__main__':main()
