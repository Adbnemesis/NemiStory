"""Publish recut evidence only after explicit per-movie picture/playback observations."""
from pathlib import Path
import json,hashlib,datetime,argparse
ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output',choices=('revision03','motion04'),default='motion04')
args=parser.parse_args()
REVIEW=ROOT/'shorts/review'/args.output
BASE=json.loads((ROOT/'shorts/review/upgrade02/MANIFEST.json').read_text())['entries']
observations=json.loads((REVIEW/'observations.json').read_text())
entries=[];rows=[]
for old in BASE:
 p=(ROOT/old['movie']).parent.parent;spec=p/'short.json';c=json.loads(spec.read_text());r=p/'review';view=observations[c['id']];revision=view.get('revision','r2');tag=f'{c["id"]}_{revision}_1080x1920';movie=p/'render'/f'{tag}.mp4'
 audio=json.loads((r/f'audio_{tag}.json').read_text());pace=json.loads((r/f'pacing_{tag}.json').read_text());export=json.loads((r/f'export_{tag}.json').read_text());view=observations[c['id']]
 assert audio['passed'] and pace['passed'] and view['pictureReviewed'] and view['playbackExercised']
 assert export['sha256']==hashlib.sha256(movie.read_bytes()).hexdigest()
 assert export['specSha256']==hashlib.sha256(spec.read_bytes()).hexdigest()
 body=sorted({q.get('bodyPose','neutral') for a in c['actors'] for q in a['cues']});transitions={}
 for shot in c['shots']:
  if 'transition' in shot:
   kind=shot['transition']['kind'];transitions[kind]=transitions.get(kind,0)+1
 entry={**old,'revision':revision,'movie':str(movie.relative_to(ROOT)),'movieSha256':export['sha256'],'specSha256':export['specSha256'],'frames':c['frames'],'duration':c['frames']/30,'shots':len(c['shots']),'wholeBodyPoses':body,'transitions':transitions,'events':len(c['events']),'sfxCount':len(c['sfx']),'music':c['music'],'maximumDecodedStaticSeconds':pace['maxStaticSeconds'],'audioCorrelation':audio['reconstructionCorrelation'],'truePeakDbTP':audio['loudness']['truePeakDbTP'],'observations':view['observations']}
 entries.append(entry)
 (r/'current.json').write_text(json.dumps({'revision':revision,'movie':entry['movie'],'movieSha256':entry['movieSha256'],'specSha256':entry['specSha256'],'technicalPassed':True,'visualReview':view['observations'],'playbackRecord':f'playback-{revision}.json'},indent=2)+'\n')
 (r/f'playback-{revision}.json').write_text(json.dumps(view,indent=2)+'\n')
 (r/'RENDERS.md').write_text(f'# Selected recut\n\n[{tag}.mp4](../render/{tag}.mp4) · {entry["duration"]:g}s,1080×1920,30fps,H.264/AAC.\n\n[Editable scene](../Edit.tscn) · [timing/poses](../short.json) · [direction](../DIRECTION.md) · [cue map](../CUE_MAP.json) · [QA](QA.md). Earlier r1 movie is retained in render/; its original source is in source-r1/ and its review records in r1/.\n')
 (r/'QA.md').write_text(f'# Recut review · {c["title"]}\n\nDistinct authored body profiles: {", ".join(body)}. Named transitions: {json.dumps(transitions)}. {len(c["sfx"])} selective recorded accents.\n\n{view["observations"]}\n\nEncoded {c["frames"]} frames at30fps,1080×1920. Source hashes/ranges and exact export frames pass. Longest decoded still {pace["maxStaticSeconds"]:.3f}s. Exact-source AAC correlation {audio["reconstructionCorrelation"]:.5f}; true peak {audio["loudness"]["truePeakDbTP"]:.2f}dBTP; all recorded SFX contributions verified. Picture observations, browser playback states and numerical sound checks are separate evidence. Audience retention has not been measured.\n\n[Export](export_{tag}.json) · [audio](audio_{tag}.json) · [pacing](pacing_{tag}.json) · [playback](playback-{revision}.json). Native proofs are in stills/{revision}/, decoded pose/transition/motion sheets are contact.jpg, transitions.jpg and motion.jpg. Original r1 source/records were saved before replacement.\n')
 cast='duo' if len(entry['cast'])==2 else entry['cast'][0]
 rows.append(f'| [{c["title"]}](../../{cast}/{c["id"]}/review/RENDERS.md) | {entry["duration"]:g}s | {len(body)} | {sum(transitions.values())} | {pace["maxStaticSeconds"]:.3f}s |')
(REVIEW/'MANIFEST.json').write_text(json.dumps({'version':3,'revision':args.output,'generatedAtUTC':datetime.datetime.now(datetime.timezone.utc).isoformat(),'entries':entries},indent=2)+'\n')
(REVIEW/'QA.md').write_text('# Eight camera and acting edits\n\n| Short | Duration | Body profiles | Pose transitions | Max decoded still |\n|---|---|---|---|---|\n'+'\n'.join(rows)+'\n\nAll native Godot source/export/audio/pacing checks passed. Actual pose, transition and within-shot motion sheets were visually inspected; each browser player was exercised at real speed and its cue controls checked. These records do not infer taste or audience results from movement measurements. Original storytime source/settings are covered separately by the isolation comparison. Camera path extrema and within-shot motion sheets are also inspected; engineering motion is not a creative score.\n')
(REVIEW/'README.md').write_text('# Ink with rhythm.\n\n[Watch eight recuts](index.html) · [checks](QA.md) · [reference pass](REFERENCE_PASS.md) · [direction](DIRECTION.md) · [skills](SKILLS.md) · [workflow](../../godot/V3_WORKFLOW.md).\n\nThe approved music recordings/start/gains and ink identity remain. Repeated closing poses were trimmed where the visual thought was already complete. Each edit now uses clearer whole-body stance drawings, authored eye/head/shoulder movement inside each pose, ongoing camera paths, selected recorded-attack impulses, outgoing/incoming pose transitions and event-linked recorded SFX/VFX. The direction emphasizes a readable opening situation, contrast/reversal and a cute visual payoff.\n\n'+'\n'.join(f'- [{x["title"]}](../../{("duo" if len(x["cast"])==2 else x["cast"][0])}/{x["id"]}/review/RENDERS.md) · {x["duration"]:g}s' for x in entries)+'\n\nCanonical source remains shorts/<cast>/<short>/; movies live in render/, evidence in review/. Previous r1 movies/source/review are retained. Music recording hashes and selected source ranges remain documented in each spec and cue map, plus the [recording catalog](../../assets/music/batch01/MUSIC_SOURCES.md). No audience-retention result is claimed before release data.\n')
print(f'Documented and selected {len(entries)} reviewed recuts.')
