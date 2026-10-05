from pathlib import Path
import mlx_whisper,json
root=Path(__file__).resolve().parents[1]
for p in sorted((root/'review/references').glob('ref*/audio.wav')):
    data=mlx_whisper.transcribe(str(p),path_or_hf_repo=str(next((Path.home()/'.cache/huggingface/hub/models--mlx-community--whisper-tiny-mlx/snapshots').iterdir())),word_timestamps=True,verbose=False,language='en')
    (p.parent/'transcript.json').write_text(json.dumps(data,indent=2))
    print(p.parent.name, data['text'],flush=True)
