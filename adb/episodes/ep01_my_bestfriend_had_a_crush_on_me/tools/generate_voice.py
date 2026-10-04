"""Generate new episode dialogue with unchanged canonical Aiden; preserve sources."""
import os,sys,json,hashlib,re
from pathlib import Path
os.environ['HF_HUB_OFFLINE']='1'
os.environ['TOKENIZERS_PARALLELISM']='false'
ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT))
from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import ADBVoiceConfig
import mlx_whisper
FOLDER=Path(__file__).resolve().parents[1]
OUT=ROOT/'renders/adb_school_crush/source_voice_r1'
OUT.mkdir(parents=True,exist_ok=True)
paragraphs=(FOLDER/'narration.txt').read_text().strip().split('\n\n')
# Authored phrase groupings; preserve pauses and interrupted reply, not arbitrary word cuts.
ranges=[(0,2),(2,3),(3,7),(7,8),(8,10),(10,13),(13,14),(14,15),(15,16),(16,17),(17,18),(18,19),(19,21),(21,22),(22,24),(24,25),(25,26),(26,27)]
assert len(paragraphs)==27,len(paragraphs)
engine=None;records=[]
for i,(a,b) in enumerate(ranges):
    text=' '.join(paragraphs[a:b])
    wav=OUT/f'{i:02d}_adb.wav';meta=wav.with_suffix('.json')
    config=ADBVoiceConfig()
    if not wav.exists():
        if engine is None:engine=QwenVoiceDesignEngine(config)
        duration=engine.synthesize_to_file(text,str(wav),speed=1.0)
        print('GENERATED',i,round(duration,3),flush=True)
    digest=hashlib.sha256(wav.read_bytes()).hexdigest()
    if meta.exists():
        record=json.loads(meta.read_text());assert record['sha256']==digest and record['text']==text
    else:
        result=mlx_whisper.transcribe(str(wav),path_or_hf_repo='mlx-community/whisper-tiny',language='en',word_timestamps=True,verbose=False)
        words=[w for s in result['segments'] for w in s.get('words',[])]
        record={'author':'adb','text':text,'file':'res://'+str(wav.relative_to(ROOT)),'sha256':digest,'speaker':config.speaker,'model':config.repo_id,'identity_prompt':config.voice_design_prompt,'tempo':1.0,'words':words,'alignment_review_required':True}
        meta.write_text(json.dumps(record,indent=2)+'\n')
    records.append(record)
    print('READY',i,record['text'],flush=True)
(FOLDER/'source_words.json').write_text(json.dumps(records,indent=2)+'\n')
