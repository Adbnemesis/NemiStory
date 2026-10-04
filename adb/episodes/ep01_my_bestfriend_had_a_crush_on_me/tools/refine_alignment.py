"""Second cached ASR pass for exact new sources; keeps original Tiny annotations."""
import os,json,sys
from pathlib import Path
os.environ['HF_HUB_OFFLINE']='1'
import mlx_whisper
folder=Path(__file__).resolve().parents[1];root=folder.parents[2]
records=json.loads((folder/'source_words.json').read_text())
for i,r in enumerate(records):
    result=mlx_whisper.transcribe(str(root/r['file'][6:]),path_or_hf_repo='mlx-community/whisper-tiny',language='en',word_timestamps=True,initial_prompt=r['text'],verbose=False)
    r['tiny_words']=r['words']
    r['words']=[w for s in result['segments'] for w in s.get('words',[])]
    r['alignment_kind']='cached Whisper Tiny second-pass word estimates with source-text context; not phoneme alignment'
    print(i,' '.join(w['word'] for w in r['words']),flush=True)
(folder/'source_words_refined.json').write_text(json.dumps(records,indent=2)+'\n')
