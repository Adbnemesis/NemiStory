"""Plan the actual entry-card and post-card evidence without a movie render."""
import importlib.util
from pathlib import Path
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
spec=importlib.util.spec_from_file_location('result_media_qa',ROOT/'tools/result_media_qa.py')
qa=importlib.util.module_from_spec(spec);spec.loader.exec_module(qa)

def fixture():
    scenes=[];prompts=[];landings=[]
    for key in range(10):
        scenes.append({'id':f's{key}','start':key*24,'end':(key+1)*24,
            'entry_card':{'duration':3.5,'title':f'{key} RESULT','subtitle':'Choose your next route'}})
        prompts.append({'id':f's{key}','choices':[{'key':(key+1)%10,'label':'Continue','chapter':f's{(key+1)%10}'}]})
        landings.append({'key':key,'chapter':f's{key}','encoded_percentage_seconds':key*24})
    timeline={'scenes':scenes,'interaction_scenes':prompts}
    clock={'clock_passed':True,'fps':30,'frame_seconds':1/30,'landings':landings,'actual_duration_seconds':240}
    return timeline,{},clock

class ResultMediaPlanTests(unittest.TestCase):
    def setUp(self):self.timeline,self.game,self.clock=fixture()
    def plan(self):return qa.result_plan(self.timeline,self.game,self.clock)
    def test_ten_entries_four_directions_and_ten_returns(self):
        plan,choices=self.plan()
        self.assertEqual(len(plan),50);self.assertEqual(len(choices),10)
        entries=[item for item in plan if item['kind']=='entry_card']
        returns=[item for item in plan if item['kind']=='actor_return']
        self.assertEqual(len(entries),40);self.assertEqual(len(returns),10)
        self.assertEqual([item['yaw'] for item in entries[:4]],[0,90,180,-90])
        self.assertEqual(entries[0]['at'],.8);self.assertEqual(returns[0]['at'],3.8)
        self.assertEqual(entries[1]['expected_direction_guide'],'TURN LEFT TO NEMI')
    def test_choices_bind_real_target_entry_title(self):
        _,choices=self.plan()
        self.assertEqual(choices[0]['chapter'],'s1')
        self.assertEqual(choices[0]['expected_entry_title'],'1 RESULT')
        self.assertEqual(choices[-1]['encoded_percentage_seconds'],0)
    def test_every_digit_needs_entry_card(self):
        self.timeline['scenes'][4].pop('entry_card')
        with self.assertRaisesRegex(ValueError,'Every digit scene'):self.plan()
    def test_card_hold_outside_supported_lifetime_rejected(self):
        self.timeline['scenes'][0]['entry_card']['duration']=.5
        with self.assertRaisesRegex(ValueError,'2–4'):self.plan()
    def test_actor_return_must_fit_scene(self):
        self.timeline['scenes'][0]['end']=3.7
        with self.assertRaisesRegex(ValueError,'Actor return sample'):self.plan()
    def test_actual_landing_frame_error_rejected(self):
        self.clock['landings'][2]['encoded_percentage_seconds']+=.1
        with self.assertRaisesRegex(ValueError,'at least one frame'):self.plan()
    def test_wrong_choice_target_rejected(self):
        self.timeline['interaction_scenes'][0]['choices'][0]['chapter']='s3'
        with self.assertRaisesRegex(ValueError,'Choice target'):self.plan()
    def test_incomplete_prompt_array_rejected(self):
        self.timeline['interaction_scenes'].pop()
        with self.assertRaisesRegex(ValueError,'every interaction prompt'):self.plan()

class DrawingResultMediaPlanTests(unittest.TestCase):
    def setUp(self):
        self.timeline,self.game,self.clock=fixture();self.timeline['world_renderer']='drawing'
        for index,scene in enumerate(self.timeline['scenes']):scene['actor_wall']=[0,3,1][index%3]
        self.timeline['scenes'][0].pop('entry_card');self.timeline['scenes'][6].pop('entry_card')
    def plan(self):return qa.result_plan(self.timeline,self.game,self.clock)
    def test_sparse_drawing_cards_still_capture_ten_four_way_entries(self):
        plan,choices=self.plan();entries=[item for item in plan if item['kind']=='entry_view']
        returns=[item for item in plan if item['kind']=='actor_return']
        self.assertEqual((len(plan),len(entries),len(returns)),(50,40,10))
        self.assertEqual([item['at'] for item in entries[:4]],[.8]*4)
        self.assertTrue(all('expected_title' not in item for item in entries[:4]))
        self.assertTrue(all(item['expected_direction_guide'] is None for item in entries[:4]))
        self.assertNotIn('expected_entry_title',choices[-1])
        self.assertFalse(choices[-1]['entry_card_present'])
    def test_guides_are_relative_to_the_actual_side_actor_wall(self):
        plan,_=self.plan();left=[item for item in plan if item['kind']=='entry_view' and item['key']==1]
        right=[item for item in plan if item['kind']=='entry_view' and item['key']==2]
        self.assertEqual([item['expected_direction_guide'] for item in left],['← TURN LEFT','TURN AROUND','TURN RIGHT →','HERE'])
        self.assertEqual([item['expected_direction_guide'] for item in right],['TURN RIGHT →','HERE','← TURN LEFT','TURN AROUND'])
    def test_actor_returns_sample_the_selected_wall_not_always_front(self):
        plan,_=self.plan();returns=[item for item in plan if item['kind']=='actor_return']
        self.assertEqual([item['wall_index'] for item in returns[:3]],[0,3,1])
        self.assertEqual([item['yaw'] for item in returns[:3]],[0,-90,90])
        self.assertEqual(returns[0]['at'],3.3)
        self.assertEqual(returns[1]['at'],27.8)
        self.assertNotIn('entry_ended_at_authored_seconds',returns[0])
        self.assertEqual(returns[0]['sample_basis'],'scene_start_plus_3.3_seconds')
    def test_drawing_source_still_rejects_bad_card_or_clock(self):
        self.timeline['scenes'][1]['entry_card']['duration']=1
        with self.assertRaisesRegex(ValueError,'2–4'):self.plan()
        self.timeline['scenes'][1]['entry_card']['duration']=3.5
        self.clock['landings'][1]['encoded_percentage_seconds']+=.1
        with self.assertRaisesRegex(ValueError,'at least one frame'):self.plan()
    def test_invalid_actor_wall_is_not_silently_mapped_to_front(self):
        self.timeline['scenes'][1]['actor_wall']=4
        with self.assertRaisesRegex(ValueError,'Actor wall'):self.plan()
    def test_uncarded_actor_sample_must_fit_the_scene(self):
        self.timeline['scenes'][0]['end']=3.2
        with self.assertRaisesRegex(ValueError,'Actor return sample'):self.plan()

if __name__=='__main__':unittest.main()
