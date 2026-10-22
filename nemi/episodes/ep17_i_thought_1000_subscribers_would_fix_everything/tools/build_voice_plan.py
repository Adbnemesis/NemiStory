"""EP17 source-hashed editorial pace; source bounds explicit, no voice changes."""
import hashlib,json,math,shutil,sys
from pathlib import Path
import numpy as np
import soundfile as sf
EP=Path(__file__).resolve().parent.parent
ROOT=EP.parents[2]
sys.path.insert(0,str(ROOT/'tools/storytime'))
from prepare_voice import prepare
TEMPOS=[1.10,1.10,1.00,1.10,1.10,1.00,1.10,1.10,1.00,1.00,1.00]
HOLDS=[.35,.40,.50,.70,.55,.75,.65,.60,.70,.80,1.70]
CUTS={3:[(7.10,7.80,'frame / Same hand')],4:[(5.35,5.95,'checkpoint / Why')],8:[(4.60,5.00,'digits / People')]}

def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def r(x):return round(float(x),6)
def db(x):return r(20*math.log10(max(1e-12,float(x))))
records=json.loads((EP/'source_words.json').read_text())
large={x['source_line']:x for x in json.loads((EP/'review/audio/large_source_words_r1.json').read_text())}
work=ROOT/'renders/nemi_ep17_voice_r3'
for p in [work,EP/'voice/narration_r3.wav',EP/'timing_reference_r3.json']:
 if p.exists():raise RuntimeError(f'Protected output exists:{p}')
clips=[]; lines=[]; current=.3;global_index=0;review=[];removed=[]
for i,record in enumerate(records):
 alignment=large.get(i,record)
 assert alignment['sha256']==record['sha256']
 words=[dict(word=w['word'].strip(),start=r(w['start']),end=r(w['end'])) for w in alignment['words']]
 if i in large:review.append(dict(line=i,alignment='independent cached whisper-large-v3-turbo source words',acoustic_review_pending=True))
 if i==0:
  j=next(j for j,w in enumerate(words) if w['word']=='1')
  assert words[j+1]['word']==',000'
  words[j]['word']='1,000';words[j]['end']=words[j+1]['end'];words.pop(j+1)
  review.append(dict(line=i,alignment='Two measured numeric ASR groups combined as1,000 without changing audio/times',acoustic_review_pending=True))
 bounds=[];start=0.0
 data,sr=sf.read(ROOT/record['file'][6:],always_2d=True)
 for a,b,reason in CUTS.get(i,[]):
  assert all(w['end']<=a or w['start']>=b for w in words)
  v=data[round(a*sr):round(b*sr)];rms=db(np.sqrt(np.mean(v*v)));peak=db(np.max(np.abs(v)))
  assert rms < -60 and peak < -40
  bounds.append((start,a));start=b;removed.append(dict(line=i,start=a,end=b,reason=reason,rms_dbfs=rms,peak_dbfs=peak))
 bounds.append((start,record['duration']))
 at=current;count=0
 for a,b in bounds:
  keep=[w for w in words if a<=w['start'] and w['end']<=b]
  clips.append(dict(author='nemi',file=record['file'],sha256=record['sha256'],at=current,start=a,end=b,tempo=TEMPOS[i],words=keep))
  current+=(b-a)/TEMPOS[i];count+=len(keep)
 lines.append(dict(source_line=i,text=record['text'],at=r(at),end=r(current),tempo=TEMPOS[i],word_start_index=global_index,word_end_index_exclusive=global_index+count,pause_after=HOLDS[i]))
 global_index+=count;current+=HOLDS[i]
duration=math.ceil(current*30)/30
assert 90<=duration<=120,duration
plan=dict(version=1,duration=duration,clips=clips)
timeline=prepare(plan,work)
(EP/'voice').mkdir(exist_ok=True)
shutil.copyfile(work/'narration.wav',EP/'voice/narration_r3.wav')
dump(EP/'voice_plan_r3.json',plan);dump(EP/'timing_reference_r3.json',timeline);dump(EP/'timing_lines_r3.json',dict(duration=duration,lines=lines))
dump(EP/'review/PACING_R3.json',dict(duration=duration,source_duration=sum(r['duration'] for r in records),tempos=TEMPOS,holds=HOLDS,selected_gap_edits=removed,word_group_repairs=review,identity_policy='Unchanged canonical Sohee CustomVoice; source1.00; atempo only',acoustic_audition_performed=False,final_word_review_required=True))
print('EP17 prepared',duration,'seconds',len(timeline['words']),'word groups')
