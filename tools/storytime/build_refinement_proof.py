#!/usr/bin/env python3
"""Build a separate ten-second directing proof from the exact approved clips."""
import json
from pathlib import Path
from prepare_voice import ROOT,prepare,digest
from audio_mix import calibrate_mix
from validate_scene import validate_data

folder=ROOT/'common/storytime/examples/refinement_10s'
audio=ROOT/'renders/storytime_refinement/audio'
words=json.loads((ROOT/'common/storytime/examples/storytime_direction_words.json').read_text())
def clip(author,start,end,at,tempo):
    source=ROOT/f'renders/storytime_direction/audio/{author}.wav'
    return dict(author=author,file='res://'+str(source.relative_to(ROOT)),sha256=digest(source),at=at,start=start,end=end,tempo=tempo,
                words=[{k:w[k] for k in ['word','start','end']} for w in words[author] if start<=w['start'] and w['end']<=end])
plan={'version':1,'duration':10,'clips':[clip('nemi',0,1.55,.2,1.12),clip('nemi',1.9,3.52,1.95,1.12),clip('adb',0,3.12,5.05,1)]}
folder.mkdir(parents=True,exist_ok=True)
(folder/'voice_plan.json').write_text(json.dumps(plan,indent=2)+'\n')
if audio.exists():
    timeline=json.loads((audio/'timeline.json').read_text())
    if timeline['audio_sha256']!=digest(audio/'narration.wav') or any(digest(ROOT/c['file'][6:])!=c['sha256'] for c in plan['clips']):
        raise SystemExit('Saved audio changed; prepare into a fresh folder and reannotate')
    if len(timeline['clips'])!=len(plan['clips']):
        raise SystemExit('Pacing plan changed; choose fresh audio output')
    for saved,planned in zip(timeline['clips'],plan['clips']):
        if any(saved[k]!=planned[k] for k in ['file','sha256','at','start','end','tempo']): raise SystemExit('Pacing plan changed; choose fresh audio output')
else: timeline=prepare(plan,audio)

def mouths(author):
    cues=[]
    for word in timeline['words']:
        if word['actor']!=author: continue
        text=word['word'].lower().strip('.,')
        start,end=word['start'],word['end']; span=end-start
        # Authored broad vowel choices and bilabial closures; approximate,
        # not a measured phoneme transcript. Review this at closeup scale.
        lead=.035 if text in {'plan','my','productive'} else .015
        rest='closed' if author=='nemi' else 'neutral'
        shape=('ae' if text in {'had','plan','laptop'} else 'o_u' if text=='opened' else 'small_open') if author=='nemi' else ('talk_round' if text=='productive' else 'talk_open')
        if lead>.015: cues.append(dict(start=round(start,6),end=round(start+lead,6),shape=rest))
        cues.append(dict(start=round(start+lead,6),end=round(end-.035,6),shape=shape))
        cues.append(dict(start=round(end-.035,6),end=round(end,6),shape=rest))
    return cues

def card(first,last):
    chosen=timeline['words'][first:last+1]
    return dict(actor=chosen[0]['actor'],words=[first,last],start=chosen[0]['start'],end=chosen[-1]['end'],text=' '.join(w['word'] for w in chosen))

spec={'version':2,'title':'One tiny plan, twenty tabs — directing refinement','duration':10,'fps':30,'caption_size':52,
      'audio':'res://renders/storytime_refinement/audio/narration.wav','audio_metadata':'res://renders/storytime_refinement/audio/timeline.json',
      'direction':{'promise':'A tiny plan becomes a ridiculous workload.','want':'Do one manageable thing.','choice':'Open the laptop.','consequence':'The task multiplies into twenty tabs.','payoff':'Busy preparation has produced no work.',
                   'beats':[{'start':0,'end':3.42,'thought':'This is manageable.','focus':'Nemi face and notebook','visual':'Held notebook, warm commitment','intent':'Let confidence become a decision.'},
                            {'start':3.42,'end':4.35,'thought':'The plan grows without permission.','focus':'Tabs insert','visual':'Cutaway; expanding paper cards','intent':'Show the consequence instead of explaining it.'},
                            {'start':4.35,'end':8.3,'thought':'That was very productive.','focus':'ADB hand and dry reaction','visual':'Pick up phone, revise claim, put it down','intent':'Economical action; irony lands through the voice and hold.'},
                            {'start':8.3,'end':10,'thought':'Nothing was accomplished.','focus':'Two faces and final aside','visual':'Quiet shared aftermath','intent':'Allow the joke to register without extra noise.'}]},
      'events':[{'id':'open','at':2.575,'intent':'Nemi commits to opening the laptop.'},{'id':'tabs','at':6.15,'intent':'The one-tab claim becomes absurd.'}],
      'actors':[{'id':'nemi','author':'nemi','performances':[{'at':0,'recipe':'pleased'},{'at':1.88,'recipe':'lean_in','duration':.28,'gaze':[.5,.1],'event':'open','event_offset':-.695},{'at':8.3,'recipe':'embarrassed','motion':'stepped','step_fps':12,'duration':.3,'blinks':[9.2]}],'mouths':mouths('nemi')},
                {'id':'adb','author':'adb','performances':[{'at':0,'recipe':'listening'},{'at':4.35,'recipe':'prop_present','duration':.45,'hands':{'right':'relaxed'},'gaze':[.5,.3]},{'at':4.8,'recipe':'prop_present','motion':'snap','hands':{'right':'holding_cup'},'gaze':[.5,.1]},{'at':6.15,'recipe':'skeptical','face':{'brow_left_height':-2.5,'brow_right_height':1,'eye_openness_left':.72,'eye_openness_right':.82},'motion':'stepped','step_fps':10,'duration':.3,'hands':{'right':'holding_cup'},'event':'tabs'},{'at':7.6,'recipe':'deadpan','motion':'snap','hands':{'right':'holding_cup'}},{'at':7.8,'recipe':'deadpan','motion':'snap','hands':{'right':'relaxed'}},{'at':8.3,'recipe':'deadpan','motion':'snap'}],
                 'hand_paths':{'right':[{'at':0,'position':[45,25],'angle':0},{'at':4.35,'position':[45,25],'angle':0},{'at':4.8,'position':[80,-2],'angle':0,'bend':[-9,-12]},{'at':5.25,'position':[98,-70],'angle':-8,'bend':[12,-4]},{'at':6.65,'position':[98,-70],'angle':-8},{'at':7.8,'position':[80,-2],'angle':0,'bend':[14,-8]},{'at':8.0,'position':[45,25],'angle':0}]},'mouths':mouths('adb')}],
      'shots':[{'id':'confidence','start':0,'end':3.42,'background':'studio_nemi','actors':{'nemi':{'position':[650,790],'scale':3.6}}},
               {'id':'consequence','start':3.42,'end':4.35,'background':'thought','actors':{},'camera':{'path':[{'at':3.42,'center':[960,540],'zoom':1},{'at':4.35,'center':[990,540],'zoom':1.07}]}},
               {'id':'dry_reply','start':4.35,'end':8.3,'background':'paper','actors':{'adb':{'position':[610,850],'scale':3.5}}},
               {'id':'aftermath','start':8.3,'end':10,'background':'evening','actors':{'nemi':{'position':[625,890],'scale':3.1},'adb':{'position':[1270,895],'scale':3.1}}}],
      'props':[{'author':'nemi','kind':'notebook','at':0,'end':2.48,'position':[1290,620],'scale':[2.5,2.5],'mode':'hold','shots':['confidence']},
               {'author':'nemi','kind':'laptop','at':2.48,'end':3.42,'position':[1290,620],'scale':[2.15,2.15],'mode':'hold','shots':['confidence']},
               {'author':'nemi','kind':'tabs','at':3.42,'end':4.35,'position':[945,565],'scale':[3.5,3.5],'mode':'hold','shots':['consequence'],'path':[{'at':3.42,'position':[945,565],'tilt':-3},{'at':3.85,'position':[1000,550],'tilt':1,'bend':[0,-12]},{'at':4.35,'position':[1000,550],'tilt':1}]},
               {'author':'adb','kind':'desk','at':4.35,'end':8.3,'position':[960,843],'scale':[1.1,1.1],'layer':0,'mode':'hold','shots':['dry_reply']},
               {'author':'adb','kind':'phone','at':4.35,'end':8.3,'position':[890,781.75],'scale':[.7,.7],'layer':0,'mode':'hold','shots':['dry_reply'],'attach':{'actor':'adb','hand':'right','grip':[0,25],'socket':[0,0],'angle':0},'attach_start':4.8,'attach_end':7.8},
               {'author':'adb','kind':'tabs','at':4.35,'end':8.3,'position':[1330,510],'scale':[2.1,2.1],'mode':'hold','shots':['dry_reply']}],
      'drawings':[{'author':'nemi','kind':'text','text':'one tiny plan','size':66,'position':[1050,210],'at':0,'end':3.42,'mode':'hold','shots':['confidence']},
                  {'author':'nemi','kind':'text','text':'just one thing','size':62,'position':[675,195],'at':3.42,'end':4.35,'mode':'hold','shots':['consequence']},
                  {'author':'adb','kind':'text','text':'one tab','size':65,'position':[1160,180],'at':4.35,'end':8.3,'mode':'hold','shots':['dry_reply']},
                  {'author':'adb','kind':'scratch','position':[1350,225],'scale':[2.1,1.8],'at':5.75,'duration':.18,'end':8.3,'mode':'live','shots':['dry_reply'],'event':'tabs','event_offset':-.4},
                  {'author':'adb','kind':'text','text':'20 tabs','size':78,'position':[1170,700],'at':5.95,'duration':.35,'end':8.3,'mode':'live','shots':['dry_reply'],'accent':True,'event':'tabs','event_offset':-.2},
                  {'author':'adb','kind':'text','text':'no work done','size':74,'position':[700,80],'at':8.3,'end':10,'mode':'hold','shots':['aftermath']}],
      'vfx':[{'kind':'tension','author':'adb','actor':'adb','offset':[150,-100],'at':6.15,'end':6.75,'strength':.8,'event':'tabs','shots':['dry_reply']}],
      'sfx':[{'file':'res://common/audio/sfx/computer/computer_mouse_fast_double_01.wav','at':2.575,'duration':.18,'gain_db':-25,'event':'open'},
             {'file':'res://common/audio/sfx/drawing/drawing_scratch_scribble_01.ogg','at':5.75,'duration':.139,'gain_db':-26,'event':'tabs','event_offset':-.4}],
      'script':[{'actor':'nemi','start':.2,'end':3.4,'text':'I had a tiny plan. Then I opened my laptop.'},{'actor':'adb','start':5.05,'end':8.17,'text':'Suddenly, twenty tabs. Very productive.'}],
      'captions':[card(0,4),card(5,9),card(10,12),card(13,14)]}
spec['mix']=calibrate_mix(spec,ROOT)
validate_data(spec)
(folder/'scene.json').write_text(json.dumps(spec,indent=2)+'\n')
print(folder/'scene.json')
