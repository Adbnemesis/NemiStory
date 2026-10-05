import {base,shot,camera} from '../../shared/utilities/builders';
import {dialogue} from '../../shared/audio/dialogue';
import timing1 from '../assets/voice/sketch_01.timing.json';
import timing2 from '../assets/voice/sketch_02.timing.json';
import cues from '../music/trust-reference.json';
import type {CueMap} from '../../shared/utilities/types';
const c=base('Nemi-QuickSketch','nemi','A quick sketch. Suddenly tomorrow.',11);
c.format='dialogue-loop';c.promise='An animator loses time to one small sketch';c.want='Draw something fast before bed';c.choice='Fix just one detail';c.consequence='Night vanishes';c.payoff='Why is it tomorrow?';
c.music={file:'audio/music/trust-reference.wav',sourceStart:0,duration:11,gainDb:-15,cues:cues as CueMap,duck:[{start:.15,end:2.01,gainDb:-10},{start:6.1,end:7.32,gainDb:-10}]};
c.dialogue=[dialogue('nemi','sketch_01',.15,'Just a quick sketch.',1.76,timing1.sourceHash,timing1.words),dialogue('nemi','sketch_02',6.1,'Why is it tomorrow?',1.12,timing2.sourceHash,timing2.words)];
c.shots=[
 shot('quick',0,2.05,{focus:'Spoken tiny intention, hand in contact with the drawing tool',background:'studio',expression:'happy',gesture:'draw',prop:'tablet',propValue:'blank',caption:{text:'A quick sketch.',style:'pop',size:90},actor:{x:460,y:1040,scale:2.55,headTilt:4,gaze:[.6,.3]},camera:camera(0,2.05,1,1.02)}),
 shot('more',2.05,3.7,{focus:'First shape appears as she considers improving it',background:'studio',expression:'confused',gesture:'draw',prop:'tablet',propValue:'detail',caption:{text:'Just fix\nthe hair…',style:'reaction',size:84},actor:{x:460,y:1040,scale:2.55,headTilt:-9,gaze:[.6,.3]},camera:camera(2.05,3.7,1.02,1.035)}),
 shot('spiral',3.7,5.2,{focus:'A single detail gets more attention than the entire sketch',background:'spotlight',expression:'smug',gesture:'hold',prop:'pixel',propValue:'huge',caption:{text:'…and the eyes.',style:'pop',size:86},actor:{x:480,y:1070,scale:2.85,headTilt:5,gaze:[0,.5]},camera:camera(3.7,5.2,1,1.02),transition:'object'}),
 shot('morning',5.2,6.1,{focus:'Clock becomes the only audience focus',background:'studio',expression:'shocked',gesture:'panic',prop:'clock',propValue:'06:02 AM',caption:{text:'WAIT.',style:'punchline',size:120,color:'#ffe0a3'},actor:{x:480,y:1110,scale:2.65,headTilt:7},camera:camera(5.2,6.1,1,1),transition:'snap'}),
 shot('tomorrow',6.1,8,{focus:'Read the eye reaction during the exact approved voice line',background:'studio',expression:'deadpan',gesture:'rest',prop:'clock',propValue:'06:02 AM',caption:{text:'Why is it\ntomorrow?',style:'reaction',size:89},actor:{x:480,y:1110,scale:3.3},camera:camera(6.1,8,1,1.015)}),
 shot('lesson',8,10.05,{focus:'She pauses, then chooses another sketch anyway',background:'studio',expression:'embarrassed',gesture:'hold',prop:'tablet',propValue:'detail',caption:{text:'Never again.\nProbably.',style:'reaction',size:79},actor:{x:460,y:1040,scale:2.55,headTilt:-5},camera:camera(8,10.05,1,1)}),
 shot('reset',10.05,11,{focus:'Return to the original blank canvas and tiny intention',background:'studio',expression:'happy',gesture:'draw',prop:'tablet',propValue:'blank',caption:{text:'A quick sketch.',style:'pop',size:90,at:0},actor:{x:460,y:1040,scale:2.55,headTilt:4,gaze:[.6,.3]},camera:camera(10.05,11,1,1)})
];
c.events=[{id:'draw',at:2.05,kind:'pop',strength:.25},{id:'detail-wipe',at:3.7,kind:'whoosh'},{id:'morning',at:5.2,kind:'impact',strength:.65},{id:'recovery',at:8,kind:'expression'}];
c.sfx=[{id:'draw-pop',file:'audio/sfx/pop.mp3',sourceStart:0.1,at:2.05,duration:.35,gainDb:-11,event:'draw'},{id:'stylus-wipe',file:'audio/sfx/whoosh.mp3',sourceStart:0.1,at:3.63,duration:14/30,gainDb:-14,event:'detail-wipe'},{id:'morning-ping',file:'audio/sfx/ping.mp3',sourceStart:0.3,at:5.2,duration:.8,gainDb:-7,event:'morning'}];
c.blinks=[{start:2.9,end:3.05},{start:8.8,end:8.96}];c.loop={kind:'visual',note:'First/final picture equals; spoken restart and reference music seam remain semantic.'};export default c;
