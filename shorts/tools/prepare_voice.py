"""Independent local demo voice adapter; exact approved identity/settings snapshot, no original imports."""
from pathlib import Path
import json,hashlib
import numpy as np,soundfile as sf
from mlx_audio.tts.utils import load_model
ROOT=Path(__file__).resolve().parents[1]
profiles=json.loads((ROOT/'shared/audio/voice-profiles.json').read_text())['authors']
jobs={'adb':[('machine_01','It works on my machine.'),('machine_02','Great. Ship the machine.')],'nemi':[('sketch_01','Just a quick sketch.'),('sketch_02','Why is it tomorrow?')]}
cache=Path.home()/'.cache/huggingface/hub/models--mlx-community--Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16/snapshots'
for author,items in jobs.items():
 config=profiles[author];folder=ROOT/author/'assets/voice';folder.mkdir(parents=True,exist_ok=True);manifest=[];model=None
 for ident,text in items:
  p=folder/(ident+'.wav')
  if not p.exists():
   if model is None:
    if not cache.exists():raise RuntimeError('Approved local model is not cached; rendering does not download models')
    model=load_model(str(next(cache.iterdir())))
    if getattr(model.config,'tts_model_type','')!='custom_voice':raise RuntimeError('Incorrect model identity')
   results=list(model.generate_custom_voice(text=text,speaker=config['speaker'],language=config['language'],instruct=config['instruct'],temperature=config['temperature'],top_k=config['topK'],top_p=config['topP'],repetition_penalty=config['repetitionPenalty'],max_tokens=config['maxTokens'],verbose=False,stream=False))
   if not results or not hasattr(results[0],'audio'):raise RuntimeError('No generated voice')
   data=np.array(results[0].audio,dtype=np.float32)
   if data.ndim>1:data=data.mean(axis=-1)
   peak=np.max(np.abs(data))
   if peak>.98:data*=.95/peak
   sf.write(p,data,config['sampleRate'],subtype='PCM_16')
  data,sr=sf.read(p)
  manifest.append({'id':ident,'text':text,'duration':len(data)/sr,'file':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),**{k:v for k,v in config.items() if k not in ['language','maxTokens']},'sampleRate':sr})
  print(author,ident,len(data)/sr,flush=True)
 (folder/'manifest.json').write_text(json.dumps(manifest,indent=2))
 del model
