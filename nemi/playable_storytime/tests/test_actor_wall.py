"""Keep side-sector staging explicit while preserving default school scenes."""
import copy
import importlib.util
from pathlib import Path
import unittest

PROJECT=Path(__file__).resolve().parents[1]
module_spec=importlib.util.spec_from_file_location('actor_wall_validation',PROJECT/'tools/validate_episode.py')
validation=importlib.util.module_from_spec(module_spec)
module_spec.loader.exec_module(validation)


def full_fixture():
    timeline={'duration':240,'fps':30,'scenes':[{'id':'single','start':0,'end':240,
        'walls':[{'index':index,'objects':[]} for index in range(4)]}]}
    game={'duration':240,'automatic_state':False,'challenges':[],'routes':[]}
    return timeline,game


def audition_fixture():
    timeline,_=full_fixture()
    timeline.update(kind='audition',playable=False,duration=40,world_renderer='drawing')
    timeline['scenes'][0].update(end=40,location='sketchbook')
    return timeline


class ActorWallContract(unittest.TestCase):
    def test_absence_preserves_default_front_school_composition(self):
        timeline,game=full_fixture()
        before=copy.deepcopy(timeline)
        validation.check_data(timeline,game)
        self.assertEqual(validation.actor_wall(timeline['scenes'][0]),0)
        self.assertEqual(timeline,before,'Validation must not add staging fields to existing episodes')

    def test_all_four_explicit_faces_are_accepted_in_both_paths(self):
        for wall in range(4):
            with self.subTest(wall=wall):
                timeline,game=full_fixture()
                timeline['scenes'][0]['actor_wall']=wall
                validation.check_data(timeline,game)
                audition=audition_fixture()
                audition['scenes'][0]['actor_wall']=wall
                validation.check_audition_data(audition)
                self.assertEqual(validation.actor_wall(audition['scenes'][0]),wall)

    def test_invalid_values_cannot_silently_reposition_the_actor(self):
        for value in [True,False,0.0,1.0,-1,4,'left',None,[],{},float('nan'),float('inf')]:
            with self.subTest(value=value):
                timeline,game=full_fixture()
                timeline['scenes'][0]['actor_wall']=value
                with self.assertRaisesRegex(ValueError,'Actor wall'):
                    validation.check_data(timeline,game)
                audition=audition_fixture()
                audition['scenes'][0]['actor_wall']=value
                with self.assertRaisesRegex(ValueError,'Actor wall'):
                    validation.check_audition_data(audition)

    def test_side_staging_does_not_change_continuous_world_layout(self):
        audition=audition_fixture()
        first=audition['scenes'][0]
        first['end']=20
        second=copy.deepcopy(first)
        second.update(id='side_outcome',start=20,end=40,actor_wall=3)
        audition.update(world_continuity=True,scenes=[first,second])
        self.assertTrue(validation.check_audition_data(audition)['world_continuity'])
        self.assertEqual(validation.actor_wall(first),0)
        self.assertEqual(validation.actor_wall(second),3)


if __name__=='__main__':unittest.main()
