#!/usr/bin/env python3
"""Package current static thumbnail deliveries; visual approval is a separate step."""
from pathlib import Path
import argparse
import hashlib
import html
import json
import shutil
import zipfile
from PIL import Image, ImageDraw


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', required=True, help='Project-relative package folder')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    manifest = json.loads((root/'tools/storytime/thumbnail_collection.json').read_text())
    out = root/args.output
    out.mkdir(parents=True, exist_ok=True)
    (out/'.gitignore').write_text('*\n!.gitignore\n')
    entries = []
    for item in manifest['episodes']:
        folder = Path(item['folder'])
        source = root/folder/'thumbnail/thumbnail.jpg'
        with Image.open(source) as im:
            im.load()
            assert im.size == (1920, 1080), source
        name = f'{item["author"].upper()}_{folder.name}.jpg'
        shutil.copy2(source, out/name)
        entries.append(dict(author=item['author'], episode=folder.name,
                            headline=item['headline'], file=name, source=str(source.relative_to(root)),
                            dimensions=[1920,1080], bytes=source.stat().st_size, sha256=digest(source)))
    for author in ['adb','nemi']:
        selected = [e for e in entries if e['author']==author]
        sheet = Image.new('RGB',(1280,((len(selected)+1)//2)*397),'#f5f0e5')
        draw = ImageDraw.Draw(sheet)
        for i, entry in enumerate(selected):
            with Image.open(out/entry['file']) as im:
                im = im.resize((640,360),Image.Resampling.LANCZOS)
            x,y = (i%2)*640,(i//2)*397
            draw.text((x+10,y+8),entry['episode'][:4].upper()+' | '+entry['headline'],fill='#24333c')
            sheet.paste(im,(x,y+30))
        sheet.save(out/f'{author.upper()}_overview.jpg',quality=94)
    for size,name in [((320,180),'phone_review.png'),((160,90),'tiny_review.png')]:
        w,h=size
        sheet=Image.new('RGB',(w*3,(h+28)*4),'#1b2530')
        draw=ImageDraw.Draw(sheet)
        for i,e in enumerate(entries):
            x,y=(i%3)*w,(i//3)*(h+28)
            draw.text((x+6,y+7),e['author'].upper()+' '+e['episode'][:4].upper(),fill='white')
            with Image.open(out/e['file']) as im: im=im.resize(size,Image.Resampling.LANCZOS)
            sheet.paste(im,(x,y+28))
        sheet.save(out/name)
    (out/'manifest.json').write_text(json.dumps(dict(date=manifest['date'],episodes=entries),indent=2)+'\n')
    (out/'README.md').write_text('# ADB + Nemi: episode-specific thumbnails\n\n'
        '12 current 1920×1080 JPGs, independently directed around their actual episodes. '
        'Open gallery.html to browse or choose the named JPG for upload. '
        'Canonical Godot animation rigs/props; one headline per thumbnail; no fixed channel background. '
        'Editable source and native 4K masters remain in the project. '
        'No platform upload or measured CTR result is implied.\n')
    cards=''.join(f'<article data-author="{e["author"]}"><a href="{e["file"]}"><img src="{e["file"]}" '
        f'alt="{html.escape(e["headline"],quote=True)}"></a><h2>{e["author"].upper()} {e["episode"][:4].upper()}</h2>'
        f'<p>{html.escape(e["headline"])}</p><a class="download" download href="{e["file"]}">Save thumbnail</a></article>' for e in entries)
    (out/'gallery.html').write_text('''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>ADB + Nemi: the story collection</title><style>*{box-sizing:border-box}body{margin:0;background:#f5f0e7;color:#24343e;font:16px system-ui;padding:32px;max-width:1600px;margin:auto}h1{font-size:32px;margin:0 0 8px}header p{color:#58616a}nav{display:flex;gap:10px;margin:24px 0}button,.download{background:#355f63;color:white;border:0;padding:11px 18px;border-radius:9px;font:inherit;cursor:pointer}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:22px}article{background:white;border-radius:14px;overflow:hidden;padding-bottom:22px;box-shadow:0 4px 18px #0001}img{width:100%;display:block;aspect-ratio:16/9}h2,p,.download{margin-left:20px;margin-right:20px}h2{font-size:17px;margin-bottom:6px}article p{margin-top:0;margin-bottom:22px}.download{display:inline-block;text-decoration:none}article[hidden]{display:none}</style><header><h1>Every thumbnail tells its own story</h1><p>12 episodes · One headline · Original animation art · Click for the full-size JPG.</p></header><nav><button onclick="filter('all')">All episodes</button><button onclick="filter('nemi')">Nemi</button><button onclick="filter('adb')">ADB</button></nav><main class="grid">'''+cards+'''</main><script>function filter(author){document.querySelectorAll('article').forEach(card=>card.hidden=author!=='all'&&card.dataset.author!==author)}</script></html>''')
    archive = out/'ADB_NEMI_episode_specific_thumbnails.zip'
    with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
        for name in [e['file'] for e in entries]+['gallery.html','README.md','manifest.json','ADB_overview.jpg','NEMI_overview.jpg']:
            z.write(out/name,name)
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        assert len([n for n in z.namelist() if n.endswith('.jpg') and not n.endswith('_overview.jpg')])==len(entries)
        for e in entries: assert hashlib.sha256(z.read(e['file'])).hexdigest()==e['sha256']
    print(f'Packaged {len(entries)} thumbnails; archive {archive.stat().st_size:,} bytes. Dimensions, hashes and ZIP verified.')


if __name__=='__main__': main()
