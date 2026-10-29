"""Regress the lost-view bug at an uninterrupted successful story handoff."""
import copy
import importlib.util
from pathlib import Path
import unittest

TOOLS = Path(__file__).resolve().parents[1] / 'tools'
loader = importlib.util.spec_from_file_location('natural_join_validation', TOOLS / 'continuity.py')
module = importlib.util.module_from_spec(loader)
loader.loader.exec_module(module)


def fixture():
    prop = dict(id='paper', kind='paper_tab', x=500, y=837)
    timeline = dict(world_renderer='drawing', scenes=[
        dict(id='crossing', start=120, end=144, actor_wall=2,
             walls=[dict(index=2, objects=[copy.deepcopy(prop)])]),
        dict(id='next_thought', start=144, end=168, actor_wall=2,
             walls=[dict(index=2, objects=[copy.deepcopy(prop) | {'folded': True}])]),
    ], natural_continuity=[dict(at=144, from_scene='crossing', to_scene='next_thought',
        actor_wall=2, position=[320, 620], landmark='paper')])
    spec = dict(shots=[
        dict(start=120, end=138, actors={'nemi':dict(position=[1000,620],scale=1.4)}),
        dict(start=138, end=144, actors={'nemi':dict(position=[320,620],scale=1.4)}),
        dict(start=144, end=168, actors={'nemi':dict(position=[320,620],scale=1.4)}),
    ])
    return timeline, spec


class NaturalJoinTests(unittest.TestCase):
    def test_success_inherits_authored_arrival_and_completed_landmark(self):
        timeline, spec = fixture()
        self.assertEqual(len(module.validate_natural_joins(timeline, spec)), 1)

    def test_same_wall_still_rejects_old_centre_reset(self):
        timeline, spec = fixture()
        spec['shots'][-1]['actors']['nemi']['position'] = [960,620]
        with self.assertRaisesRegex(ValueError, 'teleports'):
            module.validate_natural_joins(timeline, spec)

    def test_old_front_sector_reset_is_rejected(self):
        timeline, spec = fixture()
        timeline['scenes'][-1]['actor_wall'] = 0
        with self.assertRaisesRegex(ValueError, 'sphere sector'):
            module.validate_natural_joins(timeline, spec)

    def test_vehicle_join_uses_actual_travel_endpoint(self):
        timeline, spec = fixture()
        vehicle=dict(id='paper',kind='ride_eraser',x=650,y=925,
                     path=[dict(at=125,position=[650,925]),dict(at=133,position=[1150,925])])
        timeline['scenes'][0]['walls'][0]['objects']=[vehicle]
        timeline['scenes'][0]['actor_transport']=dict(actor='nemi',object='paper',event='travel')
        timeline['scenes'][1]['walls'][0]['objects'][0]=dict(id='paper',kind='ride_eraser',x=650,y=925)
        timeline['natural_continuity'][0]['position']=[1150,620]
        spec['shots']= [dict(start=120,end=144,actors={'nemi':dict(position=[650,620],scale=1.4)}),
                       dict(start=144,end=168,actors={'nemi':dict(position=[1150,620],scale=1.4)})]
        module.validate_natural_joins(timeline,spec)
        spec['shots'][-1]['actors']['nemi']['position']=[650,620]
        with self.assertRaisesRegex(ValueError,'teleports'):
            module.validate_natural_joins(timeline,spec)

    def test_new_round_card_and_lost_landmark_are_rejected(self):
        for change in ['card','landmark','boundary','unknown','unfinished']:
            timeline,spec=fixture()
            if change=='card':timeline['scenes'][1]['entry_card']={'title':'ROUND TWO'}
            if change=='landmark':timeline['scenes'][1]['walls'][0]['objects'][0]['x']=900
            if change=='boundary':timeline['natural_continuity'][0]['at']=143
            if change=='unknown':timeline['natural_continuity'][0]['callback']='turn_view'
            if change=='unfinished':timeline['scenes'][1]['walls'][0]['objects'][0]['folded']=False
            with self.subTest(change=change),self.assertRaises(ValueError):
                module.validate_natural_joins(timeline,spec)

    def test_historical_timelines_need_no_continuity_descriptor(self):
        self.assertEqual(module.validate_natural_joins({'scenes':[]}),[])


if __name__=='__main__':unittest.main()
