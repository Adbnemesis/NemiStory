#!/usr/bin/env python3
"""Author R7 from the preserved R6 story, retaining exact recorded dialogue."""
import copy
import json
from pathlib import Path

E = Path(__file__).resolve().parents[1]
SOURCE = E / 'review/revisions/r6_before_continuity/episode'


def save(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')


def wrap(yaw):
    return (yaw + 180) % 360 - 180


def author():
    story = json.loads((SOURCE / 'scripts/story.json').read_text())
    locations = json.loads((SOURCE / 'assets/locations.json').read_text())
    gameplay = json.loads((SOURCE / 'gameplay/challenges.json').read_text())
    phase = [0, 0, 0, 1, 1, 1, 2, 2, 2, 3]
    positions = [[960, 620], [900, 620], [1000, 620], [1000, 620],
                 [900, 620], [1000, 620], [320, 620], [900, 620],
                 [650, 620], [1150, 620]]
    goal = 'Get Nemi to the desk beyond the page.'
    story.update(revision='r7_continuity',
                 media_basename='NEMI_Playable_EP002_r7_2160x1080_360_REVIEW.mp4',
                 preview_goal=goal)
    story['direction']['choice'] = 'Keep following one physical escape route; inspect the next obstruction and choose an action.'
    for index, chapter in enumerate(story['chapters']):
        rotation = phase[index] * 90
        chapter['actor_wall'] = (chapter['actor_wall'] + phase[index]) % 4
        chapter['actor_position'] = positions[index]
        chapter['review_yaw'] = wrap(chapter['review_yaw'] + rotation)
        for beat in chapter.get('camera_beats', []):
            beat['yaw'] = wrap(beat['yaw'] + rotation)
        chapter['framing'] = 'Continue the same escape with a stable actor, floor and material landmark.'
    for index in [3, 6, 9]:
        story['chapters'][index]['camera_beats'][0]['yaw'] = story['chapters'][index-1]['camera_beats'][-1]['yaw']
    story['chapters'][6]['camera_beats'][-1]['yaw'] = 166
    story['chapters'][9]['camera_beats'][1]['yaw'] = -79
    # Her fold arrival and moving eraser endpoint are real authored placements.
    # The following scene inherits them, rather than resetting her to centre.
    story['natural_continuity'] = [
        dict(at=72, from_scene='there_is_space_beyond', to_scene='the_missing_bridge',
             actor_wall=1, position=[1000, 620], landmark='real_tear'),
        dict(at=144, from_scene='the_paper_holds', to_scene='where_is_the_eraser',
             actor_wall=2, position=[320, 620], landmark='loose_tab'),
        dict(at=216, from_scene='the_eraser_lift', to_scene='a_solid_desk',
             actor_wall=3, position=[1150, 620], landmark='destination_desk'),
    ]
    # Enhanced preview assistance only. Natural successful joins need no turn.
    story['preview_handoffs'] = [dict(at=story['chapters'][i]['start'],
        yaw=story['chapters'][i]['review_yaw'], duration=1.2 if i in [2, 5, 8] else .9)
        for i in [1, 2, 4, 5, 7, 8]]
    rotations = dict(page_room=0, gap_room=1, edge_choice=2,
                     edge_failure=2, edge_ride=2, studio=3)
    redundant = {'left_direction', 'right_direction', 'back_direction',
                 'gap_goal', 'edge_goal', 'ride_goal', 'final_title'}
    for location, walls in locations.items():
        for wall in walls:
            wall['index'] = (wall['index'] + rotations[location]) % 4
            wall['objects'] = [obj for obj in wall['objects'] if obj['id'] not in redundant]
        walls.sort(key=lambda wall: wall['index'])
    tear = next(obj for wall in locations['page_room'] for obj in wall['objects']
                if obj['id'] == 'real_tear')
    retained_tear = copy.deepcopy(tear)
    retained_tear.update(opened=True, text='')
    next(w for w in locations['gap_room'] if w['index'] == 1)['objects'].insert(0, retained_tear)
    tab = next(obj for wall in locations['gap_room'] for obj in wall['objects']
               if obj['id'] == 'loose_tab')
    retained_tab = copy.deepcopy(tab)
    retained_tab.update(folded=True, text='')
    for location in ['edge_choice', 'edge_failure', 'edge_ride']:
        next(w for w in locations[location] if w['index'] == 2)['objects'].insert(0, copy.deepcopy(retained_tab))
    # The destination stays on the right of the rider across the Ready? cut.
    desk = next(obj for wall in locations['studio'] for obj in wall['objects'] if obj['id'] == 'desk')
    desk['id'] = 'destination_desk'
    desk['x'] = 1500
    for event in story['chapters'][9].get('environment_events', []):
        if event['object'] == 'desk':
            event['object'] = 'destination_desk'
    feedback = [
        'Look for the two exits. Choose the one you trust.',
        'Let the door attempt play out; the rewind points you to the tear.',
        'Follow the opening toward the desk. The route continues automatically.',
        'The desk is still beyond the gap. Inspect the crossing before choosing.',
        'Let the attempt finish. The paper tab is still available after the rewind.',
        'Stay with Nemi while the fold carries the escape forward.',
        'The same eraser is heading for the desk. Choose how Nemi should follow it.',
        'Wait for the rewind, then use the eraser as a lift.',
        'Stay aboard with Nemi. The ride continues into the ending.',
        'You reached the desk. Press 0 only if you want to play again.',
    ]
    for index, prompt in enumerate(story['interaction_scenes']):
        prompt['objective'] = goal
        prompt['feedback'] = feedback[index]
    gameplay['interaction_scenes'] = copy.deepcopy(story['interaction_scenes'])
    save(E / 'scripts/story.json', story)
    save(E / 'assets/locations.json', locations)
    save(E / 'gameplay/challenges.json', gameplay)
    print('R7 authored: three continuous successful joins; recorded words/clock unchanged.')


if __name__ == '__main__':
    author()
