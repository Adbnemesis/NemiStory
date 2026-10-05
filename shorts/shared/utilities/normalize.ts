import type {ShortConfig} from './types';
export function normalize(c:ShortConfig):ShortConfig{
 const f=(t:number)=>Math.round(t*c.fps)/c.fps;
 return {...c,duration:f(c.duration),events:c.events.map(e=>({...e,at:f(e.at)})),shots:c.shots.map(s=>({...s,start:f(s.start),end:f(s.end),camera:s.camera.map(k=>({...k,at:f(k.at)})),caption:s.caption?{...s.caption,at:s.caption.at===undefined?undefined:f(s.caption.at),words:s.caption.words?.map(w=>({...w,at:f(w.at),end:f(w.end)}))}:undefined})),sfx:c.sfx.map(s=>({...s,at:f(s.at),duration:f(s.duration)})),dialogue:c.dialogue.map(d=>({...d,at:f(d.at),duration:f(d.duration),mouth:d.mouth.map(m=>({...m,start:f(m.start),end:f(m.end)})),words:d.words.map(w=>({...w,start:f(w.start),end:f(w.end)}))})),blinks:c.blinks.map(b=>({...b,start:f(b.start),end:f(b.end)}))};
}
