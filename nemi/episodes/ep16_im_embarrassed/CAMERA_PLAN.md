# Nemi EP16 — Camera Plan ("I'm Embarrassed") [Revision 3 Master]

Follows `docs/animation/COMMON_CAMERA_STAGING.md`.

## Staging & Composition Philosophy
- **Authoritative Scale (1.75)**: Nemi is authored at canonical storytime scale 1.75 (height ~665 px), positioned at `y=560` so her shoes ground directly on baseline `y=894`. She occupies a commanding and expressive visual space rather than feeling lost in the lower third.
- **Three Dynamic Environments**:
  1. `attachment_cafe_r5`: For social encounters ("What do you do for work?", polite nod, unemployed translation).
  2. `nemi_creator_studio`: For the physical reality of the workspace ($0 earnings, Ko-fi jar, 40-hour tablet labor, next frame resolution).
  3. `thought` (evening wash): For nocturnal algorithm dread, flatline analytics, and existential imposter syndrome.
- **Dynamic Camera Moves**: Smooth `camera.path` glides (smoothstep easing) replace static cuts, adding cinematic flow to character admissions.
- **Lower-Third Headroom**: Captions remain bounded below the lower third, never clipping hands, props, or character gaze lines.

## 14-Shot Breakdown

| Shot | Time Window | Spoken Cue / Anchor | Background | Center | Zoom | Composition & Purpose |
|---|---|---|---|---|---|---|
| **01. Cafe Hook** | 0.000s – 4.200s | *"Whenever someone asks..."* | `attachment_cafe_r5` | [960, 540] → [840, 520] | 1.05 → 1.25 | Establishing cafe setting; gentle camera glide toward Nemi as the question bubble appears. |
| **02. Soul Freeze Punch** | 4.200s – 7.100s | *"My soul immediately leaves..."* | `attachment_cafe_r5` | [780, 440] | 1.65 | Sudden comedic punch-in on Nemi's frozen panic expression. |
| **03. Studio Transition** | 7.100s – 16.500s | *"They do marketing or finance..."* | `nemi_creator_studio` | [960, 540] | 1.05 | Transition to reality of creator desk; normal corporate briefcase & tie appear. |
| **04. Derpy Cartoon** | 16.500s – 23.700s | *"And I have to say... cartoons."* | `nemi_creator_studio` | [980, 530] → [940, 520] | 1.15 → 1.22 | Slow punch-in as Nemi admits drawing internet cartoons with a sheepish shrug. |
| **05. Cafe Polite Nod** | 23.700s – 28.500s | *"And they give that polite nod..."* | `attachment_cafe_r5` | [960, 540] | 1.10 | Jump back to cafe social setting; awkward polite smile card appears. |
| **06. Unemployed Punch** | 28.500s – 37.300s | *"Which translates to: oh, you're unemployed."* | `attachment_cafe_r5` | [760, 460] | 1.55 | Tight punch-in on deadpan freeze as big red UNEMPLOYED stamp slams down. |
| **07. Financial Reality** | 37.300s – 49.800s | *"My total earnings this month... zero dollars."* | `nemi_creator_studio` | [960, 540] → [920, 530] | 1.08 → 1.16 | Return to studio desk; slow pan toward Nemi and the stark $0.00 earnings card. |
| **08. Ko-fi Jar** | 49.800s – 60.000s | *"No one is donating on Ko-fi either..."* | `nemi_creator_studio` | [920, 530] | 1.18 | Medium framing focusing on Nemi presenting the empty hand-drawn tip jar. |
| **09. 40-Hour Tablet Labor** | 60.000s – 72.500s | *"Forty hours a week hunched over my tablet..."* | `nemi_creator_studio` | [960, 540] → [900, 520] | 1.05 → 1.20 | Dynamic push-in framing timeline scrub bar and spinning 40h clock, affirming real labor. |
| **10. Evening Wash Enter** | 72.500s – 78.300s | *"Late at night it gets scary..."* | `thought` | [960, 540] | 1.10 | Shift to cool evening palette; doubt storm cloud gathers above Nemi. |
| **11. Flatline & Monster** | 78.300s – 88.700s | *"YouTube is getting stricter..."* | `thought` | [940, 530] → [910, 520] | 1.15 → 1.25 | Pan across flatlined view graph and looming shadowy algorithm monster. |
| **12. Imposter Vulnerability** | 88.700s – 99.100s | *"What if they're right? What if I'm just wasting my time?"* | `thought` | [780, 530] | 1.85 | Deep intimate emotional portrait; eyes in upper third, quiet brow asymmetry. |
| **13. Heart Spark Return** | 99.100s – 107.500s | *"I still care about this."* | `nemi_creator_studio` | [920, 530] | 1.22 | Morning light returns to studio; warm glowing heart spark appears beside Nemi. |
| **14. Draw Next Frame** | 107.500s – 115.300s | *"I'm going to draw the next frame anyway."* | `nemi_creator_studio` | [960, 530] → [960, 540] | 1.18 → 1.08 | Pull-out to steady balanced wide shot; stylus poised on peg sheet in serene resolve. |
