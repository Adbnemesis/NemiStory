import {existsSync,readFileSync} from 'node:fs';
import {resolve,relative} from 'node:path';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import type {ShortConfig,Dialogue} from '../shared/utilities/types';
import {expressions} from '../shared/utilities/types';
const finite=(v:unknown)=>typeof v==='number'&&Number.isFinite(v);
const keys=(obj:object,allowed:string[],path:string,errors:string[])=>{for(const k of Object.keys(obj))if(!allowed.includes(k))errors.push(`${path}: unknown field ${k}`)};
export function validate(c:ShortConfig,root:string,checkFiles=true):string[]{
 const e:string[]=[];const err=(s:string)=>e.push(`${c.id}: ${s}`);const ids=new Set<string>();
 keys(c,['version','id','author','title','format','duration','fps','width','height','promise','want','choice','consequence','payoff','music','shots','events','sfx','dialogue','blinks','loop','debugSafeArea'],'config',e);
 if(c.version!==1||!['adb','nemi'].includes(c.author)||!c.id.match(/^[A-Za-z][A-Za-z0-9-]+$/))err('invalid identity/version');
 if(!finite(c.duration)||c.duration<8||c.duration>22||c.fps!==30||c.width!==1080||c.height!==1920)err('invalid duration/export settings');
 for(const k of ['promise','want','choice','consequence','payoff'] as const)if(!c[k]?.trim())err(`missing direction ${k}`);
 const asset=(file:string,duration:number,start=0,hash?:string)=>{
  const base=resolve(root,'public'),p=resolve(base,file);if(relative(base,p).startsWith('..')||file.startsWith('/')){err('asset must stay inside public: '+file);return}
  if(!checkFiles)return;
  if(!existsSync(p)){err('missing asset '+file);return}
  if(hash&&createHash('sha256').update(readFileSync(p)).digest('hex')!==hash)err('changed asset hash '+file);
  const d=Number(execFileSync('ffprobe',['-v','error','-show_entries','format=duration','-of','default=noprint_wrappers=1:nokey=1',p],{encoding:'utf8'}));
  if(start+duration>d+.04)err(`audio exceeds source ${file}: ${start+duration} > ${d}`);
 };
 let end=0;
 for(const s of c.shots){
  keys(s,['id','start','end','focus','background','expression','gesture','caption','prop','propValue','actor','camera','transition','stepped','cast'],'shot '+s.id,e);
  if(ids.has(s.id))err('duplicate shot '+s.id);ids.add(s.id);
  if(!finite(s.start)||!finite(s.end)||s.end<=s.start||Math.abs(s.start-end)>.001)err('noncontiguous shot '+s.id);end=s.end;
  if(!s.focus?.trim()||!expressions.includes(s.expression))err('invalid focus/expression '+s.id);
  if(!['rest','explain','point','celebrate','panic','draw','hold','facepalm'].includes(s.gesture))err('invalid gesture '+s.id);
  if(!['desk','studio','gym','stairs','gradient','speed','spotlight','void','bedroom','street','school','heaven','dramatic'].includes(s.background))err('unknown background '+s.id);
  if(!['none','barbell','tablet','machine','clock','pixel','papers','notification','stairs'].includes(s.prop))err('unknown prop '+s.id);
  if(s.transition&&!['cut','whip','object','snap','spin','smear','match'].includes(s.transition))err('unknown transition '+s.id);
  keys(s.actor,['x','y','scale','headTilt','gaze','lean'],'actor',e);
  if(!finite(s.actor.x)||!finite(s.actor.y)||!finite(s.actor.scale)||s.actor.scale<=0||s.actor.scale>7)err('invalid actor '+s.id);
  for(const n of [s.actor.headTilt??0,s.actor.lean??0,...(s.actor.gaze??[0,0])])if(!finite(n))err('nonfinite actor control');
  if(!s.camera.length)err('missing camera');let at=-1;
  for(const k of s.camera){keys(k,['at','zoom','x','y','rotate'],'camera',e);if(!Object.values(k).every(finite)||k.zoom<.5||k.zoom>2.5||k.at<at||k.at<s.start-.001||k.at>s.end+.001)err('invalid camera key '+s.id);at=k.at}
  const castIds=new Set<string>();for(const member of s.cast??[]){keys(member,['id','author','expression','gesture','actor','prop','propValue'],'cast member',e);if(castIds.has(member.id)||!member.id||!['adb','nemi'].includes(member.author)||!expressions.includes(member.expression)||!['rest','explain','point','celebrate','panic','draw','hold','facepalm'].includes(member.gesture))err('invalid cast member');castIds.add(member.id);keys(member.actor,['x','y','scale','headTilt','gaze','lean'],'cast actor',e);if(![member.actor.x,member.actor.y,member.actor.scale].every(finite)||member.actor.scale<=0||member.actor.scale>7)err('invalid cast actor');if(member.prop&&!['none','barbell','tablet','machine','clock','pixel','papers','notification','stairs'].includes(member.prop))err('invalid cast prop');}
  if(s.caption){keys(s.caption,['text','style','at','words','y','size','color'],'caption',e);if(!['pop','punchline','reaction','beat','words'].includes(s.caption.style)||!s.caption.text)err('invalid caption');if((s.caption.text.split('\n').some(line=>line.length>26)))err('caption too long for portrait safe region '+s.id);if(s.caption.style==='words'&&!s.caption.words?.length)err('word caption needs timing');for(const w of s.caption.words??[])if(w.end<=w.at||w.at<s.start||w.end>s.end)err('word caption outside shot')}
 }
 if(Math.abs(end-c.duration)>.001||!c.shots.length)err('shots do not cover duration');
 const events=new Map<string,number>();
 for(const v of c.events){keys(v,['id','at','kind','strength','duration'],'event',e);if(events.has(v.id)||!finite(v.at)||v.at<0||v.at>=c.duration)err('invalid event '+v.id);if(!['impact','pop','whoosh','flash','cut','expression','drop','phrase'].includes(v.kind))err('unknown event kind');if(v.strength!==undefined&&(!finite(v.strength)||v.strength<0||v.strength>3))err('invalid event strength');if(v.duration!==undefined&&(!finite(v.duration)||v.duration<=0||v.duration>2))err('invalid FX lifetime');events.set(v.id,v.at)}
 const knownSfx=new Map<string,string>((checkFiles?JSON.parse(readFileSync(resolve(root,'shared/audio/sfx-catalog.json'),'utf8')):[]).map((s:{file:string;sha256:string})=>[s.file,s.sha256]));
 const soundIds=new Set<string>();
 for(const s of [...c.sfx,...c.dialogue]){
  keys(s,['id','file','at','duration','gainDb','event','sourceStart','sha256',...('text' in s?['text','author','mouth','words']:[])],'sound',e);
  if(soundIds.has(s.id))err('duplicate sound '+s.id);soundIds.add(s.id);
  if(![s.at,s.duration,s.gainDb,s.sourceStart??0].every(finite)||s.at<0||s.duration<=0||s.at+s.duration>c.duration+.04||s.gainDb>0||s.gainDb< -60)err('invalid sound interval/gain '+s.id);
  if(s.event&&(!events.has(s.event)||Math.abs(events.get(s.event)!-s.at)>.101))err('invalid event-linked SFX '+s.id);
  if(checkFiles&&!('text' in s)&&!knownSfx.has(s.file))err('SFX needs existing-library provenance in catalog '+s.id);
  asset(s.file,s.duration,s.sourceStart??0,s.sha256??knownSfx.get(s.file));
  if('mouth' in s){const d=s as Dialogue;if(d.author!==c.author&&!c.shots.some(s=>s.cast?.some(m=>m.author===d.author&&d.at<s.end&&d.at+d.duration>s.start)))err('dialogue identity has no actor');let last=-1;for(const m of d.mouth){keys(m,['start','end','shape'],'mouth',e);if(m.start<last||m.end<=m.start||m.end>s.duration||!['open','wide','round','closed'].includes(m.shape))err('mouth overlap/outside voice '+s.id);last=m.end}for(const w of d.words)if(w.start<0||w.end>s.duration||w.end<=w.start)err('word timing outside voice '+s.id); }
 }
 if(c.music){const m=c.music;keys(m,['file','gainDb','cues','sourceStart','duration','duck'],'music',e);if(!finite(m.gainDb)||m.gainDb>0||!finite(m.duration)||m.duration>c.duration+.04||m.sourceStart<0)err('invalid music settings');asset(m.file,m.duration,m.sourceStart,m.cues.sourceHash);if(!finite(m.cues.bpm)||m.cues.bpm<=0||!finite(m.cues.offset)||m.cues.offset<0||Math.abs(m.cues.sourceStart-m.sourceStart)>.001||m.cues.duration<m.duration-.04)err('music cues use wrong segment/clock');if(m.cues.rate!==1)err('new analysis required for source rate');for(const field of ['beats','strongBeats','drops','phrases','choruses','accents','onsets'] as const){let last=-1;for(const v of m.cues[field]){if(!finite(v)||v<0||v<last||v>m.cues.duration)err('invalid '+field);last=v}}if(m.cues.status!=='editorial-reviewed')err('music cue map not reviewed');for(const w of m.duck){keys(w,['start','end','gainDb'],'duck window',e);if(w.end<=w.start||w.start<0||w.end>c.duration||w.gainDb>0)err('invalid duck window')}}
 for(const b of c.blinks)if(b.start<0||b.end<=b.start||b.end>c.duration)err('invalid blink interval');
 if(!['visual','semantic','none'].includes(c.loop.kind)||!c.loop.note)err('invalid loop notes');
 return e;
}
