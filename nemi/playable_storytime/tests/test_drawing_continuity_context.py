"""Authored material continuity and optional local attention share one clock."""
import copy
import importlib.util
import json
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('continuity_context_validation',ROOT/'tools/validate_episode.py')
validation=importlib.util.module_from_spec(spec);spec.loader.exec_module(validation)


def fixture():
    walls=[{'index':index,'objects':[]} for index in range(4)]
    walls[0]['objects']=[
        {'id':'tear','kind':'page_tear','author':'nemi','x':500,'y':610},
        {'id':'tab','kind':'paper_tab','author':'nemi','x':1100,'y':720}]
    scenes=[{'id':f's{key}','start':key*24,'end':(key+1)*24,
        'location':'gap_room','review_yaw':0,'walls':copy.deepcopy(walls)} for key in range(10)]
    timeline={'world_renderer':'drawing','duration':240,'fps':30,'scenes':scenes}
    game={'duration':240,'automatic_state':False,'challenges':[],'routes':[]}
    return timeline,game


class HeldMaterialStateTests(unittest.TestCase):
    def test_open_tear_and_folded_tab_are_valid_held_states_without_new_events(self):
        timeline,game=fixture()
        for scene in timeline['scenes']:
            scene['walls'][0]['objects'][0]['opened']=True
            scene['walls'][0]['objects'][1]['folded']=True
        timeline['world_continuity']=True
        validation.check_data(timeline,game)
        self.assertEqual(timeline['scenes'][1]['environment_events'] if 'environment_events' in timeline['scenes'][1] else [],[])

    def test_absent_and_explicit_false_have_the_same_continuity_identity(self):
        timeline,game=fixture();before=timeline['scenes'][0];after=copy.deepcopy(before)
        after['walls'][0]['objects'][0]['opened']=False
        after['walls'][0]['objects'][1]['folded']=False
        self.assertEqual(validation.continuity_layout(before),validation.continuity_layout(after))

    def test_state_flags_reject_non_boolean_values_in_full_validation(self):
        for field,index in [('opened',0),('folded',1)]:
            for value in [0,1,None,'true',[],float('nan')]:
                timeline,game=fixture();timeline['scenes'][0]['walls'][0]['objects'][index][field]=value
                with self.subTest(field=field,value=value),self.assertRaisesRegex(ValueError,'must be a boolean'):
                    validation.check_data(timeline,game)

    def test_held_states_cannot_leak_to_other_kinds_or_the_school_renderer(self):
        for field,index in [('opened',1),('folded',0)]:
            timeline,game=fixture();timeline['scenes'][0]['walls'][0]['objects'][index][field]=True
            with self.subTest(field=field),self.assertRaisesRegex(ValueError,'only on drawing'):
                validation.check_data(timeline,game)
        timeline,game=fixture();timeline['world_renderer']='school'
        for scene in timeline['scenes']:
            for obj in scene['walls'][0]['objects']:obj['kind']='door'
        timeline['scenes'][0]['walls'][0]['objects'][0]['opened']=True
        with self.assertRaisesRegex(ValueError,'only on drawing'):
            validation.check_data(timeline,game)

    def test_incompatible_states_cannot_share_continuity_group_or_global_state(self):
        for grouped in [False,True]:
            timeline,game=fixture()
            if grouped:
                for scene in timeline['scenes']:scene['continuity_group']='same_material'
            else:timeline['world_continuity']=True
            timeline['scenes'][1]['walls'][0]['objects'][0]['opened']=True
            with self.subTest(grouped=grouped),self.assertRaisesRegex(ValueError,'matching walls'):
                validation.check_data(timeline,game)


class PreviewContinuityContextTests(unittest.TestCase):
    def enhanced(self):
        timeline,game=fixture();timeline['preview_choice_turns']=True
        timeline['preview_goal']='Get Nemi through the tear and out to the solid desk.'
        timeline['preview_handoffs']=[{'at':24,'yaw':-90,'duration':.8},{'at':48,'yaw':90,'duration':1.1}]
        return timeline,game

    def test_goal_and_handoffs_are_optional_local_context_on_existing_boundaries(self):
        timeline,game=self.enhanced();result=validation.check_data(timeline,game)
        self.assertEqual(result['preview_handoffs'],timeline['preview_handoffs'])
        timeline,game=fixture();self.assertEqual(validation.check_data(timeline,game)['preview_handoffs'],[])

    def test_saved_field_example_can_be_merged_into_a_complete_authored_timeline(self):
        example=json.loads((ROOT/'documentation/examples/drawing_continuity_context.json').read_text())
        timeline,game=fixture();timeline.update(example['timeline_fragment'])
        for scene in timeline['scenes']:
            scene['walls'][0]['objects']=copy.deepcopy(example['held_object_fragments'])
        validation.check_data(timeline,game)

    def test_goal_can_remain_visible_without_forcing_enhanced_view_control(self):
        timeline,game=fixture();timeline['preview_goal']='Keep heading toward the real desk.'
        validation.check_data(timeline,game)

    def test_goal_is_a_short_nonempty_single_line_drawing_context(self):
        for value in ['',None,'   ',' goal','goal ','a\nb','a\rb','word '*17,'x'*141]:
            timeline,game=fixture();timeline['preview_goal']=value
            with self.subTest(value=value),self.assertRaises(ValueError):validation.check_data(timeline,game)
        timeline,game=fixture();timeline['preview_goal']='Find the real desk.'
        with self.assertRaisesRegex(ValueError,'only by the drawing'):
            validation.validate_preview_context(timeline,'school')

    def test_handoffs_require_drawing_renderer_and_explicit_enhanced_opt_in(self):
        for value in [None,False,1]:
            timeline,game=self.enhanced()
            if value is None:timeline.pop('preview_choice_turns')
            else:timeline['preview_choice_turns']=value
            with self.subTest(value=value),self.assertRaises(ValueError):validation.check_data(timeline,game)
        timeline,game=self.enhanced();timeline.pop('preview_goal')
        with self.assertRaisesRegex(ValueError,'only by the drawing'):
            validation.validate_preview_context(timeline,'school')

    def test_handoffs_reject_unknown_fields_invalid_arrays_and_nonfinite_values(self):
        for edit in ['not_array','not_object','missing_duration','extra_pitch','at_bool','at_nan',
                'yaw_nan','yaw_infinity','duration_bool','duration_nan']:
            timeline,game=self.enhanced();handoff=timeline['preview_handoffs'][0]
            if edit=='not_array':timeline['preview_handoffs']={}
            if edit=='not_object':timeline['preview_handoffs'][0]=[]
            if edit=='missing_duration':handoff.pop('duration')
            if edit=='extra_pitch':handoff['pitch']=0
            if edit=='at_bool':handoff['at']=True
            if edit=='at_nan':handoff['at']=float('nan')
            if edit=='yaw_nan':handoff['yaw']=float('nan')
            if edit=='yaw_infinity':handoff['yaw']=float('inf')
            if edit=='duration_bool':handoff['duration']=True
            if edit=='duration_nan':handoff['duration']=float('nan')
            with self.subTest(edit=edit),self.assertRaises(ValueError):validation.check_data(timeline,game)

    def test_handoffs_cannot_add_initial_midscene_duplicate_or_backward_cuts(self):
        for times in [[0],[24.5],[240],[24,24],[48,24]]:
            timeline,game=self.enhanced()
            timeline['preview_handoffs']=[{'at':at,'yaw':0,'duration':.8} for at in times]
            with self.subTest(times=times),self.assertRaisesRegex(ValueError,'existing noninitial scene boundaries'):
                validation.check_data(timeline,game)

    def test_handoff_yaw_and_duration_have_finite_bounded_windows(self):
        for field,value in [('yaw',-180.01),('yaw',180.01),('duration',.199),('duration',2.001)]:
            timeline,game=self.enhanced();timeline['preview_handoffs'][0][field]=value
            with self.subTest(field=field,value=value),self.assertRaises(ValueError):validation.check_data(timeline,game)
        for yaw,duration in [(-180,.2),(180,2)]:
            timeline,game=self.enhanced();timeline['preview_handoffs'][0].update(yaw=yaw,duration=duration)
            validation.check_data(timeline,game)

    def test_handoff_must_finish_inside_the_following_scene(self):
        timeline,game=self.enhanced();timeline['scenes'][1]['end']=24.1;timeline['scenes'][2]['start']=24.1
        timeline['preview_handoffs']=[{'at':24,'yaw':0,'duration':.2}]
        with self.assertRaisesRegex(ValueError,'inside the following scene'):
            validation.check_data(timeline,game)


if __name__=='__main__':unittest.main()
