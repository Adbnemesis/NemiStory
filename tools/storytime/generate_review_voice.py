"""New review dialogue using unchanged canonical character voice configurations."""
import json,os,sys,hashlib
from pathlib import Path
os.environ['HF_HUB_OFFLINE']='1'
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import NemiVoiceConfig,ADBVoiceConfig
import mlx_whisper
folder=ROOT/'renders/storytime_review_48s/source_voice';folder.mkdir(parents=True,exist_ok=True)
lines=[('nemi','I was going to draw one tiny thing before bed. Just one.'),('adb','So naturally, she made a plan for the plan.'),('nemi','A notebook. A coffee. And a completely unnecessary number of tabs.'),('adb','I picked up my mug. She opened another window.'),('nemi','Then I finally drew the thing. It was a circle.'),('adb','Forty minutes of preparation. A very professional potato.')]
lines += [('nemi','First, I needed the perfect setup. Apparently, drawing required interior design.'),('adb','The coffee was ready. The drawing was still a theory.'),('nemi','Okay. No more planning. One line, and then another.'),('adb','Honestly? Give it eyes. Now it has a career.')]
engine=None;records=[]
for i,(author,text) in enumerate(lines):
 path=folder/f'{i:02d}_{author}.wav';meta=path.with_suffix('.json')
 config=NemiVoiceConfig() if author=='nemi' else ADBVoiceConfig()
 if not path.exists():
  if engine is None:engine=QwenVoiceDesignEngine(config)
  engine.config=config
  engine.synthesize_to_file(text,str(path),speed=1.0)
 digest=hashlib.sha256(path.read_bytes()).hexdigest()
 if meta.exists():
  record=json.loads(meta.read_text());assert record['sha256']==digest and record['text']==text
 else:
  result=mlx_whisper.transcribe(str(path),path_or_hf_repo='mlx-community/whisper-tiny',language='en',word_timestamps=True,verbose=False)
  words=[w for seg in result['segments'] for w in seg.get('words',[])]
  record={'author':author,'text':text,'file':'res://'+str(path.relative_to(ROOT)),'sha256':digest,'speaker':config.speaker,'identity_prompt':config.voice_design_prompt,'words':words,'alignment_review_required':True}
  meta.write_text(json.dumps(record,indent=2)+'\n')
 records.append(record);print('READY',i,author,text,flush=True)
(ROOT/'common/storytime/examples/story_review_48s/source_words.json').write_text(json.dumps(records,indent=2)+'\n')
