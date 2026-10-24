#!/usr/bin/env python3
"""Verify external message masters without claiming perceptual listening."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[2]

def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def aac_payload(path):
    return subprocess.check_output(['ffmpeg','-v','error','-i',str(path),'-map','0:a:0','-c:a','copy','-f','adts','-'])

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--author',choices=['adb','nemi'],required=True)
    parser.add_argument('--movie',type=Path,required=True)
    args=parser.parse_args();movie=args.movie.resolve()
    ep='ep08_message_to_storytime_animators' if args.author=='adb' else 'ep17_message_to_storytime_animators'
    folder=ROOT/args.author/'episodes'/ep;review=folder/'review/edit_4k';records=review/'render_records'
    records.mkdir(parents=True,exist_ok=True)
    approval=json.loads((review/'1080P_EXTERNAL_EDIT_APPROVAL.json').read_text())
    probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_entries','stream=codec_type,codec_name,width,height,avg_frame_rate,nb_read_frames,duration,start_time,sample_rate,channels:format=duration','-of','json',str(movie)]))
    video=next(s for s in probe['streams'] if s['codec_type']=='video')
    assert (video['width'],video['height'],video['avg_frame_rate'],int(video['nb_read_frames']))==(3840,2160,'30/1',750)
    assert abs(float(video['duration'])-25)<1e-6
    assert abs(float(probe['format']['duration'])-25)<.01
    # Hash every decoded full-resolution RGB tail frame, not a thumbnail sample.
    hashes=subprocess.check_output(['ffmpeg','-v','error','-i',str(movie),'-map','0:v:0','-vf',r'select=gte(n\,663),format=rgb24','-vsync','0','-f','framemd5','-'],text=True)
    decoded=[line.rsplit(',',1)[-1].strip() for line in hashes.splitlines() if line and not line.startswith('#')]
    black_md5=hashlib.md5(bytes(3840*2160*3)).hexdigest()
    assert len(decoded)==87 and all(digest==black_md5 for digest in decoded)
    old=aac_payload(review/'approved_r9_audio.m4a');new=aac_payload(movie)
    assert old==new,'AAC payload changed; do not clean approved media.'
    assert sha(ROOT/approval['approved_audio_archive'])==approval['approved_audio_archive_sha256']
    assert hashlib.sha256(old).hexdigest()==approval['approved_aac_adts_sha256']
    timeline=json.loads((folder/'edit_rebuild/picture_timeline.json').read_text())
    shots=timeline['shots'];assert shots[0]['start_frame']==0 and shots[-1]['end_frame']==750
    assert all(a['end_frame']==b['start_frame'] for a,b in zip(shots,shots[1:]))
    receipt=records/(movie.stem+'.json');data=json.loads(receipt.read_text())
    assert data['movie_sha256']==sha(movie)
    assert all(sha(ROOT/p)==h for p,h in data['inputs'].items())
    assert all(sha(path)==digest for path,digest in data['fonts'].items())
    measurement=subprocess.run(['ffmpeg','-hide_banner','-i',str(movie),'-af','ebur128=peak=true','-f','null','-'],capture_output=True,text=True,check=True).stderr.rsplit('Summary:',1)[-1]
    result=dict(author=args.author,movie=str(movie.relative_to(ROOT)),movie_sha256=sha(movie),format=probe,
        approved_preview_sha256=approval['preview_sha256'],approval_receipt=str((review/'1080P_EXTERNAL_EDIT_APPROVAL.json').relative_to(ROOT)),
        exact_approved_aac_payload=True,aac_adts_sha256=hashlib.sha256(new).hexdigest(),aac_bytes=len(new),
        picture_timeline_unchanged=True,all_render_inputs_current=True,
        black_tail=dict(start_frame=663,end_frame=749,start_s=22.1,frames=87,every_full_rgb_frame_matches_all_zero=True,full_rgb_frame_md5=black_md5),
        loudness_summary=measurement.strip(),
        resolution_provenance=data['raster_provenance'],
        limits='Full-file decoded numerical checks and sampled decoded visual inspection; no new full-speed perceptual audio-listening claim. Audio is bit-identical to the user-approved R9 AAC payload.')
    (records/'FINAL_4K_CHECKS.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()
