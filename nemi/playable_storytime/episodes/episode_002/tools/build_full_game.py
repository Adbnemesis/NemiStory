#!/usr/bin/env python3
"""Compile the full native-percentage game from final canonical audio."""
import json,copy,sys
from pathlib import Path
E=Path(__file__).resolve().parents[1];P=E.parents[1]
sys.dont_write_bytecode=True;sys.path.insert(0,str(P/'tools'))
from prepare_episode import prepare,save

def build():
 if not (E/'audio/timeline.json').exists():raise ValueError('Prepare the complete full-game voice before compiling picture.')
 prepare(E)
 spec=json.loads((E/'scene.json').read_text());timeline=json.loads((E/'storyboard/timeline.json').read_text());story=json.loads((E/'scripts/story.json').read_text())
 timeline.update(world_renderer='drawing',preview_choice_turns=True)
 for field in ['preview_goal','preview_handoffs','natural_continuity']:
  if field in story:timeline[field]=copy.deepcopy(story[field])
 timeline.pop('kind',None);timeline.pop('playable',None);timeline.pop('world_continuity',None)
 events={event['id']:event['at'] for event in spec['events']}
 arrivals=[]
 for i,(chapter,segment,shot) in enumerate(zip(story['chapters'],timeline['scenes'],list(spec['shots']))):
  wall=chapter['actor_wall']
  segment['actor_wall']=wall;segment['continuity_group']=chapter['continuity_group'];segment['name']=chapter['name']
  placement=dict(position=[960,620],scale=1.4)
  if wall==3:placement['position']=[900,620]
  if wall==1:placement['position']=[1000,620]
  placement['position']=chapter.get('actor_position',placement['position'])
  shot['actors']['nemi']=placement
  # A successful result flows into the next thought without a new room/view.
  start_yaw=chapter['review_yaw'];start_fov=chapter.get('review_fov',68)
  if i in [3,6,9] and 'natural_continuity' in story:
   previous=timeline['scenes'][i-1]
   previous_beats=previous.get('review_camera_beats',[])
   start_yaw=previous_beats[-1]['yaw'] if previous_beats else previous['review_yaw']
   start_fov=previous_beats[-1]['fov'] if previous_beats else previous.get('review_fov',68)
  segment.setdefault('review_camera_beats',[]).insert(0,dict(at=chapter['start'],yaw=start_yaw,pitch=0,fov=start_fov,duration=0,intent='Keep the established spatial anchor into this thought; no front-facing reset.'))
  if i in [1,2,4,5,7,8]:
   segment['entry_card']=dict(duration=3,title={1:'1 DOOR',2:'2 TEAR',4:'4 RUN ACROSS',5:'5 FOLD THE TAB',7:'7 RACE IT',8:'8 RIDE IT',3:'MISSING FLOOR',6:'FIND THE ERASER',9:'BACK IN THE STUDIO'}[i],subtitle='The chosen action is in this direction')
  else:segment.pop('entry_card',None)
  if i==5:
   # Anticipation / fold / cut / arrival coverage. This does not fake a walk.
   at=next(c['at'] for c in spec['actors'][0]['performances'] if c.get('event','').startswith('acting_fold_cross_across'))
   shot['end']=at
   arrival=copy.deepcopy(shot);arrival.update(id=shot['id']+'_arrival',start=at,end=chapter['end']);arrival['actors']['nemi']['position']=[320,620]
   arrivals.append(arrival)
  if i==8:
   start=events['ride_travel'];end=start+8
   if end>chapter['end']-.2:raise ValueError('Ride narration anchor leaves insufficient authored travel time')
   vehicle=next(o for w in segment['walls'] for o in w['objects'] if o['id']=='escape_vehicle')
   vehicle['path']=[dict(at=start,position=[650,925]),dict(at=end,position=[1150,925])]
   segment['actor_transport']=dict(actor='nemi',object='escape_vehicle',event='ride_travel')
   shot['actors']['nemi']['position']=[650,620]
  if i==6 and any(o.get('erasing',False) for w in segment['walls'] for o in w['objects']):
   # One eraser: inspect it eating the ink, then board that same solid top.
   start=events['eraser_reappears'];end=start+8
   vehicle=next(o for w in segment['walls'] for o in w['objects'] if o['id']=='escape_vehicle')
   vehicle['path']=[dict(at=start,position=[440,925]),dict(at=end,position=[650,925])]
  # Continuous finished states remain in each group; latest result labels persist.
  if i in [1,4,7]:
   safe={1:'2 TAKE THE TEAR',4:'5 FOLD THE TAB',7:'8 RIDE IT'}[i]
   rewind=next(event['event'] for event in segment['environment_events'] if event['kind']=='rewind')
   for w in segment['walls']:
    w['objects'].append(dict(id='recovery_'+str(w['index']),author='nemi',kind='paper_exit',x=960,y=330,text=safe,visible_from_event=rewind))
 # Outcome shots retain finished erased geography, while each physical set/cut
 # owns only its own finite events. No off-scene event is introduced.
 for segment in timeline['scenes'][1:3]:
  for w in segment['walls']:
   for o in w['objects']:
    if o['id']=='giant_eraser':o['erased']=True
 for i,segment in enumerate(timeline['scenes']):segment['continuity_group']='full_'+str(i)
 spec['shots'].extend(arrivals);spec['shots'].sort(key=lambda shot:shot['start'])
 if 'natural_continuity' in timeline:
  from continuity import validate_natural_joins
  validate_natural_joins(timeline,spec)
 # Breaths and held processing blinks are authored once, with ample cue spacing.
 for cue in spec['actors'][0]['performances']:
  if cue['recipe'] in ['deadpan','school_relief']:
   following=next((x['at'] for x in spec['actors'][0]['performances'] if x['at']>cue['at']),spec['duration'])
   if cue['at']+.9<following:cue['blinks']=[round(cue['at']+.5,6)]
 performances=spec['actors'][0]['performances']
 for index,cue in enumerate(performances):
  next_at=performances[index+1]['at'] if index+1<len(performances) else spec['duration']
  cue['duration']=min(cue.get('duration',.35),round(max(0,next_at-cue['at']-.001),6))
 # The compiler zip above must use the original ten shots despite arrival insert.
 save(E/'scene.json',spec);save(E/'storyboard/timeline.json',timeline)
 # Exact numbered chapters support phones, with timestamp links as recovery.
 chapters='\n'.join(f'{int(c["start"])//60}:{int(c["start"])%60:02d} {i} · {c["name"]}' for i,c in enumerate(story['chapters']))
 (E/'metadata/chapters.txt').write_text(chapters+'\n')
 (E/'metadata/title.txt').write_text('Please Get Me Out of My Own Drawing… (Playable 360° Storytime)\n')
 (E/'metadata/description.txt').write_text('An original fictional Nemi playable storytime. Help me escape the sketchbook!\n\nHOW TO PLAY\nDesktop: click the player, then click-and-drag or use WASD to look. Press the number beside your chosen action. If paused, press K or Play to see the result.\nPhone: use the current YouTube app; swipe to look, then select the matching numbered chapter. Chapter names/timestamps below provide a recovery route. The drawn labels are not tappable buttons.\n\nChoices:1/2 door or tear;4/5 run or fold;7/8 race or ride. The successful route needs three choices. You can also watch every attempt straight through. No inventory, automatic score or reaction timer.\n\n'+chapters+'\n\nNative YouTube controls and mobile chapter availability require verification of this exact upload. The local review can optionally turn toward choices; that convenience is not embedded in this MP4.\n')
 print('Full game built:',len(spec['shots']),f'authored shots; exact{story["duration"]}-second clock; three decisions.')
if __name__=='__main__':build()
