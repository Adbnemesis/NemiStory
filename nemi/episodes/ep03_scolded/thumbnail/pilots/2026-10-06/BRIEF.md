# Nemi EP03: two story-moment challengers

Authored 6 October 2026, before pilot layouts. Static thumbnail work only; the accepted thumbnail, movie, rig, narration and timing remain unchanged.

## Story and art evidence read

Read `EP03_Script.md`, `Episode03Subtitles.gd` and `beats/Beat07_EmergencyDefrost.gd`. The spoken story establishes the missed 2 PM freezer task, 5:45 PM return, rock-hard chicken, failed bath/microwave, hairdryer on maximum heat and mother entering the kitchen. The ending is cereal dinner and lost freezer privileges; neither pilot reveals that payoff.

Inspected the actual movie's saved `thumbnail/reference_1.png` at 22.178 seconds and `thumbnail/reference_2.png` at 72.079 seconds, with timestamp/hash provenance in `thumbnail/source_review.json`. They show the canonical red-haired, green-hoodie Nemi rig, open light backgrounds and the existing illustrated frozen/rubbery chicken prop. Read the canonical `PropChicken.gd`, `PropHairdryer.gd`, Nemi rig, pose, hand geometry and `HandPaths.gd` APIs. The dryer nozzle points left; its handle spans local x −8..6, y 10..38. Existing HOLD_PROP hand geometry extends downward from the wrist. Arms use the actual 62/52-unit bone origins, not a custom replacement rig.

Additionally extracted and inspected `film_hairdryer_79s.jpg` and `film_door_88s.jpg` from the actual approved film. The dryer beat confirms the identical slate/coral dryer art, its orange heat strokes, and the permafrost plate; the door beat confirms mother entering as Nemi reacts. The film uses a flipped dryer in that shot; challenger A uses its unchanged default left-facing direction. The frozen state is shown earlier in the same story, before failed microwave attempts.

Viewed all three user reference sheets under `references/thumbnail_ref/`. Borrow one staged event, eye direction toward the event, purposeful physical prop contact and short reaction wording. Do not borrow those channels' face construction, rendering treatment or invented fire/parent portraits. Their visible view counts do not prove a thumbnail CTR.

## Challenger A

- Title: **I Tried to Defrost Chicken With a Hairdryer**
- Thumbnail phrase: **MOM'S HOME**
- Hypothesis: the strange tool/food interaction earns attention; the phrase adds the approaching consequence instead of repeating the title.
- Stage: enlarged canonical frozen chicken on the front counter, canonical hairdryer held visibly by Nemi's right hand and blasting toward the chicken. Nemi looks toward an opening kitchen doorway. Warm cream kitchen, minimal cabinetry, no dramatic aura. The dryer and frozen plate form the main event, with the face nearby.
- Contact: HOLD_PROP, zero wrist angle, hairdryer scale matching the character scale, attachment at local handle top `[−3,10]`; duplicate only the existing hand drawing above the grip if needed. No hand or prop redraw.

## Challenger B

- Title: **I Forgot the Chicken Until Mom Got Home**
- Thumbnail phrase: **TOO LATE**
- Hypothesis: a large frozen block plus the returning doorway makes the deadline understandable with less visual explanation.
- Stage: foreground chicken plate enlarged, Nemi's frantic open-hand reaction toward the opening door, cool doorway against a warm kitchen. No dryer. Single short phrase above the foreground food; face, food and doorway separated.

## Review handoff

The pilot compositor renders the final GPU captures. Full-size, 320×180, 160×90 and duration-overlay inspection are pending; this brief is not visual approval or audience-performance evidence. In A, specifically inspect the crossed right sleeve, wrist grip, unobstructed mouth/eyes and heat-ray contact with the food. In B, inspect foreground plate/counter contact and the hand's direction toward the doorway.

Provenance: Godot composition with existing production rigs/props; AI-assisted direction and supporting scenery code. No generated image service.

## User creative review: rejected this literal-scene direction

The user explicitly requested newly invented promotional illustration in the animation style instead of episode-asset rearrangement. These sources/renders are retained exploratory drafts. They are not approved replacements or audience-test results. Current concepts live separately under thumbnail/promotional/2026-10-06/.
