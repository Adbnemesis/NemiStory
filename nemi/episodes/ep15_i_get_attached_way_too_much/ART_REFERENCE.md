# EP15 attachment art and location catalog

These are new production illustrations for Nemi EP15, made with the existing shared `LiveDrawing.gd` ink player. They do not modify a character rig, pose, expression, hand, mouth or old episode. Every cue selects `author: nemi`; there is no ADB fallback or color-only substitution. The associated valid version-2 silent sample is `art_example.json`. It documents all seven kinds and the two new backdrops without authoring alternate episode narration.

## References and treatment

The episode uses the current cream-paper treatment documented in `docs/animation/STORYTIME_EPISODE_COLOUR_THEME.md`, with the actual EP06 movie as the production team's colour reference. Art here uses Nemi's profile ink and rounded, slightly asymmetric centerlines, rose `#ad5e69` for selective message/emotional emphasis, cream `#fffdf8` paper and neutral desk washes. The two sets use paper `#faf7f2`, a floor/sidewalk in warm pale neutrals, faded blue-green windows, restrained brown/plum structure and limited object colour. They do not broadly fill the city walls or road with saturated colour. The parent production is responsible for inspecting these in the episode proof against EP06 and EP11 R10; a parse check is not an aesthetic review.

Neeko's actual reusable art is `nemi/characters/neeko/Neeko.gd`. The proposed historical `nemi/episodes/ep01_cat/Neeko.gd` path is absent. The new static memory illustration follows that existing reference's cream `#fbf8f3`, ginger `#c85a3a`, coral nose `#e8928a`, pale pink ear `#f5cdc6`, sage eyes `#558268`, charcoal `#2b2623`, cheek tufts, left face patch and upper-back patch. It is a symbolic warm memory portrait, not an exact rig export, photograph, replacement animal rig, loss/death claim or generated new behavior. No image generation or outside asset was used.

## Illustration catalog and local bounds

Bounds below are measured Godot stroke centerline bounds at scale `[1,1]` before tilt; allow roughly 5 local units around them for ink width. Place them near `[1240,490]` for the production actor root `[570,533.25]`, scale `1.75`, with shoe soles around y886 and the ground line y894 in the standard full world view. The root is not the foot position. Reframe the entire world for a portrait or object insert. The bounds are not a promise that every camera path will preserve every edge.

| Kind | Local x range | Local y range | Purpose and staging |
|---|---:|---:|---|
| `attachment_invite` | −133…133 | −197…193 | Large anonymous phone with enthusiastic outgoing invitation strokes and a small cup symbol. It is an evidence illustration, not a handheld prop/grip model. |
| `attachment_busy` | −220…223 | −165…166 | Two separate anonymous replies, distinguished by a clock/calendar icon and bubble shape. Let narration or separate supported drawn text carry the exact word “busy.” No identities or literal chat transcript are invented. |
| `attachment_reunion` | −224…223 | −178…182 | Imagined cafe table, two empty chairs and two cups. The vignette is a mental expectation; it does not claim a named venue or actual meeting. Keep the chairs empty/readable. |
| `attachment_messages` | −227…221 | −177…168 | Long excited outgoing chat versus a visibly tiny reply. This is qualitative evidence rather than an exact screenshot or quote. |
| `attachment_neeko` | −217…142 | −174…145 | Warm cream-and-ginger cat memory. The tail makes the shape asymmetric; center optically around local x −30. Use a quiet hold rather than celebratory VFX. |
| `attachment_heart_thread` | −204…223 | −116…140 | Bounded thread ties a warm heart to a chat bubble. A live reveal can make attachment visible; once complete it remains still. |
| `attachment_phone_rest` | −230…236 | −51…181 | Face-down phone on a neutral desk, including grounded legs. A quiet closing metaphor, not an attachment-ready physical prop or authored pickup. |

All geometry is finite and authored. `mode: hold` enters fully inked. Existing `mode: live` may reveal it, with fills only at .88 progress; choose enough duration for the actual number of strokes. No path geometry changes after completion, no per-frame randomness or opacity-only word animation is introduced. Any camera/hold/live decision still belongs to the measured thought beat. Avoid drawing every asset live or leaving several full illustrations visible together.

## Recognizable locations

- `attachment_home`: fixed y894 standing plane, left window at approximately x174–515/y203–505, left side table at x141–426/y687–894, right drawing desk at x1205–1775/y638–894, page/pen/jar and a grounded stool with its seat around y710. The desk surface is y638–643 and the side table surface y687–690, sized against the actual adult-height Nemi proof. The main actor lane remains around x570–900. The upper right is intended for one story illustration; the desk remains below it.
- `attachment_city`: generic distant facades, quiet washed windows, doors, low greenery, a right-side park bench, sidewalk and pale road. The standing plane is y894; bench feet also land there. The bench spans x1477–2009 including armrests, with seat x1500–1983 and back slats x1510–1971. It is shifted right by 280 units to keep the cafe/message illustration lane clear. The bench seat is y707–710, its back slats are y590/625/660, and supports start at y570; this replaces the rejected low doll-scale bench in the first proof. The road begins at y960. It deliberately has no landmark, name, sign or address, because the brief did not identify a city.
- Existing `school_corridor_r4`: grounded lockers and door establish the school-message recollection. The older classroom desk geometry floated above its floor during full-cut review, so the delivered episode uses this corridor without editing the old set or any episode.

The imagined cafe asset is an illustration and must not replace the actual city environment. Keep character size consistent with the bench and desk; for close framing use the supported camera center/zoom/path, not a different narrator scale.

## Checks performed and limits

A headless Godot 4.7.2 check instantiated all seven kinds through `SceneArt.make`, verified nonempty strokes, triangulated every fill polygon, checked sampled finished ink stays at progress 1, and executed both backdrop draw calls. All passed. The engine emitted its known unrelated macOS certificate lookup diagnostic. The exact centerline bounds are copied above. No movie or still was rendered by this catalog task, and no aesthetic, contact, mouth, sound, playback or full-episode review is claimed. The parent episode production must perform the required proof/integrated/full-1080p visual and audio review.

Furniture scale revision: inspected actual `review/proof_r1/frame_0.2.png` from the parent proof. The first city bench was too low relative to Nemi. Raised the new bench and home desk/stool/side table while retaining the y894 floor. No new frame or movie was rendered during this revision; the parent production must review the revised geometry in its next capture. Existing `school_day_r4` desks remain at y580–602 and feet y759 in their authored classroom background; these are background desks further upstage, not a contact surface for the foreground actor. Keep Nemi out of contact with them or inspect scale/contact if staging a sit.
