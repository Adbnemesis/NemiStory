"""Remove only EP15 superseded movie/proof media after verified4K replacement."""
import hashlib,json,shutil
from pathlib import Path
EP_REL=Path('nemi/episodes/ep15_i_get_attached_way_too_much')
ROOTS=[Path('/Users/talus/Documents/adb'),Path('/Users/talus/.codex/worktrees/nemi-ep15-review/adb')]
MASTER='NEMI_EP15_I_Get_Attached_Way_Too_Much_r5_4K_FINAL.mp4'
MOVIES={'.mp4','.mov','.avi','.mkv','.webm'}
IMAGES={'.png','.jpg','.jpeg','.webp'}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
source_ep=ROOTS[1]/EP_REL
qa=json.loads((source_ep/'review/final_4k/QA.json').read_text())
assert qa['full_decode_passed'] and qa['visual_review_passed'] and qa['playback_review_passed']
assert qa['compressed_audio_packets_identical_to_user_approved_preview']
assert qa['encoded_audio']['true_peak_dbfs']<=-1
master_sha=qa['movie_sha256']
for root in ROOTS:
    assert sha(root/EP_REL/'renders'/MASTER)==master_sha
    # Preserve exact voice, script, episode source, thumbnail candidates and references.
    ep=root/EP_REL
    protected={str(p.relative_to(ep)):sha(p) for p in ep.rglob('*') if p.is_file() and ('voice' in p.relative_to(ep).parts or p.suffix in {'.py','.gd'} or p.parent==ep and p.suffix in {'.md','.json'})}
    thumb=ep/'thumbnail'
    protected.update({str(p.relative_to(ep)):sha(p) for p in thumb.rglob('*') if p.is_file()})
    records=ep/'review/render_records';records.mkdir(parents=True,exist_ok=True)
    removed=[];moved=[]
    for folder in [ep/'renders',root/'renders/nemi_ep15']:
        if not folder.exists():continue
        for p in list(folder.rglob('*')):
            if not p.is_file() and not p.is_symlink():continue
            if p.name==MASTER and p.parent==ep/'renders':continue
            if p.suffix in MOVIES or p.suffix in IMAGES or p.name=='review_player.html':
                # Never follow a preview symlink when deleting it.
                removed.append(dict(path=str(p),bytes=p.lstat().st_size,sha256=None if p.is_symlink() else sha(p),kind='symlink' if p.is_symlink() else 'superseded_movie' if p.suffix in MOVIES else 'temporary_review_media'))
                p.unlink()
            elif p.suffix in {'.json','.log','.md'}:
                target=records/('workspace_proofs' if folder!=ep/'renders' else '')/p.name
                target.parent.mkdir(parents=True,exist_ok=True)
                if target.exists():
                    assert target.read_bytes()==p.read_bytes(),str(target)
                    p.unlink()
                else:shutil.move(p,target)
                moved.append(dict(source=str(p),destination=str(target)))
    # Keep final4K evidence, colour-treatment references and thumbnail reference art.
    for p in list((ep/'review').rglob('*')):
        if not p.is_file() or p.suffix.lower() not in IMAGES:continue
        if any(x in p.relative_to(ep/'review').parts for x in ['final_4k','colour_reference']):continue
        removed.append(dict(path=str(p),bytes=p.stat().st_size,sha256=sha(p),kind='superseded_generated_review_still'))
        p.unlink()
    for folder in [ep/'renders',root/'renders/nemi_ep15',ep/'review']:
        if folder.exists():
            for d in sorted([d for d in folder.rglob('*') if d.is_dir()],key=lambda x:len(x.parts),reverse=True):
                if not any(d.iterdir()):d.rmdir()
    assert list((ep/'renders').iterdir())==[ep/'renders'/MASTER]
    for rel,h in protected.items():assert sha(ep/rel)==h,'Protected source changed: '+rel
    record=dict(user_request='yep looks good, now render this in 4k and delete all other renders and also do the thumbnails',scope='This EP15 episode and its workspace renders/nemi_ep15 only; no unrelated episodes or global references.',verified_replacement=str(ep/'renders'/MASTER),verified_replacement_sha256=master_sha,removed=removed,moved_records=moved,protected_source_files_verified=len(protected),voice_and_scripts_and_thumbnail_candidates_preserved=True,renders_folder_contains_only_final_4k=True,approval_receipt_historical_note='Approved1080p preview was intentionally removed after final4K passed, as requested. Its realapproval quote/hash/stamp and QA remain; no futureapprovalreceipt is fabricated.',unrelated_episodes_modified=False)
    (ep/'review/CLEANUP_FINAL_4K.json').write_text(json.dumps(record,indent=2)+'\n')
    print(root,': removed',len(removed),'superseded media files, moved',len(moved),'records; final4K only.')
