from pathlib import Path
import json,mlx_whisper,hashlib
root=Path(__file__).resolve().parents[1]
model=str(next((Path.home()/'.cache/huggingface/hub/models--mlx-community--whisper-tiny-mlx/snapshots').iterdir()))
for author in ['adb','nemi']:
 for p in (root/author/'assets/voice').glob('*.wav'):
  result=mlx_whisper.transcribe(str(p),path_or_hf_repo=model,language='en',word_timestamps=True,verbose=False)
  words=[w for s in result['segments'] for w in s.get('words',[])]
  data={'sourceHash':hashlib.sha256(p.read_bytes()).hexdigest(),'transcript':result['text'],'words':words,'method':'cached tiny Whisper proposal, must inspect against recording; not phonemes'}
  (p.with_suffix('.timing.json')).write_text(json.dumps(data,indent=2));print(p.name,result['text'],[(w['word'],w['start'],w['end']) for w in words],flush=True)
