import {Audio,Sequence,staticFile,useCurrentFrame,useVideoConfig} from 'remotion';
import type {ShortConfig} from '../utilities/types';
import {clamp} from '../utilities/motion';
export const gain=(db:number)=>Math.pow(10,db/20);
export function duckDb(t:number,windows:{start:number;end:number;gainDb:number}[]){let db=0;for(const w of windows){const attack=clamp((t-(w.start-.1))/.1),release=clamp(((w.end+.2)-t)/.2);db=Math.min(db,w.gainDb*Math.min(attack,release))}return db===0?0:db}
export function AudioTrack({config}:{config:ShortConfig}){
 const frame=useCurrentFrame(),{fps}=useVideoConfig(),t=frame/fps;
 return <>{config.music&&<Audio src={staticFile(config.music.file)} startFrom={Math.round(config.music.sourceStart*fps)} endAt={Math.round((config.music.sourceStart+config.music.duration)*fps)} volume={gain(config.music.gainDb+duckDb(t,config.music.duck))}/>}
 {[...config.dialogue,...config.sfx].map(s=><Sequence key={s.id} from={Math.round(s.at*fps)} durationInFrames={Math.max(1,Math.round(s.duration*fps))} layout="none"><Audio src={staticFile(s.file)} startFrom={Math.round((s.sourceStart??0)*fps)} volume={gain(s.gainDb)}/></Sequence>)}</>
}
