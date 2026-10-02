"""Thought-linked camera direction using only the existing version-2 fields."""
import copy,json
from pathlib import Path
EP=Path(__file__).resolve().parents[1]
def apply(s):
    plan=[]
    def framing(sid,center,zoom,reason,word):
        q=next(q for q in s['shots'] if q['id']==sid)
        q['camera']={'center':center,'zoom':zoom}
        plan.append({'shot':sid,'at':q['start'],'spoken_cue':word,'focus':reason,'camera':copy.deepcopy(q['camera'])})
    def cut(sid,at,center,zoom,reason,word):
        i=next(i for i,q in enumerate(s['shots']) if q['id']==sid);q=s['shots'][i]
        assert q['start']<at<q['end']
        after=copy.deepcopy(q);after['id']=sid+'_reaction';after['start']=at;q['end']=at
        after['camera']={'center':center,'zoom':zoom};s['shots'].insert(i+1,after)
        plan.append({'shot':after['id'],'at':at,'spoken_cue':word,'focus':reason,'camera':copy.deepcopy(after['camera'])})
    framing('hook',[510,550],2.15,'Personal opening; face and explanatory hand','Wait')
    cut('hook',7.053571,[510,515],2.8,'Hold the contradiction close to the viewer','normal thing')
    framing('activities',[825,510],1.45,'Share Nemi and the steps note','amazing')
    framing('waymo_intro',[1080,650],1.18,'Show the transport and its passenger at believable size','Waymo')
    framing('ghost_driver',[960,570],1.12,'Empty front seat and wheel together','No driver')
    framing('waymo_panic',[1430,570],2.05,'Leave the empty seat behind and read the passenger reaction','clutching')
    cut('waymo_panic',51.53193,[1430,525],2.65,'A dry private confession, then hold','final day')
    framing('waymo_relief',[700,580],1.5,'Relief through face and surrounding car','safely')
    cut('deadpan_pause',82.746667,[960,540],1.0,'Return wide before the following car approaches','car right behind')
    framing('deadpan_pause',[325,560],2.6,'A quiet premature sense of safety','We stop in time')
    cut('rear_end_crash',89.43614,[325,550],2.35,'Contact has landed; read the personal consequence','back seat')
    framing('investigation',[1100,575],1.3,'Report and car inspection rather than a repeated full-body layout','statements')
    framing('crying_breakdown',[445,580],1.85,'Approach the vulnerable thought without a comic crash overlay','calm, rational adult')
    cut('crying_breakdown',107.700952,[445,535],2.6,'A held face and a short eye-relative tear accent','broke down')
    cut('payoff',118.02,[960,535],2.5,'After both car images, end on the narrator','Total disaster')
    q=next(q for q in s['shots'] if q['id']=='activities')
    q['camera']['path']=[{'at':q['start'],'center':[960,540],'zoom':1},{'at':20.20,'center':[960,540],'zoom':1},{'at':20.555652,'center':[825,510],'zoom':1.45}]
    q=next(q for q in s['shots'] if q['id']=='crying_breakdown')
    q['camera']['path']=[{'at':q['start'],'center':[445,580],'zoom':1.4},{'at':103.82,'center':[445,580],'zoom':1.85}]
    for cue in plan:cue['camera']=copy.deepcopy(next(q['camera'] for q in s['shots'] if q['id']==cue['shot']))
    # Labels belong to the selected composition, not arbitrary old canvas positions.
    for art in s['drawings']:
        if art.get('text')=='what could go wrong?':art['position']=[590,435];art['size']=18;art['end']=7.053571
        if art['kind']=='question' and art['at']==3.839286:art['position']=[655,470];art['scale']=[.8,.8]
        if art.get('text')=='20,000 steps':art['position']=[910,300]
        if art['kind']=='underline' and art['at']==21.442609:art['position']=[1080,355]
        if art.get('text')=='totally fine.':art['position']=[1480,365];art['size']=30
        if art['kind']=='scratch' and art['at']==51.53193:art['position']=[1615,395];art['scale']=[.9,.9]
    for cue in plan:
        cue['event']='camera_'+cue['shot']
        s['events'].append({'id':cue['event'],'at':cue['at'],'intent':cue['focus']})
    (EP/'camera_plan.json').write_text(json.dumps({'version':1,'clock':'Original approved scene seconds; no voice edits','notes':'Camera points use supported center/zoom/path only. Cuts are new shots. Actor scale is unchanged. Bridge retains its authored pullback.','cues':plan},indent=2)+'\n')
    return s
