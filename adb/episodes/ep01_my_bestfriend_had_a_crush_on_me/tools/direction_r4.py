"""R4: thought-specific pictures and stronger existing ADB expression/pose combinations."""
import copy,json
from pathlib import Path

def apply(spec, words, starts, ends, wt):
    shots=spec['shots'];S={s['id']:s for s in shots};actor=spec['actors'][0]
    def framing(id,background=None,center=None,zoom=None,x=None,visible=None):
        s=S[id]
        if background:s['background']=background
        if center:s['camera']['center']=list(center)
        if zoom:s['camera']['zoom']=zoom
        if visible is False:s['actors']={}
        if x is not None and 'adb' in s['actors']:s['actors']['adb']['position'][0]=x
    framing('hook',center=(760,435),zoom=1.65)
    framing('school','school_courtyard',(960,535),1)
    framing('school_detail','school_courtyard',(1100,655),1.8,visible=False)
    framing('doubt','thought',(950,520),1,x=420)
    framing('tell_me',center=(610,400),zoom=2.25)
    framing('confession',center=(925,505),zoom=1.12)
    framing('belief',center=(610,402),zoom=2.3)
    framing('replay','thought',(960,520),1,x=420)
    framing('lunch_clue','school_courtyard',(1210,530),1.18)
    framing('homework_clue','thought',(980,510),1,x=420)
    framing('charming','thought',(760,440),1.65)
    framing('answer',center=(920,505),zoom=1.12)
    framing('prank',center=(695,415),zoom=1.85)
    framing('group_project','thought',(960,520),1,x=420)
    framing('staring',center=(850,580),zoom=1.28)
    framing('speech',center=(850,480),zoom=1.32)
    framing('sanction','thought',(960,510),1.15)
    # A normal-sized page gets an object insert; do not enlarge it beside people.
    page_at=round(wt(13,'same')-.1,6)
    before=S['staring'];after=copy.deepcopy(before);after.update(id='staring_page',start=page_at,actors={},camera={'center':[1180,670],'zoom':2.4})
    before['end']=page_at;shots.insert(shots.index(before)+1,after);S['staring_page']=after
    spec['events'].append(dict(id='camera_staring_page',at=page_at,intent='The same unanswered page fills the frame.'))
    # Rebuild the illustrations so every thought has one clear audience focus.
    spec['drawings']=[];spec['props']=[];D=spec['drawings'];P=spec['props']
    def art(kind,ids,xy,scale=1,group=D,**kw):
        ids=[ids] if isinstance(ids,str) else ids
        a=dict(author='adb',kind=kind,at=min(S[i]['start'] for i in ids),end=max(S[i]['end'] for i in ids),position=list(xy),scale=[scale,scale],mode='hold',shots=ids,**kw);group.append(a);return a
    def text(label,ids,xy,size=44,**kw):
        kw.setdefault('layer',3)
        return art('text',ids,xy,text=label,size=size,**kw)
    def ev(id,t,intent):
        spec['events'].append(dict(id=id,at=round(t,6),intent=intent));return round(t,6)
    def live(kind,ids,xy,t,length,event,scale=1,**kw):
        a=art(kind,ids,xy,scale,**kw);a.update(at=round(t,6),duration=length,mode='live',event=event);return a
    classroom=[s['id'] for s in shots if s['background']=='school_classroom']
    art('school_clock',classroom,(686,205),.75,layer=-1)
    art('desk',classroom,(1180,735),1,group=P,layer=0)['scale']=[1.3,.9]
    art('homework_notes',classroom,(1190,697),.31,group=P,layer=0,tilt=-7)
    # The opening admits a hopeful interpretation; a small heart is the tension image.
    art('crush_heart','hook',(1070,365),1.05)
    text('ME?','hook',(990,520),42)
    # School friendship: actual outdoor school set and lunch on a grounded table.
    art('desk',['school','school_detail','lunch_clue'],(1180,735),1,group=P,layer=2)['scale']=[1.3,.9]
    art('lunch_box',['school','school_detail','lunch_clue'],(1220,710),.72,group=P,layer=3)
    note=art('homework_notes','school_detail',(955,697),.31,group=P,layer=3,tilt=-5)
    note['path']=[dict(at=S['school_detail']['start'],position=[580,697],tilt=-5),dict(at=S['school_detail']['start']+.5,position=[955,697],tilt=-5)]
    art('school_friend_smile',['school','lunch_clue'],(1370,894),1.65,layer=1)
    art('school_classmate',['rumor','likes'],(1280,894),1.65,layer=0)
    # Relationship-advice source cannot get a basic sum right. The page contradicts him.
    art('wrong_homework','doubt',(1220,510),1.35,group=P,tilt=5)
    text('TRUST THIS GUY?','doubt',(815,173),42)
    art('school_friend',['serious','confession','answer'],(1310,894),1.65,layer=0)
    art('school_friend_laugh','laugh',(1310,894),1.65,layer=0)
    art('school_friend_smile',['accomplice','staring','upset','speech','science'],(1300,894),1.65,layer=0)
    art('school_classmate_laugh','accomplice',(1560,894),1.58,layer=0)
    # A clock enters only while he tries to buy five seconds, not as a ticking bed.
    art('school_clock','tell_me',(920,410),.8)
    wait=ev('buy_time',wt(5,'five') if 'five' in ' '.join(w['word'].lower() for w in words if starts[5]<=w['start']<ends[5]) else S['tell_me']['start']+.7,'Nervous stall before committing to the answer.')
    # His three mundane memories become the absurd detective-board fantasy.
    art('clue_board',['replay','homework_clue'],(1200,490),1.42,group=P,layer=0)
    text('THE EVIDENCE',['replay','homework_clue'],(820,117),52)
    for label,xy in [('LUNCH',(887,250)),('TALKING',(1290,234)),('HOMEWORK',(1070,757))]:text(label,['replay','homework_clue'],xy,29)
    lunch=ev('lunch_evidence',S['lunch_clue']['start'],'An ordinary shared lunch acquires a romantic interpretation.')
    live('circle','lunch_clue',(1220,676),lunch,.65,'lunch_evidence',2.45)
    text('A SIGN?','lunch_clue',(980,238),54)
    art('crush_heart','lunch_clue',(1530,353),.55)
    clue=next(e['at'] for e in spec['events'] if e['id']=='clue')
    live('arrow','homework_clue',(883,586),clue,.58,'clue',1.25)
    live('question','homework_clue',(1550,350),clue,.7,'clue',1.3)
    notes=art('homework_notes','homework_clue',(0,0),.45,group=P,layer=0)
    notes.update(attach={'actor':'adb','hand':'right','grip':[-85,45],'angle':90},at=clue,end=S['charming']['start'])
    art('crush_heart','charming',(1110,350),1.15)
    text('CHARMING.','charming',(937,520),43)
    # Silent collapse remains a face beat; only one compact ink revision follows.
    prank=S['prank']['start'];revision=next(e['at'] for e in spec['events'] if e['id']=='revision')
    art('crush_heart','prank',(975,370),.6)
    live('scratch','prank',(975,370),revision,.38,'revision',.8)
    # The two pranksters' planning page makes the group-project line a visual payoff.
    art('prank_plan','group_project',(1220,485),1.43,group=P,tilt=-3)
    text('GROUP PROJECT','group_project',(804,148),46)
    for label,xy in [('1. RUMOR',(1000,360)),('2. CONFESS',(1000,480)),('3. LAUGH',(1000,604))]:text(label,'group_project',xy,36)
    # The unchanged Q1 page is an aftermath image, not another talking portrait.
    art('blank_classwork',['staring','staring_page'],(1180,670),.3,group=P,layer=2,tilt=-5)
    text('Q1.',['staring','staring_page'],(1145,631),15)
    # Editorial ink stamps the actual homework page; no implied physical pickup.
    art('homework_notes','sanction',(980,520),1.6,group=P,tilt=-5)
    sanction=ev('denied_stamp',S['sanction']['start']+.55,'Homework borrowing denied with an emphatic handwritten stamp.')
    live('ban_stamp','sanction',(970,504),sanction,.32,'denied_stamp',1.5,tilt=-8,layer=3)
    a=text('DENIED','sanction',(755,475),64,tilt=-8,accent=True);a.update(at=sanction+.15,duration=.45,mode='live',event='denied_stamp',event_offset=.15)
    text('SCIENCE','science',(1075,653),24)
    # Existing rig expressions and poses, driven as distinct emotional thought beats.
    def c(t,r,d=.45,**kw):return dict(at=round(t,6),recipe=r,duration=d,**kw)
    likes=next(e['at'] for e in spec['events'] if e['id']=='likes');belief=starts[6]
    actor['performances']=[
      c(0,'explaining',0),c(starts[1],'open_shrug',.5),c(starts[2],'listening',.4,gaze=[.7,0]),
      c(wt(2,'yeah'),'open_shrug',.4),c(likes,'skeptical',.3,face={'eye_openness_left':.6,'eye_openness_right':.9,'brow_left_height':-5,'brow_right_angle':10},event='likes'),
      c(wt(2,'apparently'),'deadpan',0,motion='snap',blinks=[wt(2,'everything')+.25]),
      c(starts[3],'clue_point',.48,gaze=[.7,.2]),c(wt(3,'why'),'dry_annoyance',.4),
      c(starts[4],'listening',.35,gaze=[.7,0]),c(wt(4,'did'),'nervous_wait',.4,motion='stepped',step_fps=12),
      c(starts[5],'nervous_wait',.42,gaze=[.6,.15]),c(wt(5,'actually'),'shy_confession',.45,gaze=[.6,.1],face={'blush_intensity':.5}),
      c(belief,'shy_confession',.5,gaze=[-.35,.4],face={'blush_intensity':.85,'eye_openness_left':.87,'eye_openness_right':.87},event='belief'),
      c(starts[7],'clue_point',.42),c(clue,'prop_present',.4,hands={'right':'holding_cup'},event='clue'),
      c(starts[8],'self_impressed',.5,hands={'right':'open_palm'},face={'blush_intensity':.58}),
      c(starts[9],'nervous_answer',.45,motion='stepped',step_fps=12),c(starts[10],'quiet_recoil',.2,face={'eye_openness_left':1.28,'eye_openness_right':1.28}),
      c(prank,'quiet_recoil',.22,event='reveal'),c(ends[11]+.1,'deadpan',0,motion='snap',face={'eye_openness_left':.43,'eye_openness_right':.43},blinks=[ends[11]+1.15]),
      c(starts[12],'skeptical',.4,gaze=[.9,0]),c(wt(12,'right'),'dry_annoyance',.35),
      c(starts[13],'hurt_composure',.48,gaze=[.25,.8]),c(starts[14],'nervous_wait',.4,face={'sweat_intensity':.55,'blush_intensity':.4}),
      c(wt(14,'wondering'),'dry_annoyance',.38),c(starts[15],'deadpan',0,motion='snap'),
      c(starts[16],'deadpan',0,motion='snap'),c(starts[17],'open_shrug',.5),c(ends[17],'pleased',.4,blinks=[ends[17]+.55])]
    # Extra finite marks punctuate change. Sustained sweat is already in the existing face rig.
    spec['vfx']=[
      dict(author='adb',kind='realization',actor='adb',offset=[100,-45],at=likes,end=likes+.7,event='likes',strength=.8),
      dict(author='adb',kind='focus',actor='adb',offset=[95,-30],at=starts[8],end=starts[8]+.75,strength=.8),
      dict(author='adb',kind='impact',actor='adb',offset=[100,-35],at=starts[10],end=starts[10]+.35,strength=.65),
      dict(author='adb',kind='tension',actor='adb',offset=[100,-45],at=prank,end=prank+.5,event='reveal',strength=.85),
      dict(author='adb',kind='sweat',actor='adb',offset=[90,-35],at=starts[13]+.4,end=starts[13]+1.3,strength=.75)]
    # Remove mouth intervals from new offscreen object inserts. Preserve actual word timing.
    mouths=[]
    for m in actor['mouths']:
      for s in shots:
        a=max(m['start'],s['start']);b=min(m['end'],s['end'])
        if 'adb' in s['actors'] and a<b:mouths.append(dict(start=a,end=b,shape=m['shape']))
    actor['mouths']=mouths
    intentions={
      'hook':('His composure conceals hopeful surprise.','ADB and small heart aside','Portrait plus held heart','Create tension immediately.'),
      'school':('Lunch and homework were just friendship.','School lunch table','Courtyard wide','Establish another real school place.'),
      'school_detail':('Sharing lunch is normal.','Lunch on table','Grounded object insert','Plant the ordinary evidence.'),
      'doubt':('This source cannot get maths right.','Incorrect homework page','Contradictory held page beside pointing ADB','Visualize why his advice is absurd.'),
      'tell_me':('Buy time while visibly nervous.','Sweaty ADB face','Clasped-hands nervous portrait','His face contradicts ignorance.'),
      'belief':('He privately hopes this is real.','Shy blush and lowered gaze','Hand-to-chest intimate portrait','Expose vulnerability.'),
      'replay':('Every mundane favor becomes evidence.','Ridiculous detective board','Held mental tableau and pointing pose','Make overthinking visible.'),
      'lunch_clue':('Was ordinary lunch romantic?','Circled shared lunch','Courtyard recollection with live circle','Give the memory a new meaning.'),
      'homework_clue':('A notebook becomes proof.','Held notebook and clue board','Grip lift plus live deduction arrow','Grow mistaken confidence.'),
      'charming':('Maybe I really am charming.','Smug ADB and oversized heart','Existing smug pose and finite focus','Peak the fantasy before reality.'),
      'answer':('Commit despite nerves.','Sweaty hesitant ADB','Wide awkward pose then hold','Let the breath and hands show stakes.'),
      'group_project':('Their plan was actual teamwork.','Three-step prank plan','Held plan beside narrowed eyes','Make the dry comparison a picture.'),
      'staring':('Hide hurt behind looking fine.','Downcast slouch over Q1','Grounded page and lowered shoulders','Stay with embarrassment.'),
      'speech':('Find a comeback.','Annoyed ADB facing friend','Existing annoyed stance','Recover dignity with a visible attitude change.'),
      'sanction':('Attempt a consequence.','DENIED over homework','Handwritten stamp reveal','Make the ban visible before its reversal.')}
    old_beats={s['id']:b for s,b in zip([s for s in shots if s['id']!='staring_page'],spec['direction']['beats'])}
    old_beats['staring_page']=dict(thought='The page remains unanswered.',focus='Unanswered Q1',visual='Actual page insert',intent='Hold on the same page instead of adding narration acting.')
    spec['direction']['beats']=[dict(old_beats[s['id']],start=s['start'],end=s['end']) for s in shots]
    for b,s in zip(spec['direction']['beats'],shots):
      if s['id'] in intentions:b.update(zip(['thought','focus','visual','intent'],intentions[s['id']]))
      e=next(e for e in spec['events'] if e['id']=='camera_'+s['id']);e['intent']=b['intent']
    return [('viral_whoosh',starts[7],.574688,'accent','camera_replay'),
            ('drawing_scratch_scribble_05',lunch,.325,'surface','lunch_evidence'),
            ('viral_click',sanction,.365688,'hero','denied_stamp'),
            ('paper_slide_desk_01',S['school_detail']['start'],.65,'surface','camera_school_detail')]
