#!/usr/bin/env python3
"""Validate real panorama clues, navigation contracts and final media independently."""
import argparse, json, math, re, subprocess
from pathlib import Path
PROJECT=Path(__file__).resolve().parents[1]
SCHOOL_OBJECT_KINDS={'locker','door','board','bench','poster','clock','clue','trophy','speaker','badge','sandwich','duck','bear','rabbit','microphone','form','pencil_cup'}
DRAWING_OBJECT_KINDS={'sketch_door','page_tear','eraser','paper_shelf','pencil','sketch_tree','paper_exit','binder_ring',
    'sketch_bridge','paper_tab','page_edge','studio_desk','ride_eraser',
    'ruler','ink_bottle','paper_stack','paper_clip'}
DRAWING_CONTEXT_KINDS={'ruler','ink_bottle','paper_stack','paper_clip'}
WORLD_EVENT_KINDS={'school':{'clock_tick','paper_flap','speaker_pulse'},
    'drawing':{'erase_sweep','door_flatten','tear_open','rewind','bridge_break','tab_fold','eraser_pass','escape_reveal'}}
def require(value,message):
    if not value: raise ValueError(message)
def actor_wall(scene):
    """Select a cube face for the canonical stage, never an inferred turn."""
    value=scene.get('actor_wall',0)
    require(type(value) is int and 0<=value<=3,'Actor wall must be an integer 0–3')
    return value
def world_renderer(timeline):
    renderer=timeline.get('world_renderer','school')
    require(isinstance(renderer,str) and renderer in {'school','drawing'},'World renderer must be school or drawing')
    if 'world_continuity' in timeline:
        require(type(timeline['world_continuity']) is bool,'World continuity must be a boolean')
        require(renderer=='drawing','World continuity is supported only by the drawing renderer')
    if 'preview_choice_turns' in timeline:
        require(type(timeline['preview_choice_turns']) is bool,'Preview choice turns must be a boolean')
        if timeline['preview_choice_turns']:
            require(renderer=='drawing','Enhanced preview choice turns are supported only by the drawing renderer')
    return renderer
def environment_event_limit(renderer,kind):
    """Only the authored eraser travel needs a longer finite action window."""
    return 8.0 if renderer=='drawing' and kind=='eraser_pass' else 2.5
def finite_number(value):
    return type(value) in (int,float) and math.isfinite(value)
def validate_world_material_states(scene,renderer):
    """Completed material is explicit authored state, never viewer progress."""
    for wall in scene['walls']:
        for obj in wall['objects']:
            for field,kind in [('opened','page_tear'),('folded','paper_tab'),('erasing','ride_eraser')]:
                if field not in obj:continue
                require(renderer=='drawing' and obj.get('kind')==kind,
                    field+' is supported only on drawing '+kind+' objects')
                require(type(obj[field]) is bool,field+' must be a boolean')
                if field=='erasing' and obj[field]:
                    require(isinstance(obj.get('path'),list) and len(obj['path'])>=2,
                        'Erasing ride eraser needs an authored path')
def validate_held_context(scene,renderer):
    """Material landmarks are held scenery, never undeclared interactions."""
    if renderer!='drawing':return
    context_ids={obj['id'] for wall in scene['walls'] for obj in wall['objects']
        if obj.get('kind') in DRAWING_CONTEXT_KINDS}
    for wall in scene['walls']:
        for obj in wall['objects']:
            if obj.get('kind') in DRAWING_CONTEXT_KINDS:
                require(obj.get('text','')=='','Drawing context props do not display choice text')
    require(not any(event.get('object') in context_ids for event in scene.get('environment_events',[])),
        'Drawing context props are held scenery and cannot own environment actions')
def validate_preview_context(timeline,renderer):
    """Bound optional local guidance to authored scene boundaries."""
    if 'preview_goal' in timeline:
        require(renderer=='drawing','Preview goal is supported only by the drawing renderer')
        goal=timeline['preview_goal']
        short_text(goal,'Preview goal',16,140)
        require(goal==goal.strip(),'Preview goal must not have leading or trailing whitespace')
    if 'preview_handoffs' not in timeline:return []
    require(renderer=='drawing','Preview handoffs are supported only by the drawing renderer')
    require(timeline.get('preview_choice_turns') is True,
        'Preview handoffs need explicit enhanced preview choice turns')
    handoffs=timeline['preview_handoffs']
    require(isinstance(handoffs,list),'Preview handoffs must be an array')
    # A handoff is optional local attention assistance at an existing cut. It
    # cannot introduce a new cut or steer the viewpoint in the uploaded MP4.
    boundaries={scene['start']:scene for scene in timeline['scenes'][1:]}
    previous=-math.inf
    for handoff in handoffs:
        require(isinstance(handoff,dict) and set(handoff)=={'at','yaw','duration'},
            'Preview handoff needs only at, yaw and duration')
        at=handoff['at'];yaw=handoff['yaw'];duration=handoff['duration']
        require(all(finite_number(value) for value in [at,yaw,duration]),
            'Preview handoff values must be finite numbers')
        require(previous<at and at in boundaries,
            'Preview handoff times must increase at existing noninitial scene boundaries')
        require(-180<=yaw<=180,'Preview handoff yaw must be bounded to -180..180 degrees')
        require(.2<=duration<=2 and at+duration<=boundaries[at]['end'],
            'Preview handoff duration must be 0.2..2 seconds inside the following scene')
        previous=at
    return handoffs
def validate_world_reveals(scene,renderer):
    """Held recovery text appears at one existing absolute story event."""
    for wall in scene['walls']:
        for obj in wall['objects']:
            if 'visible_from_event' not in obj:continue
            require(renderer=='drawing' and obj.get('kind')=='paper_exit',
                'Event-linked visibility is supported only on drawing paper_exit objects')
            name=obj['visible_from_event']
            require(isinstance(name,str) and bool(name.strip()) and name==name.strip(),
                'Object visibility needs a nonempty named story event')
            matches=[event for event in scene.get('environment_events',[]) if event.get('event')==name]
            require(len(matches)==1,'Object visibility needs exactly one matching environment story event')
            require(finite_number(matches[0].get('at')) and scene['start']<=matches[0]['at']<scene['end'],
                'Object visibility event must begin inside its owning scene')
def validate_world_paths(scene,renderer):
    """A finite vehicle path is explicit scenery motion, never inferred walking."""
    for wall in scene['walls']:
        for obj in wall['objects']:
            if 'path' not in obj:continue
            require(renderer=='drawing' and obj.get('kind')=='ride_eraser',
                'World paths are supported only on drawing ride_eraser objects')
            path=obj['path']
            require(isinstance(path,list) and len(path)>=2,'Ride eraser path needs at least two points')
            previous=None
            for point in path:
                require(isinstance(point,dict) and set(point)=={'at','position'},
                    'Ride path points need only at and position; bends and automatic motion are unsupported')
                at=point['at'];position=point['position']
                require(finite_number(at) and scene['start']<=at<=scene['end']
                    and (previous is None or at>previous),'Ride path times must increase within their owning scene')
                require(isinstance(position,list) and len(position)==2 and all(finite_number(value) for value in position)
                    and 0<position[0]<1920 and 0<position[1]<1080,'Ride path position leaves the finite wall canvas')
                previous=at
            require(path[0]['position']==[obj['x'],obj['y']],
                'Ride path must begin at its object base x/y')
            require(path[-1]['at']-path[0]['at']<=8,'Ride path travel must finish within eight seconds')
            cues=[event for event in scene.get('environment_events',[]) if event.get('object')==obj['id']
                and event.get('kind')=='eraser_pass' and event.get('at')==path[0]['at']
                and event.get('end')==path[-1]['at']]
            require(len(cues)==1,'Ride path needs exactly one matching eraser_pass event at its endpoints')
            if obj.get('erasing',False):
                require(all(point['position'][1]==path[0]['position'][1] for point in path),
                    'Erasing path must stay level on the drawn road')
                steps=[after['position'][0]-before['position'][0] for before,after in zip(path,path[1:])]
                require(all(step>0 for step in steps) or all(step<0 for step in steps),
                    'Erasing path must advance horizontally in one direction')
def validate_actor_transport(scene,renderer,story_events=None,spec=None):
    """Bind one canonical actor layer to the same vehicle path and named event."""
    transport=scene.get('actor_transport')
    if transport is None:return None
    require(renderer=='drawing','Actor transport is supported only by the drawing renderer')
    require(isinstance(transport,dict) and set(transport)=={'actor','object','event'},
        'Actor transport needs only actor, object and event')
    require(transport['actor']=='nemi','Actor transport supports only the canonical nemi actor')
    require(isinstance(transport['object'],str) and bool(transport['object'])
        and isinstance(transport['event'],str) and bool(transport['event']),
        'Actor transport needs an existing vehicle and named event')
    targets=[(wall['index'],obj) for wall in scene['walls'] for obj in wall['objects']
        if obj['id']==transport['object']]
    require(len(targets)==1,'Actor transport vehicle must be unique in its scene')
    wall,target=targets[0]
    require(wall==actor_wall(scene),'Actor transport vehicle must share the canonical actor wall')
    require(target.get('kind')=='ride_eraser' and isinstance(target.get('path'),list),
        'Actor transport needs a ride_eraser with an authored path')
    validate_world_paths(scene,renderer)
    path=target['path']
    matches=[event for event in scene.get('environment_events',[]) if event.get('object')==target['id']
        and event.get('kind')=='eraser_pass' and event.get('event')==transport['event']
        and event.get('at')==path[0]['at'] and event.get('end')==path[-1]['at']]
    require(len(matches)==1,'Actor transport event must match its vehicle path and eraser_pass action')
    if story_events is not None:
        require(transport['event'] in story_events and abs(story_events[transport['event']]-path[0]['at'])<.001,
            'Actor transport must name the canonical scene event at its path start')
    if spec is not None:
        require(any(actor.get('id')=='nemi' and actor.get('author')=='nemi' for actor in spec.get('actors',[])),
            'Actor transport needs the canonical nemi actor in the production scene')
        require(all(actor.get('id')=='nemi' for actor in spec.get('actors',[])),
            'Actor transport cannot move additional actors in the canonical stage')
        shots=[shot for shot in spec.get('shots',[]) if shot.get('id')==scene['id']
            and shot.get('start')==scene['start'] and shot.get('end')==scene['end']]
        require(len(shots)==1,'Actor transport needs one matching complete production shot')
        camera=shots[0].get('camera',{})
        require(camera=={'center':[960,540],'zoom':1},
            'Actor transport needs the unscaled canonical stage camera; reframe only the panoramic review')
    return target
def continuity_layout(scene):
    return {wall['index']:{obj['id']:(obj['kind'],obj['author'],obj['x'],obj['y'],json.dumps(obj.get('path'),sort_keys=True),obj.get('visible_from_event'),obj.get('opened',False),obj.get('folded',False),obj.get('erasing',False))
        for obj in wall['objects']} for wall in scene['walls']}
def continuity_group_names(timeline):
    return sorted({scene['continuity_group'] for scene in timeline['scenes'] if 'continuity_group' in scene})
def validate_continuity_groups(timeline):
    """Different physical sets may each retain their own absolute-time state."""
    if not any('continuity_group' in scene for scene in timeline['scenes']):return []
    require(world_renderer(timeline)=='drawing','Continuity groups are supported only by the drawing renderer')
    require(not timeline.get('world_continuity',False),'Continuity groups cannot be mixed with world_continuity true')
    layouts={};event_ids=set()
    for scene in timeline['scenes']:
        group=scene.get('continuity_group')
        require(isinstance(group,str) and group==group.strip() and 1<=len(group)<=64,
            'Every grouped drawing scene needs a nonempty continuity_group string of at most64 characters')
        layout=continuity_layout(scene)
        if group in layouts:
            require(layout==layouts[group],'Scenes in a continuity group must keep matching walls, object IDs, kinds, author and positions')
        else:layouts[group]=layout
        for event in scene.get('environment_events',[]):
            identity=event.get('id')
            require(isinstance(identity,str) and bool(identity.strip()) and identity not in event_ids,
                'Grouped drawing events need unique nonempty IDs across the timeline')
            event_ids.add(identity)
    return sorted(layouts)
def validate_world_continuity(timeline):
    """Keep seekable event results inside one explicitly continuous layout."""
    renderer=world_renderer(timeline)
    validate_continuity_groups(timeline)
    if not timeline.get('world_continuity',False):return False
    require(renderer=='drawing','World continuity is supported only by the drawing renderer')
    baseline=None;event_ids=set()
    for scene in timeline['scenes']:
        layout=continuity_layout(scene)
        if baseline is None:baseline=layout
        require(layout==baseline,'Continuous drawing scenes must keep matching walls, object IDs, kinds, author and positions')
        for event in scene.get('environment_events',[]):
            event_id=event.get('id')
            require(isinstance(event_id,str) and bool(event_id.strip()) and event_id not in event_ids,
                'Continuous drawing events need unique nonempty IDs across the timeline')
            event_ids.add(event_id)
    return True
def digit_targets(timeline,game):
    """Bind actual YouTube percentage shortcuts to authored scene landings."""
    navigation=game.get('navigation')
    if navigation is None:return None
    require(isinstance(navigation,dict),'Navigation must be an object')
    require(navigation.get('mode')=='youtube_digits','Unknown navigation mode')
    targets=navigation.get('key_targets',[])
    require(isinstance(targets,list) and len(targets)==10,'Digit navigation needs all ten keys 0–9')
    scenes={s['id']:s for s in timeline['scenes']};result={}
    require(len(scenes)==len(timeline['scenes']),'Digit navigation requires unique scene IDs')
    for item in targets:
        require(isinstance(item,dict),'Digit target must be an object')
        key=item.get('key')
        require(type(key) is int and 0<=key<=9 and key not in result,'Digit keys must be unique integers 0–9')
        require(item.get('chapter') in scenes,'Digit target names a missing chapter')
        at=timeline['duration']*key/10
        require(abs(at*timeline['fps']-round(at*timeline['fps']))<1e-6,'Digit destination falls between encoded frames')
        require(abs(scenes[item['chapter']]['start']-at)<1e-6,'Digit destination does not match its percentage landing')
        result[key]={'chapter':item['chapter'],'at':at}
    require(set(result)==set(range(10)),'Digit navigation needs all ten keys 0–9')
    if 'navigation' in timeline:
        require(timeline['navigation']==navigation,'Timeline and gameplay digit controls disagree')
    return result
def short_text(value,name,max_words,max_characters):
    require(isinstance(value,str) and bool(value.strip()),name+' must be nonempty text')
    require('\n' not in value and '\r' not in value,name+' must be one line')
    require(len(value.split())<=max_words and len(value)<=max_characters,name+' is too long for a readable prompt')
def entry_card_contract(scene):
    card=scene.get('entry_card')
    if card is None:return
    require(isinstance(card,dict),'Entry card must be an object')
    require(set(card)<= {'duration','title','subtitle'},'Unknown entry card field')
    duration=card.get('duration')
    require(type(duration) in [int,float] and 2<=duration<=4 and duration<scene['end']-scene['start'],'Entry card duration must be 2–4 seconds inside its scene')
    short_text(card.get('title'),'Entry card title',8,72)
    short_text(card.get('subtitle'),'Entry card subtitle',12,104)
def interaction_contracts(timeline,game,digits):
    """Validate displayed choices; the movie still never detects an answer."""
    prompts=timeline.get('interaction_scenes')
    if prompts is None:
        require('interaction_scenes' not in game,'Gameplay interaction prompts are missing from the timeline')
        return []
    require(digits is not None,'Interaction prompts need the native digit navigation contract')
    require(isinstance(prompts,list) and len(prompts)==len(timeline['scenes']),'Interaction prompts must cover every scene exactly once')
    if 'interaction_scenes' in game:require(game['interaction_scenes']==prompts,'Timeline and gameplay interaction prompts disagree')
    scenes={s['id']:s for s in timeline['scenes']};seen=set();summary=[]
    for prompt in prompts:
        require(isinstance(prompt,dict),'Interaction prompt must be an object')
        require(set(prompt)<= {'id','start','end','objective','choices','feedback'},'Unknown interaction prompt field; automatic detection is unsupported')
        scene_id=prompt.get('id')
        require(scene_id in scenes and scene_id not in seen,'Interaction prompt scene is missing or duplicated')
        scene=scenes[scene_id];seen.add(scene_id)
        require(prompt.get('start')==scene['start'] and prompt.get('end')==scene['end'],'Interaction prompt must match its complete scene interval')
        short_text(prompt.get('objective'),'Interaction objective',16,140)
        if 'feedback' in prompt:short_text(prompt['feedback'],'Interaction feedback',20,160)
        choices=prompt.get('choices')
        require(isinstance(choices,list) and len(choices)<=2,'Interaction prompt allows at most two choices')
        keys=set()
        for choice in choices:
            require(isinstance(choice,dict) and set(choice)== {'key','label','chapter'},'Choice needs only key, label and chapter')
            key=choice['key']
            require(type(key) is int and key in digits and key not in keys,'Choice key is invalid or duplicated')
            require(choice['chapter']==digits[key]['chapter'],'Choice chapter disagrees with its actual digit destination')
            short_text(choice['label'],'Choice label',10,80)
            keys.add(key)
        summary.append({'id':scene_id,'start':scene['start'],'end':scene['end'],'choice_keys':sorted(keys)})
    return summary
def check_data(timeline,game):
    require(timeline.get('kind')!='audition','Audition timelines require the explicit audition validator and cannot pass as full episodes')
    renderer=world_renderer(timeline)
    duration=timeline['duration'];fps=timeline['fps'];scenes=timeline['scenes']
    require(fps in [24,30,60] and 180<=duration<=360,'Full episode must be 3–6 minutes with supported FPS')
    previous=0
    for s in scenes:
        require(s['start']==previous and s['end']>s['start'],'Scene clock has a gap, overlap or empty scene')
        actor_wall(s)
        if timeline.get('preview_choice_turns',False):
            require(finite_number(s.get('review_yaw')) and -180<=s['review_yaw']<=180,
                'Enhanced preview choices need a finite bounded review_yaw on every destination scene')
        entry_card_contract(s)
        require(set(w['index'] for w in s['walls'])=={0,1,2,3},'Every scene needs four spatial walls')
        for w in s['walls']:
            ids=[]
            for o in w['objects']:
                require(o.get('author')=='nemi','Every illustration selects the Nemi author identity')
                require(o['id'] not in ids,'Duplicate object ID on a wall');ids.append(o['id'])
                require(0<o['x']<1920 and 0<o['y']<1080,'Object outside wall canvas')
                require(o['kind'] in (SCHOOL_OBJECT_KINDS if renderer=='school' else DRAWING_OBJECT_KINDS),'Unknown drawable object')
                if o['kind'] in ['clue','badge']:require(240<=o['x']<=1680 and 250<=o['y']<=760,'Essential clue too close to a corner or pole')
        object_ids={o['id'] for w in s['walls'] for o in w['objects']}
        for event in s.get('environment_events',[]):
            require(event['kind'] in WORLD_EVENT_KINDS[renderer],'Unknown finite environment action')
            require(event['object'] in object_ids,'Environment event targets a missing prop')
            require(s['start']<=event['at']<event['end']<=s['end'] and event['end']-event['at']<=environment_event_limit(renderer,event['kind']),'Environment event lifetime outside scene or too long')
            require(bool(event.get('event')),'Environment motion needs a named story event')
        validate_world_material_states(s,renderer)
        validate_held_context(s,renderer)
        validate_world_reveals(s,renderer)
        validate_world_paths(s,renderer)
        validate_actor_transport(s,renderer)
        previous=s['end']
    require(previous==duration==game['duration'],'Timeline does not cover exact runtime')
    handoffs=validate_preview_context(timeline,renderer)
    validate_world_continuity(timeline)
    require(game['automatic_state'] is False,'Ordinary YouTube cannot track game state')
    starts={s['start'] for s in scenes}
    digits=digit_targets(timeline,game)
    interactions=interaction_contracts(timeline,game,digits)
    for c in game['challenges']:
        require(0<=c['start']<c['end']<=duration,'Invalid challenge interval')
        require(c['state_tracking'] is False,'False automatic state contract')
        for key in ['objective','instructions','visual_change','success','retry_method','do_nothing','wrong_answer','device_limitations']:
            require(bool(c.get(key)),'Missing interaction contract: '+key)
        require(c['valid_destinations'] and all(x in starts for x in c['valid_destinations']),'Destination must be a real scene landing')
        require(all(x in starts for x in c.get('alternative_outcomes',[])),'Alternative destination must be a real scene landing')
        if digits is not None:
            for key in ['solution_key','retry_key']:
                require(type(c.get(key)) is int and c[key] in digits,'Missing or invalid challenge digit: '+key)
            answer=c['solution_key'];retry_key=c['retry_key']
            require(c['valid_destinations']==[digits[answer]['at']],'Answer key disagrees with valid destination')
            short_text(c.get('solution'),'Printed solution',8,72)
            printed=c['solution'].strip().upper()
            outcome_label=re.fullmatch(r"([0-9])\s+([A-Z][A-Z0-9 '’.,!?&/():-]*)",printed)
            require(printed==f'PRESS {answer}' or (outcome_label and int(outcome_label[1])==answer),
                'Printed solution must name the answer key as PRESS N or N OUTCOME')
            if interactions:
                prompts=[p for p in timeline['interaction_scenes'] if p['start']<c['end'] and p['end']>c['start']]
                require(any(choice['key']==answer and choice['chapter']==digits[answer]['chapter']
                    for prompt in prompts for choice in prompt['choices']),
                    'Answer key must be offered by an interaction choice during its challenge')
            require(re.search(r'\bpress\s+'+str(retry_key)+r'\b',c['retry_method'],re.I),'Retry must name its actual key')
            alternatives=c.get('alternative_keys',[])
            require(isinstance(alternatives,list) and all(type(k) is int and k in digits for k in alternatives),'Invalid alternative key')
            require(len(set(alternatives))==len(alternatives),'Duplicate alternative key')
            require(answer not in alternatives,'Answer key cannot also be a wrong alternative')
            require(sorted(c.get('alternative_outcomes',[]))==sorted(digits[k]['at'] for k in alternatives),'Alternative keys disagree with outcome landings')
        else:
            retry=re.search(r'(\d+):([0-5]\d)',c['retry_method'])
            require(retry and int(retry[1])*60+int(retry[2]) in starts,'Retry must name a real scene landing')
        matching=[s for s in scenes if s['start']<c['end'] and s['end']>c['start']]
        for s in matching:
            clues=[o for w in s['walls'] for o in w['objects'] if o['id']==c['clue_id']]
            # The detour is allowed to replace the puzzle with explicit recovery.
            if s['start'] in c.get('alternative_outcomes',[]):continue
            require(len(clues)==1,f"Clue {c['clue_id']} missing/duplicated in {s['id']}")
            require(c['solution'] in clues[0].get('text',''),'Printed clue disagrees with published destination')
        require(all(c['start']<=h['at']<c['end'] for h in c['hints']),'Hint outside challenge')
    routes=[]
    for route in game['routes']:
        require(all(t in starts for t in route['times']),'Invalid route landing')
        routes.append({'id':route['id'],'landings':route['times'],'pass':True})
    return dict(pass_=True,scenes=len(scenes),challenges=len(game['challenges']),routes=routes,world_renderer=renderer,
        continuity_groups=continuity_group_names(timeline),
        preview_handoffs=handoffs,
        digit_map=digits,
        interaction_prompts=interactions,
        controls=('Native viewpoint + YouTube percentage number keys; runtime state detection absent' if digits is not None else 'Native viewpoint + manual seeking; runtime state detection deliberately absent'),
        mobile='Structural touch-preview support; actual YouTube app test pending')
def check_audition_data(timeline):
    """Check an explicitly nonplayable storyboard without inventing a digit map."""
    finite=lambda value:type(value) in (int,float) and math.isfinite(value)
    require(isinstance(timeline,dict),'Audition timeline must be an object')
    require(timeline.get('kind')=='audition' and timeline.get('playable') is False,
        'Audition timeline must declare kind audition and playable false')
    for field in ['navigation','interaction_scenes','challenges','routes','automatic_state']:
        require(field not in timeline,'Audition cannot declare live gameplay or navigation: '+field)
    for field in ['game_ready','youtube_verified','spherical_metadata_injected']:
        require(timeline.get(field,False) is False,'Audition cannot claim verified or game-ready media: '+field)
    renderer=world_renderer(timeline)
    duration=timeline.get('duration');fps=timeline.get('fps');scenes=timeline.get('scenes')
    require(finite(duration) and 30<=duration<=60 and type(fps) is int and fps in [24,30,60],
        'Audition must be 30–60 seconds with supported FPS')
    require(abs(duration*fps-round(duration*fps))<1e-6,'Audition duration must align to an encoded frame')
    require(isinstance(scenes,list) and bool(scenes),'Audition needs at least one scene')
    previous=0;scene_ids=set()
    for scene in scenes:
        require(isinstance(scene,dict),'Audition scene must be an object')
        scene_id=scene.get('id');start=scene.get('start');end=scene.get('end')
        require(isinstance(scene_id,str) and bool(scene_id.strip()) and scene_id not in scene_ids,
            'Audition scene IDs must be nonempty and unique')
        scene_ids.add(scene_id)
        require(finite(start) and finite(end) and start==previous and start<end<=duration,
            'Audition scene clock has a gap, overlap or empty scene')
        require(all(abs(at*fps-round(at*fps))<1e-6 for at in [start,end]),'Audition scene boundaries must align to encoded frames')
        require(isinstance(scene.get('location'),str) and bool(scene['location'].strip()),'Audition scene needs a location')
        actor_wall(scene)
        entry_card_contract(scene)
        walls=scene.get('walls')
        require(isinstance(walls,list) and len(walls)==4 and all(isinstance(wall,dict) for wall in walls),
            'Every audition scene needs exactly four spatial walls')
        require(all(type(wall.get('index')) is int for wall in walls) and {wall['index'] for wall in walls}=={0,1,2,3},
            'Every audition scene needs wall indices 0,1,2,3 exactly once')
        for wall in walls:
            require(isinstance(wall.get('objects'),list),'Audition wall objects must be an array')
            ids=set()
            for obj in wall['objects']:
                require(isinstance(obj,dict),'Audition drawable must be an object')
                require(obj.get('author')=='nemi','Every illustration selects the Nemi author identity')
                object_id=obj.get('id')
                require(isinstance(object_id,str) and bool(object_id.strip()) and object_id not in ids,'Duplicate or empty object ID on an audition wall')
                ids.add(object_id)
                require(finite(obj.get('x')) and finite(obj.get('y')) and 0<obj['x']<1920 and 0<obj['y']<1080,'Object outside wall canvas')
                require(obj.get('kind') in (SCHOOL_OBJECT_KINDS if renderer=='school' else DRAWING_OBJECT_KINDS),'Unknown drawable object')
        object_ids={obj['id'] for wall in walls for obj in wall['objects']}
        events=scene.get('environment_events',[])
        require(isinstance(events,list),'Audition environment events must be an array')
        for event in events:
            require(isinstance(event,dict) and event.get('kind') in WORLD_EVENT_KINDS[renderer],'Unknown finite environment action')
            require(event.get('object') in object_ids,'Environment event targets a missing prop')
            require(finite(event.get('at')) and finite(event.get('end')) and start<=event['at']<event['end']<=end and event['end']-event['at']<=environment_event_limit(renderer,event['kind']),
                'Environment event lifetime outside scene or too long')
            require(isinstance(event.get('event'),str) and bool(event['event'].strip()),'Environment motion needs a named story event')
        validate_world_material_states(scene,renderer)
        validate_held_context(scene,renderer)
        validate_world_reveals(scene,renderer)
        validate_world_paths(scene,renderer)
        validate_actor_transport(scene,renderer)
        previous=end
    require(previous==duration,'Audition timeline does not cover exact runtime')
    handoffs=validate_preview_context(timeline,renderer)
    continuity=validate_world_continuity(timeline)
    return {'pass_':True,'kind':'audition','playable':False,'duration':duration,'fps':fps,
        'scenes':len(scenes),'world_renderer':renderer,'world_continuity':continuity,
        'continuity_groups':continuity_group_names(timeline),'preview_handoffs':handoffs,'digit_map':None,
        'controls':'Sequential voice and storyboard review; number labels illustrate planned final controls only',
        'youtube_verified':False}
def probe_video(path,spherical=False,duration=300,fps=30):
    d=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(path)]))
    video=next(s for s in d['streams'] if s['codec_type']=='video')
    audio=next((s for s in d['streams'] if s['codec_type']=='audio'),None)
    require(video['codec_name']=='h264','Expected H.264');require(video['pix_fmt'] in ['yuv420p','yuvj420p'],'Expected4:2:0')
    require(audio and audio['codec_name']=='aac','Expected AAC audio')
    require(abs(float(d['format']['duration'])-duration)<.15,'Truncated/inexact movie duration')
    require(video['avg_frame_rate']==f'{fps}/1','Unexpected frame rate')
    if spherical:require(video['width']==2*video['height'],'Spherical frame must be2:1')
    else:require((video['width'],video['height'])==(1920,1080),'Review must be1920×1080')
    return dict(path=str(path),duration=d['format']['duration'],resolution=[video['width'],video['height']],video=video['codec_name'],audio=audio['codec_name'],fps=video['avg_frame_rate'])
def validate(episode,audition=False):
    timeline=json.loads((episode/'storyboard/timeline.json').read_text())
    result=check_audition_data(timeline) if audition else check_data(timeline,json.loads((episode/'gameplay/manifest.json').read_text()))
    if (episode/'scene.json').exists():
        production=json.loads((episode/'scene.json').read_text())
        from continuity import validate_natural_joins
        validate_natural_joins(timeline,production)
        events={e['id']:e['at'] for e in production['events']}
        for scene in timeline['scenes']:
            for cue in scene.get('environment_events',[]):
                require(cue['event'] in events and abs(events[cue['event']]-cue['at'])<.001,'Environment/SFX named event timing disagrees')
    (episode/'review').mkdir(exist_ok=True)
    (episode/'review'/('audition_checks.json' if audition else 'gameplay_checks.json')).write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
    return result
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--episode',type=Path,default=PROJECT/'episodes/episode_001');p.add_argument('--video',type=Path);p.add_argument('--sphere',action='store_true');p.add_argument('--audition',action='store_true');a=p.parse_args()
    try:
        result=validate(a.episode,a.audition)
        if a.video:print(json.dumps(probe_video(a.video,a.sphere,result.get('duration',300),result.get('fps',30)),indent=2))
    except (ValueError,KeyError) as e:p.exit(1,str(e)+'\n')
