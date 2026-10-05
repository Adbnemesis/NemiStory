"""Verify source cue presence in the actual encoded raw mix by independent stem regression.
Not a substitute for subjective listening. Retains findings and actual-excerpt ASR proposals.
"""
from pathlib import Path
import argparse,subprocess,json,numpy as np,hashlib
P=argparse.ArgumentParser();P.add_argument('timeline',type=Path);P.add_argument('movie',type=Path);P.add_argument('--asr',action='store_true');a=P.parse_args();r=Path(__file__).resolve().parents[1];c=json.loads(a.timeline.read_text());out=a.movie.resolve().parent.parent/'review'/a.movie.stem;out.mkdir(parents=True,exist_ok=True);from audio_mix import measure
record=json.loads((a.movie.parent.parent/'review'/(a.movie.stem+'.render.json')).read_text());raw=Path(record['master']['raw']);findings=measure(c,raw);labels=findings['stems'];corr=findings['reconstructionCorrelation'];residual=findings['residualRms']
# Measure final timing against the expected sources independently of the raw mix correction.
final=measure(c,a.movie)
report={'movie':str(a.movie),'hash':hashlib.sha256(a.movie.read_bytes()).hexdigest(),'method':'48kHz mono-average decode; least-squares exact known-source stems against actual raw AAC mix, same scheduled times. Numeric detection, not listening.', 'reconstructionCorrelation':corr,'residualRms':residual,'rawDelaySeconds':findings['delaySeconds'],'finalDelaySeconds':final['delaySeconds'],'stems':labels,'asr':[]}
if a.asr:
 import mlx_whisper
 model=str(next((Path.home()/'.cache/huggingface/hub/models--mlx-community--whisper-tiny-mlx/snapshots').iterdir()))
 for d in c['dialogue']:
  wav=out/(d['id']+'_encoded_excerpt.wav');subprocess.run(['ffmpeg','-v','error','-y','-ss',str(d['at']),'-i',str(a.movie),'-t',str(d['duration']),'-ar','16000',str(wav)],check=True)
  result=mlx_whisper.transcribe(str(wav),path_or_hf_repo=model,language='en',verbose=False,word_timestamps=True)
  report['asr'].append({'id':d['id'],'expected':d['text'],'proposal':result['text'],'words':[w for s in result['segments'] for w in s.get('words',[])],'note':'Cached tiny-model text proposal from actual encoded mix; not phoneme or human listening verification.'})
(out/'audio-cues.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
if abs(final['delaySeconds'])>1/60 or corr<.92 or any(not s['sourceAtExpectedTimeDetected'] for s in labels):raise SystemExit('Inspect mix: cue detection below threshold')
