#!/usr/bin/env python3
"""Produce complete, validated review deliveries without overwriting revisions."""
import argparse,hashlib,json,os,re,subprocess,sys
from pathlib import Path
from bootstrap import PROJECT,REPO,GODOT,bootstrap,sync_episode,sha
from render import signature
def main():
    p=argparse.ArgumentParser();p.add_argument('--episode',default='episode_001');p.add_argument('--revision',required=True);p.add_argument('--render-only',action='store_true');p.add_argument('--generate-voice',action='store_true');a=p.parse_args()
    if not re.fullmatch(r'episode_[0-9]{3}',a.episode) or not re.fullmatch(r'r[0-9]+',a.revision):p.error('Use an episode_NNN and a new rN revision.')
    episode=PROJECT/'episodes'/a.episode;cache=PROJECT/'cache/pipeline';cache.mkdir(parents=True,exist_ok=True)
    env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',TMPDIR=str(cache),XDG_CACHE_HOME=str(PROJECT/'cache/xdg'))
    def call(tool,*args,python=sys.executable):
        subprocess.run([str(python),str(PROJECT/tool),*map(str,args)],check=True,env=env,cwd=PROJECT)
    if not a.render_only:
        call('tools/prepare_episode.py','--episode',episode)
        if a.generate_voice:call('tools/voice.py','generate','--episode',episode,python=REPO/'.venv/bin/python')
        call('tools/voice.py','check','--episode',episode)
        if not (episode/'audio/score.wav').exists():call('tools/score.py','--episode',episode,python=REPO/'.venv/bin/python')
        call('tools/prepare_episode.py','--episode',episode)
        if not (episode/'audio/mix_calibration.json').exists():call('tools/mix.py','--episode',a.episode)
        call('tools/prepare_episode.py','--episode',episode)
    call('tools/validate_episode.py','--episode',episode)
    bootstrap();scene=episode/'scene.json';frozen=sync_episode(scene);expected_signature=signature(frozen)
    base=f'NEMI_Playable_EP{a.episode[-3:]}_{a.revision}'
    output_dir=episode/'renders';output_dir.mkdir(exist_ok=True)
    results={}
    for mode,label in [('review','1080p_REVIEW'),('sphere','2160x1080_SPHERE')]:
        movie=output_dir/f'{base}_{label}.mp4';record=episode/'review/render_records'/f'{movie.stem}.render.json'
        if movie.exists():
            if not record.exists():raise ValueError('Existing movie has no verified render report. Preserve it and choose a new revision.')
            data=json.loads(record.read_text())
            if data.get('video_sha256')!=sha(movie) or data.get('spec_sha256')!=sha(scene) or data.get('render_inputs_sha256')!=expected_signature or data.get('start')!=0:
                raise ValueError('Existing movie is not this exact current production. Choose a new revision.')
            print('REUSING VERIFIED FULL MOVIE',movie,flush=True)
        else:call('tools/render.py','--scene',scene,'--mode',mode,'--output',movie)
        results[mode]=str(movie.relative_to(PROJECT))
    raw=PROJECT/results['sphere'];spherical=output_dir/f'{base}_2160x1080_360_REVIEW.mp4'
    if not spherical.exists():call('tools/spatial_metadata.py','inject',raw,spherical)
    call('tools/spatial_metadata.py','inspect',spherical)
    from spatial_metadata import inspect
    metadata=inspect(spherical)
    if not metadata['valid_spherical_metadata']:raise ValueError('Spherical metadata failed verification; no valid delivery claimed.')
    authored=json.loads(scene.read_text())
    media_clock=['--duration',authored['duration'],'--fps',authored['fps']]
    call('tools/media_qa.py',PROJECT/results['review'],'--output',episode/f'review/{a.revision}_review_media_qa.json',*media_clock)
    call('tools/media_qa.py',spherical,'--sphere','--output',episode/f'review/{a.revision}_sphere_media_qa.json',*media_clock)
    results['spherical_with_metadata']=str(spherical.relative_to(PROJECT))
    results['metadata']=metadata;results['youtube_verified']=False;results['user_satisfaction']='pending'
    (episode/f'review/{a.revision}_delivery.json').write_text(json.dumps(results,indent=2)+'\n')
    print(json.dumps(results,indent=2),flush=True)
if __name__=='__main__':main()
