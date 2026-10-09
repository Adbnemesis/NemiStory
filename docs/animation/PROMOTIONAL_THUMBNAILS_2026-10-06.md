# Original promotional thumbnail directions — 6 October 2026

> Historical workflow. On 7 October 2026 the user replaced Godot thumbnail creation with reference-guided image generation for both ADB and Nemi. Follow [the current thumbnail guide](STORYTIME_THUMBNAILS.md) and [selected generated thumbnails](GENERATED_THUMBNAIL_COLLECTION.md). The old commands and no-image-generation rules below record earlier work, not current thumbnail instructions.

These first six candidates are now included in the [complete 24-image collection](PROMOTIONAL_THUMBNAIL_COLLECTION.md), which covers two concepts for every episode.

The user rejected the literal-scene pilot direction and requested original, striking promotional illustration in the animation style. These six new candidates express the episode's subject through invented cover art, scale, perspective, interaction and visual metaphor. Main ADB/Nemi faces and rigs are canonical; supporting illustration is newly authored in Godot. No image-generation service was used.

| Episode | Version | Proposed title | Single phrase | Promotional idea |
|---|---|---|---|---|
| ADB crush | A | My Best Friend Said She Had a Crush on Me | FOR ME?! | Giant heart-sealed envelope thrust toward ADB by a foreshortened hand; receding window planes. |
| ADB crush | B | She Said She Liked Me. I Believed Her. | ME?! | Huge playful Cupid heart-arrow, bow and concentric heart shapes on a dark diagonal composition. |
| Nemi kitchen | A | I Tried to Defrost Chicken With a Hairdryer | STILL FROZEN?! | Newly illustrated whole poultry inside enormous cyan ice, against exaggerated warm hairdryer air. |
| Nemi kitchen | B | I Forgot the Chicken Until Mom Got Home | TOO LATE | Giant frozen dinner and a looming faceless parent-shaped doorway shadow; Nemi's cheek-touch reaction. |
| Nemi taxi | A | My Taxi Got Hit 5 Minutes From the Airport | SO CLOSE! | Original low-angle rear trunk and foreshortened incoming nose; dominant startled Nemi and travel motifs. |
| Nemi taxi | B | The Driverless Taxi Was Fine. The Next Ride Wasn't. | WRONG RIDE?! | Oversized travel paper contrasts a calm autonomous cab with the crumpled ordinary cab; Nemi holds the metaphor. |

Creative recommendations for the first comparison are crush B, kitchen A and taxi A. This is an art-direction judgment, not an audience-test winner. Taxi B intentionally tests a more complex reversal; its paired title is essential to distinguish the safe driverless ride from the human-cab collision.

Letter/Cupid, enormous ice, parent shadow and travel-paper staging are promotional inventions. They are not claimed to appear in the films. No actual injury, death, arrest, successful romance or Waymo collision is invented. The prank payoff stays unrevealed. Earlier delivery images and the rejected literal pilots remain preserved; these new variants live separately under each pilot episode's `thumbnail/promotional/2026-10-06/`.

Local package: [six upload JPGs and titles](../../renders/thumbnail_promotional_2026-10-06/ADB_NEMI_original_promotional_thumbnails.zip), [gallery](../../renders/thumbnail_promotional_2026-10-06/gallery.html), [paired titles](../../renders/thumbnail_promotional_2026-10-06/TITLES.md), and [overview](../../renders/thumbnail_promotional_2026-10-06/overview.jpg). The gallery offers story filters, light/dark surrounds and phone-size display; its browser interactions were not independently exercised. The ZIP contains all linked artwork and exact matching delivery hashes. Package media and native masters remain local; editable source, small JPGs and QA are backed up in Git.

All six sources passed static structural/resource validation before the final real GPU render. That render completed six variant markers and the collection marker with no errors/warnings. Every final 1920×1080 JPG was individually viewed. All six 320×180 reductions were viewed on light/dark surrounds with proposed titles and mock duration badges; all 160×90 reductions were viewed on dark surrounds. Native 3840×2160 masters were decoded/dimension-checked, not individually viewed. Output/source hashes, literal-versus-symbolic provenance and rig-to-prop grip checks are recorded per variant in `provenance_and_qa.json`.

Corrections included: separate held drawing layers to prevent hidden outlines crossing foreground fills; moving/reducing speech text within its field; using the alternate supported elbow branch to uncover Nemi's mouth; raising the taxi reaction to preserve the whole mouth/chin; and covering costume leaks behind foreground car art. Original rig/hand/pose/expression libraries were not changed.

No platform upload or live test has run. Video links/current uploaded pairs remain missing. The remaining nine episodes have not been redesigned in this promotional pass; establish this visual direction before extending the collection. No CTR result or guarantee is claimed.

Production entry point: `tools/storytime/ThumbnailPromotional.gd`, manifest `tools/storytime/thumbnail_promotional_2026-10-06.json`, structural validation `tools/storytime/validate_thumbnail_pilots.py`, and packaging `tools/storytime/package_promotional_thumbnails.py`. The static layout contract is [documented here](../../tools/storytime/THUMBNAIL_PROMOTIONAL_LAYOUT.md).
