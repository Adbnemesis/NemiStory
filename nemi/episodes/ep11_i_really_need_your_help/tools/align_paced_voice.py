"""Re-measure the actual paced narration; no synthesis or speaker change."""
import os,json,hashlib
from pathlib import Path
os.environ['HF_HUB_OFFLINE']='1'
import mlx_whisper
EP=Path(__file__).resolve().parent.parent
p=EP/'voice/narration_r7.wav'
r=mlx_whisper.transcribe(str(p),path_or_hf_repo='mlx-community/whisper-tiny',language='en',word_timestamps=True,verbose=False)
(EP/'review/paced_voice_asr_r7.json').write_text(json.dumps(dict(file='res://'+str(p.relative_to(EP.parents[2])),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),method='Cached Whisper Tiny; actual final recording; recognition does not replace listening',segments=r['segments'],text=r['text']),indent=2)+'\n')
print(r['text'])
