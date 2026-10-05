import React from 'react';
import {cameraAt,kick} from '../utilities/motion';
import type {CameraKey,Event} from '../utilities/types';
export function Camera({keys,t,events,children}:{keys:CameraKey[];t:number;events:Event[];children:React.ReactNode}){
 const c=cameraAt(keys,t);const impacts=events.filter(e=>e.kind==='impact'||e.kind==='drop');
 const shake=impacts.reduce((a,e)=>a+kick(t,e.at,e.duration??.28)*(e.strength??1)*9,0);
 const zoomKick=impacts.reduce((a,e)=>a+Math.max(0,kick(t,e.at,e.duration??.28))*.025*(e.strength??1),0);
 return <div style={{position:'absolute',inset:0,transformOrigin:'540px 960px',transform:`translate(${c.x+shake}px,${c.y+shake*.3}px) scale(${c.zoom+zoomKick}) rotate(${c.rotate+shake*.06}deg)`}}>{children}</div>
}

/** Convert authored subject positions to camera tracking keys; no runtime state. */
export function trackingKeys(samples:{at:number;x:number;y:number}[],focus={x:540,y:960},zoom=1):CameraKey[]{
 return samples.map(p=>({at:p.at,zoom,x:(focus.x-p.x)*zoom,y:(focus.y-p.y)*zoom,rotate:0}));
}
/** Closed-form damped overshoot that settles exactly at the authored window end. */
export function springProgress(p:number,damping=7,frequency=12){if(p<=0)return 0;if(p>=1)return 1;const raw=(x:number)=>1-Math.exp(-damping*x)*Math.cos(frequency*x);return raw(p)/raw(1)}
