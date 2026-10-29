"""Exercise real approval and voice guards using disposable synthetic fixtures.

No production approval receipt is written. Probe results are mocked; these tests
verify refusal behavior and do not establish that any movie is valid or approved.
"""
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

PROJECT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT / 'tools'))


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    loaded = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loaded)
    return loaded


render = module('playable_render_guardrail_target', PROJECT / 'tools/render.py')
voice = module('playable_voice_guardrail_target', PROJECT / 'tools/voice.py')


class ReviewCameraGuardrails(unittest.TestCase):
    def segment(self,**changes):
        return {'start':24,'end':48,'review_fov':64,'review_yaw':0,**changes}

    def beat(self,**changes):
        return {'at':26,'yaw':-17,'pitch':16,'fov':34,'duration':.18,
                'intent':'Read Nemi before returning to the room',**changes}

    def test_legacy_static_and_yaw_paths_remain_valid(self):
        render.validate_review_camera(self.segment())
        render.validate_review_camera(self.segment(review_yaw_path=[{'at':24,'yaw':0},{'at':35,'yaw':90},{'at':48,'yaw':0}]))

    def test_portrait_and_wide_beats_validate_independently(self):
        render.validate_review_camera(self.segment(review_camera_beats=[self.beat(),
            self.beat(at=30,yaw=180,pitch=-25,fov=110,duration=0),
            self.beat(at=40,yaw=-180,pitch=25,fov=50,duration=.5)]))

    def test_optional_pitch_and_duration_follow_renderer_defaults(self):
        beat=self.beat();beat.pop('pitch');beat.pop('duration')
        render.validate_review_camera(self.segment(review_camera_beats=[beat]))

    def test_unprepared_nonfinite_or_wrong_type_beats_are_refused(self):
        for field in ['at','yaw','pitch','fov','duration']:
            for value in [float('nan'),float('inf'),'34',True,None]:
                with self.subTest(field=field,value=value),self.assertRaisesRegex(ValueError,'finite'):
                    render.validate_review_camera(self.segment(review_camera_beats=[self.beat(**{field:value})]))

    def test_projection_bounds_are_enforced_after_freezing(self):
        for changes in [{'yaw':181},{'yaw':-181},{'pitch':25.1},{'pitch':-25.1},{'fov':33.9},{'fov':110.1}]:
            with self.subTest(changes=changes),self.assertRaisesRegex(ValueError,'projection'):
                render.validate_review_camera(self.segment(review_camera_beats=[self.beat(**changes)]))

    def test_negative_duration_and_scene_boundary_crossing_are_refused(self):
        for changes in [{'duration':-.01},{'at':23.9},{'at':48,'duration':0},{'at':47.9,'duration':.2}]:
            with self.subTest(changes=changes),self.assertRaisesRegex(ValueError,'inside its scene'):
                render.validate_review_camera(self.segment(review_camera_beats=[self.beat(**changes)]))

    def test_overlapping_out_of_order_and_duplicate_beats_are_refused(self):
        for second in [self.beat(at=26.1),self.beat(at=25),self.beat(at=26,duration=0)]:
            with self.subTest(second=second),self.assertRaisesRegex(ValueError,'without overlapping'):
                render.validate_review_camera(self.segment(review_camera_beats=[self.beat(),second]))

    def test_camera_metadata_requires_array_intention_and_known_fields(self):
        for beats in [{},[self.beat(intent='')],[self.beat(zoom=2)]]:
            with self.subTest(beats=beats),self.assertRaises(ValueError):
                render.validate_review_camera(self.segment(review_camera_beats=beats))

    def test_base_fov_keeps_its_wide_range_and_yaw_must_be_finite(self):
        for changes in [{'review_fov':34},{'review_fov':float('nan')},{'review_yaw':float('inf')}]:
            with self.subTest(changes=changes),self.assertRaises(ValueError):
                render.validate_review_camera(self.segment(**changes))


class ApprovalGuardrails(unittest.TestCase):
    def setUp(self):
        temporary_root = PROJECT / 'cache' / 'test-fixtures'
        temporary_root.mkdir(parents=True, exist_ok=True)
        self.temporary = tempfile.TemporaryDirectory(prefix='approval-', dir=temporary_root)
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.episode = self.root / 'episodes/test_only'
        (self.episode / 'review').mkdir(parents=True)
        self.scene = self.episode / 'scene.json'
        self.scene.write_text(json.dumps({'duration': 300, 'fps': 30, 'title': 'Disposable test fixture'}))
        self.preview = self.episode / 'synthetic_fixture.mp4'
        self.preview.write_bytes(b'TEST BYTES ONLY; NOT A MOVIE OR REAL APPROVAL')
        self.godot = self.root / 'isolated_godot'
        self.godot.mkdir()
        self.character = self.godot / 'Character.gd'
        self.character.write_text('extends Node2D\n# disposable fixture\n')
        self.audio = self.godot / 'voice.wav'
        self.audio.write_bytes(b'DISPOSABLE AUDIO HASH FIXTURE')
        self.addCleanup(patch.stopall)
        patch.object(render, 'PROJECT', self.root).start()
        patch.object(render, 'GODOT', self.godot).start()
        self.probe = patch.object(render, 'probe', return_value={
            'streams': [{'codec_type': 'video', 'width': 1920, 'height': 1080}],
            'format': {'duration': '300.000000'},
        }).start()
        self.input_signature = render.signature(self.scene)
        self.receipt = self.episode / 'review/1080P_APPROVAL.json'
        self.report = self.episode / 'review/synthetic_fixture.render.json'
        self.fixture_report = {
            'video': str(self.preview.relative_to(self.root)),
            'video_sha256': render.sha(self.preview),
            'spec_sha256': render.sha(self.scene),
            'render_inputs_sha256': self.input_signature,
            'start': 0, 'duration': 300, 'fps': 30, 'frames': 9000,
            'mode': 'review', 'resolution': [1920, 1080],
        }
        self.report.write_text(json.dumps(self.fixture_report))
        self.fixture_data = {
            'approved': True, 'approved_by': 'user',
            'user_quote': 'TEST FIXTURE ONLY. This is not real user approval.',
            'spec_sha256': render.sha(self.scene),
            'preview': str(self.preview.relative_to(self.root)),
            'preview_sha256': render.sha(self.preview),
            'render_inputs_sha256': self.input_signature,
            'preview_report': str(self.report.relative_to(self.root)),
            'preview_report_sha256': render.sha(self.report),
        }

    def write_fixture_receipt(self, **changes):
        data = dict(self.fixture_data)
        data.update(changes)
        self.receipt.write_text(json.dumps(data))

    def write_fixture_report(self, **changes):
        data = dict(self.fixture_report)
        data.update(changes)
        self.report.write_text(json.dumps(data))
        self.write_fixture_receipt(preview_report_sha256=render.sha(self.report))

    def test_missing_receipt_refused(self):
        with self.assertRaisesRegex(ValueError, 'explicit user satisfaction'):
            render.require_approval(self.scene, self.input_signature)
        self.probe.assert_not_called()

    def test_only_matching_full_1080_fixture_passes(self):
        self.write_fixture_receipt()
        render.require_approval(self.scene, self.input_signature)
        self.probe.assert_called_once_with(self.preview)

    def test_wrong_spec_hash_refused(self):
        self.write_fixture_receipt(spec_sha256='0' * 64)
        with self.assertRaisesRegex(ValueError, 'not bound'):
            render.require_approval(self.scene, self.input_signature)

    def test_wrong_preview_hash_refused(self):
        self.write_fixture_receipt(preview_sha256='0' * 64)
        with self.assertRaisesRegex(ValueError, 'not bound'):
            render.require_approval(self.scene, self.input_signature)

    def test_changed_preview_refused(self):
        self.write_fixture_receipt()
        self.preview.write_bytes(b'CHANGED TEST PREVIEW')
        with self.assertRaisesRegex(ValueError, 'not bound'):
            render.require_approval(self.scene, self.input_signature)

    def test_wrong_input_signature_refused(self):
        self.write_fixture_receipt(render_inputs_sha256='0' * 64)
        with self.assertRaisesRegex(ValueError, 'not bound'):
            render.require_approval(self.scene, self.input_signature)

    def test_missing_renderer_report_refused(self):
        self.write_fixture_receipt()
        self.report.unlink()
        with self.assertRaisesRegex(ValueError, 'actual renderer report'):
            render.require_approval(self.scene, self.input_signature)
        self.probe.assert_not_called()

    def test_unbound_renderer_report_refused(self):
        self.write_fixture_receipt(preview_report_sha256='0' * 64)
        with self.assertRaisesRegex(ValueError, 'actual renderer report'):
            render.require_approval(self.scene, self.input_signature)

    def test_report_changed_after_receipt_refused(self):
        self.write_fixture_receipt()
        self.report.write_text(json.dumps(dict(self.fixture_report, frames=8999)))
        with self.assertRaisesRegex(ValueError, 'actual renderer report'):
            render.require_approval(self.scene, self.input_signature)

    def test_renderer_report_outside_project_refused(self):
        self.write_fixture_receipt(preview_report='../outside_report.json')
        with self.assertRaisesRegex(ValueError, 'actual renderer report'):
            render.require_approval(self.scene, self.input_signature)

    def test_bound_report_still_requires_exact_movie_and_full_render(self):
        invalid_reports = [
            {'video': 'episodes/test_only/other_preview.mp4'},
            {'video_sha256': '0' * 64},
            {'spec_sha256': '0' * 64},
            {'render_inputs_sha256': '0' * 64},
            {'start': 10},
            {'duration': 48},
            {'fps': 24},
            {'frames': 8999},
            {'mode': 'sphere'},
            {'resolution': [2160, 1080]},
        ]
        for changes in invalid_reports:
            with self.subTest(changes=changes):
                self.write_fixture_report(**changes)
                with self.assertRaisesRegex(ValueError, 'Renderer report does not match'):
                    render.require_approval(self.scene, self.input_signature)
        self.probe.assert_not_called()

    def test_recomputed_receipt_signature_cannot_reapprove_old_preview_report(self):
        # Model an accidental receipt created from new sources alongside an old
        # movie: the immutable historical report must prevent this mismatch.
        self.character.write_text('extends Node2D\n# newer unreviewed direction\n')
        changed = render.signature(self.scene)
        self.assertNotEqual(changed, self.input_signature)
        self.write_fixture_receipt(render_inputs_sha256=changed)
        with self.assertRaisesRegex(ValueError, 'Renderer report does not match'):
            render.require_approval(self.scene, changed)
        self.probe.assert_not_called()

    def test_audition_report_cannot_be_reused_for_full_episode_approval(self):
        self.write_fixture_report(kind='audition',playable=False)
        with self.assertRaisesRegex(ValueError,'audition report cannot qualify'):
            render.require_approval(self.scene,self.input_signature)
        self.probe.assert_not_called()

    def test_wrong_resolution_refused(self):
        self.write_fixture_receipt()
        self.probe.return_value['streams'][0].update(width=2160, height=1080)
        with self.assertRaisesRegex(ValueError, 'complete current 1920x1080'):
            render.require_approval(self.scene, self.input_signature)

    def test_incomplete_preview_refused(self):
        self.write_fixture_receipt()
        self.probe.return_value['format']['duration'] = '10.000000'
        with self.assertRaisesRegex(ValueError, 'complete current 1920x1080'):
            render.require_approval(self.scene, self.input_signature)

    def test_agent_approval_and_empty_quote_refused(self):
        for changes in [{'approved_by': 'agent'}, {'user_quote': '  '}, {'approved': False}]:
            with self.subTest(changes=changes):
                self.write_fixture_receipt(**changes)
                with self.assertRaisesRegex(ValueError, 'not bound'):
                    render.require_approval(self.scene, self.input_signature)

    def test_preview_outside_project_refused(self):
        self.write_fixture_receipt(preview='../outside_project.mp4')
        with self.assertRaisesRegex(ValueError, 'outside this project'):
            render.require_approval(self.scene, self.input_signature)

    def test_picture_source_change_invalidates_approval(self):
        self.write_fixture_receipt()
        self.character.write_text('extends Node2D\n# changed picture source\n')
        changed = render.signature(self.scene)
        self.assertNotEqual(changed, self.input_signature)
        with self.assertRaisesRegex(ValueError, 'not bound'):
            render.require_approval(self.scene, changed)

    def test_voice_source_change_invalidates_approval(self):
        self.write_fixture_receipt()
        self.audio.write_bytes(b'CHANGED AUDIO INPUT')
        changed = render.signature(self.scene)
        self.assertNotEqual(changed, self.input_signature)
        with self.assertRaisesRegex(ValueError, 'not bound'):
            render.require_approval(self.scene, changed)

    def test_scene_edit_invalidates_approval(self):
        self.write_fixture_receipt()
        self.scene.write_text(json.dumps({'duration': 300, 'title': 'Edited picture direction'}))
        with self.assertRaisesRegex(ValueError, 'not bound'):
            render.require_approval(self.scene, self.input_signature)

    def test_runtime_cache_does_not_change_input_signature(self):
        runtime = self.godot / '.godot'
        runtime.mkdir()
        (runtime / 'cache.gd').write_text('disposable generated cache')
        self.assertEqual(render.signature(self.scene), self.input_signature)


class VoiceWindowGuardrails(unittest.TestCase):
    def setUp(self):
        temporary_root = PROJECT / 'cache' / 'test-fixtures'
        temporary_root.mkdir(parents=True, exist_ok=True)
        self.temporary = tempfile.TemporaryDirectory(prefix='voice-', dir=temporary_root)
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.episode = self.root / 'episodes/test_only'
        (self.episode / 'scripts').mkdir(parents=True)
        self.addCleanup(patch.stopall)
        patch.object(voice, 'ROOT', self.root).start()
        self.clip = {'id': 'test_line', 'text': 'A disposable test line.', 'at': .4, 'window_end': 9, 'tempo': 1.08}

    def write_dialogue(self, clips):
        (self.episode / 'scripts/dialogue.json').write_text(json.dumps({'duration': 30, 'clips': clips}))

    def test_unsafe_output_path_refused(self):
        with self.assertRaisesRegex(ValueError, 'inside playable_storytime'):
            voice.safe(self.root.parent / 'outside.wav')

    def test_symlink_escape_refused(self):
        link = self.root / 'escape'
        link.symlink_to(self.root.parent, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, 'inside playable_storytime'):
            voice.safe(link / 'outside.wav')

    def test_maximum_storytime_tempo_accepted(self):
        self.write_dialogue([dict(self.clip, tempo=1.15)])
        _, data, duration = voice.read_dialogue('episodes/test_only')
        self.assertEqual(data['clips'][0]['tempo'], 1.15)
        self.assertEqual(duration, 30)

    def test_excessive_tempo_refused(self):
        self.write_dialogue([dict(self.clip, tempo=1.1501)])
        with self.assertRaisesRegex(ValueError, '1.00'):
            voice.read_dialogue('episodes/test_only')

    def test_overlapping_spoken_windows_refused(self):
        self.write_dialogue([self.clip, dict(self.clip, id='second_line', at=8.9, window_end=15)])
        with self.assertRaisesRegex(ValueError, 'Overlapping'):
            voice.read_dialogue('episodes/test_only')

    def test_nonfinite_timing_refused(self):
        self.write_dialogue([dict(self.clip, at=float('nan'))])
        with self.assertRaisesRegex(ValueError, 'Nonfinite'):
            voice.read_dialogue('episodes/test_only')


if __name__ == '__main__':
    unittest.main()
