#!/usr/bin/env python3
"""Shared episode reading gate. Records delivery/notes, never claims comprehension."""
import argparse
import hashlib
import json
import re
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[2]
MANIFEST='docs/animation/preflight/reading_manifest.json'
HISTORICAL='docs/animation/preflight/historical_specs.json'
CHUNK=6000

def digest(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def read_json(path): return json.loads(Path(path).read_text())
def save(path,data):
    path=Path(path)
    temp=path.with_suffix(path.suffix+'.tmp')
    temp.write_text(json.dumps(data,indent=2)+'\n');temp.replace(path)
def safe_folder(folder,root=ROOT):
    root=Path(root).resolve();folder=Path(folder).resolve()
    if not folder.is_relative_to(root) or any(folder.is_relative_to(root/p) for p in ['nemi/animations','adb/animations','.git','.agents','.codex']):
        raise ValueError('Use a separate new production folder inside the workspace, outside animations and configuration.')
    for author in ['nemi','adb']:
        episodes=root/author/'episodes'
        if folder.is_relative_to(episodes):
            relative=folder.relative_to(episodes)
            if len(relative.parts)!=1 or not re.fullmatch(r'ep[0-9]{2,}_[a-z][a-z0-9_]{0,50}',relative.name):
                raise ValueError('Use a separate new numbered episode folder: '+author+'/episodes/epNN_story_slug.')
    return folder

def requirements(authors,features,root=ROOT):
    manifest=read_json(root/MANIFEST)
    if not authors or set(authors)-set(manifest['characters']): raise ValueError('Choose nemi, adb, or both authors')
    if set(features)-set(manifest['features']): raise ValueError('Unknown preparation feature')
    docs=list(manifest['common'][:3])
    for author in sorted(set(authors)):docs+=manifest['characters'][author]
    docs+=manifest['common'][3:]
    for feature in sorted(set(features)):docs+=manifest['features'][feature]
    return list(dict.fromkeys(docs))

def detected_features(spec):
    result=[]
    if spec.get('props'):result.append('props')
    if spec.get('sfx'):result.append('sfx')
    if any(d.get('mode')=='live' for d in spec.get('drawings',[])):result.append('live_ink')
    return result

def initialize(folder,authors,features=None,root=ROOT):
    folder=safe_folder(folder,root)
    features=features if features is not None else ['props','sfx','live_ink']
    requirements(authors,features,root)
    path=folder/'preflight.json'
    if path.exists(): raise ValueError('Preparation already exists. Use status/read/ack, not init.')
    folder.mkdir(parents=True,exist_ok=True)
    data={'version':1,'folder':str(folder.relative_to(root)),'authors':sorted(set(authors)),
          'features':sorted(set(features)),'documents':{}}
    save(path,data);return data

def load(folder,root=ROOT):
    folder=safe_folder(folder,root);path=folder/'preflight.json'
    if not path.is_file():raise ValueError('Missing preflight.json. Run preflight.py init --folder <scene-folder> --authors nemi (or adb / nemi adb).')
    data=read_json(path)
    if data.get('version')!=1 or data.get('folder')!=str(folder.relative_to(root)) or not isinstance(data.get('documents'),dict):
        raise ValueError('Invalid or copied preparation record; initialize this production separately.')
    requirements(data['authors'],data['features'],root)
    return folder,path,data

def document_chunks(path):
    text=Path(path).read_text()
    return [text[i:i+CHUNK] for i in range(0,len(text),CHUNK)] or ['']

def deliver(folder,document,part=1,root=ROOT):
    folder,path,data=load(folder,root)
    if document not in requirements(data['authors'],data['features'],root):raise ValueError('Document is not in this character/feature reading list. Use status.')
    chunks=document_chunks(root/document);sha=digest(root/document)
    if not 1<=part<=len(chunks):raise ValueError(f'Choose part 1..{len(chunks)}')
    record=data['documents'].get(document,{})
    if record.get('sha256')!=sha:record={'sha256':sha,'parts':[],'note':''}
    record['parts']=sorted(set(record['parts']+[part]));data['documents'][document]=record;save(path,data)
    return f"DOCUMENT {document} | part {part}/{len(chunks)} | sha256 {sha}\n\n{chunks[part-1]}\n\nEND PART {part}/{len(chunks)}. Read every part, then acknowledge with an episode-specific application note."

def acknowledge(folder,document,note,root=ROOT):
    folder,path,data=load(folder,root)
    if document not in requirements(data['authors'],data['features'],root):raise ValueError('Unknown required document')
    record=data['documents'].get(document,{})
    if record.get('sha256')!=digest(root/document) or record.get('parts')!=list(range(1,len(document_chunks(root/document))+1)):
        raise ValueError('Read all current parts before acknowledging this document.')
    if not isinstance(note,str) or len(note.strip())<30 or note.strip().lower() in {'todo','read','done'}:
        raise ValueError('Write a concrete application note (at least 30 characters), not a checkmark.')
    record['note']=note.strip();save(path,data)

def missing(folder,root=ROOT,authors=None,features=None):
    folder,path,data=load(folder,root)
    authors=sorted(set(data['authors'])|set(authors or []));features=sorted(set(data['features'])|set(features or []))
    problems=[]
    for doc in requirements(authors,features,root):
        record=data['documents'].get(doc,{})
        chunks=document_chunks(root/doc)
        if record.get('sha256')!=digest(root/doc):problems.append(f'{doc}: not read or changed; read parts 1..{len(chunks)}')
        elif record.get('parts')!=list(range(1,len(chunks)+1)):problems.append(f'{doc}: missing parts of 1..{len(chunks)}')
        elif len(record.get('note','').strip())<30:problems.append(f'{doc}: application note missing')
    return problems

def enforce(spec_path,spec,root=ROOT):
    if not isinstance(spec,dict):raise ValueError('Scene must be a JSON object')
    if spec.get('version')!=2:return
    path=Path(spec_path).resolve();root=Path(root).resolve()
    if not path.is_relative_to(root):raise ValueError('New storytime specs must be inside the workspace')
    relative=str(path.relative_to(root));historical=read_json(root/HISTORICAL)
    if historical.get(relative)==digest(path):return
    authors=sorted({a['author'] for a in spec['actors']})
    _,_,data=load(path.parent,root)
    if set(authors)-set(data['authors']):raise ValueError('Character added to scene. Run preflight.py extend --folder <folder> --authors nemi adb, then read the added documents.')
    needed=detected_features(spec)
    if set(needed)-set(data['features']):raise ValueError('Scene uses additional features. Extend preparation with --features '+ ' '.join(sorted(set(needed)|set(data['features']))))
    problems=missing(path.parent,root,authors,needed)
    if problems:raise ValueError('Episode preparation incomplete/stale:\n'+'\n'.join(problems)+'\nRun preflight.py status/read/ack for this scene folder.')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    sub=parser.add_subparsers(dest='command',required=True)
    for cmd in ['init','status','read','ack','extend']:
        p=sub.add_parser(cmd);p.add_argument('--folder',type=Path,required=True)
        if cmd in {'init','extend'}:
            p.add_argument('--authors',nargs='+',choices=['nemi','adb'],required=cmd=='init')
            p.add_argument('--features',nargs='*',choices=['props','sfx','live_ink'],default=None)
        if cmd in {'read','ack'}:p.add_argument('--document',required=True)
        if cmd=='read':p.add_argument('--part',type=int,default=1)
        if cmd=='ack':p.add_argument('--note',required=True)
    args=parser.parse_args()
    try:
        if args.command=='init':initialize(args.folder,args.authors,args.features)
        elif args.command=='read':print(deliver(args.folder,args.document,args.part));return
        elif args.command=='ack':acknowledge(args.folder,args.document,args.note)
        elif args.command=='extend':
            folder,path,data=load(args.folder)
            data['authors']=sorted(set(data['authors'])|set(args.authors or []));data['features']=sorted(set(data['features'])|set(args.features or []));save(path,data)
        folder,path,data=load(args.folder)
        print(read_json(ROOT/MANIFEST)['precedence'])
        print('Authors:',', '.join(data['authors']),'| Features:',', '.join(data['features']))
        problems=missing(folder)
        print('\n'.join(problems) if problems else 'READY: required current documents delivered and application notes recorded. This is not an artistic approval.')
        if args.command=='status' and problems:raise SystemExit(1)
    except (ValueError,KeyError,TypeError,OSError) as error:parser.exit(1,str(error)+'\n')

if __name__=='__main__':main()
