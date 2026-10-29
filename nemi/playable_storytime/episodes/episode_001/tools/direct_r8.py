"""Episode-specific R8 direction, resolved against final measured narration."""
from pathlib import Path
import json, re

EPISODE=Path(__file__).resolve().parents[1]

def direct():
    path=EPISODE/'scripts/story.json'
    story=json.loads(path.read_text())
    if story['revision'] not in ['r8','r9']:raise ValueError('This direction belongs only to the R8/R9 conversational cut.')
    chapters=story['chapters']
    for chapter,location in zip(chapters,['volunteer_hall','hallway','lunch_hall','host_classroom','classroom','pudding_cupboard','assembly_stage','assembly','assembly','final_rehearsal']):
        chapter['location']=location
    # Words below are actual final-recording anchors. Small reaction variations
    # direct existing controls; no recipe, rig or handwriting is replaced.
    plans=[
      [('free','pleased','Dessert briefly wins over judgment',{'right':'open_palm_up'}),
       ('signed','school_shame','Admit signing before reading',{}),
       ("You're",'school_confide','Make the viewer a trusted friend',{'right':'hand_to_chest'}),
       ('worse','deadpan','Acknowledge her own poor judgment',{}),
       ('Drag','explaining','Offer one calm practical instruction',{'right':'open_palm_up'}),
       ('phones','school_point','Include phone viewers without an announcer voice',{'right':'pointing'})],
      [('left','school_point','Eyes and pointing hand lead toward the evidence',{'left':'pointing'}),
       ('sandwich','pleased','Be visibly tempted by lunch',{'right':'open_palm_up'}),
       ('useful','skeptical','Compare herself with a sandwich',{}),
       ('door','school_resolve','Remember the sensible objective',{}),
       ('avoid','embarrassed','Catch herself inventing an excuse',{'right':'hand_to_cheek'}),
       ('Three','school_point','Give both concise choices once',{'left':'pointing'}),
       ('Please','school_confide','Ask a friend not to enable her',{}),
       ('easy','deadpan','Admit that she absolutely can be enabled',{})],
      [('hear','prop_present','Interview the absurd alternative',{'right':'open_palm_up'}),
       ('prepared','pleased','Build an unreasonable case for bread',{}),
       ('Honestly','school_question','Actually consider replacing herself',{'right':'hand_to_cheek'}),
       ('wearing','realization','The badge comparison briefly seems persuasive',{}),
       ('Unfortunately','quiet_recoil','Reality interrupts the excuse',{}),
       ('home','embarrassed','Confess what she really wanted',{}),
       ('emergency','skeptical','Retain a little faith in the understudy',{})],
      [('goodness','school_relief','Relief before reading the smaller text',{}),
       ('Hang','school_question','Eyes drop to read the badge',{}),
       ('HOST','school_recoil','Recognition hits on the actual job title',{'left':'splayed_fingers','right':'splayed_fingers'}),
       ('thought','embarrassed','She had imagined disappearing into a small helpful job',{}),
       ('microphone','school_recoil','The part she was trying to avoid becomes concrete',{}),
       ('Apparently','skeptical','Read the evidence against herself',{}),
       ('enthusiastic','school_shame','Remember the fatal checkbox',{'right':'hand_to_cheek'}),
       ('Four','school_confide','Appeal to the viewer for the next decision',{})],
      [('sensible','explaining','Present what she knows she should choose',{'right':'open_palm_up'}),
       ('old','pleased','Her attention drifts toward dessert again',{}),
       ('anything','school_shame','Anticipate the viewer noticing the obvious flaw',{}),
       ('crossed','skeptical','Register the cross-out clearly',{}),
       ('decorative','deadpan','Defend an indefensible reading',{}),
       ('Six','school_point','Offer a responsible choice and a tempting detour',{'right':'pointing'}),
       ('hoping','pleased','A small sheepish admission of the preference',{})],
      [('cup','pleased','Hope rises at a familiar dessert shape',{'right':'open_palm_up'}),
       ('Oh','realization','Look into the cup before committing the body',{}),
       ('pencils','deadpan','Let the actual contents destroy the theory',{}),
       ('cupboard','embarrassed','Own the completely avoidable detour',{'right':'hand_to_cheek'}),
       ('spoon','uncertain','Notice that she is still looking anyway',{}),
       ('sandwich','skeptical','Remember her imaginary rival',{}),
       ('Six','school_resolve','Finally agree to move toward the assembly',{}),
       ('ingredients','deadpan','Lock eyes with the viewer after the last excuse',{})],
      [('microphone','school_brace','Gather herself in front of the real microphone',{}),
       ('explain','explaining','Recover confidence in a familiar interest',{'right':'open_palm_up'}),
       ('anime','pleased','Brief enthusiastic knowledge contrast',{'right':'pointing'}),
       ('good','school_question','Try the much simpler greeting',{}),
       ('personality','overwhelmed','The tiny social task defeats her confidence',{}),
       ('check','school_confide','Ask the companion for a manageable next action',{}),
       ('Seven','school_point','Direct attention to who is watching',{'right':'pointing'}),
       ('idea','recover','Try to regain a plausible composed face',{})],
      [('turn','school_point','Invite an actual look behind her',{'right':'pointing'}),
       ('toys','realization','The audience is smaller than her imagined catastrophe',{}),
       ('rehearsal','school_relief','Release the tension',{'right':'open_palm_up'}),
       ('apology','school_shame','Recognize how far the spiral went',{'right':'hand_to_cheek'}),
       ('duck','skeptical','Begin taking the toy personally',{}),
       ('knows','quiet_recoil','A specific suspicious duck thought',{}),
       ('Nine','school_present','Offer courage or another absurd escape',{'right':'open_palm_up'}),
       ('bear','deadpan','Stop before explaining herself to another toy',{})],
      [('still','deadpan','Freeze the planted full-body silhouette',{}),
       ('chair','deadpan','Only the dry face carries the furniture claim',{}),
       ('eye','deadpan','The body stays fixed while the eyes betray her',{}),
       ('toy','deadpan','Try to reason with herself without breaking the pose',{}),
       ('Nine','recover','Give up the hiding plan and release the frozen body',{}),
       ('speech','school_resolve','Choose the actual small brave action',{}),
       ('stuffing','deadpan','Give the final stare back to the viewer',{})],
      [('whatever','school_shame','Let the imperfect greeting happen',{}),
       ('fainted','pleased','A modest recovery instead of a victory pose',{}),
       ('disappointed','skeptical','One last glance toward the imagined critic',{}),
       ('progress','school_relief','Accept that an imperfect attempt counts',{}),
       ('Thank','pleased','Warm direct gratitude to one companion',{'right':'hand_to_chest'}),
       ('Friday','realization','Finally notice the date on the pudding evidence',{}),
       ('course','deadpan','The opening promise reverses; let it land',{}),
       ('Zero','soft_shrug','Invite another attempt without a sales pitch',{'right':'open_palm_up'})]
    ]
    words=[]
    if (EPISODE/'audio/timeline.json').exists():
        words=json.loads((EPISODE/'audio/timeline.json').read_text())['words']
    clean=lambda s:re.sub('[^a-z0-9]','',s.lower())
    acting=[]
    for index,rows in enumerate(plans):
        for order,(word,recipe,intent,hands) in enumerate(rows):
            if index==6 and order==0:
                # The line already enters this brace just before the noun.
                continue
            cue=dict(id=f'c{index}_{order}',clip_id=f'r8_{index}_0',word=word,recipe=recipe,
                     duration=.38,intent=intent,hands={'left':'relaxed','right':'relaxed'}|hands)
            if recipe in ['school_gasp','realization']:
                cue.update(duration=.18,motion='snap',face={'eye_openness':1.18,'pupil_scale':.75})
            elif recipe=='deadpan':cue.update(duration=.12,motion='snap',gaze=[0,0],face={'eye_openness':.83})
            elif recipe in ['school_shame','embarrassed']:
                cue.update(duration=.5,gaze=[.25,.3])
            elif recipe=='skeptical':
                cue.update(duration=.32,gaze=[.45,0],face={'left_brow_tilt':-.1,'right_brow_tilt':.09})
            elif recipe=='school_relief':cue.update(duration=.62)
            elif recipe in ['school_point','school_resolve']:cue.update(duration=.28,motion='stepped',step_fps=12)
            if index==1 and word=='left':cue['gaze']=[-.75,0]
            if index==3 and word=='Hang':cue['gaze']=[.55,.45]
            if index==3 and word=='HOST':
                cue.update(duration=.18,motion='snap',face={'eye_openness':1.18,'pupil_scale':.75})
            if index==5 and word=='Oh':cue['gaze']=[.6,.4]
            if index==8 and word in ['chair','eye','toy']:
                cue['duration']=.12
                cue['gaze']=[.6,0] if word=='eye' else ([.2,.2] if word=='toy' else [0,0])
            # Explicit blinks occur on selected processing beats, never a timer.
            if word in ['worse','Please','Honestly','Apparently','anything','spoon','check','apology','toy','course']:
                match=next((w for w in words if w.get('clip_id')==cue['clip_id'] and clean(w['word'])==clean(word)),None)
                if match:cue['blinks']=[round(match['start']+.12,6)]
            acting.append(cue)
    story['acting_beats']=acting
    camera_plans=[
      [('Look',-17,12,42,.2,'Confide directly from the first sentence'),('volunteer',20,0,58,.35,'Show the form that tempted her'),("You're",-17,12,43,.2,'Recruit one friend'),('Drag',0,0,72,.5,'Open the playable geography')],
      [('My',-17,9,52,.2,'Establish the person asking for help'),('left',-90,0,72,.65,'Show both badge and sandwich clearly'),('Please',-17,13,40,.24,'Return for the sheepish request')],
      [('Okay',-17,8,53,.2,'Give lunch a serious hearing'),('layers',22,0,54,.38,'Look at the actual prepared sandwich'),('Honestly',-17,13,39,.2,'Read the absurd calculation'),('badge',0,0,64,.4,'Return to the practical way forward')],
      [('Oh',-17,10,52,.22,'Relief before reading'),('badge',20,0,46,.35,'Read the host pass'),('HOST',-17,14,37,.12,'Catch the recognition on her face'),('thought',-17,8,52,.28,'Allow the embarrassed explanation room'),('enthusiastic',-17,13,41,.18,'Read the checkbox confession'),('Four',0,0,64,.3,'Resume the search')],
      [('new',90,0,74,.65,'Read both notices and the obvious cross-out'),('anything',-17,12,42,.25,'Catch her anticipating the objection'),('Six',90,0,74,.6,'Leave the two real labels readable'),('hoping',-17,12,44,.25,'Let the preference show')],
      [('worth',20,0,54,.3,'Hope and the actual cup share one focus'),('cupboard',-17,13,40,.22,'Read the embarrassed admission'),('sandwich',-17,10,48,.25,'The remembered rival is a reaction, not another insert'),('ingredients',-17,10,47,.2,'Hold the last dry thought')],
      [("That's",0,0,68,.3,'Establish Nemi and the microphone at the same scale'),('anime',-17,10,46,.3,'Let familiar confidence return'),('personality',-17,14,38,.18,'The simple greeting defeats her'),('check',0,0,68,.4,'Give the audience investigation space')],
      [('around',180,0,74,.65,'Turn the whole view to the real toy audience'),('knows',-17,13,39,.25,'Return to the suspicious duck reaction'),('Nine',0,0,66,.4,'Offer the last decision in context')],
      [('still',0,0,72,.3,'Prove the whole body is planted and frozen'),('eye',-17,14,38,.28,'Only the eyes betray the hiding plan'),('Nine',-17,8,54,.3,'Release the failed freeze')],
      [('Good',-6,5,57,.3,'Let the imperfect greeting occur beside the microphone'),('disappointed',180,0,65,.5,'Check the unmoving critic'),('progress',-17,10,48,.35,'Return to a modest recovery'),('Thank',-17,13,41,.3,'Keep the gratitude personal'),('pudding',20,0,57,.4,'Read the actual old date'),('course',-17,13,40,.2,'Hold the final realization')]
    ]
    for index,plan in enumerate(camera_plans):
        cues=[]
        for word,yaw,pitch,fov,span,intent in plan:
            # Positive elevation places the actor lower in frame. The first
            # proof exposed too much headroom; keep face/shoulder portraits low.
            cue=dict(clip_id=f'r8_{index}_0',word=word,yaw=yaw,pitch=max(0,pitch-6),fov=fov,duration=span,intent=intent)
            match=next((w for w in words if w.get('clip_id')==cue['clip_id'] and clean(w['word'])==clean(word)),None)
            if match and match['start']<chapters[index]['start']+3.6:
                delay=round(chapters[index]['start']+3.6-match['start'],6)
                if delay>2:continue
                cue['offset']=delay
                cue['intent']+='; hold the initial receipt before reframing'
            cues.append(cue)
        chapters[index]['camera_beats']=cues
    chapters[9]['camera_beats'].append(dict(clip_id='r8_9_0',word='time',offset=1.2,yaw=145,pitch=8,fov=48,duration=.4,intent='Use the final quiet hold for the duck review and sandwich callback'))
    sound_plan=[
      (0,'signed','form_signature','paper_page_turn_crisp_01',.452,-9,'Her signature makes the impulsive choice real'),
      (1,'sandwich','tempting_lunch','cartoon_boing_bounce_01',1.241,-12,'Lunch distracts her from the sensible task'),
      (2,'prepared','bread_candidate','cartoon_pop_dry_01',.305,-11,'The sandwich becomes her absurd better candidate'),
      (3,'HOST','job_title','comedic_record_scratch_01',1.109,-9,'The badge reveals the public-speaking obligation'),
      (3,'enthusiastic','fatal_checkbox','paper_slide_desk_01',1.094,-11,'She remembers the checkbox that caused this'),
      (4,'crossed','obvious_crossout','paper_page_turn_crisp_01',.452,-10,'The evidence contradicts her dessert theory'),
      (5,'pencils','dessert_contents','comedic_fail_low_tone_01',1.515,-10,'Actual pencils defeat the pudding theory'),
      (6,'microphone','microphone','cartoon_boing_metallic_01',1.205,-12,'A small object causes an outsized concern'),
      (7,'toys','toy_reveal','sting_magic_sparkle_chime_01',1.301,-11,'The toy audience releases the imagined danger'),
      (7,'knows','suspicious_duck','cartoon_pop_dry_01',.305,-12,'She immediately invents a new smaller worry'),
      (9,'Friday','old_date','comedic_fail_low_tone_01',1.1,-10,'Finally reading the date reverses the opening promise')
    ]
    story['sound_cues']=[dict(id=identity,clip_id=f'r8_{index}_0',word=word,asset_id=asset,duration=length,gain_db=gain,intent=intent) for index,word,identity,asset,length,gain,intent in sound_plan]
    story['reaction_cues']=[dict(event='job_title',kind='sweat',strength=.65),dict(event='toy_reveal',kind='relief',strength=.6)]
    story['acting_accents']=[]
    labels=['1 START','2 LUNCH / 3 BADGE','3 USE BADGE','4 NOTICEBOARD','5 PUDDING / 6 ASSEMBLY','6 ASSEMBLY','7 CHECK AUDIENCE','8 HIDE / 9 MICROPHONE','9 MICROPHONE','0 PLAY AGAIN']
    drawings=[dict(author='nemi',kind='text',text=text,size=30,position=[990,875],at=chapter['start']+3.5,end=chapter['end'],mode='hold',shots=[chapter['id']]) for chapter,text in zip(chapters,labels)]
    drawings.extend([
      dict(author='nemi',kind='underline',position=[1280,492],scale=[1.6,1],at=0,duration=.45,end=12,mode='live',event='acting_c0_0',shots=['practice']),
      dict(author='nemi',kind='text',text='enthusiastic?!',size=42,position=[1030,780],at=0,end=96,mode='hold',event='acting_c3_6',shots=['badge_result']),
      dict(author='nemi',kind='scratch',position=[1310,565],scale=[1.5,.7],at=0,duration=.4,end=144,mode='live',event='dessert_contents',shots=['pudding_result']),
      dict(author='nemi',kind='text',text='good morning...',size=38,position=[1020,320],at=0,end=164,mode='hold',event='acting_c6_3',shots=['assembly_result']),
      dict(author='nemi',kind='text',text='perfectly normal chair',size=34,position=[990,575],at=0,end=212,mode='hold',event='acting_c8_0',shots=['hiding_result']),
      dict(author='nemi',kind='arrow',position=[905,555],scale=[1.5,1.0],tilt=180,at=0,duration=.5,end=212,mode='live',event='acting_c8_0',shots=['hiding_result'])
    ])
    story['additional_drawings']=drawings
    story['additional_props']=[]
    if story['revision']=='r9':
        short_receipts=['Drag to look. Press 1 to start.','2 sandwich or 3 star badge.',
            'Press 3 for the star badge.','Press 4 for the noticeboard.',
            '5 pudding or 6 assembly.','Press 6 for assembly.',
            'Press 7 to check the audience.','Look behind Nemi. Choose 8 or 9.',
            'Hiding in plain sight. Press 9.','Press 0 to play again.']
        for chapter,text in zip(chapters,short_receipts):chapter['entry_card']['subtitle']=text
    replacement=path.with_suffix('.json.tmp');replacement.write_text(json.dumps(story,indent=2,ensure_ascii=False)+'\n');replacement.replace(path)
    game_path=EPISODE/'gameplay/challenges.json';game=json.loads(game_path.read_text())
    game['interaction_scenes']=story['interaction_scenes']
    for challenge in game['challenges']:
        for key,value in list(challenge.items()):
            if isinstance(value,str):challenge[key]=value.replace('Hide behind clipboard','Hide in plain sight').replace('hide behind a clipboard','freeze like school furniture').replace('imaginary clipboard','furniture hiding plan')
    game_path.write_text(json.dumps(game,indent=2,ensure_ascii=False)+'\n')
    print(f'Authored {len(acting)} thought-specific acting beats, {sum(map(len,camera_plans))} whole-world camera beats, {len(drawings)} selective/persistent drawings.')

if __name__=='__main__':direct()
