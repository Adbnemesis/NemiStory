import type {Author,Dialogue} from '../utilities/types';
export function dialogue(author:Author,id:string,at:number,text:string,duration:number,hash:string,words:{word:string;start:number;end:number}[]):Dialogue{
 return {id,file:`audio/voice/${id}.wav`,at,text,duration,gainDb:-2,author,sha256:hash,words:words.map(w=>({text:w.word.trim(),start:w.start,end:w.end})),mouth:words.map((w,i)=>({start:w.start+.02,end:Math.max(w.start+.03,w.end-.025),shape:i%3===1?'wide':i%3===2?'round':'open'}))};
}
