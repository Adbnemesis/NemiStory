#!/usr/bin/env python3
"""Create a content-only episode from the complete editable first-episode template."""
import argparse,json,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def create(name):
    import re
    if not re.fullmatch(r'episode_[0-9]{3}',name):raise ValueError('Use episode_002, episode_003, etc.')
    target=ROOT/'episodes'/name
    if target.exists():raise ValueError('Episode exists; previous sources are protected.')
    template=ROOT/'templates/episode'
    shutil.copytree(template,target)
    story=json.loads((target/'scripts/story.json').read_text());story['id']=name
    story['episode_id']=name
    story['revision']='r1'
    story['media_basename']=f'NEMI_Playable_EP{name[-3:]}_r1_2160x1080_360_REVIEW.mp4'
    (target/'scripts/story.json').write_text(json.dumps(story,ensure_ascii=False,indent=2)+'\n')
    # A new production gets new reading receipts against the frozen manuals.
    subprocess.run([sys.executable,str(ROOT/'tools/preflight.py'),'init','--episode',name],check=True)
    print(target)
    print('Edit the complete template story, locations and challenge contracts; complete fresh reading before authoring. No old voice/timing was copied.')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('name');a=p.parse_args()
    try:create(a.name)
    except ValueError as e:p.exit(1,str(e)+'\n')
