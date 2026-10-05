import {catalog} from '../src/catalog';
import {mkdirSync,writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(fileURLToPath(new URL('..',import.meta.url)));
for(const c of catalog){
 const lines=[`# ${c.title}`,'',`Promise: ${c.promise}`,`Want: ${c.want}`,`Choice: ${c.choice}`,`Consequence: ${c.consequence}`,`Payoff: ${c.payoff}`,'',`Format: ${c.format}; ${c.duration}s / ${c.fps}fps / 1080×1920.`,`Loop: ${c.loop.kind} — ${c.loop.note}`,'','## Thought beats / storyboard',''];
 for(const s of c.shots){lines.push(`### ${s.id} — ${s.start.toFixed(3)}–${s.end.toFixed(3)}s`,'',`Audience focus: ${s.focus}`,`Audio: ${c.music?c.music.file:'intentional silence outside dialogue/FX'}`,`Voice: ${c.dialogue.filter(d=>d.at<s.end&&d.at+d.duration>s.start).map(d=>d.text).join(' / ')||'none'}`,`Camera: ${JSON.stringify(s.camera)}`,`Expression / hands: ${s.expression} / ${s.gesture}`,`SFX: ${c.sfx.filter(d=>d.at>=s.start-.1&&d.at<s.end).map(d=>`${d.id}@${d.at.toFixed(3)}s (${d.gainDb}dB source gain) → ${d.event}`).join('; ')||'intentional silence'}`,`Caption: ${s.caption?.text.replaceAll('\n',' / ')??'none'}`,`Transition: ${s.transition??'cut'}`,`Background / prop: ${s.background} / ${s.prop} ${s.propValue??''}`,'');}
 lines.push('## Second-by-second retention intent','');
 for(let sec=0;sec<Math.ceil(c.duration);sec++){const s=c.shots.find(s=>sec>=s.start&&sec<s.end)??c.shots.at(-1)!;lines.push(`- ${sec}–${Math.min(sec+1,c.duration).toFixed(2)}s: ${s.focus}.`)}
 lines.push('','These are production intentions, not proof of viewer retention. Inspect the encoded render before acceptance.');
 for(const folder of ['scripts','storyboards'])mkdirSync(resolve(root,c.author,folder),{recursive:true});
 writeFileSync(resolve(root,c.author,'storyboards',c.id+'.md'),lines.join('\n')+'\n');
 writeFileSync(resolve(root,c.author,'scripts',c.id+'.md'),`# ${c.title}\n\n${c.dialogue.map(d=>`${d.at.toFixed(3)}s — ${d.text}`).join('\n')||'No spoken character dialogue. Music and visual punchline lead.'}\n\n${c.shots.map(s=>`${s.start.toFixed(3)}–${s.end.toFixed(3)}: ${s.focus}`).join('\n')}\n`);
 writeFileSync(resolve(root,c.author,'storyboards',c.id+'.timeline.json'),JSON.stringify(c,null,2));
}
console.log('Saved four source scripts, storyboards, second-by-second intent and normalized timelines.');
