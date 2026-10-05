from pathlib import Path
import json,csv,numpy as np, subprocess
from scipy.signal import stft
R=Path(__file__).resolve().parents[1]/'review/references'
settings={1:(130,4.911,[35,78,99,129,151,179,206,235,261,290,314,344]),2:(120,.156,[20,58,62,75,78,90,92,102,117,119,165,179,210,258,260,272,287,313,325,338,350,362,365,373,377,380,384,392,403,407,410,414,427,449,474,487,525,545]),3:(92,0.035,[49,80,124,156,202,238,281,334,361,395,435,471,516,551,592]),4:(137,0.03,[56,111,152,164,218,259])}
for i,(bpm,base,boundaries) in settings.items():
 p=R/f'ref{i:02}';m=json.loads((p/'measurements.json').read_text());d=m['decoded_frames']/m['fps']
 beats=np.arange(base% (60/bpm),d,60/bpm)
 events=[{'frame':f,'time':round(f/m['fps'],4),'nearest_beat':round(float(beats[np.argmin(abs(beats-f/m['fps']))]),4),'beat_error_ms':round(float(np.min(abs(beats-f/m['fps']))*1000),1)} for f in boundaries]
 data={'bpm':bpm,'tempo_status':'editorial estimate; half/double tempo ambiguity retained','grid_status':'approximate musical pulse, not confirmed bar/downbeat phase','beats':[round(float(t),4) for t in beats],'subdivisions':[round(float(t),4) for t in np.arange(base%(30/bpm),d,30/bpm)],'visual_events':events,'phrases':{'ref01':[4.91],'ref02':[11.26,15.8],'ref03':[],'ref04':[3.733,10.933]}.get(f'ref{i:02}',[]),'audio_duration':m['duration'],'video_duration':d,'shots_including_reframes_and_text_cards':len(boundaries)+1,'average_layout_seconds':round(d/(len(boundaries)+1),3),'longest_layout_seconds':round(max(np.diff([0]+[f/m['fps'] for f in boundaries]+[d])),3),'shortest_layout_seconds':round(min(np.diff([0]+[f/m['fps'] for f in boundaries]+[d])),3)}
 (p/'editorial.json').write_text(json.dumps(data,indent=2))
 with (p/'event_beat_map.csv').open('w') as fh:
  writer=csv.DictWriter(fh,fieldnames=list(events[0]));writer.writeheader();writer.writerows(events)
 print(f'ref{i:02}',{k:data[k] for k in ['shots_including_reframes_and_text_cards','average_layout_seconds','longest_layout_seconds','shortest_layout_seconds']})
