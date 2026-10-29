/* Exercise the actual page listeners and seek lifecycle in a small DOM.
 * This is an integration check, not browser/video visual playback.
 */
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const page=fs.readFileSync(process.argv[2],'utf8');
const source=page.match(/<script>([\s\S]*?)<\/script>/)[1];
class Element{
 constructor(tag='DIV'){this.tagName=tag.toUpperCase();this.listeners={};this.textContent='';this.children=[];this.value='';this.hidden=false;this.attributes={};}
 addEventListener(name,handler){(this.listeners[name]??=[]).push(handler);}
 fire(name,event={}){for(const handler of this.listeners[name]||[])handler({target:this,...event});}
 replaceChildren(...children){this.children=children;for(const child of children)child.parentElement=this;}
 append(...children){for(const child of children){this.children.push(child);child.parentElement=this;}}
 add(child){this.append(child);}
 contains(target){return this===target||this.children.some(child=>child.contains?.(target));}
 focus(){document.activeElement=this;}
 getContext(){return null;}
 setPointerCapture(id){this.capture=id;}
 hasPointerCapture(id){return this.capture===id;}
 releasePointerCapture(id){if(this.capture===id)this.capture=null;}
 setAttribute(key,value){this.attributes[key]=value;}
 closest(){return ['INPUT','TEXTAREA','SELECT'].includes(this.tagName)||this.isContentEditable?this:null;}
}
const nodes=new Map(),tags={'#video':'VIDEO','#panorama':'CANVAS','#videoPath':'INPUT','#timelinePath':'INPUT','#progress':'INPUT','#choiceTurns':'INPUT','#scene':'SELECT','#play':'BUTTON','#center':'BUTTON','#load':'BUTTON','#mute':'BUTTON'};
const get=id=>{if(!nodes.has(id))nodes.set(id,new Element(tags[id]));return nodes.get(id);};
const document={activeElement:null,hidden:false,listeners:{},querySelector:get,
 addEventListener(name,handler){(this.listeners[name]??=[]).push(handler);},
 createElement(tag){return new Element(tag);},createTextNode(text){const node=new Element();node.textContent=text;return node;}};
get('#viewer').append(get('#panorama'),get('#video'),get('#progress'),get('#mute'));get('#progress').type='range';
get('#playerControls').append(get('#play'),get('#center'));
get('#choiceTurnOptions').append(get('#choiceTurns'));get('#choiceTurns').type='checkbox';
get('#main').append(get('#viewer'),get('#playerControls'),get('#choices'));
const video=get('#video');let actualTime=13;
Object.assign(video,{duration:240,paused:true,readyState:2,seeking:false,currentSrc:'http://localhost/episodes/episode_001/renders/NEMI_Playable_EP001_r7_2160x1080_360_REVIEW.mp4',
 load(){},play(){this.paused=false;this.plays=(this.plays||0)+1;this.fire('play');return Promise.resolve();},pause(){this.paused=true;this.fire('pause');}});
Object.defineProperty(video,'currentTime',{get(){return actualTime;},set(value){actualTime=value;video.seeking=true;}});
const frames=[],fetches=[];
let testNow=1000;
const testWindow={listeners:{},addEventListener(name,handler){(this.listeners[name]??=[]).push(handler);},fire(name,event={}){for(const handler of this.listeners[name]||[])handler(event);}};
const context=vm.createContext({document,window:testWindow,location:{origin:'http://localhost',search:''},
 performance:{now:()=>testNow},
 URL,URLSearchParams,requestAnimationFrame(fn){frames.push(fn);},fetch(url){let resolve;const promise=new Promise(done=>resolve=done);fetches.push({url,resolve});return promise;},
 Option:function(text,value){return {text,value};},console,devicePixelRatio:1});
vm.runInContext(source,context);
// Projection pixels require a browser/GPU. Model a successful fresh-frame draw
// while exercising the real event/focus/seeking code; test failures separately.
vm.runInContext('drawVideoFrame=()=>true',context);
const canvas=get('#panorama'),input=get('#videoPath'),overlay=get('#transition');
function press(key,code,extra={}){
 let prevented=false;
 const event={key,code,repeat:false,ctrlKey:false,altKey:false,metaKey:false,target:document.activeElement,
  preventDefault(){prevented=true;},stopPropagation(){},...extra};
 for(const handler of document.listeners.keydown||[])handler(event);
 return prevented;
}
function paint(){const scheduled=frames.splice(0);for(const fn of scheduled)fn(100);}
function arrived(time=actualTime){actualTime=time;video.seeking=false;video.readyState=2;video.fire('seeked');paint();}
context.sampleTimeline={duration:240,fps:30,revision:'r7',media_basename:'NEMI_Playable_EP001_r7_2160x1080_360_REVIEW.mp4',
 scenes:Array.from({length:10},(_,key)=>({id:`s${key}`,start:key*24,end:(key+1)*24,name:`Scene ${key}`})),
 navigation:{mode:'youtube_digits',key_targets:Array.from({length:10},(_,key)=>({key,chapter:`s${key}`}))},
 interaction_scenes:[{id:'badge',start:0,end:48,objective:'Find my real star badge.',choices:[{key:2,label:'Sandwich',chapter:'s2'},{key:3,label:'Star badge',chapter:'s3'}]},
  {id:'notice',start:48,end:168,objective:'Choose the current notice.',choices:[{key:5,label:'Pudding',chapter:'s5'},{key:6,label:'Assembly',chapter:'s6'}]}]};
vm.runInContext('timelineData=sampleTimeline',context);video.fire('loadedmetadata');
vm.runInContext('delete timelineData.scenes[4].name',context);
assert.equal(vm.runInContext('navigationState().map.get(4).label',context),'Scene 4','Unlisted jumps must never expose an internal scene ID');
vm.runInContext('timelineData.scenes[4].name="Scene 4"',context);
assert.equal(get('#choices').children.length,2);assert.equal(get('#objective').textContent,'Find my real star badge.');
assert.equal(get('#keyLegend').children.length,10); // only inside closed review tools
assert(get('#choiceTurnOptions').hidden,'Existing unflagged school previews must not add a visible turn toggle');
video.readyState=1;video.fire('loadedmetadata');assert(!overlay.hidden,'Metadata alone must not reveal an old movie frame');
video.readyState=2;video.fire('loadeddata');assert(overlay.hidden);
// A clicked choice is replaced at arrival. Keep focus on the stable picture,
// otherwise the next physical number key would silently stop working.
get('#choices').children[1].focus();get('#choices').children[1].fire('click');
assert.equal(document.activeElement,canvas);assert.equal(actualTime,72);arrived();
assert(press('4','Digit4'));assert.equal(actualTime,96);arrived();
actualTime=13;video.seeking=false;vm.runInContext('updateInteraction(true)',context);
canvas.focus();vm.runInContext('yaw=.6;pitch=-.2',context);
assert(press('3','Digit3'));assert.equal(actualTime,72);assert(video.paused);assert.equal(video.plays||0,0);
assert.equal(vm.runInContext('yaw',context),.6);assert.equal(vm.runInContext('pitch',context),-.2);
assert(!overlay.hidden);assert.equal(get('#transitionTitle').textContent,'Star badge…');assert.equal(overlay.attributes['data-mode'],'seek');assert.doesNotMatch(get('#transitionText').textContent,/Going to|Opening/);
paint();assert(!overlay.hidden,'currentTime alone must not uncover stale pixels');
video.fire('canplay');paint();assert(!overlay.hidden,'canplay before seeked is not completed');
arrived();assert(overlay.hidden);assert.match(get('#status').textContent,/Opened 3.*Star badge.*Paused/);
assert.equal(get('#objective').textContent,'Choose the current notice.');

// All visible transport controls are DOM elements. Native AV controls swallow
// keys in the actual WebView, so the page deliberately does not expose them.
assert(!/<video\b[^>]*\bcontrols\b/.test(page));
get('#progress').focus();video.paused=false;assert(press('6','Digit6'));assert.equal(actualTime,144);assert(!video.paused);arrived();assert(overlay.hidden);
get('#mute').focus();assert(press('3','Digit3'));assert.equal(actualTime,72);arrived();
get('#mute').fire('click');assert.equal(video.muted,true);get('#mute').fire('click');assert.equal(video.muted,false);
get('#progress').value='96';get('#progress').fire('input');assert.equal(actualTime,96);video.fire('seeking');arrived();assert(overlay.hidden);
get('#play').focus();assert(press('5','Numpad5'));assert.equal(actualTime,120);arrived();
get('#viewer').focus();assert(press('0','Digit0'));assert.equal(actualTime,0);arrived();
input.focus();actualTime=17;assert(!press('4','Digit4'));assert.equal(actualTime,17);
get('#load').focus();assert(!press('4','Digit4'));assert.equal(actualTime,17);
canvas.focus();assert(!press('4','Digit4',{ctrlKey:true}));assert.equal(actualTime,17);
press('4','Digit4',{repeat:true});assert.equal(actualTime,17);
press('k','KeyK');assert(video.paused);press('k','KeyK');assert(!video.paused);press(' ','Space');assert(video.paused);

// The last rapid choice owns the loading screen, even if an old event arrives.
press('3','Digit3');const first=vm.runInContext('pendingSeek.token',context);
press('9','Digit9');const last=vm.runInContext('pendingSeek.token',context);assert(last>first);assert.equal(actualTime,216);
arrived(72);assert(!overlay.hidden);assert.equal(vm.runInContext('pendingSeek.token',context),last);
arrived(216);assert(overlay.hidden);assert.match(get('#status').textContent,/Opened 9/);
video.paused=false;press('3','Digit3');actualTime=72.45;video.seeking=false;video.fire('seeked');actualTime=72.8;paint();
assert(overlay.hidden,'Ordinary playback advancement before a delayed paint must not leave the route loading forever');assert(!video.paused);
press('3','Digit3');actualTime=120;video.fire('seeking');assert.match(get('#transitionText').textContent,/Scene 5/);
arrived(120);assert(overlay.hidden);assert.match(get('#status').textContent,/Opened scene.*Scene 5/);

video.duration=300;actualTime=17;press('3','Digit3');assert.equal(actualTime,17);assert.match(get('#status').textContent,/do not match/);
assert(!overlay.hidden);vm.runInContext('updateDigitLegend()',context);assert.equal(get('#keyLegend').children.length,0);
video.duration=240;video.currentSrc='http://localhost/other_r6.mp4';press('3','Digit3');assert.equal(actualTime,17);assert.match(get('#status').textContent,/different revision/);
video.currentSrc='http://localhost/NEMI_Playable_EP001_r7_2160x1080_360_REVIEW.mp4';
context.sampleTimeline.scenes[3].start=73;press('3','Digit3');assert.equal(actualTime,17);assert.match(get('#status').textContent,/does not align/);
context.sampleTimeline.scenes[3].start=72;
context.sampleTimeline.interaction_scenes[0].choices[0].chapter='s8';press('2','Digit2');assert.equal(actualTime,17);assert.match(get('#status').textContent,/wrong scene/);
context.sampleTimeline.interaction_scenes[0].choices[0].chapter='s2';
video.duration=NaN;press('5','Digit5');assert.equal(actualTime,17);

video.duration=240;get('#progress').focus();press('3','Digit3');video.fire('waiting');assert.match(get('#transitionState').textContent,/Buffering/);
arrived();assert(overlay.hidden);video.fire('waiting');assert(!overlay.hidden);video.fire('canplay');assert(overlay.hidden);
press('2','Digit2');video.fire('error');assert(!overlay.hidden);assert.equal(vm.runInContext('pendingSeek',context),null);assert.match(get('#status').textContent,/could not load/);
vm.runInContext('drawVideoFrame=()=>false',context);press('3','Digit3');arrived();
assert(!overlay.hidden);assert.match(get('#status').textContent,/360° picture could not display/);assert.doesNotMatch(get('#status').textContent,/Opened/);
vm.runInContext('drawVideoFrame=()=>true',context);
// Every drawing timeline starts in native mode. Local view assistance needs
// an explicit checkbox opt-in and must never masquerade as uploaded behavior.
context.enhancedTimeline=JSON.parse(JSON.stringify(context.sampleTimeline));
context.enhancedTimeline.world_renderer='drawing';context.enhancedTimeline.preview_choice_turns=true;
context.enhancedTimeline.title='Please get me out of my own drawing';
for(const scene of context.enhancedTimeline.scenes)scene.review_yaw=scene.id==='s1'?-76:scene.id==='s2'?76:0;
vm.runInContext('timelineData=enhancedTimeline',context);video.readyState=2;video.seeking=false;video.paused=true;video.fire('loadedmetadata');
assert(!get('#choiceTurnOptions').hidden);assert(!get('#choiceTurns').checked);
assert.equal(get('#storyTitle').textContent,context.enhancedTimeline.title);
assert.match(get('#choiceTurnNote').textContent,/Native behavior \(default\)/);
canvas.focus();vm.runInContext('yaw=.2;pitch=.15',context);
const defaultPlays=video.plays||0;
assert(press('1','Digit1'));assert.equal(actualTime,24);assert(video.paused);
assert.equal(video.plays||0,defaultPlays);assert.equal(vm.runInContext('yaw',context),.2);
assert.equal(vm.runInContext('pitch',context),.15);assert.equal(vm.runInContext('viewTurn',context),null);arrived();
get('#choiceTurns').checked=true;get('#choiceTurns').fire('change');
assert.match(get('#choiceTurnNote').textContent,/Local preview convenience/);
canvas.focus();vm.runInContext('yaw=.2;pitch=.15',context);const beforePlays=video.plays||0;
assert(press('1','Digit1'));assert.equal(actualTime,24);assert(video.paused);assert.equal(video.plays||0,beforePlays);
assert.equal(get('#transitionTitle').textContent,'Scene 1…');assert.equal(overlay.attributes['data-mode'],'seek');
vm.runInContext('advanceViewTurn(1170)',context);assert(vm.runInContext('yaw>.2&&yaw<76*Math.PI/180',context));
assert(!overlay.hidden,'The view animation must not reveal a stale pre-seek movie frame');
vm.runInContext('advanceViewTurn(1340)',context);
assert(Math.abs(vm.runInContext('yaw',context)-76*Math.PI/180)<1e-9);assert.equal(vm.runInContext('pitch',context),0);
arrived();assert(overlay.hidden);assert(video.paused);

// A later rapid choice owns both its loading token and the final view target.
testNow=1400;press('2','Digit2');const turningTwo=vm.runInContext('pendingSeek.token',context);
testNow=1450;press('1','Digit1');assert(vm.runInContext('pendingSeek.token',context)>turningTwo);
arrived(48);assert(!overlay.hidden);vm.runInContext('advanceViewTurn(1790)',context);arrived(24);
assert(overlay.hidden);assert(Math.abs(vm.runInContext('yaw',context)-76*Math.PI/180)<1e-9);

get('#choiceTurns').checked=false;get('#choiceTurns').fire('change');
assert.match(get('#choiceTurnNote').textContent,/Native behavior/);
vm.runInContext('yaw=.6;pitch=-.2',context);get('#choiceTurns').focus();press('2','Digit2');
assert.equal(actualTime,48);assert.equal(vm.runInContext('yaw',context),.6);assert.equal(vm.runInContext('pitch',context),-.2);
assert.equal(vm.runInContext('viewTurn',context),null);assert.match(get('#choiceTurnNote').textContent,/keep your viewing direction/);arrived();
press('0','Digit0');arrived();assert.equal(vm.runInContext('yaw',context),.6,'Unchecked native behavior must retain viewpoint even for key0');

get('#choiceTurns').checked=true;get('#choiceTurns').fire('change');testNow=2000;press('0','Digit0');
vm.runInContext('advanceViewTurn(2340)',context);arrived();
assert(Math.abs(vm.runInContext('yaw',context))<1e-9);assert.equal(vm.runInContext('pitch',context),0);

testNow=2400;canvas.focus();press('1','Digit1');assert(vm.runInContext('viewTurn!==null',context));
canvas.fire('pointerdown',{clientX:50,clientY:50,pointerId:1});assert(!vm.runInContext('dragging',context),'An in-flight choice must not accept a new stale-picture drag');assert(vm.runInContext('viewTurn!==null',context));arrived();
canvas.fire('pointerdown',{clientX:50,clientY:50,pointerId:1});assert.equal(vm.runInContext('viewTurn',context),null);
const draggedFrom=vm.runInContext('yaw',context);canvas.fire('pointermove',{clientX:80,clientY:50});
assert(Math.abs(vm.runInContext('yaw',context)-draggedFrom-.09)<1e-9);canvas.fire('pointerup');arrived();
testNow=2800;press('2','Digit2');assert(vm.runInContext('viewTurn!==null',context));press('d','KeyD');
assert.equal(vm.runInContext('viewTurn',context),null);vm.runInContext('heldKeys.clear()',context);arrived();

// A stale drag must never survive choosing, seeking, pointer loss or app blur.
canvas.fire('pointerdown',{clientX:50,clientY:50,pointerId:10,pointerType:'mouse',button:0});
assert(vm.runInContext('dragging',context));press('1','Digit1');assert(!vm.runInContext('dragging',context));assert.equal(canvas.capture,null);
const choiceYaw=vm.runInContext('yaw',context);canvas.fire('pointermove',{clientX:900,clientY:900,pointerId:10,pointerType:'mouse',buttons:1});assert.equal(vm.runInContext('yaw',context),choiceYaw);arrived();
canvas.fire('pointerdown',{clientX:50,clientY:50,pointerId:11,pointerType:'mouse',button:0});
const onePointerYaw=vm.runInContext('yaw',context);canvas.fire('pointermove',{clientX:200,clientY:50,pointerId:12,pointerType:'touch',buttons:1});assert.equal(vm.runInContext('yaw',context),onePointerYaw);
canvas.fire('pointermove',{clientX:200,clientY:50,pointerId:11,pointerType:'mouse',buttons:0});assert(!vm.runInContext('dragging',context));assert.equal(vm.runInContext('yaw',context),onePointerYaw);
for(const event of ['lostpointercapture','pointercancel']){
 canvas.fire('pointerdown',{clientX:50,clientY:50,pointerId:13,pointerType:'touch'});canvas.fire(event,{pointerId:13});assert(!vm.runInContext('dragging',context));
}
canvas.fire('pointerdown',{clientX:50,clientY:50,pointerId:14,pointerType:'touch'});testWindow.fire('blur');assert(!vm.runInContext('dragging',context));assert.equal(vm.runInContext('viewTurn',context),null);
canvas.fire('pointerdown',{clientX:50,clientY:50,pointerId:15,pointerType:'touch'});document.hidden=true;for(const handler of document.listeners.visibilitychange||[])handler();assert(!vm.runInContext('dragging',context));document.hidden=false;
canvas.fire('pointerdown',{clientX:50,clientY:50,pointerId:16,pointerType:'touch'});get('#progress').value='48';get('#progress').fire('input');assert(!vm.runInContext('dragging',context));video.fire('seeking');arrived();

// Authored enhanced handoffs bridge ordinary playback only. They do not
// become a camera-follow loop or change native mode/paused-seek behavior.
context.flowTimeline=JSON.parse(JSON.stringify(context.enhancedTimeline));
context.flowTimeline.preview_goal='Get Nemi to the desk beyond the page.';
context.flowTimeline.preview_handoffs=[{at:24,yaw:-76,duration:.9},{at:48,yaw:76,duration:.9}];
vm.runInContext('timelineData=flowTimeline',context);video.seeking=false;video.paused=false;video.fire('loadedmetadata');
assert(!get('#choiceTurns').checked,'Loading another drawing timeline must restore native mode');
get('#choiceTurns').checked=true;get('#choiceTurns').fire('change');
actualTime=23.8;testNow=5000;video.fire('timeupdate');vm.runInContext('yaw=0;pitch=.2',context);
actualTime=24.1;video.fire('timeupdate');assert.equal(vm.runInContext('viewTurn.kind',context),'handoff');assert.equal(vm.runInContext('viewTurn.duration',context),900);
vm.runInContext('advanceViewTurn(5450)',context);assert(vm.runInContext('yaw>0&&yaw<76*Math.PI/180',context));
vm.runInContext('advanceViewTurn(5900)',context);assert(Math.abs(vm.runInContext('yaw',context)-76*Math.PI/180)<1e-9);assert.equal(vm.runInContext('pitch',context),0);
actualTime=24.2;video.fire('timeupdate');assert.equal(vm.runInContext('viewTurn',context),null,'A handoff must fire only at its crossing');
assert.equal(get('#objective').textContent,context.flowTimeline.preview_goal);
actualTime=48.1;video.fire('timeupdate');assert.equal(vm.runInContext('viewTurn',context),null,'A large timeline discontinuity must not infer a natural handoff');
actualTime=47.8;video.fire('timeupdate');testNow=6000;canvas.fire('pointerdown',{clientX:40,clientY:40,pointerId:20,pointerType:'touch'});canvas.fire('pointerup',{pointerId:20});
actualTime=48.1;video.fire('timeupdate');assert.equal(vm.runInContext('viewTurn',context),null,'Recent manual looking takes priority over a handoff');
actualTime=47.8;video.fire('timeupdate');testNow=8000;video.paused=true;actualTime=48.1;video.fire('timeupdate');assert.equal(vm.runInContext('viewTurn',context),null,'Pausing never triggers a handoff');
video.paused=false;actualTime=47.8;video.fire('timeupdate');actualTime=48.1;video.fire('timeupdate');assert.equal(vm.runInContext('viewTurn.kind',context),'handoff');video.fire('pause');assert.equal(vm.runInContext('viewTurn',context),null,'Pausing cancels a natural helper turn');
get('#choiceTurns').checked=false;get('#choiceTurns').fire('change');video.paused=false;actualTime=47.8;video.fire('timeupdate');vm.runInContext('yaw=.4;pitch=-.3',context);actualTime=48.1;video.fire('timeupdate');assert.equal(vm.runInContext('viewTurn',context),null);assert.equal(vm.runInContext('yaw',context),.4);assert.equal(vm.runInContext('pitch',context),-.3);
get('#choiceTurns').checked=true;get('#choiceTurns').fire('change');canvas.focus();actualTime=47.8;video.fire('timeupdate');testNow=10000;press('2','Digit2');arrived();video.fire('timeupdate');assert.notEqual(vm.runInContext('viewTurn?.kind',context),'handoff','Seeking past the same boundary never adds a natural helper turn');
vm.runInContext('viewTurn=null',context);context.flowTimeline.preview_handoffs[0].duration=0;assert(!vm.runInContext('navigationState().ok',context));context.flowTimeline.preview_handoffs[0].duration=.9;
context.flowTimeline.preview_handoffs.push(null);assert(!vm.runInContext('navigationState().ok',context));context.flowTimeline.preview_handoffs.pop();
const goal=context.flowTimeline.preview_goal;context.flowTimeline.preview_goal={};assert(!vm.runInContext('navigationState().ok',context));context.flowTimeline.preview_goal=goal;
actualTime=13;video.seeking=false;vm.runInContext('updateInteraction(true)',context);assert.equal(get('#objective').textContent,context.flowTimeline.preview_goal);actualTime=72.1;video.fire('timeupdate');assert.equal(get('#objective').textContent,context.flowTimeline.preview_goal,'The overall escape goal remains stable between content sections');
testWindow.matchMedia=()=>({matches:true});vm.runInContext('yaw=0;pitch=.3;turnToward(90)',context);assert.equal(vm.runInContext('viewTurn',context),null);assert.equal(vm.runInContext('yaw',context),-Math.PI/2);assert.equal(vm.runInContext('pitch',context),0);delete testWindow.matchMedia;
assert.equal(vm.runInContext('choiceProgressLabel("Take the tear",2)',context),'Taking the tear…');assert.equal(vm.runInContext('choiceProgressLabel("Try the door",1)',context),'Trying the door…');

// The opt-in does not permanently change the default viewer after loading R9.
vm.runInContext('timelineData=sampleTimeline',context);video.fire('loadedmetadata');
assert(get('#choiceTurnOptions').hidden);assert(!get('#choiceTurns').checked);
assert.equal(get('#storyTitle').textContent,'Help Nemi save the school day');
context.noTitleDrawing=JSON.parse(JSON.stringify(context.enhancedTimeline));delete context.noTitleDrawing.title;context.noTitleDrawing.episode_id='episode_002';
vm.runInContext('timelineData=noTitleDrawing',context);video.fire('loadedmetadata');
assert.equal(get('#storyTitle').textContent,'Please get me out of my own drawing','The full drawing film must never inherit a school title when the compiler omits title');
context.noTitleDrawing.episode_id='episode_003';vm.runInContext('turnTimeline=null;configureChoiceTurns()',context);
assert.equal(get('#storyTitle').textContent,'Help Nemi save the school day','The episode-specific fallback must not invent a title for unrelated episodes');
vm.runInContext('timelineData=sampleTimeline',context);video.fire('loadedmetadata');
console.log('Enhanced local choice turns passed: opt-in toggle, directed targets,340ms interpolation, native-view/pause preservation, latest rapid choice, restart and drag/WASD cancellation.');
console.log('Continuous preview checks passed: authored natural handoffs, stable goal, native/pause/seek preservation, manual-look priority and stale-pointer cleanup.');
console.log('Actual-page checks passed: DOM playback/progress focus, click-to-key continuity, progressive choices, validated destinations, stale revision blocking, seeked-before-reveal, latest rapid choice, buffering/errors, pause/view preservation and keyboard guards.');
(async()=>{
 // A slow earlier timeline request must not replace a newer selected pair.
 get('#videoPath').value='old.mp4';get('#timelinePath').value='old.json';
 const firstLoad=vm.runInContext('load()',context);
 get('#videoPath').value='new.mp4';get('#timelinePath').value='new.json';
 const secondLoad=vm.runInContext('load()',context);
 const latest={...context.sampleTimeline,revision:'new',media_basename:'new.mp4'};
 fetches[2].resolve({ok:true,json:()=>Promise.resolve(latest)});await secondLoad;
 assert.match(video.src,/new\.mp4\?review=new$/);
 fetches[1].resolve({ok:true,json:()=>Promise.resolve({...latest,revision:'old',media_basename:'old.mp4'})});await firstLoad;
 assert.match(video.src,/new\.mp4\?review=new$/);assert.equal(vm.runInContext('timelineData.revision',context),'new');
 // Even startup current.json discovery may finish after manual source loading.
 fetches[0].resolve({ok:true,json:()=>Promise.resolve({video:'startup.mp4',timeline:'startup.json'})});
 await new Promise(done=>setImmediate(done));
 assert.equal(get('#videoPath').value,'new.mp4');assert.equal(get('#timelinePath').value,'new.json');assert.match(video.src,/new\.mp4\?review=new$/);
 console.log('Async source-pair checks passed: newer selection owns timeline/movie and stale startup discovery is ignored.');
 if(process.argv[3]){
  context.productionTimeline=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));
  vm.runInContext('timelineData=productionTimeline',context);
  video.duration=context.productionTimeline.duration;video.currentSrc='http://localhost/'+context.productionTimeline.media_basename;video.readyState=2;video.seeking=false;video.fire('loadedmetadata');
  assert(vm.runInContext('navigationState().ok',context));
  let choices=0;
  for(const action of context.productionTimeline.interaction_scenes){
   actualTime=action.start+.1;video.fire('timeupdate');
   assert.equal(get('#objective').textContent,context.productionTimeline.preview_goal||action.objective);assert.equal(get('#choices').children.length,action.choices.length);
   for(const choice of action.choices){
    actualTime=action.start+.1;video.seeking=false;canvas.focus();press(String(choice.key),'Digit'+choice.key);
    assert.equal(actualTime,video.duration*choice.key/10);assert.equal(overlay.attributes['data-mode'],'seek');assert(get('#transitionTitle').textContent.endsWith('…'));assert.doesNotMatch(get('#transitionTitle').textContent,/^Opening|Going to/);arrived();assert(overlay.hidden);choices++;
   }
  }
  console.log(`Current production contract passed: ${context.productionTimeline.interaction_scenes.length} task panels and ${choices} labeled choices match their percentage destinations.`);
 }
})().catch(error=>{console.error(error);process.exitCode=1;});
