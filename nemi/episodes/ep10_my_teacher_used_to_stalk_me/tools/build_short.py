"""Explicit phrase edit under the user's hard 150s limit. Same voice, no rushing."""
import copy,json,math,re,sys,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];sys.path.insert(0,str(ROOT/'tools/storytime'))
from prepare_voice import prepare,digest
from audio_mix import calibrate_mix
from sfx_levels import choose_gain,pcm
from validate_scene import validate
EP=Path(__file__).resolve().parent.parent
source=json.loads((EP/'source_words_final.json').read_text());old=json.loads((EP/'scene_long_draft.json').read_text())
oldplan=json.loads((EP/'voice_plan_long_draft.json').read_text());old_sound=json.loads((EP/'sound_plan_long_draft.json').read_text())
# Source boundaries below are chosen sentence/pause cuts, not automatic silence removal.
selections=[(0,0,5.44),(1,3.90,4.99),(5,3.85,8.30),(7,0,3.18),(7,7.78,11.12),(9,0,1.10),(10,0,8.64),(13,0,7.40),(14,0,6.64),(15,0,1.9),(15,6.70,11.68),(16,0,10),(18,0,8.32),(19,0,11.04),(20,0,8.40),(21,0,3.90),(22,0,6.42),(23,0,8.24),(26,3.48,10),(24,0,5.55),(24,8.73,10.55),(27,0,11.20)]
clips=[];at=.25;ends=[];starts=[];original=[]
for j,(i,start,end) in enumerate(selections):
    r=source[i];words=[];previous=start
    for w in r['words']:
        if w['start']<start or w['end']>end:continue
        st=max(previous,w['start'])
        if st<w['end']:words.append(dict(word=w['word'].strip(),start=st,end=w['end']));previous=w['end']
    assert words,(i,start,end)
    starts.append(round(at,6));ends.append(round(at+end-start,6));original.append(i)
    clips.append(dict(author='nemi',file=r['file'],sha256=r['sha256'],at=round(at,6),start=start,end=end,tempo=1.0,words=words))
    pause=.15
    if i in [0,10,14,16,19,21,23,26]:pause=.40
    if i==27:pause=1.1
    at+=end-start+pause
duration=math.ceil(at)
assert duration<=150,('Hard duration limit exceeded',duration)
plan=dict(version=1,duration=duration,clips=clips)
scratch=ROOT/'renders/nemi_ep10/audio_r4'
if scratch.exists():
    timeline=json.loads((scratch/'timeline.json').read_text());assert timeline['audio_sha256']==digest(scratch/'narration.wav')
    assert timeline['duration']==duration and len(timeline['clips'])==len(clips)
    for saved,wanted in zip(timeline['clips'],clips):
        assert all(saved[k]==wanted[k] for k in ['author','file','sha256','at','start','end','tempo']), 'Changed edit needs a new audio revision folder'
else:timeline=prepare(plan,scratch)
shutil.copyfile(scratch/'narration.wav',EP/'voice/narration_r2.wav')
(EP/'voice_plan.json').write_text(json.dumps(plan,indent=2)+'\n')
(EP/'timing_reference.json').write_text(json.dumps(timeline,indent=2)+'\n')
words=timeline['words'];groups=[];offset=0
for w in words:
    if w['word'].lower()=='stationary':w['word']='stationery'  # Homophone spelling; measured boundaries unchanged.
(EP/'timing_reference.json').write_text(json.dumps(timeline,indent=2)+'\n')
for c in clips:groups.append(words[offset:offset+len(c['words'])]);offset+=len(c['words'])
shots=[];props=[];drawings=[];vfx=[];sfx=[];events=[];performances=[];camera=[];sound_detail=[];beats=[]
def event(name,t,intent):events.append(dict(id=name,at=round(t,6),intent=intent));return name
for j,((i,trim_start,trim_end),c) in enumerate(zip(selections,clips)):
    start=0 if j==0 else starts[j]-.08;end=starts[j+1]-.08 if j+1<len(clips) else duration;sid=f'short_{j:02d}'
    src=next(s for s in old['shots'] if s['id']==f'beat_{i:02d}')
    shot=copy.deepcopy(src);shot.update(id=sid,start=round(start,6),end=round(end,6));shots.append(shot)
    focus=old['direction']['beats'][i]['focus']
    ev=event('camera_'+sid,start,focus)
    camera.append(dict(at=start,spoken_cue=groups[j][0]['word'],spoken_at=groups[j][0]['start'],focus=focus,camera=shot.get('camera',{}),event=ev,finish='Hold until the next thought; editorial cuts replace repetition.'))
    cue=copy.deepcopy(next(p for p in old['actors'][0]['performances'] if abs(p['at']-src['start'])<.001));cue.update(at=round(start,6));cue.pop('event',None);cue.pop('event_offset',None);cue['blinks']=[round(start+1.1,6)] if end-start>1.7 else []
    performances.append(cue)
    for group,target in [('props',props),('drawings',drawings)]:
        for item in old[group]:
            if src['id'] not in item.get('shots',[]):continue
            if item.get('mode')=='live':continue
            item=copy.deepcopy(item);item.update(at=round(start,6),end=round(end,6),shots=[sid]);item.pop('event',None);item.pop('event_offset',None)
            target.append(item)
    # Hide the secret phrase until those words are spoken, not during the setup.
    if i==15 and trim_start==0:
        drawings[:]=[d for d in drawings if sid not in d.get('shots',[])]
        props[:]=[p for p in props if sid not in p.get('shots',[])]
        shot['background']='home_curtain';shot['camera']={'center':[520,434],'zoom':2.1}
    elif i==15:
        drawings[:]=[d for d in drawings if sid not in d.get('shots',[])]
        drawings.append(dict(author='nemi',kind='text',at=start,end=end,mode='hold',position=[830,365],size=78,text='secret',shots=[sid]))
        for p in props:
            if sid in p.get('shots',[]) and p['kind']=='evidence_phone':p['position']=[1500,516]
    # Exact recorded word gives selected reaction and underline.
    for w in groups[j]:
        text=re.sub(r'\W','',w['word'].lower())
        if (i,text) in [(7,'realized'),(19,'suddenly'),(23,'secret')]:
            performances.append(dict(at=w['start'],recipe='quiet_recoil' if i!=23 else 'lean_in',duration=.30,gaze=[0,0]))
        if i==15 and trim_start>0 and text=='mention':
            ev2=event('secret_underline',w['start'],'The secret request becomes evidence')
            drawings.append(dict(author='nemi',kind='underline',at=w['start'],end=end,duration=.85,mode='live',position=[1000,470],scale=[2.2,2.2],shots=[sid],event=ev2))
    original_at=oldplan['clips'][i]['at']
    for q in old_sound['cues']:
        local=q['at']-original_at
        if q['beat']!=i or not trim_start<=local<trim_end:continue
        t=round(c['at']+local-trim_start,6)
        evs=event('sound_'+sid+'_'+q['id'],t,q['reason'])
        sfx.append(dict(file='res://common/audio/sfx/'+Path(next(a['file'] for a in old['sfx'] if abs(a['at']-q['at'])<.0001)).name,at=t,duration=q['duration'],gain_db=q['gain_db'],event=evs))
        # Keep exact original nested library path.
        sfx[-1]['file']=next(a['file'] for a in old['sfx'] if abs(a['at']-q['at'])<.0001)
        q=copy.deepcopy(q);q.update(beat=j,at=t);sound_detail.append(q)
    beats.append(dict(start=round(start,6),end=round(end,6),thought=focus,focus=focus,visual=shot['background']+'; '+('portrait' if shot.get('camera',{}).get('zoom',1)>2 else 'held location'),intent='Advance the account through '+focus.lower()))
# Original hook second cut stays word-linked after the new edit.
t=next(w['start'] for w in groups[0] if "hadn't" in w['word'].lower())
first=shots[0];second=copy.deepcopy(first);second.update(id='hook_private_short',start=t,camera={'center':[520,420],'zoom':2.35});first['end']=t;shots.insert(1,second)
for a in props+drawings:
    if 'short_00' in a.get('shots',[]):a['shots'].append('hook_private_short')
performances.append(dict(at=t,recipe='quiet_recoil',duration=.25,face={'eye_openness':1.16,'pupil_scale':.72}))
performances.sort(key=lambda x:x['at'])
for k,p in enumerate(performances):
    next_at=performances[k+1]['at'] if k+1<len(performances) else duration
    p['blinks']=[b for b in p.get('blinks',[]) if p['at']<=b and b+.14<=next_at]
captions=[];mouths=[];offset=0
for j,g in enumerate(groups):
    group=[]
    for k,w in enumerate(g):
        group.append((offset+k,w));gap=k==len(g)-1 or g[k+1]['start']-w['end']>=.35
        if len(group)==5 or gap or w['word'].endswith(('.', '?', '!')):
            captions.append(dict(actor='nemi',words=[group[0][0],group[-1][0]],start=group[0][1]['start'],end=group[-1][1]['end'],text=' '.join(a[1]['word'] for a in group)));group=[]
        if w['end']-w['start']>.07:
            text=w['word'].lower();st=w['start']+.012;en=w['end']-.02
            if text.lstrip('.,?!').startswith(('m','b','p')) and en-st>.1:mouths.append(dict(start=st,end=st+.035,shape='closed'));st+=.035
            if st<en:mouths.append(dict(start=st,end=en,shape='o_u' if re.search(r'oo|you|who|home|know|road|told',text) else 'ae' if len(text)>3 else 'small_open'))
    offset+=len(g)
phone_index=original.index(13);last_phone=original.index(14)
phone_start=starts[phone_index]-.08;phone_end=starts[last_phone+1]-.08
hand_paths={'right':[dict(at=phone_start,position=[94,-2],angle=0),dict(at=phone_start+.6,position=[97,-67],angle=0,bend=[4,-8]),dict(at=starts[last_phone]-.08,position=[97,-67],angle=0),dict(at=starts[last_phone]+.65,position=[83,-5],angle=0)]}
spec={k:copy.deepcopy(old[k]) for k in ['version','title','fps','caption_size','direction']};spec['duration']=duration;spec['direction']['beats']=beats
spec.update(audio='res://'+str((EP/'voice/narration_r2.wav').relative_to(ROOT)),audio_metadata='res://'+str((EP/'timing_reference.json').relative_to(ROOT)),actors=[dict(id='nemi',author='nemi',performances=performances,mouths=mouths,hand_paths=hand_paths,hand_path_window=[phone_start,phone_end])],shots=shots,drawings=drawings,props=props,vfx=vfx,sfx=sfx,events=events,captions=captions,script=[dict(actor='nemi',start=starts[j],end=ends[j],text=' '.join(w['word'] for w in groups[j])) for j in range(len(clips))])
voice=pcm(EP/'voice/narration_r2.wav')
for q,a in zip(sound_detail,sfx):
    gain,levels=choose_gain(ROOT/a['file'][6:],voice,a['at'],a['duration'],q['prominence']);a['gain_db']=gain;q.update(gain_db=gain,**levels)
spec['mix']=calibrate_mix(spec,ROOT)
(EP/'scene.json').write_text(json.dumps(spec,indent=2)+'\n');validate(EP/'scene.json')
(EP/'camera_plan.json').write_text(json.dumps(camera,indent=2)+'\n')
(EP/'sound_plan.json').write_text(json.dumps(dict(beats=[dict(beat=j,start=b['start'],end=b['end'],thought=b['thought'],selection='; '.join(q['reason'] for q in sound_detail if q['beat']==j) or 'Intentional quiet, preserve voice and aftermath.') for j,b in enumerate(beats)],cues=sound_detail),indent=2)+'\n')
(EP/'SCRIPT_AND_BEATS.md').write_text('# My Teacher Used to Stalk Me — final short edit\n\nHard limit: 150 seconds. Actual authored duration: '+str(duration)+' seconds. Whole performance sources retained. Selected phrase/pause cuts and tempo 1.00, no pitch/EQ/identity changes. Original fictionalized school story, teacher unnamed.\n\n'+'\n\n'.join(f'## {j+1:02d} — {starts[j]:.2f}–{ends[j]:.2f}s\n\n{turn["text"]}\n\nFocus: {beats[j]["focus"]}.' for j,turn in enumerate(spec['script']))+'\n')
print('SHORT READY',duration,'seconds;',len(captions),'captions;',len(sfx),'sounds')
