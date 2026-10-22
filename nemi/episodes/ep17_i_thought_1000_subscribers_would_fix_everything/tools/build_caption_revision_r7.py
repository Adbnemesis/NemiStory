"""Correct one caption token against intended script + independent final-audio ASR.

Preserve existing recordings, timings and R6; create a new immutable R7 spec.
"""
import hashlib,json,sys
from pathlib import Path
EP=Path(__file__).resolve().parent.parent
ROOT=EP.parents[2]
sys.path.insert(0,str(ROOT/'tools/storytime'))
from validate_scene import validate
base=EP/'scene_r6_1080p.json';spec=json.loads(base.read_text())
old_metadata=ROOT/spec['audio_metadata'].removeprefix('res://')
metadata=json.loads(old_metadata.read_text());assert metadata['words'][89]['word']=='reach'
assert "I'd reached the checkpoint." in (EP/'story.json').read_text()
asr=EP/'review/audio/final_narration_asr_r6.json'
independent=json.loads(asr.read_text());assert independent['audio_sha256']==metadata['audio_sha256']
assert any(w['word'].strip().lower().rstrip('.,?!')=='reached' and 39<w['start']<41 for w in independent['words'])
metadata['words'][89]['word']='reached'
new_metadata=EP/'timing_reference_r4.json';output=EP/'scene_r7_1080p.json'
assert not new_metadata.exists() and not output.exists(),'Refuse overwriting protected revision.'
new_metadata.write_text(json.dumps(metadata,indent=2)+'\n')
spec['audio_metadata']='res://'+str(new_metadata.relative_to(ROOT))
card=next(c for c in spec['captions'] if c['words']==[88,91]);assert card['text']=="I'd reach the checkpoint."
card['text']="I'd reached the checkpoint."
output.write_text(json.dumps(spec,indent=2)+'\n');validate(output)
(EP/'scene.json').write_bytes(output.read_bytes())
(EP/'review/CAPTION_CORRECTION_R7.json').write_text(json.dumps(dict(reason='Correct reach to reached against intended script and independent final-audio ASR. No voice, timing, mouth, camera, art or mix changes.',old_scene=base.name,current_scene=output.name,old_metadata=old_metadata.name,current_metadata=new_metadata.name,word_index=89,old_word='reach',correct_word='reached',caption_window=[card['start'],card['end']],source_audio_sha256=metadata['audio_sha256'],evidence=str(asr.relative_to(EP)),evidence_sha256=hashlib.sha256(asr.read_bytes()).hexdigest(),perceptual_listening_performed=False),indent=2)+'\n')
print('R7 caption correction validated; source audio and all timing unchanged.')
