"""Audit exact source clip lead-ins; never synthesize or modify the clips."""
from pathlib import Path
import json,subprocess,hashlib,numpy as np
r=Path(__file__).resolve().parents[1];catalog=json.loads((r/'shared/audio/sfx-catalog.json').read_text());starts={'pop':.1,'whoosh':.1,'click':1/30,'error':.6,'chime':.4,'bruh':1/30,'key-press':0,'ping':.3};audit=[]
for item in catalog:
 p=r/'public'/item['file'];x=np.frombuffer(subprocess.check_output(['ffmpeg','-v','error','-i',str(p),'-ac','2','-ar','48000','-f','f32le','pipe:1']),'<f4').reshape(-1,2);mono=x.mean(axis=1);windows=np.array([np.sqrt(np.mean(mono[i:i+480]**2)) for i in range(0,len(mono),480)]);active=np.flatnonzero(windows>max(windows)*.12)
 row={'id':item['id'],'file':item['file'],'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'duration':len(mono)/48000,'activeOnset':float(active[0]*.01),'rmsPeakAt':float(np.argmax(windows)*.01),'activeEnd':float(active[-1]*.01),'recommendedSourceStart':starts[item['id']],'placementLead':2/30 if item['id']=='key-press' else 0,'note':'10ms RMS windows, 12% of peak threshold; sourceStart rounded to an actual 30fps audio source frame; inspect placement in encoded mix.'};audit.append(row)
 item.update({k:row[k] for k in ['activeOnset','rmsPeakAt','recommendedSourceStart','placementLead']})
(r/'review/SFX_AUDIT.json').write_text(json.dumps(audit,indent=2));(r/'shared/audio/sfx-catalog.json').write_text(json.dumps(catalog,indent=2));print('Audited exact source lead-ins for',len(audit),'SFX')
