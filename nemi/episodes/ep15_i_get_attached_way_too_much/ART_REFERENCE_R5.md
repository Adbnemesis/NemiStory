# EP15 R5 art and set staging
New production modules: `common/storytime/production/AttachmentRevisionArt.gd` and `AttachmentRevisionBackdrop.gd`. Old modules, rigs and profiles are unchanged.

All illustrations require `author: "nemi"`. They use the existing version-2 art fields and shared LiveDrawing clock: `mode: hold` is complete on entry; `mode: live` has an explicit positive duration. Fill arrival is .88. Completed geometry never moves. The example `art_example_r5.json` is a silent staging catalog, not an episode delivery or artistic approval.

## Coordinates and progressive layers

Ordinary art anchor: `position: [1190,490]`, `scale: [1,1]`. Nemi stands at `[570,533.25]`, scale `1.75`, feet y894. Do not rescale the actor separately for a closer shot; reframe the world with the shot camera.

| Thought | Main / base | Transparent stages and approximate local bounds |
|---|---|---|
| Lifetime contract | `attachment_contract_scroll`, x−226..235 y−193..183 | `attachment_contract_seal`, x90..162 y89..196; add after the contract rather than redrawing it |
| Years apart | `attachment_time_apart`, x−204..178 y−176..165 | Three calendar sheets, Nemi-profile lettering “2-3 years”, two anonymous friend portraits; no exact dates/identities |
| Journey to friends | `attachment_journey_friends`, x−238..250 y−139..192 | `attachment_journey_route`, x−143..160 y−93..98; symbolic branching journey, not a geographic map |
| Imagined conversation | `attachment_cafe_conversation`, x−212..215 y−211..−30 | Conversation arcs only; cups have world anchors below. Grounded furniture belongs to the café backdrop |
| Both busy | `attachment_busy_pair`, x−250..264 y−170..190, convenience combined | Prefer `attachment_busy_first` then `attachment_busy_second` at the same art anchor; separate clock/calendar icons distinguish anonymous replies without inventing motives |
| Their own lives | `attachment_life_calendar`, x−229..227 y−211..166 | Generic calendar/clock metaphor. It is Nemi acknowledging plans, not evidence of what either friend did |
| School texting | `attachment_school_message_frame`, x−248..244 y−242..235 | Add `attachment_school_message_first`, `attachment_school_message_second`, then `attachment_school_message_reply` at the identical anchor. `attachment_school_message_build` combines all four only for convenience |
| Editing excitement | `attachment_message_edit`, x−232..224 y−175..196 | `attachment_message_edit_crossout` crosses the exclamation marks and leaves eraser crumbs; there is no invented literal message |
| Neeko care | `attachment_neeko_care`, x−231..228 y−80..204 | Canonical existing EP15 cream/ginger Neeko geometry scaled into a cushion/bowl memory vignette; no replacement animal rig or new animal motion |
| Carrying memories | `attachment_memory_drawer`, x−247..237 y−101..170 | Empty drawer first; `attachment_memory_keepsakes` adds anonymous friend/photo/chat/cat keepsakes; `attachment_memory_overflow` adds a bounded overflow gag, x−292..287 y−209..101 |
| Quiet reply / self-worth | `attachment_worth_reply`, x−246..213 y−156..154 | Large quiet reply plus a loose implication arrow; no literal verdict is written. `attachment_worth_heart`, x61..187 y53..160, completes a whole heart after the narrator revises the implication |

Do not layer a combined convenience kind together with its component stages: it duplicates their outlines. Component stages share the same anchor/scale, so their finished ink registers exactly. Clear the prior thought's art through `end`/`shots`; a richer beat should develop sequentially rather than permanently accumulate cards. Add live words/cross-outs as separate existing Nemi `text`/`scratch` drawings if the spoken thought needs them.

## Café cup contact

The three cup kinds are the sole exception to the ordinary art anchor. They contain world coordinates and require `position: [0,0]`, `scale: [1,1]`, `tilt: 0`, against `attachment_cafe_r5`.

| Kind | Cup bottom centre | Full stroke bounds |
|---|---|---|
| `attachment_cafe_cup_one` | [1120,631] | x1083..1165 y556..643 |
| `attachment_cafe_cup_two` | [1335,613] | x1299..1379 y539..624 |
| `attachment_cafe_cup_three` | [1555,634] | x1518..1600 y559..646 |

Use separate entries and deliberate timings so cups/conversation progress across the imagined catch-up. Cups are already-drawn props when introduced unless drawing a new cup is the actual thought; they do not animate steam forever.

## New recognizable settings

All four backgrounds use cream #faf7f2, soft neutral/sage window washes, warm neutral furniture and y894 floor. Dark readable Nemi ink remains on foreground evidence. No saturated wall/road block or place label replaces the setting.

- `attachment_visit_r5`: family-visit arrival corner; city through the left window, two luggage cases at x153..441 with wheels ending y894, quiet guest bench right, coat hooks. No transport mode, named city, relative or friend's identity is invented.
- `attachment_cafe_r5`: imagined café, full-size table surface x1035..1645 y579..699; grounded pedestal/base ends y894. Left chair centre930 seat719, far chair centre1335 seat632, right chair centre1742 seat719; chair feet end y894. Actor x570 remains beside the scene rather than pretending an unsupported seated pose. Window, hanging shade and small plant support the location. Use this as a mental image; the story does not assert an actual café meeting.
- `attachment_school_nook_r5`: school locker bank left, real door right, upper window, grounded bench x1236..1610 seat714/feet894 and a bag beside the door. This is a new set; the old floating school-day desk set is not modified or reused.
- `attachment_home_care_r5`: new cream home console for the final putdown. Contact surface x1205..1742, y510, thickness to532; doors reach870 and feet894. Window left, one quiet upper shelf right. Root's intended final actor blocking is [1110,533.25], scale1.75; this is a contact staging starting point, not proof of reach/grip. Author and inspect exact hand path, prop orientation, and attach_end boundary against the actual phone. Original `attachment_home` is unchanged.

## Verification status

The engine instantiated/prepared all 26 new art kinds, checked finite stroke coordinates, and loaded the background dispatcher. No unsupported lettering or Godot parse/runtime error appeared; the known unrelated headless macOS certificate diagnostic remains. Full scene validation, a fresh proof, integrated review, 1080p playback and actual prop-contact inspection remain the episode owner's responsibility. A silent catalog is not proof of lip-sync, voice pacing or sound quality.

