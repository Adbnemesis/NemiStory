# ADB Character QA Standards
## Character-Specific Verification Checklist: Silhouette, Rig Mechanics, and Personality Audit

**Document Status**: LOCKED & AUTHORITATIVE QA SPECIFICATION  
**Character**: ADB (Independent Storyteller)  
**Location**: `adb/docs/ADB_CHARACTER_QA.md`

---

## 1. Character Silhouette & Visual Audit

- [ ] **Independent Silhouette**: Does ADB clearly read as ADB in pure silhouette? (Taller build, textured curtain bangs, relaxed knit pullover, straight trousers).
- [ ] **No "Nemi Clone" Tells**: Are ADB's proportions, jawline, eye shape, and clothing 100% distinct from Nemi?
- [ ] **Linework Integrity**: Are all contour strokes rendered in `#2b2623` with natural calligraphic tapers (`2.5px`–`3.8px`)?
- [ ] **Palette Harmony**: Do the oatmeal sweater (`#e8dfd5`), dark slate trousers (`#1d212a`), and layered hair (`#1e222d`) contrast cleanly against the warm paper backdrop (`#faf6ee`)?
- [ ] **Hair Layering & Occlusion**: Do the curtain bangs properly frame the forehead without awkwardly cutting through the eyes or eyebrows?

---

## 2. Rig Deformation & Mechanics Audit

- [ ] **Joint Limits**: Do elbow and shoulder rotations respect natural human anatomical limits? (Zero hyperextended backwards elbows).
- [ ] **Neck & Head Tilt**: Does the head rotate cleanly around the cervical pivot (`Y = -140px`) without creating gaps between the collar and neck?
- [ ] **Secondary Hair Physics**: Do hair bangs exhibit subtle, spring-damped follow-through during head turns without excessive rubbery jelly wobble?
- [ ] **Prop Attachment Accuracy**: When holding objects (phone, mug, notebook), do hands grasp the prop naturally with fingers wrapped over surfaces? (Zero hovering or clipping).
- [ ] **Pelvis & Grounding**: When standing or sitting, is the character firmly anchored to the floor or chair baseline?

---

## 3. Personality & Acting Dynamics Audit

- [ ] **Composed Baseline**: Does ADB maintain a relaxed, confident baseline during normal narration without fidgeting?
- [ ] **The "Cool ↔ Cute" Dynamic**: Does ADB display the signature disarmed fluster (soft cheek blush, sheepish smile) when caught off guard, and smoothly recover to composed confidence?
- [ ] **Deadpan Timing**: Does ADB execute comedic holds with rigid 0-motion freeze (`0.5s`–`1.2s`), flat dash lips, and straight-to-camera eye contact?
- [ ] **Eye Liveliness**: Do eyes perform natural blinks (`0.12s`) and subtle gaze micro-saccades during conversational passages? (Zero dead glass eyes).

---

## 4. Lip-Sync & Audio Alignment

- [ ] **Mouth Precision**: Does the mouth match spoken vowels (`talk_open`, `talk_wide`, `talk_round`) and close tightly during audio pauses?
- [ ] **Voice Dominance**: Is ADB's spoken voice clearly audible and prioritized above all sound effects?
- [ ] **Zero Coupling**: Can the character rig, test scenes, and episodes load and run headlessly without referencing any Nemi character nodes or scenes?
