import type {Author,Caption} from '../utilities/types';
import {pulse,clamp} from '../utilities/motion';
export function PopCaption({caption,t,start,author}:{caption:Caption;t:number;start:number;author:Author}){
 const local=t-(caption.at??start);if(local<0)return null;
 const words=caption.style==='words'&&caption.words?caption.words.filter(w=>t>=w.at&&t<w.end).map(w=>w.text).join(' '):caption.text;
 if(!words)return null;
 const s=1+pulse(t,caption.at??start,.25)*.07;
 const dark=author==='adb';
 return <div data-caption style={{position:'absolute',left:100,right:190,top:caption.y??195,textAlign:'center',fontFamily:caption.style==='punchline'||dark?'Impact':'Gochi',fontSize:caption.size??(caption.style==='punchline'?98:74),lineHeight:1.06,whiteSpace:'pre-line',fontWeight:400,color:caption.color??(dark?'#edfff6':'#fff5ea'),WebkitTextStroke:'3px #222831',paintOrder:'stroke fill',textShadow:'0 7px 0 #222831',transform:`scale(${s})`,letterSpacing:dark?1:0}}>{words}</div>
}
export const WordByWordCaption=PopCaption;
export const PunchlineText=PopCaption;
export const ReactionText=PopCaption;
export const BeatCaption=PopCaption;
