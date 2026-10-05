import {test} from 'node:test';import assert from 'node:assert/strict';
import {beatAt,beatProgress,sliceCueMap} from '../shared/beat-sync';
import {pulse,cameraAt,kick} from '../shared/utilities/motion';
import {duckDb} from '../shared/audio/AudioTrack';
import {normalize} from '../shared/utilities/normalize';
import {catalog} from '../src/catalog';
import {validate} from '../tools/validation';
import {handAnchor} from '../shared/utilities/Character';
import {profiles} from '../shared/utilities/profiles';
test('audio offsets remain silent before first cue and subdivision resets at its boundary',()=>{assert.equal(beatAt([.2,.7,1.2],.19).index,-1);assert.equal(beatAt([.2,.7,1.2],.7).index,1);assert.equal(beatProgress([.2,.7,1.2],.7),0);assert.ok(Math.abs(beatProgress([.2,.7,1.2],.95)-.5)<1e-8)});
test('frame seeking yields same finite effect without state accumulation',()=>{const late=pulse(2,1,.3);assert.equal(late,0);assert.equal(kick(.8,1),0);assert.equal(pulse(1.1,1),pulse(1.1,1));assert.equal(cameraAt([{at:0,zoom:1,x:0,y:0,rotate:0},{at:1,zoom:2,x:10,y:20,rotate:5}],2).zoom,2)});
test('speech duck attacks before word, remains across pause and recovers after line',()=>{const w=[{start:1,end:2,gainDb:-12}];assert.equal(duckDb(.8,w),0);assert.equal(duckDb(1.3,w),-12);assert.ok(duckDb(2.1,w)<0);assert.equal(duckDb(2.3,w),0)});
test('both author arm segments preserve their original lengths in every gesture',()=>{for(const author of ['adb','nemi'] as const)for(const gesture of ['rest','explain','point','celebrate','panic','draw','hold','facepalm'] as const)for(const side of [-1,1]){const a=handAnchor(author,gesture,side),p=profiles[author];assert.ok(Math.abs(Math.hypot(a.elbow[0]-a.shoulder[0],a.elbow[1]-a.shoulder[1])-p.armUpper)<1e-8);assert.ok(Math.abs(Math.hypot(a.wrist[0]-a.elbow[0],a.wrist[1]-a.elbow[1])-p.armLower)<1e-8)}});
test('normalization preserves contiguous coverage; validator rejects invented fields, missing event, wrong clocks',()=>{for(const c of catalog)assert.deepEqual(validate(c,'.',false),[]);const c=structuredClone(catalog[0]);c.shots[1].start+=.1;c.sfx[0].event='missing';(c.shots[0] as any).randomBob=true;const errors=validate(c,'.',false).join('\n');assert.match(errors,/noncontiguous/);assert.match(errors,/unknown field/);assert.match(errors,/event-linked/);assert.deepEqual(normalize(normalize(catalog[0])),normalize(catalog[0]))});

test('source excerpt retiming keeps cues on the scene clock and rejects uncovered audio',()=>{const source=catalog[0].music!.cues;const trim=sliceCueMap(source,2,8);assert.equal(trim.sourceStart,2);assert.ok(trim.beats.every(t=>t>=0&&t<8));assert.equal(trim.drops[0],source.drops[0]-2);assert.throws(()=>sliceCueMap(source,20,8),/outside analyzed source/);const c=structuredClone(catalog[0]);c.music!.sourceStart=2;assert.match(validate(c,'.',false).join('\n'),/wrong segment/)});
