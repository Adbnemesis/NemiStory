import {base,shot,camera} from '../../shared/utilities/builders';
import {dialogue} from '../../shared/audio/dialogue';
import timing1 from '../assets/voice/machine_01.timing.json';
import timing2 from '../assets/voice/machine_02.timing.json';
const c=base('ADB-ShipTheMachine','adb','Works on my machine? Ship the machine.',10);
c.format='dialogue-visual-punchline';c.promise='Literal solution to a programmer excuse';c.want='Make a successful deployment';c.choice='Treat the excuse literally';c.consequence='Hardware becomes the deliverable';c.payoff='Ship the entire machine';
c.dialogue=[dialogue('adb','machine_01',.2,'It works on my machine.',1.44,timing1.sourceHash,timing1.words),dialogue('adb','machine_02',5.4,'Great. Ship the machine.',1.6,timing2.sourceHash,timing2.words)];
c.shots=[
 shot('claim',0,1.9,{focus:'Confident ADB and his actual computer, spoken claim',background:'desk',expression:'smug',gesture:'rest',prop:'machine',caption:{text:'WORKS ON\nMY MACHINE.',style:'pop',size:82},actor:{x:490,y:1140,scale:3.3,headTilt:-4},camera:camera(0,1.9,1,1.025)}),
 shot('deploy',1.9,3.5,{focus:'One attempt to deploy',background:'desk',expression:'neutral',gesture:'point',prop:'notification',propValue:'Deploying…',caption:{text:'SHIP IT.',style:'beat',size:104,color:'#afffd2'},actor:{x:400,y:1110,scale:2.9,headTilt:3,gaze:[.6,.4]},camera:camera(1.9,3.5,1,1)}),
 shot('error',3.5,5.4,{focus:'The server refuses; read before the dry response',background:'desk',expression:'deadpan',gesture:'rest',prop:'notification',propValue:'error: works nowhere else',caption:{text:'OF COURSE.',style:'reaction',size:94,color:'#ff9e87'},actor:{x:490,y:1140,scale:3.7},camera:camera(3.5,5.4,1,1.025),transition:'snap'}),
 shot('literal',5.4,7.65,{focus:'A literal box appears around the original computer, synced to speech',background:'desk',expression:'deadpan',gesture:'explain',prop:'machine',propValue:'ship',caption:{text:'SHIP THE\nMACHINE.',style:'punchline',size:96,at:6.28},actor:{x:490,y:1040,scale:2.8,headTilt:-3},camera:camera(5.4,7.65,1,1),transition:'match'}),
 shot('hold',7.65,9.1,{focus:'Final machine joke breathes, unimpressed face stays still',background:'desk',expression:'sideEye',gesture:'rest',prop:'machine',propValue:'ship',caption:{text:'Problem solved.',style:'reaction',size:87},actor:{x:490,y:1040,scale:2.8,headTilt:-3},camera:camera(7.65,9.1,1,1)}),
 shot('reset',9.1,10,{focus:'Return to original programmer confidence, semantic restart',background:'desk',expression:'smug',gesture:'rest',prop:'machine',caption:{text:'WORKS ON\nMY MACHINE.',style:'pop',size:82,at:0},actor:{x:490,y:1140,scale:3.3,headTilt:-4},camera:camera(9.1,10,1,1)})
];
c.events=[{id:'deploy-click',at:1.9,kind:'pop',strength:.3},{id:'server-error',at:3.5,kind:'impact',strength:.55},{id:'box',at:6.28,kind:'pop',strength:.35}];
c.sfx=[{id:'deploy',file:'audio/sfx/click.mp3',sourceStart:0.03333333333333333,at:1.9,duration:.3,gainDb:-6,event:'deploy-click'},{id:'error',file:'audio/sfx/error.mp3',sourceStart:0.6,at:3.5,duration:.65,gainDb:0,event:'server-error'},{id:'box-pop',file:'audio/sfx/pop.mp3',sourceStart:0.1,at:6.28,duration:.35,gainDb:-13,event:'box'}];
c.blinks=[{start:2.9,end:3.03},{start:8.55,end:8.69}];c.loop={kind:'semantic',note:'The confident claim restarts after the literal solution; voice sentence restart is intentional.'};export default c;
