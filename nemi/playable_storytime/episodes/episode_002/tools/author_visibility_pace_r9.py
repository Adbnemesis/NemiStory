#!/usr/bin/env python3
"""R9: clearer physical materials and a shorter, exact-percentage clock."""
import copy
import json
from pathlib import Path

E = Path(__file__).resolve().parents[1]
SOURCE = E / 'review/revisions/r8_before_visibility_pace/episode'
RATIO = 22 / 24
TEMPOS = dict(
    drawing_hook=1.08, phone_chapter_hint=1.08, door_admission=1.08,
    door_recovery=1.10, door_pursuit=1.12, tear_discovery=1.08,
    desk_beyond=1.12, bridge_choice=1.15, bridge_failure=1.10,
    bridge_pursuit=1.08, fold_cross=1.12, paper_safety=1.05,
    eraser_choice=1.10, race_failure=1.12, ride_commit=1.00,
    eraser_ride=1.10, ride_land=1.08, studio_ending=1.08)


def save(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')


def clock(t):
    return round(t * RATIO, 6)


def author():
    story = json.loads((SOURCE / 'scripts/story.json').read_text())
    locations = json.loads((SOURCE / 'assets/locations.json').read_text())
    gameplay = json.loads((SOURCE / 'gameplay/challenges.json').read_text())
    story.update(revision='r9_visibility_pace', duration=220,
        media_basename='NEMI_Playable_EP002_r9_2160x1080_360_REVIEW.mp4')
    for chapter in story['chapters']:
        chapter['start'], chapter['end'] = clock(chapter['start']), clock(chapter['end'])
        for line in chapter['lines']:
            line['at'], line['window_end'] = clock(line['at']), clock(line['window_end'])
            line['tempo'] = TEMPOS[line['id']]
        for event in chapter.get('environment_events', []):
            # Named events move to fresh measured words in prepare_episode.
            # Their finite physical duration remains authored, including the
            # same eight-second eraser paths used by build_full_game.
            length = event['end'] - event['at']
            event['at'] = clock(event['at'])
            event['end'] = round(event['at'] + length, 6)
    for prompt in story['interaction_scenes']:
        prompt['start'], prompt['end'] = clock(prompt['start']), clock(prompt['end'])
    for field in ['natural_continuity', 'preview_handoffs']:
        for item in story[field]:
            item['at'] = clock(item['at'])
    gameplay['duration'] = 220
    gameplay['interaction_scenes'] = copy.deepcopy(story['interaction_scenes'])
    for challenge in gameplay['challenges']:
        challenge['start'], challenge['end'] = clock(challenge['start']), clock(challenge['end'])
        for key in ['valid_destinations', 'alternative_outcomes']:
            challenge[key] = [clock(t) for t in challenge[key]]
    for route in gameplay['routes']:
        route['times'] = [clock(t) for t in route['times']]
    # Each connected location retains its material landmarks. These are
    # physical context only: no new choice, inventory or secret solution.
    def prop(identity, kind, x, y):
        return dict(id=identity, author='nemi', kind=kind, x=x, y=y, text='')
    def add(location, wall, *items):
        next(w for w in locations[location] if w['index'] == wall)['objects'].extend(items)
    add('page_room', 2, prop('drawing_ruler', 'ruler', 1200, 905))
    add('gap_room', 0, prop('bridge_ink_bottle', 'ink_bottle', 610, 905))
    for location in ['gap_room', 'edge_choice', 'edge_failure', 'edge_ride']:
        add(location, 2,
            prop('real_paper_stack', 'paper_stack', 1420, 905),
            prop('stack_paper_clip', 'paper_clip', 1440, 745))
    save(E / 'scripts/story.json', story)
    save(E / 'assets/locations.json', locations)
    save(E / 'gameplay/challenges.json', gameplay)
    print('R9 authored: 220 seconds, exact22-second percentage blocks; unchanged route and voice words.')


if __name__ == '__main__':
    author()
