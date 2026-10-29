"""Keep short auditions explicit, nonplayable and behind normal source checks."""
import copy
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import types
import unittest
from unittest.mock import Mock,patch

PROJECT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(PROJECT/'tools'))
import validate_episode

spec=importlib.util.spec_from_file_location('audition_render_target',PROJECT/'tools/render.py')
render=importlib.util.module_from_spec(spec);spec.loader.exec_module(render)


def timeline():
    scenes=[]
    for index,(start,end) in enumerate([(0,24),(24,34),(34,45)]):
        scenes.append({'id':f'beat_{index}','start':start,'end':end,'location':'paper room',
            'review_fov':64,'walls':[{'index':wall,'objects':[
                {'id':f'door_{wall}','kind':'sketch_door','author':'nemi','x':960,'y':540}]} for wall in range(4)]})
    return {'kind':'audition','playable':False,'duration':45,'fps':30,'world_renderer':'drawing','scenes':scenes}


class AuditionTimelineContract(unittest.TestCase):
    def test_drawing_audition_is_separate_from_full_game_validation(self):
        result=validate_episode.check_audition_data(timeline())
        self.assertEqual(result['kind'],'audition')
        self.assertIs(result['playable'],False)
        self.assertIsNone(result['digit_map'])
        with self.assertRaisesRegex(ValueError,'explicit audition'):
            validate_episode.check_data(timeline(),{})

    def test_audition_requires_both_explicit_nonplayable_markers(self):
        for changes in [{'kind':'episode'},{'playable':True},{'playable':0}]:
            with self.subTest(changes=changes),self.assertRaisesRegex(ValueError,'declare kind'):
                validate_episode.check_audition_data(dict(timeline(),**changes))

    def test_native_navigation_and_verified_claims_are_not_accepted(self):
        for field,value in [('navigation',None),('interaction_scenes',[]),('challenges',[]),
                ('routes',[]),('automatic_state',False),('game_ready',True),('youtube_verified',True),
                ('spherical_metadata_injected',True)]:
            with self.subTest(field=field),self.assertRaises(ValueError):
                validate_episode.check_audition_data(dict(timeline(),**{field:value}))

    def test_bounded_runtime_frame_rate_and_finite_values(self):
        for changes in [{'duration':29.99},{'duration':60.01},{'duration':float('nan')},
                {'duration':float('inf')},{'fps':True},{'fps':29},{'fps':30.0}]:
            with self.subTest(changes=changes),self.assertRaisesRegex(ValueError,'30–60 seconds'):
                validate_episode.check_audition_data(dict(timeline(),**changes))

    def test_complete_contiguous_unique_scene_clock_is_required(self):
        for edit in ['gap','overlap','empty','duplicate','truncated','between_frames']:
            data=timeline()
            if edit=='gap':data['scenes'][1]['start']=24.1
            if edit=='overlap':data['scenes'][1]['start']=23
            if edit=='empty':data['scenes'][1]['end']=24
            if edit=='duplicate':data['scenes'][1]['id']='beat_0'
            if edit=='truncated':data['scenes'][-1]['end']=44
            if edit=='between_frames':data['scenes'][0]['end']=24.01;data['scenes'][1]['start']=24.01
            with self.subTest(edit=edit),self.assertRaises(ValueError):validate_episode.check_audition_data(data)

    def test_exactly_four_unique_integer_walls_are_required(self):
        for edit in ['missing','duplicate','extra','boolean']:
            data=timeline();walls=data['scenes'][0]['walls']
            if edit=='missing':walls.pop()
            if edit=='duplicate':walls[-1]['index']=2
            if edit=='extra':walls.append(copy.deepcopy(walls[0]))
            if edit=='boolean':walls[0]['index']=False
            with self.subTest(edit=edit),self.assertRaisesRegex(ValueError,'wall'):
                validate_episode.check_audition_data(data)

    def test_drawing_identity_coordinates_and_known_kinds_are_checked(self):
        for changes in [{'author':'adb'},{'kind':'unknown'},{'x':float('nan')},
                {'x':True},{'x':1920},{'y':0},{'id':''}]:
            data=timeline();data['scenes'][0]['walls'][0]['objects'][0].update(changes)
            with self.subTest(changes=changes),self.assertRaises(ValueError):validate_episode.check_audition_data(data)
        for kind in validate_episode.DRAWING_OBJECT_KINDS:
            data=timeline();data['scenes'][0]['walls'][0]['objects'][0]['kind']=kind
            validate_episode.check_audition_data(data)

    def test_school_default_and_renderer_enum_remain_explicit(self):
        data=timeline();data.pop('world_renderer')
        for scene in data['scenes']:
            for wall in scene['walls']:wall['objects'][0]['kind']='door'
        self.assertEqual(validate_episode.check_audition_data(data)['world_renderer'],'school')
        with self.assertRaisesRegex(ValueError,'school or drawing'):
            validate_episode.check_audition_data(dict(data,world_renderer='unrecognized'))

    def test_drawing_actions_have_finite_named_lifetimes_and_real_targets(self):
        for changes in [{'kind':'clock_tick'},{'object':'missing'},{'event':''},
                {'at':float('nan')},{'end':2.6},{'end':24.01}]:
            data=timeline();data['scenes'][0]['environment_events']=[{
                'id':'draw','kind':'tear_open','object':'door_0','at':0,'end':1.6,'event':'paper_opens',**changes}]
            with self.subTest(changes=changes),self.assertRaises(ValueError):validate_episode.check_audition_data(data)
        data=timeline();data['scenes'][0]['environment_events']=[{
            'id':'draw','kind':'tear_open','object':'door_0','at':0,'end':2.5,'event':'paper_opens'}]
        validate_episode.check_audition_data(data)


class AuditionRendererGuards(unittest.TestCase):
    def test_audition_4k_is_refused_but_normal_request_remains_available(self):
        render.validate_export_kind(False,True)
        render.validate_export_kind(True,False)
        with self.assertRaisesRegex(ValueError,'cannot be 4K'):render.validate_export_kind(True,True)

    def test_explicit_flag_controls_validator_and_both_projection_modes_keep_identity(self):
        self.assertEqual(render.validate_timeline(timeline(),audition=True)['kind'],'audition')
        with self.assertRaisesRegex(ValueError,'explicit audition'):render.validate_timeline(timeline(),{})
        self.assertEqual(render.render_identity(True)['kind'],'audition')
        self.assertIs(render.render_identity(True)['playable'],False)
        self.assertEqual(render.render_identity(False)['kind'],'episode')

    def test_events_are_bound_to_canonical_scene_clock(self):
        scene=timeline()['scenes'][0]
        scene['environment_events']=[{'id':'open','kind':'tear_open','object':'door_0',
            'at':2,'end':4.5,'event':'paper_opens'}]
        render.validate_environment_events(scene,{'paper_opens':2},'drawing')
        for events in [{},{'paper_opens':2.1}]:
            with self.subTest(events=events),self.assertRaisesRegex(ValueError,'canonical scene event'):
                render.validate_environment_events(scene,events,'drawing')

    def test_short_storyboard_does_not_bypass_canonical_voice_or_preflight_validation(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary).resolve();scene=root/'scene.json';scene.write_text('{}')
            canonical=types.ModuleType('validate_scene')
            canonical.validate=Mock(side_effect=ValueError('Canonical preflight/voice validation failed'))
            audio=types.ModuleType('audio_mix');audio.mix_audio=Mock();audio.measure_audio=Mock()
            argv=['render.py','--scene',str(scene),'--output',str(root/'audition.mp4'),'--audition','--validate-only']
            with (patch.object(render,'PROJECT',root),patch.object(render,'bootstrap') as bootstrap,
                    patch.object(render,'sync_episode',return_value=scene),patch.object(sys,'argv',argv),
                    patch.dict(sys.modules,{'validate_scene':canonical,'audio_mix':audio})):
                with self.assertRaisesRegex(ValueError,'Canonical preflight/voice'):render.main()
            canonical.validate.assert_called_once_with(scene)
            bootstrap.assert_called_once()
            audio.mix_audio.assert_not_called()


class DrawingWorldContinuity(unittest.TestCase):
    def test_continuity_is_explicit_and_absent_or_false_keeps_scene_local_layouts(self):
        for enabled in [None,False]:
            data=timeline();data['scenes'][1]['walls'][0]['objects'][0]['x']=1200
            if enabled is not None:data['world_continuity']=enabled
            self.assertIs(validate_episode.check_audition_data(data)['world_continuity'],False)
        data=timeline();data['world_continuity']=True
        self.assertIs(validate_episode.check_audition_data(data)['world_continuity'],True)

    def test_only_a_boolean_drawing_flag_is_supported(self):
        for value in [0,1,'true',None,[],{}]:
            with self.subTest(value=value),self.assertRaisesRegex(ValueError,'boolean'):
                validate_episode.check_audition_data(dict(timeline(),world_continuity=value))
        for value in [True,False]:
            with self.subTest(value=value),self.assertRaisesRegex(ValueError,'only by the drawing'):
                validate_episode.check_audition_data(dict(timeline(),world_renderer='school',world_continuity=value))

    def test_cross_scene_object_identity_kind_and_position_must_match(self):
        for changes in [{'id':'a_different_door'},{'kind':'page_tear'},{'x':959},{'y':541}]:
            data=timeline();data['world_continuity']=True
            data['scenes'][1]['walls'][0]['objects'][0].update(changes)
            with self.subTest(changes=changes),self.assertRaisesRegex(ValueError,'matching walls'):
                validate_episode.check_audition_data(data)
        data=timeline();data['world_continuity']=True;data['scenes'][1]['walls'][0]['objects']=[]
        with self.assertRaisesRegex(ValueError,'matching walls'):validate_episode.check_audition_data(data)

    def test_moving_an_object_to_another_wall_breaks_continuity(self):
        data=timeline();data['world_continuity']=True
        data['scenes'][1]['walls'][0]['objects'],data['scenes'][1]['walls'][1]['objects']=data['scenes'][1]['walls'][1]['objects'],data['scenes'][1]['walls'][0]['objects']
        with self.assertRaisesRegex(ValueError,'matching walls'):validate_episode.check_audition_data(data)

    def test_layout_matching_does_not_depend_on_list_order_or_held_labels(self):
        data=timeline();data['world_continuity']=True
        for scene in data['scenes']:
            scene['walls'][0]['objects'].append({'id':'tear','kind':'page_tear','author':'nemi','x':1300,'y':540})
        data['scenes'][1]['walls'][0]['objects'].reverse();data['scenes'][1]['walls'].reverse()
        data['scenes'][2]['walls'][0]['objects'][0].update(text='The door stays here',accent='rose')
        validate_episode.check_audition_data(data)

    def test_continuous_event_ids_are_unique_across_scenes(self):
        data=timeline();data['world_continuity']=True
        data['scenes'][0]['environment_events']=[{'id':'sweep','kind':'erase_sweep','object':'door_0','at':2,'end':3,'event':'erase'}]
        data['scenes'][1]['environment_events']=[{'id':'rewind','kind':'rewind','object':'door_0','at':25,'end':26,'event':'undo'}]
        validate_episode.check_audition_data(data)
        data['scenes'][1]['environment_events'][0]['id']='sweep'
        with self.assertRaisesRegex(ValueError,'unique nonempty IDs across'):
            validate_episode.check_audition_data(data)


if __name__=='__main__':unittest.main()
