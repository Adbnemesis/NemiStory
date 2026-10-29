"""Fixed material landmarks stay valid drawing art without inventing gameplay."""
import copy
import importlib.util
import json
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
loader=importlib.util.spec_from_file_location('material_validation',ROOT/'tools/validate_episode.py')
validation=importlib.util.module_from_spec(loader);loader.loader.exec_module(validation)
fixtures_loader=importlib.util.spec_from_file_location('material_full_fixture',Path(__file__).with_name('test_drawing_full_game.py'))
fixtures=importlib.util.module_from_spec(fixtures_loader);fixtures_loader.loader.exec_module(fixtures)
EXAMPLE=json.loads((ROOT/'documentation/examples/drawing_material_props.json').read_text())
CONTEXT={'ruler','ink_bottle','paper_stack','paper_clip'}


def fixture():
    timeline,game=fixtures.fixture()
    for scene in timeline['scenes']:
        for source in EXAMPLE['scene_fragment']['walls']:
            scene['walls'][source['index']]['objects'].extend(copy.deepcopy([
                obj for obj in source['objects'] if obj['kind'] in CONTEXT]))
    return timeline,game


def context_object(timeline,kind='paper_stack'):
    return next(obj for wall in timeline['scenes'][0]['walls'] for obj in wall['objects'] if obj['kind']==kind)


class DrawingMaterialPropsTests(unittest.TestCase):
    def test_documented_context_fragments_join_a_complete_continuous_game(self):
        timeline,game=fixture();result=validation.check_data(timeline,game)
        self.assertEqual(result['world_renderer'],'drawing')
        self.assertEqual(result['digit_map'][5]['at'],120)
        self.assertEqual(validation.DRAWING_CONTEXT_KINDS,CONTEXT)
        self.assertFalse(CONTEXT & validation.SCHOOL_OBJECT_KINDS)
        self.assertEqual([len(prompt['choice_keys']) for prompt in result['interaction_prompts']],
            [2,1,0,2,1,0,2,1,0,0])

    def test_each_new_landmark_keeps_author_canvas_and_continuity_contracts(self):
        for kind in CONTEXT:
            for field,value in [('author','adb'),('x',1920),('y',0),('kind','unknown')]:
                timeline,game=fixture();context_object(timeline,kind)[field]=value
                with self.subTest(kind=kind,field=field),self.assertRaises(ValueError):
                    validation.check_data(timeline,game)
            timeline,game=fixture();context_object(timeline,kind)['x']+=1
            with self.subTest(kind=kind,field='continuity'),self.assertRaisesRegex(ValueError,'matching walls'):
                validation.check_data(timeline,game)

    def test_context_objects_do_not_display_unadvertised_choice_labels(self):
        for kind in CONTEXT:
            for text in ['3 OPEN INVENTORY',None,0]:
                timeline,game=fixture();context_object(timeline,kind)['text']=text
                with self.subTest(kind=kind,text=text),self.assertRaisesRegex(ValueError,'choice text'):
                    validation.check_data(timeline,game)

    def test_fixed_landmarks_cannot_silently_own_existing_material_actions(self):
        for kind in CONTEXT:
            timeline,game=fixture();obj=context_object(timeline,kind)
            timeline['scenes'][0]['environment_events']=[{'id':'invalid_context_fold',
                'object':obj['id'],'kind':'tab_fold','at':2,'end':3,'event':'new_interaction'}]
            with self.subTest(kind=kind),self.assertRaisesRegex(ValueError,'held scenery'):
                validation.check_data(timeline,game)

    def test_context_props_cannot_acquire_vehicle_paths_reveals_or_material_flags(self):
        for changes in [{'path':[{'at':2,'position':[1420,905]},{'at':3,'position':[1500,905]}]},
                {'folded':True},{'opened':True},{'erasing':True},{'visible_from_event':'new_interaction'}]:
            timeline,game=fixture();context_object(timeline).update(changes)
            with self.subTest(changes=changes),self.assertRaises(ValueError):
                validation.check_data(timeline,game)

    def test_audition_has_the_same_held_context_guards(self):
        fragment=copy.deepcopy(EXAMPLE['scene_fragment']);fragment['start']=0;fragment['end']=45
        data={'kind':'audition','playable':False,'duration':45,'fps':30,
            'world_renderer':'drawing','scenes':[fragment]}
        self.assertEqual(validation.check_audition_data(data)['world_renderer'],'drawing')
        obj=next(obj for wall in fragment['walls'] for obj in wall['objects'] if obj['kind']=='paper_stack')
        fragment['environment_events']=[{'id':'invalid','kind':'tab_fold','object':obj['id'],
            'at':2,'end':3,'event':'new_interaction'}]
        with self.assertRaisesRegex(ValueError,'held scenery'):validation.check_audition_data(data)


if __name__=='__main__':unittest.main()
