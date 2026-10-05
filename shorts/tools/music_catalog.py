"""Rank locally supplied or platform candidate music by topic and choreography, never assert stale trends."""
from pathlib import Path
import argparse,json,datetime
p=argparse.ArgumentParser();p.add_argument('catalog');p.add_argument('--topic',required=True);p.add_argument('--energy',type=float,default=.7);p.add_argument('--duration',type=float,default=15);p.add_argument('--platform',default='youtube');p.add_argument('--region',default='IN');a=p.parse_args()
catalog=json.loads(Path(a.catalog).read_text());now=datetime.date.today();out=[]
for m in catalog:
 if m.get('platform') not in [a.platform,'reference','any']:continue
 overlap=sum(1 for word in a.topic.lower().split() if any(word in tag.lower() for tag in m['topics']));topic=min(1,overlap/max(1,len(a.topic.split())))
 date=m.get('verifiedAt');age=(now-datetime.date.fromisoformat(date)).days if date else None
 verified=m.get('trendStatus')=='verified' and age is not None and 0<=age<=7 and m.get('region')==a.region and bool(m.get('evidenceUrl'))
 sync=min(1,len(m.get('usefulCues',[]))/3);fit=max(0,1-abs(a.duration-m['recommendedDuration'])/12);energy=max(0,1-abs(a.energy-m['energy']))
 out.append({'id':m['id'],'score':round(40*topic+20*sync+15*fit+15*energy+10*verified,1),'topicFit':topic,'trendVerifiedCurrent':verified,'trendAgeDays':age,'reason':'Topic, usable cues, duration, energy, fresh platform/region evidence. No license gate.'})
print(json.dumps(sorted(out,key=lambda m:m['score'],reverse=True),indent=2))
