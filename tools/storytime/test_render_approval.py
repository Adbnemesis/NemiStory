"""Regression checks for the actual 1080p approval and current-cut binding."""
import json,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
from render_approval import require_1080p_approval,sha,render_inputs_sha256

class Gate(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.root=Path(self.temp.name)
        self.ep=self.root/'nemi/episodes/ep10_example';(self.ep/'review').mkdir(parents=True)
        self.spec=self.ep/'scene.json';self.spec.write_text(json.dumps({'duration':137}))
        self.preview=self.ep/'review.mp4';self.preview.write_bytes(b'test fixture, not a movie')
        self.receipt=self.ep/'review/1080P_APPROVAL.json'
        self.data=dict(approved=True,approved_by='user',user_quote='Test-only simulated user approval.',spec_sha256=sha(self.spec),preview='res://nemi/episodes/ep10_example/review.mp4',preview_sha256=sha(self.preview))
        self.data.update(render_inputs_sha256=render_inputs_sha256(self.spec,self.root),preview_stamp='res://nemi/episodes/ep10_example/review/render_stamp.json')
        (self.ep/'review/render_stamp.json').write_text(json.dumps(dict(render_inputs_sha256=self.data['render_inputs_sha256'],preview_sha256=sha(self.preview))))
        self.probe={'streams':[{'codec_type':'video','width':1920,'height':1080}],'format':{'duration':'137'}}
    def tearDown(self):self.temp.cleanup()
    def run_gate(self):
        with patch('render_approval.subprocess.check_output',return_value=json.dumps(self.probe).encode()):require_1080p_approval(self.spec,self.root)
    def save(self):self.receipt.write_text(json.dumps(self.data))
    def test_missing(self):
        with self.assertRaisesRegex(ValueError,'4K blocked'):self.run_gate()
    def test_agent_cannot_approve(self):
        self.data['approved_by']='agent';self.save()
        with self.assertRaises(ValueError):self.run_gate()
    def test_exact_full_preview(self):self.save();self.run_gate()
    def test_changed_cut(self):
        self.save();self.spec.write_text(json.dumps({'duration':138}))
        with self.assertRaisesRegex(ValueError,'scene changed'):self.run_gate()
    def test_changed_preview(self):
        self.save();self.preview.write_bytes(b'changed')
        with self.assertRaisesRegex(ValueError,'changed'):self.run_gate()
    def test_excerpt_rejected(self):
        self.save();self.probe['format']['duration']='10'
        with self.assertRaisesRegex(ValueError,'full'):self.run_gate()
    def test_4k_is_not_1080p_approval(self):
        self.save();self.probe['streams'][0].update(width=3840,height=2160)
        with self.assertRaisesRegex(ValueError,'full'):self.run_gate()
    def test_external_direction_change(self):
        self.save();folder=self.root/'common/storytime/production';folder.mkdir(parents=True);(folder/'ActingTimeline.gd').write_text('changed wrist direction')
        with self.assertRaisesRegex(ValueError,'inputs changed'):self.run_gate()
    def assert_picture_edit_revokes_approval(self,author,resource):
        self.spec.write_text(json.dumps({'duration':137,'actors':[{'author':author}]}))
        source=self.root/resource
        source.parent.mkdir(parents=True,exist_ok=True)
        source.write_text('original picture source')
        self.data.update(spec_sha256=sha(self.spec),render_inputs_sha256=render_inputs_sha256(self.spec,self.root))
        (self.ep/'review/render_stamp.json').write_text(json.dumps(dict(render_inputs_sha256=self.data['render_inputs_sha256'],preview_sha256=sha(self.preview))))
        self.save();self.run_gate()
        source.write_text('changed picture source')
        with self.assertRaisesRegex(ValueError,'inputs changed'):self.run_gate()
    def test_adb_external_rig_sources_revoke_approval(self):
        for resource in ['adb/poses/ADBPoseLibrary.gd','adb/expressions/ADBFace.gd',
                         'adb/hands/ADBHands.gd','adb/lipsync/ADBLipSync.gd']:
            with self.subTest(resource=resource):
                self.assert_picture_edit_revokes_approval('adb',resource)
    def test_common_ink_and_lettering_revoke_approval(self):
        for author in ['adb','nemi']:
            for resource in ['common/engine/drawing/CommonInkStroke.gd',
                             'common/assets/lettering/story_pen.json']:
                with self.subTest(author=author,resource=resource):
                    self.assert_picture_edit_revokes_approval(author,resource)

if __name__=='__main__':unittest.main()
