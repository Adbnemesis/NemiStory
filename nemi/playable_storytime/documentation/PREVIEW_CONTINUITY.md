# Continuous local review controls

The movie owns the story, spatial continuity and native number-key routes.
The local preview can offer a small amount of viewing help when
`preview_choice_turns` is true and the viewer checks **Help me follow Nemi**.
This is a local convenience. It is not functionality embedded in an uploaded
YouTube movie.

## Authored handoff data

An optional `preview_goal` string keeps one overall objective visible while
the current choices and feedback change. It should state the story goal, such
as “Get Nemi to the desk beyond the page.” It is not a scene or round title.

An optional `preview_handoffs` array marks the few normal-play transitions
where Nemi changes sectors:

```json
{
  "preview_choice_turns": true,
  "preview_goal": "Get Nemi to the desk beyond the page.",
  "preview_handoffs": [
    {"at": 24, "yaw": -90, "duration": 0.9},
    {"at": 48, "yaw": 90, "duration": 1.2}
  ]
}
```

`at` and `duration` are seconds; yaw uses the authored world degrees, matching
scene `review_yaw`. Handoffs must have increasing positive times below the
movie duration, yaw from −180 to 180 degrees and duration from 0.2 to 2
seconds. A normal handoff should last roughly 0.9 seconds for a quarter turn;
longer turns can use a longer authored duration. Do not place a handoff at a
boundary that already preserves Nemi's position and viewing sector.

The page rejects malformed handoff data alongside its existing revision,
duration and route guards. The production validator also needs to validate
the authored metadata before export.

## Runtime behavior

The helper runs once when ordinary, playing movie time crosses an authored
handoff. It takes the shortest yaw path and settles pitch to the horizon. It
does not run after a seek, load, discontinuity larger than one second or while
paused. It does not continually track Nemi, follow review-camera beats or
retry a skipped handoff later.

Dragging or W/A/S/D immediately takes control and suppresses a natural
handoff for 1.5 seconds after the latest manual look. A choice is an explicit
request and retains the existing brief choice turn. A new seek, unchecked
helper or app focus loss cancels pending helper motion. Pausing also stops a
natural handoff turn. **Face Nemi** is an explicit, gentle return over 650 ms.
When the browser reports a reduced-motion preference, these explicit turns
settle immediately instead of animating.

With the option unchecked, natural playback and number choices retain the
viewer's yaw/pitch. Both modes preserve pause state. The local helper never
resumes a paused movie.

## Pointer ownership

Only the active primary pointer can move the view. Mouse movement without a
pressed button ends the drag. Pointer-up, pointer-cancel, lost pointer capture,
app blur, hidden page, new choice, seek or load releases drag ownership. This
prevents a missing pointer-up event from moving the next scene unexpectedly.
There is no inertial drag effect.

## Choice presentation

The picture and transport come directly after the fixed header. The goal,
choices, playback buttons and changing feedback sit below the picture. A
choice appearing or disappearing, or a line of feedback wrapping on a narrow
phone layout, therefore cannot move the picture down the page. No large
reserved blank panel is needed. Existing player/choice focus and number-key
listeners use the same stable element IDs after this source-order change.

A number choice retains the last decoded picture while showing a compact
action notice, such as “Taking the tear…”. It does not replace the whole
viewport with a new-round/timestamp screen. New pointer drags are blocked
while that choice is decoding, and each choice clears earlier pointer state.

The picture is revealed only after the latest requested seek has completed
and its new frame draws successfully. The existing seek-token, matching-media
and fresh-frame guards remain in force. This is not a crossfade that relabels
an old frame as the new result. Startup, errors and unexpected buffering
retain the full loading/error cover.

## Verification

`tests/preview_keyboard_check.js` exercises the actual page listener code in
a simulated DOM. It covers natural crossings, seek/pause/native preservation,
manual-look priority, one-shot handoffs, stable objective text, stale pointer
cleanup, rapid choices and the existing matching-media guards. It can also
read the current production timeline as its third command argument.

These checks do not establish GPU projection, actual browser playback,
continuous listening, phone hardware behavior or native YouTube behavior.
Those remain separate review steps. The R6 page and tests before these fixes
are preserved under
`episodes/episode_002/review/revisions/r6_before_continuity/`.
