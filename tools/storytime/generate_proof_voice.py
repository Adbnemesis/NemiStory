#!/usr/bin/env python3
"""Generate only the NEW direction proof's two lines with the existing local voices."""
import json
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import NemiVoiceConfig
engine=QwenVoiceDesignEngine(NemiVoiceConfig())
folder=ROOT/'renders/storytime_direction/audio'
folder.mkdir(parents=True,exist_ok=True)
lines=[('nemi','sohee','I had a tiny plan. Then I opened my laptop.','Warm conversational delivery, a small amused hesitation before then. No shouting.'),('adb','aiden','Suddenly, twenty tabs. Very productive.','Dry, understated conversational delivery. Small pause before very productive.')]
result=[]
for author,speaker,text,note in lines:
 path=folder/f'{author}.wav'
 duration=engine.synthesize_to_file(text,str(path),speaker=speaker,instruct=note)
 result.append(dict(author=author,speaker=speaker,text=text,file=str(path.relative_to(ROOT)),duration=duration))
(folder/'lines.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
