"""Full rich 1080p review revision. Exact retained 137s narration, no 4K approval."""
import copy,json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];sys.path.insert(0,str(ROOT/'tools/storytime'))
from validate_scene import validate
from audio_mix import calibrate_mix
from sfx_assets import validate_asset
from sfx_levels import choose_gain,pcm
from prepare_voice import digest
EP=Path(__file__).resolve().parent.parent
old=json.loads((EP/'scene_r3_rejected.json').read_text());spec=copy.deepcopy(old)
words=json.loads((EP/'timing_reference.json').read_text())['words'];beats=old['direction']['beats']
def W(j,word,n=0):
    b=beats[j];hits=[w['start'] for w in words if b['start']<=w['start']<b['end'] and re.sub(r'\W','',w['word'].lower())==re.sub(r'\W','',word.lower())]
    return hits[n]
events=[]
def E(name,t,intent):
    found=next((e for e in events if e['id']==name),None)
    if found:assert abs(found['at']-t)<1e-6
    else:events.append(dict(id=name,at=round(t,6),intent=intent))
    return name
bg=['bedroom_evening_r4','school_day_r4','school_day_r4','school_street_r4','school_street_r4','school_courtyard_r4','school_street_r4','bedroom_evening_r4','bedroom_evening_r4','bedroom_evening_r4','bedroom_evening_r4','school_corridor_r4','bedroom_evening_r4','lane_night_r4','bedroom_evening_r4','bedroom_evening_r4','school_office_r4','school_office_r4','school_office_r4','school_courtyard_r4','school_courtyard_r4','bedroom_evening_r4']
# Each pair is a shot's subject, not a fixed narrator template. Camera paths settle.
framing=[([850,490],1.35),([960,540],1),([940,490],1.15),([970,485],1.12),([1080,460],1.2),([650,465],1.35),([960,540],1),([790,480],1.4),([935,490],1.15),([520,440],1.9),([960,470],1.3),([930,520],1.05),([930,500],1.1),([960,540],1),([840,505],1.15),([1000,485],1.05),([960,520],1.05),([960,505],1.05),([980,490],1.15),([960,540],1),([900,500],1.2),([865,480],1.35)]
cuts={0:[W(0,"hadn't")],6:[W(6,'Across'),W(6,'teacher')],7:[W(7,'recognize'),W(7,'Did')],8:[W(8,'hate'),W(8,'scared')],11:[W(11,'notebook'),W(11,'Ignoring')],12:[W(12,'lamp'),W(12,'message')],13:[W(13,'From'),W(13,'just'),W(13,'suddenly')],14:[W(14,'tried'),W(14,'handed')],15:[W(15,'shut')],16:[W(16,'screenshots')],17:[W(17,'Mom'),W(17,'secret'),W(17,'answer')],18:[W(18,'only')],21:[W(21,'bothers'),W(21,'watching'),W(21,'world')]}
custom={
(0,1):([535,417],2.15),(6,1):([1120,520],1.2),(6,2):([1340,497],2.0),
(7,1):([545,433],1.95),(7,2):([980,470],1.32),
(8,1):([535,425],2.05),(8,2):([925,470],1.22),
(11,1):([1235,643],1.7),(11,2):([535,438],2.05),
(12,1):([1200,583],1.55),(12,2):([850,457],1.42),
(13,1):([1020,440],1.2),(13,2):([1090,400],1.5),(13,3):([532,435],2.05),
(14,1):([535,425],2.0),(14,2):([1120,484],1.68),
(15,1):([1240,396],1.55),(16,1):([1170,619],1.4),
(17,1):([1120,470],1.4),(17,2):([1100,425],1.65),(17,3):([1470,444],1.55),
(18,1):([1150,447],1.4),(21,1):([535,426],2.0),(21,2):([1235,425],1.4),(21,3):([535,423],2.05)}
shots=[];bybeat={};camera_plan=[]
for j,b in enumerate(beats):
    bounds=[b['start']]+cuts.get(j,[])+[b['end']];ids=[]
    for k,(start,end) in enumerate(zip(bounds,bounds[1:])):
        sid=f'r4_{j:02d}_{k}';ids.append(sid);center,zoom=custom.get((j,k),framing[j]);camera=dict(center=center,zoom=zoom)
        # Authored pans/pushes are brief and motivated, followed by clear holds.
        if (j,k) in [(0,0),(2,0),(3,0),(6,1),(7,0),(8,2),(10,0),(12,2),(13,1),(14,0),(16,0),(18,1),(19,0),(21,0)]:
            delay=min(.32,(end-start)*.12);move=min(.85,(end-start)*.42)
            dest=[center[0]+(85 if j in [3,6,13,16] else -18),center[1]-9]
            camera['path']=[dict(at=start,center=center,zoom=zoom),dict(at=round(start+delay,6),center=center,zoom=zoom),dict(at=round(start+delay+move,6),center=dest,zoom=min(2.7,zoom+.12))]
        shot=dict(id=sid,start=start,end=end,background=bg[j],actors={'nemi':dict(position=[520,570],scale=1.75)},camera=camera)
        shots.append(shot);ev=E('camera_'+sid,start,'Direct attention to '+b['focus'])
        nearest=next((w for w in words if w['start']>=start and w['start']<end),None)
        camera_plan.append(dict(shot=sid,at=start,word=nearest['word'] if nearest else 'pause',focus=b['focus'],camera=camera,event=ev,finish='Settle after the authored move; next cut changes the thought.'))
    bybeat[j]=ids
drawings=[];props=[];vfx=[]
def art(group,j,kind,pos,scale=1,at=None,end=None,live=None,event=None,**extra):
    b=beats[j];item=dict(author='nemi',kind=kind,at=b['start'] if at is None else at,end=b['end'] if end is None else end,position=pos,scale=[scale,scale],shots=bybeat[j],mode='hold')
    if live is not None:item.update(mode='live',duration=live)
    if event:item['event']=event
    item.update(extra);group.append(item);return item
def text(j,label,pos,size=58,at=None,end=None,live=None,accent=False):return art(drawings,j,'text',pos,at=at,end=end,live=live,text=label,size=size,accent=accent)
def live(j,kind,word,pos,scale,duration,name=None):
    at=W(j,word);name=name or f'ink_{j}_{kind}';E(name,at,'Build the evidence: '+kind)
    return art(drawings,j,kind,pos,scale,at=at,live=duration,event=name)
# Retain physically grounded cast/furniture; discard the unsupported late grip.
for j,b in enumerate(beats):
    source_id=f'short_{j:02d}'
    for item in old['props']:
        if source_id not in item.get('shots',[]):continue
        if item['kind'] in ['window_lit','curtain_closed','evidence_phone']:continue
        if j in [3,4] and item['kind'] in ['teacher_distant','car']:continue
        if j==14 and item['kind']=='phone':continue
        if item['kind']=='nemi_mother' and j in [14,15]:continue
        item=copy.deepcopy(item);item.update(at=b['start'],end=b['end'],shots=bybeat[j]);props.append(item)
    if j in [0,7,8,9,10,12,14,15,21]:
        art(props,j,'desk',[1245,716],1,layer=0)
        art(props,j,'bedroom_lamp',[1160,650],.65,layer=0)  # Bottom rests at the desk surface.
    if j in [1,19]:art(props,j,'school_satchel',[770,819],.62,layer=0)
# Opening: the window/time relationship is visibly authored before the private reveal.
live(0,'clock_light','time',[1260,412],1.06,1.4)
art(drawings,0,'window_sightline',[1185,590],.62,at=W(0,'bedroom'),live=1.25)
text(1,'15',[1170,319],100,live=.52)
live(2,'school_questions','ask',[1240,465],.8,2.2)
live(2,'question','who',[1100,656],.9,.7)
art(drawings,2,'clock_light',[1520,543],.48,at=W(2,'mom'),live=.75)
for j in [3,4]:art(drawings,j,'route_map',[1290,451],.88)
live(3,'route_main','asked',[1290,451],.88,1.85)
drawings[-1]['end']=beats[4]['end'];drawings[-1]['shots']+=bybeat[4]
live(4,'route_detour','realized',[1290,451],.88,1.55)
text(4,'never told him',[1040,665],49,at=W(4,'realized'),live=1.05,accent=True)
art(drawings,6,'arrow',[1140,711],1.2,at=W(6,'Across'),live=.7)
live(6,'circle','teacher',[1340,400],.85,.58)
live(7,'unknown_contact','message',[1420,398],.78,1.35)
text(7,'home safely?',[1230,657],55,at=W(7,'Did'),live=1.0)
text(8,'yes sir',[1140,337],58,at=W(8,'yes'),live=.7)
text(8,'thank you',[1100,446],60,at=W(8,'Thank'),live=.85)
live(8,'circle','remembering',[1260,422],2.0,.72)
text(8,'scared',[1140,590],69,at=W(8,'scared'),live=.8,accent=True)
back=art(drawings,8,'school_notebook',[1310,489],at=W(8,'yes'),layer=0);back['scale']=[2.6,3.0]
for d in drawings:
    if d['kind']=='text' and set(d['shots'])&set(bybeat[8]):d['size']=52 if d['text']!='scared' else 62
live(10,'sealed_message','don\'t',[1390,507],.78,1.65)
text(10,'secret',[1150,303],83,at=W(10,'mention'),live=1.1,accent=True)
live(10,'underline','school',[1280,404],1.6,.6)
back=art(drawings,10,'school_notebook',[1350,363],at=W(10,'mention'),layer=0);back['scale']=[2.15,1.6]
live(11,'notebook','notebook',[1480,352],.53,1.1)
text(11,'not nice?',[1120,411],56,at=W(11,'Ignoring'),live=1.0,accent=True)
live(12,'spark','on',[1155,590],1.5,.7)
live(12,'clock_light','message',[1460,447],.6,.9)
text(12,'long night?',[1100,340],60,at=W(12,'Long'),live=.8,accent=True)
back=art(drawings,12,'school_notebook',[1360,427],at=W(12,'Long'),layer=0);back['scale']=[2.25,2.1]
live(13,'window_sightline','From',[970,410],.86,2.0)
live(13,'circle','light',[1115,285],2.4,.85)
text(13,'outside',[905,658],60,at=W(13,'curtain'),live=.8,accent=True)
for d in drawings:
    if d['kind']=='text' and set(d['shots'])&set(bybeat[13]):d['position']=[885,699];d['size']=54
# The narrator never has a second unowned phone grip. The receiver is a held illustration.
art(props,14,'nemi_mother',[1120,894],1,layer=0,end=W(14,'handed'))
art(props,14,'mother_phone',[1120,894],1,layer=0,at=W(14,'handed'))
art(props,15,'mother_phone',[1120,894],1,layer=0)
live(14,'screenshot_stack','phone',[1420,432],.66,1.6)
art(props,15,'curtain_closed',[1245,404],1.52,at=W(15,'shut'),layer=0)
live(16,'evidence_folder','school',[1250,640],.54,1.65)
live(16,'screenshot_stack','screenshots',[1490,408],.63,1.4)
text(17,'concern?',[1215,198],60,at=W(17,'concern'),live=.85)
art(props,17,'teacher_ordinary',[1510,894],1,layer=0)
live(17,'scratch','secret',[1340,236],1.9,.7)
live(18,'clock_light','only',[1480,439],.6,1.5)
text(18,'checking?',[1120,336],61,at=W(18,'checking'),live=.9,accent=True)
for d in drawings:
    if d['kind']=='text' and set(d['shots'])&set(bybeat[18]):d['position']=[1200,200];d['size']=53
live(19,'arrow','moved',[1220,473],2.0,.8)
art(drawings,20,'unknown_contact',[1290,457],.7)
live(20,'scratch','stopped',[1290,452],1.8,.8)
art(drawings,21,'window_lit',[1260,408],1.14)
back=art(drawings,21,'school_notebook',[1250,505],layer=0);back['scale']=[2.65,3.2]
live(21,'window_sightline','watching',[1180,569],.74,1.45)
live(21,'circle','window',[1260,412],2.45,.95)
# Thought-driven performances. Existing canonical pose/expression vocabulary only.
base_recipes=['school_confide','school_explain','school_question','school_point','school_gasp','school_confide','school_question','school_present','school_shame','school_question','school_brace','school_resolve','school_explain','school_question','school_confide','school_relief','school_present','school_resolve','school_point','school_relief','school_question','school_confide']
acting=[]
def act(at,recipe,duration=.44,gaze=None,hands=None,motion='smooth',face=None):
    cue=dict(at=round(at,6),recipe=recipe,duration=duration,motion=motion)
    if gaze:cue['gaze']=gaze
    if hands:cue['hands']=hands
    if face:cue['face']=face
    if motion=='stepped':cue['step_fps']=12
    if motion=='snap':cue['duration']=0
    acting.append(cue);return cue
for j,b in enumerate(beats):
    cue=act(b['start'],base_recipes[j])
    if j in [7,8]:cue['hands']={'right':'hold_prop'}
    if j in [3,4,6,13]:cue['gaze']=[.6,-.05]
    if j in [8,14]:cue['gaze']=[-.25,.25]
secondary=[(0,"knew",'school_question'),(0,"hadn't",'school_recoil'),(0,'anyone','school_confide'),(2,'home','school_point'),(2,'mom','school_question'),(3,'road','school_point'),(4,'realized','school_recoil'),(4,'route','school_question'),(6,'shop','school_explain'),(6,'Across','school_question'),(6,'teacher','school_gasp'),(7,'recognize','school_question'),(7,'Did','school_present'),(7,'him','school_recoil'),(8,'hate','school_shame'),(8,'scared','school_brace'),(10,'mention','school_point'),(10,'People','school_question'),(11,'notebook','school_gasp'),(11,'Ignoring','school_recoil'),(12,'lamp','school_point'),(12,'message','school_recoil'),(13,'road','school_explain'),(13,'see','school_gasp'),(13,'suddenly','school_recoil'),(13,'different','school_confide'),(14,'tried','school_shame'),(14,'words','school_brace'),(14,'handed','school_confide'),(15,'twice','school_question'),(15,'shut','school_relief'),(16,'screenshots','school_point'),(16,'friend','school_explain'),(17,'concern','school_question'),(17,'Mom','school_confide'),(17,'secret','school_resolve'),(17,'answer','school_last'),(18,'only','school_question'),(18,'sleep','school_resolve'),(19,'class','school_explain'),(21,'reasonable','school_question'),(21,'bothers','school_confide'),(21,'watching','school_recoil'),(21,'window','school_resolve'),(21,'world','school_last')]
for j,word,recipe in secondary:
    t=W(j,word)
    c=act(t,recipe,.34 if recipe=='school_recoil' else .44,motion='stepped' if recipe=='school_recoil' else 'smooth')
    if j in [7,8]:c['hands']={'right':'hold_prop'}
    if recipe=='school_recoil':c['face']={'pupil_scale':.73,'eye_openness':1.22}
acting.sort(key=lambda c:c['at'])
for i,c in enumerate(acting):
    end=acting[i+1]['at'] if i+1<len(acting) else 137
    c['duration']=min(c['duration'],max(0,end-c['at']-.01))
    c['blinks']=[round(c['at']+.85,6)] if end-c['at']>1.35 and c['recipe']!='school_recoil' else []
acting[-1].update(motion='snap',duration=0,blinks=[])
spec['actors'][0]['performances']=acting
# Keep the tested initial bounded phone path; the director now restores wrists after it.
spec['actors'][0]['hand_paths']=copy.deepcopy(old['actors'][0]['hand_paths'])
spec['actors'][0]['hand_path_window']=copy.deepcopy(old['actors'][0]['hand_path_window'])
for j,word,kind,strength in [(0,"hadn't",'tension',.7),(4,'realized','realization',.75),(6,'teacher','tension',.8),(8,'scared','sweat',.5),(11,'Ignoring','tension',.75),(12,'message','realization',.65),(13,'suddenly','tension',.85),(14,'words','tears',.4),(15,'shut','relief',.55),(17,'secret','focus',.5)]:
    t=W(j,word);name=E(f'react_{j}_{kind}',t,'Punctuate the emotional thought, then disappear')
    vfx.append(dict(kind=kind,author='nemi',at=t,end=min(t+1.0,beats[j]['end']),actor='nemi',offset=[85,-55],strength=strength,event=name))
# More audible narrative Foley, sketch sounds, message and recognition accents.
catalog={a['id']:a for a in json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']}
voice=pcm(ROOT/spec['audio'][6:]);sfx=[];sounds=[]
def sound(j,word,id,length,prominence,why,event=None):
    # Select stronger existing recordings when a quiet source cannot achieve
    # its intended prominence within the supported -6 dB maximum gain.
    if id in ['drawing_pencil_letters_01','drawing_pencil_write_short_01']:id='drawing_pencil_sketch_01'
    if id=='paper_page_flip_01':id='paper_book_paging_single_01'
    if id=='viral_key_press':id='viral_click';length=.36
    t=W(j,word);asset=catalog[id];path=validate_asset(asset,ROOT)
    ev=event or E(f'sfx_{j}_{word}_{len(sfx)}',t,why)
    gain,level=choose_gain(path,voice,t,length,prominence)
    sfx.append(dict(file='res://'+asset['relative_path'],at=t,duration=length,gain_db=gain,event=ev))
    sounds.append(dict(beat=j,at=t,word=word,id=id,duration=length,gain_db=gain,reason=why,source=asset['source'],license=asset['license'],sha256=digest(path),**level))
for item in [
(0,'time','drawing_pencil_sketch_01',1.3,'accent','Clock sketch makes private observation visible'),
(0,"hadn't",'suspense_glass_hit_cinematic_01',.7,'hero','Private detail recognition'),
(1,'15','paper_page_flip_01',.45,'accent','Cut into the school memory'),
(2,'ask','drawing_pencil_letters_01',1.5,'accent','Intrusive question-sheet sketch'),
(2,'mom','sting_question_chime_01',.6,'accent','The personal family question'),
(3,'asked','drawing_pencil_write_short_01',1.6,'accent','Trace the public route'),
(4,'realized','drawing_pencil_sketch_01',1.2,'accent','The unspoken detour emerges'),
(5,'friend','movement_cloth_rustle_01',.5,'surface','Nemi gathers herself to confide'),
(6,'Across','viral_whoosh',.5,'accent','Pan across the street toward the teacher'),
(6,'teacher','suspense_glass_hit_cinematic_01',.85,'hero','Recognize him at the parked car'),
(7,'message','viral_notification',1.2,'accent','The first private message arrives'),
(7,'Did','drawing_pencil_letters_01',.9,'accent','Reveal the exact message fragment'),
(8,'typed','viral_key_press',.4,'surface','The polite reply'),
(8,'Thank','drawing_pencil_write_short_01',.7,'accent','The unwanted thank-you is written'),
(8,'scared','movement_cloth_rustle_01',.5,'surface','Hands gather nervously'),
(9,'stranger','viral_ping',.8,'accent','Escalating message'),
(10,'don\'t','drawing_pencil_sketch_01',1.4,'accent','Envelope closes around the secret'),
(10,'mention','drawing_pencil_letters_01',.85,'accent','Write the secret evidence'),
(11,'notebook','paper_book_close_01',.5,'hero','Notebook as threat, not schoolwork'),
(11,'Ignoring','suspense_glass_hit_cinematic_01',.7,'hero','The soft public threat hits Nemi'),
(12,'on','ui_click_tactile_01',.3,'accent','The lamp turns on'),
(12,'message','viral_notification',1.2,'accent','The lit-window message arrives'),
(13,'From','drawing_pencil_sketch_01',1.5,'accent','Draw the outside sightline'),
(13,'light','drawing_scratch_scribble_01',.7,'accent','Circle the light, not the person'),
(13,'suddenly','suspense_glass_hit_cinematic_01',.75,'hero','The pattern becomes clear'),
(14,'phone','paper_slide_desk_01',.55,'surface','Move attention onto the retained evidence'),
(14,'handed','movement_cloth_rustle_01',.6,'surface','Cut to mother receiving the phone'),
(15,'curtain','movement_cloth_rustle_01',.75,'hero','The curtain closes'),
(16,'school','paper_page_flip_02',.5,'accent','Bring the evidence to school'),
(16,'screenshots','viral_click',.36,'accent','Recorded screenshots'),
(16,'friend','paper_page_flip_01',.4,'surface','A corroborating account joins the folder'),
(17,'secret','drawing_scratch_scribble_01',.6,'accent','Cross out the concern excuse'),
(18,'only','drawing_pencil_write_short_01',1.0,'accent','Sleep clock as the flimsy excuse'),
(19,'moved','viral_whoosh',.4,'accent','Return to school aftermath'),
(20,'stopped','ui_click_tactile_01',.3,'surface','Messages cease'),
(21,'watching','drawing_pencil_sketch_01',1.2,'accent','Final window callback completes')]:sound(*item)
# The last spoken phrase and final hold deliberately remain silent apart from narration.
spec.update(shots=shots,props=props,drawings=drawings,vfx=vfx,sfx=sfx,events=events)
for j,b in enumerate(spec['direction']['beats']):
    b['visual']=f'{bg[j]} with thought-specific held/live art, gaze/body change and directed camera'
    b['intent']='Build the account with a visible counterpoint: '+b['focus']
spec['mix']=calibrate_mix(spec,ROOT)
path=EP/'scene_r4_1080p.json';path.write_text(json.dumps(spec,indent=2)+'\n');validate(path)
(EP/'camera_plan_r4.json').write_text(json.dumps(camera_plan,indent=2)+'\n')
(EP/'sound_plan_r4.json').write_text(json.dumps(dict(cues=sounds,final_hold='Intentional silence after the last phrase; no background music.'),indent=2)+'\n')
stats=dict(duration=137,shots=len(shots),moving_cameras=sum('path' in s.get('camera',{}) for s in shots),acting_cues=len(acting),pose_recipes=len(set(c['recipe'] for c in acting)),expression_states=sorted(set(json.loads((ROOT/'common/storytime/performances/recipes.json').read_text())['nemi'][c['recipe']]['expression'] for c in acting)),drawings=len(drawings),live_drawings=sum(d['mode']=='live' for d in drawings),unique_art_kinds=sorted(set(d['kind'] for d in props+drawings)),sfx=len(sfx),vfx=len(vfx),voice_sha256=digest(ROOT/spec['audio'][6:]),approval='Await full 1080p user satisfaction; no 4K receipt created.')
(EP/'review/R4_DESIGN.json').write_text(json.dumps(stats,indent=2)+'\n')
print(json.dumps(stats,indent=2))
