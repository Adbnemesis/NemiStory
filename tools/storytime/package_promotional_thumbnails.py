#!/usr/bin/env python3
"""Package native Godot promotional art and titles; never predicts performance."""
from pathlib import Path
import hashlib
import html
import json
import shutil
import textwrap
import zipfile
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'renders/thumbnail_promotional_2026-10-06'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    manifest = json.loads((ROOT / 'tools/storytime/thumbnail_promotional_2026-10-06.json').read_text())
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / '.gitignore').write_text('*\n!.gitignore\n')
    font_path = '/System/Library/Fonts/Supplemental/Arial.ttf'
    title_font = ImageFont.truetype(font_path, 17)
    label_font = ImageFont.truetype(font_path, 13)
    entries = []
    for item in manifest['variants']:
        source = ROOT / item['layout']
        layout = json.loads(source.read_text())
        image = source.parent / 'thumbnail.jpg'
        with Image.open(image) as im:
            im.load()
            assert im.size == (1920, 1080), image
        name = f'{item["author"].upper()}_{item["slug"]}_{item["variant"].upper()}.jpg'
        shutil.copy2(image, OUT / name)
        shutil.copy2(source.parent / 'scene_without_text.png', OUT / name.replace('.jpg', '_art.png'))
        entries.append(dict(author=item['author'], story=item['slug'], variant=item['variant'],
                            title=layout['title'], headline=layout['thumbnail_phrase'],
                            file=name, source=str(image.relative_to(ROOT)),
                            sha256=sha(image), dimensions=[1920, 1080], revision=layout['revision']))
    (OUT / 'manifest.json').write_text(json.dumps({'date':manifest['date'], 'status':'Creative candidates; no live test/result', 'variants':entries}, indent=2)+'\n')
    titles = '# Original promotional thumbnail/title pairs\n\n6 creative candidates, drawn in Godot. All titles are proposed, not confirmed current uploads.\n\n'
    for e in entries:
        titles += f'## {e["author"].upper()} {e["story"]} — {e["variant"].upper()}\n\nTitle: **{e["title"]}**\n\nThumbnail: **{e["headline"]}**\n\nImage: `{e["file"]}`\n\n'
    (OUT / 'TITLES.md').write_text(titles)
    for mode, background, text in [('light','#faf4e8','#333440'),('dark','#181a22','#f8f0e4')]:
        for width in [320,160]:
            height = width*9//16
            row_height = height+95 if width==320 else height+72
            sheet = Image.new('RGB',(width*2,row_height*3),background)
            draw = ImageDraw.Draw(sheet)
            font = title_font if width==320 else label_font
            for i,e in enumerate(entries):
                x,y=(i%2)*width,(i//2)*row_height
                with Image.open(OUT/e['file']) as im: thumb=im.resize((width,height),Image.Resampling.LANCZOS)
                td=ImageDraw.Draw(thumb)
                badge_w=42 if width==320 else 31
                td.rounded_rectangle((width-badge_w-5,height-23,width-5,height-5),radius=3,fill='#17171d')
                td.text((width-badge_w,height-21),'2:00',font=ImageFont.truetype(font_path,11 if width==320 else 9),fill='white')
                sheet.paste(thumb,(x,y))
                draw.text((x+8,y+height+7),f'{e["author"].upper()} {e["story"]} · {e["variant"].upper()}',font=label_font,fill='#777b83')
                for j,line in enumerate(textwrap.wrap(e['title'],width=33 if width==320 else 21)[:3]):
                    draw.text((x+8,y+height+26+j*(21 if width==320 else 14)),line,font=font,fill=text)
            sheet.save(OUT/f'feed_{mode}_{width}.png')
    overview=Image.new('RGB',(1280,3*386),'#f8f0e2')
    od=ImageDraw.Draw(overview)
    for i,e in enumerate(entries):
        x,y=(i%2)*640,(i//2)*386
        od.text((x+10,y+6),f'{e["author"].upper()} {e["story"]} · {e["variant"].upper()}',font=title_font,fill='#353541')
        with Image.open(OUT/e['file']) as im: overview.paste(im.resize((640,360),Image.Resampling.LANCZOS),(x,y+26))
    overview.save(OUT/'overview.jpg',quality=95)
    cards=''.join(f'<article data-story="{e["story"]}"><a href="{e["file"]}"><img class="art" src="{e["file"]}" alt="{html.escape(e["headline"],quote=True)}"></a><div class="copy"><small>{e["author"].upper()} · {e["story"].title()} · {e["variant"].upper()}</small><h2>{html.escape(e["title"])}</h2><a download href="{e["file"]}">Save thumbnail</a><a href="{e["file"].replace(".jpg","_art.png")}">Art without text</a></div></article>' for e in entries)
    (OUT/'gallery.html').write_text('''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>ADB + Nemi · Original cover art</title><style>*{box-sizing:border-box}body{--paper:#faf4e8;--card:#fffdf8;--ink:#363344;margin:0;background:var(--paper);color:var(--ink);font:16px system-ui;transition:background .2s}body.dark{--paper:#191b23;--card:#252730;--ink:#f8f1e4}main,header{max-width:1400px;margin:auto;padding:28px}header{padding-top:44px}h1{font-size:clamp(30px,4vw,49px);letter-spacing:-1.5px;margin:0 0 12px}header p{max-width:700px;line-height:1.6;opacity:.75}nav{display:flex;flex-wrap:wrap;gap:9px;margin-top:24px}button{border:1px solid #9b83944d;background:var(--card);color:var(--ink);padding:11px 17px;border-radius:24px;font:inherit;cursor:pointer}button[aria-pressed=true]{background:#713d5a;color:#fff}main{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:24px;padding-top:0}article{background:var(--card);border-radius:15px;overflow:hidden;box-shadow:0 8px 30px #2923330b}.art{display:block;width:100%;aspect-ratio:16/9}.copy{padding:18px 22px 24px}small{opacity:.6}h2{font-size:20px;line-height:1.35;margin:8px 0 20px}.copy a{font-size:14px;color:var(--ink);display:inline-block;margin-right:22px;text-underline-offset:4px}.phone main{grid-template-columns:repeat(2,320px);justify-content:center}.phone h2{font-size:16px}@media(max-width:750px){main,.phone main{grid-template-columns:1fr}.phone article{max-width:320px;margin:auto}header,main{padding-left:16px;padding-right:16px}}</style><header><h1>Original cover art for our stories</h1><p>Six newly illustrated concepts, each paired with its proposed video title. Browse full-size or compare at phone size.</p><nav><button aria-pressed="true" onclick="filter('all',this)">All six</button><button aria-pressed="false" onclick="filter('crush',this)">Crush</button><button aria-pressed="false" onclick="filter('kitchen',this)">Kitchen</button><button aria-pressed="false" onclick="filter('taxi',this)">Taxi</button><button onclick="document.body.classList.toggle('dark')">Light / dark</button><button onclick="document.body.classList.toggle('phone')">Phone size</button></nav></header><main>'''+cards+'''</main><script>function filter(story,button){document.querySelectorAll('article').forEach(card=>card.hidden=story!=='all'&&card.dataset.story!==story);document.querySelectorAll('button[aria-pressed]').forEach(b=>b.setAttribute('aria-pressed',b===button))}</script></html>''')
    (OUT/'README.md').write_text('# ADB + Nemi original promotional thumbnails\n\nSix 1920×1080 upload JPGs and paired proposed titles. Open gallery.html to compare, or read TITLES.md. Canonical main-character Godot art with newly authored supporting illustration; no image-generation service. Editable source and native 4K masters remain in the episode thumbnail/promotional folders. These candidates have no measured performance result or platform upload. Earlier deliveries and rejected literal pilots are preserved.\n')
    archive=OUT/'ADB_NEMI_original_promotional_thumbnails.zip'
    with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
        for name in [e['file'] for e in entries]+[e['file'].replace('.jpg','_art.png') for e in entries]+['TITLES.md','README.md','manifest.json','gallery.html','overview.jpg']:
            z.write(OUT/name,name)
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for e in entries: assert hashlib.sha256(z.read(e['file'])).hexdigest()==e['sha256']
    print(f'Packaged 6 original cover JPGs/titles. ZIP {archive.stat().st_size:,} bytes; image dimensions, hashes and CRC checked.')


if __name__=='__main__': main()
