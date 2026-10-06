# Nemi EP09: story-moment thumbnail pilots

Prepared 6 October 2026 before authoring the pilot layouts. Thumbnail-only work: preserve the delivered control and every movie, recording, timing file and production library.

## Evidence read and inspected

Read `.agents/skills/nemi-storytime/SKILL.md`, `docs/animation/STORYTIME_THUMBNAILS.md`, `SCRIPT_AND_BEATS.md` and `DIRECTION_REVISION.md`. The spoken story establishes a safe solo San Francisco trip and safe Waymo ride. The ordinary human-driven airport cab brakes on the highway, is rear-ended five minutes from SFO, and receives highway patrol; Nemi cries while the crushed bumper is inspected. These events support the two promises below. The script's later displayed timestamp minute formatting is inconsistent; rely on the actual seconds in the beat sheet and saved scene.

Inspected `review/camera_contact.jpg` and `review/set_scale_contact.jpg`: rear-seat location around 45–52s, ordinary car at 68–83s, rear contact at 86.9s, patrol/cones at 95–100s, crying beat around 104–108.95s. Those are actual saved film contact sheets, not evidence of a new render. The stills establish exact red-haired/green-costume Nemi, cream side-view taxi, blue-grey window/seat art, crushed rear bumper and muted highway hills/rail. Read `TravelArt.gd`, relevant `NemiPose.gd` entries, `NemiFace.gd`, `FXSad.gd` and its base, existing static compositor helpers and the Nemi profile.

Inspected all three supplied `references/thumbnail_ref/thumbnails_set_*.png` and the delivered EP09 control (`thumbnail/thumbnail.jpg`). Reference borrowing is compositional: object/contact moment before text, purposeful gaze and a reaction inside the location. Do not borrow other channels' face construction, anime anatomy, shading, fonts or artwork. Screenshot view counts do not establish CTR.

## Pilot A: the last five minutes

Title: **My Taxi Got Hit 5 Minutes From the Airport**

Single thumbnail phrase: **ALMOST THERE**

Hypothesis: visible rear-end contact and a passenger actually inside the taxi will explain the event faster than the control's detached portrait, tiny cars and travel-memory bridge. Simple blue-grey sky/hills/highway; cream taxi enlarged across the frame, travelling left, canonical trailing car entering from the right. Nemi recoils behind the taxi's original rear window. Optional single Nemi-profile impact accent at the bumper contact. Short phrase sits in clear sky, without covering faces or event.

The thumbnail-local cutaway taxi wrapper masks the exact original rear-window interior through the existing fills to expose the canonical actor behind the car. Omitting just the window fill would leave the original underlying body opaque. All original car polygons/ink, wheels, door/body fills and crushed rear outline are reused unchanged; a native Godot canvas shader discards only that quad interior, inset 2.1 local units to retain the original window ink. This is compositional transparency; no production prop or character geometry is altered. Inspect that the original door/body occludes Nemi's torso and the head fits the rear window; the whole event must survive feed size.

## Pilot B: overwhelmed aftermath

Title: **My First Solo Trip Ended With a Car Crash**

Single thumbnail phrase: **ALMOST HOME**

Hypothesis: the emotional consequence of a first solo trip may attract a different audience from the impact shot. Camera inside the cab: Nemi sits in the rear, visibly upset, cheek touch/frown and exact existing Nemi teardrop VFX. A canonical seat and tissue box establish the seat space; through the window, the existing crushed taxi/patrol lights identify the reason for the tears. This is a compressed illustrated aftermath scene, not a claim that she was arrested, injured or trapped. No police officer or new driver face.

Use canonical seated pose, supported hand target, sad expression and frown. Existing FXSad TEARDROP is held fully drawn via a local static wrapper, avoiding any new tear or face drawing. The tissue box is an existing TravelArt asset used as editorial context for the crying beat; do not describe it as a documented object from the film, because it was not identified in the inspected contact sheets. Window frame and cabin surfaces are supporting scenery using the existing LiveDrawing and Nemi profile ink. Keep patrol indication subordinate, expression unmistakable and text away from eyes.

## Required review (pending root render)

No new pilot has been rendered or visually approved yet. Root owns GPU rendering and review. Check both full 1920×1080 exports, native 320×180 and 160×90 feed views, duration overlay, type boundaries, rear-bumper contact direction, rear-window occlusion, crying tear placement, cheek/sleeve overlap, cabin seat scale and actual canonical art continuity. Native 4K dimensions alone are not visual review. Save truthful provenance and performed checks after inspection. CTR remains an untested target.

## First root GPU renders inspected; r2 correction

Viewed both root-rendered `a/thumbnail.jpg` and `b/thumbnail.jpg` at full delivery size. A successfully exposed canonical Nemi behind the original rear-window mask and showed the enlarged rear contact, but her legs protruded below the taxi body and the mouth touched the window edge. Saved the exact r1 layouts/JPGs and shared local helpers under `drafts/r1/` before changes. R2 adds a held matching highway strip after the actor and before both cars, preserving the existing road stripes and allowing canonical body/wheels to draw over the strip; the passenger moves up 20 pixels to make the chin readable.

B has clear sad eyes, existing blue tears and a hand beside the cheek without covering the mouth. The original bottom-left phrase crossed canonical seat lines. R2 moves the single phrase to the empty window sky above the parked damaged car, without changing canonical prop or character art. New r2 exports and feed-size/duration-overlay review remain pending root rendering.

## User creative review: rejected this literal-scene direction

The user explicitly requested newly invented promotional illustration in the animation style instead of episode-asset rearrangement. These sources/renders are retained exploratory drafts. They are not approved replacements or audience-test results. Current concepts live separately under thumbnail/promotional/2026-10-06/.
