"""Recovery text cannot precede the finite authored outcome it refers to."""
import copy
import importlib.util
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('reveal_validation',ROOT/'tools/validate_episode.py')
validation=importlib.util.module_from_spec(spec);spec.loader.exec_module(validation)


def fixture():
    return {'start':24,'end':48,'walls':[{'index':0,'objects':[
        {'id':'door','kind':'sketch_door','author':'nemi','x':1100,'y':610},
        {'id':'retry','kind':'paper_exit','author':'nemi','x':960,'y':330,
         'text':'2 TAKE THE TEAR','visible_from_event':'door_rewind'}]}],
        'environment_events':[{'id':'rewind','kind':'rewind','object':'door',
            'at':37.2,'end':38.3,'event':'door_rewind'}]}


class RecoveryRevealTests(unittest.TestCase):
    def test_recovery_binds_to_the_existing_absolute_outcome_event(self):
        scene=fixture()
        validation.validate_world_reveals(scene,'drawing')
        self.assertEqual(scene['environment_events'][0]['at'],37.2)

    def test_default_held_art_keeps_its_existing_behavior(self):
        scene=fixture();scene['walls'][0]['objects'][1].pop('visible_from_event')
        scene['environment_events']=[]
        validation.validate_world_reveals(scene,'drawing')
        validation.validate_world_reveals(scene,'school')

    def test_anchor_must_be_unique_named_and_inside_the_owning_scene(self):
        for edit in ['missing','empty','space','non_string','duplicate','early','at_end','nan']:
            scene=fixture();obj=scene['walls'][0]['objects'][1]
            if edit=='missing':obj['visible_from_event']='unknown'
            if edit=='empty':obj['visible_from_event']=''
            if edit=='space':obj['visible_from_event']=' door_rewind'
            if edit=='non_string':obj['visible_from_event']=True
            if edit=='duplicate':scene['environment_events'].append(copy.deepcopy(scene['environment_events'][0]))
            if edit=='early':scene['environment_events'][0]['at']=23.9
            if edit=='at_end':scene['environment_events'][0]['at']=48
            if edit=='nan':scene['environment_events'][0]['at']=float('nan')
            with self.subTest(edit=edit),self.assertRaises(ValueError):
                validation.validate_world_reveals(scene,'drawing')

    def test_visibility_cannot_hide_arbitrary_props_or_school_content(self):
        for renderer,kind in [('drawing','sketch_door'),('school','paper_exit')]:
            scene=fixture();scene['walls'][0]['objects'][1]['kind']=kind
            with self.subTest(renderer=renderer,kind=kind),self.assertRaisesRegex(ValueError,'only on drawing paper_exit'):
                validation.validate_world_reveals(scene,renderer)

    def test_continuity_layout_includes_reveal_ownership(self):
        before=fixture();after=copy.deepcopy(before)
        after['walls'][0]['objects'][1]['visible_from_event']='other_rewind'
        self.assertNotEqual(validation.continuity_layout(before),validation.continuity_layout(after))


if __name__=='__main__':unittest.main()
