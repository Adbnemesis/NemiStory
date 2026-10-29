# ADB EP07 — Quality Assurance & Verification Report

## Production Gates Summary (4K Master Delivery)

| Verification Category | Criterion / Requirement | Measured Result | Verdict |
|---|---|---|---|
| **Episode Runtime** | Under 140.0 seconds | **128.733 seconds** | **PASSED** |
| **Video Resolution** | 3840×2160 (Native 4K UHD Master) | **3840×2160 @ 30.0 fps** (3,862 frames) | **PASSED** |
| **Voice Consistency** | Canonical Aiden voice (1.00x tempo, no pitch shifts) | Synthesized with exact profile hashes | **PASSED** |
| **Integrated Loudness** | -18.0 LUFS target (±1.0 LUFS) | **-18.0 LUFS** | **PASSED** |
| **True Peak Level** | <= -1.0 dBFS (prevent digital clipping) | **-1.90 dBFS** | **PASSED** |
| **Video Quality** | High Profile libx264 CRF 17 | Bitrate: ~1937 kb/s, faststart enabled | **PASSED** |
| **4K Gate Compliance** | Explicit user approval before 4K export | User signed in `review/1080P_APPROVAL.json` | **PASSED** |
| **Directory Cleanup** | `renders/` contains ONLY final 4K video | Purged superseded 1080p; sidecars moved to records | **PASSED** |
| **Thumbnail Delivery** | Match EP06 R2 style with 2 distinct concepts | Candidates A & B with 320x180/160x90 checks | **PASSED** |

---

## Feedback Verification Checklist

- [x] **4K Native Render**: Rendered and validated native 3840×2160 master at 30 fps (3,862 frames, 128.733s).
- [x] **Render Directory Cleanup**: Deleted superseded 1080p r1 and r2 renders per user request. Relocated `.audio_qa.json`, `.capture.log`, and `.review_stamp.json` to `review/render_records/`. Verified that `renders/` contains ONLY `EP07_How_I_Got_Over_My_Crush_4K_master.mp4`.
- [x] **EP06 R2 Style Thumbnails**: Created 2 distinct promotional concepts matching EP06 R2's visual language:
  - Candidate A ("I'M OVER HER!"): Smug, relieved Aiden pointing thumb back to crumbling Greek pedestal and broken heart doodle.
  - Candidate B ("SHE DATED AGAIN?!"): Comedic shock staging with sweat drop, shock shadow, and phone.
  - Both feature heavy white sans headlines in speech bubbles with thick BLACK/RED/BLACK nested contours on pale lavender checkerboards with white cutout margins.
- [x] **Background Variety**: 6 distinct story-appropriate environments (`school_day_r4`, `school_corridor_r4`, `bedroom_evening_r4`, `school_courtyard_r4`, `school_street_r4`, `thought`, `adb_studio_ep02`).
- [x] **Aiden's Expressions**: Removed smiles across P0–P7; Aiden smiles strictly and only when meeting Nemi in college.
- [x] **Subtitle Fix**: Verified canonical "Nemi." spelling in timeline and subtitles.
- [x] **Doodles & Props**: 45+ total items with live pencil animation and synchronized scribble SFX.
