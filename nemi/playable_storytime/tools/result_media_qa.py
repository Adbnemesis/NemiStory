#!/usr/bin/env python3
"""Save orientation/result evidence from the exact encoded playable movie.

Captures every numbered entry from four preserved cardinal viewpoints and
the authored actor wall after the entry hold. This records pixels and clock
evidence; it does not use OCR or automatically approve readability/player UX.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess

from digit_media_qa import (PROJECT, WALL_YAWS, capture, inspect_clock, paths,
    probe, relative, require, sha256)
from validate_episode import actor_wall

GUIDES={0:'NEMI IS HERE',1:'TURN LEFT TO NEMI',2:'TURN AROUND TO NEMI',3:'TURN RIGHT TO NEMI'}
DRAWING_GUIDES={0:'HERE',1:'TURN RIGHT →',2:'TURN AROUND',3:'← TURN LEFT'}

def choice_target_table(timeline,targets):
    choices=[];prompts=timeline.get('interaction_scenes')
    require(isinstance(prompts,list) and len(prompts)==10,'Result evidence needs every interaction prompt')
    for prompt in prompts:
        for choice in prompt['choices']:
            target=targets[choice['key']]
            require(choice['chapter']==target['chapter'],'Choice target does not match encoded digit destination')
            choices.append({'from_chapter':prompt['id'],'choice_key':choice['key'],
                'choice_label':choice['label'],**{key:value for key,value in target.items() if key!='key'}})
    return choices

def drawing_result_plan(timeline,clock):
    """Sparse result cards and side actors are source facts, not missing art."""
    scenes={scene['id']:scene for scene in timeline['scenes']}
    require(len(scenes)==10 and len(clock['landings'])==10,'Result evidence requires all ten digit scenes')
    captures=[];targets={};frame=clock['frame_seconds']
    for landing in clock['landings']:
        scene=scenes[landing['chapter']];card=scene.get('entry_card');wall=actor_wall(scene)
        if card is not None:
            require(isinstance(card,dict) and bool(card),'Drawing entry card must be a nonempty object when present')
            duration=card.get('duration')
            require(type(duration) in [int,float] and 2<=duration<=4,'Entry card duration must be 2–4 seconds')
        else:duration=None
        actual=landing['encoded_percentage_seconds'];delta=abs(actual-scene['start'])
        require(delta<frame,'Encoded entry landing differs by at least one frame')
        entry_sample=actual+.8
        require(scene['start']<=entry_sample<scene['end'],'Entry evidence must be inside its scene')
        if duration is not None:
            require(entry_sample<scene['start']+duration,'Entry evidence must be inside the card hold')
        return_sample=actual+(duration+.3 if duration is not None else 3.3)
        require((scene['start']+duration if duration is not None else scene['start'])<return_sample<scene['end'],
            'Actor return sample must be after any card hold and inside its scene')
        require(return_sample<clock['actual_duration_seconds'],'Actor return sample is outside the actual movie')
        target={'key':landing['key'],'chapter':scene['id'],'encoded_percentage_seconds':actual,
            'authored_start_seconds':scene['start'],'landing_delta_seconds':delta,
            'landing_delta_frames':delta*clock['fps'],'entry_card_present':duration is not None,
            'entry_card_duration_seconds':duration,'target_actor_wall':wall}
        if duration is not None:
            target.update(expected_entry_title=card['title'],expected_entry_subtitle=card['subtitle'])
        targets[landing['key']]=target
        for wall_index,yaw in WALL_YAWS.items():
            item={'kind':'entry_view','key':landing['key'],'chapter':scene['id'],
                'wall_index':wall_index,'target_actor_wall':wall,'entry_card_present':duration is not None,
                'expected_direction_guide':DRAWING_GUIDES[(wall-wall_index)%4] if duration is not None else None,
                'expected_picture':'Inspect the authored drawing-world entry and canonical actor location; no card text is expected when the source has no card.',
                'at':entry_sample,'yaw':yaw,'filename':f"key_{landing['key']}_entry_wall_{wall_index}.jpg"}
            if duration is not None:item.update(expected_title=card['title'],expected_subtitle=card['subtitle'])
            captures.append(item)
        item={'kind':'actor_return','key':landing['key'],'chapter':scene['id'],
            'wall_index':wall,'target_actor_wall':wall,
            'expected_picture':'Inspect the current canonical performance on its authored actor wall after any entry card ends.',
            'sample_basis':'after_entry_card' if duration is not None else 'scene_start_plus_3.3_seconds',
            'at':return_sample,'yaw':WALL_YAWS[wall],
            'filename':f"key_{landing['key']}_actor_return_wall_{wall}.jpg"}
        if duration is not None:item['entry_ended_at_authored_seconds']=scene['start']+duration
        captures.append(item)
    return captures,choice_target_table(timeline,targets)

def result_plan(timeline,game,clock):
    require(clock.get('clock_passed') is True,'Encoded clock must pass before result evidence capture')
    if timeline.get('world_renderer')=='drawing':return drawing_result_plan(timeline,clock)
    scenes={scene['id']:scene for scene in timeline['scenes']}
    require(len(scenes)==10 and len(clock['landings'])==10,'Result evidence requires all ten digit scenes')
    captures=[];targets={};frame=clock['frame_seconds']
    for landing in clock['landings']:
        scene=scenes[landing['chapter']];card=scene.get('entry_card')
        require(isinstance(card,dict) and bool(card),'Every digit scene needs an entry card')
        duration=card.get('duration')
        require(type(duration) in [int,float] and 2<=duration<=4,'Entry card duration must be 2–4 seconds')
        actual=landing['encoded_percentage_seconds'];delta=abs(actual-scene['start'])
        require(delta<frame,'Encoded entry landing differs by at least one frame')
        card_sample=actual+.8;return_sample=actual+duration+.3
        require(scene['start']<=card_sample<scene['start']+duration,'Entry evidence must be inside the card hold')
        require(scene['start']+duration<return_sample<scene['end'],
            'Actor return sample must be after the card hold and inside its scene')
        require(return_sample<clock['actual_duration_seconds'],'Actor return sample is outside the actual movie')
        targets[landing['key']]={'key':landing['key'],'chapter':scene['id'],
            'encoded_percentage_seconds':actual,'authored_start_seconds':scene['start'],
            'landing_delta_seconds':delta,'landing_delta_frames':delta*clock['fps'],
            'expected_entry_title':card['title'],'expected_entry_subtitle':card['subtitle'],
            'entry_card_duration_seconds':duration}
        for wall_index,yaw in WALL_YAWS.items():
            captures.append({'kind':'entry_card','key':landing['key'],'chapter':scene['id'],
                'wall_index':wall_index,'expected_title':card['title'],'expected_subtitle':card['subtitle'],
                'expected_direction_guide':GUIDES[wall_index],
                'expected_picture':'Baked entry receipt and direction guide; inspect character visibility against this revision’s composition',
                'at':card_sample,'yaw':yaw,'filename':f"key_{landing['key']}_entry_wall_{wall_index}.jpg"})
        captures.append({'kind':'actor_return','key':landing['key'],'chapter':scene['id'],
            'wall_index':0,'expected_picture':'Entry receipt ended; inspect current canonical performance picture and the transition boundary',
            'entry_ended_at_authored_seconds':scene['start']+duration,
            'at':return_sample,'yaw':0,'filename':f"key_{landing['key']}_actor_return_front.jpg"})
    return captures,choice_target_table(timeline,targets)

def make_report(episode,video,output):
    episode,video,output,frames=paths(episode,video,output)
    sources={'timeline':episode/'storyboard/timeline.json','gameplay':episode/'gameplay/manifest.json'}
    if (episode/'scene.json').is_file():sources['production_scene']=episode/'scene.json'
    hashes={name:sha256(path) for name,path in sources.items()}
    timeline=json.loads(sources['timeline'].read_text());game=json.loads(sources['gameplay'].read_text())
    clock=inspect_clock(timeline,game,probe(video))
    plan,choices=result_plan(timeline,game,clock)
    output.parent.mkdir(parents=True,exist_ok=True)
    with output.open('x') as handle:handle.write('{}\n')
    frames.mkdir()
    entry_count_name='entry_views' if timeline.get('world_renderer')=='drawing' else 'entry_card_views'
    report={'created_utc':datetime.now(timezone.utc).isoformat(),'episode':relative(episode),
        'video':relative(video),'video_sha256':sha256(video),'video_bytes':video.stat().st_size,
        'sources':{name:{'file':relative(path),'sha256':hashes[name]} for name,path in sources.items()},
        'clock':clock,'choice_target_table':choices,'captures':[],
        'expected_capture_counts':{entry_count_name:40,'actor_return_views':10,'total':50},
        'orientation_contract':{'preserve_viewer_orientation':True,
            'capture_yaws_degrees':[0,90,180,-90],
            'meaning':'Each entry is independently sampled at the same four fixed viewpoints; capture never recenters a native player.',
            'native_player_orientation_verified':False},
        'completed':False,'youtube_verified':False,'human_readability_review':'pending',
        'actor_return_visual_review':'pending',
        'limitations':['Expected text comes from source contracts; it is not an OCR result or proof that the text is visible.',
            'Selected actual movie frames provide review evidence. They do not automatically approve card readability or actor visibility.',
            'Four cardinal views do not establish readability at every off-axis angle or pitch.',
            'Actual YouTube seeking, orientation persistence and mobile controls still need a platform test.',
            'Full movie decode, audio listening and overall pacing review are separate checks.']}
    try:
        for item in plan:
            image=capture(video,frames/item['filename'],item['at'],item['yaw'])
            report['captures'].append({**{key:value for key,value in item.items() if key not in ['at','yaw','filename']},**image})
        require(all(sha256(path)==hashes[name] for name,path in sources.items()),'Source changed during result evidence capture')
        require(sha256(video)==report['video_sha256'],'Encoded video changed during result evidence capture')
        report['completed']=True
    except Exception as error:
        report['error']=str(error)
        raise
    finally:
        report['capture_counts']={entry_count_name:sum(item['kind'] in ['entry_card','entry_view'] for item in report['captures']),
            'actor_return_views':sum(item['kind']=='actor_return' for item in report['captures']),
            'total':len(report['captures'])}
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
            'captures':len(report['captures']),'choices':len(report['choice_target_table']),
            'report':str(args.output.resolve()),'youtube_verified':False},indent=2))
    except (ValueError,KeyError,OSError,subprocess.CalledProcessError,StopIteration) as error:
        parser.exit(1,f'{error}\n')

if __name__=='__main__':main()
