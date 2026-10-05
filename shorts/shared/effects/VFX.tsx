import {activeEvents,pulse,clamp} from '../utilities/motion';
import type {Event,Author} from '../utilities/types';
export function VFX({events,t,author}:{events:Event[];t:number;author:Author}){
 const color=author==='adb'?'#abffd8':'#ffbcb3';
 return <svg width="1080" height="1920" style={{position:'absolute',inset:0,pointerEvents:'none'}}>{activeEvents(events,t).map(e=>{const p=clamp((t-e.at)/(e.duration??.3));if(e.kind==='flash')return <rect key={e.id} width="1080" height="1920" fill={color} opacity={pulse(t,e.at,e.duration??.15)*.26}/>;if(e.kind!=='impact'&&e.kind!=='drop'&&e.kind!=='pop')return null;
 return <g key={e.id} opacity={1-p}>{Array.from({length:e.kind==='drop'?16:8},(_,i)=>{const a=i*Math.PI*2/(e.kind==='drop'?16:8),r=100+p*350;return <path key={i} d={`M ${500+Math.cos(a)*r} ${950+Math.sin(a)*r} l ${Math.cos(a)*90} ${Math.sin(a)*90}`} stroke={color} strokeWidth={8*(1-p)} strokeLinecap="round"/>})}<circle cx="500" cy="950" r={80+p*240} fill="none" stroke={color} strokeWidth={5*(1-p)}/></g>})}</svg>
}
