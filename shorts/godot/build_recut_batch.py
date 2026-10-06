"""Render/check the eight canonical recuts through their cast skill helpers."""
from pathlib import Path
import argparse,json,subprocess,sys
ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('action',choices=('stills','build'))
parser.add_argument('--revision',required=True)
parser.add_argument('--only',nargs='*',help='Optional exact short ids from the saved eight-edit manifest.')
args=parser.parse_args()
if not args.revision.isalnum():parser.error('Use an alphanumeric fresh revision.')
entries=json.loads((ROOT/'shorts/review/upgrade02/MANIFEST.json').read_text())['entries']
ids={e['id'] for e in entries}
if args.only and not set(args.only)<=ids:parser.error('Unknown short id.')
python=ROOT/'.venv/bin/python';executable=str(python) if python.exists() else sys.executable
for entry in entries:
 if args.only and entry['id'] not in args.only:continue
 cast='duo' if len(entry['cast'])==2 else entry['cast'][0]
 spec=ROOT/'shorts'/cast/entry['id']/'short.json'
 print(f'{args.action}: {cast}/{entry["id"]} {args.revision}',flush=True)
 subprocess.run([executable,str(ROOT/'.agents/skills'/f'{cast}-ink-shorts/scripts/build_short.py'),args.action,str(spec),'--revision',args.revision],cwd=ROOT,check=True)
print('Batch complete. Picture/playback review still requires actual inspection.',flush=True)
