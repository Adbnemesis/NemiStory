# Camera and sound plan

All cues share one scene clock. Cut boundaries match the 25-second / 30 FPS reference. Camera reframes the complete world; character scale remains 1.75. The final studio portrait uses center [620,331], with room actor at [620,570], zoom2.17, measured against the supplied source head/crop, and is held, bright inserts change framing only at reference cuts. Hand/foot/body scale review is required in the 7.6-second wider pose and object insert sequence, as well as portrait mouth/face crops.

| Exact words or pause | Time | Frame / purpose | Hold / return |
| --- | --- | --- | --- |
| A message | 0 | Locked studio, direct address | Through 2.533 |
| My name's Nemi | 3.54 | Bright then studio, name introduction | Room returns 3.9 |
| I'm an overthinker | 6.06 | Bright closeup then locked portrait | Room returns 6.4 |
| And I'm gonna steal your watch time | 9.24 | Wide bright pose then room, confidence | Room returns 9.667 |
| By becoming the biggest storytime animator in the world | 11.58 | Same locked studio, words replace each other | Cut 14.333 |
| Instrumental gap | 14.333–18.56 | Desk, story stack and close detail | Sequential cleared inserts |
| I've already got the stories | 18.56 | Shrug turns back to dry room portrait | Return 18.867 |
| Now I just gotta stop overthinking | 19.97 first spoken word after source-bound edit | Quiet eye contact, no text | Hold to 22.1 |
| Last hit and silence | 22.1–25 | Empty black | End |

Music is the local hybrid reference bed: original soundtrack in verified narrator-free windows and separated instrumental elsewhere, on a separate music lane, preserving its authored dropouts. Provenance is under `renders/message_to_storytime_reference/audio/`; not a newly generated similar track. The hybrid revision is current: original soundtrack in verified narrator-free windows with separated bed under narration. It is never folded into narration.

Existing library cues: `paper_book_open_01` at 15.3 seconds for story-stack reveal, gain −8 dB; `paper_page_flip_01` at 16.2 for the detail cut, duration0.75s to retain its original peak at source0.590s, gain −12 dB (the longer excerpt has a strong transient). They use their original category files and named scene events. No synthesized effects or voice-replacement memes. Other cuts intentionally rely on the reference music and silence. The final full mix is calibrated with one constant master gain; encoded loudness and peaks plus decoded contamination checks will be recorded under review. Numerical checks do not establish subjective audibility.

R6 contact correction: the 14.333–15.3s desk uses position[1450,602], scale1.65: its leg endpoints lie at y894.05–895.70, matching Nemi floor y894. The laptop uses position[1450,551.6], scale0.8: bottom reference y63 reaches tabletop y602 exactly. Nemi points toward it using the existing supported pointing hand. This replaces R5's rejected floating-laptop insert; all audio and first ten-second picture remain unchanged.
