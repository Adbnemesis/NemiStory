#!/usr/bin/env python3
"""Bind YouTube digit routes to an encoded sphere and save actual frame evidence.

This performs a quick container probe and selected-frame decodes, not a full
media decode or a YouTube player test. Existing reports/frames are never reused.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
from fractions import Fraction
import hashlib
import json
import math
from pathlib import Path
import subprocess

from validate_episode import check_data, digit_targets

PROJECT=Path(__file__).resolve().parents[1]
WALL_YAWS={0:0,1:90,2:180,3:-90}

def sha256(path):
    digest=hashlib.sha256()
    with path.open('rb') as handle:
        for block in iter(lambda:handle.read(1024*1024),b''):digest.update(block)
    return digest.hexdigest()

def require(value,message):
    if not value:raise ValueError(message)

def relative(path):return str(path.relative_to(PROJECT))

def run(command):
    return subprocess.run(command,capture_output=True,text=True,check=True)

def probe(video):
    result=run(['ffprobe','-v','error','-show_entries',
        'format=duration:stream=index,codec_type,codec_name,width,height,avg_frame_rate,r_frame_rate,nb_frames,duration,start_time',
        '-of','json',str(video)])
    return json.loads(result.stdout)

def inspect_clock(timeline,game,media):
    """Use actual container duration, because YouTube digit keys seek by percent."""
    check_data(timeline,game)
    targets=digit_targets(timeline,game)
    require(targets is not None,'Episode must declare youtube_digits navigation')
    video=next((s for s in media['streams'] if s['codec_type']=='video'),None)
    require(video is not None,'No encoded video stream')
    duration=float(media['format']['duration'])
    fps=float(Fraction(video['avg_frame_rate']))
    require(math.isfinite(duration) and duration>0 and fps>0,'Invalid encoded duration or frame rate')
    frame=1/fps
    landings=[]
    for key in range(10):
        actual=duration*key/10;authored=targets[key]['at'];error=abs(actual-authored)
        landings.append({'key':key,'chapter':targets[key]['chapter'],
            'authored_start_seconds':authored,'encoded_percentage_seconds':actual,
            'error_seconds':error,'error_frames':error*fps,'within_one_frame':error<frame})
    checks={'sphere_2_to_1':video['width']==2*video['height'],
        'fps_matches_authored':abs(fps-timeline['fps'])<1e-9,
        'duration_within_one_frame':abs(duration-timeline['duration'])<frame,
        'all_digit_landings_within_one_frame':all(x['within_one_frame'] for x in landings),
        'video_starts_near_zero':abs(float(video.get('start_time',0)))<frame}
    return {'actual_duration_seconds':duration,'authored_duration_seconds':timeline['duration'],
        'fps':fps,'frame_seconds':frame,'resolution':[video['width'],video['height']],
        'declared_container_frame_count':video.get('nb_frames'),
        'frame_count_note':'Container metadata only; full decoded frame count belongs to the separate media QA.',
        'checks':checks,'landings':landings,'clock_passed':all(checks.values())}

def rectilinear_filter(yaw):
    # FFmpeg v360 positive yaw samples positive equirectangular longitude,
    # matching the compositor's right(+90)/left(-90) wall convention.
    return f'v360=input=equirect:output=flat:yaw={yaw}:pitch=0:h_fov=90:w=960:h=540'

def capture(video,path,at,yaw):
    result=run(['ffmpeg','-hide_banner','-v','error','-n','-ss',f'{at:.9f}',
        '-i',str(video),'-map','0:v:0','-an','-vf',rectilinear_filter(yaw),
        '-frames:v','1','-q:v','2','-update','1',str(path)])
    require(path.is_file() and path.stat().st_size>0,'Frame extraction did not produce evidence')
    return {'file':relative(path),'sha256':sha256(path),'bytes':path.stat().st_size,
        'requested_sample_seconds':at,'intended_yaw_degrees':yaw,
        'ffmpeg_yaw_degrees':yaw,'pitch_degrees':0,'horizontal_fov_degrees':90,
        'resolution':[960,540],'projection':'rectilinear from actual encoded equirectangular pixels',
        'readability_review':'pending; image presence does not prove clue readability'}

def evidence_plan(timeline,game,clock):
    plan=[]
    for item in clock['landings']:
        plan.append({'kind':'digit_landing','key':item['key'],'chapter':item['chapter'],
            'at':item['encoded_percentage_seconds']+.65,'yaw':0,
            'filename':f"key_{item['key']}_landing_front.jpg"})
    for index,challenge in enumerate(game['challenges']):
        at=challenge['start']+6
        require(at<challenge['end'] and at<timeline['duration'],'Clue sample is outside its challenge')
        scene=next((s for s in timeline['scenes'] if s['start']<=at<s['end']),None)
        require(scene is not None,'Clue sample has no authored scene')
        matches=[(w,o) for w in scene['walls'] for o in w['objects'] if o['id']==challenge['clue_id']]
        require(len(matches)==1,'Clue sample needs one unambiguous spatial object')
        wall,obj=matches[0];wall_index=wall['index']
        plan.append({'kind':'primary_clue','challenge':challenge['id'],'clue_id':obj['id'],
            'scene':scene['id'],'wall_index':wall_index,'authored_text':obj.get('text',''),
            'at':at,'yaw':WALL_YAWS[wall_index],
            'filename':f'clue_{index+1}_wall_{wall_index}.jpg'})
    require(all(0<=x['at']<clock['actual_duration_seconds'] for x in plan),'Evidence frame outside actual movie')
    return plan

def paths(episode,video,output):
    episode=episode.resolve();video=video.resolve();output=output.resolve()
    require(episode.is_relative_to(PROJECT/'episodes') and episode.is_dir(),'Use an isolated episode folder')
    require(video.is_relative_to(PROJECT) and video.is_file(),'Use an existing isolated video file')
    require(output.is_relative_to(PROJECT) and output.suffix=='.json','Save a new JSON report inside the isolated project')
    frames=output.with_name(output.stem+'_frames')
    require(not output.exists() and not frames.exists(),'Report or frame folder already exists; choose a new revision filename')
    return episode,video,output,frames

def make_report(episode,video,output):
    episode,video,output,frames=paths(episode,video,output)
    sources={'timeline':episode/'storyboard/timeline.json','gameplay':episode/'gameplay/manifest.json'}
    source_hashes={name:sha256(path) for name,path in sources.items()}
    timeline=json.loads(sources['timeline'].read_text());game=json.loads(sources['gameplay'].read_text())
    media=probe(video);clock=inspect_clock(timeline,game,media)
    require(clock['clock_passed'],'Encoded movie clock or spherical shape disagrees with the authored digit contract')
    plan=evidence_plan(timeline,game,clock)
    output.parent.mkdir(parents=True,exist_ok=True)
    # Exclusive creation prevents accidental report reuse even between concurrent runs.
    with output.open('x') as handle:handle.write('{}\n')
    frames.mkdir()
    report={'created_utc':datetime.now(timezone.utc).isoformat(),
        'episode':relative(episode),'video':relative(video),'video_sha256':sha256(video),
        'video_bytes':video.stat().st_size,'clock':clock,'captures':[],
        'sources':{name:{'file':relative(path),'sha256':source_hashes[name]} for name,path in sources.items()},
        'contracts':{'navigation':game['navigation'],
            'challenges':[{k:c.get(k) for k in ['id','start','end','clue_id','solution','solution_key','retry_key','alternative_keys','valid_destinations','alternative_outcomes']} for c in game['challenges']]},
        'completed':False,'youtube_verified':False,'human_readability_review':'pending',
        'limitations':['Ideal percentage positions are calculated from the actual container duration; native YouTube seeking still needs an upload test.',
            'Only selected encoded frames are decoded here. Full decode/audio QA is recorded separately.',
            'Front landing samples do not guarantee a viewer faces front; native viewpoint orientation is preserved.',
            'Frame extraction and hashes do not establish artistic quality, readability or actual player interaction.']}
    try:
        for item in plan:
            image=capture(video,frames/item['filename'],item['at'],item['yaw'])
            report['captures'].append({**{k:v for k,v in item.items() if k not in ['filename','at','yaw']},**image})
        require(all(sha256(path)==source_hashes[name] for name,path in sources.items()),'Source contract changed during evidence capture')
        require(sha256(video)==report['video_sha256'],'Video changed during evidence capture')
        report['completed']=True
    except Exception as error:
        report['error']=str(error)
        raise
    finally:
        output.write_text(json.dumps(report,indent=2)+'\n')
    return report

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--episode',type=Path,required=True)
    parser.add_argument('--video',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    try:
        report=make_report(args.episode,args.video,args.output)
        print(json.dumps({'completed':report['completed'],'clock_passed':report['clock']['clock_passed'],
            'captures':len(report['captures']),'report':str(args.output.resolve()),'youtube_verified':False},indent=2))
    except (ValueError,KeyError,OSError,subprocess.CalledProcessError,StopIteration) as error:
        parser.exit(1,f'{error}\n')

if __name__=='__main__':main()
