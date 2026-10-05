import type {CameraKey,Event} from './types';
export const clamp=(v:number,a=0,b=1)=>Math.max(a,Math.min(b,v));
export const lerp=(a:number,b:number,p:number)=>a+(b-a)*p;
export const smooth=(p:number)=>{const n=clamp(p);return n*n*(3-2*n)};
export const quantize=(t:number,fps:number)=>Math.round(t*fps);
export const steppedTime=(t:number,cadence=15)=>Math.floor(t*cadence)/cadence;
export function pulse(t:number,at:number,duration=.28){const p=(t-at)/duration;return p<0||p>=1?0:Math.sin(p*Math.PI)*Math.exp(-p*2)}
export function kick(t:number,at:number,duration=.3){const d=t-at;return d<0||d>=duration?0:Math.sin(d*58)*Math.exp(-d*14)}
export function cameraAt(keys:CameraKey[],t:number):CameraKey{
 if(t<=keys[0].at)return keys[0];
 const k=keys.findIndex((v,i)=>i>0&&v.at>t);
 if(k<0)return keys.at(-1)!;
 const a=keys[k-1],b=keys[k],p=smooth((t-a.at)/(b.at-a.at));
 return {at:t,zoom:lerp(a.zoom,b.zoom,p),x:lerp(a.x,b.x,p),y:lerp(a.y,b.y,p),rotate:lerp(a.rotate,b.rotate,p)};
}
export function activeEvents(events:Event[],t:number){return events.filter(e=>t>=e.at&&t<e.at+(e.duration??.3))}
export function eventStrength(events:Event[],t:number,kind?:Event['kind']){return events.reduce((v,e)=>v+(!kind||e.kind===kind?pulse(t,e.at,e.duration??.3)*(e.strength??1):0),0)}
export function loopFrame(frame:number,duration:number){return ((frame%duration)+duration)%duration}
export function cyclicPose(frame:number,duration:number){return Math.sin(loopFrame(frame,duration)/duration*Math.PI*2)}
