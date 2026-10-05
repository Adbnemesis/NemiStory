# Timeline and component contract

The source of truth is `types.ts`. Author **seconds**, never mix frames and seconds. `src/catalog.ts` applies `normalize()` once; the normalized clock feeds characters, props, effects, sound, captions and camera. Cue metadata retains its measured precision; visual events are rounded to the nearest export frame (at most 16.7 ms).

A config has identity, direction (`promise`, `want`, `choice`, `consequence`, `payoff`), 8–22 s duration, 1080×1920/30 fps, contiguous shots, named events, SFX, dialogue, blinks and an explicit loop kind/note. Music is optional. Missing direction, assets, hashes, wrong segment clocks and invented fields stop export.

```ts
import {base, shot, camera} from './builders';
const c = base('ADB-Example', 'adb', 'A concrete joke', 12);
c.promise = 'One recognizable setup';
c.want = 'What he wants'; c.choice = 'What he does';
c.consequence = 'The visible cost'; c.payoff = 'The ending earns it';
c.shots = [
  shot('setup', 0, 4, {
    focus: 'One readable face and relevant prop',
    expression: 'smug', gesture: 'explain',
    actor: {x: 470, y: 990, scale: 2.7, headTilt: -4, gaze: [0, 0]},
    background: 'gym', prop: 'barbell',
    camera: camera(0, 4, 1, 1.025),
    caption: {text: 'A SHORT HOOK', style: 'pop', size: 85},
  }),
  // Add contiguous escalation, payoff and ending; do not stretch this example.
];
```

Expressions: neutral, happy, confused, sideEye, shocked, angry, smug, crying, deadpan, screaming, evil, embarrassed, destroyed. Gestures: rest, explain, point, celebrate, panic, draw, hold, facepalm. Body/arm pose settles in .25 s; head follows with .06 s delay and .28 s settle. `stepped: true` quantizes the character and attached tool to 15 fps. Background/camera/captions still export at 30 fps. Completed props/ink stay held.

Camera keys `{at,zoom,x,y,rotate}` use absolute scene times. Camera interpolation is smooth, with explicit duplicate/nearby keys for authored holds/anticipation. Impacts have finite damped kicks. `trackingKeys()` converts authored subject samples into keys; `springProgress()` is available for a deliberately chosen overshoot. Background depth uses one-quarter camera translation/zoom and one-fifth rotation, avoiding continuous unrelated movement.

Shot transitions: cut, match, whip, object, snap, spin, smear. An event `{id,at,kind,strength?,duration?}` has a finite lifetime; event kinds are impact/pop/whoosh/flash/cut/expression/drop/phrase. `expression`, `cut` and `phrase` are synchronization labels: the visible expression/cut remains authored in the shot. They do not silently mutate state. Hook text is visible at frame 0; `caption.at` can delay a punchline until its word. `words` captions use absolute per-word `{text,at,end}`. Captions support per-shot color, size and y; font selection remains an author/style choice.

`shot.cast` adds actors with `{id,author,expression,gesture,actor,prop?,propValue?}`. Primary actor remains the channel's author. Cast art uses its own author profile; voice mouth shapes route by author. Prefer one actor of each author in dialogue; same-author doubles need separate dialogue routing if developed further. Rig clip IDs are unique. Cast is supported and validated, but the first four demos use solo acting.

SFX `{id,file,at,duration,gainDb,event,sourceStart?,sha256?}` is a scheduled source excerpt. Gains are decibels relative to that file, not inferred stem mix values. Voice adds exact text, author, hash, word and mouth intervals. Word alignment does not infer phonemes: these demos use authored generic open/wide/round shapes over word intervals. Emotional pauses stay intact.

Music `{file,gainDb,sourceStart,duration,cues,duck}` uses a cue map with source hash/start/duration/rate, BPM/offset, beat/strong-beat/phrase/drop/chorus/accent/onset arrays and review status. Cue times are excerpt-local seconds. `sliceCueMap()` subtracts the new source shift. Rate changes require reanalysis. A duck window is `{start,end,gainDb}` with 100 ms attack before speech and 200 ms release after it; the quietest overlapping window wins.

Unknown controls require a deliberate type, validator, documentation and example update. Do not invent a JSON property and assume the renderer will act on it. Local font loading blocks frame capture until ready. Audio finishing measures raw encoder delay, corrects that delay to the scene clock, then adjusts overall amplitude. Video frames, original voice identity and pacing remain unchanged.
