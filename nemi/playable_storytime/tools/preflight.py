#!/usr/bin/env python3
"""Run the unchanged shared reading gate against isolated, frozen manuals."""
import argparse,importlib.util,json,shutil
from pathlib import Path
from bootstrap import PROJECT,GODOT,bootstrap
def main():
    p=argparse.ArgumentParser();p.add_argument('action',choices=['init','status','read','ack']);p.add_argument('--episode',default='episode_001');p.add_argument('--document');p.add_argument('--part',type=int,default=1);p.add_argument('--note');a=p.parse_args()
    episode=(PROJECT/'episodes'/a.episode).resolve()
    if episode.parent!=PROJECT/'episodes' or not episode.is_dir():p.error('Choose an existing isolated episode folder.')
    bootstrap()
    spec=importlib.util.spec_from_file_location('frozen_preflight',GODOT/'tools/storytime/preflight.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    frozen=GODOT/'nemi/playable_storytime/episodes'/a.episode;frozen.mkdir(parents=True,exist_ok=True)
    receipt=episode/'preflight.json';mirror=frozen/'preflight.json'
    if receipt.exists():shutil.copy2(receipt,mirror)
    if a.action=='init':module.initialize(frozen,['nemi'],root=GODOT);print('New reading record initialized; authoring remains pending until all current documents are read and acknowledged.')
    elif a.action=='read':print(module.deliver(frozen,a.document,a.part,root=GODOT))
    elif a.action=='ack':module.acknowledge(frozen,a.document,a.note,root=GODOT);print('Saved episode-specific application note.')
    else:
        missing=module.missing(frozen,root=GODOT);print(json.dumps({'ready':not missing,'missing':missing},indent=2))
    if mirror.exists():shutil.copy2(mirror,receipt)
if __name__=='__main__':main()
