#!/usr/bin/env python3
"""Validate, freeze and render an isolated spherical or directed review cut."""
from pathlib import Path
import argparse
import fcntl
import hashlib
import json
import math
import os
import shutil
import subprocess
import sys
import tempfile
from bootstrap import PROJECT, REPO, GODOT, bootstrap, sync_episode, sha


def signature(scene):
    files=[p for p in GODOT.rglob('*') if p.is_file() and '.godot' not in p.parts
           and p.suffix in {'.gd','.tscn','.json','.gdshader','.godot','.wav','.mp3','.ogg'}
           and p.name not in {'dependency_provenance.json','episode_snapshot.json'}]
    h=hashlib.sha256()
    for path in sorted(files):
        h.update(str(path.relative_to(GODOT)).encode());h.update(sha(path).encode())
    return h.hexdigest()


def probe(path,count=False):
    command=['ffprobe','-v','error']
    if count: command+=['-count_frames']
    command+=['-show_streams','-show_format','-of','json',str(path)]
    return json.loads(subprocess.run(command,capture_output=True,text=True,check=True).stdout)


def validate_review_camera(segment):
    """Refuse invalid frozen camera data independently of the story compiler."""
    finite=lambda value:type(value) in (int,float) and math.isfinite(value)
    start,end=segment['start'],segment['end']
    fov=segment.get('review_fov',85);yaw=segment.get('review_yaw',0)
    if not finite(fov) or not 50<=fov<=110:raise ValueError('Review base FOV must be 50..110 degrees.')
    if not finite(yaw) or not -180<=yaw<=180:raise ValueError('Review base yaw must be -180..180 degrees.')
    previous=start-1
    path=segment.get('review_yaw_path',[])
    if not isinstance(path,list):raise ValueError('Review yaw path must be an array.')
    for point in path:
        if not (isinstance(point,dict) and finite(point.get('at')) and finite(point.get('yaw'))
                and previous<point['at']<=end and point['at']>=start and -180<=point['yaw']<=180):
            raise ValueError('Review yaw paths require increasing scene-clock times and bounded yaw angles.')
        previous=point['at']
    beats=segment.get('review_camera_beats',[])
    if not isinstance(beats,list):raise ValueError('Review camera beats must be an array.')
    allowed={'at','yaw','pitch','fov','duration','intent'};previous_at=start-1;previous_end=start
    for beat in beats:
        if not isinstance(beat,dict) or set(beat)-allowed:raise ValueError('Unknown review camera beat fields.')
        at=beat.get('at');yaw=beat.get('yaw');pitch=beat.get('pitch',0)
        fov=beat.get('fov');duration=beat.get('duration',.32)
        if not all(finite(value) for value in [at,yaw,pitch,fov,duration]):raise ValueError('Review camera beat values must be finite numbers.')
        if not (-180<=yaw<=180 and -25<=pitch<=25 and 34<=fov<=110):raise ValueError('Review camera beat projection is outside yaw/pitch/FOV bounds.')
        if not (duration>=0 and start<=at<end and at+duration<=end):raise ValueError('Review camera beat transition must fit inside its scene.')
        if at<=previous_at or at<previous_end:raise ValueError('Review camera beats must increase without overlapping transitions.')
        if not isinstance(beat.get('intent'),str) or not beat['intent'].strip():raise ValueError('Review camera beat needs its authored intention.')
        previous_at=at;previous_end=at+duration


def validate_export_kind(audition,four_k):
    if audition and four_k:raise ValueError('Audition renders cannot be 4K or qualify as full episode approval.')


def render_identity(audition):
    if audition:
        return {'kind':'audition','playable':False,
            'audition_note':'Sequential voice/storyboard audition. Number labels illustrate planned final controls; this shortened cut has no live choice or valid digit navigation.'}
    return {'kind':'episode'}


def validate_timeline(timeline,game=None,audition=False):
    from validate_episode import check_audition_data,check_data
    return check_audition_data(timeline) if audition else check_data(timeline,game)


def validate_environment_events(segment,story_events,renderer='school'):
    from validate_episode import WORLD_EVENT_KINDS,environment_event_limit
    objects={item['id'] for wall in segment['walls'] for item in wall['objects']}
    finite=lambda value:type(value) in (int,float) and math.isfinite(value)
    seen=set()
    for event in segment.get('environment_events',[]):
        event_id=event.get('id');at=event.get('at');end=event.get('end');named=event.get('event')
        maximum=environment_event_limit(renderer,event.get('kind')) if renderer=='drawing' else 2
        if not (isinstance(event_id,str) and event_id.strip() and event_id not in seen
                and event.get('object') in objects and event.get('kind') in WORLD_EVENT_KINDS[renderer]
                and finite(at) and finite(end) and segment['start']<=at<end<=segment['end'] and end-at<=maximum):
            raise ValueError('Environment events need unique IDs, existing objects, finite bounded intervals and a supported world event kind.')
        if not (isinstance(named,str) and named in story_events and abs(story_events[named]-at)<.001):
            raise ValueError('Environment motion must name a canonical scene event at the same scene-clock time.')
        seen.add(event_id)


def isolated_env():
    environment=dict(os.environ)
    cache=PROJECT/'cache'
    for key,subfolder in [('TMPDIR','tmp'),('XDG_CACHE_HOME','xdg'),('PYTHONPYCACHEPREFIX','python')]:
        destination=cache/subfolder;destination.mkdir(parents=True,exist_ok=True)
        environment[key]=str(destination)
    environment['PYTHONDONTWRITEBYTECODE']='1'
    return environment


def isolated_godot(source):
    # Godot documents portable/self-contained mode through an _sc_ marker next
    # to the executable. Copy the existing binary rather than changing its app.
    destination=PROJECT/'cache/godot/Godot.app/Contents/MacOS/Godot' if sys.platform=='darwin' else PROJECT/'cache/godot/Godot'
    destination.parent.mkdir(parents=True,exist_ok=True)
    stamp=destination.parent/'source.json'
    source_stat=Path(source).stat()
    identity={'source':str(source),'size':source_stat.st_size,'mtime_ns':source_stat.st_mtime_ns}
    if not destination.exists() or not stamp.exists() or json.loads(stamp.read_text())!=identity:
        staging=PROJECT/'cache/godot/Godot-signing'
        shutil.copyfile(source,staging)
        staging.chmod(0o755)
        if sys.platform=='darwin':
            plist=Path(source).parent.parent/'Info.plist'
            if plist.is_file(): shutil.copyfile(plist,destination.parent.parent/'Info.plist')
            # The existing local binary has an invalid signature on this host;
            # ad-hoc sign only our disposable copy to make the portable runtime
            # executable. Original application and quarantine remain untouched.
            subprocess.run(['codesign','--force','--sign','-',str(staging)],check=True,capture_output=True)
        shutil.move(staging,destination)
        stamp.write_text(json.dumps(identity,indent=2)+'\n')
    (destination.parent/'_sc_').touch(exist_ok=True)
    if sys.platform=='darwin': (destination.parent.parent/'_sc_').touch(exist_ok=True)
    return str(destination)


def engine_errors(transcript):
    """Separate known blocked, unused macOS userdata setup from actual errors."""
    errors=[]
    for line in transcript.splitlines():
        if 'ERROR:' not in line and 'Parse Error:' not in line: continue
        # Godot always initializes user:// before scripts. This renderer never
        # reads/writes user://. The environment rejects this automatic directory
        # creation; actual caches/logs/media are inside this project. Do not
        # suppress script, resource, shader, audio or rendering errors.
        if line.startswith('ERROR: Could not create directory:') and '/Library/Application Support/Godot/app_userdata/Nemi Playable Storytime' in line: continue
        if line.startswith('ERROR: Error attempting to create data dir:') and '/Library/Application Support/Godot/app_userdata/Nemi Playable Storytime' in line: continue
        errors.append(line)
    return errors


def graphical_command(binary):
    if sys.platform!='darwin': return [binary]
    # Grant graphics separately while retaining a strict write boundary for the
    # engine process and its children. Framework caches outside production are
    # denied; logs/imports/movie captures use explicit in-project locations.
    profile='(version 1)(allow default)(deny file-write*)(allow file-write* (subpath '+json.dumps(str(PROJECT))+'))'
    return ['/usr/bin/sandbox-exec','-p',profile,binary]


def require_approval(scene,input_signature):
    receipt=scene.parent/'review/1080P_APPROVAL.json'
    if not receipt.is_file(): raise ValueError('Render the complete 1080p review and obtain explicit user satisfaction before 4K.')
    data=json.loads(receipt.read_text())
    preview=(PROJECT/data.get('preview','')).resolve()
    if not preview.is_relative_to(PROJECT) or not preview.is_file(): raise ValueError('Approval preview is missing or outside this project.')
    if not (data.get('approved') is True and data.get('approved_by')=='user' and data.get('user_quote','').strip()
            and data.get('spec_sha256')==sha(scene) and data.get('render_inputs_sha256')==input_signature
            and data.get('preview_sha256')==sha(preview)):
        raise ValueError('Approval is not bound to the current full review and current inputs.')
    report_path=(PROJECT/data.get('preview_report','')).resolve()
    if not report_path.is_relative_to(PROJECT) or not report_path.is_file() or data.get('preview_report_sha256')!=sha(report_path):
        raise ValueError('Approval must bind the actual renderer report with preview_report and preview_report_sha256.')
    report=json.loads(report_path.read_text())
    if report.get('kind')=='audition':raise ValueError('An audition report cannot qualify as full episode approval.')
    spec=json.loads(scene.read_text())
    report_video=(PROJECT/report.get('video','')).resolve()
    if not (report_video==preview and report.get('video_sha256')==sha(preview)
            and report.get('spec_sha256')==sha(scene) and report.get('render_inputs_sha256')==input_signature
            and report.get('mode')=='review' and report.get('resolution')==[1920,1080]
            and report.get('start')==0 and report.get('duration')==spec['duration']
            and report.get('fps')==spec['fps'] and report.get('frames')==round(spec['duration']*spec['fps'])):
        raise ValueError('Renderer report does not match the exact complete current 1080p review.')
    details=probe(preview)
    video=next(s for s in details['streams'] if s['codec_type']=='video')
    duration=float(spec['duration'])
    if (video['width'],video['height'])!=(1920,1080) or abs(float(details['format']['duration'])-duration)>.1:
        raise ValueError('Only the complete current 1920x1080 cut can receive approval.')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--scene',type=Path,default=PROJECT/'episodes/episode_001/scene.json')
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--mode',choices=['sphere','review'],default='sphere')
    parser.add_argument('--start',type=float,default=0)
    parser.add_argument('--duration',type=float)
    parser.add_argument('--godot',default=os.environ.get('GODOT_BIN'))
    parser.add_argument('--4k',dest='four_k',action='store_true')
    parser.add_argument('--audition',action='store_true',help='Render an explicitly nonplayable 30–60 second voice/storyboard timeline.')
    parser.add_argument('--validate-only',action='store_true')
    args=parser.parse_args()
    try:validate_export_kind(args.audition,args.four_k)
    except ValueError as error:parser.error(str(error))
    scene=args.scene.resolve();output=args.output.resolve()
    if not scene.is_relative_to(PROJECT) or not output.is_relative_to(PROJECT): parser.error('Inputs and outputs must remain inside playable_storytime.')
    if output.exists(): parser.error('Output exists; use a new revision filename.')
    if output.suffix!='.mp4': parser.error('Output must be MP4.')
    bootstrap()
    source_spec_signature=sha(scene)
    frozen=sync_episode(scene)
    if sha(frozen)!=source_spec_signature: parser.error('Source scene changed while freezing production inputs.')
    sys.path.insert(0,str(GODOT/'tools/storytime'))
    from validate_scene import validate
    from audio_mix import mix_audio, measure_audio
    spec=validate(frozen)
    timeline=json.loads((frozen.parent/'storyboard/timeline.json').read_text())
    game=None if args.audition else json.loads((frozen.parent/'gameplay/manifest.json').read_text())
    validate_timeline(timeline,game,args.audition)
    from continuity import validate_natural_joins
    validate_natural_joins(timeline,spec)
    if timeline['duration']!=spec['duration'] or timeline['fps']!=spec['fps']: parser.error('Panorama and acting timelines must share the same duration/fps.')
    story_events={event['id']:event['at'] for event in spec.get('events',[])}
    from validate_episode import validate_actor_transport
    for segment in timeline['scenes']:
        try:
            validate_review_camera(segment)
            validate_environment_events(segment,story_events,timeline.get('world_renderer','school'))
            validate_actor_transport(segment,timeline.get('world_renderer','school'),story_events,spec)
        except ValueError as error:parser.error(str(error))
    duration=args.duration if args.duration is not None else spec['duration']-args.start
    if not (0<=args.start<spec['duration'] and 0<duration<=spec['duration']-args.start): parser.error('Render window is outside the episode.')
    fps=spec['fps'];frames=round(duration*fps)
    if any(abs(value*fps-round(value*fps))>1e-5 for value in [args.start,duration]): parser.error('Render times must align to frame boundaries.')
    input_signature=signature(frozen)
    if args.four_k:
        require_approval(scene,input_signature)
    width,height=((3840,1920) if args.mode=='sphere' else (3840,2160)) if args.four_k else ((2160,1080) if args.mode=='sphere' else (1920,1080))
    if args.validate_only:
        print(json.dumps({'validated':True,'frozen_scene':str(frozen),'render_inputs_sha256':input_signature,**render_identity(args.audition)},indent=2));return
    candidates=[args.godot,shutil.which('godot'),str(Path.home()/'Downloads/Godot.app/Contents/MacOS/Godot'),'/Applications/Godot.app/Contents/MacOS/Godot']
    godot=next((p for p in candidates if p and Path(p).is_file()),None)
    if not godot or not shutil.which('ffmpeg') or not shutil.which('ffprobe'): parser.error('Existing Godot, FFmpeg and FFprobe are required.')
    godot=isolated_godot(godot)
    output.parent.mkdir(parents=True,exist_ok=True)
    records=scene.parent/'review/render_records';records.mkdir(parents=True,exist_ok=True)
    cache=PROJECT/'cache';cache.mkdir(exist_ok=True)
    environment=isolated_env()
    if not (GODOT/'.godot/global_script_class_cache.cfg').is_file():
        import_log=records/'engine_import.log'
        subprocess.run(graphical_command(godot)+['--headless','--editor','--quit','--path',str(GODOT),'--log-file',str(import_log)],check=True,env=environment)
        if engine_errors(import_log.read_text()): raise RuntimeError('Godot import failed; inspect '+str(import_log))
    with (cache/'capture.lock').open('a') as lock:
        try: fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError: parser.error('Another isolated capture is active.')
        with tempfile.TemporaryDirectory(prefix='capture-',dir=cache) as temporary:
            work=Path(temporary);raw=work/'capture.avi';log=records/(output.stem+'.capture.log')
            command=graphical_command(godot)+['--path',str(GODOT),'--resolution',f'{width}x{height}','--log-file',str(log),'--fixed-fps',str(fps),
                '--write-movie',str(raw),'--script','res://RenderPlayable.gd','--',
                '--spec=res://'+frozen.relative_to(GODOT).as_posix(),'--mode='+args.mode,
                '--start='+str(args.start),'--duration='+str(duration)]
            if args.four_k: command.append('--4k')
            override=GODOT/'override.cfg'
            previous_override=override.read_bytes() if override.exists() else None
            override.write_text('[display]\n'+
                f'window/size/viewport_width={width}\nwindow/size/viewport_height={height}\n'+
                f'window/size/window_width_override={width}\nwindow/size/window_height_override={height}\n'+
                'window/stretch/mode="disabled"\n')
            try: subprocess.run(command,check=True,env=environment)
            finally:
                if previous_override is None: override.unlink(missing_ok=True)
                else: override.write_bytes(previous_override)
            transcript=log.read_text()
            completion='AUDITION COMPLETE:' if args.audition else 'PLAYABLE COMPLETE:'
            if engine_errors(transcript) or completion not in transcript:
                raise RuntimeError('Capture did not pass engine checks; inspect '+str(log))
            raw_probe=probe(raw,True)
            video=next(s for s in raw_probe['streams'] if s['codec_type']=='video')
            if (video['width'],video['height'])!=(width,height): raise RuntimeError('Capture resolution mismatch.')
            actual=int(video.get('nb_read_frames',0))
            if actual not in range(frames,frames+3): raise RuntimeError(f'Incomplete capture: {actual} frames; expected {frames}.')
            audio=mix_audio(spec,GODOT,work/'mix.wav')
            result=work/'final.mp4'
            command=['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(raw)]
            if audio:
                command+=['-ss',str(args.start),'-i',str(audio),'-map','0:v:0','-map','1:a:0','-af',f'apad,atrim=duration={duration}']
            else: command+=['-map','0:v:0','-an']
            command+=['-vf',f'trim=end_frame={frames},setpts=PTS-STARTPTS','-t',str(duration),
                      '-c:v','libx264','-preset','fast','-crf','18','-g',str(fps*2),'-pix_fmt','yuv420p',
                      '-color_primaries','bt709','-color_trc','bt709','-colorspace','bt709',
                      '-c:a','aac','-b:a','256k','-ar','48000','-movflags','+faststart',str(result)]
            subprocess.run(command,check=True,env=environment)
            decoded=probe(result,True)
            final_video=next(s for s in decoded['streams'] if s['codec_type']=='video')
            if int(final_video['nb_read_frames'])!=frames or abs(float(decoded['format']['duration'])-duration)>.06:
                raise RuntimeError('Encoded duration/frame count failed.')
            measured=measure_audio(result) if audio else None
            if measured and measured['true_peak_dbfs']>-1.0: raise RuntimeError('Encoded audio exceeds -1 dBFS true peak; revise the mix.')
            if signature(frozen)!=input_signature: raise RuntimeError('Frozen production inputs changed during capture.')
            if sha(scene)!=source_spec_signature: raise RuntimeError('Source scene changed during capture; render the current prepared revision.')
            shutil.copy2(result,output)
            report={'video':str(output.relative_to(PROJECT)),'video_sha256':sha(output),'spec_sha256':source_spec_signature,
                    'render_inputs_sha256':input_signature,'mode':args.mode,'resolution':[width,height],
                    'fps':fps,'frames':frames,'start':args.start,'duration':duration,'audio':measured,
                    'youtube_verified':False,'spherical_metadata_injected':False,**render_identity(args.audition),
                    'note':'Sphere mode is true equirectangular room-ray projection; metadata injection is a separate validated packaging step.'}
            (records/(output.stem+'.render.json')).write_text(json.dumps(report,indent=2)+'\n')
            print(json.dumps(report,indent=2))

if __name__=='__main__': main()
