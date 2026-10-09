"""Second cached recognition pass; never changes recordings or fabricates word timing."""
import json,os
from pathlib import Path
os.environ['HF_HUB_OFFLINE']='1'
import mlx_whisper
EP=Path(__file__).resolve().parent.parent
records=json.loads((EP/'source_words.json').read_text())
for i,r in enumerate(records):
    out=EP/'voice/source'/f'{i:02d}_large_alignment.json'
    if out.exists(): result=json.loads(out.read_text())
    else:
        result=mlx_whisper.transcribe(str(EP/'voice/source'/f'{i:02d}_nemi.wav'),path_or_hf_repo='mlx-community/whisper-large-v3-turbo',language='en',word_timestamps=True,verbose=False)
        out.write_text(json.dumps(result,indent=2)+'\n')
    r['words']=[w for s in result['segments'] for w in s.get('words',[])]
    r['alignment_kind']='cached Whisper large-v3-turbo word estimates; not phonemes'
    print(i,' '.join(w['word'].strip() for w in r['words']),flush=True)
(EP/'source_words_final.json').write_text(json.dumps(records,indent=2)+'\n')
