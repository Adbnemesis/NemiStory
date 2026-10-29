"""An erasing vehicle is one finite authored road action, never input logic."""
import copy
import importlib.util
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
loader=importlib.util.spec_from_file_location('erasing_validation',ROOT/'tools/validate_episode.py')
validation=importlib.util.module_from_spec(loader);loader.loader.exec_module(validation)


def fixture():
    return {'start':144,'end':168,'walls':[{'index':3,'objects':[
        {'id':'escape_vehicle','kind':'ride_eraser','author':'nemi','x':440,'y':925,
         'text':'8 RIDE IT','erasing':True,
         'path':[{'at':148,'position':[440,925]},{'at':156,'position':[650,925]}]}]}],
        'environment_events':[{'id':'eraser_approach_world','kind':'eraser_pass',
            'object':'escape_vehicle','event':'eraser_approach','at':148,'end':156}]}


def check(scene,renderer='drawing'):
    validation.validate_world_material_states(scene,renderer)
    validation.validate_world_paths(scene,renderer)


class ErasingVehicleTests(unittest.TestCase):
    def test_same_solid_vehicle_uses_its_existing_finite_path_and_event(self):
        scene=fixture();check(scene)
        self.assertEqual(scene['walls'][0]['objects'][0]['path'][-1]['position'],[650,925])
        self.assertNotIn('actor_transport',scene)

    def test_erasing_is_a_strict_boolean_on_drawing_ride_erasers_only(self):
        for edit in ['integer','string','null','other_kind','school']:
            scene=fixture();obj=scene['walls'][0]['objects'][0];renderer='drawing'
            if edit=='integer':obj['erasing']=1
            if edit=='string':obj['erasing']='true'
            if edit=='null':obj['erasing']=None
            if edit=='other_kind':obj['kind']='eraser'
            if edit=='school':renderer='school'
            with self.subTest(edit=edit),self.assertRaises(ValueError):check(scene,renderer)

    def test_erasing_cannot_appear_without_an_authored_matching_action(self):
        for edit in ['no_path','short_path','no_event','wrong_event','shifted_event','duplicate_event']:
            scene=fixture();obj=scene['walls'][0]['objects'][0]
            if edit=='no_path':obj.pop('path')
            if edit=='short_path':obj['path']=obj['path'][:1]
            if edit=='no_event':scene['environment_events']=[]
            if edit=='wrong_event':scene['environment_events'][0]['kind']='bridge_break'
            if edit=='shifted_event':scene['environment_events'][0]['at']+=.1
            if edit=='duplicate_event':scene['environment_events'].append(copy.deepcopy(scene['environment_events'][0]))
            with self.subTest(edit=edit),self.assertRaises(ValueError):check(scene)

    def test_ink_strip_cannot_climb_reverse_or_pause_halfway_through_erasing(self):
        for positions in [
            [[440,925],[650,900]],
            [[440,925],[540,925],[500,925]],
            [[440,925],[440,925],[650,925]],
        ]:
            scene=fixture();obj=scene['walls'][0]['objects'][0]
            obj['path']=[{'at':148+8*index/(len(positions)-1),'position':position}
                         for index,position in enumerate(positions)]
            with self.subTest(positions=positions),self.assertRaises(ValueError):check(scene)

    def test_leftward_and_multisegment_level_travel_are_explicitly_supported(self):
        for positions in [ [[440,925],[520,925],[650,925]], [[440,925],[350,925],[250,925]] ]:
            scene=fixture();obj=scene['walls'][0]['objects'][0]
            obj['path']=[{'at':148+4*index,'position':position} for index,position in enumerate(positions)]
            with self.subTest(positions=positions):check(scene)

    def test_existing_non_erasing_vehicle_art_and_paths_keep_their_contract(self):
        for erasing in [None,False]:
            scene=fixture();obj=scene['walls'][0]['objects'][0]
            if erasing is None:obj.pop('erasing')
            else:obj['erasing']=False
            obj.pop('path');scene['environment_events']=[]
            with self.subTest(erasing=erasing):check(scene)
        scene=fixture();obj=scene['walls'][0]['objects'][0];obj['erasing']=False
        obj['path'][-1]['position'][1]=900
        check(scene)

    def test_continuity_identity_distinguishes_erasing_from_non_erasing_art(self):
        before=fixture();after=copy.deepcopy(before);after['walls'][0]['objects'][0]['erasing']=False
        self.assertNotEqual(validation.continuity_layout(before),validation.continuity_layout(after))
        omitted=copy.deepcopy(after);omitted['walls'][0]['objects'][0].pop('erasing')
        self.assertEqual(validation.continuity_layout(after),validation.continuity_layout(omitted))


if __name__=='__main__':unittest.main()
