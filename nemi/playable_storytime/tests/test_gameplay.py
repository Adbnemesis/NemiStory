import copy, importlib.util, json, unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
s=importlib.util.spec_from_file_location('validation',ROOT/'tools/validate_episode.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
class GameTests(unittest.TestCase):
    def setUp(self):
        ep=ROOT/'episodes/episode_001';self.t=json.loads((ep/'storyboard/timeline.json').read_text());self.g=json.loads((ep/'gameplay/manifest.json').read_text())
    def test_all_intended_routes(self):
        routes=m.check_data(self.t,self.g)['routes']
        self.assertEqual({route['id'] for route in routes},{'passive','main','all_silly'})
        self.assertTrue(all(route['pass'] for route in routes))
    def environment_fixture(self):
        # Add one valid, finite cue before corrupting it so these guard tests
        # do not depend on which effects the current episode schedules.
        scene=self.t['scenes'][0]
        target=next(o for wall in scene['walls'] for o in wall['objects'])
        event={'id':'fixture_paper','object':target['id'],'kind':'paper_flap',
            'at':scene['start']+4,'end':scene['start']+4.5,'event':'fixture_named_event'}
        scene['environment_events']=[event]
        m.check_data(self.t,self.g)
        return scene,event
    def test_unreachable_destination_rejected(self):
        self.g['challenges'][0]['valid_destinations']=[87]
        with self.assertRaisesRegex(ValueError,'Destination'):m.check_data(self.t,self.g)
    def test_missing_required_clue_rejected(self):
        self.t['scenes'][1]['walls'][3]['objects']=[o for o in self.t['scenes'][1]['walls'][3]['objects'] if o['id']!='star_badge']
        with self.assertRaisesRegex(ValueError,'missing'):m.check_data(self.t,self.g)
    def test_wrong_printed_clue_rejected(self):
        challenge=self.g['challenges'][0]
        scene=next(s for s in self.t['scenes'] if s['start']<challenge['end'] and s['end']>challenge['start'])
        clue=next(o for w in scene['walls'] for o in w['objects'] if o['id']==challenge['clue_id'])
        self.assertIn(challenge['solution'],clue['text'])
        clue['text']=clue['text'].replace(challenge['solution'],'WRONG CLUE')
        with self.assertRaisesRegex(ValueError,'disagrees'):m.check_data(self.t,self.g)
    def test_fake_state_rejected(self):
        self.g['challenges'][0]['state_tracking']=True
        with self.assertRaisesRegex(ValueError,'automatic'):m.check_data(self.t,self.g)
    def test_scene_gap_rejected(self):
        self.t['scenes'][1]['start']=30.1
        with self.assertRaisesRegex(ValueError,'gap'):m.check_data(self.t,self.g)
    def test_polar_clue_rejected(self):
        self.t['scenes'][1]['walls'][3]['objects'][-3]['y']=10
        with self.assertRaisesRegex(ValueError,'pole'):m.check_data(self.t,self.g)
    def test_missing_author_rejected(self):
        self.t['scenes'][0]['walls'][0]['objects'][0].pop('author')
        with self.assertRaisesRegex(ValueError,'author'):m.check_data(self.t,self.g)
    def test_unbounded_environment_event_rejected(self):
        scene,event=self.environment_fixture();event['end']=scene['end']+.1
        with self.assertRaisesRegex(ValueError,'lifetime'):m.check_data(self.t,self.g)
    def test_environment_event_missing_prop_rejected(self):
        scene,event=self.environment_fixture();event['object']='missing_fixture_prop'
        with self.assertRaisesRegex(ValueError,'missing prop'):m.check_data(self.t,self.g)
    def test_unreachable_alternative_rejected(self):
        self.g['challenges'][1]['alternative_outcomes']=[152]
        with self.assertRaisesRegex(ValueError,'Alternative'):m.check_data(self.t,self.g)
    def test_unreachable_retry_rejected(self):
        self.g['challenges'][0]['retry_method']='Manually seek to 0:31'
        with self.assertRaisesRegex(ValueError,'Retry'):m.check_data(self.t,self.g)
if __name__=='__main__':unittest.main()
