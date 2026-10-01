#!/usr/bin/env python3
"""Build the NEW proof spec/narration from saved voices and word annotations."""
import json
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[2]
folder=ROOT/'renders/storytime_direction/audio'
# Alignments are saved with source so reproducing the proof doesn't require ASR.
annotation=ROOT/'common/storytime/examples/storytime_direction_words.json'
words=json.loads(annotation.read_text())
for author in ['nemi','adb']:
 if not (folder/f'{author}.wav').is_file(): raise SystemExit('Generate the new voice clips first: .venv/bin/python tools/storytime/generate_proof_voice.py')
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(folder/'nemi.wav'),'-i',str(folder/'adb.wav'),'-filter_complex','[0:a]adelay=300:all=1[n];[1:a]adelay=5300:all=1[a];[n][a]amix=inputs=2:normalize=0,apad,atrim=duration=10[out]','-map','[out]','-ar','24000',str(folder/'narration.wav')],check=True)
def mouth_cues(author,offset):
 result=[]
 shapes={'nemi':{'i':'small_open','had':'small_open','a':'small_open','tiny':'small_open','plan':'ae','then':'small_open','opened':'o_u','my':'small_open','laptop':'small_open'},'adb':{'suddenly':'talk_open','twenty':'talk_open','tabs':'talk_open','very':'talk_open','productive':'talk_open'}}
 for word in words[author]:
  text=word['word'].strip().lower().strip('.,!?')
  start=round(offset+word['start']+.02,3);end=round(offset+word['end']-.02,3)
  if end>start: result.append(dict(start=start,end=end,shape=shapes[author].get(text,'small_open' if author=='nemi' else 'talk_open')))
 return result
spec={'version':2,'title':'A tiny plan, twenty tabs','duration':10,'fps':30,'audio':'res://renders/storytime_direction/audio/narration.wav',
'events':[{'id':'revision','at':6.12,'intent':'Cross out the overconfident one-tab claim.'}],
'actors':[
 {'id':'nemi','author':'nemi','performances':[{'at':0,'recipe':'listening'},{'at':.4,'recipe':'weight_shift','blinks':[1.88]},{'at':2.2,'recipe':'lean_in','gaze':[.7,.05],'hands':{'right':'open_palm_up'}},{'at':8.65,'recipe':'deadpan'}],'mouths':mouth_cues('nemi',.3)},
 {'id':'adb','author':'adb','performances':[{'at':0,'recipe':'listening'},{'at':5.3,'recipe':'prop_present','hands':{'right':'holding_cup'},'gaze':[.35,.15]},{'at':6.15,'recipe':'soft_shrug','hands':{'right':'holding_cup'},'blinks':[7.03]},{'at':7.3,'recipe':'deadpan'},{'at':8.65,'recipe':'deadpan'}],'mouths':mouth_cues('adb',5.3)}],
'shots':[
 {'id':'setup','start':0,'end':3.85,'background':'room','actors':{'nemi':{'position':[560,650],'scale':1.55}}},
 {'id':'inside_plan','start':3.85,'end':5.3,'background':'thought','actors':{},'camera':{'center':[960,540],'zoom':1}},
 {'id':'reply','start':5.3,'end':8.65,'background':'paper','actors':{'adb':{'position':[530,625],'scale':1.65}}},
 {'id':'aftermath','start':8.65,'end':10,'background':'evening','actors':{'nemi':{'position':[550,650],'scale':1.5},'adb':{'position':[1230,642],'scale':1.5}}}],
'props':[
 {'author':'nemi','kind':'notebook','at':0,'end':2.75,'position':[1120,635],'scale':[1.7,1.7],'shots':['setup'],'mode':'hold'},
 {'author':'nemi','kind':'laptop','at':2.75,'end':3.85,'position':[1150,690],'scale':[1.5,1.5],'shots':['setup'],'mode':'hold'},
 {'author':'nemi','kind':'cloud','at':3.85,'end':5.3,'position':[930,485],'scale':[3.6,2.5],'shots':['inside_plan'],'mode':'hold','layer':-1},
 {'author':'nemi','kind':'tabs','at':3.85,'end':5.3,'position':[930,505],'scale':[1.9,1.9],'shots':['inside_plan'],'mode':'hold'},
 {'author':'adb','kind':'tabs','at':5.3,'end':8.65,'position':[1270,555],'scale':[2,2],'shots':['reply'],'mode':'hold'},
 {'author':'adb','kind':'phone','at':5.3,'end':7.3,'scale':[.8,.8],'mode':'hold','attach':{'actor':'adb','hand':'right','grip':[0,8],'angle':0},'layer':0}],
'drawings':[
 {'author':'nemi','kind':'text','text':'just one thing','size':38,'at':0,'end':3.85,'position':[920,320],'mode':'hold','shots':['setup']},
 {'author':'nemi','kind':'text','text':'a tiny plan','size':37,'at':3.85,'end':5.3,'position':[735,200],'mode':'hold','shots':['inside_plan']},
 {'author':'adb','kind':'text','text':'one tab','size':45,'at':5.3,'end':8.65,'position':[1155,225],'mode':'hold','shots':['reply']},
 {'author':'adb','kind':'scratch','event':'revision','at':6.12,'duration':.2,'end':8.65,'position':[1280,250],'scale':[1.8,1.2],'mode':'live','accent':True,'shots':['reply']},
 {'author':'adb','kind':'text','text':'20 tabs','size':52,'at':6.34,'duration':.55,'end':8.65,'position':[1120,785],'mode':'live','accent':True,'shots':['reply']},
 {'author':'adb','kind':'text','text':'no work done','size':38,'at':8.65,'end':10,'position':[780,285],'mode':'hold','accent':True,'shots':['aftermath']}],
'vfx':[{'kind':'realization','author':'nemi','actor':'nemi','offset':[95,-65],'at':2.75,'end':3.35,'shots':['setup']},{'kind':'sweat','author':'adb','actor':'adb','offset':[95,-30],'event':'revision','at':6.12,'end':6.85,'shots':['reply']}],
'sfx':[{'file':'res://common/audio/sfx/computer/computer_mouse_fast_double_01.wav','at':2.95,'duration':.18,'gain_db':-24},{'file':'res://common/audio/sfx/paper/paper_page_flip_03.ogg','at':3.85,'duration':.23,'gain_db':-22},{'file':'res://common/audio/sfx/drawing/drawing_scratch_scribble_01.ogg','event':'revision','at':6.12,'duration':.139,'gain_db':-24}],
'script':[{'actor':'nemi','start':.3,'end':3.82,'text':'I had a tiny plan. Then I opened my laptop.'},{'actor':'adb','start':5.3,'end':8.42,'text':'Suddenly, twenty tabs. Very productive.'}],
'captions':[{'start':.3,'end':1.72,'text':'I had a tiny plan.'},{'start':2.32,'end':3.82,'text':'Then I opened my laptop.'},{'start':5.3,'end':6.8,'text':'Suddenly, twenty tabs.'},{'start':7.34,'end':8.42,'text':'Very productive.'}]}
(ROOT/'common/storytime/examples/storytime_direction_10s.json').write_text(json.dumps(spec,indent=2)+'\n')
print('Prepared ten-second direction proof')
