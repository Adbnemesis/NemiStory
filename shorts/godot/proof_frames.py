"""Frames to inspect settled poses and every finite transition boundary."""
def settled_frame(config, shot):
    next_cut = next((s['frame'] for s in config['shots'] if s['frame'] > shot['frame']), config['frames'])
    settle = max(7, shot.get('settle', 5), shot.get('transition', {}).get('duration', 0))
    return min(next_cut - 1, shot['frame'] + settle + 2)


def pose_frames(config):
    return sorted({0, config['frames'] - 1, *(settled_frame(config, shot) for shot in config['shots'])})


def transition_frames(config):
    selected = [s for s in config['shots'] if 'transition' in s]
    frames = set()
    for shot in selected:
        at = shot['frame']; duration = shot['transition']['duration']
        frames.update((max(0, at-1), at, at+duration//2, at+duration-1, at+duration, settled_frame(config,shot)))
    return sorted(f for f in frames if f < config['frames'])


def motion_frames(config):
    """Inspect path extrema and the late pose; a settled still misses ongoing motion."""
    frames = set()
    for i, shot in enumerate(config['shots']):
        end = config['shots'][i+1]['frame'] if i+1<len(config['shots']) else config['frames']
        frames.update((settled_frame(config,shot), (shot['frame']+end)//2, end-1))
        for key in shot.get('camera',{}).get('keys',[]):frames.add(key['frame'])
    return sorted(f for f in frames if 0<=f<config['frames'])
