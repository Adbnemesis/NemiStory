#!/usr/bin/env python3
"""Episode-owned authored content. Run only when preparing a new source revision."""
import json,re,copy
from pathlib import Path
E=Path(__file__).resolve().parents[1]
def save(n,d):
 p=E/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
draft=(E/'concept/FULL_GAME_SCRIPT_DRAFT.md').read_text()
texts=re.findall(r'^> (.+)$',draft,re.M)
assert len(texts)==13,len(texts)
ids=['drawing_hook','phone_chapter_hint','door_admission','door_recovery','tear_discovery','desk_beyond','bridge_choice','bridge_failure','fold_cross','eraser_choice','race_failure','eraser_ride','studio_ending']
T=dict(zip(ids,texts))
sceneids=['the_floor_is_disappearing','the_door_was_only_ink','there_is_space_beyond','the_missing_bridge','the_bridge_gives_way','the_paper_holds','where_is_the_eraser','the_path_is_gone','the_eraser_lift','a_solid_desk']
names=['Get me off the page','The door is only ink','A real opening','The unfinished bridge','Before the first step','A supported paper fold','The eraser is going there','The erased shortcut','The ridiculous vehicle','Outside the drawing']
groups=['page_room']*3+['gap_room']*3+['edge_choice','edge_failure','edge_ride','studio']
actorwalls=[0,3,1,0,3,1,0,3,1,0]
yaws=[0,-76,76,0,-76,76,0,-76,76,0]
clips=[['drawing_hook','phone_chapter_hint'],['door_admission','door_recovery'],['tear_discovery','desk_beyond'],['bridge_choice'],['bridge_failure'],['fold_cross'],['eraser_choice'],['race_failure'],['eraser_ride'],['studio_ending']]
recipes=['quiet_recoil','realization','realization','embarrassed','school_brace','uncertain','school_question','quiet_recoil','school_brace','school_relief']
placements={'drawing_hook':(.35,17.9),'phone_chapter_hint':(18.1,23.75),'door_admission':(24.4,33.0),'door_recovery':(34,47.5),'tear_discovery':(48.3,57.5),'desk_beyond':(58.0,71.5)}
chapters=[]
for i in range(10):
 start=i*24;end=start+24
 lines=[]
 for j,cid in enumerate(clips[i]):
  at,window=placements.get(cid,(start+.4,end-.5))
  lines.append(dict(id=cid,text=T[cid],at=at,window_end=window,tempo=1.08 if cid=='bridge_choice' else 1.0,recipe=recipes[i] if j==0 else 'explaining',duration=.45,hands={'left':'relaxed','right':'relaxed'}))
 chapters.append(dict(id=sceneids[i],name=names[i],start=start,end=end,location=groups[i],continuity_group=groups[i],actor_wall=actorwalls[i],review_yaw=yaws[i],review_fov=68,framing='Grounded full-body spatial action with an earned thought reaction',focus=names[i],drawing=None,prop=None,lines=lines,environment_events=[]))
s=dict(title='Please Get Me Out of My Own Drawing — Playable Storytime',episode_id='episode_002',revision='r5_full',media_basename='NEMI_Playable_EP002_r5_2160x1080_360_REVIEW.mp4',world_renderer='drawing',preview_choice_turns=True,duration=240,fps=30,direction=dict(promise='Help Nemi get off her unfinished sketchbook before the eraser removes the way out.',want='She wants the ordinary solid desk beyond the page.',choice='Inspect physical evidence around the sphere and choose one of two actions at three decisions.',consequence='Ink-only shortcuts collapse; a real paper fold supports her and the eraser becomes transport.',payoff='Nemi reaches the studio and keeps the eraser outside the book.'),chapters=chapters,acting_beats=[],sound_cues=[],reaction_cues=[],additional_drawings=[],additional_props=[])
def beat(cid,word,recipe,intent,**kw):
 b=dict(id=cid+'_'+re.sub(r'[^a-z0-9]','',word.lower())+str(len(s['acting_beats'])),clip_id=cid,word=word,recipe=recipe,duration=.35,intent=intent,hands={'left':'relaxed','right':'relaxed'});b.update(kw);s['acting_beats'].append(b)
def camera(i,cid,word,yaw,fov=68,**kw):chapters[i].setdefault('camera_beats',[]).append(dict(clip_id=cid,word=word,yaw=yaw,pitch=0,fov=fov,duration=.4,intent='Follow the named thought and its actual spatial evidence',**kw))
def cue(i,cid,word,eid,kind,obj,asset,span=1.,gain=-8,offset=0):
 s['sound_cues'].append(dict(id=eid,clip_id=cid,word=word,offset=offset,asset_id=asset,duration=min(span,1.1),gain_db=gain,intent=eid.replace('_',' ')+' uses an existing recorded source tied to this authored physical action'))
 chapters[i]['environment_events'].append(dict(id=eid+'_world',kind=kind,object=obj,at=i*24,end=i*24+span,event=eid))
# Preserve the accepted performance thoughts, measuring every anchor again.
for word,recipe in [('place','embarrassed'),('floor','quiet_recoil'),('Click','explaining'),('left','explaining'),('right','uncertain'),('press','explaining')]:beat('drawing_hook',word,recipe,'Approved opening thought',gaze=[-.7 if word=='left' else .7 if word=='right' else 0,0])
for cid,pairs in {
 'phone_chapter_hint':[('phones','explaining')],
 'door_admission':[('drawing','embarrassed'),('absolutely','deadpan')],
 'door_recovery':[('ambitious','skeptical'),('two','explaining')],
 'tear_discovery':[('space','realization'),('through','school_relief'),('best','deadpan')],
 'desk_beyond':[('desk','pleased'),('stop','quiet_recoil')],
 'bridge_choice':[('halfway','embarrassed'),('Future','deadpan'),('underneath','explaining'),('Four','uncertain')],
 'bridge_failure':[('confident','pleased'),('hole','quiet_recoil'),('useful','deadpan'),('Five','explaining')],
 'fold_cross':[('holding','school_relief'),('trusting','uncertain'),('normal','deadpan'),('across','school_relief'),('breathe','recover')],
 'eraser_choice':[('where','school_question'),('behind','uncertain'),('path','quiet_recoil'),('lift','realization'),('Seven','explaining')],
 'race_failure':[('nothing','deadpan'),('Excellent','skeptical'),('staying','school_brace'),('eight','school_resolve')],
 'eraser_ride':[('ridiculous','skeptical'),('going','school_brace'),('polite','deadpan'),('shoes','quiet_recoil'),('edge','realization')],
 'studio_ending':[('solid','school_relief'),('Thank','pleased'),('proper','school_resolve'),('Actually','deadpan'),('here','pleased')]
}.items():
 for w,r in pairs:beat(cid,w,r,'One clear thought change: '+w)
# Director-only views demonstrate the scan; sphere keeps viewer control.
camera(0,'drawing_hook','I',0);camera(0,'drawing_hook','door',-76);camera(0,'drawing_hook','tear',76);camera(0,'drawing_hook','press',0)
camera(1,'door_admission','Oh',-76);camera(1,'door_admission','absolutely',-92,50);camera(1,'door_recovery','put',-76);camera(1,'door_recovery','two',76)
camera(2,'tear_discovery','Wait',76);camera(2,'tear_discovery','best',92,56);camera(2,'desk_beyond','desk',76)
camera(3,'bridge_choice','Oh',0);camera(3,'bridge_choice','underneath',-76);camera(3,'bridge_choice','tab',76);camera(3,'bridge_choice','Four',0)
camera(4,'bridge_failure','I',-76);camera(4,'bridge_failure','useful',-92,52);camera(4,'bridge_failure','Back',-76)
camera(5,'fold_cross','There',76);camera(5,'fold_cross','trusting',91,56);camera(5,'fold_cross','across',76)
camera(6,'eraser_choice','Wait',0);camera(6,'eraser_choice','behind',180);camera(6,'eraser_choice','there',-76);camera(6,'eraser_choice','top',76);camera(6,'eraser_choice','Seven',0)
camera(7,'race_failure','I',-76);camera(7,'race_failure','Excellent',-92,54);camera(7,'race_failure','eight',76)
camera(8,'eraser_ride','Okay',76);camera(8,'eraser_ride','going',76);camera(8,'eraser_ride','edge',92,64)
camera(9,'studio_ending','A',0);camera(9,'studio_ending','Thank',0,48);camera(9,'studio_ending','eraser',25,68)
# Named physical actions. Recording trims are source-based and finite.
cue(0,'drawing_hook','eraser','eraser_cut','erase_sweep','giant_eraser','paper_slide_desk_01',1.0,-8,-.15)
cue(1,'door_admission','course','door_flat','door_flatten','ink_door','paper_page_turn_crisp_01',1.,-7,.3)
cue(1,'door_recovery','put','door_rewind','rewind','ink_door','comedic_record_scratch_fast_01',1.1,-10)
cue(2,'tear_discovery','space','tear_open','tear_open','real_tear','paper_page_turn_crisp_01',1.2,-6)
cue(4,'bridge_failure','bridge','bridge_falls','bridge_break','unfinished_bridge','impact_wood_hard_hit_01',1.2,-13)
cue(4,'bridge_failure','Back','bridge_rewind','rewind','unfinished_bridge','comedic_record_scratch_fast_01',1.1,-10)
cue(5,'fold_cross','fold','tab_opens','tab_fold','loose_tab','paper_book_paging_single_01',1.5,-7)
cue(6,'eraser_choice','behind','eraser_reappears','eraser_pass','rear_eraser','paper_slide_desk_01',2.4,-7)
cue(7,'race_failure','nothing','path_erased','bridge_break','race_path','paper_slide_desk_01',1.5,-7)
cue(7,'race_failure','back','path_rewind','rewind','race_path','comedic_record_scratch_fast_01',1.1,-10)
cue(8,'eraser_ride','going','ride_travel','eraser_pass','escape_vehicle','paper_slide_desk_01',8.,-9)
cue(9,'studio_ending','desk','studio_arrival','escape_reveal','desk','paper_slide_desk_01',1.,-10)
# All ten keys remain native percentage seeks; only six are story decisions.
nav=dict(mode='youtube_digits',key_targets=[dict(key=i,chapter=sceneids[i]) for i in range(10)])
choice_defs={0:[(1,'Try the door'),(2,'Take the tear')],1:[(2,'Take the tear')],3:[(4,'Run across'),(5,'Fold the tab')],4:[(5,'Fold the tab')],6:[(7,'Race it'),(8,'Ride it')],7:[(8,'Ride it')],9:[(0,'Play again')]}
objectives=['Find a real way off the page.','The door is only ink. Try the paper tear.','The tear opens. Follow the route to the missing floor.','Inspect the unfinished bridge and the loose paper tab.','The bridge gives way. Try folding the tab.','The paper holds. Nemi reaches the far bank.','Find the eraser, then choose how to reach the page edge.','The racing path is gone. Use the eraser.','The eraser carries Nemi toward the desk.','You reached the ending.']
interactions=[dict(id=sceneids[i],start=i*24,end=(i+1)*24,objective=objectives[i],feedback=names[i],choices=[dict(key=k,label=l,chapter=sceneids[k]) for k,l in choice_defs.get(i,[])]) for i in range(10)]
s['navigation']=nav;s['interaction_scenes']=interactions
save('scripts/story.json',s)
def obj(id,kind,x,y,text='',**kw):return dict(id=id,author='nemi',kind=kind,x=x,y=y,text=text,**kw)
def room(front,left,right,back=None):return [dict(index=i,objects=o) for i,o in enumerate([front,right,back or [obj('bindings','binder_ring',440,510)],left])]
r4=json.loads((E/'review/revisions/r4_approved_audition/assets/locations.json').read_text())['sketchbook']
locations={'page_room':r4}
locations['gap_room']=room([obj('gap_goal','paper_exit',960,130,'CROSS THE MISSING FLOOR'),obj('gap_landmark','page_edge',1240,840,'')],[obj('unfinished_bridge','sketch_bridge',1420,820,'4 RUN ACROSS')],[obj('loose_tab','paper_tab',500,837,'5 FOLD THE TAB')])
locations['edge_choice']=room([obj('edge_goal','paper_exit',960,130,'REACH THE PAGE EDGE'),obj('forward_edge','page_edge',1450,840,'')],[obj('race_path','sketch_bridge',1420,820,'7 RACE IT')],[obj('escape_vehicle','ride_eraser',500,925,'8 RIDE IT')],[obj('rear_eraser','eraser',1150,895),obj('rear_note','paper_exit',960,220,'THE ERASER IS HEADING TO THE DESK')])
locations['edge_failure']=room([obj('edge_goal','paper_exit',960,130,'REACH THE PAGE EDGE')],[obj('race_path','sketch_bridge',1420,820,'7 RACE IT')],[obj('escape_vehicle','ride_eraser',500,925,'8 RIDE IT')])
locations['edge_ride']=room([obj('ride_goal','paper_exit',960,130,'OFF THE PAGE')],[obj('last_ink','page_edge',1420,840,'')],[obj('escape_vehicle','ride_eraser',650,925,'8 RIDE IT'),obj('destination_desk','studio_desk',1500,1023,'')])
locations['studio']=room([obj('desk','studio_desk',450,760,''),obj('outside_eraser','eraser',1450,900,''),obj('final_title','paper_exit',1000,130,'BACK OUTSIDE THE DRAWING')],[obj('studio_pencil','pencil',1250,700,'')],[obj('finished_door','sketch_door',500,610,'A PROPER EXIT')])
save('assets/locations.json',locations)
challenges=[]
for i,start,answer,bad,clue,solution in [(0,0,2,1,'real_tear','2  TAKE THE TEAR'),(1,72,5,4,'loose_tab','5 FOLD THE TAB'),(2,144,8,7,'escape_vehicle','8 RIDE IT')]:
 challenges.append(dict(id=['real_exit','missing_floor','eraser_escape'][i],narrative_purpose=objectives[start//24],start=start,end=start+24,objective=objectives[start//24],instructions='Mouse: click and drag to look. Phone: swipe, then choose the matching numbered chapter. Desktop: press the displayed number.',clue_id=clue,inputs=['mouse drag','desktop WASD','YouTube app swipe','pause','desktop number keys','numbered chapters'],solution=solution,solution_key=answer,retry_key=start//24,alternative_keys=[bad],valid_destinations=[answer*24],alternative_outcomes=[bad*24],hints=[],visual_change='View rotation reveals physical evidence. Native digit seeks select authored outcomes at exact whole-video percentages.',success='The material choice creates a supported route and the story continues.',retry_method=f'Press {start//24} to inspect this choice again, or press {answer} for the physical route.',do_nothing='The failed attempt, authored rewind and better attempt play as a coherent linear story; no automatic choice detection.',wrong_answer='An entertaining physical failure and rewind names the safe next number.',state_tracking=False,desktop=True,mobile='Swipe to look and select the matching numbered chapter, when available; use description timestamps as recovery.',device_limitations=['Desktop player must have focus. Digits seek time and preserve pause/view state.','Mobile chapter and actual upload behavior need channel/device verification.','Local automatic viewpoint steering is optional and not part of the uploaded movie.']))
game=dict(duration=240,automatic_state=False,challenges=challenges,routes=[dict(id='passive',times=[i*24 for i in range(10)]),dict(id='main',times=[0,48,120,192]),dict(id='all_failures',times=[0,24,48,72,96,120,144,168,192,216])],navigation=nav,interaction_scenes=interactions)
save('gameplay/challenges.json',game)
print('Full source:',sum(len(l['text'].split()) for c in chapters for l in c['lines']),'words,13clips,240seconds.')
