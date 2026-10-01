"""Identity settings, pitch preservation, measured mapping and source protection."""
import copy
import hashlib
import json
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import numpy as np
import soundfile as sf
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from tools.tts.engine import QwenVoiceDesignEngine
from tools.tts.config import NemiVoiceConfig,ADBVoiceConfig
from tools.tts.segmenter import ScriptSegmenter
from prepare_voice import prepare,digest

rate=24000
signal=(.3*np.sin(2*np.pi*180*np.arange(rate*3)/rate)).astype('float32')
def frequency(audio):
    center=audio[rate//3:len(audio)-rate//3]
    crossings=np.count_nonzero((center[:-1]<0)&(center[1:]>=0))
    return crossings*rate/len(center)
for config in [NemiVoiceConfig(),ADBVoiceConfig()]:
    calls=[]
    def generate(**kwargs):
        calls.append(kwargs); return [SimpleNamespace(audio=signal)]
    engine=QwenVoiceDesignEngine.__new__(QwenVoiceDesignEngine)
    engine.config=config;engine.model=SimpleNamespace(config=SimpleNamespace(tts_model_type='custom_voice'),generate_custom_voice=generate)
    original=engine.synthesize('Same character.',speed=1)
    paced=engine.synthesize('Same character.',speed=1.15)
    assert np.array_equal(original,signal)
    assert calls[0]==calls[1] and calls[0]['speaker']==config.speaker and calls[0]['instruct']==config.voice_design_prompt
    assert abs(len(paced)/rate-3/1.15)<.06
    assert abs(frequency(paced)-frequency(original))<1.2
    try:engine.synthesize('Invalid speed',speed=float('nan'))
    except ValueError:pass
    else:raise AssertionError('Nonfinite tempo accepted')

with tempfile.TemporaryDirectory(prefix='pacing-test-',dir=ROOT/'renders') as folder:
    folder=Path(folder);source=folder/'original.wav';sf.write(source,signal,rate,subtype='FLOAT')
    before=digest(source)
    plan={'version':1,'duration':4,'clips':[{'author':'nemi','file':'res://'+str(source.relative_to(ROOT)),'sha256':before,'at':.5,'start':0,'end':3,'tempo':1.15,'words':[{'word':'same','start':.2,'end':.8}]}]}
    timeline=prepare(plan,folder/'prepared');audio,sr=sf.read(folder/'prepared/narration.wav')
    assert sr==rate and len(audio)/sr==4 and digest(source)==before
    assert np.max(np.abs(audio[:round(.49*sr)]))==0
    assert abs(timeline['words'][0]['start']-(.5+.2/1.15))<1e-6
    assert timeline['audio_sha256']==digest(folder/'prepared/narration.wav')
    for output,bad in [(folder/'prepared',plan),(folder/'bad',dict(plan,clips=[dict(plan['clips'][0],sha256='bad')]))]:
        try:prepare(bad,output)
        except ValueError:pass
        else:raise AssertionError('Overwrite or substituted voice accepted')
    script=folder/'script.md';script.write_text('### BEAT 1: Test\n```text\n[00:00.0] ADB:\n"Hi. Same voice."\n[PAUSE: 0.7s]\n[SPEED: 1.15]\n[Acting: Hold.]\n```\n')
    segments=ScriptSegmenter.parse_intro_script(str(script),speaker='ADB')
    assert len(segments)==1 and segments[0].speed==1.15 and segments[0].pause_after==.7 and segments[0].tts_text=='Hi. Same voice.'
print('PASS: both voice identities/settings unchanged, 180 Hz pitch preserved, tempo applied, explicit gaps, mapped words and protected sources')
