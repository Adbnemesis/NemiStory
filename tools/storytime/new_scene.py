#!/usr/bin/env python3
"""Create a separate version-2 visual starter; refuses overwrites."""
import argparse
import json
from pathlib import Path
import re
from validate_scene import ROOT,validate_data
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--name',required=True)
parser.add_argument('--author',choices=['nemi','adb'],required=True)
args=parser.parse_args()
if not re.fullmatch('[a-z][a-z0-9_]{0,50}',args.name): parser.error('Use a short lowercase name with underscores.')
folder=ROOT/'common/storytime/examples'/args.name
if folder.exists(): parser.error('That production folder already exists. Choose a new name.')
a=args.author
spec={'version':2,'title':args.name.replace('_',' '),'duration':10,'fps':30,'caption_size':52,'audio':None,
 'direction':{'promise':'A manageable idea becomes a problem.','want':'Complete one small task.','choice':'Try the obvious solution.','consequence':'It creates an unexpected problem.','payoff':'A quiet reaction reveals the cost.',
 'beats':[{'start':0,'end':4,'thought':'This will be easy.','focus':'Face and notebook','visual':'Held object','intent':'Establish confidence.'},{'start':4,'end':7,'thought':'The solution has a cost.','focus':'Mental image','visual':'Thought insert','intent':'Show the consequence.'},{'start':7,'end':10,'thought':'I may have been wrong.','focus':'Face','visual':'Quiet reaction','intent':'Let the consequence land.'}]},
 'actors':[{'id':a,'author':a,'performances':[{'at':0,'recipe':'pleased'},{'at':1.5,'recipe':'lean_in','duration':.3},{'at':7,'recipe':'skeptical','motion':'stepped','step_fps':12,'duration':.3,'blinks':[8.6]}]}],
 'shots':[{'id':'setup','start':0,'end':4,'background':'studio_'+a,'actors':{a:{'position':[510,570 if a=='nemi' else 540],'scale':1.85}}},{'id':'consequence','start':4,'end':7,'background':'thought','actors':{}},{'id':'reaction','start':7,'end':10,'background':'paper','actors':{a:{'position':[510,570 if a=='nemi' else 540],'scale':1.85}}}],
 'drawings':[{'author':a,'kind':'text','text':'a little plan','size':62,'position':[1030,260],'at':0,'end':4,'mode':'hold','shots':['setup']},{'author':a,'kind':'question','position':[950,430],'scale':[3,3],'at':4,'duration':.65,'end':7,'mode':'live','shots':['consequence']}],
 'props':[{'author':a,'kind':'notebook','position':[1260,650],'scale':[2.3,2.3],'at':0,'end':4,'mode':'hold','shots':['setup']}],
 'vfx':[],'sfx':[],'script':[],'captions':[]}
validate_data(spec)
folder.mkdir()
(folder/'scene.json').write_text(json.dumps(spec,indent=2)+'\n')
(folder/'SCRIPT_AND_BEATS.md').write_text('# '+spec['title']+'\n\nSilent visual starter, not a finished story. Replace the promise/want/choice/consequence/payoff and all beat thoughts with your own story before adding voice. Use approved original recordings and measured word times; pacing only, never change speaker/model/prompt/pitch.\n\n| Time | Thought / intention | Audience focus | Shot / action | Sound or silence |\n|---|---|---|---|---|\n| 0–4 | Confidence becomes commitment | Face and notebook | Closer setup, held prop | Silence |\n| 4–7 | The choice creates a problem | Mental image | Thought insert, one live mark | Silence |\n| 7–10 | Recognize the consequence | Face | Stepped reaction, then hold | Silence |\n\nFollow docs/animation/STORYTIME_REFINEMENT_WORKFLOW.md and STORYTIME_DIRECTION_WORKFLOW.md. Save a new proof under renders/'+args.name+'/. Do not copy this sequence mechanically into every story.\n')
print(folder/'scene.json')
