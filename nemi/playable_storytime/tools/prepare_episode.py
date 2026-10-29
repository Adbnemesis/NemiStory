#!/usr/bin/env python3
"""Compile episode-specific story data, measured audio, stage direction and puzzles."""
import argparse, copy, hashlib, json, math, re, shutil
from pathlib import Path

PROJECT=Path(__file__).resolve().parents[1]
REPO=PROJECT.parents[1]
def save(path,data):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
def stamp(t):
    return f'{int(t)//60}:{int(t)%60:02d}'
def source_ref(path):
    return 'res://nemi/playable_storytime/'+str(path.relative_to(PROJECT))
def obj(id,kind,x,y,text='',**kw):
    return dict(id=id,kind=kind,x=x,y=y,text=text,**kw)
PERFORMANCE_FIELDS=('duration','motion','step_fps','gaze','face','hands','blinks')
def performance_cue(item,at):
    """Direct existing acting controls; never infer emotion from line number."""
    cue={'at':at,'recipe':item['recipe'],'duration':item.get('duration',.34)}
    for field in PERFORMANCE_FIELDS:
        if field in item:cue[field]=copy.deepcopy(item[field])
    return cue
def chapter_plates(chapter):
    """A chapter need not carry a permanent heading or unrelated prop."""
    drawings=[];props=[];start,end=chapter['start'],chapter['end']
    drawing=chapter.get('drawing');prop=chapter.get('prop')
    if isinstance(drawing,str) and drawing.strip():
        drawings.append(dict(author='nemi',kind='text',text=drawing,size=chapter.get('heading_size',40),position=[980,150],at=start,end=end,mode='hold',shots=[chapter['id']]))
    if isinstance(prop,str) and prop.strip():
        props.append(dict(author='nemi',kind=prop,at=start,end=end,position=[1200,480],scale=[1.0,1.0],mode='hold',shots=[chapter['id']]))
    return drawings,props
def resolve_art_event(item,event_times):
    """Retain actual v2 art fields; an event owns only the measured start."""
    item=copy.deepcopy(item)
    if 'event' in item:
        if item['event'] not in event_times:raise ValueError('Art names a missing event: '+str(item['event']))
        item['at']=round(event_times[item['event']]+item.get('event_offset',0),6)
    return item
def measured_anchor(item,by_clip):
    """Resolve a final-audio word, with deliberate occurrence/offset ownership."""
    clip_id=item.get('clip_id')
    if clip_id not in by_clip:raise ValueError('Measured anchor names missing clip: '+str(clip_id))
    clean=lambda text:re.sub(r"[^a-z0-9]",'',text.lower())
    word=item.get('word')
    if not isinstance(word,str) or not clean(word):raise ValueError('Measured anchor needs a spoken word')
    occurrence=item.get('occurrence',0);offset=item.get('offset',0)
    if type(occurrence) is not int or occurrence<0:raise ValueError('Measured anchor occurrence must be a nonnegative integer')
    if type(offset) not in (int,float) or not math.isfinite(offset) or abs(offset)>2:raise ValueError('Measured anchor offset must be within two seconds')
    matches=[w['start'] for w in by_clip[clip_id] if clean(w['word'])==clean(word)]
    if len(matches)<=occurrence:raise ValueError('Measured event anchor missing: '+str(item))
    return round(matches[occurrence]+offset,6)
def anchored_acting(beats,by_clip,chapters):
    """Compile thought-specific turns without adding another animation player."""
    allowed=set(PERFORMANCE_FIELDS)|{'id','clip_id','word','occurrence','offset','recipe','intent'}
    owners={line['id']:ch for ch in chapters for line in ch['lines']}
    cues=[];events=[];ids=set();times=set()
    for beat in beats:
        if set(beat)-allowed:raise ValueError('Unknown anchored acting field: '+str(sorted(set(beat)-allowed)))
        identity=beat.get('id')
        if not isinstance(identity,str) or not re.fullmatch(r'[a-z][a-z0-9_]*',identity) or identity in ids:raise ValueError('Anchored acting needs a unique lower-case id')
        ids.add(identity)
        at=measured_anchor(beat,by_clip);owner=owners.get(beat['clip_id'])
        if owner is None or not owner['start']<=at<owner['end']:raise ValueError('Anchored acting leaves its chapter: '+identity)
        if at in times:raise ValueError('Two anchored acting beats share a time')
        times.add(at)
        if not isinstance(beat.get('recipe'),str):raise ValueError('Anchored acting needs an existing recipe')
        transition=0 if beat.get('motion')=='snap' else beat.get('duration',.34)
        if type(transition) not in (int,float) or not math.isfinite(transition) or transition<0 or at+transition>owner['end']:raise ValueError('Anchored acting transition leaves its chapter: '+identity)
        eid='acting_'+identity
        cue=performance_cue(beat,at);cue['event']=eid
        cues.append(cue)
        events.append(dict(id=eid,at=at,intent=beat.get('intent','Act on the measured word '+beat['word'])))
    return cues,events
def anchored_camera(beats,by_clip,chapter):
    """Whole-world director projection only; stage/wall scale stays unchanged."""
    allowed={'clip_id','word','occurrence','offset','yaw','pitch','fov','duration','intent'}
    clip_ids={line['id'] for line in chapter['lines']};result=[]
    for beat in beats:
        if set(beat)-allowed:raise ValueError('Unknown camera beat field: '+str(sorted(set(beat)-allowed)))
        if beat.get('clip_id') not in clip_ids:raise ValueError('Camera beat must use a clip from its chapter')
        at=measured_anchor(beat,by_clip);duration=beat.get('duration',.32)
        yaw=beat.get('yaw');pitch=beat.get('pitch',0);fov=beat.get('fov')
        finite=lambda n:type(n) in (int,float) and math.isfinite(n)
        if not finite(yaw) or not -180<=yaw<=180:raise ValueError('Camera beat yaw must be -180..180 degrees')
        if not finite(pitch) or not -25<=pitch<=25:raise ValueError('Camera beat pitch must be -25..25 degrees')
        if not finite(fov) or not 34<=fov<=110:raise ValueError('Camera beat FOV must be 34..110 degrees')
        if not finite(duration) or duration<0 or not chapter['start']<=at<=at+duration<=chapter['end']:raise ValueError('Camera beat transition leaves its chapter')
        if result and result[-1]['at']+result[-1]['duration']>at:raise ValueError('Camera beats must increase without overlapping transitions')
        if result and result[-1]['at']==at:raise ValueError('Camera beat times must be unique')
        if not isinstance(beat.get('intent'),str) or not beat['intent'].strip():raise ValueError('Camera beat needs a thought-specific intention')
        result.append(dict(at=at,yaw=yaw,pitch=pitch,fov=fov,duration=duration,intent=beat['intent']))
    return result
def walls(location):
    return [dict(index=i,objects=[
        obj(f'{location}_{i}_door','door',1450,490,'ASSEMBLY' if location=='assembly' else 'CLASSROOM'),
        obj(f'{location}_{i}_clock','clock',280,210),
        obj(f'{location}_{i}_lockers','locker',470,560),
        obj(f'{location}_{i}_bench','bench',920,820),
    ]) for i in range(4)]
def prepare(episode):
    story=json.loads((episode/'scripts/story.json').read_text())
    dialogue={'duration':story['duration'],'speaker':'nemi','clips':[]}
    scenes=[]
    locations=json.loads((episode/'assets/locations.json').read_text())
    for ch in story['chapters']:
        for line in ch['lines']:
            dialogue['clips'].append({k:line[k] for k in ['id','text','at','window_end']}|{'tempo':line.get('tempo',1.08)})
        w=json.loads(json.dumps(locations[ch['location']]))
        start=ch['start'];yaw=ch['review_yaw'];length=ch['end']-start
        review_path=[{'at':round(start+length*fraction,6),'yaw':angle}
                     for fraction,angle in [(0,0),(8/30,0),(12/30,yaw),(24/30,yaw),(28/30,0)]]
        room={k:ch[k] for k in ['id','start','end','location','review_yaw']}|{'walls':w,'review_yaw_path':review_path,'review_fov':ch.get('review_fov',60),'environment_events':ch.get('environment_events',[])}
        if 'entry_card' in ch:room['entry_card']=ch['entry_card']
        scenes.append(room)
    save(episode/'scripts/dialogue.json',dialogue)
    spatial={'duration':story['duration'],'fps':story['fps'],'scenes':scenes}
    if 'navigation' in story:spatial['navigation']=story['navigation']
    for key in ['revision','episode_id','media_basename','interaction_scenes']:
        if key in story:spatial[key]=story[key]
    save(episode/'storyboard/timeline.json',spatial)
    (episode/'scripts/SCRIPT.md').write_text('# '+story['title']+'\n\nAn original fictional story performed by Nemi.\n\n'+ '\n\n'.join('## '+stamp(c['start'])+' — '+c['name']+'\n\n'+'\n\n'.join(l['text'] for l in c['lines']) for c in story['chapters'])+'\n')
    save(episode/'concept/direction.json',story['direction'])
    gameplay=json.loads((episode/'gameplay/challenges.json').read_text())
    if gameplay['duration']!=story['duration']:raise ValueError('Story/gameplay clocks disagree')
    save(episode/'gameplay/manifest.json',gameplay)
    if not (episode/'audio/timeline.json').exists():
        print('Prepared dialogue, complete script, spatial timeline and interaction contracts; voice needed next.')
        return
    audio=json.loads((episode/'audio/timeline.json').read_text())
    if audio.get('dialogue_sha256')!=hashlib.sha256((episode/'scripts/dialogue.json').read_bytes()).hexdigest():
        raise ValueError('Script/placement changed after voice preparation. Preserve the previous audio revision and rebuild voice/timing first.')
    words=audio['words']; review_path=episode/'audio/caption_review.json'
    caption_review=json.loads(review_path.read_text()) if review_path.exists() else {}
    omitted=caption_review.get('omit_uncertain_caption_word_ranges',[])
    corrections=caption_review.get('safe_same_unit_spelling_corrections',[])
    for fix in corrections:
        if words[fix['word_index']]['word']!=fix['from']:raise ValueError('Stale caption spelling review')
        words[fix['word_index']]['word']=fix['to']
    audio['display_corrections']=corrections
    audio['raw_alignment_preserved']='timeline.json and processed/*.words.json retain original recognizer output'
    save(episode/'audio/render_timeline.json',audio)
    clips={c['id']:c for c in audio['clips']}
    performances=[]; mouths=[]; captions=[]; script=[]; shots=[]; drawings=[]; props=[]; events=[]; sfx=[]; beats=[]; camera=[]; sounds=[]
    catalog_path=PROJECT/'assets/sfx/source_catalog.json'
    if not catalog_path.exists():
        catalog_path.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(REPO/'common/audio/sfx/sfx_catalog.json',catalog_path)
    catalog=json.loads(catalog_path.read_text())['assets']
    licensed=[x for x in catalog if x.get('source') in ['Mixkit','Kenney'] and x.get('commercial_use')]
    choices=[('paper','paper'),('ui','success'),('cartoon',''),('transitions',''),('drawing','')]
    selected=[]
    for cat,key in choices:
        pool=[x for x in licensed if x['category']==cat and key in x['id']]
        if pool:selected.append(pool[0])
    if not selected:raise ValueError('No licensed recorded SFX available')
    for ci,ch in enumerate(story['chapters']):
        start,end=ch['start'],ch['end']
        framing=ch['framing']; center=[960,540]
        zoom=1
        shots.append(dict(id=ch['id'],start=start,end=end,background='paper',actors={'nemi':dict(position=[660,535],scale=1.7)},camera=dict(center=center,zoom=zoom)))
        camera.append(dict(start=start,end=end,words=ch['lines'][0]['text'],framing=framing,intent=ch['focus'],panorama_policy='Viewer controls orientation. Director review uses authored yaw only; spherical upload has no forced turn.'))
        visual=ch.get('drawing')
        beats.append(dict(start=start,end=end,thought=ch['name'],focus=ch['focus'],visual=visual if isinstance(visual,str) and visual.strip() else ch['focus'],intent='Develop one thought with settled acting and readable spatial evidence.'))
        chapter_drawings,chapter_props=chapter_plates(ch)
        drawings.extend(chapter_drawings);props.extend(chapter_props)
        for li,line in enumerate(ch['lines']):
            clip=clips[line['id']]; ws=[(i,w) for i,w in enumerate(words) if w['start']>=clip['at']-.002 and w['end']<=clip['end_at']+.002]
            if not ws:raise ValueError('Missing measured words '+line['id'])
            a=ws[0][1]['start'];b=ws[-1][1]['end']
            script.append(dict(actor='nemi',start=clip['at'],end=clip['end_at'],text=line['text']))
            performances.append(performance_cue(line,0 if ci==li==0 else a))
            for wi,w in ws:
                text=w['word'].lower();shape='o_u' if any(x in text for x in ['oo','you','who']) else 'ae' if any(x in text for x in ['a','e']) else 'small_open'
                m_end=max(w['start']+.015,w['end']-.035)
                mouths.append(dict(start=w['start'],end=min(m_end,w['end']),shape=shape))
            for j in range(0,len(ws),4):
                group=ws[j:j+4]
                if any(group[0][0]<=x['words'][1] and group[-1][0]>=x['words'][0] for x in omitted):continue
                captions.append(dict(actor='nemi',words=[group[0][0],group[-1][0]],start=group[0][1]['start'],end=group[-1][1]['end'],text=' '.join(w['word'] for _,w in group)))
    assets_by_id={x['id']:x for x in licensed}
    by_clip={c['id']:[w for w in words if c['at']<=w['start']<c['end_at']] for c in audio['clips']}
    def anchor(item):return measured_anchor(item,by_clip)
    for cue in story.get('sound_cues',[]):
        event_at=anchor(cue);eid=cue['id'];events.append(dict(id=eid,at=event_at,intent=cue['intent']))
        asset=assets_by_id[cue['asset_id']];source=REPO/asset['relative_path'];target=PROJECT/'assets/sfx'/source.name
        target.parent.mkdir(parents=True,exist_ok=True)
        if not target.exists():shutil.copy2(source,target)
        sfx.append(dict(file=source_ref(target),at=event_at,duration=cue['duration'],gain_db=cue['gain_db'],event=eid))
        sounds.append(dict(event=eid,at=event_at,source=asset['relative_path'],copy=str(target.relative_to(PROJECT)),sha256=hashlib.sha256(target.read_bytes()).hexdigest(),license=asset['license'],source_url=asset.get('source_url'),intent=cue['intent']))
    authored_cues,authored_events=anchored_acting(story.get('acting_beats',[]),by_clip,story['chapters'])
    if {e['id'] for e in authored_events}&{e['id'] for e in events}:raise ValueError('Anchored acting event conflicts with a sound event')
    events.extend(authored_events)
    # An explicit word beat may deliberately replace a line's initial pose.
    # Two independently authored word beats at one time were rejected above.
    for cue in authored_cues:
        performances=[old for old in performances if abs(old['at']-cue['at'])>=1e-6]
        performances.append(cue)
    event_times={e['id']:e['at'] for e in events}
    effects=[]
    for cue in story.get('reaction_cues',[]):
        at=event_times[cue['event']]
        effects.append(dict(kind=cue['kind'],author='nemi',actor='nemi',at=at,end=at+.7,strength=cue['strength'],event=cue['event']))
    for cue in story.get('acting_accents',[]):
        at=event_times[cue['event']] if 'event' in cue else anchor(cue)
        performances.append(performance_cue(cue,at))
    performances.sort(key=lambda x:x['at'])
    for drawing in story.get('additional_drawings',[]):
        drawings.append(resolve_art_event(drawing,event_times))
    for prop in story.get('additional_props',[]):
        props.append(resolve_art_event(prop,event_times))
    for segment in scenes:
        for cue in segment.get('environment_events',[]):
            length=cue['end']-cue['at']
            cue['at']=event_times[cue['event']]
            cue['end']=round(cue['at']+length,6)
    for ch,segment,plan in zip(story['chapters'],scenes,camera):
        if ch.get('camera_beats'):
            segment['review_camera_beats']=anchored_camera(ch['camera_beats'],by_clip,ch)
            plan['word_cues']=[dict(at=beat['at'],yaw=beat['yaw'],pitch=beat['pitch'],fov=beat['fov'],duration=beat['duration'],action=beat['intent']) for beat in segment['review_camera_beats']]
        elif ch.get('review_look'):
            look=anchor(ch['review_look']);back=anchor(ch['review_return'])
            yaw=ch['review_yaw']
            if not ch['start']<=look<look+.8<back<back+.8<=ch['end']:
                raise ValueError('Measured camera look/return does not fit chapter '+ch['id'])
            segment['review_yaw_path']=[{'at':ch['start'],'yaw':0},{'at':look,'yaw':0},
                {'at':round(look+.8,6),'yaw':yaw},{'at':back,'yaw':yaw},
                {'at':round(back+.8,6),'yaw':0}]
            plan['word_cues']=[dict(at=look,exact_word=ch['review_look']['word'],action='Turn to the actual clue; hold readable evidence',return_at=back),
                dict(at=back,exact_word=ch['review_return']['word'],action='Return to Nemi and the key prompt; settle and hold')]
        else:
            plan['word_cues']=[dict(at=clips[ch['lines'][0]['id']]['at'],exact_words=ch['lines'][0]['text'],action='Face Nemi; hold this personal thought')]
    save(episode/'storyboard/timeline.json',spatial)
    spec=dict(version=2,title=story['title'],duration=story['duration'],fps=story['fps'],audio=source_ref(episode/'audio/narration.wav'),audio_metadata=source_ref(episode/'audio/render_timeline.json'),caption_size=48,
        direction=story['direction']|{'beats':beats},actors=[dict(id='nemi',author='nemi',performances=performances,mouths=mouths)],shots=shots,drawings=drawings,props=props,events=events,sfx=sfx,vfx=effects,script=script,captions=captions)
    if (episode/'audio/score.wav').exists():spec['music']=[dict(at=0,file=source_ref(episode/'audio/score.wav'),duration=story['duration'],gain_db=-15)]
    if (episode/'audio/mix_calibration.json').exists():
        calibration=json.loads((episode/'audio/mix_calibration.json').read_text())
        fingerprint=hashlib.sha256(json.dumps({'audio':spec['audio'],'sfx':sfx,'music':spec.get('music',[])},sort_keys=True).encode()).hexdigest()
        if calibration.get('configuration_sha256')!=fingerprint:raise ValueError('Mix configuration changed; preserve previous calibration and recalibrate.')
        spec['mix']=calibration['mix']
    save(episode/'scene.json',spec);save(episode/'camera_plan.json',camera);save(episode/'sound_plan.json',sounds)
    srt=[]
    def st(t):
        ms=round(t*1000);return f'{ms//3600000:02d}:{ms//60000%60:02d}:{ms//1000%60:02d},{ms%1000:03d}'
    for i,c in enumerate(captions):srt.append(f'{i+1}\n{st(c["start"])} --> {st(c["end"])}\n{c["text"]}\n')
    (episode/'metadata').mkdir(exist_ok=True);(episode/'metadata/captions.srt').write_text('\n'.join(srt))
    print(f'Built full stage spec with {len(words)} measured words; {len(captions)} captions; {len(sfx)} licensed recorded SFX cues.')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--episode',type=Path,default=PROJECT/'episodes/episode_001');a=p.parse_args();prepare(a.episode.resolve())
