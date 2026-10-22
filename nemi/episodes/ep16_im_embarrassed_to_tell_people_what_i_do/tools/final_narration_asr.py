#!/usr/bin/env python3
"""One independent final-audio ASR check; no picture/audio/timing edits."""
from pathlib import Path
import argparse,json,os,hashlib,fcntl,re,difflib,statistics
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--spec',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--root',type=Path,default=Path.cwd(),help='Repository root; defaults to current directory');a=p.parse_args()
if a.out.exists():raise SystemExit('Output exists; preserve bounded original review.')
root=a.root.resolve();s=json.loads(a.spec.read_text());audio=root/s['audio'].removeprefix('res://');metadata=root/s['audio_metadata'].removeprefix('res://');m=json.loads(metadata.read_text());digest=hashlib.sha256(audio.read_bytes()).hexdigest();assert m['audio_sha256']==digest
os.environ['HF_HUB_OFFLINE']='1'
lock=open('/private/tmp/nemi_ep16_ep17_tts.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
import mlx_whisper
r=mlx_whisper.transcribe(str(audio),path_or_hf_repo='mlx-community/whisper-large-v3-turbo',language='en',word_timestamps=True,verbose=False,condition_on_previous_text=False,temperature=0)
words=[w for seg in r['segments'] for w in seg.get('words',[])];reference=m['words']
norm=lambda t:re.sub(r'[^a-z0-9\']','',t.lower().replace('’',"'"))
left=[norm(w['word']) for w in reference];right=[norm(w['word']) for w in words];match=difflib.SequenceMatcher(a=left,b=right,autojunk=False);differences=[];deltas=[]
for tag,i,j,k,l in match.get_opcodes():
 if tag=='equal':
  for x,y in zip(reference[i:j],words[k:l]):deltas.append(abs(x['start']-y['start']))
 else:differences.append(dict(kind=tag,reference_indices=[i,j],asr_indices=[k,l],reference=' '.join(w['word'] for w in reference[i:j]),asr=' '.join(w['word'] for w in words[k:l])))
result=dict(audio=s['audio'],audio_sha256=digest,metadata=s['audio_metadata'],metadata_sha256=hashlib.sha256(metadata.read_bytes()).hexdigest(),scene=str(a.spec),scene_sha256=hashlib.sha256(a.spec.read_bytes()).hexdigest(),model='cached mlx-community/whisper-large-v3-turbo',initial_prompt=None,condition_on_previous_text=False,temperature=0,text=r['text'],words=words,comparison=dict(reference_words=len(reference),asr_words=len(words),normalized_token_similarity=match.ratio(),cosmetic_or_semantic_differences_to_review=differences,matched_word_start_absolute_delta_median_seconds=statistics.median(deltas) if deltas else None,matched_word_start_absolute_delta_max_seconds=max(deltas) if deltas else None),limitations='Independent ASR is approximate transcription/timing evidence, not acoustic audition, phoneme-perfect sync or artistic approval. No media, scene or timing files modified.')
assert hashlib.sha256(audio.read_bytes()).hexdigest()==digest,'Audio changed during ASR'
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n');print(r['text']);print(json.dumps(result['comparison'],indent=2));print(a.out)
