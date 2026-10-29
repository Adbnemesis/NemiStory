#!/usr/bin/env python3
"""Measure and calibrate the actual episode mix, with all temp files isolated."""
import argparse,hashlib,json,os,sys,tempfile
from pathlib import Path
from bootstrap import PROJECT,GODOT,bootstrap,sync_episode
def main():
    p=argparse.ArgumentParser();p.add_argument('--episode',default='episode_001');a=p.parse_args();episode=PROJECT/'episodes'/a.episode
    cache=PROJECT/'cache/audio';cache.mkdir(parents=True,exist_ok=True);tempfile.tempdir=str(cache);os.environ['TMPDIR']=str(cache)
    bootstrap();scene=episode/'scene.json';frozen=sync_episode(scene)
    sys.path.insert(0,str(GODOT/'tools/storytime'))
    from validate_scene import validate
    from audio_mix import calibrate_mix,mix_audio,measure_audio
    spec=validate(frozen);spec.pop('mix',None)
    calibration=episode/'audio/mix_calibration.json'
    if calibration.exists():raise ValueError('Calibration exists; preserve it under a revision name before recalibrating.')
    mix=calibrate_mix(spec,GODOT);spec['mix']=mix
    output=episode/'audio/mix.wav';mix_audio(spec,GODOT,output)
    configuration={'audio':spec['audio'],'sfx':spec['sfx'],'music':spec.get('music',[])}
    record={'configuration_sha256':hashlib.sha256(json.dumps(configuration,sort_keys=True).encode()).hexdigest(),
        'mix':mix,'actual':measure_audio(output),'audio_sha256':hashlib.sha256(output.read_bytes()).hexdigest(),
        'listening_review':'pending; this runtime does not support audio perception'}
    calibration.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2))
if __name__=='__main__':main()
