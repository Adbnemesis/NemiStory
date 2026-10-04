"""Version 2 shot/audio/acting contract. Reuses version 1 core validation."""
import copy
import math
from pathlib import Path

ART = {'laptop','phone','mug','tabs','cloud','desk','suitcase','car','damaged_car','police_car','steering_wheel','boarding_pass','clipboard','flashlight','traffic_cone','tissue_box','seat_front'}
ART |= {'school_friend','school_friend_smile','school_friend_laugh','school_classmate','school_classmate_laugh','lunch_box','homework_notes','school_clock'}
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
    keys(spec,'version title duration fps caption_size audio audio_metadata mix direction actors shots drawings props vfx sfx script captions events','scene')
    require(num(spec.get('caption_size',32)) and 32<=spec.get('caption_size',32)<=64,'caption_size must be 32..64 pixels')
    require(isinstance(spec.get('shots'),list) and spec['shots'],'shots are required')
    require(isinstance(spec.get('actors'),list) and spec['actors'],'actors are required')
    require(isinstance(spec.get('script'),list),'script must contain ordered spoken turns')
    duration=spec.get('duration'); require(num(duration) and duration>0,'duration must be positive')
    def path_check(path, start, end, field='position', extra='tilt bend angle'):
        require(isinstance(path,list) and path,'path needs ordered keyframes')
        previous=start-1
        for frame in path:
            keys(frame,'at '+field+' '+extra,'path keyframe')
            require(num(frame.get('at')) and start<=frame['at']<=end and frame['at']>previous and point(frame.get(field)),'invalid path keyframe time/point')
            previous=frame['at']
            for key in ['tilt','angle']:
                if key in frame: require(num(frame[key]) and abs(frame[key])<=180,'path angle must be -180..180')
            if 'bend' in frame: require(point(frame['bend']) and max(abs(v) for v in frame['bend'])<=300,'path bend must be bounded')
            if 'zoom' in frame: require(num(frame['zoom']) and .5<=frame['zoom']<=3,'path zoom must be .5..3')
    if 'mix' in spec:
        mix=spec['mix']; keys(mix,'master_gain_db target_lufs peak_dbfs','mix')
        require(all(num(mix.get(k)) for k in ['master_gain_db','target_lufs','peak_dbfs']) and -24<=mix['master_gain_db']<=12 and -24<=mix['target_lufs']<=-14 and -6<=mix['peak_dbfs']<=-1,'mix needs bounded constant gain, loudness target and peak headroom')
    if 'direction' in spec:
        direction=spec['direction']; keys(direction,'promise want choice consequence payoff beats','direction')
        require(all(isinstance(direction.get(k),str) and direction[k].strip() for k in ['promise','want','choice','consequence','payoff']),'direction needs a concrete promise, want, choice, consequence and payoff')
        require(isinstance(direction.get('beats'),list) and direction['beats'],'direction beats are required')
        previous=0
        for beat in direction['beats']:
            keys(beat,'start end thought focus visual intent','direction beat')
            require(num(beat.get('start')) and num(beat.get('end')) and previous<=beat['start']<beat['end']<=duration,'invalid direction beat times')
            require(all(isinstance(beat.get(k),str) and beat[k].strip() for k in ['thought','focus','visual','intent']),'direction beat must explain thought, focus, visual and intent')
            previous=beat['end']
    ids={}; normalized=copy.deepcopy(spec)
    normalized['version']=1
    for i,actor in enumerate(normalized['actors']):
        keys(actor,'id author performances mouths hand_paths hand_path_window',f'actor {i}')
        require(isinstance(actor.get('id'),str) and actor['id'] and actor['id'] not in ids,f'actor {i}: unique id required')
        ids[actor.pop('id')]=actor.get('author')
        actor['position']=[0,0]; actor['scale']=1
        paths=actor.pop('hand_paths',{}); keys(paths,'left right','hand paths')
        window=actor.pop('hand_path_window',None)
        if window is not None:
            require(paths and isinstance(window,list) and len(window)==2 and all(num(v) for v in window) and 0<=window[0]<window[1]<=duration,'hand_path_window needs paths and an ordered interval inside the scene')
        for path in paths.values(): path_check(path,0,duration,'position','angle bend')
        for cue in actor.get('performances',[]):
            keys(cue,'at recipe duration blinks gaze hands grounded motion step_fps face event event_offset',f'actor {i} performance')
            face=cue.get('face',{})
            allowed='eye_openness pupil_scale left_brow_offset right_brow_offset left_brow_tilt right_brow_tilt' if actor.get('author')=='nemi' else 'eye_openness_left eye_openness_right brow_left_angle brow_right_angle brow_left_height brow_right_height blush_intensity tear_intensity sweat_intensity'
            keys(face,allowed,'face refinement')
            for key,value in face.items():
                if key in {'left_brow_offset','right_brow_offset'}: require(point(value) and max(abs(v) for v in value)<=8,'brow offset must be a bounded point')
                else:
                    bounds=(0,1.5) if 'eye_openness' in key else (.3,2.2) if key=='pupil_scale' else (0,1) if 'intensity' in key else (-.35,.35) if 'tilt' in key else (-20,20) if 'angle' in key else (-8,8)
                    require(num(value) and bounds[0]<=value<=bounds[1],f'Invalid face control: {key}')
            require(cue.get('motion','smooth') in {'smooth','snap','stepped'},'motion must be smooth, snap or stepped')
            if 'step_fps' in cue: require(cue.get('motion')=='stepped' and cue['step_fps'] in {8,10,12,15},'step_fps belongs to stepped motion: 8/10/12/15')
            if cue.get('motion')=='snap': cue['duration']=0
            require(isinstance(cue.get('grounded',True),bool),'grounded must be a boolean')
            if 'gaze' in cue: require(point(cue['gaze']) and max(abs(v) for v in cue['gaze'])<=1,'gaze must be normalized [x,y]')
            hands=cue.get('hands',{}); keys(hands,'left right','hands')
            require(actor.get('author') in HANDS,'actor author must be nemi or adb')
            for value in hands.values(): require(value in HANDS[actor['author']],f'Unknown {actor["author"]} hand shape: {value}')
            for field in ['gaze','hands','grounded','motion','step_fps','face','event','event_offset']: cue.pop(field,None)
    events={}
    for event in spec.get('events',[]):
        keys(event,'id at intent','event')
        require(isinstance(event.get('id'),str) and event['id'] not in events and num(event.get('at')) and 0<=event['at']<duration and isinstance(event.get('intent'),str),'event needs unique id, at and intent')
        events[event['id']]=event['at']
    def timing_event(item):
        if 'event_offset' in item: require('event' in item and num(item['event_offset']) and abs(item['event_offset'])<=2,'event_offset requires a named event and -2..2 seconds')
        if 'event' in item:
            require(item['event'] in events and num(item.get('at')) and abs(item['at']-events[item['event']]-item.get('event_offset',0))<1e-6,'event cue must match its named landing time plus explicit offset')
    for actor in spec['actors']:
        for cue in actor['performances']: timing_event(cue)
    previous=0; shot_ids=set()
    for shot in spec['shots']:
        keys(shot,'id start end background actors camera','shot')
        require(isinstance(shot.get('id'),str) and shot['id'] not in shot_ids,'shot ids must be unique strings')
        shot_ids.add(shot['id'])
        require(num(shot.get('start')) and num(shot.get('end')) and abs(shot['start']-previous)<1e-6 and shot['start']<shot['end']<=duration,'shots must cover the scene in order, without gaps/overlaps')
        previous=shot['end']
        require(shot.get('background') in {'paper','room','thought','evening','studio_nemi','studio_adb','sf_street','sf_bridge','tech_auditorium','car_cabin','airport_road','roadside','school_classroom','school_corridor'},'Unknown background')
        require(isinstance(shot.get('actors'),dict),'shot actors must be an id → placement object')
        for id,placement in shot['actors'].items():
            require(id in ids,f'Unknown shot actor: {id}')
            keys(placement,'position scale','placement')
            require(point(placement.get('position')) and num(placement.get('scale')) and 0<placement['scale']<=4,'placement needs position and positive scale <=4')
        camera=shot.get('camera',{}); keys(camera,'center zoom path','camera')
        require(point(camera.get('center',[960,540])) and num(camera.get('zoom',1)) and .5<=camera.get('zoom',1)<=3,'invalid camera')
        if 'path' in camera: path_check(camera['path'],shot['start'],shot['end'],'center','zoom')
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
    normalized['captions']=[]
    for card in spec.get('captions',[]):
        keys(card,'start end text actor words','caption')
        if 'actor' in card: require(card['actor'] in ids,'caption actor must exist')
        if 'words' in card: require('audio_metadata' in spec and 'actor' in card and isinstance(card['words'],list) and len(card['words'])==2 and all(isinstance(i,int) and not isinstance(i,bool) for i in card['words']) and 0<=card['words'][0]<=card['words'][1],'caption needs actor and ordered word indices')
        normalized['captions'].append({k:v for k,v in card.items() if k not in {'actor','words'}})
    drawings=[]
    import json
    profiles={a:json.loads((root/f'common/storytime/profiles/{a}.json').read_text()) for a in set(ids.values())}
    for group in ['drawings','props']:
        require(isinstance(spec.get(group,[]),list),f'{group} must be a list')
        for i,item in enumerate(spec.get(group,[])):
            keys(item,'author kind position at duration end scale tilt accent text size variant mode layer shots attach attach_start attach_end path event event_offset',f'{group} {i}')
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
            if 'attach_start' in item or 'attach_end' in item:
                require('attach' in item and point(item.get('position')) and all(num(item.get(k)) for k in ['attach_start','attach_end']) and item['at']<=item['attach_start']<item['attach_end']<=item['end'],'bounded attachment needs start/end and a world rest position')
            if 'path' in item: path_check(item['path'],item.get('at',0),item.get('end',duration),'position','tilt bend')
            copy_item={k:v for k,v in item.items() if k not in {'mode','layer','shots','attach','attach_start','attach_end','path','event','event_offset'}}
            copy_item.setdefault('duration',min(.1,item.get('end',0)-item.get('at',0)))
            copy_item.setdefault('position',[0,0])
            if copy_item['kind'] in ART: copy_item['kind']='notebook'
            drawings.append(copy_item)
    normalized['drawings']=drawings
    normalized['audio']=spec.get('audio') if check_assets else None
    for key in ['shots','props','vfx','sfx','script','events','audio_metadata','mix','direction','caption_size']: normalized.pop(key,None)
    core_validate(normalized)
    require(not spec['script'] or spec.get('audio'),'spoken script needs narration audio; silent studies must omit spoken turns/mouths')
    if spec.get('audio'): media(spec['audio'],'narration')
    if 'audio_metadata' in spec:
        import hashlib
        path=spec['audio_metadata']
        require(spec.get('audio') and isinstance(path,str) and path.startswith('res://'),'audio_metadata needs narration and a res:// JSON path')
        metadata=(root/path[6:]).resolve()
        require(metadata.is_relative_to(root) and metadata.suffix=='.json','invalid metadata path')
        if check_assets:
            require(metadata.is_file(),'missing voice timing/provenance metadata')
            data=json.loads(metadata.read_text())
            require(data.get('audio_sha256')==hashlib.sha256((root/spec['audio'][6:]).read_bytes()).hexdigest(),'Narration changed after alignment; rebuild timings before rendering')
            words=data.get('words',[])
            for card in spec.get('captions',[]):
                if 'words' not in card: continue
                first,last=card['words']; require(last<len(words),'caption word index out of range')
                selected=words[first:last+1]
                require(all(word['actor']==card['actor'] for word in selected),'caption words belong to a different speaker')
                require(abs(card['start']-selected[0]['start'])<=.06 and 0<=card['end']-selected[-1]['end']<=.25,'caption drift from measured word times')
                import re
                clean=lambda text: re.findall(r"[\w]+(?:['’][\w]+)*",text.lower())
                require(clean(card['text'])==clean(' '.join(w['word'] for w in selected)),'caption text differs from its measured words')
    for effect in spec.get('vfx',[]):
        keys(effect,'kind author actor position offset at end shots event event_offset strength','VFX')
        timing_event(effect)
        require(effect.get('kind') in {'realization','impact','sweat','focus','tension','relief','tears'} and effect.get('author') in profiles,'unknown VFX kind/author')
        require(num(effect.get('strength',1)) and .25<=effect.get('strength',1)<=1.5,'VFX strength must be .25..1.5')
        require(num(effect.get('at')) and num(effect.get('end')) and 0<=effect['at']<effect['end']<=duration and effect['end']-effect['at']<=2,'VFX must last 0..2 seconds inside the scene')
        if 'actor' in effect: require(effect['actor'] in ids and ids[effect['actor']]==effect['author'] and point(effect.get('offset',[80,-30])),'invalid VFX actor/offset')
        else: require(point(effect.get('position')),'VFX needs actor or position')
        if 'shots' in effect: require(set(effect['shots'])<=shot_ids,'unknown VFX shot')
    for sound in spec.get('sfx',[]):
        keys(sound,'at file duration gain_db event event_offset','SFX')
        timing_event(sound)
        require(num(sound.get('at')) and num(sound.get('duration')) and 0<=sound['at'] and 0<sound['duration']<=2.5 and sound['at']+sound['duration']<=duration,'SFX must be short and inside the scene')
        require(num(sound.get('gain_db')) and -60<=sound['gain_db']<=-6,'SFX gain must be -60..-6 dB')
        media(sound.get('file'),'SFX')
    return spec
