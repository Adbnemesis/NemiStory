import {useCurrentFrame,useVideoConfig} from 'remotion';
import {pulse,clamp} from '../utilities/motion';
import type {CueMap} from '../utilities/types';
export function beatAt(cues:number[],t:number){let index=-1;for(let i=0;i<cues.length;i++){if(cues[i]>t)break;index=i}return {index,at:index<0?null:cues[index],next:cues[index+1]??null}}
export function beatProgress(cues:number[],t:number){const b=beatAt(cues,t);return b.at===null||b.next===null?0:clamp((t-b.at)/(b.next-b.at))}
const useTime=()=>{const f=useCurrentFrame(),{fps}=useVideoConfig();return f/fps};
export const useBeat=(c:CueMap)=>beatAt(c.beats,useTime());
export const useBeatProgress=(c:CueMap)=>beatProgress(c.beats,useTime());
export const useStrongBeat=(c:CueMap)=>beatAt(c.strongBeats,useTime());
export const usePhrase=(c:CueMap)=>beatAt(c.phrases,useTime());
export const useDrop=(c:CueMap)=>beatAt(c.drops,useTime());
export const useAudioCue=(times:number[])=>beatAt(times,useTime());
export const beatBounce=(t:number,cue:number,amount=16)=>-pulse(t,cue)*amount;
export const beatScale=(t:number,cue:number,amount=.08)=>1+pulse(t,cue)*amount;
export const beatShake=(t:number,cue:number,amount=8)=>pulse(t,cue)*Math.sin((t-cue)*70)*amount;
export const beatFlash=(t:number,cue:number)=>pulse(t,cue,.13)*.2;
export const beatRotate=(t:number,cue:number,amount=4)=>pulse(t,cue)*amount;
export const beatExpression=<T>(t:number,cue:number,before:T,after:T)=>t<cue?before:after;
export const beatCut=(t:number,cues:number[])=>beatAt(cues,t).index;

/** Retime a reviewed cue map for a nonzero source excerpt without changing the recording. */
export function sliceCueMap(c:CueMap,sourceStart:number,duration:number):CueMap{
 const shift=sourceStart-c.sourceStart;if(shift<0||duration<=0||shift+duration>c.duration+.001)throw Error('Segment outside analyzed source');
 const trim=(times:number[])=>times.filter(v=>v>=shift&&v<shift+duration).map(v=>v-shift);
 const beats=trim(c.beats);return {...c,sourceStart,duration,offset:beats[0]??0,beats,strongBeats:trim(c.strongBeats),drops:trim(c.drops),phrases:trim(c.phrases),choruses:trim(c.choruses),accents:trim(c.accents),onsets:trim(c.onsets)};
}
