#!/usr/bin/env python3
"""Author the R7 practice-and-three-decisions cut after preserving R6."""
import json
from pathlib import Path
P=Path(__file__).resolve().parents[1]
def save(path,data):path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
def main():
    assert (P/'review/revisions/r6_source_snapshot/snapshot.json').exists()
    previous=json.loads((P/'review/revisions/r6_source_snapshot/scripts/story.json').read_text())
    definitions=[
      ('practice','hallway','PRACTICE · PRESS 1','Press 1 to open the badge round.','school_satchel','your choice changes the scene',0,[
        "You control my school day. Three choices. Please get me to assembly with some dignity.",
        "First, a practice. Press one on your keyboard. It opens the badge round. Try it now.",
        "Drag to look around. On a phone, swipe, then choose chapter one. I'll wait right here."],['school_brace','school_present','school_point']),
      ('badge_choice','hallway','1 · BADGE OR LUNCH','Find the star badge. Choose badge or sandwich.','school_questions','round one: badge or lunch',-90,[
        "Round one. Badge or lunch? I need my student badge to get into assembly.",
        "Look left. The star badge is three. The sandwich is two. Choose one number.",
        "Three takes the badge. Two inspects lunch. You can choose while I worry."],['school_question','school_point','skeptical']),
      ('sandwich_result','hallway','2 · SANDWICH ROUTE','Sandwich inspected. Press 3 to use the badge.','school_notebook','sandwich security',0,[
        "Sandwich route. That's lunch. Apparently bread is not a recognized form of identification.",
        "The sandwich has excellent layers. None of them contain my student number.",
        "Press three to take the badge and continue. I'm retiring from sandwich security."],['deadpan','school_explain','school_point']),
      ('badge_result','classroom','3 · BADGE FOUND','Badge found. Press 4 for the noticeboard.','clipboard','student host?!',0,[
        "Badge route. Badge found. Wait. Student host? I volunteered to hold a door. An audience is different.",
        "One signature. That's all it took to promote me from late student to public entertainment.",
        "Next: choose the right room. Press four for the noticeboard. Please read it more carefully than I did."],['realization','school_shame','school_point']),
      ('notice_choice','classroom','4 · WHICH ROOM?','Choose the new assembly notice or the old pudding notice.','route_map','round two: which room',90,[
        "Round two. Which room? Look right. Today's star marks the new assembly notice.",
        "Six goes to assembly. Five follows the crossed-out pudding notice. One of these seems suspiciously delicious.",
        "Choose five for pudding, or six for assembly. I'll judge the school, not you."],['school_question','school_point','skeptical']),
      ('pudding_result','classroom','5 · PUDDING ROUTE','Pudding detour. Press 6 to go to assembly.','mug','pudding department',0,[
        "Pudding route. There is no pudding. The cup is full of pencils. This department has betrayed me.",
        "If you came for dessert, I'm sorry. If you're just watching, this is why I need supervision.",
        "Press six to go to assembly. I'm leaving a strongly worded review in crayon."],['deadpan','embarrassed','school_resolve']),
      ('assembly_result','assembly','6 · ASSEMBLY REACHED','Assembly reached. Press 7 for the final choice.','school_notebook','one tiny microphone',0,[
        "Assembly route. We made it. That's the microphone. Why does it look more prepared than me?",
        "I could hide. Or I could check the audience before inventing a national emergency.",
        "Press seven for the last choice. Hide, or take the microphone. You get the deciding vote."],['school_relief','school_shame','school_present']),
      ('audience_choice','assembly','7 · HIDE OR HOST?','Look behind Nemi. Choose hiding or the microphone.','school_questions','round three: hide or host',180,[
        "Final round. Hide or host? Turn around and look at the audience before you choose.",
        "The audience is three stuffed animals. Eight is hiding. Nine takes the microphone. I can probably survive a duck.",
        "Ready? Press nine. Want the cowardly version? Press eight. I've prepared both emotionally."],['school_brace','realization','school_point']),
      ('hiding_result','assembly','8 · HIDING ROUTE','Hiding detour. Press 9 to take the microphone.','clipboard','an excellent hiding place',0,[
        "Hiding route. My natural habitat: avoiding a harmless social situation. A very comfortable mistake.",
        "Unfortunately, the duck can still see me. I've hidden behind a clipboard. It is not a large clipboard.",
        "Press nine for the stage. We'll face the three softest critics in education together."],['embarrassed','skeptical','school_resolve']),
      ('stage_result','assembly','9 · ON STAGE','You reached the ending. Press 0 to play again.','clipboard','you saved my school day',0,[
        "On stage. Good morning, distinguished duck. Today's lesson: read the form before volunteering.",
        "I survived. You're hired: camera operator. Your salary is imaginary pudding. The benefits are also imaginary.",
        "Press zero to play again and try the ridiculous routes. And please don't read the duck's review."],['school_present','pleased','deadpan'])]
    options=[[(1,'Start: badge round')],[(2,'Inspect sandwich'),(3,'Use star badge')],[(3,'Use star badge')],[(4,'Choose the room')],[(5,'Try pudding room'),(6,'Go to assembly')],[(6,'Go to assembly')],[(7,'Make the final choice')],[(8,'Hide behind clipboard'),(9,'Take the microphone')],[(9,'Take the microphone')],[(0,'Play again')]]
    titles=['PRACTICE: PRESS 1','1  BADGE OR LUNCH','2  SANDWICH ROUTE','3  BADGE FOUND','4  CHOOSE THE ROOM','5  PUDDING ROUTE','6  ASSEMBLY REACHED','7  HIDE OR HOST','8  HIDING ROUTE','9  ON STAGE']
    chapters=[];prompts=[];drawings=[]
    for i,(ident,loc,name,objective,prop,heading,yaw,texts,recipes) in enumerate(definitions):
        start,end=i*24,(i+1)*24
        lines=[dict(id=f'r7_{i}_{j}',text=text,at=start+[.8,8.3,15.8][j],window_end=start+[8,15.5,23.9][j],recipe=recipes[j],tempo=1.12 if i not in [2,8,9] else 1.08) for j,text in enumerate(texts)]
        entry=dict(duration=3.5,title=titles[i],subtitle='Three choices. You control the route.' if i==0 else objective)
        chapter=dict(id=ident,start=start,end=end,name=name,location=loc,focus=objective,framing='wide' if yaw else 'medium',review_yaw=yaw,review_fov=60 if yaw else 50,prop=prop,drawing=heading,heading_size=34,lines=lines,entry_card=entry)
        if yaw:
            chapter['review_look']={'clip_id':lines[1 if i==1 else 0]['id'],'word':'left' if i==1 else 'right' if i==4 else 'around'}
            chapter['review_return']={'clip_id':lines[2]['id'],'word':'Three' if i==1 else 'Choose' if i==4 else 'Ready'}
        chapters.append(chapter)
        choices=[dict(key=k,label=label,chapter=definitions[k][0]) for k,label in options[i]]
        prompts.append(dict(id=ident,start=start,end=end,objective=objective,choices=choices,feedback=titles[i]))
        label='   /   '.join(f'{k}: {text.lower()}' for k,text in options[i])
        drawings.append(dict(author='nemi',kind='text',text=label,size=28,position=[980,730],at=start+15.5,end=end,mode='hold',shots=[ident]))
    def sound(ident,chapter,line,word,asset,duration,gain,intent):
        return dict(id=ident,clip_id=f'r7_{chapter}_{line}',word=word,asset_id=asset,duration=duration,gain_db=gain,intent=intent)
    sounds=[
      sound('missing_badge',1,0,'badge','paper_page_turn_crisp_01',.452,-10,'The first task points to real identification.'),
      sound('camera_discovery',0,2,'Drag','transition_camera_shutter_01',.351,-10,'The practice explains actual view rotation.'),
      sound('badge_evidence',1,1,'star','paper_slide_desk_01',1.094,-10,'Focus on the authored badge option.'),
      sound('sandwich',2,0,'Sandwich','cartoon_boing_bounce_01',1.241,-11,'The sandwich route confirms a comic alternative.'),
      sound('student_host',3,0,'host','comedic_record_scratch_01',1.109,-10,'The recovered badge reveals the real obligation.'),
      sound('signature',3,1,'signature','paper_slide_desk_01',1.094,-12,'The commitment becomes evidence.'),
      sound('corrected_notice',4,0,'star','paper_page_turn_crisp_01',.452,-10,'The corrected star notice is the intended choice.'),
      sound('detour',5,0,'pudding','comedic_fail_low_tone_01',1.515,-11,'Pudding arrival confirms its promised silly route.'),
      sound('pencils',5,0,'pencils','cartoon_pop_dry_01',.305,-10,'The cup reveals the wrong dessert.'),
      sound('microphone_fear',6,0,'microphone','cartoon_boing_metallic_01',1.205,-12,'A small microphone earns an outsized reaction.'),
      sound('rehearsal_reveal',7,1,'animals','sting_magic_sparkle_chime_01',1.301,-11,'The audience discovery releases the fear.'),
      sound('hiding',8,0,'Hiding','comedic_fail_low_tone_01',1.1,-12,'The hide route gives its own clear comic consequence.'),
      sound('clipboard',8,1,'clipboard','paper_slide_desk_01',1.094,-10,'The hiding prop fails visibly.'),
      sound('duck_greeting',9,0,'duck','paper_page_turn_crisp_01',.452,-11,'Nemi starts the rehearsal from notes.'),
      sound('unpaid_promotion',9,1,'salary','comedic_fail_low_tone_01',1.1,-12,'The imaginary pay callback rewards the viewer.')]
    story=dict(id='episode_001',title='You Control My School Day — Three Choices',fiction=True,duration=240,fps=30,revision='r7',episode_id='episode_001',media_basename='NEMI_Playable_EP001_r7_2160x1080_360_REVIEW.mp4',
      direction=dict(promise='Make three easy choices to get Nemi through an accidental assembly commitment.',want='Nemi needs her badge, the correct room and enough courage to host.',choice='The viewer chooses a clearly named route using one number.',consequence='Each route opens with its exact name and a visible result, including funny detours.',payoff='The audience is three toys; Nemi hosts and pays the viewer imaginary pudding.'),
      chapters=chapters,additional_drawings=drawings,sound_cues=sounds,reaction_cues=[dict(event='student_host',kind='sweat',strength=.7),dict(event='rehearsal_reveal',kind='relief',strength=.7)],acting_accents=[dict(event='student_host',recipe='school_gasp'),dict(event='unpaid_promotion',recipe='deadpan')],navigation=dict(mode='youtube_digits',key_targets=[dict(key=i,chapter=c['id']) for i,c in enumerate(chapters)]),interaction_scenes=prompts)
    save(P/'scripts/story.json',story)
    locations=json.loads((P/'assets/locations.json').read_text())
    labels={'star_badge':'STAR\n3 USE BADGE','sandwich_decoy':'2 INSPECT LUNCH','old_notice':'OLD: 5 PUDDING\nINSPECTION ROOM','star_correction':'TODAY\n6 ASSEMBLY','audience_notice':'REHEARSAL\n3 STUFFED ANIMALS\n8 HIDE / 9 HOST'}
    for loc,walls in locations.items():
        for wall in walls:
            for item in wall['objects']:
                if item['id'] in labels:item['text']=labels[item['id']]
                if item['kind']=='door':item['text']='NEMI HERE' if wall['index']==0 else 'EXIT' if wall['index']==2 else 'ROOM A' if wall['index']==3 else 'ROOM B'
    save(P/'assets/locations.json',locations)
    game=json.loads((P/'gameplay/challenges.json').read_text())
    game['navigation']=story['navigation'];game['interaction_scenes']=prompts
    solutions=[(1,3,2,'star_badge','3 USE BADGE'),(4,6,5,'star_correction','6 ASSEMBLY'),(7,9,8,'audience_notice','9 HOST')]
    for c,(round_key,key,wrong,clue,label) in zip(game['challenges'],solutions):
        c.update(start=round_key*24,end=(round_key+2)*24,clue_id=clue,solution=label,solution_key=key,retry_key=round_key,alternative_keys=[wrong],valid_destinations=[key*24],alternative_outcomes=[wrong*24],objective=prompts[round_key]['objective'],instructions=prompts[round_key]['objective'],hints=[],retry_method=f'Press {round_key} to return to this round; each result offers a single forward continuation.',do_nothing='Nemi previews the optional silly detour, then the main story continues. No detected choice is claimed.',wrong_answer='The explicitly named detour gives a joke and a single clear continuation.',success='The named intended route gives an immediate outcome receipt from every viewing direction.')
    game['routes']=[dict(id='passive',times=[i*24 for i in range(10)]),dict(id='main',times=[0,24,72,96,144,168,216]),dict(id='all_silly',times=[0,24,48,72,96,120,144,168,192,216])]
    save(P/'gameplay/challenges.json',game)
    (P/'concept/R7_DIRECTION.md').write_text('''# R7: three choices with clear consequences

User-observed failure: local keys could lose focus, mismatched media still
accepted jumps, and preserved orientation hid the next scene. R7 repairs
those defects and teaches the interaction before the first puzzle.

A single practice key1 opens the badge round. Each round offers only two
named outcomes:2sandwich/3badge,5pudding/6assembly,8hide/9microphone. Results
name the exact promised route, visibly on all4walls for3.5seconds. One
forward key continues. No hint-key maze, inventory or detected-choice claim.
The uniquely marked NEMI HERE door and directional result cards recover
orientation. The local player shows loading and decoded arrival, supports
keys after native controls, refuses wrong media and keeps only current choices.

Keep240seconds maximum and the exact24second slot grid. New speech uses the
unchanged Sohee identity, with pitch-preserving1.12 on explanatory passages
and1.08 on dry detours/payoff. Measure every take and place selected gaps.
All dependent cues use fresh final audio. Preserve all rejected R6media/voice.
Full current1080review precedes any4Kmovie.
''')
    print('Authored R7:',sum(len(l['text'].split()) for c in chapters for l in c['lines']),'words; practice and3two-choice rounds.')
if __name__=='__main__':main()
