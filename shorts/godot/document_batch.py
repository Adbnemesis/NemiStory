"""Save final batch indices from checked source/export/audio records."""
from pathlib import Path
import json,hashlib,datetime
ROOT=Path(__file__).resolve().parents[2];batch=ROOT/'shorts/godot/batch01'
tracks={x['file']:x for x in json.loads((ROOT/'shorts/assets/music/batch01/catalog.json').read_text())}
observations=[
 'Headphones stay present across the raised peace/wave gestures. Ear/face, reverse-view, shoe and full-body crops alternate; sound arcs/stars occupy negative space. The raised hand was moved clear of the hair after the art proof.',
 'The raised sleeve has a separate authored contour, without the erased-arm rectangle seen in the initial study. A real side/back illustration changes the silhouette. The LAB 3 sign and door are readable at the reveal; the later small deadpan hold communicates the reversal.',
 'Pencil and page are locked to the illustrated grip. The prop insert exposes the authored page drawing. A foreground pencil crosses once; the page frame, stars, cloud, leaf and crescent accumulate in the outer space. The final page and figure hold.',
 'Full-body pair frames show both sets of feet. ADB stays restrained while Nemi switches to wave/peace/profile/back drawings. The saved darker ink palette arrives at frame120; its contrast reversals are held, rather than continuous flashing. ADB ends with one smile and tilt.',
 'The phone is drawn inside ADB’s finger grip at chest level. Viewfinder corners establish the portrait. One brief shutter wash marks the capture; two illustrated photo poses compare the shy and confident expression before the photographer reaction and final pair.'
]
entries=[]
for i,p in enumerate(sorted(batch.glob('0*/short.json'))):
 c=json.loads(p.read_text());r=p.parent/'review';current=json.loads((r/'current.json').read_text());ex=json.loads((r/'export.json').read_text());audio=json.loads((r/'audio.json').read_text());assert audio['passed']
 music=tracks[c['music']['file']];cm=json.loads((p.parent/'CUE_MAP.json').read_text())
 cut_error=max(abs(x['pictureMinusSourceAccentMs']) for x in cm['cuts'][1:]);rev=current['revision'];file=Path(current['file']).resolve();relative=file.relative_to(p.parent)
 entry={'id':c['id'],'title':c['title'],'folder':str(p.parent.relative_to(ROOT)),'file':str(file.relative_to(ROOT)),'revision':rev,'frames':450,'duration':15,'music':{'title':music['title'],'artist':music['artist'],'sourceUrl':music['catalogUrl'],'sourceHash':c['music']['sourceHash'],'sourceStart':c['music']['sourceStart']},'lufs':audio['loudness']['integratedLufs'],'truePeakDbTP':audio['loudness']['truePeakDbTP'],'decodedAudioCorrelation':audio['reconstructionCorrelation'],'audioDelayMs':audio['delay']['milliseconds'],'cutAccentMaxErrorMs':cut_error,'movieSha256':ex['sha256'],'specSha256':ex['specSha256']}
 entries.append(entry)
 qa=f'''# {c['title']} — export review

Current export: [{file.name}](../{relative}). Revision **{rev}**. 15.00 seconds, 450 decoded frames, native 1080 × 1920 at 30 fps; H.264/AAC, stereo 48 kHz.

## Picture

{observations[i]}

Inspected the rendered settled contact frames, first/final frames, face/prop/full-body views, and actual browser playback at phone size. Exported picture changes occur at all {len(ex['cuts'])} saved cut frames; previous held-frame differences are near zero. The cuts after the opening are within **{cut_error:.3f} ms** of their selected source accent candidates. These are measured onsets/editorial accents, not an assertion that each is a musical downbeat. The opening is an immediate hook and may begin ahead of its first onset.

The art is separately authored Godot curve/line/polygon source. Original hidden rig controls remain read-only. Completed drawings hold after finite settles; no generated image atlas, reference-frame sprites or automatic walking are used. The last pose closes the visual idea; browser replay is a semantic restart, not a certified seamless full-song audio loop.

## Encoded sound

- Exact source section and SHA-256 verified; gain-only music, no tempo/pitch change.
- Full-mix reconstruction correlation **{audio['reconstructionCorrelation']:.5f}**; detected audio delay **{audio['delay']['milliseconds']:.5f} ms**.
- Loudness **{audio['loudness']['integratedLufs']:.2f} LUFS**, true peak **{audio['loudness']['truePeakDbTP']:.2f} dBTP**, zero clipped decoded samples.
- Every named recorded SFX is present in decoded AAC. Source-omission comparisons, clip residual correlation and relative level are retained in [audio.json](audio.json).

These source/level measurements verify the encoded mix. They do not claim a human audition, current platform trend ranking, or audience performance data. Native playback was visually inspected; user listening/creative review remains part of final taste approval.

## Evidence

[Contact sheet](contact.jpg), [export checks](export.json), [audio checks](audio.json), [capture/source record]({rev}.render.json), [direction](../DIRECTION.md), [source-clock cue map](../CUE_MAP.json). Earlier revisions remain local as iteration history. Existing storytime source and outside-Shorts changes passed the batch isolation comparison.
'''
 (r/'QA.md').write_text(qa)
 renders=['# Render index','',f'Current checked export: **{file.name}**. The user approved the earlier direction proof; this new short awaits the user’s creative judgment.','', '| Revision | Movie | Status |','| --- | --- | --- |']
 for m in sorted((p.parent/'renders').glob('*.mp4')):renders.append(f'| {m.stem.split("_")[-2]} | [{m.name}](../renders/{m.name}) | '+('Current checked export' if m==file else 'Superseded iteration, retained')+' |')
 (r/'RENDERS.md').write_text('\n'.join(renders)+'\n')
 for cut in cm['cuts']:cut['measurementStatus']='Actual encoded picture change verified; selected measured accent candidate, not claimed downbeat' if cut['frame'] else 'Immediate opening hook; onset phase is recorded separately'
 cm['exportVerification']={'revision':rev,'allPictureCutsPresent':True,'audioClockPassed':True,'cutAccentMaxErrorAfterOpeningMs':cut_error};(p.parent/'CUE_MAP.json').write_text(json.dumps(cm,indent=2)+'\n')
manifest={'createdUtc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'directionApproval':'User approved InkEdit r3 on 2026-10-05 and asked for this five-short batch. New batch creative acceptance is not inferred.','visualRenderer':'Godot only','shorts':entries};(batch/'MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
header='''# Five Godot ink edits — batch01

The monochrome r3 proof was approved by the user on 5 October 2026. This batch delivers five distinct 15-second music edits with additional gray washes/hatching, authored hand/prop illustrations and event-linked doodles. Every visual frame is drawn in Godot. No image generation or narration is used.

[Watch all five](../../review/batch01/index.html) · [Workflow](../WORKFLOW.md) · [Schema](../SCHEMA.md) · [Batch QA](review/QA.md) · [Storytime isolation](review/ISOLATION.md)

| Short | Character / signature | Music | Checked export |
| --- | --- | --- | --- |
'''
signatures=['Nemi / headphones, sound arcs','ADB / garment cuts and doorway','Nemi / pencil wipe and page constellation','Duo / contrasting gestures and reverse ink','Duo / viewfinder, photo comparison, reaction']
for i,e in enumerate(entries):
 folder=Path(e['folder']).name;fname=Path(e['file']).name;header+=f'| [{e["title"]}]({folder}/DIRECTION.md) | {signatures[i]} | {e["music"]["title"]} — {e["music"]["artist"]} | [{fname}]({folder}/renders/{fname}) |\n'
header+='''
Each production has editable `Edit.tscn` + `short.json`, direction, exact source-clock cue map, `renders/` movies and `review/` evidence. Current revisions are selected in each `review/current.json` and the batch `MANIFEST.json`. The local review player provides native playback, seeking, downloads and source/direction links.

Five actual public official Apple/iTunes preview recordings were downloaded and decoded at unchanged speed. Their exact artist/version, source URL, original/PCM hashes, waveform/onset analysis and chosen intervals are saved in [MUSIC_SOURCES.md](../../assets/music/batch01/MUSIC_SOURCES.md). Source section times refer to the downloaded previews; their offset in the full song is unknown. These are famous/reference-fit selections; current platform trend ranks are unverified.

Original root recorded SFX are retained with exact hashes. The new batch uses no synthesized replacement sounds or character dialogue. Music dominates the edit; each short has one event-linked sound accent.

The source isolation check passed for all 1,081 protected editable files and all 347 existing Git status entries outside `shorts/`. Root project/episode/rig/pose/voice source was unchanged. The accepted original proof and previous movies are preserved. These are held-pose music edits with finite reframes, not a general walking/pickup animation rig. New batch creative acceptance and audience results require user/audience judgment.
'''
(batch/'README.md').write_text(header)
qa='''# Batch01 — final technical and visual review

Five complete exports, each 15.00s / 450 decoded frames /1080×1920 /30fps /H.264 + stereo 48 kHz AAC. All visuals are Godot-authored, with no image generation or reference-video sprites.

| Edit | Revision | Picture accents after opening | Audio source correlation | LUFS | True peak |
| --- | --- | --- | --- | --- | --- |
'''
for e in entries:qa+=f'| {e["title"]} | {e["revision"]} | ≤{e["cutAccentMaxErrorMs"]:.3f}ms | {e["decodedAudioCorrelation"]:.5f} | {e["lufs"]:.2f} | {e["truePeakDbTP"]:.2f}dBTP |\n'
qa+='''
All source hash/range checks, actual encoded cut checks, recorded-SFX contribution checks, audio latency/headroom checks and eight validator rejection tests passed. Decoded audio has zero clipped samples and no measurable source-clock delay. The opening compositions appear immediately and need not land on the first analyzed onset. Later cut timing is measured against selected exact-recording accents; the onset detector is not a downbeat oracle.

Reviewed settled native Godot stills and actual browser playback for all five edits. The art proof caught an ADB sleeve patch and a hand hidden behind hair; both were corrected before the final exports. Phone/pencil grip details are drawn with fixed contact; feet are visible in the wide shots. Handheld props do not slide independently. Doodles enter briefly and then hold; the foreground pencil is one finite wipe, the camera wash lasts two frames, and the duo dark/paper reversals hold between phrase changes.

Each raw Godot capture contains 451 decoded frames. The packager retains exactly 450 authored frames and trims the surplus trailing frame. Godot's summary frame counter does not include every explicit forced-draw call; actual FFprobe decoded counts, encoded cue changes and still/playback inspection are the export evidence. The still route also forces drawing to avoid waiting on a window-dependent frame callback.

Source/level checks establish the encoded sound mix and recorded clip presence; no human audition or current trend rank is claimed. The five last holds close their visual ideas. Native replay is a semantic restart; no seamless full-song audio seam is certified. The user accepted the earlier r3 proof; this batch remains available for their creative review. No retention/CTR/virality gain is inferred without audience data.

Per-short `review/QA.md`, `export.json`, `audio.json`, current revision render records, contact sheets, directions and cue maps are the detailed evidence. [MANIFEST.json](../MANIFEST.json) retains checked export/source identities.

## Isolation

Final [isolation-after.json](isolation-after.json) passed: zero changed/added/removed protected source files; 1,081 original editable files unchanged, root project settings unchanged, and all 347 existing outside-Shorts status entries preserved. Original episodes and their generated media were not edited or cleaned up. Binary media was excluded from hashing; all batch write targets were under `shorts/` or temporary capture directories.
'''
(batch/'review/QA.md').write_text(qa)
sourcefiles=[ROOT/'shorts/godot'/n for n in ['InkPoseArt.gd','InkEdit.gd','BatchPoseArt.gd','BatchAccentArt.gd','BatchEdit.gd','validate_ink.py','render_ink.py','render_batch.gd','project.godot']]+list(batch.glob('0*/short.json'))
source={str(p.relative_to(ROOT)):{'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size} for p in sourcefiles};(batch/'review/SOURCE_HASHES.json').write_text(json.dumps(source,indent=2)+'\n')
print('Saved batch index, five QA/render indices, cue verification, source identities and manifest.')
