"""Create EP17 source recordings with unchanged canonical Nemi identity."""
import os, sys, json, hashlib
from pathlib import Path
os.environ['HF_HUB_OFFLINE']='1'
ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT))
from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import NemiVoiceConfig
import mlx_whisper
FOLDER=Path(__file__).resolve().parents[1]
LINES=[
 ('00_hook','A message to every storytime animator.'),
 ('01_name','My name is Nemi.'),
 ('02_identity',"I'm a professional overthinker."),
 ('03_challenge',"And I'm gonna steal your watch time."),
 ('04_ambition','By becoming the biggest storytime animator in the world.'),
 ('05_ending',"I've already got the stories. Now I just gotta stop overthinking."),
 ('06_name_short',"I'm Nemi."),
 ('07_identity_short',"I'm an overthinker."),
 ('08_ending_short','Got the stories. Just gotta stop overthinking.'),
 ('09_name_clean',"My name's Nemi."),
]
config=NemiVoiceConfig();engine=None
records=[]
for stem,text in LINES:
 path=FOLDER/'audio/source'/f'{stem}.wav';meta=path.with_suffix('.json')
 if not path.exists():
  if engine is None: engine=QwenVoiceDesignEngine(config)
  duration=engine.synthesize_to_file(text,str(path),speed=1.0)
  print('SYNTHESIZED',stem,round(duration,3),flush=True)
 digest=hashlib.sha256(path.read_bytes()).hexdigest()
 if meta.exists():
  record=json.loads(meta.read_text());assert record['sha256']==digest and record['text']==text
 else:
  result=mlx_whisper.transcribe(str(path),path_or_hf_repo='mlx-community/whisper-tiny',language='en',word_timestamps=True,verbose=False)
  words=[w for seg in result['segments'] for w in seg.get('words',[])]
  record={'author':'nemi','text':text,'file':'res://'+str(path.relative_to(ROOT)),'sha256':digest,'speaker':config.speaker,'identity_prompt':config.voice_design_prompt,'words':words,'alignment_review_required':True}
  meta.write_text(json.dumps(record,indent=2)+'\n')
 records.append(record);print('READY',stem,text,flush=True)
(FOLDER/'source_words.json').write_text(json.dumps(records,indent=2)+'\n')
