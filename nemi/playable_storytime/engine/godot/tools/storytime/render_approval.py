"""Numbered episode 4K requires actual user approval of the current full 1080p cut."""
import hashlib,json,re,subprocess
from pathlib import Path

def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def render_inputs_sha256(spec_path,root):
    """Bind approval to actual picture/voice inputs, including external rig direction."""
    root=Path(root).resolve();spec_path=Path(spec_path).resolve();spec=json.loads(spec_path.read_text());paths={spec_path}
    def media(value):
        if isinstance(value,dict):
            for x in value.values():media(x)
        elif isinstance(value,list):
            for x in value:media(x)
        elif isinstance(value,str) and value.startswith('res://'):
            p=(root/value[6:]).resolve()
            if p.is_relative_to(root) and p.is_file():paths.add(p)
    media(spec)
    folders=[root/'common/storytime/production',root/'common/engine/illustration',
             root/'common/engine/drawing',root/'common/assets/lettering']
    for author in {a['author'] for a in spec.get('actors',[])}:
        folders.append(root/author/'characters')
        # ADB's canonical face, hands, poses and mouth controls live outside
        # characters/. They affect the picture even when scene JSON is unchanged.
        if author=='adb':
            folders.extend(root/author/name for name in ['poses','expressions','hands','lipsync'])
        for name in [author+'.json',author+'_lettering.json']:
            p=root/'common/storytime/profiles'/name
            if p.is_file():paths.add(p)
    for folder in folders:
        if folder.exists():paths.update(p for p in folder.rglob('*') if p.suffix in ['.gd','.tscn','.json','.svg','.ttf'])
    for name in ['common/storytime/PerformancePlayer.gd','common/storytime/ProfileAssets.gd','common/storytime/StorytimeStage.gd','common/storytime/StorytimeStage.tscn','tools/storytime/render_stage.gd','tools/storytime/audio_mix.py','project.godot']:
        p=root/name
        if p.is_file():paths.add(p)
    h=hashlib.sha256()
    for p in sorted(paths):h.update(str(p.relative_to(root)).encode()+b'\0'+p.read_bytes()+b'\0')
    recipes=root/'common/storytime/performances/recipes.json'
    if recipes.is_file():
        data=json.loads(recipes.read_text())
        h.update(json.dumps({a:data[a] for a in sorted({x['author'] for x in spec.get('actors',[])})},sort_keys=True).encode())
    return h.hexdigest()

def require_1080p_approval(spec_path,root):
    spec_path=Path(spec_path).resolve();root=Path(root).resolve()
    if not (spec_path.parent.parent in [root/'nemi/episodes',root/'adb/episodes'] and re.fullmatch(r'ep\d{2,}_[a-z][a-z0-9_]{0,50}',spec_path.parent.name)):
        return  # Explicit technical studies are not numbered episode deliveries.
    receipt=spec_path.parent/'review/1080P_APPROVAL.json'
    if not receipt.is_file():raise ValueError('4K blocked: deliver the full current 1080p episode and obtain explicit user satisfaction first. No 1080P_APPROVAL.json exists.')
    data=json.loads(receipt.read_text())
    if data.get('approved_by')!='user' or data.get('approved') is not True or not isinstance(data.get('user_quote'),str) or not data['user_quote'].strip():
        raise ValueError('4K blocked: approval must record the actual user quote, never an agent or technical-check approval.')
    if data.get('spec_sha256')!=sha(spec_path):raise ValueError('4K blocked: scene changed after the approved 1080p cut; obtain fresh user satisfaction.')
    signature=render_inputs_sha256(spec_path,root)
    if data.get('render_inputs_sha256')!=signature:raise ValueError('4K blocked: picture/voice inputs changed or were not bound to the approved preview.')
    preview=data.get('preview','')
    if not isinstance(preview,str) or not preview.startswith('res://'):raise ValueError('4K approval needs the exact full 1080p preview resource.')
    path=(root/preview[6:]).resolve()
    if not path.is_relative_to(root) or not path.is_file() or path.suffix!='.mp4' or data.get('preview_sha256')!=sha(path):
        raise ValueError('4K blocked: approved preview is missing or changed.')
    stamp_uri=data.get('preview_stamp','')
    stamp=(root/stamp_uri[6:]).resolve() if isinstance(stamp_uri,str) and stamp_uri.startswith('res://') else root/'missing-review-stamp'
    if not stamp.is_relative_to(root) or not stamp.is_file():raise ValueError('4K blocked: missing actual full-preview render stamp.')
    rendered=json.loads(stamp.read_text())
    if rendered.get('render_inputs_sha256')!=signature or rendered.get('preview_sha256')!=sha(path):raise ValueError('4K blocked: preview was rendered with different picture/voice inputs.')
    probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_entries','stream=codec_type,width,height:format=duration','-of','json',str(path)]))
    video=next((s for s in probe['streams'] if s.get('codec_type')=='video'),{})
    duration=json.loads(spec_path.read_text())['duration']
    if (video.get('width'),video.get('height'))!=(1920,1080) or abs(float(probe['format']['duration'])-duration)>.08:
        raise ValueError('4K blocked: approval must refer to a full 1920×1080 preview of this episode, not a proof, excerpt or 4K file.')
