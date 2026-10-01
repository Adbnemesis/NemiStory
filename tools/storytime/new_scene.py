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
spec={'version':2,'title':args.name.replace('_',' '),'duration':10,'fps':30,'audio':None,'actors':[{'id':a,'author':a,'performances':[{'at':0,'recipe':'listening'},{'at':1,'recipe':'lean_in'},{'at':5,'recipe':'soft_shrug','blinks':[6.2]},{'at':8,'recipe':'recover'}]}],'shots':[{'id':'setup','start':0,'end':10,'background':'room','actors':{a:{'position':[540,650 if a=='nemi' else 620],'scale':1.5}}}],'drawings':[{'author':a,'kind':'text','text':'a little plan','size':38,'position':[900,330],'at':0,'end':10,'mode':'hold'},{'author':a,'kind':'arrow','position':[870,660],'at':2,'duration':.6,'end':10,'mode':'live'}],'props':[{'author':a,'kind':'notebook','position':[1180,655],'scale':[1.7,1.7],'at':0,'end':10,'mode':'hold'}],'vfx':[],'sfx':[],'script':[],'captions':[]}
validate_data(spec)
folder.mkdir()
(folder/'scene.json').write_text(json.dumps(spec,indent=2)+'\n')
(folder/'SCRIPT_AND_BEATS.md').write_text('# '+spec['title']+'\n\nSilent visual starter. Replace this note with spoken script and measured beat times before adding voice/mouth cues.\n\n| Word/pause time | Thought | Shot/acting | Hold / prop / live drawing | VFX/SFX or silence |\n|---|---|---|---|---|\n| 0 | A little plan | Room, listen | Held notebook | Silence |\n\nFollow docs/animation/STORYTIME_DIRECTION_WORKFLOW.md. Save a new proof under renders/'+args.name+'/.\n')
print(folder/'scene.json')
