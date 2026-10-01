"""Mix narration and punctual SFX on the same seconds-based production clock."""
import subprocess
from pathlib import Path

def mix_audio(spec,root,destination):
    inputs=[]; filters=[]; labels=[]
    if spec.get('audio'):
        inputs += ['-i',str(root/spec['audio'].removeprefix('res://'))]
        filters.append(f'[0:a]asetpts=PTS-STARTPTS,volume=-2dB,apad,atrim=duration={spec["duration"]}[voice]')
        labels.append('[voice]')
    for sound in spec.get('sfx',[]):
        index=len(inputs)//2
        inputs += ['-i',str(root/sound['file'].removeprefix('res://'))]
        label=f's{index}'
        filters.append(f'[{index}:a]atrim=duration={sound["duration"]},asetpts=PTS-STARTPTS,volume={sound["gain_db"]}dB,adelay={round(sound["at"]*1000)}:all=1[{label}]')
        labels.append(f'[{label}]')
    if not inputs: return None
    filters.append(''.join(labels)+f'amix=inputs={len(labels)}:normalize=0:duration=longest,apad,atrim=duration={spec["duration"]}[out]')
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y',*inputs,'-filter_complex',';'.join(filters),'-map','[out]','-ar','48000','-ac','2','-c:a','pcm_s16le',str(destination)],check=True)
    return Path(destination)
