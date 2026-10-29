"""Validate authored native-view joins, including the actor's real endpoint."""
import math


def require(value, message):
    if not value:
        raise ValueError(message)


def finite(value):
    return type(value) in (int, float) and math.isfinite(value)


def object_on(scene, identity):
    found = [(wall['index'], obj) for wall in scene['walls']
             for obj in wall['objects'] if obj['id'] == identity]
    require(len(found) == 1, 'Continuous landmark must exist exactly once in both adjacent scenes')
    return found[0]


def endpoint(scene, shot, at):
    actor = shot['actors']['nemi']
    point = list(actor['position'])
    transport = scene.get('actor_transport')
    if transport:
        _, vehicle = object_on(scene, transport['object'])
        path = vehicle['path']
        require(path[-1]['at'] <= at, 'Continuous join precedes completion of its vehicle path')
        point = [point[axis] + path[-1]['position'][axis] - path[0]['position'][axis]
                 for axis in [0, 1]]
    return point, actor['scale']


def validate_natural_joins(timeline, spec=None):
    joins = timeline.get('natural_continuity', [])
    require(isinstance(joins, list), 'Natural continuity must be an array')
    if not joins:
        return []
    require(timeline.get('world_renderer') == 'drawing', 'Natural continuity needs the drawing world')
    scenes = {scene['id']: scene for scene in timeline['scenes']}
    previous = -1
    for join in joins:
        require(isinstance(join, dict) and set(join) == {
            'at', 'from_scene', 'to_scene', 'actor_wall', 'position', 'landmark'},
            'Natural join needs exact adjacent scenes, actor wall/position and landmark')
        at = join['at']
        require(finite(at) and at > previous, 'Natural joins need increasing finite times')
        before, after = scenes.get(join['from_scene']), scenes.get(join['to_scene'])
        require(before is not None and after is not None and before['end'] == at == after['start'],
                'Natural join must name adjacent scene boundaries')
        require(type(join['actor_wall']) is int and 0 <= join['actor_wall'] <= 3
                and before.get('actor_wall', 0) == after.get('actor_wall', 0) == join['actor_wall'],
                'Natural join changes Nemi sphere sector')
        require(isinstance(join['position'], list) and len(join['position']) == 2
                and all(finite(value) for value in join['position']),
                'Natural join requires a finite local actor position')
        old_wall, old_landmark = object_on(before, join['landmark'])
        new_wall, new_landmark = object_on(after, join['landmark'])
        require(old_wall == new_wall and old_landmark['kind'] == new_landmark['kind']
                and old_landmark['x'] == new_landmark['x'],
                'Natural join loses or swaps its material landmark')
        held_flag = {'page_tear': 'opened', 'paper_tab': 'folded'}.get(new_landmark['kind'])
        if held_flag:
            require(new_landmark.get(held_flag) is True,
                    'Natural join must retain the completed material state')
        require('entry_card' not in after, 'Natural continuation must not introduce a new round card')
        if spec is not None:
            old_shots = [shot for shot in spec['shots'] if shot['start'] < at <= shot['end']]
            new_shots = [shot for shot in spec['shots'] if shot['start'] <= at < shot['end']]
            require(len(old_shots) == len(new_shots) == 1, 'Natural join needs unambiguous shot coverage')
            point, scale = endpoint(before, old_shots[0], at)
            incoming = new_shots[0]['actors']['nemi']
            require(point == incoming['position'] == join['position'] and scale == incoming['scale'],
                    'Natural join teleports Nemi from her crossing or vehicle endpoint')
        previous = at
    return joins
