#!/usr/bin/env python3
"""Compile this nonplayable audition from verified final voice measurements."""
import json
import sys
from pathlib import Path

EPISODE = Path(__file__).resolve().parents[1]
PROJECT = EPISODE.parents[1]
sys.dont_write_bytecode = True
sys.path.insert(0, str(PROJECT / 'tools'))
from prepare_episode import prepare, save


def build():
    prepare(EPISODE)
    spec_path = EPISODE / 'scene.json'
    if not spec_path.exists():
        return
    spec = json.loads(spec_path.read_text())
    timeline_path = EPISODE / 'storyboard/timeline.json'
    timeline = json.loads(timeline_path.read_text())
    timeline.update(kind='audition', playable=False, world_renderer='drawing', world_continuity=True)
    story = json.loads((EPISODE / 'scripts/story.json').read_text())
    for chapter, segment in zip(story['chapters'], timeline['scenes']):
        segment['actor_wall'] = chapter.get('actor_wall', 0)
        if segment['actor_wall']:
            segment['review_camera_beats'].insert(0, dict(
                at=chapter['start'], yaw=chapter['review_yaw'], pitch=0,
                fov=68, duration=0,
                intent='Authored cut starts already facing the chosen side sector.'
            ))
    for shot in spec['shots']:
        shot['actors']['nemi'].update(position=[960, 620], scale=1.4)
        if shot['id'] == 'the_door_was_only_ink':
            shot['actors']['nemi']['position'] = [900, 620]
        elif shot['id'] == 'there_is_space_beyond':
            shot['actors']['nemi']['position'] = [1000, 620]
    # One deliberate blink after an admission, and one after real relief.
    # These are final scene-clock measurements, not repeating blink timers.
    for cue in spec['actors'][0]['performances']:
        if cue.get('event') in ['acting_door_deadpan', 'acting_tear_relief']:
            cue['blinks'] = [round(cue['at'] + .65, 6)]
    # This is a storyboard comparison. The existing full player remains R9.
    save(spec_path, spec)
    save(timeline_path, timeline)
    (EPISODE / 'README.md').write_text(
        '# Drawing escape — voice and storyboard audition\n\n'
        'A 40-second spatial audition with canonical Nemi/Sohee. Click and drag with a mouse, '
        'or swipe on a phone, to discover the separate left door and right paper tear. '
        'The local preview turns toward the selected exit and plays its outcome with 1/2 '
        '(20/30 seconds); Restart returns forward. The MP4 has no native YouTube percentage '
        'map at this shortened duration, and the local automatic turn is not a YouTube feature. '
        'The current R9 playable preview and all earlier media remain preserved.\n'
    )


if __name__ == '__main__':
    build()
