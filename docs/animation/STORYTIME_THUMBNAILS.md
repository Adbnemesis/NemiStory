# ADB and Nemi thumbnails — image-generation workflow

## Current user direction

On 7 October 2026, the user approved Nemi EP10's generated **Don't Tell Anyone...** thumbnail and explicitly replaced Godot thumbnail creation with **image generation for both ADB and Nemi from now on**. This guide is the current authority. The earlier static Godot compositor, native-4K vector requirement, no-image-generation rule and dated promotional collections are historical thumbnail workflows. Episode animation and ink Shorts still use their respective Godot workflows.

Load the target author's storytime skill and this guide for thumbnail work. Use the built-in image-generation tool and the imagegen skill when available. A thumbnail-only request uses this image route; it does not require animation preflight, scene JSON, Godot thumbnail layouts, validators or movie proofs. Combined animation work still needs its own preparation and complete 1080p satisfaction before 4K movie export.

## Approved visual references

Inspect these images before composing; filenames alone are not evidence of viewing:

- `references/thumbnail_ref/thumbnail_set_raora.png` — the editorial reference for typography, background treatment, scale, cutout separation and graphic hierarchy. Borrow those design choices, not its Hololive characters, costumes, screenshots or branding.
- `nemi/episodes/ep10_my_teacher_used_to_stalk_me/thumbnail/thumbnail.png` — the user-approved generated example of applying that reference while retaining our illustrated identity. Upload copy: `thumbnail/thumbnail.jpg`. Prompt and review are beside it.
- Actual movie frames or canonical artwork from the **target author's episode** — the identity and ink/fill reference. ADB thumbnails must preserve ADB, not copy Nemi's face or outfit. For a historical episode, use the character version actually in that movie unless the user requests a character update.

The default treatment is broad, heavy white sans-serif headline lettering with substantial **black inner / red middle / black outer contours**, bright white or pale checkerboard backgrounds, large expressive faces, clear white silhouette/cutout edges with selective red edging, and story-specific props/doodles. Use the approved images to judge weight, spacing and hierarchy: a thin black/red hairline, small handwritten headline or dull gradient does not reproduce this treatment. Do not add an extra explanatory caption, labels, logos or a timestamp badge to the deliverable.

Retain recognizable face construction, hair silhouette, eyes, clothing, proportions, author-specific ink colour and flat illustrated fills. Nemi retains her red-orange hair/ahoge, green eyes, green outfit and warm burgundy ink. ADB uses his own canonical episode references. Stronger expressions, staged interactions and supporting characters are welcome; generic anime faces, unrelated costumes, photorealism or a different main-character design lose the continuity. Generated artwork is a reference-guided illustration, not an exact rig export.

Keep the shared graphic treatment while inventing an original promotional idea for each story. White/checker backgrounds and outline colours can adapt to the episode when useful; there is no gold-ADB/blue-Nemi palette rule or required portrait-on-one-side template. Episode movies continue to use the separate [EP06 cream-paper colour theme](STORYTIME_EPISODE_COLOUR_THEME.md).

## Develop and generate

Read the actual script, opening and payoff. Choose an audience question and a truthful emotional promise, then design the image and proposed title together. An exaggerated prop, interaction, scale or visual metaphor need not be a filmed scene. Do not invent real injuries, deaths, crimes, outcomes or success metrics. For example, the safe driverless ride must not become the human-driven taxi crash, and the rescued kitten must not be implied dead. CTR improvement needs actual audience data.

For a new episode's thumbnail pair, develop two distinct visual concepts unless the user asks for one image. They should differ in idea or staging, not merely colour or wording. A single-image edit or a user-selected thumbnail does not require another concept. Use one short, eye-catching headline per image and a complementary proposed title. Once the user chooses an image, mark only it as the current delivery.

Use the built-in image-generation tool for new thumbnails and for visual revisions. In the prompt, label each supplied image's role: Raora for typography/background; the approved EP10 image for the desired thumbnail finish; the target episode's canonical art for character identity. Inspect local images before passing them as inputs and follow the tool's current reference-image interface. Describe the exact headline verbatim, the relationship between characters/props, the intended emotion and the identity details that must stay recognizable. Ask for a 16:9 opaque landscape composition with safe type boundaries and no watermark or secondary copy.

A useful prompt starting point is:

> Create a 16:9 YouTube thumbnail for [episode/story]. Reference 1 supplies the heavy white sans headline with thick BLACK/RED/BLACK contours, bright white/pale checker background and cutout composition. Reference 2 supplies the approved illustrated thumbnail finish. Reference 3 supplies [ADB/Nemi]'s canonical identity: preserve [visible hair/eyes/face/outfit/ink/fills]. Illustrate [story-specific interaction or metaphor] with [emotion]. Text verbatim: "[single headline]". Keep faces large, hands/contact clean and the headline readable at phone size. No secondary captions, screenshot UI, unrelated anime characters or watermark.

This is scaffolding, not a fixed scene. The selected EP10 [full prompt](../../nemi/episodes/ep10_my_teacher_used_to_stalk_me/thumbnail/PROMPT.md) is a concrete example. For a revision, include the current target episode thumbnail as the **edit target**, separately label style and canonical identity reference images, and state exactly what should change. Preserve character and headline invariants during targeted edits. Use normal image tooling only for format conversion, downsampling and packaging, not as a substitute for image generation or visual revisions.

If the built-in tool is unavailable, report that limitation. Do not silently return to the Godot thumbnail builder or switch to an API/CLI fallback; follow the imagegen skill's fallback authorization requirements. Never require an API key for the normal built-in path.

## Review and save

Inspect the actual output at full size and at 320×180 and 160×90, beside the target episode art and the style references. Check exact text/spelling, outline weight, background match, face/hair/outfit recognizability, clear emotion, eye/mouth readability, hands and prop contact, face/type overlaps, clutter, crop safety and the lower-right platform-duration area. If a meaningful mismatch remains, make a targeted image-generation edit and inspect again. Technical dimensions are not artistic approval.

Record what was actually viewed and any remaining limitation. Never claim the result is a canonical Godot rig render, editable vector artwork, entirely human-made, native 4K after an upscale, an uploaded thumbnail or a proven CTR winner. Honest provenance is **AI-generated raster illustration using canonical episode art and supplied thumbnail references**.

Save the generator's original selected file in the project before finishing. The canonical episode layout is:

```text
<author>/episodes/epNN_slug/thumbnail/
  thumbnail.png       original selected generated image, native dimensions
  thumbnail.jpg       upload copy, 16:9 and downsampled when appropriate
  PROMPT.md           final prompt and input-image roles
  manifest.json       selected image/title/headline, approval and file pointers
  QA.json             dimensions, hashes, references/provenance and checks
  REVIEW.md           actual full/mobile visual findings
  review/
    phone.png         320×180 review copy
    tiny.png          160×90 review copy
```

Native resolution is whatever the tool actually generated; do not impose the retired Godot native-4K requirement. Preserve the original PNG. A 1280×720 upload JPG is suitable when the native image supports downsampling; use 1920×1080 only when native resolution supports it. Do not upscale merely to claim a larger master. Record source dimensions and conversions honestly. All assets and prompt/QA belong under the episode's `thumbnail/`, never its movie `renders/` folder or only the tool's global generated-image cache.

While iterating, keep candidate outputs under `thumbnail/revisions/<revision>/`; after selection promote the chosen native/upload copies to the canonical paths and update the selected manifest/index. Preserve prior deliveries by default. **If the user explicitly asks to delete rejected alternatives, first verify the selected copies and hashes, then delete only the requested episode's superseded thumbnail files/folders and record cleanup.** Preserve the selected prompt/provenance/QA and the episode's movie, script, voice and rigs. This does not authorize cleanup of other episodes.

## Current and historical indexes

[Generated thumbnail collection](GENERATED_THUMBNAIL_COLLECTION.md) and `tools/storytime/thumbnail_generated_collection.json` identify selected images made through this workflow. EP10 is the first approved example. Future updates add the chosen episode rather than regenerating unrelated historical thumbnails.

The dated [Godot promotional collection](PROMOTIONAL_THUMBNAIL_COLLECTION.md), [earlier single-image collection](THUMBNAIL_COLLECTION.md), [title plan](THUMBNAIL_TITLE_PLAN_2026-10-06.md) and [static layout contract](../../tools/storytime/THUMBNAIL_PROMOTIONAL_LAYOUT.md) are historical references. They retain the facts of their earlier exports; their font choices, source commands, native-4K requirement and no-image-generation wording do not govern current thumbnail requests. No platform upload or test is implied by generating or saving a thumbnail.
