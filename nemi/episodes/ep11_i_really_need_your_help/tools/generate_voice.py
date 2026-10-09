"""New EP11 performance, unchanged canonical identity; retains and hashes sources."""
import hashlib,json,os,sys
from pathlib import Path
os.environ['HF_HUB_OFFLINE']='1'
ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT))
from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import NemiVoiceConfig
import soundfile as sf
import mlx_whisper
EP=Path(__file__).resolve().parent.parent
folder=EP/'voice/source';folder.mkdir(parents=True,exist_ok=True)
story=json.loads((EP/'story.json').read_text())
config=NemiVoiceConfig();engine=None;records=[]
for i,text in enumerate(story['lines']):
    path=folder/f'{i:02d}_nemi.wav';meta=path.with_suffix('.json')
    if not path.exists():
        if engine is None:engine=QwenVoiceDesignEngine(config)
        engine.synthesize_to_file(text,str(path),speed=1.0)
    digest=hashlib.sha256(path.read_bytes()).hexdigest()
    if meta.exists():
        record=json.loads(meta.read_text())
        assert record['sha256']==digest and record['text']==text
    else:
        result=mlx_whisper.transcribe(str(path),path_or_hf_repo='mlx-community/whisper-tiny',language='en',word_timestamps=True,verbose=False)
        words=[w for seg in result['segments'] for w in seg.get('words',[])]
        record=dict(author='nemi',text=text,file='res://'+str(path.relative_to(ROOT)),sha256=digest,speaker=config.speaker,identity_prompt=config.voice_design_prompt,words=words,duration=sf.info(path).duration,alignment_review_required=True)
        meta.write_text(json.dumps(record,indent=2)+'\n')
    records.append(record)
    (EP/'source_words.json').write_text(json.dumps(records,indent=2)+'\n')
    print('READY',i,round(record['duration'],2),text,flush=True)
