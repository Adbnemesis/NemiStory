"""Mix narration and punctual SFX on the same seconds-based production clock."""
import subprocess
import re
import tempfile
from pathlib import Path

def measure_audio(path):
    result = subprocess.run(['ffmpeg','-hide_banner','-i',str(path),'-af','ebur128=peak=true','-f','null','-'],capture_output=True,text=True,check=True)
    summary = result.stderr.rsplit('Summary:',1)[-1]
    return {'integrated_lufs':float(re.search(r'I:\s*([-\d.]+) LUFS',summary)[1]),
            'true_peak_dbfs':float(re.search(r'Peak:\s*([-\d.]+) dBFS',summary)[1])}

def calibrate_mix(spec, root, target_lufs=-18.0, peak_dbfs=-1.5):
    """Constant gain only: no EQ, compression, pitch or voice redesign."""
    base=dict(spec); base.pop('mix',None)
    with tempfile.TemporaryDirectory(prefix='mix-calibration-') as folder:
        source=mix_audio(base,root,Path(folder)/'base.wav',floating=True)
        if source is None: raise ValueError('Mix calibration needs real audio')
        measured=measure_audio(source)
    gain=min(target_lufs-measured['integrated_lufs'],peak_dbfs-measured['true_peak_dbfs'])
    if not -24<=gain<=12: raise ValueError('Source level needs review; required master gain is outside -24..12 dB')
    return {'master_gain_db':round(gain,2),'target_lufs':target_lufs,'peak_dbfs':peak_dbfs}

def mix_audio(spec,root,destination,floating=False):
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
    gain=spec.get('mix',{}).get('master_gain_db',0)
    filters.append(''.join(labels)+f'amix=inputs={len(labels)}:normalize=0:duration=longest,apad,atrim=duration={spec["duration"]},volume={gain}dB[out]')
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y',*inputs,'-filter_complex',';'.join(filters),'-map','[out]','-ar','48000','-ac','2','-c:a','pcm_f32le' if floating else 'pcm_s16le',str(destination)],check=True)
    if 'mix' in spec:
        measured=measure_audio(destination)
        if measured['true_peak_dbfs']>spec['mix']['peak_dbfs']+.15:
            raise ValueError('Mix peak exceeds headroom; recalibrate after audio/SFX changes')
    return Path(destination)
