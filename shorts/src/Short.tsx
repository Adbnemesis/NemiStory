import React,{useEffect,useState} from 'react';
import {AbsoluteFill,useCurrentFrame,useVideoConfig,staticFile,delayRender,continueRender} from 'remotion';
import type {ShortConfig} from '../shared/utilities/types';
import {Background} from '../shared/backgrounds/Background';
import {Camera} from '../shared/camera/Camera';
import {Character} from '../shared/utilities/Character';
import {Props} from '../shared/utilities/Props';
import {PopCaption} from '../shared/typography/Captions';
import {VFX} from '../shared/effects/VFX';
import {Transition} from '../shared/transitions/Transition';
import {AudioTrack} from '../shared/audio/AudioTrack';
import {SafeArea} from '../shared/utilities/SafeArea';
function FontLoader(){const [handle]=useState(()=>delayRender('Load local Shorts fonts'));useEffect(()=>{Promise.all(['Impact','Gochi','Patrick'].map(f=>document.fonts.load(`32px ${f}`))).then(()=>continueRender(handle)).catch(()=>continueRender(handle));return()=>continueRender(handle)},[handle]);return <style>{`@font-face{font-family:Impact;src:url('${staticFile('fonts/Impact.ttf')}')}@font-face{font-family:Gochi;src:url('${staticFile('fonts/GochiHand-Regular.ttf')}')}@font-face{font-family:Patrick;src:url('${staticFile('fonts/PatrickHand-Regular.ttf')}')}`}</style>}
export function Short({config,debugSafeArea=false}:{config:ShortConfig;debugSafeArea?:boolean}){
 const frame=useCurrentFrame(),{fps}=useVideoConfig();const t=frame/fps;
 const index=config.shots.findIndex(s=>t>=s.start&&t<s.end),shot=config.shots[index<0?config.shots.length-1:index],previous=index>0?config.shots[index-1]:undefined;
 const mouthFor=(author:string)=>{let mouth='closed';for(const d of config.dialogue.filter(d=>d.author===author)){const m=d.mouth.find(m=>t>=d.at+m.start&&t<d.at+m.end);if(m)mouth=m.shape}return mouth};const mouth=mouthFor(config.author);
 return <AbsoluteFill style={{background:'#1b292d',overflow:'hidden'}}><FontLoader/><Background kind={shot.background} author={config.author} t={t} keys={shot.camera}/><Camera keys={shot.camera} t={t} events={config.events}><svg width="1080" height="1920" style={{position:'absolute',inset:0}}><Props shot={shot} author={config.author} t={t} events={config.events} previous={previous} layer="back"/><Character author={config.author} shot={shot} previous={previous} t={t} events={config.events} blinks={config.blinks} mouth={mouth}/><Props shot={shot} author={config.author} t={t} events={config.events} previous={previous}/>{shot.cast?.map(member=>{const extra={...shot,...member,prop:member.prop??'none',cast:undefined};const old=previous?.cast?.find(m=>m.id===member.id);const prior=old?{...previous!,...old,prop:old.prop??'none',cast:undefined}:undefined;return <g key={member.id}><Props shot={extra} author={member.author} t={t} events={config.events} previous={prior} layer="back"/><Character author={member.author} shot={extra} previous={prior} t={t} events={config.events} blinks={config.blinks} mouth={mouthFor(member.author)}/><Props shot={extra} author={member.author} t={t} events={config.events} previous={prior}/></g>})}</svg></Camera>
 <VFX events={config.events} t={t} author={config.author}/><Transition shot={shot} t={t} author={config.author}/>{shot.caption&&<PopCaption caption={shot.caption} t={t} start={shot.start} author={config.author}/>}<AudioTrack config={config}/>{(debugSafeArea||config.debugSafeArea)&&<SafeArea/>}</AbsoluteFill>
}
