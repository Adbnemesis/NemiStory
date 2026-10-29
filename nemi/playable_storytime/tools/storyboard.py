#!/usr/bin/env python3
"""Join authored story, actual stage cues and spatial/gameplay data for review."""
import argparse,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser();p.add_argument('--episode',type=Path,default=ROOT/'episodes/episode_001');a=p.parse_args();ep=a.episode.resolve()
    if not ep.is_relative_to(ROOT):p.error('Use an isolated episode folder.')
    story=json.loads((ep/'scripts/story.json').read_text());timeline=json.loads((ep/'storyboard/timeline.json').read_text());stage=json.loads((ep/'scene.json').read_text());game=json.loads((ep/'gameplay/manifest.json').read_text())
    records=[]
    for ch,room in zip(story['chapters'],timeline['scenes']):
        start,end=ch['start'],ch['end']
        records.append(dict(scene_id=ch['id'],start=start,end=end,narrative_objective=ch['focus'],voiceover=ch['lines'],characters=['nemi'],
            expressions_actions=[x for actor in stage['actors'] for x in actor['performances'] if start<=x['at']<end],
            camera=dict(upload='Viewer controls orientation; no forced turn/reset',director_review=room['review_yaw_path'],fov=room['review_fov']),
            spatial_layout=room['walls'],environment_events=room.get('environment_events',[]),
            props=[x for x in stage['props'] if start<=x['at']<end],ink=[x for x in stage['drawings'] if start<=x['at']<end],
            sound=[x for x in stage['sfx'] if start<=x['at']<end],vfx=[x for x in stage['vfx'] if start<=x['at']<end],
            music=stage.get('music',[]),transition='Exact chapter-clock location cut; viewer orientation persists',
            gameplay=[x for x in game['challenges'] if x['start']<end and x['end']>start],
            accessibility='Pause/retry freely; narration supplies directions and eventual answers; complete optional SRT uses measured utterance bounds',
            dependencies=['scene.json','audio/narration.wav','audio/render_timeline.json','assets/locations.json','gameplay/challenges.json']))
    (ep/'storyboard/storyboard.json').write_text(json.dumps(dict(duration=story['duration'],fps=story['fps'],scenes=records),ensure_ascii=False,indent=2)+'\n')
    (ep/'metadata/chapters.txt').write_text('\n'.join(f"{int(x['start'])//60}:{int(x['start'])%60:02d} {x['name']}" for x in story['chapters'])+'\n')
    print('Saved complete joined storyboard and exact chapter markers.')
if __name__=='__main__':main()
