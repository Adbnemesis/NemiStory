from pathlib import Path
from fractions import Fraction
import json, hashlib, os, time
import numpy as np
import torch
import soundfile as sf
from safetensors import safe_open
from safetensors.torch import load_file
from demucs.htdemucs import HTDemucs
from demucs.apply import apply_model
p=Path(__file__).parent
weights=next(Path('/Users/talus/.cache/huggingface/hub/models--adefossez--HTDemucs/snapshots').glob('*/*.safetensors'))
with safe_open(weights,framework='pt') as f:
 meta=f.metadata()
kwargs=json.loads(meta['kwargs'])
for k,v in list(kwargs.items()):
 if isinstance(v,dict) and v.get('_type')=='fraction':kwargs[k]=Fraction(v['numerator'],v['denominator'])
model=HTDemucs(**kwargs)
model.load_state_dict(load_file(str(weights)))
model.eval()
y,sr=sf.read(p/'reference_stereo.wav',dtype='float32');assert sr==44100
mix=torch.from_numpy(y.T.copy())
ref=mix.mean(0); mix=(mix-ref.mean())/ref.std()
torch.set_num_threads(6)
t0=time.time()
with torch.no_grad():
 estimates=apply_model(model,mix[None],device='cpu',shifts=1,split=True,overlap=.25,progress=True,num_workers=0)[0]
estimates=estimates*ref.std()+ref.mean()
for name,stem in zip(model.sources,estimates):sf.write(p/f'reference_{name}.wav',stem.T.numpy(),sr,subtype='PCM_24')
inst=estimates[:3].sum(0).T.numpy()
sf.write(p/'reference_instrumental_separated.wav',inst,sr,subtype='PCM_24')
record={'source':'/Users/talus/Downloads/This Is A Message To All Minecraft Youtubers.mp4','source_sha256':hashlib.sha256(Path('/Users/talus/Downloads/This Is A Message To All Minecraft Youtubers.mp4').read_bytes()).hexdigest(),'method':'HTDemucs 4.0.1; cached 955717e8 safetensors; no new musical synthesis','model_sha256':hashlib.sha256(weights.read_bytes()).hexdigest(),'sample_rate':sr,'samples':len(inst),'duration':len(inst)/sr,'elapsed_seconds':time.time()-t0,'output_sha256':hashlib.sha256((p/'reference_instrumental_separated.wav').read_bytes()).hexdigest(),'review_required':True,'note':'Model estimate; no claim of lossless/original instrumental. Check voice leakage before use.'}
(p/'separation_provenance.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps(record,indent=2))
