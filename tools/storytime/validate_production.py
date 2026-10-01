"""Version 2 shot/audio/acting contract. Reuses version 1 core validation."""
import copy
import math
from pathlib import Path

ART = {'laptop','phone','mug','tabs','cloud'}
HANDS = {'nemi': {'relaxed','pointing','fist','open','open_palm_up','finger_count_one','finger_count_two','finger_count_three','splayed_fingers','pinch','hold_prop','hand_to_chest','hand_to_cheek','hand_to_mouth','facepalm','hands_together','grip_strap'},
         'adb': {'relaxed','open_palm','pointing','fist','holding_cup','shrug_open','hand_to_chin'}}

def validate_production(spec, root, core_validate, check_assets=True):
    def require(ok,message):
        if not ok: raise ValueError(message)
    def keys(obj,allowed,where):
        require(isinstance(obj,dict),f'{where}: expected an object')
        require(not set(obj)-set(allowed.split()),f'{where}: unknown fields {sorted(set(obj)-set(allowed.split()))}')
    def num(v): return isinstance(v,(int,float)) and not isinstance(v,bool) and math.isfinite(v)
    def point(v): return isinstance(v,list) and len(v)==2 and all(num(n) for n in v)
    def media(path,where):
        require(isinstance(path,str) and path.startswith('res://'),f'{where}: res:// audio path required')
        resolved=(root/path[6:]).resolve()
        require(resolved.is_relative_to(root) and resolved.suffix.lower() in {'.wav','.mp3','.ogg'},f'{where}: unsupported/outside-workspace audio')
        if check_assets: require(resolved.is_file(),f'{where}: missing audio; regenerate/fetch the declared asset first: {path}')
    keys(spec,'version title duration fps audio actors shots drawings props vfx sfx script captions events','scene')
    require(isinstance(spec.get('shots'),list) and spec['shots'],'shots are required')
    require(isinstance(spec.get('actors'),list) and spec['actors'],'actors are required')
    require(isinstance(spec.get('script'),list),'script must contain ordered spoken turns')
    duration=spec.get('duration'); require(num(duration) and duration>0,'duration must be positive')
    ids={}; normalized=copy.deepcopy(spec)
    normalized['version']=1
    for i,actor in enumerate(normalized['actors']):
        keys(actor,'id author performances mouths',f'actor {i}')
        require(isinstance(actor.get('id'),str) and actor['id'] and actor['id'] not in ids,f'actor {i}: unique id required')
        ids[actor.pop('id')]=actor.get('author')
        actor['position']=[0,0]; actor['scale']=1
        for cue in actor.get('performances',[]):
            keys(cue,'at recipe duration blinks gaze hands grounded',f'actor {i} performance')
            require(isinstance(cue.get('grounded',True),bool),'grounded must be a boolean')
            if 'gaze' in cue: require(point(cue['gaze']) and max(abs(v) for v in cue['gaze'])<=1,'gaze must be normalized [x,y]')
            hands=cue.get('hands',{}); keys(hands,'left right','hands')
            require(actor.get('author') in HANDS,'actor author must be nemi or adb')
            for value in hands.values(): require(value in HANDS[actor['author']],f'Unknown {actor["author"]} hand shape: {value}')
            for field in ['gaze','hands','grounded']: cue.pop(field,None)
    events={}
    for event in spec.get('events',[]):
        keys(event,'id at intent','event')
        require(isinstance(event.get('id'),str) and event['id'] not in events and num(event.get('at')) and 0<=event['at']<duration and isinstance(event.get('intent'),str),'event needs unique id, at and intent')
        events[event['id']]=event['at']
    def timing_event(item):
        if 'event' in item:
            require(item['event'] in events and num(item.get('at')) and abs(item['at']-events[item['event']])<1e-6,'event-linked cues must share the declared event time')
    previous=0; shot_ids=set()
    for shot in spec['shots']:
        keys(shot,'id start end background actors camera','shot')
        require(isinstance(shot.get('id'),str) and shot['id'] not in shot_ids,'shot ids must be unique strings')
        shot_ids.add(shot['id'])
        require(num(shot.get('start')) and num(shot.get('end')) and abs(shot['start']-previous)<1e-6 and shot['start']<shot['end']<=duration,'shots must cover the scene in order, without gaps/overlaps')
        previous=shot['end']
        require(shot.get('background') in {'paper','room','thought','evening'},'Unknown background')
        require(isinstance(shot.get('actors'),dict),'shot actors must be an id → placement object')
        for id,placement in shot['actors'].items():
            require(id in ids,f'Unknown shot actor: {id}')
            keys(placement,'position scale','placement')
            require(point(placement.get('position')) and num(placement.get('scale')) and 0<placement['scale']<=4,'placement needs position and positive scale <=4')
        camera=shot.get('camera',{}); keys(camera,'center zoom','camera')
        require(point(camera.get('center',[960,540])) and num(camera.get('zoom',1)) and .5<=camera.get('zoom',1)<=3,'invalid camera')
    require(abs(previous-duration)<1e-6,'last shot must end at scene duration')
    # Annotations must belong to a visible speaker and use the same frame clock.
    captions=[]; previous=0
    for turn in spec['script']:
        keys(turn,'actor start end text','script turn')
        require(turn.get('actor') in ids,'script actor must exist')
        require(num(turn.get('start')) and num(turn.get('end')) and previous<=turn['start']<turn['end']<=duration,'script turns must be ordered and nonoverlapping')
        require(isinstance(turn.get('text'),str) and turn['text'],'script text required')
        previous=turn['end']
    for actor in spec['actors']:
        for mouth in actor.get('mouths',[]):
            require(any(turn['actor']==actor['id'] and turn['start']<=mouth['start']<mouth['end']<=turn['end'] for turn in spec['script']),'mouth cue must stay within its speaker turn')
            visible_time=sum(max(0,min(shot['end'],mouth['end'])-max(shot['start'],mouth['start'])) for shot in spec['shots'] if actor['id'] in shot['actors'])
            require(visible_time>=mouth['end']-mouth['start']-1e-6,'mouth cue belongs to an invisible actor')
    # Captions are separate cards so a spoken turn can exceed five words.
    normalized['captions']=spec.get('captions',[])  # accepted below; kept outside script
    drawings=[]
    import json
    profiles={a:json.loads((root/f'common/storytime/profiles/{a}.json').read_text()) for a in set(ids.values())}
    for group in ['drawings','props']:
        require(isinstance(spec.get(group,[]),list),f'{group} must be a list')
        for i,item in enumerate(spec.get(group,[])):
            keys(item,'author kind position at duration end scale tilt accent text size variant mode layer shots attach event',f'{group} {i}')
            timing_event(item)
            require(item.get('author') in profiles,f'{group} {i}: author must have an actor')
            allowed=set(profiles[item['author']]['marks'])|ART|{'text'}
            require(item.get('kind') in allowed,f'{group} {i}: unknown art kind')
            require(item.get('mode','hold') in {'hold','live'},'mode must be hold or live')
            if group=='props': require(item.get('mode','hold')=='hold','props use hold; live geometry belongs in drawings')
            if item.get('mode','hold')=='live': require('duration' in item,'live drawing duration is required')
            if 'shots' in item: require(isinstance(item['shots'],list) and set(item['shots'])<=shot_ids,'unknown drawing shot')
            require(isinstance(item.get('layer',2),int) and -10<=item.get('layer',2)<=10,'layer must be -10..10')
            if 'attach' in item:
                attach=item['attach']; keys(attach,'actor hand grip angle socket','attachment')
                require(attach.get('actor') in ids and attach.get('hand') in {'left','right'} and point(attach.get('grip')) and num(attach.get('angle',0)) and point(attach.get('socket',[0,8])),'attachment needs actor, hand and grip')
                require(ids[attach['actor']]==item['author'],'attachment author must match its actor')
            copy_item={k:v for k,v in item.items() if k not in {'mode','layer','shots','attach','event'}}
            copy_item.setdefault('duration',min(.1,item.get('end',0)-item.get('at',0)))
            copy_item.setdefault('position',[0,0])
            if copy_item['kind'] in ART: copy_item['kind']='notebook'
            drawings.append(copy_item)
    normalized['drawings']=drawings
    normalized['audio']=spec.get('audio') if check_assets else None
    for key in ['shots','props','vfx','sfx','script','events']: normalized.pop(key,None)
    core_validate(normalized)
    require(not spec['script'] or spec.get('audio'),'spoken script needs narration audio; silent studies must omit spoken turns/mouths')
    if spec.get('audio'): media(spec['audio'],'narration')
    for effect in spec.get('vfx',[]):
        keys(effect,'kind author actor position offset at end shots event','VFX')
        timing_event(effect)
        require(effect.get('kind') in {'realization','impact','sweat','focus'} and effect.get('author') in profiles,'unknown VFX kind/author')
        require(num(effect.get('at')) and num(effect.get('end')) and 0<=effect['at']<effect['end']<=duration and effect['end']-effect['at']<=2,'VFX must last 0..2 seconds inside the scene')
        if 'actor' in effect: require(effect['actor'] in ids and ids[effect['actor']]==effect['author'] and point(effect.get('offset',[80,-30])),'invalid VFX actor/offset')
        else: require(point(effect.get('position')),'VFX needs actor or position')
        if 'shots' in effect: require(set(effect['shots'])<=shot_ids,'unknown VFX shot')
    for sound in spec.get('sfx',[]):
        keys(sound,'at file duration gain_db event','SFX')
        timing_event(sound)
        require(num(sound.get('at')) and num(sound.get('duration')) and 0<=sound['at'] and 0<sound['duration']<=2.5 and sound['at']+sound['duration']<=duration,'SFX must be short and inside the scene')
        require(num(sound.get('gain_db')) and -60<=sound['gain_db']<=-6,'SFX gain must be -60..-6 dB')
        media(sound.get('file'),'SFX')
    return spec
