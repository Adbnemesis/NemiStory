#!/usr/bin/env python3
"""External layered video edit. Godot is used only for the input character plates.

Picture and sound are independent editable tracks; evaluate the final picture on
the 30 fps edit clock and mux the separately reviewed audio. No rig or episode
stage code is invoked by this compositor.
"""
import argparse
import functools
import hashlib
import json
import math
from pathlib import Path
import subprocess

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / 'renders/message_to_storytime_rebuild'
PLATES = ASSETS / 'character_plates'
W, H, FPS = 1920, 1080, 30
RASTER_SCALE = 1
NATIVE_PLATES = ASSETS / 'character_plates_4k'
SERIF = '/System/Library/Fonts/Supplemental/Times New Roman.ttf'
SANS = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
CUTS = [0, 76, 117, 145, 192, 228, 290, 430, 459, 486, 498, 510, 540, 566, 663, 750]
POSES = {1:'direct_confident',2:'lean_smug',3:'wide_bravado',4:'challenge_point',
         5:'self_presentation',6:'dry_payoff',7:'clutch_sketchbook',8:'hoist_trophy',
         9:'chin_thought',10:'proud_behind_back'}

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def aac_sha(path):
    payload=subprocess.check_output(['ffmpeg','-v','error','-i',str(path),'-map','0:a:0','-c:a','copy','-f','adts','-'])
    return hashlib.sha256(payload).hexdigest()

def approved_audio(folder,approved):
    """Retain an honest approval trail even after authorized movie cleanup."""
    preview=ROOT/approved['preview']
    if preview.exists():
        assert sha(preview)==approved['preview_sha256'],'Approved full1080p preview changed.'
    else:
        cleanup=folder/'review/edit_4k/CLEANUP_FINAL_4K.json'
        record=json.loads(cleanup.read_text())
        assert record['replacement_qa_passed'],'Approved preview may be absent only after verified replacement cleanup.'
        assert any(item['file']==approved['preview'] and item['sha256']==approved['preview_sha256'] for item in record['deleted_movies']),'The exact approved preview is not documented in episode cleanup.'
        qa=ROOT/record['replacement_qa']
        assert sha(qa)==record['replacement_qa_sha256'],'Replacement QA receipt changed after cleanup.'
    archive=ROOT/approved['approved_audio_archive']
    assert sha(archive)==approved['approved_audio_archive_sha256'],'Archived approved audio changed.'
    assert aac_sha(archive)==approved['approved_aac_adts_sha256'],'Approved AAC payload changed.'
    if preview.exists():assert aac_sha(preview)==approved['approved_aac_adts_sha256'],'Audio archive differs from approved preview.'
    return archive

@functools.lru_cache(maxsize=48)
def plate(author, pose, mouth='closed', hands=False):
    stem=f'{pose:02d}_{POSES[pose]}'
    folder=NATIVE_PLATES if RASTER_SCALE==2 else PLATES
    file=folder/author/(stem+('_hands.png' if hands else f'_{mouth}.png'))
    image=Image.open(file).convert('RGBA')
    image.info['logical_density']=2 if RASTER_SCALE==2 else 1
    return image

@functools.lru_cache(maxsize=1)
def anchors():
    return json.loads((PLATES/'anchors.json').read_text())['authors']

def anchor(author,pose,key):
    return anchors()[author][f'{pose:02d}_{POSES[pose]}'][key]

@functools.lru_cache(maxsize=2)
def room():
    return Image.open(ASSETS/'assets/studio_background.png').convert('RGBA').resize((W*RASTER_SCALE,H*RASTER_SCALE),Image.Resampling.LANCZOS)

@functools.lru_cache(maxsize=1)
def bright():
    y=np.linspace(0,1,H*RASTER_SCALE)[:,None,None]
    top=np.array([249,251,252.0])[None,None,:]
    bottom=np.array([222,230,234.0])[None,None,:]
    arr=np.broadcast_to(top*(1-y)+bottom*y,(H*RASTER_SCALE,W*RASTER_SCALE,3)).astype('uint8').copy()
    return Image.fromarray(arr).convert('RGBA')

def text_image(text, font_file, size, color, stroke=0):
    density=RASTER_SCALE
    font=ImageFont.truetype(font_file,size*density)
    box=font.getbbox(text,stroke_width=stroke*density)
    im=Image.new('RGBA',(box[2]-box[0]+8*density,box[3]-box[1]+8*density))
    ImageDraw.Draw(im).text((4*density-box[0],4*density-box[1]),text,font=font,fill=color,
                           stroke_width=stroke*density,stroke_fill='#310000')
    return im

@functools.lru_cache(maxsize=80)
def headline(text):
    im=text_image(text,SERIF,580,'#ed0000')
    width=min(1910*RASTER_SCALE,round(im.width*.78))
    return im.resize((width,im.height),Image.Resampling.LANCZOS)

@functools.lru_cache(maxsize=12)
def intro_caption(text):
    density=RASTER_SCALE
    font=ImageFont.truetype(SANS,110*density)
    lines=['']
    for word in text.split():
        candidate=(lines[-1]+' '+word).strip()
        if font.getlength(candidate)>1700*density and lines[-1]:lines.append(word)
        else:lines[-1]=candidate
    image=Image.new('RGBA',(W*density,310*density));d=ImageDraw.Draw(image)
    for i,line in enumerate(lines):
        length=font.getlength(line)
        d.text(((W*density-length)/2,(3+i*114)*density),line,font=font,fill='#ef0000',stroke_width=4*density,stroke_fill='#360000')
    return image

def composite_at(canvas, source, scale, origin, shadow=False, room_grade=False):
    source_density=source.info.get('logical_density',1)
    factor=scale*RASTER_SCALE/source_density
    image=source.resize((round(source.width*factor),round(source.height*factor)),Image.Resampling.LANCZOS)
    if room_grade:
        a=image.getchannel('A')
        rgb=ImageEnhance.Brightness(image.convert('RGB')).enhance(.83)
        image=rgb.convert('RGBA');image.putalpha(a)
    x,y=(round(value*RASTER_SCALE) for value in origin)
    if shadow:
        matte=Image.new('RGBA',image.size,(8,13,18,0))
        matte.putalpha(image.getchannel('A').point(lambda v:round(v*.22)).filter(ImageFilter.GaussianBlur(7*RASTER_SCALE)))
        canvas.alpha_composite(matte,(x+8*RASTER_SCALE,y+9*RASTER_SCALE))
    canvas.alpha_composite(image,(x,y))

def transform(author,pose,scale,head_y,center_x=960):
    # Head reference from the original direct plate. Keep actor scale and source
    # coordinate space stable; pose-specific gaze/lean remains authored movement.
    raw_y=287 if author=='nemi' else 162
    return scale,(center_x-1000*scale,head_y-raw_y*scale)

@functools.lru_cache(maxsize=2)
def edit_timeline(author):
    ep='ep17_message_to_storytime_animators' if author=='nemi' else 'ep08_message_to_storytime_animators'
    return json.loads((ROOT/author/'episodes'/ep/'edit_rebuild/picture_timeline.json').read_text())

@functools.lru_cache(maxsize=4)
def book_art(author,width,height):
    """A finished sketchbook prop, not a new character/ink player."""
    # Draw the same logical paths directly at output density, not a book upscale.
    density=RASTER_SCALE
    im=Image.new('RGBA',((width+35)*density,(height+35)*density));d=ScaledDraw(im,density)
    d.polygon([(14,15),(width,0),(width+25,height-12),(33,height+20)],fill='#66534b',outline='#342e31',width=5)
    d.polygon([(25,9),(width-9,2),(width+11,height-21),(39,height+6)],fill='#d9c4a5',outline='#40393b',width=4)
    d.polygon([(38,21),(width-24,15),(width-5,height-35),(49,height-9)],fill='#fffaf0',outline='#675e60',width=3)
    ink='#704956' if author=='nemi' else '#48515b'
    for yy in range(40,height-18,40):
        d.ellipse((19,yy,52,yy+16),outline='#353235',width=4)
    margin=70; cw=(width-margin-40)//2; ch=(height-110)//2
    for row in range(2):
        for col in range(2):
            x=margin+col*cw;y=48+row*ch
            d.rectangle((x,y,x+cw-15,y+ch-18),outline=ink,width=3)
            cx=x+(cw-15)//2;cy=y+ch//3
            d.ellipse((cx-20,cy-23,cx+20,cy+23),outline=ink,width=4)
            d.line((cx,cy+23,cx,cy+70),fill=ink,width=4)
            d.line((cx-28,cy+45,cx+28,cy+45),fill=ink,width=4)
            d.line((cx,cy+70,cx-25,cy+95),fill=ink,width=4)
            d.line((cx,cy+70,cx+25,cy+95),fill=ink,width=4)
            d.ellipse((x+cw-67,y+15,x+cw-24,y+41),outline=ink,width=3)
    im.info['logical_density']=density
    return im

class ScaledDraw:
    """Preserve the approved logical geometry with high-resolution raster edges."""
    def __init__(self,image,density):
        self.draw=ImageDraw.Draw(image);self.density=density
    def _coords(self,points):
        if points and isinstance(points[0],(tuple,list)):
            return [(x*self.density,y*self.density) for x,y in points]
        return tuple(value*self.density for value in points)
    def __getattr__(self,name):
        method=getattr(self.draw,name)
        def scaled(points,*args,**kwargs):
            if 'width' in kwargs:kwargs['width']*=self.density
            return method(self._coords(points),*args,**kwargs)
        return scaled

def add_book(canvas,author,pose,scale,origin,huge=False,detail=False):
    left=anchor(author,pose,'left_palm');right=anchor(author,pose,'right_palm')
    cx=(left[0]+right[0])/2;py=(left[1]+right[1])/2
    width=1100 if huge else round(abs(right[0]-left[0])+65)
    height=750 if huge else round(width*1.20)
    raw_left=cx-width/2;raw_top=py-height+18 if huge else py-height*.58
    image=book_art(author,width,height)
    composite_at(canvas,image,scale,(origin[0]+raw_left*scale,origin[1]+raw_top*scale),shadow=True)
    # Real captured hands sit in front of the book, preserving the grip.
    composite_at(canvas,plate(author,pose,hands=True),scale,origin)

def desk_overlay(canvas,author,scale,origin):
    left=anchor(author,2,'left_palm');right=anchor(author,2,'right_palm')
    py=(left[1]+right[1])/2
    y=round(origin[1]+py*scale+27)
    layer=Image.new('RGBA',(W*RASTER_SCALE,H*RASTER_SCALE));d=ScaledDraw(layer,RASTER_SCALE)
    d.polygon([(0,y+35),(W,y),(W,H),(0,H)],fill='#806047',outline='#382f2e',width=4)
    d.polygon([(0,y),(W,y-35),(W,y),(0,y+35)],fill='#c7a071',outline='#443932',width=4)
    d.polygon([(1150,y-120),(1710,y-130),(1800,y-20),(1240,y-10)],fill='#faf5e8',outline='#61585a',width=4)
    d.line((1250,y-85,1645,y-92),fill='#af9a96',width=3)
    d.line((1280,y-55,1600,y-62),fill='#af9a96',width=3)
    d.line((1680,y-130,1770,y-20),fill='#3b4852',width=15)
    canvas.alpha_composite(layer)

@functools.lru_cache(maxsize=48)
def character_layer(author,shot,late=False,motion_index=None):
    layer=Image.new('RGBA',(W*RASTER_SCALE,H*RASTER_SCALE))
    authored=edit_timeline(author)['shots'][shot]
    if shot in [0,2,4,6,13]:
        pose=6 if late else authored.get('pose',1)
        s,xy=transform(author,pose,authored.get('scale',.80),authored.get('head_y',342))
        composite_at(layer,plate(author,pose),s,xy,shadow=True,room_grade=True)
        return layer
    if shot==1:
        pose=9;s,xy=transform(author,pose,1.17,100)
    elif shot==3:
        pose=2;s,xy=transform(author,pose,1.38,110)
    elif shot==5:
        pose=3;s,xy=transform(author,pose,.93,95)
    elif shot==7:
        pose=2;s,xy=transform(author,pose,.90,120)
    elif shot in [8,9]:
        pose=7
        if shot==8:s,xy=transform(author,pose,1.03,50)
        else:
            palm=anchor(author,pose,'left_palm');s=1.80
            xy=(960-1000*s,550-palm[1]*s)
    elif shot==10:
        pose=8;s,xy=transform(author,pose,.50,350)
    elif shot==11:
        pose=1;s,xy=transform(author,pose,1.00,105)
    else:
        pose=9;s,xy=transform(author,pose,1.15,95)
    if 'scale' in authored and shot!=9:
        pose=authored.get('pose',pose)
        s,xy=transform(author,pose,authored['scale'],authored['head_y'],authored.get('center_x',960))
    source=plate(author,pose)
    if motion_index is not None:
        source=Image.open(PLATES/author/'motion_01_to_03'/f'{motion_index:03d}.png').convert('RGBA')
    composite_at(layer,source,s,xy,shadow=True)
    if shot==7:desk_overlay(layer,author,s,xy)
    if shot in [8,9,10]:add_book(layer,author,pose,s,xy,huge=shot==10,detail=shot==9)
    return layer

def load_words(author):
    voice='audio' if author=='nemi' else 'voice'
    ep='ep17_message_to_storytime_animators' if author=='nemi' else 'ep08_message_to_storytime_animators'
    folder=ROOT/author/'episodes'/ep
    path=folder/voice/'edit_r8/final_words.json'
    data=json.loads(path.read_text())
    return folder,data.get('words',data),path

def clean(word):return word.strip(' .,!?').upper()

def word_at(words,t):
    candidates=[w for w in words if w['start']<=t]
    return candidates[-1] if candidates else None

def picture(author,frame,words):
    t=frame/FPS
    shot=next(i for i,s in enumerate(edit_timeline(author)['shots']) if s['start_frame']<=frame<s['end_frame'])
    if frame>=663:return Image.new('RGB',(W*RASTER_SCALE,H*RASTER_SCALE))
    master=shot in [0,2,4,6,13]
    image=(room() if master else bright()).copy()
    if shot in [2,4,6]:
        word=word_at(words,t)
        if word:
            text=clean(word['word'])
            if shot==2 and author=='adb' and text in {'A','D','B'}:text='ADB'
            label=headline(text)
            image.alpha_composite(label,((W*RASTER_SCALE-label.width)//2,27*RASTER_SCALE))
    late=shot==13 and t>(20.18 if author=='nemi' else 20.48)
    # The reference cuts directly to committed open arms, then holds the pose.
    image.alpha_composite(character_layer(author,shot,late))
    # A single short dissolve resolves the giant-prop gag, as observed in source.
    if shot==11 and frame<514:
        old=bright().copy();old.alpha_composite(character_layer(author,10))
        image=Image.blend(old,image,(frame-510+1)/4)
    if shot==0:
        visible=[w['word'].strip() for w in words if w['start']<=t and w['start']<2.5]
        if visible:image.alpha_composite(intro_caption(' '.join(visible)),(0,730*RASTER_SCALE))
    return image.convert('RGB')

def main():
    global RASTER_SCALE
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--author',choices=['nemi','adb'],required=True)
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--duration',type=float,default=25)
    p.add_argument('--start',type=float,default=0)
    p.add_argument('--stills',action='store_true')
    p.add_argument('--4k',dest='is_4k',action='store_true',help='Approved external edit: native2x typography/props/character captures, original raster background scaled.')
    args=p.parse_args();folder,words,timing=load_words(args.author)
    assert 0<=args.start<25 and 0<args.duration<=25-args.start
    assert abs(round(args.duration*FPS)-args.duration*FPS)<1e-6 and abs(round(args.start*FPS)-args.start*FPS)<1e-6
    out=args.output.resolve();assert not out.exists(),'Preserve earlier edits; use a new revision name.'
    out.parent.mkdir(parents=True,exist_ok=True)
    mix=folder/('audio' if args.author=='nemi' else 'voice')/'edit_r8/mix_r8.wav'
    assert mix.is_file(),'Final separately authored sound track is required.'
    approval_path=None;approved=None;audio_source=mix
    if args.is_4k:
        assert args.start==0 and args.duration==25,'The approved4K delivery is the complete25-second cut.'
        assert out.parent==folder/'renders','Save the final4K movie in the matching episode renders folder.'
        approval_path=folder/'review/edit_4k/1080P_EXTERNAL_EDIT_APPROVAL.json'
        approved=json.loads(approval_path.read_text())
        assert approved.get('approved') and approved.get('approved_by')=='user' and approved.get('user_quote'),'An actual user approval receipt is required.'
        audio_source=approved_audio(folder,approved)
        assert sha(ROOT/approved['preview_receipt'])==approved['preview_receipt_sha256'],'Approved input receipt changed.'
        assert sha(ROOT/approved['approved_compositor_snapshot'])==approved['approved_compositor_sha256'],'Approved compositor snapshot changed.'
        for path,digest in approved['approved_inputs'].items():
            if path=='tools/edits/storytime_message_edit.py':continue
            assert sha(ROOT/path)==digest,f'Approved picture/audio input changed: {path}'
        assert NATIVE_PLATES.is_dir(),'Capture the same registered canonical plates at2x first.'
        RASTER_SCALE=2
    command=['ffmpeg','-hide_banner','-loglevel','error','-f','rawvideo','-pixel_format','rgb24','-video_size',f'{W*RASTER_SCALE}x{H*RASTER_SCALE}','-framerate','30','-i','pipe:0']
    # Even '-ss 0' can discard an AAC priming packet from an audio-only MP4.
    # The4K delivery is a full-cut copy and must retain every approved packet.
    if not args.is_4k:command+=['-ss',str(args.start)]
    command+=['-i',str(audio_source),'-map','0:v:0','-map','1:a:0','-t',str(args.duration),'-c:v','libx264','-preset','fast','-crf','16' if args.is_4k else '17','-pix_fmt','yuv420p']
    command+=['-c:a','copy'] if args.is_4k else ['-c:a','aac','-b:a','256k']
    # A clean intra frame prevents tiny inter-prediction residues from the
    # preceding picture leaking into the authored all-black final87 frames.
    if args.is_4k:command+=['-force_key_frames','22.1']
    command+=['-movflags','+faststart',str(out)]
    process=subprocess.Popen(command,stdin=subprocess.PIPE)
    for f in range(round(args.start*FPS),round((args.start+args.duration)*FPS)):
        im=picture(args.author,f,words)
        if args.stills and (f%30==0 or f in [116,117,144,145,191,192,228,229,230,231,289,290,458,459,485,486,497,498,509,510,539,540,565,566,662,663]):
            dest=folder/('review/edit_4k/stills' if args.is_4k else 'review/edit_r8/stills');dest.mkdir(parents=True,exist_ok=True)
            im.save(dest/f'{f:04d}.jpg',quality=92)
        process.stdin.write(im.tobytes())
        if f%150==0:print('FRAME',f,'/',round((args.start+args.duration)*FPS),flush=True)
    process.stdin.close();assert process.wait()==0
    sources=[ASSETS/'assets/studio_background.png',PLATES/'anchors.json',timing,mix,folder/'edit_rebuild/picture_timeline.json',Path(__file__)]
    sources+=sorted(((NATIVE_PLATES if args.is_4k else PLATES)/args.author).glob('*.png'))
    if not args.is_4k:sources+=sorted((PLATES/args.author/'motion_01_to_03').glob('*.png'))
    if args.is_4k:sources+=[approval_path,audio_source,NATIVE_PLATES/'capture_message_plates_4k.gd']
    receipt={'author':args.author,'format':[W*RASTER_SCALE,H*RASTER_SCALE,FPS],'start':args.start,'duration':args.duration,'frames':round(args.duration*FPS),'compositor':'External Pillow layer evaluation + FFmpeg encoding; Godot only source character alpha plates','picture_layers':['studio/background','giant serif behind head','character/real hand occlusion','foreground opener'],'movie_sha256':sha(out),'inputs':{str(x.relative_to(ROOT)):sha(x) for x in sources},'approval':'Exact full1080p R9 approved by user; external receipt bound to source hashes' if args.is_4k else '1080p review; no user satisfaction/4K approval recorded'}
    if args.is_4k:
        receipt.update(approval_receipt=str(approval_path.relative_to(ROOT)),approved_preview_sha256=approved['preview_sha256'],audio='AAC stream copied from approved R9 movie without re-encoding',raster_provenance={'typography':'Native3840 output rasterization from installed source fonts','props':'Same approved logical paths rasterized at2x','characters':'Same canonical rigs/poses recaptured at4000x4400 registration; no performance changes','studio_background':'Original1672x940 raster resized to3840x2160 with Lanczos; not a native4K source','bright_background':'Analytic gradient evaluated at3840x2160'},fonts={file:sha(file) for file in [SERIF,SANS]})
    records=folder/('review/edit_4k/render_records' if args.is_4k else 'review/edit_r8/render_records');records.mkdir(parents=True,exist_ok=True)
    (records/(out.stem+'.json')).write_text(json.dumps(receipt,indent=2)+'\n')
    print(out)

if __name__=='__main__':main()
