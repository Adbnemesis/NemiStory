# EP03 school/channel catalog

This extension to the version-2 art/background registry uses existing production fields and the shared `LiveDrawing` player. It adds no schema fields, clock, actor, rig pose, hand or mouth. `SceneArt.gd` and `Backdrop.gd` register the catalog; `tools/storytime/validate_production.py` accepts the same kinds. The compact pen geometry and lettering come from the selected author, and every cue must declare `author`.

The source is `common/storytime/production/SchoolYoutubeArt.gd` and `SchoolYoutubeBackdrop.gd`. The miniature copyable field example is saved at `adb/episodes/ep03_my_school_found_my_youtube_channel/assets/school_youtube_example.json`. It is an art/staging excerpt, not a separate playable episode or approval proof.

The actual ADB colour-mode rig and EP02 movie frame take precedence over the outdated oatmeal-knit prose: slate curtain hair, a green button shirt, pale trousers. The browser and phone contain an illustrative ADB bust. They do not claim to depict the user's real face or recovered old footage. No channel name, precise date, analytical dashboard, invented testimonial or platform violation is shown.

| Kind | Local geometric bounds | Purpose |
|---|---|---|
| `school_youtube_browser` | x −250..250, y −145..145 | Old lip-sync page, ADB bust and bounded red play icons; no real recommendation labels |
| `school_youtube_phone` | x −100..100, y −186..190 | Vertical face-video recording metaphor, green shirt and bounded red recording dot |
| `school_youtube_subscribers` | x −245..245, y −145..145 | Approximately `1k` subscribers from the user's memory; hand lettering, no analytics screenshot |
| `school_youtube_peers` | x −236..241, y −249..0 | Three anonymous smiling observer busts; a seated/shoulder origin, not standing figures or a walk |
| `school_youtube_private_public` | x −265..265, y −125..125 | One-friend to whole-class contrast; compact supported lettering |
| `school_youtube_archive` | x −250..250, y −185..185 | Work papers and closed old-video folder; no ban claim |
| `school_youtube_then_now` | x −290..290, y −170..170 | Old face-video page beside the current illustration/timeline page |

These are held evidence by default. When a thought needs a live reveal, use ordinary `drawings` with `mode: live` and positive `duration`; completed ink then holds. The paper and character fills arrive late during a live reveal. Do not place all the evidence on screen together, and do not live-draw the phone recording as a substitute for narration or acting.

Both backdrops use dominant cream paper `#faf7f2`, pale neutral floor `#f2ebe0`, dark readable soft scenery contours and a bounded light-blue window. The floor is at world y894. `adb_computer_lab` has two grounded workstations, monitors, keyboards, mouse, tower cases and tucked chairs. The center-left x560..950 remains open for ADB. `adb_creator_studio_ep03` preserves the same hero workstation scale and adds a small shelf.

The hero desktop is x1090..1810, tabletop y694..713 and feet y894. Its monitor outer bounds are x1215..1585/y440..645, inner screen x1228..1572/y453..632, and stand ends at y687. The browser cue at world `[1400,542]`, scale `[0.60,0.60]` fits that inner screen in both sets. The tabletop keyboard ends at y690. These are held scenery coordinates; they do not generate seated contact.

Recommended ADB placement for a full-body lab shot is `[750,634.8]`, scale `1.35`, with the tread fill at y894. The unchanged rig's cuff target is actor-local y178, while its visible tread reaches y192; placement therefore uses the actual shoe geometry rather than the cuff target. The outline straddles the floor line by 1.35 pixels. Reframe the entire world for portraits and object inserts. Larger supporting evidence near `[1390,500]` can use art scale around `1.0` in a deliberately composed evidence shot, then clear it when the narrator reaction becomes the focus. Inspect actual hands, wrists and furniture scale in the root's fresh validated 1080p proof.

Reference inspection performed for this extension: EP02's actual `review/r2_stills/r2_01_hook.jpg` and an actual EP06 "How I Animate" movie frame captured at27s in EP03 `review/reference/ep06_27s.png`. Source compilation/engine verification is separate from full-cut visual/audio review.
