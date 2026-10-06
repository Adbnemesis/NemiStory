"""Author the requested eight motion edits from preserved interim sources.

This is an explicit batch direction, not a random motion generator or a skill
quality gate. Every camera recipe follows a named thought in the saved cue map.
Godot interprets all visual keys; this script only writes editable direction.
"""
from pathlib import Path
import copy,json,math
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'shorts/review/motion04'
ENDS={'my-song':435,'wrong-class':450,'quick-doodle':527,'different-energy':450,
      'act-natural':457,'adb-big-idea':420,'nemi-tiny-cat':420,'duo-matching-moment':405}
# Motion choices are aligned to each actual story, rather than one camera loop.
RECIPES={
 'my-song':['shy_pull','notice_push','groove_slide','groove_push','release_push','groove_slide','groove_push','groove_slide','release_push','caught_push','shy_pull','listen_push','release_push','groove_slide','listen_push'],
 'wrong-class':['runway_push','runway_slide','composed_pull','runway_push','runway_slide','detail_push','approval_push','door_follow','caught_push','recoil_pull','composed_pull','quiet_pull','farewell_push','exit_slide','exit_slide'],
 'quick-doodle':['page_push','detail_push','consider_pull','page_push','page_slide','page_push','detail_push','consider_pull','page_push','page_slide','page_push','caught_push','consider_pull','page_slide','reveal_push','detail_push','proud_pull'],
 'different-energy':['build_push','dry_pull','anticipate_push','invite_slide','invite_slide','drop_push','groove_slide','groove_slide','invite_slide','reply_push','shared_push','shared_slide','shared_slide','payoff_pull'],
 'act-natural':['awkward_pull','notice_push','offer_slide','reply_push','detail_push','awkward_pull','reframe_push','offer_slide','dry_pull','detail_push','shared_slide','awkward_pull','photo_push','photo_push','relief_pull','shared_slide','approval_push'],
 'adb-big-idea':['confident_push','caught_push','detail_push','consider_pull','idea_push','consider_pull','detail_push','recovery_slide','idea_push','composed_pull','detail_push','proud_pull'],
 'nemi-tiny-cat':['page_push','page_slide','detail_push','page_slide','moon_push','curled_pull','consider_pull','page_push','page_slide','consider_pull','reveal_push','detail_push','proud_pull','curled_pull','proud_pull'],
 'duo-matching-moment':['offer_slide','detail_push','reply_push','shared_slide','offer_slide','reply_push','notice_push','shared_slide','shared_slide','reply_push','photo_push','relief_pull','curled_pull','approval_push']}
IMPULSE_SHOTS={'my-song':{90,150,210,352},'wrong-class':{90,180,360},
 'quick-doodle':{124,248,426},'different-energy':{112,164,335,422},
 'act-natural':{79,166,342,434},'adb-big-idea':{90,292,360},
 'nemi-tiny-cat':{126,205,292},'duo-matching-moment':{90,189,315,375}}
def cue_at(actor,frame):return max((q for q in actor['cues'] if q['frame']<=frame),key=lambda q:q['frame'])
def camera_recipe(name,shot,config,index):
 start=shot['frame'];end=config['shots'][index+1]['frame'] if index+1<len(config['shots']) else config['frames'];last=end-1
 duo=len(shot['actors'])==2;close=shot['zoom']>=1.4
 landing=start+shot.get('transition',{}).get('duration',0)
 focus=[540,780 if close else 930]
 # Full duo shapes need hand margin; scale-down starts create a gentle push
 # without enlarging already-near-edge pointing/open palms.
 if 'pull' in name: first,final=(1.04,.91) if close else (1.0,.92)
 elif close:first,final=.95,1.14
 elif duo:first,final=.965,1.0
 else:first,final=.98,1.045
 dx=0;dy=-13;roll=0.0
 if 'slide' in name:dx=-26 if index%2 else 26;dy=-7
 if 'page' in name:focus=[540,890];dx=12 if index%2 else -12;dy=-9
 if name=='door_follow':first,final=1,.99;dx=-22;focus=[790,850]
 if 'exit' in name:dx=-36;roll=-.3;final=.88
 if 'caught' in name:roll=-.45;dy=12
 if 'runway' in name:roll=.25;dy=-9
 if 'curled' in name:focus=[540,850];dy=15
 if 'photo' in name:dy=-4;focus=[540,790]
 if duo:dx=max(-12,min(12,dx));roll*=.4
 if config['id']=='different-energy' and start==0:
  first,final=.95,1.025;dx=0;dy=-8
 if config['id']=='my-song' and start==0:
  first,final=1.05,.955;dx=5;dy=-12
 # A tight right-pointing hand is kept inside while its attention moves outward.
 actions=[cue_at(a,landing)['action'] for a in config['actors'] if a['id'] in shot['actors']]
 if duo and 'point' in actions:dx=min(dx,-9);first=min(first,.975);final=min(final,.993)
 if 'quiet' in name:dx=4;dy=-4;first=1;final=.955
 def state(at):
  u=(at-start)/max(1,last-start)
  return {'frame':at,'factor':round(first+(final-first)*u,5),'pan':[round(dx*u,3),round(dy*u,3)],'roll':round(roll*u,4),'ease':'linear'}
 keys={start:state(start),last:state(last)}
 impulses=[]
 # Selected primary pose arrivals also get an attack/recovery. Most cuts use
 # only the quiet base path; the big musical choice is allowed to feel bigger.
 if start in IMPULSE_SHOTS[config['id']] and last-landing>=10:
  candidates=attacks[Path(config['music']['file']).stem]['bands']['lowBody']['candidates']
  source=config['music']['sourceStart']+landing/30
  nearest=min(candidates,key=lambda q:abs(q['sourceTime']-source))
  if abs(nearest['sourceTime']-source)<=.055:
   for f in (max(start,landing-2),landing,landing+8):keys[f]=state(f)
   keys[landing]['factor']=round(keys[landing]['factor']+(0.019 if duo else 0.03),5)
   keys[landing]['pan'][1]-=6;keys[landing]['ease']='out';keys[landing+8]['ease']='out'
   impulses.append({'frame':landing,'sourceTime':source,'measuredAttackSourceTime':nearest['sourceTime'],'quantizationErrorMs':round((source-nearest['sourceTime'])*1000,3),'role':'Primary pose arrival','basis':'Measured low-band attack of the approved recording; not an assumed stem/downbeat.'})
 if start in IMPULSE_SHOTS[config['id']] and not impulses and last-landing>=22:
  candidates=attacks[Path(config['music']['file']).stem]['bands']['lowBody']['candidates']
  eligible=[q for q in candidates if q['strengthPercentile']>=.6 and landing+8<=round((q['sourceTime']-config['music']['sourceStart'])*30)<=last-9]
  if eligible:
   chosen=min(eligible,key=lambda q:abs((q['sourceTime']-config['music']['sourceStart'])*30-(landing+end)/2))
   at=round((chosen['sourceTime']-config['music']['sourceStart'])*30)
   for f in (at-2,at,at+8):keys[f]=state(f)
   keys[at]['factor']=round(keys[at]['factor']+(0.016 if duo else 0.024),5)
   keys[at]['pan'][1]=round(keys[at]['pan'][1]-5,3)
   keys[at]['ease']='out';keys[at+8]['ease']='out'
   impulses.append({'frame':at,'sourceTime':config['music']['sourceStart']+at/30,'measuredAttackSourceTime':chosen['sourceTime'],'quantizationErrorMs':round((config['music']['sourceStart']+at/30-chosen['sourceTime'])*1000,3),'basis':'Measured low-band mixed-recording attack; musical role chosen editorially, not a separated drum stem.'})
 return {'focus':focus,'keys':[keys[k] for k in sorted(keys)]},impulses
def actor_motion(actor,config):
 keys={};previous={'head':0,'look':0,'eyes':1,'lean':0,'gesture':1}
 for i,q in enumerate(actor['cues']):
  at=q['frame'];end=actor['cues'][i+1]['frame'] if i+1<len(actor['cues']) else config['frames'];last=end-1
  if last-at<3:continue
  action=q['action'];body=q.get('bodyPose','neutral');sign=-1 if body in ['groove_left','recoil','folded'] else 1
  amp=2.6 if actor['author']=='nemi' else 1.8
  base=max(-6,min(6,float(q.get('head',0))*.55))
  contact=action in ['sketch','book_show','phone','phone_up']
  lean_amp=.45 if contact else (.75 if actor['author']=='nemi' else .5)
  goal={'head':round(base+sign*amp,3),'look':q.get('gaze',[0,0])[0],'eyes':1,'lean':round(sign*lean_amp,3),'gesture':1}
  initial={**previous,'gesture':1};initial['eyes']=1
  lead=min(last,at+3);follow=min(last,at+max(7,round((end-at)*.38)));read=min(last,at+max(9,round((end-at)*.75)))
  keys[at]={'frame':at,**initial};keys[lead]={'frame':lead,**initial,'look':goal['look']}
  keys[follow]={'frame':follow,**goal}
  # A second subtle head/shoulder choice continues through the held thought.
  # It resolves rather than looping; rigid grip drawings remain fully arrived.
  final={**goal,'head':round(base-sign*amp*.25,3),'lean':round(-sign*lean_amp*.35,3)}
  if q.get('view')=='back':final={**goal,'head':0,'lean':0}
  keys[last]={'frame':last,**final}
  if i%4==2 and last-follow>=10 and q['emotion'] not in ['cover','deadpan']:
   blink=min(last-4,read);keys[blink-2]={'frame':blink-2,**goal};keys[blink]={'frame':blink,**goal,'eyes':.05};keys[blink+3]={'frame':blink+3,**goal}
  previous=final
 return [keys[k] for k in sorted(keys)]
attacks=json.loads((OUT/'source-attack-candidates.json').read_text())['tracks']
records=[]
for cast in ('adb','nemi','duo'):
 for spec in (ROOT/'shorts'/cast).glob('*/short.json'):
  p=spec.parent;archive=p/'review/source-motion03';c=json.loads((archive/'short.json').read_text());mapping=json.loads((archive/'CUE_MAP.json').read_text())
  old_frames=c['frames'];c['frames']=ENDS[c['id']];c['music']['duration']=c['frames']/30
  c['shots']=[s for s in c['shots'] if s['frame']<c['frames']]
  c['events']=[e for e in c['events'] if e['at']<c['frames']]
  for e in c['events']:e['end']=min(e['end'],c['frames'])
  ids={e['id'] for e in c['events']};c['sfx']=[s for s in c['sfx'] if s['event'] in ids]
  for a in c['actors']:a['cues']=[q for q in a['cues'] if q['frame']<c['frames']]
  names=RECIPES[c['id']];assert len(names)==len(c['shots']),(c['id'],len(names),len(c['shots']))
  camera_records=[]
  for i,(shot,name) in enumerate(zip(c['shots'],names)):
   shot.pop('travel',None);shot['camera'],impulses=camera_recipe(name,shot,c,i)
   camera_records.append({'shotFrame':shot['frame'],'recipe':name,'thought':next(row['audienceFocus'] for row in mapping['cuts'] if row['frame']==shot['frame']),'camera':shot['camera'],'selectedAttackImpulses':impulses})
  for a in c['actors']:a['motion']=actor_motion(a,c)
  spec.write_text(json.dumps(c,indent=2)+'\n')
  mapping['revision']='r4';mapping['frames']=c['frames'];mapping['music']=c['music'];mapping['cuts']=[x for x in mapping['cuts'] if x['frame']<c['frames']];mapping['poseLandings']=[x for x in mapping['poseLandings'] if x['frame']<c['frames']]
  mapping['motion04']={'previousFrames':old_frames,'selectedFrames':c['frames'],'durationReason':'Keep the complete visual payoff and end before repeated closing poses or the next source texture cycle; sourceStart and recording/gain remain unchanged.','cameraThoughts':camera_records,'actorMotion':'Eyes lead by3frames; finite head/shoulder response continues inside the held thought, then resolves. No periodic/random wobble and no arm-entry cycling.','referenceEvidence':'shorts/review/motion04/ref01/MOTION.md and ref03/MOTION.md; frame evidence and tracking limits are separate from authored choices.','review':'Native motion extrema + all joins + decoded whole playback pending.'}
  mapping['sfxEvents']=c['sfx'];(p/'CUE_MAP.json').write_text(json.dumps(mapping,indent=2)+'\n')
  direction=(archive/'DIRECTION.md').read_text();direction+='\n## Motion04 direction\n\nThe user requested ongoing slight movement within each held pose, stronger purposeful camera development and musical coherence. Camera paths now continue across each thought, with selected attack/recovery accents; eye leads, small head turns and grounded shoulder settling support them. Finished ink contours and prop grips stay coherent. This is not a periodic idle loop.\n\n'+f'Duration: {old_frames/30:g}s → {c["frames"]/30:g}s. Keep the existing approved recording/start/gain, stop after the useful ending and remove repeat poses; full playback must confirm the cut.\n\n'+'\n'.join(f'- {row["shotFrame"]/30:.3f}s: {row["recipe"]}; {row["thought"]}' for row in camera_records)+'\n\nNative/encoded motion, picture, sound and whole-clip playback remain pending until their real observations are recorded.\n';(p/'DIRECTION.md').write_text(direction)
  records.append({'id':c['id'],'cast':cast,'revision':'r4','duration':c['frames']/30,'previousDuration':old_frames/30,'cameraShots':len(camera_records),'selectedAttackImpulses':sum(len(x['selectedAttackImpulses']) for x in camera_records)})
(OUT/'AUTHORING.json').write_text(json.dumps(records,indent=2)+'\n')
print(f'Authored {len(records)} motion04 sources; validate and inspect real Godot output next.')
