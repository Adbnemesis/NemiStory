#!/usr/bin/env python3
"""EP09 visual revision from preserved Antigravity source; no voice generation."""
import copy
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT/'tools/storytime'))
from preflight import missing
from validate_scene import validate
from audio_mix import calibrate_mix
from sfx_assets import validate_asset
EP=ROOT/'nemi/episodes/ep09_sf_accident'

def build():
    problems=missing(EP)
    if problems:raise ValueError('\n'.join(problems))
    s=json.loads((EP/'scene_antigravity_original.json').read_text())
    timeline=json.loads((ROOT/s['audio_metadata'][6:]).read_text())
    # Correct two clear ASR spellings against the saved spoken source. Times do not change.
    for w in timeline['words']:
        if 36.9<w['start']<37.2 and w['word'].lower()=='wrote':w['word']='rode'
        if 37.4<w['start']<37.7 and w['word']=='WAMO':w['word']='Waymo'
    (EP/'timing_revision.json').write_text(json.dumps(timeline,indent=2)+'\n')
    s['audio_metadata']='res://nemi/episodes/ep09_sf_accident/timing_revision.json'
    for card in s['captions']:
        a,b=card['words']
        card['text']=' '.join(w['word'] for w in timeline['words'][a:b+1]).replace('20 ,000','20,000')
    s['caption_size']=52
    bounds=[(q['id'],q['start'],q['end']) for q in s['shots']]
    settings={
      'hook':('studio_nemi',510,1.2),
      'san_francisco':('sf_street',675,1.15),
      'activities':('sf_street',675,1.15),
      'apple_event':('tech_auditorium',455,1.2),
      'golden_gate':('sf_bridge',365,1.05),
      'waymo_intro':('sf_street',480,1.15),
      'ghost_driver':('car_cabin',1430,1.2),
      'waymo_panic':('car_cabin',1430,1.2),
      'waymo_relief':('sf_street',480,1.15),
      'heading_airport':('sf_street',480,1.15),
      'five_minutes':('airport_road',325,1.12),
      'sudden_brake':('airport_road',325,1.12),
      'deadpan_pause':('airport_road',325,1.12),
      'rear_end_crash':('airport_road',325,1.12),
      'police_arrive':('roadside',445,1.12),
      'investigation':('roadside',445,1.12),
      'crying_breakdown':('roadside',445,1.25),
      'payoff':('studio_nemi',960,1.18)}
    for shot in s['shots']:
        bg,x,scale=settings[shot['id']]
        shot['background']=bg
        y=894-203*scale
        if bg=='car_cabin':y=654
        shot['actors']={'nemi':{'position':[x,round(y,3)],'scale':scale}}
        shot.pop('camera',None)
    # Pull back to the actual landmark on "look at this view", without making Nemi larger.
    s['shots'][4]['camera']={'center':[960,540],'zoom':1,'path':[{'at':30.77,'center':[960,540],'zoom':1},{'at':32.606364,'center':[1000,520],'zoom':.94}]}
    # Keep road geometry fixed across braking and rear-end approach.
    s['drawings']=[];s['props']=[];s['events']=[];s['vfx']=[];s['sfx']=[]
    def art(kind,at,end,pos,scale=1,group='props',**extra):
        item={'author':'nemi','kind':kind,'position':pos,'scale':[scale,scale],'at':at,'end':end,'mode':'hold',**extra}
        s[group].append(item);return item
    def label(text,at,end,pos,size=44,**extra):return art('text',at,end,pos,group='drawings',text=text,size=size,**extra)
    def event(name,at,intent):s['events'].append({'id':name,'at':at,'intent':intent});return name
    def mark(kind,at,end,pos,scale=1,live=False,**extra):return art(kind,at,end,pos,scale,group='drawings',**({'mode':'live','duration':.65} if live else {}),**extra)
    def sound(id,at,duration,gain,event_id=None):
        catalog=json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']
        asset=next(a for a in catalog if a['id']==id)
        assert asset.get('commercial_use')
        cue={'file':'res://'+asset['relative_path'],'at':at,'duration':duration,'gain_db':gain}
        if event_id:cue['event']=event_id
        s['sfx'].append(cue)
    # Opening travel kit. The known luggage/boarding pass later return in the aftermath.
    art('suitcase',0,8.46,[1060,843],1.2)
    art('desk',0,8.46,[1400,717],1.0,layer=0)
    art('laptop',0,8.46,[1350,664],.8,layer=0)
    art('boarding_pass',0,8.46,[1540,689],.4,layer=0)
    label('what could go wrong?',0,8.46,[1020,205],42)
    mark('question',3.839286,6.0,[1150,390],1.2,live=True)
    # Real city, pavement-scale luggage and a quiet travel postcard.
    art('suitcase',8.46,25.94,[850,846],1.15)
    label('san francisco',11.990435,17.06,[895,135],46)
    label('20,000 steps',20.555652,25.94,[900,165],46)
    mark('underline',21.442609,25.94,[1080,222],1.4,live=True)
    # Auditorium and landmark replace generic room names.
    label('apple event',25.94,30.77,[924,193],47)
    label('2040?',29.867273,30.77,[1040,504],52)
    label('golden gate',30.77,35.75,[966,121],44)
    photo=event('bridge_photo',32.606364,'The held bay/bridge establishes the view before the shutter accent.')
    sound('transition_camera_shutter_01',32.606364,.3,-29,photo)
    # Outside: the car is big enough to transport a person, not a floating toy.
    art('car',35.75,42.59,[1310,800],1.4,layer=0)
    label('waymo',37.539474,42.59,[1030,352],44)
    # The empty seat and turning wheel are the story evidence. Backseat foreground masks knees.
    for at,end in [(42.59,53.55)]:
        art('seat_front',at,end,[750,692],1.12,layer=0)
        art('seat_front',at,end,[1450,1152],1.18,layer=3)
        wheel=art('steering_wheel',at,end,[448,688],.98,layer=2)
        wheel['path']=[{'at':at,'position':[448,688],'tilt':0},{'at':45.888246,'position':[448,688],'tilt':-18},{'at':46.65,'position':[448,688],'tilt':14},{'at':47.3,'position':[448,688],'tilt':4}]
    label('nobody there.',42.59,47.76,[215,111],43)
    empty=event('empty_driver_seat',43.677719,'Question appears beside the visibly empty front seat.')
    mark('question',43.677719,47.76,[718,327],1.25,live=True,event=empty)
    label('totally fine.',50.917895,53.55,[1140,146],40)
    mark('scratch',51.53193,53.55,[1340,171],1.4,live=True)
    # Survival and false safety: a held car, no sparkle confetti quota.
    art('car',53.55,61.10,[1310,800],1.4,layer=0)
    label('safe.',54.141304,61.10,[1100,321],48)
    mark('underline',56.471739,61.10,[1187,378],1.0)
    # Return luggage, then swap to the ordinary cab at the airport line.
    art('suitcase',61.10,67.96,[730,847],1.13)
    art('car',61.10,67.96,[1310,800],1.4,layer=0)
    label('airport cab',64.665217,67.96,[1020,337],44)
    # A physical highway geography. Diagram plane at 894; car wheels meet it.
    for at,end in [(67.96,85.50)]:
        taxi=art('car',at,end,[1235,810.8],1.3,layer=0)
        taxi['path']=[{'at':at,'position':[1150,810.8]},{'at':72.57,'position':[1235,810.8]},{'at':79.075714,'position':[1308,810.8]},{'at':79.355714,'position':[1335,810.8],'tilt':2},{'at':79.62,'position':[1335,810.8],'tilt':0}]
    label('sfo',67.96,93.18,[970,340],40)
    label('5 minutes',67.96,72.57,[1005,180],46)
    brake=event('brake_event',79.355714,'Car settles on the recorded brakes word after a brief anticipation; narration clock is unchanged.')
    sound('impact_soft_thud_01',79.355714,.23,-26,brake)
    # A following vehicle approaches but never passes through the taxi bumper.
    follower=art('car',82.746667,86.839649,[410,810.8],1.3,layer=0)
    follower['path']=[{'at':82.746667,'position':[270,810.8]},{'at':85.5,'position':[375,810.8]},{'at':86.839649,'position':[527,810.8]}]
    # At contact, right edge of following car (527+319*1.3) meets taxi rear (1335-299*1.3).
    art('car',85.5,86.839649,[1335,810.8],1.3,layer=0)
    art('damaged_car',86.839649,93.18,[1335,810.8],1.3,layer=0,event='crash_event')
    art('car',86.839649,93.18,[527,810.8],1.3,layer=0)
    crash=event('crash_event',86.839649,'Rear bumper contact lands on into; afterwards both vehicles hold at contact.')
    sound('impact_soft_thud_01',86.839649,.42,-22,crash)
    s['vfx'].append({'kind':'impact','author':'nemi','position':[950,725],'at':86.839649,'end':87.45,'strength':1.2,'event':crash})
    # Roadside: obvious investigation objects and a deliberately quieter reaction.
    art('police_car',94.876429,103.32,[1030,667],.7,layer=0)
    art('damaged_car',93.18,109.81,[1260,810.8],1.3,layer=0)
    for x in [700,1745]:art('traffic_cone',93.18,109.81,[x,870],1.0,layer=0)
    label('incident report',100.317143,103.32,[935,188],42)
    art('clipboard',99.977857,103.32,[1040,424],1.2)
    art('flashlight',99.299286,103.32,[1600,454],.6,tilt=14)
    paperwork=event('statement_event',100.317143,'The report arrives when statements is spoken, below narration.')
    sound('paper_page_flip_01',100.317143,.35,-29,paperwork)
    tears=event('tears_event',108.710476,'Quiet sad expression and two short tears on crying, with no borrowed gasp voice.')
    s['vfx'].append({'kind':'tears','author':'nemi','actor':'nemi','offset':[0,12],'at':108.710476,'end':109.8,'strength':1.15,'event':tears})
    # Payoff: the intact car and dented taxi are an explicit visual callback; then let the face hold.
    art('car',109.81,118.02,[500,701],.85,layer=0)
    art('damaged_car',115.114348,118.02,[1430,701],.85,layer=0)
    label('robot',109.81,118.02,[372,399],42)
    label('normal cab',115.114348,118.02,[1240,399],42)
    mark('underline',113.862174,118.02,[444,461],.8,live=True)
    art('suitcase',109.81,120,[1670,845],1.18,layer=0)
    for beat in s['direction']['beats']:
        if abs(beat['start']-42.59)<.001:beat['focus']='Empty front seat and turning steering wheel'
        if abs(beat['start']-85.5)<.001:beat['focus']='Rear bumper contact and one impact accent'
    # Thought acting follows exact semantic words, not a repeated generic full-body layout.
    perf=[]
    def act(at,recipe,duration=.32,**kw):
        perf.append({'at':at,'recipe':recipe,'duration':duration,**kw})
    act(0,'explaining',gaze=[0,0],blinks=[2.15])
    act(3.839286,'skeptical',motion='stepped',step_fps=12)
    act(7.053571,'deadpan',0,motion='snap')
    act(8.46,'pleased',0,motion='snap',blinks=[13.1])
    act(18.973043,'prop_present',gaze=[.4,-.1])
    act(22.381739,'weight_shift',blinks=[23.8])
    act(25.94,'realization',0,motion='snap')
    act(30.77,'pleased',0,motion='snap',gaze=[.55,-.2])
    act(35.75,'explaining',0,motion='snap',gaze=[.4,0])
    act(42.59,'passenger_listening',0,motion='snap',grounded=False,gaze=[-.65,.05])
    act(45.888246,'passenger_worried',.32,grounded=False,face={'left_brow_offset':[0,-3],'right_brow_offset':[0,1]},blinks=[46.5])
    act(48.023158,'passenger_worried',.24,grounded=False,hands={'left':'fist','right':'fist'},face={'pupil_scale':.7,'eye_openness':1.15})
    act(51.53193,'passenger_deadpan',0,motion='snap',grounded=False)
    act(53.55,'recover',0,motion='snap',grounded=True)
    act(56.471739,'pleased',blinks=[57.45])
    act(61.10,'explaining',0,motion='snap')
    act(67.96,'pleased',0,motion='snap')
    act(78.984286,'uncertain',.2,gaze=[.6,0],face={'pupil_scale':.85})
    act(79.355714,'quiet_recoil',.2,motion='stepped',step_fps=12,event=brake)
    act(80.48,'deadpan',0,motion='snap')
    act(83.108571,'skeptical',.25,gaze=[-.6,0])
    act(86.839649,'quiet_recoil',.16,motion='stepped',step_fps=12,event=crash,hands={'left':'splayed_fingers','right':'splayed_fingers'})
    act(89.43614,'uncertain',blinks=[90.9])
    act(93.18,'listening',0,motion='snap',gaze=[.5,.2])
    act(99.977857,'embarrassed',gaze=[.4,.25])
    act(103.32,'overwhelmed',0,motion='snap')
    act(107.700952,'overwhelmed',.4,hands={'left':'hand_to_cheek'},face={'eye_openness':.65},blinks=[108.3])
    act(109.81,'soft_shrug',0,motion='snap',gaze=[0,0])
    act(113.862174,'pleased',blinks=[114.3])
    act(117.114348,'deadpan',0,motion='snap')
    s['actors'][0]['performances']=perf
    s['mix']=calibrate_mix(s,ROOT)
    (EP/'scene.json').write_text(json.dumps(s,indent=2)+'\n')
    validate(EP/'scene.json')
    report=['# EP09 revised direction and staging','', 'Narration and all 18 spoken turns are preserved. The two-minute duration is unchanged pending the user’s length preference. No voice generation or second tempo pass.','', '| Seconds | Thought / focus | Revised image |','|---|---|---|']
    for beat in s['direction']['beats']:
        sid=next(q['id'] for q in s['shots'] if q['start']<=beat['start']<q['end'])
        bg=settings[sid][0]
        beat['visual']='Authored '+bg+' set, held story objects and a motivated reaction.'
        report.append(f"| {beat['start']:.2f}–{beat['end']:.2f} | {beat['thought']} / {beat['focus']} | {beat['visual']} |")
    (EP/'DIRECTION_REVISION.md').write_text('\n'.join(report)+'\n')
    (EP/'scene.json').write_text(json.dumps(s,indent=2)+'\n')
    validate(EP/'scene.json')
    from camera_revision import apply
    s=apply(s)
    # Preserve the canonical authored sound pass when rebuilding the picture spec.
    sound_plan=EP/'sound_plan.json'
    if sound_plan.is_file():
        cues=json.loads(sound_plan.read_text())['events']
        catalog={a['id']:a for a in json.loads((ROOT/'common/audio/sfx/sfx_catalog.json').read_text())['assets']}
        s['sfx']=[]
        for cue in cues:
            asset=catalog[cue['sfx_id']]
            assert asset['license']==cue['license']
            validate_asset(asset,ROOT)
            s['events'].append({'id':cue['event'],'at':cue['at'],'intent':cue['intent']})
            s['sfx'].append({'file':'res://'+asset['relative_path'],**{k:cue[k] for k in ['at','duration','gain_db','event']}})
        s['mix']=calibrate_mix(s,ROOT)
    (EP/'scene.json').write_text(json.dumps(s,indent=2)+'\n')
    validate(EP/'scene.json')
    print('EP09 revised spec ready:',EP/'scene.json')
if __name__=='__main__':build()
