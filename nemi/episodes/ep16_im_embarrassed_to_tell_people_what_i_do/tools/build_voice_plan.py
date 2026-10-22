"""Prepare protected sources with selected explicit editorial pauses.

Larger cached-ASR is independently measured. Energy only tightens leading/trailing
silence inside broad word intervals; it is not a phoneme detector or audition.
No automatic global silence trimming. Source recordings are never modified.
"""
import hashlib,json,math,shutil,sys,wave
from pathlib import Path
import numpy as np
EP=Path(__file__).resolve().parent.parent
ROOT=EP.parents[2]
sys.path.insert(0,str(ROOT/'tools/storytime'))
from prepare_voice import prepare
records=json.loads((EP/'source_words.json').read_text())
large=json.loads((EP/'review/audio/large_source_words_r1.json').read_text())
# Chosen speech-free boundaries in the opening, prolonged explanatory pause and
# phone request. Emotional pauses in lines7–11 are preserved at original tempo.
choices={
0:dict(tempo=1.08,spans=[(0,1.10),(1.70,2.88),(3.45,5.72),(6.08,7.34),(8.00,10.32)],joins=[.28,.38,.28,.30],pause=.5,reason='Shorten selected oversized opening gaps; retain the question and dry lawyer landing.'),
1:dict(tempo=1.00,pause=.65,reason='Already brisk comparison and a dry electricity hold; preserve source pace.'),
2:dict(tempo=1.10,spans=[(0,7.45),(9.00,13.36)],joins=[.55],pause=.55,reason='Explanatory evasion drags; shorten the long non-emotional excellent-to-now gap with explicit bounds.'),
3:dict(tempo=1.08,pause=.6,reason='Light acceleration of private explanation; retain public deadpan gap and breath.'),
4:dict(tempo=1.00,spans=[(0,1.90),(2.70,6.72)],joins=[.42],pause=.65,reason='Retain phone worry tone; shorten only the oversized request-to-phone gap.'),
5:dict(tempo=1.08,pause=.5,reason='Apology list needs brisk conversational flow; keep sentence separations.'),
6:dict(tempo=1.00,pause=.9,reason='Dry emergency-exit line and its quiet aftermath need a held pause.'),
7:dict(tempo=1.00,pause=.8,reason='Preserve recognition, not-at-me admission and the emotional pauses.'),
8:dict(tempo=1.00,pause=.7,reason='Keep uncertainty and the follow-up question in the original warm performance.'),
9:dict(tempo=1.00,pause=.9,reason='Honest answer and cafe-continues callback keep their original pace.'),
10:dict(tempo=1.00,pause=.7,reason='Reflective self-audition admission needs no acceleration.'),
11:dict(tempo=1.00,pause=1.9,reason='Final pride is quiet, with source breaths/hesitation and a full ending hold.')}
out_audio=EP/'voice/narration_r1.wav';out_timing=EP/'timing_reference_r1.json';out_plan=EP/'voice_plan_r1.json';out_lines=EP/'timing_lines_r1.json'
work=ROOT/'renders/nemi_ep16_voice_r1'
for f in [out_audio,out_timing,out_plan,out_lines,work]:
 if f.exists():raise RuntimeError(f'Protected output exists: {f}; choose a new revision.')
current=.25;clips=[];lines=[];wi=0;word_review=[]
for i,(record,lr) in enumerate(zip(records,large)):
 source=ROOT/record['file'][6:]
 assert record['sha256']==hashlib.sha256(source.read_bytes()).hexdigest()==lr['sha256']
 with wave.open(str(source),'rb') as wf:
  sr=wf.getframerate();arr=np.frombuffer(wf.readframes(wf.getnframes()),dtype=np.int16).astype(float)/32768
 wlist=[]
 for raw in lr['words']:
  a=float(raw['start']);b=float(raw['end']);n1=int(a*sr);n2=min(len(arr),int(b*sr))
  chunk=arr[n1:n2];step=int(sr*.01);active=[]
  for off in range(0,max(0,len(chunk)-step+1),step):
   if np.sqrt(np.mean(chunk[off:off+step]**2))>10**(-43/20):active.append(off/sr)
  aa=a;bb=b
  if active:
   if active[0]>.15:aa=max(a,a+active[0]-.035)
   tail=(len(chunk)/sr)-(active[-1]+.01)
   if tail>.15:bb=min(b,a+active[-1]+.045)
  token=raw['word'].strip()
  # Hyphenated source words are a single visible card/word interval.
  if token.startswith('-') and wlist:
   wlist[-1]['word']+=token;wlist[-1]['end']=round(bb,6);continue
  wlist.append(dict(word=token,start=round(aa,6),end=round(bb,6)))
  if aa!=a or bb!=b:word_review.append(dict(source_line=i,word=token,asr=[a,b],energy_refined=[round(aa,6),round(bb,6)]))
 choice=choices[i];spans=choice.get('spans',[(0,record['duration'])]);joins=choice.get('joins',[]);tempo=choice['tempo'];line_at=current;line_first=wi
 line_words=[]
 for j,(a,b) in enumerate(spans):
  selected=[dict(w) for w in wlist if a<=w['start']<w['end']<=b]
  # Every measured spoken word must be included in exactly one authored span.
  clip=dict(author='nemi',file=record['file'],sha256=record['sha256'],at=round(current,6),start=a,end=b,tempo=tempo,words=selected)
  clips.append(clip)
  line_words.extend(selected);wi+=len(selected)
  current+=(b-a)/tempo
  if j<len(joins):current+=joins[j]
 assert len(line_words)==len(wlist),f'Chosen bounds cut a measured word line{i}: {wlist}'
 lines.append(dict(source_line=i,script=record['text'],measured_transcript=' '.join(w['word'] for w in line_words),at=round(line_at,6),end_at=round(current,6),tempo=tempo,pause_after=choice['pause'],word_start_index=line_first,word_end_index_exclusive=wi,reason=choice['reason']))
 current+=choice['pause']
duration=math.ceil(current*30)/30
assert 90<=duration<=120,duration
plan=dict(version=1,duration=duration,clips=clips)
timeline=prepare(plan,work)
out_plan.write_text(json.dumps(plan,indent=2)+'\n')
shutil.copyfile(work/'timeline.json',out_timing);shutil.copyfile(work/'narration.wav',out_audio)
out_lines.write_text(json.dumps(dict(version=1,duration=duration,audio_sha256=hashlib.sha256(out_audio.read_bytes()).hexdigest(),word_count=wi,lines=lines),indent=2)+'\n')
(EP/'review/audio/word_boundary_refinements_r1.json').write_text(json.dumps(dict(method='Raw large-v3-turbo boundaries tightened only across >150ms low energy within word; -43dBFS 10ms RMS,35ms edge pad. Not phoneme alignment or listening.',changes=word_review),indent=2)+'\n')
(EP/'voice/PACING_R1.md').write_text('# EP16 pacing R1\n\nProtected original Sohee sources total103.200s. Final narration'+f'{duration:.3f}s including authored pauses.\n\n'+'\n'.join(f"- Line{i:02d}: {c['tempo']:.2f}×. {c['reason']}" for i,c in choices.items())+'\n\nExact selected source bounds and joins are in voice_plan_r1.json. Source hashes are preserved. Word intervals come from independent cached large-v3-turbo recognition and conservative energy-boundary refinement. Perceptual listening is pending: the agent tool surface cannot ingest audio; numeric/ASR checks are not claimed as audition.\n')
print(f'EP16 prepared {duration:.3f}s, {wi} words, {len(clips)} explicit clips')
