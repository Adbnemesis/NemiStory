"""Use verified existing library/root files; reject procedural substitutes."""
import hashlib,json
from pathlib import Path

def validate_asset(asset,root):
    path=(root/asset['relative_path']).resolve()
    if not path.is_relative_to((root/'common/audio/sfx').resolve()) or not path.is_file():raise ValueError('SFX must exist in the shared vault')
    if any(x in asset.get('source','').lower() for x in ['procedural','synthesized','generated']):raise ValueError('Use existing root clips or library recordings, not procedural substitutes')
    if asset.get('origin')=='existing_root_mp3':
        inventory=json.loads((root/'common/audio/sfx/root_sfx_inventory.json').read_text())['assets']
        saved=next(a for a in inventory if a['id']==asset['id'])
        if path.parent!=(root/'common/audio/sfx').resolve() or path.suffix!='.mp3':raise ValueError('Root clip path changed')
        digest=hashlib.sha256(path.read_bytes()).hexdigest()
        if digest!=saved['sha256'] or digest!=asset['sha256'] or saved['relative_path']!=asset['relative_path']:raise ValueError('Existing root clip hash/path changed')
    elif not asset.get('commercial_use'):raise ValueError('Library SFX needs its recorded commercial-use provenance')
    return path
