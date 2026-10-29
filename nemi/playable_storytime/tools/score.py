#!/usr/bin/env python3
"""Render an original, explicitly notated soft keyboard score, ducked to speech.

This creates music only. Event SFX are the separately credited recordings.
"""
import argparse, hashlib, json
from pathlib import Path
from score_plan import validated_plan_notes
PROJECT=Path(__file__).resolve().parents[1]
def compose(episode):
    import numpy as np
    import soundfile as sf
    episode=episode.resolve()
    if not episode.is_relative_to(PROJECT/'episodes'):
        raise ValueError('Score outputs must remain in an isolated playable_storytime episode.')
    output=episode/'audio/score.wav'
    if output.exists():raise ValueError('Score exists; preserve and choose a revised filename before recomposing.')
    timeline=json.loads((episode/'audio/timeline.json').read_text());sr=48000
    duration=timeline['duration'];music=np.zeros((round(duration*sr),2),dtype=np.float32);notes=[]
    plan_path=episode/'audio/score_plan.json'
    if plan_path.exists():
        plan=json.loads(plan_path.read_text());notes=validated_plan_notes(plan,timeline)
        title=plan['title'];plan_hash=hashlib.sha256(plan_path.read_bytes()).hexdigest()
        mode='Explicit measured-word-linked musical phrases; protected comic silence'
    else:
        # Legacy template compatibility; new productions can author exact phrases.
        plan=None;plan_hash=None;title='A Small Favour';mode='Legacy chapter motifs'
        motifs=[[62,66,69,73],[59,62,66,69],[64,67,71,74],[57,61,64,69]]
        story=json.loads((episode/'scripts/story.json').read_text())
        for scene,chapter in enumerate(story['chapters']):
            for j,offset in enumerate([.1,2.0,5.5,7.5,13.0,15.0,20.0,22.0]):
                if scene==len(story['chapters'])-1 and offset>15:continue
                at=chapter['start']+offset
                if at>=chapter['end']:continue
                notes.append(dict(at=at,midi=motifs[(scene//3)%4][j%4],duration=min(2.5,duration-at),velocity=.18,pan=.35 if j%2 else -.35))
    for note in notes:
        at,midi,length,velocity,pan=(note[k] for k in ['at','midi','duration','velocity','pan'])
        t=np.arange(round(length*sr))/sr;freq=440*2**((midi-69)/12)
        # An explicitly pitched soft piano instrument; original music, never SFX.
        envelope=(1-np.exp(-t/0.022))*np.exp(-t/0.85)*np.minimum(1,(length-t)/.3)
        wave=(np.sin(2*np.pi*freq*t)+.23*np.sin(2*np.pi*2*freq*t)+.05*np.sin(2*np.pi*3*freq*t))*envelope*velocity
        start=round(at*sr);end=min(len(music),start+len(wave))
        music[start:end,0]+=wave[:end-start]*(1-pan)*.7;music[start:end,1]+=wave[:end-start]*(1+pan)*.7
    duck=np.ones(len(music),dtype=np.float32)
    for c in timeline['clips']:
        a=max(0,round((c['at']-.15)*sr));b=min(len(music),round((c['end_at']+.18)*sr))
        duck[a:b]=np.minimum(duck[a:b],.42)
        ramp=min(round(.15*sr),a,len(music)-b)
        if ramp>0:
            duck[a-ramp:a]=np.minimum(duck[a-ramp:a],np.linspace(1,.42,ramp))
            duck[b:b+ramp]=np.minimum(duck[b:b+ramp],np.linspace(.42,1,ramp))
    music*=duck[:,None];sf.write(output,music,sr,subtype='PCM_16')
    (episode/'audio/score_composition.json').write_text(json.dumps(dict(title=title,mode=mode,score_plan_sha256=plan_hash,narration_sha256=timeline['audio_sha256'],composer='Original score authored for Nemi Playable Storytime',license='Original project composition; no sampled recordings',instrument='Synthesized soft electric piano; explicitly pitched original music, not replacement SFX',sample_rate=sr,duration=duration,notes=notes,phrases=plan['phrases'] if plan else None,protected_silences=plan.get('silent_ranges',[]) if plan else [],ducking='Speech intervals reduce music to42percent with150ms approach/release',sha256=hashlib.sha256(output.read_bytes()).hexdigest(),listening_review='pending; musical note and energy checks do not establish perceptual quality'),indent=2)+'\n')
    print(output)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--episode',type=Path,default=PROJECT/'episodes/episode_001');a=p.parse_args();compose(a.episode)
