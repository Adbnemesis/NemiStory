import type {Shot,Author} from '../utilities/types';
import {clamp} from '../utilities/motion';
export function Transition({shot,t,author}:{shot:Shot;t:number;author:Author}){
 const d=t-shot.start;if(!shot.transition||['cut','match'].includes(shot.transition)||d<0||d>.22)return null;
 const p=clamp(d/.22),color=author==='adb'?'#a6ffd0':'#ef7c68';
 if(shot.transition==='object')return <svg width="1080" height="1920" style={{position:'absolute',inset:0,transform:`translateX(${(p*2-1)*1500}px) rotate(-18deg)`}}><rect x="260" y="-200" width="430" height="2350" rx="110" fill="#272b32"/><rect x="290" y="-200" width="100" height="2350" fill={color}/></svg>;
 if(shot.transition==='snap'||shot.transition==='smear')return <div style={{position:'absolute',inset:0,background:color,opacity:(1-p)*.14,transform:`scale(${1+p*.4})`}}/>;
 return <div style={{position:'absolute',inset:'-200px',background:color,transform:`translateX(${(p*2-1)*1600}px) rotate(${shot.transition==='spin'?p*180:-12}deg)`}}/>;
}
